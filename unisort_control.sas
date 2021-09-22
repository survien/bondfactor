
%macro unisort_control(dataname,tvar,varnme,wvar,varc,numc,outname);
ods noresults;
ods exclude all;
ods graphics off;
*;
proc sort data=&dataname;by &tvar &varc;run;
proc rank data=&dataname out=rankc group=&numc;
  by &tvar;
  var &varc;
  ranks rankc;
run;
proc sort data=rankc;by &tvar rankc;run;
*Summarize the bond numbers in each rank in each month;
*calculate the means;
%if %length(&wvar)~=0 %then %do;
	proc means data=rankc noprint;
		by &tvar rankc;
		var &varnme;
		weight &wvar;
		output out=_mean_1 mean=&varnme;
	run;
%end;
%if %length(&wvar)=0 %then %do;
	proc means data=rankc noprint;
		by &tvar rankc;
		var &varnme;
		output out=_mean_1 mean=&varnme;
	run;
%end;

data &outname;length portname $12.;set _mean_1;
	do i=0 to %eval(&numc-1);
		if rankc=i then portname=compress(cat("&varc",put(i,2.)));
	end;
	drop i _type_ rankc _freq_;
run;
*;
proc datasets library=work nolist noprint;
	delete _mean_l _t_mean_1 rankc;
quit;
*;
ods graphics on;
ods exclude none;
ods results;
%mend unisort_control;

****Nominal Sorting Control;
%macro unisort_nom_control(dataname,tvar,varnme,wvar,varc,numc,outname);
ods noresults;
ods exclude all;
ods graphics off;
*;
proc sort data=&dataname;by &tvar &varc;run;
*Summarize the bond numbers in each rank in each month;
%if %length(&wvar)~=0 %then %do;
	proc means data=&dataname noprint;
		by &tvar &varc;
		var &varnme;
		weight &wvar;
		output out=_mean_1 mean=&varnme;
	run;
%end;
%if %length(&wvar)=0 %then %do;
	proc means data=&dataname noprint;
		by &tvar &varc;
		var &varnme;
		output out=_mean_1 mean=&varnme;
	run;
%end;

data &outname;length portname $12.;set _mean_1;
	do i=0 to %eval(&numc-1);
		if &varc=i then portname=compress(cat("&varc",put(i,2.)));
	end;
	drop &varc i _type_ _freq_;
run;
*;
proc datasets library=work nolist noprint;
	delete _mean_l;
quit;
*;
ods graphics on;
ods exclude none;
ods results;
%mend unisort_nom_control;
