%LET job = SQLC2;
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
*  Job name:      SQLC2_jenewong.sas   
*
*  Purpose:       Comparison of created schedule data set 
* 		   	  	  using MIMIC icustays data set
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data set caregivers, chartevents, d_item, 
*				  patients, admissions  
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

PROC CONTENTS DATA = mimic.caregivers;
RUN;

PROC CONTENTS DATA = mimic.chartevents;
RUN;

PROC CONTENTS DATA = mimic.d_items;
RUN;

*PDF output;
ODS PDF FILE = "&outdir/PDFs/&job._&onyen..PDF" STYLE = JOURNAL;
 
PROC SQL;

	TITLE "Caregiver Schedule for Charting done on Feb. 6, 2107";
	CREATE TABLE schedule AS
	SELECT p.subject_id, a.admission_type, p.gender, c.cgid, c.label, 
	       d.label AS Task, 
	       h.charttime 
	FROM mimic.patients AS p,
		 mimic.admissions AS a,
		 mimic.caregivers AS c,
		 mimic.chartevents AS h,
		 mimic.d_items AS d
	WHERE c.cgid = h.cgid AND 
		  h.subject_id = p.subject_id = a.subject_id AND 
		  h.itemid = d.itemid AND
		  c.label = "RN" AND
		  DATEPART(h.charttime) = "06FEB2107"d
	ORDER BY h.charttime, cgid, task;

QUIT;

PROC PRINT DATA = schedule (OBS = 10);
RUN;

PROC SORT DATA = mimic.patients (KEEP = subject_id gender) OUT = patients;
	BY subject_id;
RUN;

PROC SORT DATA = mimic.admissions (KEEP = subject_id admission_type) OUT = admissions;
	BY subject_id;
RUN;

PROC SORT DATA = mimic.chartevents (KEEP = subject_id charttime cgid itemid) OUT = chartevents;
	BY subject_id;
RUN;

DATA schedule2;
	MERGE patients (IN = p)
		  admissions (IN = a)
		  chartevents (IN = h);
	BY subject_id;
		IF DATEPART(charttime) = "06FEB2107"d;
	IF p AND a AND h;
RUN;

PROC SORT DATA = schedule2 OUT = schedule2a;
	BY cgid;
RUN;

PROC SORT DATA = mimic.caregivers (KEEP = cgid label) OUT = caregivers;
	BY cgid;
RUN;

DATA schedule3;
	MERGE schedule2a (IN = s2)   
		  caregivers (IN = c RENAME = (Label = Caregiver));
	BY cgid;
		IF caregiver = "RN";
	IF s2 AND c;
RUN;

PROC SORT DATA = schedule3 OUT = schedule3a;
	BY itemid;
RUN;

PROC SORT DATA = mimic.d_items (KEEP = itemid label) OUT = ditems;
	BY itemid;
RUN; 

DATA schedule4;
	MERGE schedule3a (IN = s3)   
		  ditems (IN = d RENAME = (Label = Task));
	BY itemid;
	IF s3 AND d;
	DROP itemid;
RUN;

PROC SORT DATA = schedule4 OUT = schedule4a;
	BY charttime cgid task;
RUN;

PROC PRINT DATA = schedule4a (OBS = 10);
RUN;

PROC COMPARE BASE = schedule COMPARE = schedule4a LISTALL;
	TITLE "Comparing the datasets ";
RUN;

ODS PDF CLOSE;


PROC PRINTTO; 
RUN; 
*closes open log file;
