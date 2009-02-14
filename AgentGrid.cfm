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
					preferred_agent_name.agent_id,
					preferred_agent_name.agent_name,
					agent_type
				FROM 
					agent_name
					left outer join preferred_agent_name ON (agent_name.agent_id = preferred_agent_name.agent_id)
					LEFT OUTER JOIN agent ON (agent_name.agent_id = agent.agent_id)
					LEFT OUTER JOIN person ON (agent.agent_id = person.person_id)
				WHERE 
					agent.agent_id > -1
					and rownum<500 -- some throttle control
					">
					<!---
					agent_name_type='preferred'
					--->
<cfif isdefined("First_Name") AND len(#First_Name#) gt 0>
	<cfset sql = "#sql# AND first_name LIKE '#First_Name#'">
</cfif>
<cfif isdefined("Last_Name") AND len(#Last_Name#) gt 0>
	<cfset lastname = #replace(last_name,"'","''")#>
	<cfset sql = "#sql# AND Last_Name LIKE '#lastname#'">
</cfif>

<cfif isdefined("Middle_Name") AND len(#Middle_Name#) gt 0>
	<cfset sql = "#sql# AND Middle_Name LIKE '#Middle_Name#'">
</cfif>
<cfif isdefined("Suffix") AND len(#Suffix#) gt 0>
	<cfset sql = "#sql# AND Suffix = '#Suffix#'">
</cfif>
<cfif isdefined("Prefix") AND len(#Prefix#) gt 0>
	<cfset sql = "#sql# AND Prefix = '#Prefix#'">
</cfif>
<cfif isdefined("Birth_Date") AND len(#Birth_Date#) gt 0>
	<cfset bdate = #dateformat(birth_date,'dd-mmm-yyyy')#>
	<cfset sql = "#sql# AND Birth_Date #birthOper# '#bdate#'">
</cfif>
<cfif isdefined("Death_Date") AND len(#Death_Date#) gt 0>
	<cfset ddate = #dateformat(Death_Date,'dd-mmm-yyyy')#>
	<cfset sql = "#sql# AND Death_Date #deathOper# '#ddate#'">
</cfif>
<cfif isdefined("anyName") AND len(#anyName#) gt 0>
	<cfset aName = replace(anyName,"'","''","all")>
	<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#ucase(aName)#%'">
</cfif>
<cfif isdefined("agent_id") AND isnumeric(#agent_id#)>
	<cfset sql = "#sql# AND agent_name.agent_id = #agent_id#">
</cfif>
<cfif isdefined("address") AND len(#address#) gt 0>
	<cfset sql = "#sql# AND agent_id IN (
			select agent_id from addr where upper(formatted_addr) like '%#ucase(address)#%')">
</cfif>

<cfset sql = "#sql# GROUP BY  preferred_agent_name.agent_id,
					preferred_agent_name.agent_name,
					agent_type">
<cfset sql = "#sql# ORDER BY preferred_agent_name.agent_name">
		<cfquery name="getAgents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>
<cfif getAgents.recordcount is 0>
    <span class="error">Nothing Matched.</span>
</cfif>
<cfloop query="getAgents">
	 <a href="editAllAgent.cfm?agent_id=#agent_id#" 
	 	target="_person">#agent_name#</a> <font size="-1">(#agent_type#: #agent_id#)</font> 
   <br>
</cfloop>
</cfoutput>


<cfinclude template="includes/_pickFooter.cfm">