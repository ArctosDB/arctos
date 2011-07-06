<cfoutput>
	<cfif not isdefined("limit") or not isnumeric(limit)>
		<cfset limit=100>
	</cfif>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select * from (
			select
				scientific_name
			from
				taxonomy
			where 
				upper(scientific_name) like '%#ucase(q)#%'
			order by
				scientific_name
		) 
		where rownum <= #limit#
	</cfquery>
	<cfloop query="pn">
		#scientific_name##chr(10)#
	</cfloop>
</cfoutput>
