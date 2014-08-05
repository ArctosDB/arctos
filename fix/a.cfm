<cfinclude template="/includes/_header.cfm">


<cfoutput>

create table temp_mp as select media_uri,PREVIEW_URI from media where PREVIEW_URI is not null;

alter table temp_mp add checkeddate date;
alter table temp_mp add previewfilesize number;


<cfquery name="d" datasource="uam_god">
	select * from temp_mp where checkeddate is null and rownum<10
</cfquery>
<cfloop query="d">

<cfhttp method="head" timeout="99" url="#PREVIEW_URI#"></cfhttp>
<cfdump var=#cfhttp#>
<cfquery name="u" datasource="uam_god">
	update temp_mp set checkeddate=sysdate,previewfilesize=#cfhttp.Responseheader["Content-Length"]# where media_id=#media_id#
</cfquery>


</cfloop>

	
</cfoutput>