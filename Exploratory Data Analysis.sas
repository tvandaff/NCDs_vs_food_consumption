/*Perform Exploratory Data Analysis on Dataset */
/*Step One: Analyze the Distribution of Consumption Rates Across Countries*/

%global caps;
%let caps=/folders/myshortcuts/myfolder/Capstone;
libname capstone "&caps";

ods html path='/folders/myfolders' GPATH='/folders/myfolders/';
ods graphics on / imagemap;

%let causes = percapita_neoplasms
	percapita_diabetes percapita_cardio percapita_pulmonary;
	
%let interval =  Higher Middle Low Lowest All Calories_Median 
	Fat_Median Protein_Median Carbohydrate_Median percapita_all;

proc univariate data=capstone.consumpfoodhealth noprint;
	var &interval;
	histogram &interval / normal kernel; 
	inset n mean std / position= ne;
run;

proc univariate data=capstone.consumpfoodhealth;
	id Country;
	var &causes;
run;
	/* Diabetes Mellitus */
ods graphics / reset=all imagemap;

proc corr data=capstone.consumpfoodhealth rank
	plots(only)=scatter(nvar=all ellipse=none);
	var &interval;
	with diabetes_mellitus;
	id cat;
	title "Correlation and Scatter Plots with Diabetes";
run;

ods graphics off;

proc corr data=capstone.consumpfoodhealth nosimple best=3;
	var &interval;
	title "Correlations and Scatter Plot Matrix of Predictors";
run;
	/* Malignant Neoplasms */
ods graphics / reset=all imagemap;

proc corr data=capstone.consumpfoodhealth rank
	plots(only)=scatter(nvar=all ellipse=none);
	var &interval;
	with Malignant_neoplasms;
	id cat;
	title "Correlation and Scatter Plots with Malignant Neoplasms";
run;

ods graphics off;

proc corr data=capstone.consumpfoodhealth nosimple best=3;
	var &interval;
	title "Correlations and Scatter Plot Matrix of Predictors";
run;
	/* Chronic Obstructive Pulmonary */
ods graphics / reset=all imagemap;

proc corr data=capstone.consumpfoodhealth rank
	plots(only)=scatter(nvar=all ellipse=none);
	var &interval;
	with Chronic_obstructive_pulmonary;
	id cat;
	title "Correlation and Scatter Plots with Chronic Obstructive Pulmonary";
run;

ods graphics off;

proc corr data=capstone.consumpfoodhealth nosimple best=3;
	var &interval;
	title "Correlations and Scatter Plot Matrix of Predictors";
run;
	/* Cardiovascular Disease */
ods graphics / reset=all imagemap;

proc corr data=capstone.consumpfoodhealth rank
	plots(only)=scatter(nvar=all ellipse=none);
	var &interval;
	with Cardiovascular_diseases;
	id cat;
	title "Correlation and Scatter Plots with Cardiovascular Disease";
run;

ods graphics off;

proc corr data=capstone.consumpfoodhealth nosimple best=3;
	var &interval;
	title "Correlations and Scatter Plot Matrix of Predictors";
run;

/* Step 2: Plot the data to explore associations */
	/* Diabetes Mellitus */
proc sgscatter data=capstone.consumpfoodhealth;
	plot Diabetes_mellitus*(&interval) / reg;
	title "Associations of Interval Variables with Diabetes";
run;

proc sgplot data=capstone.consumpfoodhealth;
	vbox percapita_diabetes / category=Country connect=mean;
	xaxis display=none;
	title "Diabetes Differences Across Country";
run;
	/* Malignant Neoplasms */
proc sgscatter data=capstone.consumpfoodhealth;
	plot Malignant_neoplasms*(&interval) / reg;
	title "Associations of Interval Variables with Mallignant Neoplasms";
run;

proc sgplot data=capstone.consumpfoodhealth;
	vbox percapita_neoplasms / category=Country connect=mean;
	xaxis display=none;
	title "Malignant Neoplasms Differences Across Country";
run;
	/* Cardiovascular Diseases */
proc sgscatter data=capstone.consumpfoodhealth;
	plot Cardiovascular_diseases*(&interval) / reg;
	title "Associations of Interval Variables with Cardiovascular Disease";
run;

proc sgplot data=capstone.consumpfoodhealth;
	vbox percapita_cardio / category=Country connect=mean;
	xaxis display=none;
	title "Cardiovascular Disease Differences Across Country";
run;
	/* Chronic Obstructive Pulmonary */
proc sgscatter data=capstone.consumpfoodhealth;
	plot Chronic_obstructive_pulmonary*(&interval) / reg;
	title "Associations of Interval Variables with Chronic Obstructive Pulmonary";
run;

proc sgplot data=capstone.consumpfoodhealth;
	vbox percapita_pulmonary / category=Country connect=mean;
	xaxis display=none;
	title "Chronic Obstructive Pulmonary Differences Across Country";
run;
/* Step 3: Performing a One-Way ANOVA */
	/* Diabetes Mellitus */
proc glm data=capstone.consumpfoodhealth plots=diagnostics;
	model diabetes_mellitus=all;
	title "One-Way ANOVA with Consumption as Predictor";
run;

proc glm data=capstone.consumpfoodhealth plots=diagnostics;
	model percapita_diabetes=percapita_all;
	title "One-Way ANOVA with Consumption as Predictor";
run;
	/* Malignant Neoplasms */
proc glm data=capstone.consumpfoodhealth plots=diagnostics;
	model Malignant_neoplasms=all;
	title "One-Way ANOVA with Consumption as Predictor";
run;
	/* Cardiovascular Diseases */
proc glm data=capstone.consumpfoodhealth plots=diagnostics;
	model Cardiovascular_diseases=all;
	title "One-Way ANOVA with Consumption as Predictor";
run;
	/* Chronic Obstructive Pulmonary */
proc glm data=capstone.consumpfoodhealth plots=diagnostics;
	model Chronic_obstructive_pulmonary=all;
	title "One-Way ANOVA with Consumption as Predictor";
run;

/* Step 4: Simple Linear Regression */

ods graphics; 
	/* Diabetes Mellitus */
proc reg data=capstone.consumpfoodhealth;
	model diabetes_mellitus=all;
	title "Simple Regression with Consumption as Regressor";
run;
	/* Malignant Neoplasms */
proc reg data=capstone.consumpfoodhealth;
	model Malignant_neoplasms=all;
	title "Simple Regression with Consumption as Regressor";
run;
	/* Cardiovascular Diseases */
proc reg data=capstone.consumpfoodhealth;
	model Cardiovascular_diseases=all;
	title "Simple Regression with Consumption as Regressor";
run;
	/* Chronic Obstructive Pulmonary */
proc reg data=capstone.consumpfoodhealth;
	model Chronic_obstructive_pulmonary=all;
	title "Simple Regression with Consumption as Regressor";
run;

/* Step 5: Stepwise Regression */
	/* Diabetes Mellitus */
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model diabetes_mellitus = &interval / 
		selection=stepwise details=steps select=SL
		ststay=0.5; 
	title "Stepwise Model Selection for Diabetes - SL 0.05"; 
run; 
	/* Malignant Neoplasms */
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model malignant_neoplasms = &interval / 
		selection=stepwise details=steps select=SL
		ststay=0.5; 
	title "Stepwise Model Selection for Malignant Neoplasms - SL 0.05"; 
run; 
	/* Cardiovascular Diseases */
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model Cardiovascular_diseases = &interval / 
		selection=stepwise details=steps select=SL
		ststay=0.5; 
	title "Stepwise Model Selection for Cardiovascular Disease - SL 0.05"; 
run; 
	/* Chronic Obstructive Pulmonary */
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model Chronic_obstructive_pulmonary = &interval / 
		selection=stepwise details=steps select=SL
		ststay=0.5; 
	title "Stepwise Model Selection for Chronic Obstructive Pulmonary - SL 0.05"; 
run; 
/* Step 6: Perform Model Selection */
	/* Diabetes Mellitus */
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model diabetes_mellitus = &interval/ selection=stepwise select=BIC;
	title "BIC STEPWISE Selection with Diabetes"; 
run;
	/* Malignant Neoplasms */
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model malignant_neoplasms = &interval/ selection=stepwise select=BIC;
	title "BIC STEPWISE Selection with Malignant Neoplasms"; 
run;
	/* Cardiovascular Diseases */
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model Cardiovascular_diseases = &interval/ selection=stepwise select=BIC;
	title "BIC STEPWISE Selection with Cardiovascular Diseases"; 
run;
	/* Chronic Obstructive Pulmonary */
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model Chronic_obstructive_pulmonary = &interval/ selection=stepwise select=BIC;
	title "BIC STEPWISE Selection with Chronic Obstructive Pulmonary"; 
run;
/* Step 7: All Possible Model Selection */
	/* Diabetes Mellitus */
proc reg data=capstone.consumpfoodhealth plots(only)=(rsquare adjrsq cp); 
	model diabetes_mellitus = &interval / selection=rsquare adjrsq cp; 
	title "All Possible Model Selection for Diabetes";
run; 
	/* Malignant Neoplasms */
proc reg data=capstone.consumpfoodhealth plots(only)=(rsquare adjrsq cp); 
	model malignant_neoplasms = &interval / selection=rsquare adjrsq cp; 
	title "All Possible Model Selection for Malignant Neoplasms";
run; 
	/* Cardiovascular Diseases */
proc reg data=capstone.consumpfoodhealth plots(only)=(rsquare adjrsq cp); 
	model Cardiovascular_diseases = &interval / selection=rsquare adjrsq cp; 
	title "All Possible Model Selection for Cardiovascular Diseases";
run; 
	/* Chronic Obstructive Pulmonary */
proc reg data=capstone.consumpfoodhealth plots(only)=(rsquare adjrsq cp); 
	model Chronic_obstructive_pulmonary = &interval / selection=rsquare adjrsq cp; 
	title "All Possible Model Selection for Chronic Obstructive Pulmonary";
run; 
/* Step 8: Examine Residual Plots to check Model Assumptions and Check for Outliers */
	/* Diabetes Mellitus */
proc reg data=capstone.consumpfoodhealth; 
	model diabetes_mellitus = &interval; 
	title "Diabetes Model - Plots of Diagnostic Statistics"; 
run; 
proc reg data=capstone.consumpfoodhealth 
		plots(only)=(QQ RESIDUALBYPREDICTED RESIDUALS); 
	model diabetes_mellitus = &interval; 
	title "Diabetes Model - Plots of Diagnostic Statistics"; 
run;
	/* Malignant Neoplasms */
proc reg data=capstone.consumpfoodhealth; 
	model malignant_neoplasms = &interval; 
	title "Malignant Neoplasms Model - Plots of Diagnostic Statistics"; 
run; 
proc reg data=capstone.consumpfoodhealth 
		plots(only)=(QQ RESIDUALBYPREDICTED RESIDUALS); 
	model malignant_neoplasms = &interval; 
	title "Malignant Neoplasms Model - Plots of Diagnostic Statistics"; 
run;
	/* Cardiovascular Diseases */
proc reg data=capstone.consumpfoodhealth; 
	model Cardiovascular_diseases = &interval; 
	title "Cardiovascular Diseases Model - Plots of Diagnostic Statistics"; 
run;
proc reg data=capstone.consumpfoodhealth 
		plots(only)=(QQ RESIDUALBYPREDICTED RESIDUALS); 
	model Cardiovascular_diseases = &interval; 
	title "Cardiovascular Diseases Model - Plots of Diagnostic Statistics"; 
run;
	/* Chronic Obstructive Pulmonary */
proc reg data=capstone.consumpfoodhealth; 
	model Chronic_obstructive_pulmonary = &interval; 
	title "Chronic Obstructive Pulmonary Model - Plots of Diagnostic Statistics"; 
run; 
proc reg data=capstone.consumpfoodhealth 
		plots(only)=(QQ RESIDUALBYPREDICTED RESIDUALS); 
	model Chronic_obstructive_pulmonary = &interval; 
	title "Chronic Obstructive Pulmonary Model - Plots of Diagnostic Statistics"; 
run;
/* Step 9: Looking for Influential Observations */
	/* Diabetes Mellitus */
ods select none; 
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model diabetes_mellitus = &interval / selection=stepwise details=steps
		select=SL slentry=0.5; 
	title "Stepwise Model Selection for Diabetes - SL 0.05"; 
run; 
quit; 
ods select all; 

ods graphics on; 
ods output RSTUDENTBYPREDICTED=Rstud
		   COOKSDPLOT=Cook
		   DFFITSPLOT=Dffits
		   DFBETASPANEL=Dfbs;

proc reg data=capstone.consumpfoodhealth 
		plots(only label)=(RSTUDENTBYPREDICTED COOKSD DFFITS DFBETAS);
	model diabetes_mellitus = &_GLSIND; 
	title "SigLimit Model - Plots of Diagnostic Statistics";
run;
quit;

title;
proc print data=Rstud;
run;

proc print data=Cook; 
run;

proc print data=Dffits;
run;

proc print data=Dfbs; 
run;

data Dfbs01; 
	set Dfbs (obs=300);
run;

data dfbs02;
	set dfbs (firstobs=301);
run;

data dfbs2; 
	update dfbs01 dfbs02;
	by observation; 
run;

data influential; 
	merge Rstud 
		  Cook
		  Dffits
		  	Dfbs2; 
	by observation; 
	if (ABS(Rstudent)>3) or (Cooksdlabel ne ' ') or Dffitsout then flag=1;
	array dfbetas{*} _dfbetasout: ;
	do i=2 to dim(dfbetas);
		if dfbetas{i} then flag=1; 
	end;
	if ABS(Rstudent)<=3 then Rstudent=.;
	if Cooksdlabel eq ' ' then CooksD=.;
	if flag=1;
	drop i flag; 
run;

title;
proc print data=capstone.influential_diabetes;
	id observation;
	var Rstudent CooksD Dffitsout _dfbetasout;
run;
	/* Malignant Neoplasms */
ods select none; 
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model malignant_neoplasms = &interval / selection=stepwise details=steps
		select=SL slentry=0.5; 
	title "Stepwise Model Selection for Malignant Neoplasms - SL 0.05"; 
run; 
quit; 
ods select all; 

ods graphics on; 
ods output RSTUDENTBYPREDICTED=Rstud
		   COOKSDPLOT=Cook
		   DFFITSPLOT=Dffits
		   DFBETASPANEL=Dfbs;

proc reg data=capstone.consumpfoodhealth 
		plots(only label)=(RSTUDENTBYPREDICTED COOKSD DFFITS DFBETAS);
	model malignant_neoplasms = &_GLSIND; 
	title "SigLimit Model - Plots of Diagnostic Statistics";
run;
quit;

title;
proc print data=Rstud;
run;

proc print data=Cook; 
run;

proc print data=Dffits;
run;

proc print data=Dfbs; 
run;

data Dfbs01; 
	set Dfbs (obs=300);
run;

data dfbs02;
	set dfbs (firstobs=301);
run;

data dfbs2; 
	update dfbs01 dfbs02;
	by observation; 
run;

data influential; 
	merge Rstud 
		  Cook
		  Dffits
		  	Dfbs2; 
	by observation; 
	if (ABS(Rstudent)>3) or (Cooksdlabel ne ' ') or Dffitsout then flag=1;
	array dfbetas{*} _dfbetasout: ;
	do i=2 to dim(dfbetas);
		if dfbetas{i} then flag=1; 
	end;
	if ABS(Rstudent)<=3 then Rstudent=.;
	if Cooksdlabel eq ' ' then CooksD=.;
	if flag=1;
	drop i flag; 
run;

title;
proc print data=capstone.influential_neoplasms;
	id observation;
	var Rstudent CooksD Dffitsout _dfbetasout;
run;
	/* Cardiovascular Disease */
ods select none; 
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model Cardiovascular_diseases = &interval / selection=stepwise details=steps
		select=SL slentry=0.5; 
	title "Stepwise Model Selection for Cardiovascular Diseases - SL 0.05"; 
run; 
quit; 
ods select all; 

ods graphics on; 
ods output RSTUDENTBYPREDICTED=Rstud
		   COOKSDPLOT=Cook
		   DFFITSPLOT=Dffits
		   DFBETASPANEL=Dfbs;

proc reg data=capstone.consumpfoodhealth 
		plots(only label)=(RSTUDENTBYPREDICTED COOKSD DFFITS DFBETAS);
	model Cardiovascular_diseases = &_GLSIND; 
	title "SigLimit Model - Plots of Diagnostic Statistics";
run;
quit;

title;
proc print data=Rstud;
run;

proc print data=Cook; 
run;

proc print data=Dffits;
run;

proc print data=Dfbs; 
run;

data Dfbs01; 
	set Dfbs (obs=300);
run;

data dfbs02;
	set dfbs (firstobs=301);
run;

data dfbs2; 
	update dfbs01 dfbs02;
	by observation; 
run;

data influential; 
	merge Rstud 
		  Cook
		  Dffits
		  	Dfbs2; 
	by observation; 
	if (ABS(Rstudent)>3) or (Cooksdlabel ne ' ') or Dffitsout then flag=1;
	array dfbetas{*} _dfbetasout: ;
	do i=2 to dim(dfbetas);
		if dfbetas{i} then flag=1; 
	end;
	if ABS(Rstudent)<=3 then Rstudent=.;
	if Cooksdlabel eq ' ' then CooksD=.;
	if flag=1;
	drop i flag; 
run;

title;
proc print data=capstone.influential_cardio;
	id observation;
	var Rstudent CooksD Dffitsout _dfbetasout;
run;
	/* Chronic Obstructive Pulmonary */
ods select none; 
proc glmselect data=capstone.consumpfoodhealth plots=all; 
	model Chronic_obstructive_pulmonary = &interval / selection=stepwise details=steps
		select=SL slentry=0.5; 
	title "Stepwise Model Selection for Chronic Obstructive Pulmonary- SL 0.05"; 
run; 
quit; 
ods select all; 

ods graphics on; 
ods output RSTUDENTBYPREDICTED=Rstud
		   COOKSDPLOT=Cook
		   DFFITSPLOT=Dffits
		   DFBETASPANEL=Dfbs;

proc reg data=capstone.consumpfoodhealth 
		plots(only label)=(RSTUDENTBYPREDICTED COOKSD DFFITS DFBETAS);
	model Chronic_obstructive_pulmonary = &_GLSIND; 
	title "SigLimit Model - Plots of Diagnostic Statistics";
run;
quit;

title;
proc print data=Rstud;
run;

proc print data=Cook; 
run;

proc print data=Dffits;
run;

proc print data=Dfbs; 
run;

data Dfbs01; 
	set Dfbs (obs=300);
run;

data dfbs02;
	set dfbs (firstobs=301);
run;

data dfbs2; 
	update dfbs01 dfbs02;
	by observation; 
run;

data influential; 
	merge Rstud 
		  Cook
		  Dffits
		  	Dfbs2; 
	by observation; 
	if (ABS(Rstudent)>3) or (Cooksdlabel ne ' ') or Dffitsout then flag=1;
	array dfbetas{*} _dfbetasout: ;
	do i=2 to dim(dfbetas);
		if dfbetas{i} then flag=1; 
	end;
	if ABS(Rstudent)<=3 then Rstudent=.;
	if Cooksdlabel eq ' ' then CooksD=.;
	if flag=1;
	drop i flag; 
run;

title;
proc print data=capstone.influential_pulmonary;
	id observation;
	var Rstudent CooksD Dffitsout _dfbetasout;
run;
/* Step 10: Calculating Collinearity Diagnostics */
	/* Diabetes Mellitus */
proc corr data=capstone.consumpfoodhealth nosimple; 
	var &interval; 
	with score; 
run; 

proc reg data=capstone.consumpfoodhealth; 
	model diabetes_mellitus = &interval score / vif; 
	title "Collinearity Diagnostics";
run;
quit;

proc reg data=capstone.consumpfoodhealth; 
	model diabetes_mellitus = &interval / vif; 
	title2 "Removing Score";
run;
quit;

	/* Malignant Neoplasms */
proc corr data=capstone.consumpfoodhealth nosimple; 
	var &interval; 
	with score; 
run; 

proc reg data=capstone.consumpfoodhealth; 
	model malignant_neoplasms = &interval score / vif; 
	title "Collinearity Diagnostics";
run;
quit;

proc reg data=capstone.consumpfoodhealth; 
	model malignant_neoplasms = &interval / vif; 
	title2 "Removing Score";
run;
quit;

	/* Cardiovascular Disease */
proc corr data=capstone.consumpfoodhealth nosimple; 
	var &interval; 
	with score; 
run; 

proc reg data=capstone.consumpfoodhealth; 
	model cardiovascular_diseases = &interval score / vif; 
	title "Collinearity Diagnostics";
run;
quit;

proc reg data=capstone.consumpfoodhealth; 
	model cardiovascular_diseases = &interval / vif; 
	title2 "Removing Score";
run;
quit;
	/* Chronic Obstructive Pulmonary */
proc corr data=capstone.consumpfoodhealth nosimple; 
	var &interval; 
	with score; 
run; 

proc reg data=capstone.consumpfoodhealth; 
	model chronic_obstructive_pulmonary = &interval score / vif; 
	title "Collinearity Diagnostics";
run;
quit;

proc reg data=capstone.consumpfoodhealth; 
	model chronic_obstructive_pulmonary = &interval / vif; 
	title2 "Removing Score";
run;
quit;



