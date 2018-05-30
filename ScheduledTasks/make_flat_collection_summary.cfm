
<cfquery name="getFLD" datasource="uam_god">
	select * from ssrch_field_doc where SPECIMEN_RESULTS_COL=1 order by DISP_ORDER
</cfquery>
<cfoutput>
		select
	<cfloop query="getFLD">
			#replace(SQL_ELEMENT,'flatTableName','flat')# AS #CF_VARIABLE#,

	</cfloop>
</cfoutput>