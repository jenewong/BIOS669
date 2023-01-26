%LET job = SQLA2;
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
*  Job name:      SQLA2_jenewong.sas   
*
*  Purpose:       Report on each patient stay and how long they waited for acknowledgement 
*				  of their approval to be discharged with MIMIC Patients data set.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set callout (could also list macros or 
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


PROC CONTENTS DATA = mimic.callout;
RUN;

*PDF output;
ODS PDF FILE = "&outdir/PDFs/&job._&onyen..PDF" STYLE = JOURNAL;

PROC SQL;
	TITLE "Percent of Wait Time Each Patient Waited for Acknowledgement and Approval to be Discharged";
	SELECT hadm_id,(INTCK("min", createtime, outcometime)) AS TotalWaitTime LABEL = "Total Wait Time",
		(((INTCK("min", createtime, acknowledgetime)))/ CALCULATED TotalWaitTime)
				AS PercentWaitforAck LABEL = "Percent of Time Waiting" 
				FORMAT = percent7.1
	FROM mimic.callout
	WHERE NOT missing(acknowledgetime)
	ORDER BY PercentWaitforAck DESC;
QUIT;

ODS PDF CLOSE;


PROC PRINTTO; 
RUN; 
*closes open log file;
