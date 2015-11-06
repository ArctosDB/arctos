<cftry>

	<cfquery name="x" datasource="uam_god">
		select * from agent where preferred_agent_name='#q#'
	</cfquery>

	<cfcatch>
		<cfdump var=#cfcatch#>
	</cfcatch>
</cftry>

