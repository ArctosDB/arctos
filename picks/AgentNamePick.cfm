<cfinclude template="../includes/_pickHeader.cfm">

<body bgcolor="#FFFBF0" text="midnightblue" link="blue" vlink="midnightblue">
 
 <!---<SCRIPT LANGUAGE=JAVASCRIPT><!--


    function setForm() {
    opener.document.f1.f1.value = document.selectedAgent.agentID.value;
    opener.document.f1.f2.value = document.selectedAgent.agentName.value;
    self.close();
    return false;
}

//--></SCRIPT>--->
<!---<FORM NAME="inputForm1" onSubmit="return setForm();">
<BR><INPUT NAME="inputField1" TYPE="TEXT" VALUE="">
<BR><INPUT NAME="inputField2" TYPE="TEXT" VALUE="">
<BR><INPUT TYPE="SUBMIT" VALUE="Update opener">
</FORM> --->


<!--- create a small application that can be called as a pop-up window used to select agent_id --->

<!--- build an agent id search --->
<form name="searchForAgent" action="AgentNamePick.cfm" method="post">
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
			SELECT agent_id from agent_name where
				UPPER(agent_name) LIKE '%#ucase(agentname)#%'
				AND agent_name_type = 'preferred'
		</cfquery>
		<cfquery name="names" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT agent_name, agent_name_id from agent_name where 
			agent_id = #getAgentId.agent_id#
		</cfquery>
	
	<cfloop query="getAgentId">
		<cfquery name="names" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT agent_name, agent_name_id from agent_name where 
			agent_id = #getAgentId.agent_id#
		</cfquery>
			<cfloop query="names">
			<cfset thisName = #replace(names.agent_name,"'","`","all")#>
			<br><a href="##" onClick="javascript: opener.document.#formName#.#agentIdFld#.value='#names.agent_name_id#';opener.document.#formName#.#agentNameFld#.value='#thisName#';self.close();">#names.agent_name# (#names.agent_name_id#)</a>
			</cfloop>
		</cfloop>
	</cfoutput>
</cfif>
<cfinclude template="../includes/_pickFooter.cfm">