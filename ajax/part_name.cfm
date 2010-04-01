<cfoutput>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select a.part_name
		from (
		        select part_name, partname
		        from ctspecimen_part_name, ctspecimen_part_list_order
		        where ctspecimen_part_name.part_name =  ctspecimen_part_list_order.partname (+)
		        and upper(part_name) like '#ucase(q)#%'
		) a
		group by a.part_name, a.partname
		order by a.partname asc, a.part_name
	</cfquery>
	<cfloop query="pn">
		#part_name# #chr(10)#
	</cfloop>
</cfoutput>