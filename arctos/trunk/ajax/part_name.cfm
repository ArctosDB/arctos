<cfoutput>
	<cfquery name="pn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select part_name from (select
			part_name
		from
			ctspecimen_part_name,
		    ctspecimen_part_list_order
		where 
			ctspecimen_part_name.part_name =  ctspecimen_part_list_order.partname (+) and
			upper(part_name) like '#ucase(q)#%'
		order by
			partname,part_name
			)
			group by
			part_name
	</cfquery>
	<cfloop query="pn">
		#part_name# #chr(10)#
	</cfloop>
</cfoutput>