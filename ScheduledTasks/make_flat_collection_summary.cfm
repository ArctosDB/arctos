
<cfquery name="getFLD" datasource="uam_god">
	select * from ssrch_field_doc where SPECIMEN_RESULTS_COL=1 order by DISP_ORDER
</cfquery>


<cfoutput>
	<cfset s="create table temp_kwp_exp as select ">
	<cfloop query="getFLD">
		<cfset s=s & "#replacenocase(SQL_ELEMENT,'flatTableName','flat')# AS #CF_VARIABLE#,">
	</cfloop>
	<cfset s=s & " sysdate as compiled_date from flat where guid like 'KWP:Ento:%'">


	<cfdump var=#s#>


	<cfquery name="mktbl" datasource="uam_god">
		#preservesinglequotes(s)#
	</cfquery>
</cfoutput>