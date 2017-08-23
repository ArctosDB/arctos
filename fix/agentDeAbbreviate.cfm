<cfinclude template="/includes/_header.cfm">
<cfoutput>
agentDeAbbreviate.cfm
		<cfquery name="d" datasource="uam_god">
			select
				agent_id,
				preferred_agent_name from agent where
			agent_type='person' and preferred_agent_name like '%Dr.%' and
			  agent_id not in (select agent_id from agent_relations union select related_agent_id from agent_relations )
			order by preferred_agent_name
		</cfquery>
		<cfloop query="d">
			<hr>
			#preferred_agent_name#
			<cfset shouldFindName=replace(d.preferred_agent_name,'Dr. ','','all')>
			<br>#shouldFindName#
			<cfquery name="hg"  datasource="uam_god">
				select * from agent_name where agent_name='#shouldFindName#' and agent_name_type not in
					('last name')
			</cfquery>

			<cfif hg.recordcount gte 1>
				<cfdump var=#hg#>
			</cfif>

		</cfloop>

</cfoutput>

