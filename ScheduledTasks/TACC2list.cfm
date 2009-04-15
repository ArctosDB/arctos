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
		select barcode from tacc_check order by barcode
	</cfquery>
	<cfset t="">
	<cfloop query="all_tacc">
		<cfset t = t & "#barcode#.dng#chr(10)#">
	</cfloop>
	<cffile action="write" file="#application.webDirectory#/temp/tacc.txt" output="#t#">
</cfoutput>