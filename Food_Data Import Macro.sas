/*Create Macro to Create a List of all the CSV files in the Folder*/

%global caps;
%let caps=/folders/myshortcuts/myfolder/Capstone; 
libname capstone "&caps";


%macro list_files(dir, ext);
	%local filrf rc did memcnt name i;
	%let rc=%sysfunc(filename(filrf, &dir));
	%let did=%sysfunc(dopen(&filrf));

	%if &did eq 0 %then
		%do;
			%put Directory &dir cannot be open or does not exist;
			%return;
		%end;

	%do i=1 %to %sysfunc(dnum(&did));
		%let name=%qsysfunc(dread(&did, &i));

		%if %qupcase(%qscan(&name, -1, .))=%upcase(&ext) %then
			%do;
				%put &dir\&name;
				%let file_name =  %qscan(&name, 1, .);
				%put &file_name;

				data _tmp;
					length dir $512 name $100;
					dir=symget("dir");
					name=symget("name");
					path=catx('\', dir, name);
					the_name=substr(name, 1, find(name, '.')-1);
				run;

				proc append base=list data=_tmp out=work.list force;
				run;

				quit;

				proc sql;
					drop table _tmp;
				quit;

			%end;
		%else %if %qscan(&name, 2, .)=%then
			%do;
				%list_files(&dir\&name, &ext) 
			%end;
	%end;
	%let rc=%sysfunc(dclose(&did));
	%let rc=%sysfunc(filename(filrf));
		
%mend list_files;

/*Finish Macro and create code to import datasets, and also remove extraneous obs*/

%macro import_file(path, file_name, dataset_name );

		data &dataset_name REPLACE;
			INFILE "&path./&file_name." firstobs=5 obs=9 dsd truncover end=last;
			LENGTH Nutrient $20 Amount 8. Namevar $50;
			Namevar = "&file_name";
			Namevar = substr(Namevar,1,(length(Namevar)-4));
			INPUT Nutrient Amount;

			if not last then
				output;
		run;
		
		proc transpose data=&dataset_name out=&dataset_name (DROP=_NAME_);
			VAR Amount;
			ID Nutrient;
			BY Namevar;
		run;
		
		proc append base = H1
			data = &dataset_name FORCE;
		run; 

		

%mend;

%list_files(/folders/myshortcuts/myfolder/food_data, csv);

/*This code will iterate through the files and import each of them with a new title*/

	data _null_;
		set list;
		string=catt('%import_file(', dir, ', ', name, ', ', catt('H', _n_, ');'));
		call execute (string);
	run;
	
/*This code will sort the data and remove duplicate values*/

PROC SORT DATA=H1
	 OUT=capstone.combined_food_data
	 NODUPKEY;
	 BY Namevar;
RUN ;


		