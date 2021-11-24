# delimit ; 

* DADOS;
use "C:\Users\B35346\Desktop\A2_QMM_CaoBittencourtFerreira_Pt2\donation.dta", clear;

log using "C:\Users\B35346\Desktop\A2_QMM_CaoBittencourtFerreira_Pt2\logs\tobit_donations.log", replace;

* MODELO TOBIT;

global y 
	gift
	;

global x
	resplastmail
	propresponse
	averagegift
	;

	
summarize $y $x;

summarize $y, detail;

summarize $y 
	if $y >0, detail;

histogram $y, bin(25) freq;

	
tobit $y $x, ll(0) vce(robust); 
	
* Comentário sobre os resultados do modelo tobit.
	É um erro comum interpretar os coeficientes do modelo tobit como os de uma regressão linear usual (i.e. como o efeito das variáveis explicativas sobre a variável dependente).
	Ao contrário, os coeficientes do modelo tobit referem-se aos efeitos sobre a variável *latente* à variável dependente.
	Assim, 
	
	1) um acréscimo unitário em "resplastmail" está associado a um efeito marginal de 4.94 USD sobre o valor *esperado* das doações. O efeito é significativo ao menor nível de significância (cf. p-valor 0.000) e, portanto, é quase certamente não nulo. Isso sugere que famílias que doaram na campanha passada sejam *previstas* como mais generosas na campanha atual.
	
	2) um acréscimo unitário em "propresponse" está associado a um efeito marginal de 44.00 USD sobre o valor *esperado* das doações. O efeito é significativo ao menor nível de significância (cf. p-valor 0.000) e, portanto, é quase certamente não nulo. Isso sugere que famílias que historicamente costumam doar à campanha sejam *previstas* como mais generosas também na campanha atual.
	
	3) um acréscimo unitário em "averagegift" está associado a um efeito marginal de 0.0258 USD sobre o valor *esperado* das doações. O p-valor associado a esse efeito é de 0.182, o que não permite rejeitar a hipótese de que seja nulo. Observando o intervalo de confiança de 95%, é evidente que os limites do intervalo são muito pequenos (centavos de USD para mais ou para menos), de modo que parece apropriado concluir que o efeito *previsto* de fato seja muito pequeno ou nulo. Isso sugere que a magnitude da generosidade das famílias (em média) não está associada à *previsão* de uma generosidade maior na campanha atual. Ao contrário, é a constância nas doações (o exercício repetido da generosidade) que tende a aumentar marginalmente o valor *previsto* das doações.
	
	4) como um todo, esses efeitos marginais indicam que o valor *previsto* das doações de famílias mais generosas no passado (próximo ou historicamente) é maior do que o valor *previsto* das doações de famílias menos generosas no passado (próximo ou historicamente).

; 
	
* MARGINAL EFFECTS (TRUNCATED/CONDITIONAL);
margins, dydx(*) atmeans predict (e(0,.));

* Comentário sobre os efeitos marginais condicionais.
	Considerando *apenas as observações positivas* (i.e. doações não nulas), constata-se que:
	
	1) um acréscimo unitário em "resplastmail" está associado a um efeito marginal de 1.45 USD sobre as doações. O efeito é significativo ao menor nível de significância (cf. p-valor 0.000) e, portanto, é quase certamente não nulo. Isso sugere que famílias que doaram na campanha passada sejam mais generosas na campanha atual.
	
	2) um acréscimo unitário em "propresponse" está associado a um efeito marginal de 12.92 USD sobre as doações. O efeito é significativo ao menor nível de significância (cf. p-valor 0.000) e, portanto, é quase certamente não nulo. Isso sugere que famílias que historicamente costumam doar à campanha sejam mais generosas também na campanha atual.
	
	3) um acréscimo unitário em "averagegift" está associado a um efeito marginal de 0.0076 USD sobre as doações. O p-valor associado a esse efeito é de 0.182, o que não permite rejeitar a hipótese de que seja nulo. Observando o intervalo de confiança de 95%, é evidente que os limites do intervalo são muito pequenos (centavos de USD para mais ou para menos), de modo que parece apropriado concluir que o efeito de fato seja muito pequeno ou nulo. Isso sugere que a magnitude da generosidade das famílias (em média) não está associada a uma generosidade maior na campanha atual. Ao contrário, é a constância nas doações (o exercício repetido da generosidade) que tende a aumentar marginalmente o valor das doações realizadas.
	
	4) como um todo, esses efeitos marginais indicam que famílias mais generosas no passado (próximo ou historicamente), são mais propensas a fazerem doações maiores para a campanha, independentemente da média histórica de suas doações. É importante ressaltar que esses efeitos marginais referem-se às famílias cujas doações são não nulas.


* MARGINAL EFFECTS (CENSORED/UNCONDITIONAL);
margins, dydx(*) atmeans predict (ystar(0,.));


* Comentário sobre os efeitos marginais não condicionais.
	Agora, considerando *também as observações nulas*, constata-se que:	
	
	1) um acréscimo unitário em "resplastmail" está associado a um efeito marginal de 1.79 USD sobre as doações. O efeito é significativo ao menor nível de significância (cf. p-valor 0.000) e, portanto, é quase certamente não nulo. Isso sugere que famílias que doaram na campanha passada sejam mais generosas na campanha atual.
	
	2) um acréscimo unitário em "propresponse" está associado a um efeito marginal de 15.94 USD sobre as doações. O efeito é significativo ao menor nível de significância (cf. p-valor 0.000) e, portanto, é quase certamente não nulo. Isso sugere que famílias que historicamente costumam doar à campanha sejam mais generosas também na campanha atual.
	
	3) um acréscimo unitário em "averagegift" está associado a um efeito marginal de 0.0093 USD sobre as doações. O p-valor associado a esse efeito é de 0.182, o que não permite rejeitar a hipótese de que seja nulo. Observando o intervalo de confiança de 95%, é evidente que os limites do intervalo são muito pequenos (centavos de USD para mais ou para menos), de modo que parece apropriado concluir que o efeito de fato seja muito pequeno ou nulo. Isso sugere que a magnitude da generosidade das famílias (em média) não está associada a uma generosidade maior na campanha atual. Ao contrário, é a constância nas doações (o exercício repetido da generosidade) que tende a aumentar marginalmente o valor das doações realizadas.
	
	4) como um todo, esses efeitos marginais indicam que famílias mais generosas no passado (próximo ou historicamente), são mais propensas a fazerem doações maiores para a campanha, independentemente da média histórica de suas doações. Esses efeitos marginais referem-se a todas as famílias, incluindo aquelas com doações nulas.

; 


* Comentário final sobre os efeitos marginais.
	É evidente que os efeitos marginais sobre a variável latente (i.e. os coeficientes do modelo tobit) são os maiores dos três, seguido pelos efeitos marginais não condicionais. Por fim, os efeitos marginais condicionais são os menores de todos os três.
;

log close;
