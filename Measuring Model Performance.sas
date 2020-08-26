%global caps;
%let caps=/folders/myshortcuts/myfolder/Capstone;
libname capstone "&caps";

proc orthoreg data=work.train_imputed_swoe_diab; 
	model diabetes_bin = percapita_all cat_swoe percapita_all*cat_swoe; 
	store logmodel; 
run; 

proc plm restore=logmodel; 
	score data=work.valid_imputed_swoe_diab out=finem pred=p_diabetes_bin; 
run;

proc sort data=finem out=finemo;
	by p_diabetes_bin; 
run; 

proc means data=finemo; 
	class sector;
	var p_diabetes_bin; 
	output out=finemo mean=;
run; 

proc sort data=finemo out=finemon;
	by descending p_diabetes_bin; 
run; 

proc print data=finemon; 
run; 

proc glmselect data=work.train_imputed_swoe_diab;
	model diabetes_bin(event='1')= percapita_all cat_swoe percapita_all*cat_swoe; 
	score data=work.valid_imputed_swoe_diab;
run; 

/*Step One: Preparing Validation Data */

%global rho1; 
proc sql noprint; 
	select mean(diabetes_bin) into :rho1
	from capstone.diabetes_valid; 
run; 

proc means data=capstone.diabetes_valid sum nway noprint; 
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

data work.valid_imputed_swoe_diab; 
	set capstone.diabetes_valid; 
	%include brswoe /source2;
run;

/*Step Two: Measuring Model Performance */

%global selected; 
%let selected= percapita_all cat_swoe percapita_all*cat_swoe;

%let pi1= 0.25;

ods select roccurve scorefitstat; 
proc logistic data=work.train_imputed_swoe_diab;
	model diabetes_bin(event='1')= percapita_all cat_swoe percapita_all*cat_swoe; 
	score data=work.train_imputed_swoe_diab out=work.scova
		priorevent=&pi1 outroc=work.roc fitstat; 
run; 

title1 "Statistics in the ROC Data Set"; 
proc print data=work.roc(obs=10);
	var _prob_ _sensit_ _1mspec_;
run; 

data work.roc; 
	set work.roc; 
	cutoff=_PROB_;
	specif=1-_1MSPEC_;
	tp=&pi1*_SENSIT_;
	fn=&pi1*(1-_SENSIT_);
	tn=(1-&pi1)*specif; 
	fp=(1-&pi1)*_1MSPEC_;
	depth=tp+fp;
	pospv=tp/depth;
	negpv=tn/(1-depth);
	acc=tp+tn;
	lift=pospv/&pi1;
	keep cutoff tn fp fn tp
		_SENSIT_ _1MSPEC_ specif depth
		pospv negpv acc lift;
run; 

title1 "Lift Chart for the Validation Data";
proc sgplot data=work.roc; 
	where 0.005 <= depth <= 0.50; 
	series y=lift x=depth; 
	refline .0 / axis=y; 
	yaxis values=(0 to 9 by 1);
run;
quit; 
title1;

	/* The C statistic with the validation dataset is .607 and the training data set was .601. This means the model generalizes well to new data */
	
/*Step Three: Using the K-S Statistic to Measure Model Performance */ 

title1 "K-S Statistic for the Validation Data Set";
proc npar1way edf data=work.scova; 
	class diabetes_bin; 
	var p_1;
run;
	
	/* This shows that the d statistic is .166 and the greatest separation occurs at .257 */ 

