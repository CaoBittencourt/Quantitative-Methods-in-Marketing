# delimit ; 

* DADOS;
* Limpeza de dados efetuada em R;
import delimited 
using "C:\Users\B35346\Desktop\CPI\probit_data.csv", clear;

log using "C:\Users\B35346\Desktop\CPI\probit_CPI.log", replace;

* MODELO PROBIT;
* Comentário sobre as variáveis utilizadas.
Para a estimação do modelo probit com variáveis de renda, educação, idade e desigualdade (dentre outras à escolha), empregou-se as seguintes variáveis. 

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
	dummy_cpi // Dummy para os níveis de CPI determinados: CPI >= 0.7;	
	;

global x
	log_gdp_ppp // Medida de renda;
	gov_expenditure_educ_prct_of_gdp // Medida de educação;
	gini_index // Medida de desigualdade;
	pop_ages_15to64_prct // Medida de estrutura etária da população;
	
	inflation_prct // Variável adicional: taxa de inflação;
	unemployment_prct // Variável adicional: taxa de desemprego;
	;
	
probit $y $x, vce(robust);	


* Comentário sobre os coeficientes. 
	Tratando-se de um modelo probit, não pode-se interpretar os coeficientes em termos de magnitude.
	Os sinais dos coeficientes, entretanto, indicam que:
	1) os efeitos da renda são positivos sobre a probabilidade de classificar um país como "limpo" a partir de seu score no CPI.
	2) a educação da população, medida pelos gastos do governo com educação, tem também um efeito positivo sobre o score de um país no CPI.
	3) ao contrário, a desigualdade (índice de Gini) tem efeito negativo sobre o score de um país no CPI. Assim, países mais desiguais tendem a ser identificados como "sujos".
	4) a estrutura etária da população (PEA) parece ter efeito positivo, mas o p-valor excessivamente elevado não permite rejeitar a hipótese de que o efeito seja nulo.
	5) ambas variáveis explicativas adicionais parecem ter efeitos negativos sobre o CPI (i.e. inflação e desemprego mais baixos aumentam a probabilidade de classificar um país como "limpo"). Embora o p-valor da inflação não esteja dentro dos níveis de significância usuais, observando o intervalo de confiança de 95%, bem como os resultados do modelo probit ordenado e os efeitos marginais (e respectivos p-valores), é adequado afirmar que o efeito não seja nulo.
; 

* MARGINAL EFFECTS;
mfx;

* Comentário sobre os efeitos marginais.
	Por sua vez, os efeitos marginais indicam que:
	1) um acréscimo unitário na medida de renda de um país está associado a uma probabilidade de 3.77% de classificá-lo como "limpo". O efeito é significativo apenas ao nível de significância de 10%, mas os resultados do modelo ordenado corroboram a sua importância explicativa. 
	2) um acréscimo unitário na medida de educação de um país está associado a uma probabilidade de 11.97% de classificá-lo como "limpo". O efeito é significativo ao nível de significância de 1%. 
	3) a desigualdade (índice de Gini) é também significativa ao nível de 1% e está associada a uma redução de 2.26% na probabilidade de classificar um país como "limpo". Os países mais desiguais, portanto, tendem a ser mais corruptos também.
	4) o efeito marginal da estrutura etária é provavelmente pequeno ou nulo (ao menos nesta estimação do modelo), devido ao seu efeito marginal pequeno (0.22%) e o p-valor a ele associado (0.833).
	5) tanto inflação quanto desemprego mostram-se variáveis explicativas significativas (aos níveis de 5% e 1%, respectivamente). E ambas estão associadas a uma redução de cerca de 2.5% na probabilidade de classificar um país como "limpo". Com isso, reforça-se a conjectura inicial acerca da relação entre corrupção, inflação e desemprego: países cujas taxas de inflação e desemprego são mais elevadas tendem a ser mais corruptos. 
	
	6) Como um todo, esses resultados sugerem que países mais ricos, mais educados, menos desiguais e com menores taxas de inflação e desemprego tendem a ser menos corruptos. De fato, parece ser o caso de que a corrupção seja "endêmica" aos países em desenvolvimento. 
; 

* HIT RATE TABLE;
estat class;

* Comentário sobre a hit rate table.
	A hit rate table indica que a taxa de acerto do modelo é de 89.41% (i.e. tem uma precisão elevada).
	Em outras palavras, a partir desse conjunto de variáveis explicativas, é possível classificar corretamente o score de um país no CPI como "limpo" ou "sujo" cerca de 90% das vezes.
; 

log close;