
<cfquery name="getFLD" datasource="uam_god">
	select * from SPECIMEN_RESULTS_COL where SPECIMEN_RESULTS_COL=1
</cfquery>
<cfoutput>
		select
	<cfloop query="getFLD">
			#replace(SQL_ELEMENT,'flatTableName','flat')# AS CF_VARIABLE,

	</cfloop>
</cfoutput>