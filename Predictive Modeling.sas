/*Step One: Splitting the Data */

%global caps;
%let caps=/folders/myshortcuts/myfolder/Capstone;
libname capstone "&caps";

data capstone.consumpfoodhealth; 
	set capstone.consumpfoodhealth; 
	if percapita_diabetes >= 	2.52795E-04 then diabetes_bin = 1; 
	else diabetes_bin =0; 
	if percapita_neoplasms >= 0.000997668 then neoplasms_bin = 1; 
	else neoplasms_bin =  0; 
	if percapita_cardio >= 2.28153E-03 then cardio_bin = 1; 
	else cardio_bin = 0; 
	if percapita_pulmonary >= 	3.80540E-04 then pul_bin = 1; 
	else pul_bin = 0; 
run; 

proc sort data=capstone.consumpfoodhealth out=health_sort; 
	by diabetes_bin; 
run; 

proc surveyselect noprint data=work.health_sort
		samprate=0.5 out=health_sample seed=27755
		outall stratumseed=restore;
	strata diabetes_bin;
run; 

data capstone.diabetes_train (drop=selected)
	 capstone.diabetes_valid (drop=selected); 
	 set health_sample; 
	 if selected then output capstone.diabetes_train; 
	 else output capstone.diabetes_valid; 
run;

/* Step Two: Handling Missing Values */

proc means data=capstone.consumpfoodhealth 
	nmiss n; 
run; 

/* Step Three: Computing Smoothed Weight of Evidence */

%global rho1; 
proc sql noprint; 
	select mean(diabetes_bin) into :rho1
	from capstone.diabetes_train; 
run; 

proc means data=capstone.diabetes_train sum nway noprint; 
	class cat; 
	var diabetes_bin; 	
	output out=work.diab_counts sum=events; 
run; 

filename brswoe "/folders/myshortcuts/myfolder/Capstone/brswoe/diab_brswoe.sas";

data _null_; 
	file brswoe; 
	set work.diab_counts end=last; 
	logit=log((events + &rho1*24)/(_FREQ_ - events + (1-&rho1)*24)); 
	if _n_=1 then put "select (cat);" ; 
	put " when ('" cat +(-1)"') cat_swoe = " logit ";"; 
	if last then do; 
	logit = log(&rho1/(1-&rho1)); 
	put " otherwise cat_swoe = " logit ";" / "end;";
	end;
run; 

data work.train_imputed_swoe_diab; 
	set capstone.diabetes_train; 
	%include brswoe /source2;
run;

/* Step Four: Detecting Nonlinear Relationships */

ods select none; 
ods output spearmancorr=work.spearman
			hoeffdingcorr=work.hoeffding; 

proc corr data=work.train_imputed_swoe_diab spearman hoeffding; 
	var diabetes_bin; 
	with percapita_all calories_median fat_median protein_median carbohydrate_median cat_swoe; 
run; 

ods select all; 

proc sort data=work.spearman; 
	by variable; 
run; 

proc sort data=work.hoeffding; 
	by variable; 
run; 

data work.correlations; 
	merge work.spearman(rename=(diabetes_bin=scorr pdiabetes_bin=spvalue))
		  work.hoeffding(rename=(diabetes_bin=hcorr pdiabetes_bin=hpvalue));
	by variable; 
	scorr_abs=abs(scorr);
	hcorr_abs=abs(hcorr);
run; 

proc rank data=work.correlations out=work.correlations1 descending; 
	var scorr_abs hcorr_abs;
	ranks ranksp rankho;
run; 

proc sort data=work.correlations1; 
	by ranksp; 
run; 

title1 "Rank of Spearman Correlations and Hoeffding Correlations";
proc print data=work.correlations1 label split='*';
	var variable ranksp rankho scorr spvalue hcorr hpvalue; 
	label ranksp = 'Spearman rank*of variables'
		  scorr = 'Spearman Correlation'
		  spvalue = 'Spearman p-value'
		  rankho = 'Hoeffding rank*of variables'
		  hcorr = 'Hoeffding Correlation'
		  hpvalue = 'Hoeffding p-value';
run;
	
%global vref href; 

proc sql noprint; 
	select min(ranksp) into :vref
	from (select ranksp 
	from work.correlations1
	having spvalue > .5);
	
	select min(rankho) into :href
	from (select rankho
	from work.correlations1
	having hpvalue> .5);
quit;

title1 "Scatter Plot of the Ranks of Spearman vs. Hoeffding"; 
proc sgplot data=work.correlations1; 
	refine &vref / axis = y;
	refine &href /axis = x; 
	scatter y=ranksp x=rankho / datalabel=variable;
	yaxis label="Rank of Spearman";
	xaxis label="Rank of Hoeffding";
run;
title1 ; 

%global screened; 
%let screened= percapita_all calories_median fat_median protein_median carbohydrate_median cat_swoe;

     /* There are no variables in the top left corner of the graph indicating a nonlinear relationship with the target - a high Hoeffding and low spearman */

/* Step Five: Interaction Detection */ 

title1 "P-Value for Entry and Retention";

%global sl; 
proc sql; 
	select 1-probchi(log(sum(diabetes_bin ge 0)),1) into :sl
	from work.train_imputed_swoe_diab; 
quit; 

title "Interaction Detection Using Forward Selection";
proc logistic data=work.train_imputed_swoe_diab; 
	model diabetes_bin(event='1')= &screened
		percapita_all|calories_median|fat_median|protein_median|carbohydrate_median|cat_swoe @2 /include=28 clodds=pl
			selection=forward slentry=&sl;
run;

/*Step Six: Select Models with Best Subsets Selection Method */

data work.train_imputed_swoe_diab; 
	set work.train_imputed_swoe_diab; 
run; 

title1 "Models Selected by Best Subsets Selection";
proc logistic data=work.train_imputed_swoe_diab;
	model diabetes_bin(event='1')=&screened 
		percapita_all*calories_median percapita_all*fat_median
		percapita_all*protein_median percapita_all*carbohydrate_median
		percapita_all*cat_swoe / selection=score best=1;
run; 

/* Step Seven: Use Fit Statistics to Select a Model */ 

%macro fitstat(data=, target=, event=, inputs=, best=, priorevent=);

ods select none; 
ods output bestsubsets=work.score; 

proc logistic data=&data namelen=50; 
	model &target(event="&event")=&inputs / selection=sore best=&best;
run;

proc sql noprint; 	
	select variablesinmodel into :inputs1 - 
	from work.score; 
	
	select NumberOfVariables into :ic1 - 
	from work.score; 
quit; 

%let lastindx=&SQLOBS; 

%do model_indx=1 %to &lastindx; 

%let im=&&inputs&model_indx; 
%let ic=&&ic&model_indx; 

ods output scorefitstat=work.stat&ic; 

proc logistic data=&data namelen=50; 
	model &target(event="&event")=&im; 
	score data=&data out=work.scored fitstat	
		priorevent=&priorevent; 
run; 

proc datasets 
	library=work
	nodetails
	nolist;
	delete scored; 
run; 
quit;

%end; 

data work.modelfit; 
	set work.stat1 - work.stat&lastindx; 
	model=_n_;
run; 

%mend fitstat; 

%fitstat(data=work.train_imputed_swoe_diab, target=diabetes_bin, event=1, inputs=&screened
		percapita_all*calories_median percapita_all*fat_median
		percapita_all*protein_median percapita_all*carbohydrate_median
		percapita_all*cat_swoe, best=1, priorevent=0.02);
		
proc sort data=work.modelfit; 
	by bic; 
run; 

title1 "Fit Statistics from Models Selected from Best Subseets";
ods select all; 
proc print data=work.modelfit; 
	var model auc aic bic misclass adjrsquare brierscore; 
run; 

%global selected; 
proc sql; 
	select VariablesInModel into :selected 
	from work.score; 
	where numberofvariables=35; 
quit; 

	/* Based on the results, it appears that cat_swoe*percapita_all cat_swoe percapita_all 
	is a good model to represent the results in diabetes */

proc logistic data=work.train_imputed_swoe_diab; 
	model diabetes_bin(event='1') = percapita_all cat_swoe percapita_all*cat_swoe;  
run; 

