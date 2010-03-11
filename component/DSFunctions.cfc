<cfcomponent>
<cffunction name="getAllAgentNames" access="remote">
	<cfargument name="agent_id" type="any" required="yes">
	<cfif isnumeric(agent_id) and len(agent_id) gt 0>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_name from agent_name where agent_id=#agent_id# order by agent_name
		</cfquery>
		<cfreturn valuelist(d.agent_name,';')>
	<cfelse>
		<cfreturn "">
	</cfif>
</cffunction>
<cffunction name="findAgentMatch" access="remote">
	<cfargument name="key" type="numeric" required="yes">	
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from ds_temp_agent where key=#key#
	</cfquery>
	<cfquery name="n" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
	        'the key is #d.key#' key,
	        first_name,
	        middle_name,
	        last_name,
	        birth_date,
	        death_date,
	        suffix,
	        preferred_agent_name.agent_id, 
	        preferred_agent_name.agent_name preferred_agent_name
		from 
	        person,
	        agent_name srch,
	        preferred_agent_name
		where 
	        person.person_id=srch.agent_id and
	        person.person_id=preferred_agent_name.agent_id and
	        srch.agent_name in ('#d.preferred_name#','#d.other_name_1#','#d.other_name_2#','#d.other_name_3#')
	    group by
	    	first_name,
	        middle_name,
	        last_name,
	        birth_date,
	        death_date,
	        suffix,
	        preferred_agent_name.agent_id, 
	        preferred_agent_name.agent_name
	</cfquery>
	<cfset result = querynew("key,first_name,middle_name,last_name,birth_date,death_date,suffix,agent_id,preferred_agent_name,othernames")>
	<cfset i=1>
	<cfloop query="n">
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "key", n.key, i)>
		<cfset temp = QuerySetCell(result, "first_name", n.first_name, i)>
		<cfset temp = QuerySetCell(result, "middle_name", n.middle_name, i)>
		<cfset temp = QuerySetCell(result, "last_name", n.last_name, i)>
		<cfset temp = QuerySetCell(result, "birth_date", n.birth_date, i)>
		<cfset temp = QuerySetCell(result, "death_date", n.death_date, i)>
		<cfset temp = QuerySetCell(result, "suffix", n.suffix, i)>
		<cfset temp = QuerySetCell(result, "agent_id", n.agent_id, i)>
		<cfset temp = QuerySetCell(result, "preferred_agent_name", n.preferred_agent_name, i)>
		<cfset temp = QuerySetCell(result, "othernames", getAllAgentNames(n.agent_id), i)>
		<cfset i=i+1>
	</cfloop>
	<cfreturn result>
</cffunction>
</cfcomponent>