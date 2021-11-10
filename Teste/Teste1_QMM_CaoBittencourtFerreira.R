# 1. PACOTES
pkg <- c('ivreg', #Regressões e estatística
         'naniar', #NAs
         'rio', 'plyr', 'glue', 'tidyverse') #Leitura e Manipulação de Dados

lapply(pkg, function(x)
  if(!require(x, character.only = T))
  {install.packages(x); require(x)})


# 2. DADOS
# Diretório de trabalho (Github)
setwd('C:/Users/Sony/Documents/GitHub/Marketing/Teste')

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

# Linhas inteiras de NAs (exceto pela variável instrumental) => Remover NAs
df.cerveja %>%
  drop_na(.) -> df.cerveja2


# 3. QUESTÕES
# 3.0. MODELO ORIGINAL (ENUNCIADO)
df.cerveja2 %>%
  mutate(across(.cols = c(consumopc, pcerv, pub, renda),
                .fns = log,
                .names = 'log_{.col}')) %>%
  select(contains('log_'),
         d_verao) %>%
  lm(formula = log_consumopc  ~ . ) -> model.ols

summary(model.ols)  

# 3.1. Regressão requisitada: 2SLS com log_pemb como IV para pcerv
df.cerveja2 %>%
  mutate(across(.cols = c(consumopc, pcerv, pub, renda, pemb),
                .fns = log,
                .names = 'log_{.col}')) %>%
  select(contains('log_'),
         d_verao) %>%
  ivreg(formula = log_consumopc  ~ log_pub + log_renda + d_verao | log_pcerv | log_pemb,
        data = .) -> model.IV


summary(model.IV, diagnostics = T)



# Comentário:
# 1) Teste de Wu-Hausman altamente significativo (p.value < 0.001) => Evidência forte a favor da endogeneidade de pcerv.
# 2) Teste de adequação dos instrumentos altamenente significativo (p.value < 0.01) => Evidência forte de que pemb é um bom instrumento para pcerv.

# Veridito:
# O modelo mais adequado é o 2SLS. O teste de Wu-Hausman testa a H0 de que o modelo original (OLS) é mais adequado do que o segundo modelo (2SLS).
# A hipótese nula foi rejeitada ao nível de significância mais elevado. Portanto, o estimador de OLS é viesado, e o estimador de IV é não-viesado.
# Além disso, a variável instrumental é adequada. Logo, deve-se utilizar o modelo 2SLS

# Equação de Demanda:
# log_consumopc = 3.41549 + -1.21920xlog_pcerv + 0.10285xlog_pub + -0.25779xlog_renda + 0.15275xd_verao; IV: log_pcerv = log_pemb.
# Os coeficientes signigicativos referem-se às variáveis: pcerv (p.value < 0.05), pub (p.value < 0.1) e d_Verao (p.value < 0.001).
# Como as variáveis estão log-transformadas, os coeficientes são precisamente a elasticidade de demanda por cada variável:
# Assim, por exemplo, uma variação percentual (d = 1%) no preço da cerveja, está associado a uma redução mais que proporcional (d = -1.21%) na demanda.
# A variável mais significativa de todas é d_verao, indicando forte importância da sazonalidade na demanda por cerveja.
# Os gastos com anúncios parecem ser pouco relevantes na demanda por cerveja, ao menos se comparado a essas duas variáveis (preço e sazonalidae):
# o efeito percentual dos anúncios é baixo (elasticidade = 0.10%) e comparativamente pouco significativo.
# Deve-se ressaltar também que a cerveja é um produto algo homogêneo, de modo que seja esperada uma influência pequena dos anúncios.
# Finalmente, o logaritmo da renda é insignificante nos intervalos de confiança usuais, o que não nos permite rejeitar a hipótese nula de que o coeficiente seja zero.
# Parece, então, que o consumo de cerveja não depende da renda (i.e. trata-se de um produto consumido por todas as classes sociais).

# Como o coeficiente de log_pcerv é significativo é igual a -1.2192, temos forte evidência de que a elasticidade não é -1, mas menor do que esse valor.

# # NÃO CONSEGUI FAZER O LINGERING EFFECTS MODEL
# df.cerveja2 %>%
#   mutate(lag_consumopc = dplyr::lag(consumopc)) %>% 
#   select(contains('consumopc'),
#          pub) %>%
#   lm(formula = consumopc ~ . ) -> ling.fx.model
# 
# summary(ling.fx.model)
# 
# # Uma vez que o erro segue uma média móvel MA(1), o efeito cumulativo dos anúncios pode ser estimado por: 
# # Efeito cumulativo dos anúncios sobre as vendas após 3 períodos
# tibble('m' = seq(0,3,1)) %>%
#   mutate(pub_coef = ling.fx.model$coefficients['pub'],
#          lag_consumopc_coef = ling.fx.model$coefficients['lag_consumopc'],
#          
#          cumfx_m = pub_coef*(1 - lag_consumopc_coef^m)/(1 - lag_consumopc_coef),
#          cumfx_inf = pub_coef/(1 - lag_consumopc_coef))
