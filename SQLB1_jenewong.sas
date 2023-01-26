%LET job = SQLB1;
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
*  Job name:      SQLB1_jenewong.sas   
*
*  Purpose:       Report of patients ICU stays using MIMIC icustays data set
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

PROC PRINT DATA = mimic.icustays;
	VAR subject_id LOS;
RUN;

*PDF output;
ODS PDF FILE = "&outdir/PDFs/&job._&onyen..PDF" STYLE = JOURNAL;
 

PROC SQL;
	
	TITLE "Number of ICU Stays and Total Number of Days in an ICU Unit for each Patient";
	SELECT subject_id, COUNT(icustay_id) AS Count LABEL "Number of ICU stays",
		SUM(LOS) AS TotDays LABEL "Total number of days in an ICU unit"
	FROM mimic.icustays
	GROUP BY subject_id
	ORDER BY Count DESC;

	TITLE1 "Patients with more than 2 ICU stays";
	TITLE2 "or who Spent more than 20 days total in an ICU unit";
	SELECT subject_id, COUNT(icustay_id) AS Count LABEL "Number of ICU stays",
		SUM(LOS) AS TotDays LABEL "Total number of days in an ICU unit"
	FROM mimic.icustays
	GROUP BY subject_id
	HAVING Count > 2 OR TotDays > 20
	ORDER BY Count DESC;
	
QUIT;

ODS PDF CLOSE;


PROC PRINTTO; 
RUN; 
*closes open log file;
