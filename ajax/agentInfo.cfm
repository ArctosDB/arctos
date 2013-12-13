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
	<cfset r='<div position="relative">'>
		<cfset r=r & '<span class="docControl" onclick="removeHelpDiv()">X</span>'>
		<cfset r=r & '<div class="docTitle">#pan.preferred_agent_name#</div><div class="docDef">'>
		<cfset r=r & 'Names'>
		<cfloop query="d">
			<cfset r=r & '<div>#agent_name# (#agent_name_type#)</div>'>
		</cfloop>
		
		<cfset r=r & '</div>'>
				<cfset r=r & '<a class="docMoreInfo" href="/null"'>
					<cfset r=r & 'target="_docMoreWin" onclick="removeHelpDiv()"'>
				<cfset r=r & '>[ Agent Activity ]</div>'>
	
	<cfset r=r & '</div>'>
	<cfsavecontent variable="response"><cfoutput>#r#</cfoutput></cfsavecontent>
	<cfscript>
        getPageContext().getOut().clearBuffer();
        writeOutput(response);
	</cfscript>
