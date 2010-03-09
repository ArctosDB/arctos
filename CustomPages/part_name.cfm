<cfoutput>
	<cfquery name="pn" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			part_name
		from
			pt_ctspecimen_part_name
		where 
			upper(part_name) like '%#ucase(q)#%'
		group by
			part_name
		order by
			part_name
	</cfquery>
	<cfloop query="pn">
		#part_name# #chr(10)#
	</cfloop>
</cfoutput>