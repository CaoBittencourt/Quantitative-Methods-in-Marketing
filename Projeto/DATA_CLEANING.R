# PACOTES -----------------------------------------------------------------
pkg <- c(
  # 'readxl' #Leitura de excel
  # 'rio' #Leitura de excel
  'naniar','tidyverse' #Manipulação de dados e datas
  # , 'mxf'
)

# Ativa e/ou instala os pacotes 
lapply(pkg, function(x)
  if(!require(x, character.only = T))
  {install.packages(x); require(x)})

# lapply(pkg, function(x)
#   {citation(package = x)})
# Citação dos pacotes


# DADOS -------------------------------------------------------------------
setwd('C:/Users/Sony/Documents/GitHub/Marketing/Projeto')

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


# LIMPEZA DOS DADOS (NOMES E FORMATOS) -------------------------------------------------------
# heritage.index %>% glimpse(.)
# df.indicators %>% glimpse(.)
# cpi %>% glimpse(.)

# Nomes
setNames(df.indicators, c('COUNTRY', 'SERIES', 'VALUE')) -> df.indicators

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

# Formatos corretos
cpi.fct <- c(
  'COUNTRY'
  , 'ISO3'
  , 'REGION'
)

heritage.fct <- c(
  'ID'
  ,'COUNTRY_NAME'
  ,'WEBNAME'
  ,'REGION'
  ,'COUNTRY'
)

heritage.vars <- c(
  'HERITAGE_INDEX_2017'
  ,'PROPERTY_RIGHTS'
  ,'JUDICAL_EFFECTIVENESS'
  ,'GOVERNMENT_INTEGRITY'
  ,'TAX_BURDEN'
  ,'GOV_SPENDING'
  ,'FISCAL_HEALTH'
  ,'BUSINESS_FREEDOM'
  ,'LABOR_FREEDOM'
  ,'MONETARY_FREEDOM'
  ,'TRADE_FREEDOM'
  ,'INVESTMENT_FREEDOM'
  ,'FINANCIAL_FREEDOM'
)

heritage.prct <- c(heritage.vars, names.new[str_detect(names.new, 'PRCT')])

heritage.million <- names.new[str_detect(names.new, 'MILLI')]

heritage.billion <- names.new[str_detect(names.new, 'BILLI')]


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

indicators.prct <- indicators.names[str_detect(indicators.names, 'PRCT')]
indicators.fct <- 'COUNTRY'

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
        # Porcentagem
        ,across(
          .cols = all_of(prct)
          , ~ .x / 100
        )
      ) %>% 
      rename_with(~ str_remove_all(.x, 'MILLIONS')) %>% 
      rename_with(~ str_remove_all(.x, 'BILLIONS')) %>% 
      rename_with(~ str_replace_all(.x, '__','_')) %>%
      rename_with(~ str_remove_all(.x, '_$')) -> df
    
  }
  , df = list('cpi' = df.cpi, 'heritage' = df.heritage.index, 'indicators' = df.indicators)
  , fct = list('cpi' = cpi.fct, 'heritage' = heritage.fct, 'indicators' = indicators.fct)
  , prct = list('cpi' = NULL, 'heritage' = heritage.prct, 'indicators' = indicators.prct)
  , mill = list('cpi' = NULL, 'heritage' = heritage.million, 'indicators' = NULL)
  , bill = list('cpi' = NULL, 'heritage' = heritage.billion, 'indicators' = NULL)
) -> df.list

# BASE DE DADOS AGREGADA -----------------------------------------------------
# Usar left join para manter apenas aqueles países que têm CPI
df.list$cpi %>% 
  inner_join(df.list$heritage, by = c('COUNTRY' = 'COUNTRY_NAME'), suffix = c('.x','.y')) %>%
  inner_join(df.list$indicators, by = c('COUNTRY' = 'COUNTRY'), suffix = c('','.y')) %>% 
  select(-ends_with('.x'), -ends_with('.y'), 'REGION.y') %>%
  rename(REGION = REGION.y) -> df.agg

# Dummy CPI Score > 0.7
df.agg %>%
  mutate(DUMMY_CPI = ifelse(CPI_SCORE_2017 > .7, yes = 1, no = 0)) -> df.agg

# AJUSTES FINAIS (MISSING VALUES) -----------------------------------------
naniar::vis_miss(df.agg) # Poucos Na's: cerca de 7% da base de dados

# Solução adotada: imputação da mediana
# Para adequar melhor os valores imputados, a mediana é calculada com base em grupos de países específicos
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
  mutate(across(
    # NA'S nas colunas numéricas => mediana da região e do grupo (quantil) de renda per capita
    .cols = where(~ is.numeric(.))
    ,.fns = function(x){ifelse(
      is.na(x)
      , yes = median(x, na.rm = T), no = x)} 
  )) %>% 
  group_by(REGION) %>% #Ainda restam alguns casos (coincidência de NA's em regiões e quantis de renda específicos)
  mutate(across(
    # NA'S nas colunas numéricas => mediana da região e do grupo (quantil) de renda per capita
    .cols = where(~ is.numeric(.))
    ,.fns = function(x){ifelse(
      is.na(x)
      , yes = median(x, na.rm = T), no = x)} 
  )) %>% 
  ungroup(.) %>% #Ainda alguns pouquíssimos casos (Banco Mundial não disponibiliza o índice de GINI de uma região inteira)
  mutate(across(
    # NA'S nas colunas numéricas => mediana da coluna
    .cols = where(~ is.numeric(.))
    ,.fns = function(x){ifelse(
      is.na(x)
      , yes = median(x, na.rm = T), no = x)} 
  )) -> df.agg




# PROBIT ------------------------------------------------------------------
df.agg %>%
  select(
    where(~ !is.factor(.))
    , -c(CPI_RANK_2017, N_SOURCES_2017, STD_ERROR_2017
         ,WORLD_RANK, REGION_RANK, CPI_SCORE_2017)
  ) -> df.agg.probit

glm(
  data = df.agg.probit
  , formula = DUMMY_CPI ~ .
  , family = binomial(link = 'probit')
) -> lalala



# EXPORT ------------------------------------------------------------------


