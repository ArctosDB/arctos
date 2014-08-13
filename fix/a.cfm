<cfinclude template="/includes/_header.cfm">
<script src="/includes/jquery.multiselect.min.js"></script>
jquery.multiselect.css
<link rel="stylesheet" href="/includes/jquery.multiselect.css" />

<!----
<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/ui-lightness/jquery-ui.css" />
---->





<script>
$(function(){
   $("select").multiselect(); 
});
</script>

<cfoutput>
<cfif action is "fs">
	<cfdump var=#form#>
</cfif>
<form method="post" action="a.cfm">

<select name="example-optgroup" multiple="multiple" size="5">
	<optgroup label="Group One">
		<option value="option1">Option 1</option>
		<option value="option2">Option 2</option>
		<option value="option3">Option 3</option>
	</optgroup>
	<optgroup label="Group Two">
		<option value="option4">Option 4</option>
		<option value="option5">Option 5</option>
		<option value="option6">Option 6</option>
		<option value="option7">Option 7</option>
	</optgroup>
	</select>
	
	
	<input type="hidden" name="action" value="fs">
	<input type="submit">
	</form>
	
	
	
<!----
drop table temp_mp;

create table temp_mp as select media_id,media_uri,PREVIEW_URI from media where PREVIEW_URI is not null;

alter table temp_mp add checkeddate date;
alter table temp_mp add previewfilesize number;
alter table temp_mp add previewstatus varchar2(200);
alter table temp_mp add mediastatus varchar2(200);


create unique index ix_temp_mid on temp_mp(media_id) tablespace uam_idx_1;






	<cfquery name="d" datasource="uam_god">
		select * from temp_mp where previewfilesize is null and rownum<500
	</cfquery>
	<cfloop query="d">
		<cfhttp method="head" timeout="2" url="#PREVIEW_URI#"></cfhttp>
		<cfset pfs=cfhttp.Responseheader["Content-Length"]>
		<cfset ps=cfhttp.Responseheader.Status_Code>
		<cfif media_uri contains 'http://web.corral.tacc.utexas.edu'>
			<cfset ms='on_tacc_nocheck'>
		<cfelse>
			<cfhttp method="head" timeout="2" url="#media_uri#"></cfhttp>
			<cfset ms=cfhttp.Responseheader["Status_Code"]>
		</cfif>
		<cfquery name="u" datasource="uam_god">
			update 
				temp_mp 
			set 
				checkeddate=sysdate,
				previewfilesize=#pfs#,
				previewstatus='#ps#',
				mediastatus='#ms#'
			where 
				media_id=#media_id#
		</cfquery>
	</cfloop>
	
	
	
	---->
</cfoutput>