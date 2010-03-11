<cfcomponent>
<cffunction name="getAllAgentNames" access="remote">
	<cfreturn "bob, jim, jojo">
</cffunction>
<cffunction name="findAgentMatch" access="remote">
	<cfargument name="key" type="numeric" required="yes">	
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from ds_temp_agent where key=#key#
	</cfquery>
	<cfquery name="eName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
	        first_name,
	        middle_name,
	        last_name,
	        birth_date,
	        death_date,
	        suffix,
	        preferred_agent_name.agent_id, 
	        preferred_agent_name.agent_name,
	        '#getAllAgentNames#' names
		from 
	        person,
	        agent_name srch,
	        preferred_agent_name
		where 
	        person.person_id=srch.agent_id and
	        person.person_id=preferred_agent_name.agent_id and
	        srch.agent_name in ('#d.preferred_name#','#d.other_name_1#','#d.other_name_2#','#d.other_name_3#')
	</cfquery>
	<cfreturn eName>
</cffunction>
</cfcomponent>