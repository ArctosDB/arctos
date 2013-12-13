<cfif not isdefined("agent_id")>bad call<cfabort></cfif>

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			preferred_agent_name,
			agent_name,
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
	
	<cfoutput>
	<cfsavecontent variable="x">
		Names
		<ul>
			<cfloop query="d">
				<li>#agent_name# (#agent_name_type#)</li>
			</cfloop>
		</ul>
		
		Agent Relationships:
		
			<ul>
		<cfloop query="agent_relations">
			<li>#AGENT_RELATIONSHIP# <a href="agentActivity.cfm?agent_id=#RELATED_AGENT_ID#">#agent_name#</a></li>
		</cfloop>
	</ul>
	
	<ul>
		<cfloop query="r_agent_relations">
			<li><a href="agentActivity.cfm?agent_id=#agent_id#">#agent_name#</a> is #AGENT_RELATIONSHIP#</li>
		</cfloop>
	</ul>
	
	Groups:	
	
	<ul>
		<cfloop query="group_member">
			<li><a href="agentActivity.cfm?agent_id=#GROUP_AGENT_ID#">#agent_name#</a></li>
		</cfloop>
	</ul>		
	
	</cfsavecontent>
	
	</cfoutput>
	
	
	
	<cfset r='<div position="relative">'>
		<cfset r=r & '<span class="docControl" onclick="removeHelpDiv()">X</span>'>
		<cfset r=r & '<div class="docTitle">#pan.preferred_agent_name#</div><div class="docDef">'>
		<cfset r=r & '#x#'>
		<cfloop query="d">
			<cfset r=r & '<div>#agent_name# (#agent_name_type#)</div>'>
		</cfloop>
		
		<cfset r=r & '</div>'>
				<cfset r=r & '<a class="docMoreInfo" href="/info/agentActivity.cfm?agent_id=#agent_id#"'>
					<cfset r=r & 'target="_docMoreWin" onclick="removeHelpDiv()"'>
				<cfset r=r & '>[ Agent Activity ]</div>'>
	
	<cfset r=r & '</div>'>
	<cfsavecontent variable="response"><cfoutput>#r#</cfoutput></cfsavecontent>
	<cfscript>
        getPageContext().getOut().clearBuffer();
        writeOutput(response);
	</cfscript>
