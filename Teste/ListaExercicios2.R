# 1. PACOTES
pkg <- c('sandwich', 'lmtest', 'stargazer', 'ivreg', #'itsmr',#'REndo', #Regressões e estatística
         # 'gghighlight', 'ggridges', 'ggthemes', 'viridis', 'patchwork', , 'scales', #Visualização
         'naniar',
         'rio', 'plyr', 'glue', 'tidyverse') #Leitura e Manipulação de Dados

lapply(pkg, function(x)
  if(!require(x, character.only = T))
  {install.packages(x); require(x)})


# 2. DADOS
# Diretório de trabalho (Github)
setwd('C:/Users/Sony/Documents/GitHub/Marketing/Teste 1')

# Base de dados (Palda)
df.cerveja <- import('cerveja.dta')

# Exploração inicial
df.cerveja %>% 
  glimpse(.)

df.cerveja %>%
  summary(.)

df.cervejam %>%
  summary(.)

# Missing values (NAs)
df.cerveja %>% 
  vis_miss(.)


# 3. QUESTÕES
# 3.0. MODELO ORIGINAL (ENUNCIADO)
df.cerveja %>%
  mutate(across(.cols = c(consumopc, pcerv, pub, renda),
                .fns = log,
                .names = 'log_{.col}')) %>%
  select(contains('log_'),
         d_verao) %>%
  lm(formula = log_consumopc  ~ . ) -> model1

summary(model1)  

# 3.1. Regressão requisitada: 2SLS com log_pemb como IV para pcerv
df.cerveja %>%
  mutate(across(.cols = c(consumopc, pcerv, pub, renda, pemb),
                .fns = log,
                .names = 'log_{.col}')) %>%
  select(contains('log_'),
         d_verao) %>%
  ivreg(formula = log_consumopc  ~ log_pub + log_renda + d_verao | log_pcerv | log_pemb,
        data = .) -> modelIV

summary(modelIV, diagnostics = T)  

# Comentário:
# 1) Teste de Wu-Hausman altamente significativo (p.value < 0.001) => Evidência forte a favor da endogeneidade de pcerv.
# 2) Teste de adequação dos instrumentos altamenente significativo (p.value < 0.01) => Evidência forte de que pemb é um bom instrumento para pcerv.

# Veridito:
# O modelo mais adequado é o 2SLS. O teste de Wu-Hausman testa a H0 de que o modelo original (OLS) é mais adequado do que o segundo modelo (2SLS).
# A hipótese nula foi rejeitada ao nível de significância mais elevado. Portanto, o estimador de OLS é viesado, e o estimador de IV é não-viesado.
# Além disso, a variável instrumental é adequada. Logo, deve-se utilizar o modelo 2SLS



# Efeito cumulativo dos anúncios sobre as vendas após m períodos
# Ilustração: m de 1 até 50
tibble('m' = seq(0,50,1)) %>%
  mutate(adver_coef = ling.fx.model$coefficients['adver'],
         sales.lag_coef = ling.fx.model$coefficients['sales.lag'],
         
         cumfx_m = adver_coef*(1 - sales.lag_coef^m)/(1 - sales.lag_coef),
         cumfx_inf = adver_coef/(1 - sales.lag_coef))


# 3.3. Lingering Effects: tempo necessário para obter 90% dos efeitos dos anúncios (em meses => x12)
# sales.lag significativo => Tempo necessário para obter 90% dos efeitos dos anúncios: m = log(1-0.9)/log(coef(sales.lag))
tibble('adver.fx_prct' = seq(0,1,0.1)) %>%
  mutate(sales.lag_coef = ling.fx.model$coefficients['sales.lag'],
         
         time.to.fx_years = log(1-adver.fx_prct)/log(sales.lag_coef),
         time.to.fx_months = 12*time.to.fx_years)

# Comentário:
# De acordo com o modelo de Lingering Effects, o tempo necessário para obter 90% dos efeitos dos anúncios é de 4.62 anos, ou 55 meses e meio.
# Esse valor não é razoável. 


# 3.4. Idem, mas considerando o perído de 1908-1926 + 1938-1960
df.cerveja_dummies %>%
  filter(year >= 1908 & year <= 1926 
         |year >= 1938 & year <= 1960) %>%
  mutate(sales.lag = lag(sales)) %>% 
  select(-c(year, inc)) %>%
  lm(formula = sales ~ . ) -> ling.fx.model2

summary(ling.fx.model2)

# Efeito cumulativo dos anúncios sobre as vendas após m períodos
# Ilustração: m de 1 até 50
tibble('m' = seq(0,50,1)) %>%
  mutate(adver_coef = ling.fx.model2$coefficients['adver'],
         sales.lag_coef = ling.fx.model2$coefficients['sales.lag'],
         
         cumfx_m = adver_coef*(1 - sales.lag_coef^m)/(1 - sales.lag_coef),
         cumfx_inf = adver_coef/(1 - sales.lag_coef))

# Efeito cumulativo dos anúncios sobre as vendas após m períodos
# sales.lag significativo => Tempo necessário para obter 90% dos efeitos dos anúncios: m = log(1-0.9)/log(coef(sales.lag))
tibble('adver.fx_prct' = seq(0,1,0.1)) %>%
  mutate(sales.lag_coef = ling.fx.model2$coefficients['sales.lag'],
         
         time.to.fx_years = log(1-adver.fx_prct)/log(sales.lag_coef),
         time.to.fx_months = 12*time.to.fx_years)

# Comentário:
# Considerando o período de 1908-1926 + 1938-1960, o tempo necessário para que os anúncios tenham 90% do efeito é de aproximadamente 2 anos (o que é significativamente menor do que no modelo original).
# Embora bastante diferentes, estes resultados são mais razoáveis.
df.cervejam %>%  
  mutate(ano = substr(mes, 0, 4),
         ano = as.numeric(ano)) %>%
  mutate(dum1 = ifelse(ano >= 1908 & ano <= 1914,
                       yes = 1, no = 0),
         dum2 = ifelse(ano >= 1915 & ano <= 1925,
                       yes = 1, no = 0),
         dum3 = ifelse(ano >= 1926 & ano <= 1940,
                       yes = 1, no = 0)) %>%
  mutate(msales.lag = lag(msales)) %>% 
  select(-c(ano, mes, period)) %>%
  lm(formula = msales ~ . ) -> ling.fx.modelm

summary(ling.fx.modelm)
summary(ling.fx.model)


# Efeito cumulativo dos anúncios sobre as vendas após m períodos
# Ilustração: m de 1 até 50
tibble('m' = seq(0,50,1)) %>%
  mutate(adver_coef = ling.fx.modelm$coefficients['madv'],
         sales.lag_coef = ling.fx.modelm$coefficients['msales.lag'],
         
         cumfx_m = adver_coef*(1 - sales.lag_coef^m)/(1 - sales.lag_coef),
         cumfx_inf = adver_coef/(1 - sales.lag_coef))


# 3.3. Lingering Effects: tempo necessário para obter 90% dos efeitos dos anúncios (em meses => x12)
# sales.lag significativo => Tempo necessário para obter 90% dos efeitos dos anúncios: m = log(1-0.9)/log(coef(sales.lag))
tibble('adver.fx_prct' = seq(0,1,0.1)) %>%
  mutate(sales.lag_coef = ling.fx.modelm$coefficients['msales.lag'],
         
         time.to.fx_years = log(1-adver.fx_prct)/log(sales.lag_coef),
         time.to.fx_months = 12*time.to.fx_years)




