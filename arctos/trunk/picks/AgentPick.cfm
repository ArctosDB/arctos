<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Agent Pick">
<!--- build an agent id search --->
<form name="searchForAgent" action="AgentPick.cfm" method="post">
	<br>Agent Name: <input type="text" name="agentname">
	<br><input type="submit" value="Find Matches">
	<input type="hidden" name="search" value="true">
	<cfoutput>
		<input type="hidden" name="agentIdFld" value="#agentIdFld#">
		<input type="hidden" name="agentNameFld" value="#agentNameFld#">
		<input type="hidden" name="formName" value="#formName#">
	</cfoutput>
</form>
<cfif isdefined("search") and #search# is "true">
	<!--- make sure we're searching for something --->
	<cfif len(#agentname#) is 0>
		You must enter search criteria.
		<cfabort>
	</cfif>
	<cfoutput>
		<cfquery name="getAgentId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT agent_name, agent_id from agent_name where
				UPPER(agent_name) LIKE '%#ucase(agentname)#%'
				AND agent_name_type = 'preferred'
		</cfquery>
	</cfoutput>
	<cfoutput query="getAgentId">
		
<br>
<cfset thisName = #replace(agent_name,"'","`","all")#>
<a href="##" onClick="javascript: opener.document.#formName#.#agentIdFld#.value='#agent_id#';opener.document.#formName#.#agentNameFld#.value='#thisName#';self.close();">#agent_name# (#agent_id#)</a>
	</cfoutput>
</cfif>
<cfinclude template="../includes/_pickFooter.cfm">