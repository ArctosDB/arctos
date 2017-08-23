<cfinclude template="/includes/_header.cfm">
<cfoutput>
agentDeAbbreviate.cfm
		<cfquery name="d" datasource="uam_god">
			select preferred_agent_name from agent where
agent_type='person' and preferred_agent_name like '%Dr.% and
  agent_id not in (select related_agent_id from agent_relations where agent_relationship='bad duplicate of')
order by preferred_agent_name
		</cfquery>
		<cfloop query="d">
			preferred_agent_name

		</cfloop>

	</cfif>
</cfoutput>

