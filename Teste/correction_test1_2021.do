# delimit ;

set more off ;

* Solutions for exam 1, 23 September 2020;

* Opening the database and creating the .log file to register the results;

  use "C:\Users\Jose Feres\Documents\MQM 2020\A1\cerveja.dta",clear;
  log using "C:\Users\Jose Feres\Documents\MQM 2020\A1\answers.log", replace;
  
 
 
 * Item 1: Hausman test to assess the endogeneity of variable lnpcerv.
 
 First, we need to construct the variables in log;
 
 generate lnconsumopc = ln(consumopc);
 generate lnpcerv = ln(pcerv);
 generate lnrenda = ln(renda);
 generate lnpemb = ln(pemb);
 generate lnpub = ln(pub);
 
 * Now we can proceed to the Hausman test.
 
   First step: regress variable lnpcerv (the variable potentially endogenous)
   on all exogenous variables including the instrument lnpemb;
 
 regress lnpcerv lnrenda lnpemb lnpub d_verao;
 predict e, resid;
 
 * Second step estimate the original equation by adding the residual of the first
   stage as an additional eplanatory variable.;
 
 regress lnconsumopc lnpcerv lnrenda lnpub d_verao e;
 
 * We observe that the coefficient associated to the residual is significant. 
 This finding provides evidence the variable lnpcerv is endogeneous. In this case,
 the OLS estimator is inconsistent and biased and we should prefer an instumental
 variable method. ;
 
 * Item 2: estimation of the demand equation by 2SLS.;
 
   ivregress 2sls lnconsumopc (lnpcerv=lnpemb) lnpub lnrenda d_verao;
   
 * Since the variables are expressed in log, we can interpret the coefficients in 
  terms of elasticity. The high price elasticity suggest that consumers are
   quite sensitive to price variations: a 1% increase in the price of beer is associated to  
   a 1.22% reduction in consumption. The coefficient for advertising is
   positive and significant: a 1% increase in advertising expenditures
   is related to a 0.10% increase in consumption. Income elasticity is not
   statistic significant, suggesting the an income increase is not associated to 
   an increase in beer consumption. Finally the dummy d_verao suggests that
   beer consumption is 15.3% higher in summer when compared to other months.;
   
  * Item 3: hypothesis test for price elasticity = -1 ;
  
    test lnpcerv=-1;
	
  * p-value of 0.69 indicates that we cannot reject the null hypothesis 
    that the price elasticity is equal to -1.;
   
   
   * Item 4: Estimation of the lingering effects model and computation 
     of impact after 3 periods.;
   
   tsset mes;
   
   arima consumopc l.consumopc pub, ma(1);
   
   scalar proportion_m3 = 1-_b[l.consumopc]^3;
   display proportion_m3;
   
   * After 3 periods we obtain approximately 68% of the total impact of
     advertising on sales;
   
   * Item 5: number of months to attain 85% of the impact of advertising 
     on sales;
   
   scalar m_85 = ln(1-0.85)/ln(_b[l.consumopc]);
   display m_85;
   
   * The result suggests that a new campaign should be launched
     after 5 months, when 85% of the total impact of the previous campaign
	 has been reached.;
	 
   * Item 6: estimation of the brand loyalty model;
   
     prais consumopc pub l.consumopc, corc;
	 
   * The Durbin-Watson statistic from the original equation is ambiguous
     about serial correlation. The coefficient of the lagged sales is 
	 significant, which is evidence against the current effects model. We should
	 prefer the brande loyalty model, although the lingering effects model 
	 would also be a reasonable specification.;
   
   log close;
