<cfif not isdefined("agent_id")>bad call<cfabort></cfif>

	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from agent_name where  agent_id = '#agent_id#'
	</cfquery>
	<cfset r='<div position="relative">'>
		<cfset r=r & '<span class="docControl" onclick="removeHelpDiv()">X</span>'>
		<cfset r=r & '<div class="docTitle">dictitle</div><div class="docDef">definition</div><div class="docSrchTip">searchhint</div>'>
		<cfif len(d.more_info) gt 0>
				<cfset r=r & '<a class="docMoreInfo" href="/null"'>
					<cfset r=r & 'target="_docMoreWin" onclick="removeHelpDiv()"'>
				<cfset r=r & '>[ More Information ]</div>'>
		</cfif>
	
	<cfset r=r & '</div>'>
	<cfsavecontent variable="response"><cfoutput>#r#</cfoutput></cfsavecontent>
	<cfscript>
        getPageContext().getOut().clearBuffer();
        writeOutput(response);
	</cfscript>
