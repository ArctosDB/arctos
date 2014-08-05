<cfinclude template="/includes/_header.cfm">


<cfoutput>

<!----
drop table temp_mp;

create table temp_mp as select media_id,media_uri,PREVIEW_URI from media where PREVIEW_URI is not null;

alter table temp_mp add checkeddate date;
alter table temp_mp add previewfilesize number;
alter table temp_mp add previewstatus number;
alter table temp_mp add mediastatus number;

---->




<cfquery name="d" datasource="uam_god">
	select * from temp_mp where checkeddate is null and rownum<10
</cfquery>
<cfloop query="d">
<hr>
<br>media_id: #media_id#

<cfhttp method="head" timeout="2" url="#PREVIEW_URI#"></cfhttp>
<br>--cfhttp--
<cfdump var=#cfhttp#>
<br>--cfhttp.Responseheader--
<cfdump var=#cfhttp.Responseheader#>

<cfset previewfilesize=cfhttp.Responseheader["Content-Length"]>
<cfset previewstatus=cfhttp.Responseheader.Status_Code>

<br>previewfilesize: #previewfilesize#
<br>previewstatus: #previewstatus#
<cfif media_uri contains 'http://web.corral.tacc.utexas.edu'>
	<cfset mediastatus='on_tacc_nocheck'>
<cfelse>

	<cfhttp method="head" timeout="2" url="#media_uri#"></cfhttp>
	<cfdump var=#cfhttp#>
	<cfset mediastatus=cfhttp.Responseheader["Status_Code"]>
</cfif>


<br>mediastatus: #mediastatus#

<cfquery name="u" datasource="uam_god">
	update 
		temp_mp 
	set 
		checkeddate=sysdate,
		previewfilesize=#previewfilesize#,
		previewstatus='#previewstatus#',
		mediastatus='#mediastatus#'
	where 
		media_id=#media_id#
</cfquery>


</cfloop>

	
</cfoutput>