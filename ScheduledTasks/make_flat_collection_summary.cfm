
<cfquery name="getFLD" datasource="uam_god">
	select * from ssrch_field_doc where SPECIMEN_RESULTS_COL=1 order by DISP_ORDER
</cfquery>
<cfoutput>
<cfquery name="mktbl" datasource="uam_god">
		create table temp_kwp_exp as select
	<cfloop query="getFLD">
		<cfset s=replace(SQL_ELEMENT,'flatTableName','flat')>

			#preservesinglequotes(s)# AS #CF_VARIABLE#,
	</cfloop>
	sysdate as compiled_date from flat where guid like 'KWP:Ento:%'
	</cfquery>
</cfoutput>