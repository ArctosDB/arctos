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
	<cfif len(agentname) is 0>
		You must enter search criteria.
		<cfabort>
	</cfif>
	<cfoutput>
		<cfquery name="getAgentId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT 
				preferred_agent_name agent_name, 
				agent.agent_id, 
				regexp_replace(address,'[^[:print:]]','-') jsaddr,
				regexp_replace(address,'[^[:print:]]','<br>') htmladdr,
				address_type,
				address_id,
				VALID_ADDR_FG 
			from 
				agent,
				agent_name, 
				address
			 where 
			 	agent.agent_id=agent_name.agent_id (+) and
			 	agent.agent_id=address.agent_id (+) AND
			 UPPER(agent_name.agent_name) LIKE '%#ucase(agentname)#%'				
		</cfquery>
	</cfoutput>
	<cfquery name="da" dbtype="query">
		select agent_name,agent_id from getAgentId group by agent_name,agent_id  order by agent_name
	</cfquery>
	<cfoutput>
		<cfloop query="da">
			<div style="border:1px solid black;margin:1em;">
				#agent_name# (<a href="/agents.cfm?agent_id=#agent_id#" target="_blank">#agent_id#: edit/add address</a>)
				<cfquery name="addrs" dbtype="query">
					select * from getAgentId where jsaddr is not null and agent_id=#agent_id# order by VALID_ADDR_FG desc, address_type, address
				</cfquery>
				<cfloop query="addrs">
					<cfif VALID_ADDR_FG is 0>
						<cfset bclr="red">
					<cfelse>
						<cfset bclr="green">
					</cfif>
					<div style="margin:1em;border:1px solid #bclr#">
						Address Type: #address_type#
						<p style="margin:1em">
							#htmladdr#
							<br><span class="likeLink" onclick="opener.document.#formName#.#addrFld#.value='#jsaddr#';opener.document.#formName#.#addrIdFld#.value='#address_id#';self.close();">use this address</span>
						</p>
						<br>
					</div>
				</cfloop>
			</div>
		</cfloop>
	</cfoutput>
	
	<!----
	<cfoutput query="getAgentId">	
<br>
<br>
<cfif len(address) gt 0>

<a href="##" onClick="javascript: ">
	<cfif VALID_ADDR_FG is 0><span class="red">#address#</span><cfelse>#address#</cfif></a>
<br>
      <a href="/agents.cfm?agent_id=#agent_id#" target="_blank"><font color="##00FF66">Add 
      address for #agent_name# <font size="-2">(new window)</font></font></a> 
      <cfelse>
      <a href="/agents.cfm?agent_id=#agent_id#" target="_blank"><font color="##00FF66">Add 
      address for #agent_name# <font size="-2">(new window)</font></font></a> 
    </cfif>
<hr>
	</cfoutput>
	---->
</cfif>
<cfinclude template="../includes/_pickFooter.cfm">