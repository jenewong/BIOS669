%LET job = SQLC1;
%LET onyen = jenewong;
%LET outdir = /home/u59075382/bios669/SQLC;

PROC PRINTTO LOG = "&outdir/Logs/&job._&onyen..log" NEW;
RUN; *opens a log file to write to*;

*********************************************************************
*  Assignment:    SQLC                                         
*                                                                    
*  Description:   Third collection of PROC SQL problems using 
*                 MIMIC data sets
*
*  Name:          Jennifer Wong
*
*  Date:          1/25/2023                                     
*------------------------------------------------------------------- 
*  Job name:      SQLC1_jenewong.sas   
*
*  Purpose:       Report of subjects admitted in the same month as their
*				  birthday using MIMIC icustays data set
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set patients, admissions  
*                 
*
*  Output:        PDF file (you might also be making permanent data
*                 sets, xls files, etc. that you should list here)     
*                                                                    
********************************************************************;

OPTIONS NODATE MPRINT MERGENOBY = WARN VARINITCHK = WARN NOFULLSTIMER;
ODS _ALL_ CLOSE;
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

LIBNAME mimic "/home/u59075382/my_shared_file_links/klh52250/MIMIC" ACCESS = readonly;


PROC CONTENTS DATA = mimic.patients;
RUN;

PROC CONTENTS DATA = mimic.admissions;
RUN;


*PDF output;
ODS PDF FILE = "&outdir/PDFs/&job._&onyen..PDF" STYLE = JOURNAL;
 
PROC SQL;

	TITLE "Subjects Admitted in the Same Month as their Birth Month";
	SELECT subject_id, put(dobMonth, MONNAME.) AS MONTH
	FROM
		(SELECT p.subject_id, p.dob AS dobMonth LABEL = "DOB Month" FORMAT = MONTH., 
			   	DATEPART(a.admittime) AS MonthAdmit LABEL = "Admit Month" FORMAT = MONTH.
		FROM mimic.patients AS p,
		 	 mimic.admissions AS a
		WHERE p.subject_id = a.subject_id)
	WHERE put(dobMonth, MONTH.) = put(MonthAdmit, MONTH.);

QUIT;

ODS PDF CLOSE;


PROC PRINTTO; 
RUN; 
*closes open log file;
