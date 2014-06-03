<cfinclude template="includes/_pickHeader.cfm">
<cfif not isdefined("Action") OR not action is "search">
	<cfabort>
</cfif>
<cfoutput>
	<cfset sql = "SELECT 
					agent.agent_id,
					agent.preferred_agent_name,
					agent.agent_type
				FROM 
					agent,
					agent_name,
					agent_status
				WHERE 
					agent.agent_id=agent_name.agent_id (+) and
					agent.agent_id=agent_status.agent_id (+) and
					agent.agent_id > -1
					">
					

	<cfif isdefined("anyName") AND len(anyName) gt 0>
		<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#ucase(escapeQuotes(anyName))#%'">
	</cfif>
	<cfif isdefined("agent_id") AND isnumeric(#agent_id#)>
		<cfset sql = "#sql# AND agent.agent_id = #agent_id#">
	</cfif>
	<cfif isdefined("status_date") AND len(status_date) gt 0>
		<cfset sql = "#sql# AND status_date #status_date_oper# '#status_date#'">
	</cfif>
	<cfif isdefined("agent_status") AND len(agent_status) gt 0>
		<cfset sql = "#sql# AND agent_status='#agent_status#'">
	</cfif>			
	<cfif isdefined("address") AND len(#address#) gt 0>
		<cfset sql = "#sql# AND agent.agent_id IN (select agent_id from addr where upper(formatted_addr) like '%#ucase(address)#%')">
	</cfif>
	<cfif isdefined("agent_name_type") AND len(agent_name_type) gt 0>
		<cfset sql = "#sql# AND agent_name_type='#agent_name_type#'">
	</cfif>
	<cfif isdefined("agent_type") AND len(agent_type) gt 0>
		<cfset sql = "#sql# AND agent.agent_type='#agent_type#'">
	</cfif>
	<cfif isdefined("agent_name") AND len(agent_name) gt 0>
		<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#ucase(escapeQuotes(agent_name))#%'">
	</cfif>
	<cfif isdefined("created_by") AND len(created_by) gt 0>
		<cfset sql = "#sql# AND agent.created_by_agent_id in (select agent_id from agent_name where upper(agent_name.agent_name) like '%#ucase(escapeQuotes(created_by))#%')">
	</cfif>
	
	<cfif isdefined("created_date") AND len(created_date) gt 0>
		<cfif len(created_date) is 4>
			<cfset filter='YYYY'>
		<cfelseif len(created_date) is 7>
			<cfset filter='YYYY-MM'>
		<cfelseif len(created_date) is 10>
			<cfset filter='YYYY-MM-DD'>
		<cfelse>
			Search created date as YYYY, YYYY-MM, YYYY-MM-DD
			<cfabort>
		</cfif>
		<cfset sql = "#sql# AND to_char(CREATED_DATE,'#filter#') #create_date_oper# '#created_date#'">
	</cfif>
	<cfset sql = "#sql# GROUP BY  agent.agent_id,
						agent.preferred_agent_name,
						agent.agent_type">
	<cfset sql = "#sql# ORDER BY agent.preferred_agent_name">

	<cfquery name="getAgents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfif getAgents.recordcount is 0>
	    <span class="error">Nothing Matched.</span>
	</cfif>
	<div style="height:20em; overflow:auto;">
		<cfloop query="getAgents">
			<div>
			 <a href="editAllAgent.cfm?agent_id=#agent_id#" target="_person">#preferred_agent_name#</a> <font size="-1">(#agent_type#: #agent_id#)</font> 
		   </div>
		</cfloop>
	</div>
</cfoutput>
<cfinclude template="includes/_pickFooter.cfm">