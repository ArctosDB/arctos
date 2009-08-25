<cfoutput>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			preferred_agent_name.agent_name,
			preferred_agent_name.agent_id
		from
			agent_name,
			preferred_agent_name
		where 
			agent_name.agent_id=preferred_agent_name.agent_id and
			upper(agent_name.agent_name) like '#%ucase(q)#%'
		group by
			preferred_agent_name.agent_name,
			preferred_agent_name.agent_id
		order by
			preferred_agent_name.agent_name
	</cfquery>
	<cfloop query="pn">
		#agent_name#|#agent_id##chr(10)#
	</cfloop>
</cfoutput>