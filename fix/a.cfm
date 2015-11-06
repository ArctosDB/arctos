<cftry>
	<cfquery name="x" datasource="uam_god">
		select * from agent where preferred_agent_name='#q#'
	</cfquery>
	<cfdump var=#x#>
	<cfcatch>
		<cfdump var=#cfcatch#>
	</cfcatch>
</cftry>


<cftry>
	<cfset x="select * from agent where preferred_agent_name='#q#'">
	<cfquery name="x" datasource="uam_god">
		#preservesinglequotes(x)#
	</cfquery>
	<cfdump var=#x#>
	<cfcatch>
		<cfdump var=#cfcatch#>
	</cfcatch>
</cftry>




