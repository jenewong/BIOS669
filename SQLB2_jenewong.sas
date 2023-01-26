%LET job = SQLB2;
%LET onyen = jenewong;
%LET outdir = /home/u59075382/bios669/SQLB;

PROC PRINTTO LOG = "&outdir/Logs/&job._&onyen..log" NEW;
RUN; *opens a log file to write to*;

*********************************************************************
*  Assignment:    SQLB                                         
*                                                                    
*  Description:   Second collection of PROC SQL problems using 
*                 MIMIC data sets
*
*  Name:          Jennifer Wong
*
*  Date:          1/23/2023                                     
*------------------------------------------------------------------- 
*  Job name:      SQLB2_jenewong.sas   
*
*  Purpose:       Report of patients ICU care unit stays using MIMIC icustays data set
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set icustays (could also list macros or 
*                 other external files that you are accessing)
*
*  Output:        PDF file (you might also be making permanent data
*                 sets, xls files, etc. that you should list here)     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY = WARN VARINITCHK = WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

LIBNAME mimic "/home/u59075382/my_shared_file_links/klh52250/MIMIC" ACCESS = readonly;


PROC CONTENTS DATA = mimic.icustays;
RUN;

PROC FREQ DATA = mimic.icustays;
	TABLE subject_id*first_careunit / NOPERCENT NOCOL NOROW;
RUN;

*PDF output;
ODS PDF FILE = "&outdir/PDFs/&job._&onyen..PDF" STYLE = JOURNAL;
 
PROC FORMAT;
	VALUE $careunitf
	"CCU" = "Coronary care unit" 
	"CSRU" = "Cardiac surgery recovery unit" 
	"MICU" = "Medical intensive care unit" 
	"NICU" = "Neonatal intensive care unit" 
	"NWARD" = "Neonatal ward" 
	"SICU" = "Surgical intensive care unit" 
	"TSICU" = "Trauma/surgical intensive care unit";
RUN;

PROC SQL;
	
	TITLE "Number of ICU stays and total number of days in an ICU unit";
	SELECT put(first_careunit,$careunitf.) AS CareUnite LABEL "Care Unit",
		COUNT(icustay_id) AS Count LABEL "Number of ICU stays"
	FROM mimic.icustays
	GROUP BY first_careunit
	ORDER BY Count DESC;
	
	TITLE1 "Number of subjects for each care unit*";
	TITLE2 "*subjects counted once per care unit";
	SELECT put(first_careunit,$careunitf.) AS CareUnite LABEL "Care Unit",
		COUNT(DISTINCT subject_id) AS Subject LABEL "Number of Subjects"
	FROM mimic.icustays
	GROUP BY first_careunit
	ORDER BY Subject DESC;
	
	CREATE TABLE alos AS
	SELECT put(first_careunit,$careunitf.) AS CareUnite LABEL "Care Unit",
		COUNT(icustay_id) AS Count LABEL "Number of ICU stays",
		AVG(LOS) AS AvgLOS LABEL "Average Length of Stay"
	FROM mimic.icustays
	GROUP BY first_careunit
	ORDER BY AvgLOS DESC;

QUIT;

PROC PRINT DATA = alos LABEL;
TITLE "Number of ICU stays and average length of stay for each care unit";
RUN;

PROC MEANS DATA = mimic.icustays NOPRINT NWAY;
	CLASS first_careunit;
	VAR LOS;
	FORMAT first_careunit $careunitf.;
	OUTPUT OUT = d N = Num_ICUstays MEAN = AverageLOS;
RUN;

PROC SORT DATA = d (DROP = _TYPE_ _FREQ_);
	BY AverageLOS;
RUN;

PROC PRINT DATA = d LABEL;
	TITLE "Number of ICU stays and average length of stay for each care unit";
RUN;

ODS PDF CLOSE;


PROC PRINTTO; 
RUN; 
*closes open log file;
