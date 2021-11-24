# delimit ; 

* DADOS;
* Limpeza de dados efetuada em R;
import delimited 
using "C:\Users\B35346\Desktop\CPI\probit_data.csv", clear;

log using "C:\Users\B35346\Desktop\CPI\probit_ordered_CPI.log", replace;

* MODELO PROBIT;
* Comentário sobre as variáveis utilizadas.
Para a estimação do modelo probit ordenado com variáveis de renda, educação, idade e desigualdade (dentre outras à escolha), empregou-se as seguintes variáveis. 

1) Para a medida de renda, o logarítmo do PIB PPP (paridade de poder de compra, a fim de facilitar comparações entre países).
2) Para medir a educação, os gastos do governo com educação (como porcentagem do PIB).
3) Para estimar a idade, tomou-se como critério a população em idade economicamente ativa (PEA).
4) E, como medida de desigualdade, o índice de Gini. 

Outras variáveis testadas foram (e.g. no caso de educação): a taxa de alfabetização de adultos e jovens, a evasão escolar de adolescentes e crianças, a colocação do país na Olimpíada Internacional de Matemática e assim por diante. 

Foram testadas muitas combinações de variáveis explicativas adicionais, dentre medidas macroeconômicas, contas nacionais e índices de liberdade econômica (pode-se visualizar a lista completa de variáveis testadas na base de dados consolidada). No entanto, por simplicidade e consistência empírica, optou-se por realizar um estudo focado apenas em duas variáveis adicionais: a taxa de inflação e a taxa de desemprego. 

A tese que motiva a escolha da primeira dessas duas medidas é inspirada nos modelos neoclássicos e monetaristas em Macroeconomia, que associam políticas fiscais e monetárias expansivas iniciadas pelo governo a níveis de preços permanentemente mais elevados. No contexto de corrupção, é de se esperar que governos mais corruptos, utilizando-se da máquina pública para benefício próprio ilícito, façam uso dessas mesmas políticas expansivas em seus esquemas de corrupção. Alguns exemplos clássicos são: o superfaturamento de obras públicas, a emissão ilegítima de papel moeda e o desvio de verba de programas sociais. Em todo caso, a elevação permanente nos níveis de preços é resultado final de "descuidos" (lícitos ou ilícitos) no manejo do tesouro nacional por parte do governo. Assim, é de se esperar que países com maiores taxas de inflação estejam também mais envolvidos com corrupção e, alternadamente, que os governos percebidos como mais "limpos" sejam também aqueles com orçamentos e bases monetárias equilibrados e, portanto, taxas de inflação mais baixas. 

Analogamente, espera-se que a taxa de desemprego seja mais elevada em países mais corruptos. Para uma explicação detalhada das relações entre desemprego e corrupção ver, por exemplo: "Dynamic Relationship between Corruption and Youth Unemployment Empirical Evidences from a System GMM Approach" publicado pelo World Bank Group (BOUZID, 2016).
  
; 

global y 
	dummy_cpi_ordered // Dummy para os níveis de CPI determinados: CPI <= 0.3, CPI > 0.3 e CPI < 0.7 CPI >= 0.7;	
	;

global x
	log_gdp_ppp // Medida de renda;
	gov_expenditure_educ_prct_of_gdp // Medida de educação;
	gini_index // Medida de desigualdade;
	pop_ages_15to64_prct // Medida de estrutura etária da população;
	
	inflation_prct // Variável adicional: taxa de inflação;
	unemployment_prct // Variável adicional: taxa de desemprego;
	;
	
oprobit $y $x, vce(robust);
	
* Comentário sobre os coeficientes. 
	Tratando-se de um modelo probit, não pode-se interpretar os coeficientes em termos de magnitude.
	Os sinais dos coeficientes, entretanto, indicam que:
	1) os efeitos da renda são positivos sobre a probabilidade de classificar um país como "limpo" a partir de seu score no CPI.
	2) a educação da população, medida pelos gastos do governo com educação, tem também um efeito positivo sobre o score de um país no CPI.
	3) ao contrário, a desigualdade (índice de Gini) tem efeito negativo sobre o score de um país no CPI. Assim, países mais desiguais tendem a ser identificados como "sujos".
	4) a estrutura etária da população (PEA) parece ter efeito positivo. Ao contrário do modelo probit não ordenado, nesse caso o efeito positivo parece ser significativo (cf. p-valor de 0.051)
	5) ambas variáveis explicativas adicionais parecem ter efeitos negativos sobre o CPI (i.e. inflação e desemprego mais baixos aumentam a probabilidade de classificar um país como "limpo").
	6) como um todo, os coeficientes são significativos nos níveis usuais.  No caso dos coeficientes referentes à estrutura etária e ao desemprego, embora não apresentem p-valor precisamente inferior a 5%, ainda assim estão muito próximos. É, portanto, evidente que os efeitos estimados pelo modelo ordenado muito provavelmente não são nulos.
; 
	
* MARGINAL EFFECTS;
mfx, predict(outcome(1));
mfx, predict(outcome(2));
mfx, predict(outcome(3));

* Comentário sobre os efeitos marginais.
	Por sua vez, os efeitos marginais indicam que:
	1) um acréscimo unitário na medida de renda de um país está associado a:
		a) uma redução de 3.09% na probabilidade de classificá-lo como "sujo". O efeito é quase certamente não nulo (cf. p-valor 0.036).
		b) uma redução de 2.31% na probabilidade de classificá-lo como "intermediário". No entanto, é possível que o efeito seja nulo (cf. p-valor 0.144), embora os resultados do modelo não ordenado e das demais classificações (viz. "sujo" e "limpo") corroborem que esse não seja o caso.
		c) um acréscimo de 5.40% na probabilidade de classificá-lo como "limpo". O efeito é significativo ao nível de significância de 1%.
		d) em suma, países mais ricos tendem a ser menos corruptos. Esse achado está de acordo com a literatura (e.g. BOUZID, 2016), segundo a qual a corrupção é um "problema endêmico" em economias em desenvolvimento.
		
	2) um acréscimo unitário na medida de educação de um país está associado a:
		a) uma redução de 5.15% na probabilidade de classificá-lo como "sujo". O efeito é quase certamente não nulo (cf. p-valor 0.004).
		b) uma redução de 3.84% na probabilidade de classificá-lo como "intermediário". Novamente, é possível que o efeito seja nulo (cf. p-valor 0.143), ainda que os resultados do modelo não ordenado e das demais classificações (viz. "sujo" e "limpo") corroborem que esse não seja o caso.
		c) um acréscimo de 8.99% na probabilidade de classificá-lo como "limpo". O efeito é significativo ao nível de significância de 1%.
		d) em suma, países com educação mais elevada tendem a ser menos corruptos.
	
	3) um acréscimo unitário na medida de desigualdade econômica de um país está associado a:
		a) um acréscimo de 1.32% na probabilidade de classificá-lo como "sujo". O efeito é quase certamente não nulo (cf. p-valor 0.003).
		b) um acréscimo de 0.98% na probabilidade de classificá-lo como "intermediário". Novamente, é possível que o efeito seja nulo (cf. p-valor 0.130), ainda que os resultados do modelo não ordenado e das demais classificações (viz. "sujo" e "limpo") corroborem que esse não seja o caso.
		c) uma redução de 2.30% na probabilidade de classificá-lo como "limpo". O efeito é quase certamente não nulo (cf. p-valor 0.000).
		d) em suma, países mais desiguais tendem a ser mais corruptos.
	
	4) um acréscimo unitário na população economicamente ativa (medida etária) de um país está associado a:
		a) uma redução de 0.96% na probabilidade de classificá-lo como "sujo". O efeito é possivelmente nulo em alguns níveis de significância, mas dificilmente ao nível de 10% (cf. p-valor 0.080).
		b) uma redução de 0.71% na probabilidade de classificá-lo como "intermediário". É possível que o efeito seja nulo (cf. p-valor 0.196), especialmente considerando os resultados do modelo não ordenado e dos efeitos marginais das demais classificações (viz. "sujo" e "limpo").
		c) um acréscimo de 1.67% na probabilidade de classificá-lo como "limpo". O efeito é significativo ao nível de significância de 5%. Esse resultado pode sugerir que países com maior proporção da população entre 15 e 65 anos (i.e. em idade economicamente ativa) sejam menos corruptos.
		d) apesar da observação 4)c), como um todo, o efeito marginal da estrutura etária parece ser ambíguo ou nulo. 
	
	5) um acréscimo unitário na taxa de inflação de um país está associado a:
		a) um acréscimo de 1.15% na probabilidade de classificá-lo como "sujo". O efeito é significativo ao nível de significância de 1%.
		b) um acréscimo de 0.86% na probabilidade de classificá-lo como "intermediário". O efeito é possivelmente nulo (cf. p-valor 0.116), ainda que os resultados do modelo não ordenado e das demais classificações (viz "sujo" e "limpo") corroborem que esse não seja o caso.
		c) uma redução de 2.01% na probabilidade de classificá-lo como "limpo". O efeito é quase certamente não nulo (cf. p-valor 0.000).
		d) em suma, como esperado, países com um taxa de inflação mais elevada tendem a ser mais corruptos.
	
	6) um acréscimo unitário na taxa de desemprego de um país está associado a:
		a) um acréscimo de 0.46% na probabilidade de classificá-lo como "sujo". Embora pequeno, o efeito é significativo ao nível de significância de 5%.
		b) um acréscimo de 0.34% na probabilidade de classificá-lo como "intermediário". O efeito é possivelmente nulo (cf. p-valor 0.304), ainda que os resultados do modelo não ordenado sugiram que esse não seja o caso.
		c) uma redução de 0.81% na probabilidade de classificá-lo como "limpo". O efeito é possivelmente nulo em alguns níveis de significância, mas dificilmente ao nível de 10% (cf. p-valor 0.095).
		d) em suma, ao contrário da estimação do modelo não ordenado, nesse caso o efeito marginal do desemprego parece ser pequeno ou nulo.
	
	7) Esses resultados sugerem que países mais ricos, mais educados, menos desiguais e com menores taxas de inflação tendem a ser menos corruptos. De fato, parece ser o caso de que a corrupção seja "endêmica" aos países em desenvolvimento. 
	
; 


* PREVISÕES DO MODELO;
predict pr1, pr outcome(1);
predict pr2, pr outcome(2);
predict pr3, pr outcome(3);

* HIT RATE TABLE
	Embora o comando "estat class" aplique-se apenas aos modelos probit e logit não ordenados, pode-se começar a averiguar a precisão dos modelos ordenados comparando a média das probabilidades previstas pelo modelo com a distribuição original dos dados. O comando "tabulate" fornece a frequência de cada categoria de CPI e o sumário das previsões é obtido com o comando "summarize". Além disso, é possível calcular (manualmente) a taxa de acerto, como demonstrado a seguir.
;

summarize pr1 pr2 pr3;
tabulate $y;

* Comentário sobre as previsões do modelo.
	Comparando a tabela de frequência original com as previsões do modelo probit ordenado, constata-se que:
	1) nos dados originais, 16.47% dos países são classificados como "sujos" (CPI <= 0.3). O modelo probit ordenado prevê 16.62% de países "sujos".
	2) nos dados originais, 58.82% dos países são classificados como "indermediários" (CPI > 0.3 e CPI < 0.7). O modelo probit ordenado prevê 58.51% de países "indermediários".
	3) nos dados originais, 24.71% dos países são classificados como "limpos" (CPI >= 0.7). O modelo probit ordenado prevê 24.85% de países "limpos".
	
	4) é evidente que o modelo prevê adequadamente o número de países em cada categoria.
;

gen pr1_1 = ((pr1 - pr2 - pr3) > 0);
gen pr2_2 = ((pr2 - pr1 - pr3) > 0);
gen pr3_3 = ((pr3 - pr1 - pr2) > 0);

replace pr1_1 = 1 if pr1_1 == 1;
replace pr2_2 = 2 if pr2_2 == 1;
replace pr3_3 = 3 if pr3_3 == 1;

gen pr = pr1_1 + pr2_2 + pr3_3;
gen acerto = dummy_cpi_ordered == pr;

summarize acerto;

* Comentário sobre as previsões do modelo.
	Ao calcular a taxa de acerto (manualmente), verifica-se, entretanto, que a precisão do modelo ordenado é menor (72.94%) do que a do modelo original (em mais de 10%).
	As possíveis explicações para a menor precisão são duas, a princípio: 
	1) a seleção amostral é restrita demais para permitir uma precisão adequada. Provavelmente um modelo estimado com base em mais de um ano de referência teria precisão mais elevada.
	2) o modelo ordenado conta com três categorias de classificação, de modo que a complexidade maior tende a diminuir a precisão dos resultados. O modelo probit dicotômico (original) é mais "conciso" e, por esse mesmo motivo, também mais preciso: a maior concentração dos dados aumenta a consistência dos resultados. Assim, o que o modelo ordenado ganha em especificidade também perde em precisão.
;

log close;