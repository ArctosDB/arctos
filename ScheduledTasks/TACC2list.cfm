<!---
create table tacc_folder (
	folder varchar2(255),
	file_count number
	);
	
create table tacc_check (
	collection_object_id number,
	barcode varchar2(255),
	folder varchar2(255),
	chkdate date default sysdate)
	;
--->

<cfoutput>
	<cfquery name="all_tacc" datasource="uam_god">
		select distinct(barcode) from tacc_check where status='all_done' order by barcode
	</cfquery>
	<cfset t="">
	<cfloop query="all_tacc">
		<cfset t = t & "#barcode#.dng#chr(10)#">
	</cfloop>
	<cffile action="write" file="#application.webDirectory#/temp/tacc.txt" output="#t#">
</cfoutput>


uam> update tacc set FULLPATH=replace(FULLPATH,'goodnight','web') where FULLPATH like '%goodnight%';
OLLECTION_OBJECT_ID						NUMBER
 BARCODE							VARCHAR2(255)
 FOLDER 							VARCHAR2(255)
 CHKDATE							DATE
 STATUS 							VARCHAR2(255)
 JPG_STATUS							VARCHAR2(255)

uam> desc tacc
 Name						       Null?	Type
 ----------------------------------------------------- -------- ------------------------------------
 FULLPATH							VARCHAR2(4000)
 FILENAME							VARCHAR2(255)
 FILETYPE							VARCHAR2(255)
 LASTDATE							DATE
 CRAWLED_PATH_DATE						DATE
 COLLECTION_OBJECT_ID						NUMBER
 STATUS 							VARCHAR2(255)
