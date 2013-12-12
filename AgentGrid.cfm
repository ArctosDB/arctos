<cfinclude template="includes/_pickHeader.cfm">
<cfif not isdefined("Action") OR not #action# is "search">
	<!---- waiting for something to search --->
	<cfabort>
</cfif>
<!--- make sure they didn't just hit search (return all agents) --->
<!----
<cfif not (
	len(#First_Name#) gt 0 or
	len(#Last_Name#) gt 0 or
	len(#Middle_Name#) gt 0 or
	len(#Suffix#) gt 0 or
	len(#Prefix#) gt 0 or
	len(#Birth_Date#) gt 0 or
	len(#anyName#) gt 0 or
	len(#agent_id#) gt 0 or
	len(#Death_Date#) gt 0)
>
	<font color="#FF0000"><strong>You must enter search criteria.</strong></font>	
	<cfabort>

</cfif>
---->

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
					and rownum<500
					">
					<!---
					agent_name_type='preferred'
					--->

<cfif isdefined("anyName") AND len(anyName) gt 0>
	<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#ucase(escapeQuotes(anyName))#%'">
</cfif>

<cfif isdefined("agent_id") AND isnumeric(#agent_id#)>
	<cfset sql = "#sql# AND agent.agent_id = #agent_id#">
</cfif>

<cfif isdefined("status_date") AND len(status_date) gt 0>
	<cfset sql = "#sql# AND status_date #status_date_oper# '#status_date#'">
</cfif>		
			
			
<cfif isdefined("address") AND len(#address#) gt 0>
	<cfset sql = "#sql# AND agent_id IN (
			select agent_id from addr where upper(formatted_addr) like '%#ucase(address)#%')">
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
	 <a href="editAllAgent.cfm?agent_id=#agent_id#" 
	 	target="_person">#preferred_agent_name#</a> <font size="-1">(#agent_type#: #agent_id#)</font> 
   <br>
</cfloop>
</div>
</cfoutput>


<cfinclude template="includes/_pickFooter.cfm">