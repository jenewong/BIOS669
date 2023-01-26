%LET job = SQLA1;
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
*  Job name:      SQLA1_jenewong.sas   
*
*  Purpose:       Run basic queries on MIMIC Patients data set.
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set patients (could also list macros or 
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

PROC CONTENTS DATA = mimic.patients;
RUN; 

*PDF output;
ODS PDF FILE = "&outdir/PDFs/&job._&onyen..PDF" STYLE = JOURNAL;


PROC FORMAT;
	VALUE $genderf
	"M" = "Male"
	"F" = "Female";
RUN;

PROC SQL NUMBER;

	TITLE "MIMIC Patients data set";
	SELECT *
	FROM mimic.patients;
	
	TITLE "Demographics of Patients in the Critical Care Unit";
	SELECT subject_id, gender, dob, dod
	FROM mimic.patients;

	TITLE "Demographics Patients in the Critical Care Unit";
	SELECT subject_id, put(gender,$genderf.) AS Gender LABEL = "Patient Gender", dob, dod
	FROM mimic.patients;
	
	TITLE "Demographics of Patients in the Critical Care Unit: Calculated Age of Death";
	SELECT subject_id, put(gender,$genderf.) AS Gender LABEL = "Patient Gender", dob, dod,
		INT((dod-dob)/365.25) AS AgeAtDeath LABEL = "Age at Death"
	FROM mimic.patients;
	
	TITLE "Demographics of Patients in the Critical Care Unit with an
			Age at Death of Less than 120 Years";
	SELECT subject_id, put(gender,$genderf.) AS Gender LABEL = "Patient Gender", dob, dod,
		INT((dod-dob)/365.25) AS AgeAtDeath LABEL = "Age at Death"
	FROM mimic.patients
	WHERE CALCULATED AgeAtDeath < 120;
	
	TITLE "Demographics of Male Patients in the Critical Care Unit
			with an Age at Death of Less than 120 Years";
	SELECT subject_id, put(gender,$genderf.) AS Gender LABEL = "Patient Gender",
		INT((dod-dob)/365.25) AS AgeAtDeath LABEL = "Age at Death"
	FROM mimic.patients
	WHERE CALCULATED AgeAtDeath < 120 AND gender = "M";
	
	TITLE "Demographics of Male Patients in the Crtical Care Unit
			with an Age at Death of Less than 120 Years: Sorted Oldest to Youngest";
	SELECT subject_id, put(gender,$genderf.) AS Gender LABEL = "Patient Gender",
		INT((dod-dob)/365.25) AS AgeAtDeath LABEL = "Age at Death"
	FROM mimic.patients
	WHERE CALCULATED AgeAtDeath < 120 AND gender = "M"
	ORDER BY CALCULATED AgeAtDeath DESC;
	
	TITLE "Demographics of Patients in the Critical Care Unit
			with an Age at Death 80-120 Years";
	CREATE TABLE HIGH_AGE AS
	SELECT subject_id, put(gender,$genderf.) AS Gender LABEL = "Patient Gender",
		INT((dod-dob)/365.25) AS AgeAtDeath LABEL = "Age at Death"
	FROM mimic.patients
	WHERE 80 <= CALCULATED AgeAtDeath < 120 
	ORDER BY subject_id;
QUIT;

PROC PRINT DATA = HIGH_AGE;
RUN;

ODS PDF CLOSE;


PROC PRINTTO; 
RUN; 
*closes open log file;
