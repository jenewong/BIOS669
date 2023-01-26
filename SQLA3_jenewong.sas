%LET job = SQLA3;
%LET onyen = jenewong;
%LET outdir = /home/u59075382/bios669/SQLA;

PROC PRINTTO LOG = "&outdir/Logs/&job._&onyen..log" NEW;
RUN; *opens a log file to write to*;

*********************************************************************
*  Assignment:    SQLA                                         
*                                                                    
*  Description:   First collection of PROC SQL problems using 
*                 MIMIC data sets
*
*  Name:          Jennifer Wong
*
*  Date:          1/18/2023                                     
*------------------------------------------------------------------- 
*  Job name:      SQLA3_jenewong.sas   
*
*  Purpose:       Run basic queries on MIMIC Admissions data set
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set admissions (could also list macros or 
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


PROC CONTENTS DATA = mimic.admissions;
RUN;

*PDF output;
ODS PDF FILE = "&outdir/PDFs/&job._&onyen..PDF" STYLE = JOURNAL;
 

PROC SQL;
	
	TITLE "All Insurance Types that Patients Have";
	SELECT DISTINCT insurance AS Insurance LABEL "Patient's Medical Insurance Types"
	FROM mimic.admissions
	ORDER BY insurance;

	TITLE "Count of Number of Different Unique Discharge Locations";
	SELECT COUNT(DISTINCT discharge_location) AS DisLoc LABEL "Discharge Location"
	FROM mimic.admissions;
	
	TITLE "Number of Times a Unique Discharge Location appears in the Data Set";
	SELECT DISTINCT discharge_location, COUNT(discharge_location) AS Count
	FROM mimic.admissions
	GROUP BY discharge_location
	ORDER BY Count DESC;
	
QUIT;

ODS PDF CLOSE;


PROC PRINTTO; 
RUN; 
*closes open log file;
