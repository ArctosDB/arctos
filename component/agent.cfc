<cfcomponent>
<cffunction name="saveAgentxxx" access="remote">
	<cftry>
	<cfquery name="n" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select sq_agent_name_id.nextval n from dual
	</cfquery>

	<cfquery name="updateName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO agent_name (
			agent_name_id, agent_id, agent_name_type, agent_name)
		VALUES (
			#n.n#, #agent_id#, '#agent_name_type#','#agent_name#')
	</cfquery>
		<cfset d = querynew("status,agent_name_id,agent_name_type,agent_name")>
		<cfset temp = queryaddrow(d,1)>
		<cfset temp = QuerySetCell(d, "status", "success",1)>
		<cfset temp = QuerySetCell(d, "agent_name_id", n.n,1)>
		<cfset temp = QuerySetCell(d, "agent_name_type", agent_name_type,1)>
		<cfset temp = QuerySetCell(d, "agent_name", agent_name,1)>
		<cfreturn d>
	<cfcatch>
		<cfset d = querynew("status")>
		<cfset temp = queryaddrow(d,1)>
		<cfset temp = QuerySetCell(d, "status", cfcatch.message & ': ' & cfcatch.detail,1)>
		<cfreturn d>
	</cfcatch>
	</cftry>
</cffunction>


<cffunction name="saveAgent" access="remote">
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>
	
	<cfoutput>
	<cfloop list="#structKeyList(url)#" index="key">
				<br>Key: #key#, Value: #url[key]#
				<cfif left(key,11) is "agent_name_">
					<cfset thisAgentNameID=listlast(key,"_")>
					<br>thisAgentNameID: #thisAgentNameID#
					<cfset thisAgentNameType=url["agent_name_type_#thisAgentNameID#"]>
					<br>thisAgentNameType: #thisAgentNameType#
					<cfset thisAgentName=url[key]>
					<br>thisAgentName: #thisAgentName#
				</cfif>
				
			</cfloop>


</cfoutput>

<cfabort>
	<cftry>
	
	

agent_name_type_10740831=aka&agent_name_10740831=D.+L.+McDonald&agent_name_type_10854068=aka&agent_name_10854068=Dusty+Lee+McDonald&agent_name_type_1021885=aka&agent_name_1021885=Dusty+MacDonald&agent_name_type_10737985=aka&agent_name_10737985=Dusty+McDonald&agent_name_type_10756423=first+name&agent_name_10756423=Dusty&agent_name_type_10812638=last+name&agent_name_10812638=McDonald&agent_name_type_4551=login&agent_name_4551=dlm&agent_name_type_10944645=login&agent_name_10944645=uam&agent_name_type_10794137=middle+name&agent_name_10794137=Lee&agent_name_type_new1=&agent_name_new1=&agent_status_28=born&status_date_28=1973-11-02&status_remark=&new_agent_status1=&new_status_date1=2014-09-10&new_status_remark1=&agent_relationship_new1=&related_agent_id_new1=&related_agent_new1=
		<cftransaction>
			<cfquery name="updateAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE agent SET 
					agent_remarks = '#escapeQuotes(agent_remarks)#',
					agent_type='#agent_type#',
					preferred_agent_name='#escapeQuotes(preferred_agent_name)#'
				WHERE
					agent_id = #agent_id#
			</cfquery>
			

		</cftransaction>
	<cfreturn "success">
	<cfcatch>
		<cfreturn cfcatch.message & ': ' & cfcatch.detail>
	</cfcatch>
	</cftry>
</cffunction>
<!------------------------------------->

<cffunction name="findAgents" access="remote">
	<cfoutput>
	
	<cfif not isdefined("escapeQuotes")>
		<cfinclude template="/includes/functionLib.cfm">
	</cfif>
	
	
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
		<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#trim(ucase(escapeQuotes(anyName)))#%'">
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
	<cfreturn getAgents>
	<!----
	<cfif getAgents.recordcount is 0>
	    <span class="error">Nothing Matched.</span>
	</cfif>
	<div style="height:20em; overflow:auto;">
		<cfloop query="getAgents">
			<div class="likeLink" onclick="loadEditAgent('#agent_id#');">
				#preferred_agent_name# <font size="-1">(#agent_type#: #agent_id#)</font> 
		   </div>
		</cfloop>
	</div>
	---->
</cfoutput>
</cffunction>

</cfcomponent>