<cfif not isdefined("agent_id")>bad call<cfabort></cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			preferred_agent_name,
			agent_name,
			agent_type,
			agent_name_type
		from
			agent,
			agent_name
		where
			agent.agent_id=agent_name.agent_id and
			agent.agent_id = '#agent_id#'
		order by agent_name
	</cfquery>
	<cfquery name="pan" dbtype="query">
		select preferred_agent_name from d group by preferred_agent_name
	</cfquery>
	<cfquery name="agent_relations" datasource="uam_god">
		select AGENT_RELATIONSHIP,agent_name,RELATED_AGENT_ID
		from agent_relations,preferred_agent_name
		where
		agent_relations.RELATED_AGENT_ID=preferred_agent_name.agent_id and
		agent_relations.agent_id=#agent_id#
	</cfquery>
	<cfquery name="r_agent_relations" datasource="uam_god">
		select AGENT_RELATIONSHIP,agent_name,preferred_agent_name.agent_id
		from agent_relations,preferred_agent_name
		where
		agent_relations.agent_id=preferred_agent_name.agent_id and
		RELATED_AGENT_ID=#agent_id#
	</cfquery>
	<cfquery name="group_member" datasource="uam_god">
		select
			agent_name,
			GROUP_AGENT_ID
		from
			group_member, preferred_agent_name
		where
			group_member.GROUP_AGENT_ID=preferred_agent_name.agent_id and
			MEMBER_AGENT_ID=#agent_id#
		order by agent_name
	</cfquery>
	<cfquery name="agent_status" datasource="uam_god">
		select
			AGENT_STATUS,
			STATUS_DATE
		from
			agent_status
		where
			AGENT_ID=#agent_id#
		order by STATUS_DATE
	</cfquery>
	<cfoutput>
		<cfsavecontent variable="response">
			<div position="relative">
				<span class="docControl" onclick="removeHelpDiv()">X</span>
				<div class="docTitle">Names & Relations</div>
				<div class="docDef">
					<div>
						#pan.preferred_agent_name# (#d.agent_type#)
					</div>
					Names
					<ul>
						<cfloop query="d">
							<li>#agent_name# (#agent_name_type#)</li>
						</cfloop>
					</ul>
					<cfif agent_relations.recordcount gt 0 or r_agent_relations.recordcount gt 0>
						Relationships
					</cfif>
					<ul>
						<cfloop query="agent_relations">
							<li>#AGENT_RELATIONSHIP# <a target="_blank" href="/info/agentActivity.cfm?agent_id=#RELATED_AGENT_ID#">#agent_name#</a></li>
						</cfloop>
					</ul>
					<ul>
						<cfloop query="r_agent_relations">
							<li><a target="_blank" href="/info/agentActivity.cfm?agent_id=#agent_id#">#agent_name#</a> is #AGENT_RELATIONSHIP#</li>
						</cfloop>
					</ul>
					<cfif group_member.recordcount gt 0>
						Group Membership
					</cfif>
					<ul>
						<cfloop query="group_member">
							<li><a target="_blank" href="/info/agentActivity.cfm?agent_id=#GROUP_AGENT_ID#">#agent_name#</a></li>
						</cfloop>
					</ul>
					<cfif agent_status.recordcount gt 0>
						Status
					</cfif>
					<ul>
						<cfloop query="agent_status">
							<li>#AGENT_STATUS# (#STATUS_DATE#) </li>
						</cfloop>
					</ul>
				</div>
				<a class="docMoreInfo" target="_blank" href="/info/agentActivity.cfm?agent_id=#agent_id#" onclick="removeHelpDiv();">[ Agent Activity ]</a>
			</div>
		</cfsavecontent>
	</cfoutput>

	<cfscript>
        getPageContext().getOut().clearBuffer();
        writeOutput(response);
	</cfscript>
