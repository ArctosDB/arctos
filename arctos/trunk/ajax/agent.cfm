<cfoutput>
	<cfif not isdefined("limit") or not isnumeric(limit)>
		<cfset limit=20>
	</cfif>
	<!---- cachedwithin="#createtimespan(0,0,60,0)#"---->
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from (
			select
				preferred_agent_name.agent_name,
				preferred_agent_name.agent_id
			from
				agent_name,
				preferred_agent_name
			where 
				agent_name.agent_id=preferred_agent_name.agent_id and
				upper(agent_name.agent_name) like '%#ucase(q)#%'
			group by
				preferred_agent_name.agent_name,
				preferred_agent_name.agent_id
			order by
				preferred_agent_name.agent_name
		) 
		where rownum <= #limit#
	</cfquery>
	<cfdump var=#pn#>
	<cfloop query="pn">
		#agent_name#|#agent_id##chr(10)#
	</cfloop>
</cfoutput>