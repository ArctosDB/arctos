<cfinclude template="/includes/_header.cfm">
<cfoutput>
agentDeAbbreviate.cfm
		<cfquery name="d" datasource="uam_god">
			select
				agent_id,
				preferred_agent_name from agent where
			agent_type='person' and preferred_agent_name like '%Dr.%' and
			  agent_id not in (select agent_id from agent_relations where agent_relationship='bad duplicate of')
			order by preferred_agent_name
		</cfquery>
		<cfloop query="d">
			<br>#preferred_agent_name#
			<cfset shouldFindName=replace(d.preferred_agent_name,'Dr. ','','all')>
			<br>#shouldFindName#
			<cfquery name="hg"  datasource="uam_god">
				select * from agent_name where agent_name='#shouldFindName#'
			</cfquery>
			<cfif hg.recordcount gte 1>
				<cfdump var=#hg#>
			</cfif>

		</cfloop>

</cfoutput>

