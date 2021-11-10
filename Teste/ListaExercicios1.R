# 1. PACOTES
pkg <- c('sandwich', 'lmtest', 'stargazer', 'ivreg', #'systemfit', #'robustbase', #'ivreg', #'itsmr',#'REndo', #Regressões e estatística
         'gghighlight', 'ggridges', 'ggthemes', 'viridis', 'patchwork', 'naniar', 'scales', #Visualização
         'rio', 'plyr', 'glue', 'tidyverse') #Leitura e Manipulação de Dados

lapply(pkg, function(x)
  if(!require(x, character.only = T))
  {install.packages(x); require(x)})


# 2. DADOS
# Diretório de trabalho (Github)
setwd('C:/Users/Sony/Documents/GitHub/Marketing')

# Base de dados (Palda)
df.orange <- import('orange2.dta')

# Exploração inicial
df.orange %>% 
  glimpse(.)

df.orange %>%
  summary(.)

# Missing values (NAs)
df.orange %>% 
  vis_miss(.)

# Obs: uma linha de NAs (51)
df.orange %>%
  filter(!across(everything(.), is.na)) -> df.orange

# Variáveis requisitadas
df.orange %>%
  mutate(price = rev/qty) %>%
  transmute(year = year, 
            rev = rev,
            anomaly = anomaly, 
            
            across(.cols = -c(year, rev, anomaly),
                   .fns = log,
                   .names = 'ln{.col}')) -> df.orange


# 3. EXERCÍCIOS
# 3.0. Modelo proposto (enunciado)
lm(data = df.orange,
   formula = lnqty ~ lnprice + lninc + lncuradv,
   subset = c(year >= 1919)) -> lm.oranges

summary(lm.oranges)

# 3.1. Teste de Hausman para verificar endogeneidade dos preços. IV = lnprice
# Forma 1: y ~ x1 + x2 | z1 + z2 (regressão normal | regressão instrumental)
# ivreg(data = df.orange,
#       formula = lnqty ~ lnprice + lninc + lncuradv | lntemp + lninc + lncuradv) -> iv.oranges

# Forma 2: y ~ x1 + x2 | . - x1 + z1 (regressão normal | instrumento + tudo - var.endo)
ivreg(data = df.orange,
      formula = lnqty ~ lnprice + lninc + lncuradv | . - lnprice + lntemp,
      subset = c(year >= 1919)) -> iv.oranges


# Forma 3: y ~ x1 | x2 | z1 + z2 (variáveis exógenas | endógenas | instrumentais para as endógenas)
# ivreg(data = df.orange,
#       formula = lnqty ~ lninc + lncuradv | lnprice | lntemp) -> iv.oranges

summary(iv.oranges, diagnostics = T)

# Comentário:
# Suspeita de endogeneidade: a variável lnprice provavelmente é endógena, uma vez que a quantidade ofertada e demandada é determinante do preço. Se o preço não fosse endógeno, então não tratar-se-ia de um equilíbrio de mercado (e.g. caso o preço fosse fixado pelo governo ex-ante). Mas como sabemos que trata-se de um equilíbro de mercado, então o preço deve ser determinado por oferta e demanda (i.e. quantidade) e, portanto, deve ser uma variável endógena. 
# Intuição sobre o uso de lntemp como IV para lnprice: devido à influência da sazonalidade climática sobre o produto (laranjas), é esperado que variações na temperatura afetem a qualidade/quantidade do produto e, portanto, a oferta e a demanda por ele. Assim, espera-se que lntemp seja um possível instrumento para lnprice. Além disso, variações climáticas são certamente exógenas em relação ao erro da equação de demanda. Portanto, lntemp pode ser um bom instrumento.
# Teste de Hausman: H0 = Modelos OLS e 2SLS igualmente consistentes, H1 = Modelo 2SLS consistente, OLS inconsistente. 
# Resultado do Teste de Hausman: H0 rejeitada ao nível de significância de 5% (evidência forte a favor da endogeneidade). Estimador de OLS viesado. Deve-se utilizar o estimador de IV.
# Adequação do instrumento: H0 = lntemp é um instrumento fraco para lnprice. H1 = lntemp é um instrumento forte para lnprice.
# Resultado do Teste de adequação instrumental: H0 rejeitada ao nível de significância de 10% (evidência fraca a favor do uso da variável instrumental).

# 3.2. Regressão 2SLS com lntemp como IV para lnprice. Comente os coeficientes.
# Ver acima (3.1).
# Comentário: 
# Na regressão original (3.0), a elasticidade da quantidade com respeito ao preço (determinada pelo coeficiente da regressão log-log) é de -0.29480. Esse coeficiente é altamente signigicativo (i.e. ao nível de 0.1%). 
# Nesse primeiro modelo, então, um acréscimo de 1% nos preços está associado a uma redução de aproximadamente 0.3% na quantidade demandada.
# Esse resultado sugere que a demanda é relativamente inelástica aos preços (i.e. que o consumo de laranja pelas famílias mantém-se estável apesar dos preços)
# Na regressão instrumental (3.1), a elasticidade é de -0.6464 e o coeficiente é significativo ao nível de significância de 5%.
# Como existe evidência a favor da valiade dos instrumentos, a conclusão é de que a demanda é mais reativa aos preço do que aparentava no modelo OLS (viesado).
# Obs: note também que a elasticidade da demanda com respeito à renda é unitária (1% de aumento associado a 1% de aumento). Como o coeficiente é significativo, isso sugere que laranjas são um bem normal (cuja demanda aumenta conforme a renda).
# Obs: é importante notar também que o impacto percentual dos anúncios (conforme o estimador de lncuradv) é insignificante. Isso é esperado tratando-se de um produto homogêneo (laranjas).

# 3.3. Comparação de regressão 2SLS correta e incorreta.
# lm(data = df.orange,
#    formula = lnprice ~ lntemp + lninc + lncuradv,
#    subset = c(year >= 1919)) -> iv.oranges.errada1
# 
# summary(iv.oranges.errada1)
# 
# df.orange %>%
#   filter(year >= 1919) %>%
#   mutate(lnpricehat = iv.oranges.errada1$fitted.values) -> df.orange.errado
# 
# 
# lm(data = df.orange.errado,
#    formula = lnqty ~ lnpricehat + lninc + lncuradv,
#    subset = c(year >= 1919)) -> iv.oranges.errada2
# 
# summary(iv.oranges.errada2)
# summary(iv.oranges)

# Obs: deu certo (exatamente o mesmo resultado). Fiz errado errado (certo). O que será que deu de errado (certo)?

# 3.4. 2SLS: IV = lntemp e lntemp^2. Teste de Sargan (pois n(IV) > n(endo)).
ivreg(data = df.orange,
      formula = lnqty ~ lninc + lncuradv | lnprice | lntemp + I(lntemp^2),
      subset = c(year >= 1919)) -> iv.oranges2

summary(iv.oranges2)

# Comentário:
# Nenhum dos testes diagnósticos (inclusive o teste de Sargan) nos permite validar os instrumentos.

