libname bond "H:\Research Data\Bond";
libname newBond "H:\Research Data\Bond\new_data";
libname newfact "H:\Research Data\Bond\new_factor";
libname regdata "H:\Research Data\Bond\reg_data";

*Include the macros;
%include "E:\My Work\Research\Project_Bond Market\scripts\macro\doublesort.sas";
%include "H:\Research Data\SASMACRO\AssetPricing\doublesort_control.sas";
%include "H:\Research Data\SASMACRO\AssetPricing\rollingRegression.sas";

**************************Interbank Market***********************;
%let ratetype=%str(("固定利率"));
%let bondtype=%str(("超短期融资债券","一般短期融资券","一般企业债","一般公司债","一般中期票据"));
%let mkttype=((1));
data tmplast1;set newfact.volliq_rank;
intmon=intck('month',startdate,lagdate);
if v18 in &bondtype;
if markettype in &mkttype;
if ratetype in &ratetype;
mretn=100*mretn;
amihud_1mon=amihud_1mon*1000;
amtmon=amtmon/(10**8);
run;
data tmplast2;
	set tmplast1;
	if not missing(amihud_1mon) and not missing(rating2);
run;
proc sort data=tmplast2 nodupkey out=bondmon(keep=secid trdmon);
by trdmon secid;run;
data tmplast3;set tmplast2;if trdmon>input("2009-12-31",YYMMDD10.);
if rating1<=3;
run;

**************Independent Sorting 3x3 based on credit rating and Amihud_1mon*****************************;
%let varc=rating1;%let nums=3;
proc sort data=tmplast3;by trdmon;run;
proc rank data=tmplast3 out=_ranks group=&nums;
	by trdmon;
	var amihud_1mon;
	ranks ranks;
run;

*;
proc sort data=_ranks;by trdmon rating1 ranks;run;
proc means data=_ranks noprint;
by trdmon rating1 ranks;weight v23;
var mretn;
output out=_means mean=mretn;run;
proc transpose data=_means out=_means_t(drop=_name_) prefix=port;
by trdmon;
id rating1 ranks;
var mretn;
run;

*;
data newfact.inter2fac;set _means_t;
credit_G=(port10+port11+port12)/3;
credit_M=(port20+port21+port22)/3;
credit_B=(port30+port31+port32)/3;
*;
illiq_L=(port10+port20+port30)/3;
illiq_M=(port11+port21+port31)/3;
illiq_H=(port12+port22+port32)/3;
drop port10 port11 port12 port20 port21 port22 port30 port31 port32 port32;

*;
INTERCRD=credit_B-credit_G;
INTERLIQ=illiq_H-illiq_L;
run;

*;
DATA tmp;set newfact.inter2fac;RUN;
filename myfile "H:\Research Data\Bond\bondexcel\volfactor_inter.txt" encoding=unicode;
proc export data=tmp
outfile=myfile
DBMS=TAB REPLACE; run;
proc datasets library=work kill noprint nolist;quit;
