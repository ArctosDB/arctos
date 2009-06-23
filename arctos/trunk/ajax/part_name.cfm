<cfoutput>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			part_name
		from
			ctspecimen_part_name
		where 
			upper(part_name) like '#ucase(q)#%'
		group by
			part_name
		order by
			part_name
	</cfquery>
	<cfloop query="pn">
		#part_name# #chr(10)#
	</cfloop>
</cfoutput>