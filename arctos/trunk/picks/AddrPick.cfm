<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Agent Pick">
 
 
<!--- build an agent id search --->
<form name="searchForAgent" action="AddrPick.cfm" method="post">
	<br>Agent Name: <input type="text" name="agentname">
	<br><input type="submit" value="Find Matches">
	<input type="hidden" name="search" value="true" class="lnkBtn">
	<cfoutput>
		<input type="hidden" name="addrIdFld" value="#addrIdFld#">
		<input type="hidden" name="addrFld" value="#addrFld#">
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
			SELECT agent_name, preferred_agent_name.agent_id, formatted_addr, addr_id,VALID_ADDR_FG from 
			preferred_agent_name, addr
			 where 
			 preferred_agent_name.agent_id = addr.agent_id (+) AND
			 UPPER(agent_name) LIKE '%#ucase(agentname)#%'				
		</cfquery>
	</cfoutput>
	<cfoutput query="getAgentId">
		
<br>
#agent_name#<br>
<cfif len(#formatted_addr#) gt 0>
<cfset addr = #replace(formatted_addr,"'","`","ALL")#>
<cfset addr = #replace(addr,"#chr(9)#","-","ALL")#>
<cfset addr = #replace(addr,"#chr(10)#","-","ALL")#>
<cfset addr = #replace(addr,"#chr(13)#","-","ALL")#>
<cfset addr=trim(addr)>
<a href="##" onClick="javascript: opener.document.#formName#.#addrFld#.value='#addr#';opener.document.#formName#.#addrIdFld#.value='#addr_id#';self.close();">
	<cfif VALID_ADDR_FG is 0><span class="red">#addr#</span><cfelse>#addr#</cfif></a>
<br>
      <a href="/agents.cfm?agent_id=#agent_id#" target="_blank"><font color="##00FF66">Add 
      address for #agent_name# <font size="-2">(new window)</font></font></a> 
      <cfelse>
      <a href="/agents.cfm?agent_id=#agent_id#" target="_blank"><font color="##00FF66">Add 
      address for #agent_name# <font size="-2">(new window)</font></font></a> 
    </cfif>
<hr>
	</cfoutput>
</cfif>
<cfinclude template="../includes/_pickFooter.cfm">