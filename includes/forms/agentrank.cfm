<cfquery name="agnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select agent_name from preferred_agent_name where agent_id=#agent_id#
</cfquery>
<cfquery name="pr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from agent_rank where agent_id=#agent_id#
</cfquery>
Agent #agnt.agent_name# has been ranked #pr.recordcount# times.
<cfdump var=#agnt#>
<cfdump var=#pr#>