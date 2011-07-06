<cfoutput>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			part_name
		from 
			cctspecimen_part_name21
		where
			upper(part_name) like '%#ucase(q)#%'
		group by part_name
		order by part_name
	</cfquery>
	<cfloop query="pn">
		#part_name##chr(10)#
	</cfloop>
</cfoutput>