<cfquery name="agnt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select agent_name from preferred_agent_name where agent_id=#agent_id#
</cfquery>
<cfdump var=#agnt#>