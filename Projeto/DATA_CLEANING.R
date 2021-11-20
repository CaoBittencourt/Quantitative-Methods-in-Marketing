# PACOTES -----------------------------------------------------------------
pkg <- c(
  'rio' #Leitura de XML
  ,'naniar','tidyverse' #Manipulação de dados e datas
)

# Ativa e/ou instala os pacotes 
lapply(pkg, function(x)
  if(!require(x, character.only = T))
  {install.packages(x); require(x)})

# lapply(pkg, function(x)
#   {citation(package = x)})
# Citação dos pacotes


# DADOS -------------------------------------------------------------------
setwd('C:/Users/Sony/Documents/GitHub/QMM/Projeto')

# Heritage Index
df.heritage.index <- read.csv(
  url('https://docs.google.com/spreadsheets/d/e/2PACX-1vQ6Sh1g2BJg5rdGHeLn292gHQKyB1eT_Nfe22RtJqLX6evyVSrBMcrlTo58wUlJxrIGRROyWoRM3xhu/pub?gid=769896488&single=true&output=csv')
  ,encoding = 'UTF-8')

# Educação e variáveis demográficas
df.indicators <- read.csv(
  'world_bank_indicators.csv'
  ,encoding = 'UTF-8')

# Corruption Perception Index (CPI)
df.cpi <- read.csv(
  url('https://docs.google.com/spreadsheets/d/e/2PACX-1vSj_c2eW0u0K_WexAlZpz3dzIQ97pjVv6fp-gHQhuJXjmOk6xaTahmfUZzOESB2jQ/pub?gid=2693956&single=true&output=csv')
  ,encoding = 'UTF-8')

df.imo <- import('IMO_Team_2017.xml')

# LIMPEZA DOS DADOS (NOMES E FORMATOS) -------------------------------------------------------
# heritage.index %>% glimpse(.)
# df.indicators %>% glimpse(.)
# cpi %>% glimpse(.)

# # Nomes
# Heritage
df.heritage.index %>% 
  names(.) -> names.new

names.new %>%
  str_to_upper(.) %>%
  str_replace_all('\\.\\.\\.\\.', '_PRCT') %>%
  str_replace_all('\\.\\.\\.', '_') %>%
  str_replace_all('\\.\\.', '_') %>%
  str_replace_all('\\.', '_') %>%
  str_replace_all('COUNTRYID', 'ID') %>%
  str_replace_all('GOV_T', 'GOV') %>%
  str_replace_all('PRCTOF.GDP', 'PRCT_OF_GDP') %>% 
  str_replace_all('X2017_SCORE', 'HERITAGE_INDEX_2017') %>% 
  str_replace_all('X5', 'FIVE') %>% 
  str_remove_all('_$') -> names.new

df.heritage.index %>%
  setNames(names.new) -> df.heritage.index

# World Bank
df.indicators %>%
  setNames(c('COUNTRY', 'SERIES', 'VALUE')) -> df.indicators

df.indicators %>% 
  filter(SERIES != '') %>% 
  pivot_wider(names_from = SERIES
              , values_from = VALUE) -> df.indicators

df.indicators %>% 
  names(.) -> indicators.names

indicators.names %>%
  str_to_upper(.) %>%
  str_remove_all('\\(') %>%
  str_remove_all('\\)') %>%
  str_replace_all('%', '_PRCT') %>%
  str_replace_all(' ', '_') %>%
  str_replace_all('__', '_') %>%
  str_replace_all(',', '') %>%
  str_replace_all('GINI_INDEX_WORLD_BANK_ESTIMATE', 'GINI_INDEX') %>%
  str_replace_all('ADOLESCENTS', 'TEENS') %>%
  str_replace_all('GOVERNMENT', 'GOV') %>%
  str_replace_all('POPULATION', 'POP') %>%
  str_replace_all('ON_EDUCATION_TOTAL', 'EDUC') %>%
  str_replace_all('-', 'TO') %>%
  str_remove_all('AT_BIRTH_TOTAL_YEARS') %>%
  str_remove_all('OF_LOWER_SECONDARY_SCHOOL_AGE') %>%
  str_remove_all('OF_PRIMARY_SCHOOL_AGE') %>%
  str_remove_all('OF_TOTAL_POP') %>%
  str_remove_all('_TOTAL_PRCT_OF_PEOPLE.*$') %>%
  str_replace_all('__', '_') %>%
  str_remove_all('_$') -> indicators.names

df.indicators %>%
  setNames(indicators.names) -> df.indicators

# Olimpiada Internacional de Matemática
df.imo %>% 
  rename_with(toupper) %>% 
  rename(COUNTRY = NAME) -> df.imo

# # Formatos corretos
# Corruption Perception Index
cpi.fct <- c(
  'COUNTRY'
  , 'ISO3'
  , 'REGION'
)

# cpi.prct <- 'CPI_SCORE_2017'

# Heritage
heritage.fct <- c(
  'ID'
  ,'COUNTRY_NAME'
  ,'WEBNAME'
  ,'REGION'
  ,'COUNTRY'
)

heritage.million <- names.new[str_detect(names.new, 'MILLI')]

heritage.billion <- names.new[str_detect(names.new, 'BILLI')]

# World Bank
indicators.fct <- 'COUNTRY'

# Olimpiada Internacional de Matemática
imo.fct <- 'COUNTRY'

Map(
  function(df, fct, prct, mill, bill){
    
    df %>% 
      mutate(
        # Fatores
        across(
          .cols = all_of(fct)
          , ~ factor(.x)
        )
        # Milhões
        ,across(
          .cols = all_of(mill)
          , ~ .x * 1000000
        )
        # Bilhões
        ,across(
          .cols = all_of(bill)
          , ~ .x * 1000000000
        )
      ) %>% 
      rename_with(~ str_remove_all(.x, 'MILLIONS')) %>% 
      rename_with(~ str_remove_all(.x, 'BILLIONS')) %>% 
      rename_with(~ str_replace_all(.x, '__','_')) %>%
      rename_with(~ str_remove_all(.x, '_$')) -> df
    
  }
  , df = list('cpi' = df.cpi, 'heritage' = df.heritage.index, 'indicators' = df.indicators, 'imo' = df.imo)
  , fct = list('cpi' = cpi.fct, 'heritage' = heritage.fct, 'indicators' = indicators.fct, 'imo' = imo.fct)
  , mill = list('cpi' = NULL, 'heritage' = heritage.million, 'indicators' = NULL, 'imo' = NULL)
  , bill = list('cpi' = NULL, 'heritage' = heritage.billion, 'indicators' = NULL, 'imo' = NULL)
) -> df.list

# BASE DE DADOS AGREGADA -----------------------------------------------------
df.list$cpi %>% 
  inner_join(df.list$heritage, by = c('COUNTRY' = 'COUNTRY_NAME'), suffix = c('.x','.y')) %>%
  inner_join(df.list$indicators, by = c('COUNTRY' = 'COUNTRY'), suffix = c('','.y')) %>%
  inner_join(df.list$imo, by = c('COUNTRY' = 'COUNTRY'), suffix = c('','.y')) %>%
  select(-ends_with('.x'), -ends_with('.y'), 'REGION.y') %>%
  rename(REGION = REGION.y) -> df.agg

# MISSING VALUES -----------------------------------------
naniar::vis_miss(df.agg) 
naniar::gg_miss_fct(df.agg, REGION)

# Solução adotada: imputação da mediana
# Para melhor adequar os valores imputados, 
# a mediana é calculada com base em grupos de países específicos
df.agg %>%
  group_by(REGION) %>%
  mutate(
    GDP_PER_CAPITA_PPP = ifelse(
      is.na(GDP_PER_CAPITA_PPP)
      , yes = mean(GDP_PER_CAPITA_PPP, na.rm = T), no = GDP_PER_CAPITA_PPP)
    
    , GDP_PER_CAPITA_QUANTILE = cut(
      GDP_PER_CAPITA_PPP
      , quantile(GDP_PER_CAPITA_PPP) #Quantis de renda per capita por região
      , include.lowest = T
      , right = T)
    
  ) %>% 
  group_by(REGION, factor(GDP_PER_CAPITA_QUANTILE)) %>%
  mutate(across(# NA'S nas colunas numéricas => mediana da região e do grupo (quantil) de renda per capita
    .cols = where(~ is.numeric(.))
    ,.fns = function(x){ifelse(
      is.na(x)
      , yes = median(x, na.rm = T), no = x)} 
  )) %>% 
  group_by(REGION) %>% #Ainda restam alguns casos (coincidência de NA's em regiões e quantis de renda específicos)
  mutate(across(# NA'S nas colunas numéricas => mediana da região e do grupo (quantil) de renda per capita
    .cols = where(~ is.numeric(.))
    ,.fns = function(x){ifelse(
      is.na(x)
      , yes = median(x, na.rm = T), no = x)} 
  )) %>% 
  ungroup(.) %>% #Ainda alguns pouquíssimos casos (Banco Mundial não disponibiliza o índice de GINI de uma região inteira) => drop
  drop_na(.) -> df.agg

naniar::vis_miss(df.agg)
naniar::gg_miss_fct(df.agg, REGION)

# VARIÁVEIS ADICIONAIS ----------------------------------------------------
# Dummies CPI Score
df.agg %>%
  mutate(
    DUMMY_CPI = ifelse(CPI_SCORE_2017 >= 70, yes = 1, no = 0)
    ,DUMMY_CPI_ORDERED = case_when(CPI_SCORE_2017 <= 30 ~ 1
                                   
                                   ,CPI_SCORE_2017 < 70 & 
                                     CPI_SCORE_2017 > 30 ~ 2
                                   
                                   ,CPI_SCORE_2017 >= 70 ~ 3
    )
    ,across(
      .cols = contains('_OF_GDP')
      , ~ .x * GDP_PPP
      ,.names = '{.col}_remove_suffix'
    )
  ) %>% 
  rename_with(.cols = contains('_remove_suffix')
              , .fn = function(x){
                x %>% 
                  str_remove('_remove_suffix') %>% 
                  str_remove('_OF_GDP') %>% 
                  str_remove('_PRCT') %>% 
                  paste0('_PPP')
              }) -> df.agg

# Variáveis em Log
df.agg %>% 
  mutate(
    across(
      .cols = contains('PPP')
      ,.fns = log
      ,.names = 'log_{.col}'
    )
  ) -> df.aggssss

# EXPORT ------------------------------------------------------------------
write.csv(df.agg, file = 'probit_data.csv')