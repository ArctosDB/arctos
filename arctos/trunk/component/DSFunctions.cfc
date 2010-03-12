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


<cffunction name="loadAgent" access="remote">
	<cfargument name="key" type="numeric" required="yes">
	<cfargument name="agent_id" type="any" required="yes">
	<cfif len(agent_id) is 0>
		<cfset rl="#key#,FAIL,No agent was selected">
	<cfelseif isnumeric(agent_id) and agent_id gt 0>
		<cfset rl="#key#,PASS,agent updated">
	<cfelseif agent_id is -1>
		<cfset rl="#key#,PASS,agent created">
	<cfelse>
		
		<cfset rl="#key#,unknown error">
	</cfif>
	<cfset result=serializejson(rl,1)>
	<cfreturn rl>
</cffunction>


<cffunction name="findAgentMatch" access="remote">
	<cfargument name="key" type="numeric" required="yes">	
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select first_name,middle_name,last_name,preferred_name,other_name_1,other_name_2,other_name_3 
		from ds_temp_agent where key=#key#
	</cfquery>
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
	        #KEY# key,
	        preferred_agent_name.agent_id, 
	        preferred_agent_name.agent_name preferred_agent_name
		from 
	        agent_name srch,
	        preferred_agent_name
		where 
	        srch.agent_id=preferred_agent_name.agent_id and
	        srch.agent_name in (
	        	trim('#d.preferred_name#'),
	        	trim('#d.other_name_1#'),
	        	trim('#d.other_name_2#'),
	        	trim('#d.other_name_3#')
	        )
	    group by
	    	preferred_agent_name.agent_id, 
	        preferred_agent_name.agent_name,
	        #key#
	    union
	    select
	    	#KEY# key,
	        preferred_agent_name.agent_id, 
	        preferred_agent_name.agent_name preferred_agent_name
		from
			person,
			preferred_agent_name
		where
			person.person_id=preferred_agent_name.agent_id and
			upper(first_name) = trim(upper('#d.first_name#')) and
			upper(last_name) = trim(upper('#d.last_name#'))			
	</cfquery>
	<cfreturn result>
</cffunction>
<cffunction name="findAgentMatchOld" access="remote">
	<cfargument name="key" type="numeric" required="yes">	
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from ds_temp_agent where key=#key#
	</cfquery>
	<cfquery name="n" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
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
	<cfset result = querynew("key,first_name,middle_name,last_name,birth_date,death_date,suffix,agent_id,
			preferred_agent_name,othernames,n_agent_type,n_preferred_name,n_first_name,n_middle_name,n_last_name,n_birth_date,n_death_date,
			n_prefix,n_suffix,n_other_name_1,n_other_name_type_1,n_other_name_2,n_other_name_type_2,n_other_name_3,
			n_other_name_type_3")>
	
	
	
	<cfset i=1>
	<cfloop query="n">
		<cfset temp = queryaddrow(result,1)>
		<cfset temp = QuerySetCell(result, "key", key, i)>
		<cfset temp = QuerySetCell(result, "first_name", n.first_name, i)>
		<cfset temp = QuerySetCell(result, "middle_name", n.middle_name, i)>
		<cfset temp = QuerySetCell(result, "last_name", n.last_name, i)>
		<cfset temp = QuerySetCell(result, "birth_date", n.birth_date, i)>
		<cfset temp = QuerySetCell(result, "death_date", n.death_date, i)>
		<cfset temp = QuerySetCell(result, "suffix", n.suffix, i)>
		<cfset temp = QuerySetCell(result, "agent_id", n.agent_id, i)>
		<cfset temp = QuerySetCell(result, "preferred_agent_name", n.preferred_agent_name, i)>
		<cfset temp = QuerySetCell(result, "n_agent_type", d.n_agent_type, i)>
		<cfset temp = QuerySetCell(result, "n_preferred_name", d.n_preferred_name, i)>
		<cfset temp = QuerySetCell(result, "n_first_name", d.n_first_name, i)>
		<cfset temp = QuerySetCell(result, "n_middle_name", d.n_middle_name, i)>
		<cfset temp = QuerySetCell(result, "n_last_name", d.n_last_name, i)>
		<cfset temp = QuerySetCell(result, "n_birth_date", d.n_birth_date, i)>
		<cfset temp = QuerySetCell(result, "n_death_date", d.n_death_date, i)>
		<cfset temp = QuerySetCell(result, "n_prefix", d.n_prefix, i)>
		<cfset temp = QuerySetCell(result, "n_suffix", d.n_suffix, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_1", d.n_other_name_1, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_type_1", d.n_other_name_type_1, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_2", d.n_other_name_2, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_type_2", d.n_other_name_type_2, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_3", d.n_other_name_3, i)>
		<cfset temp = QuerySetCell(result, "n_other_name_type_3", d.n_other_name_type_3, i)>
		<cfset i=i+1>
	</cfloop>
	<cfreturn result>
</cffunction>
</cfcomponent>