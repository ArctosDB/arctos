<cfoutput>
	<cfquery name="pn" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			accn_number
		from
			accn,trans
		where
			accn.transaction_id=trans.transaction_id and
			collection_id=21 and
			upper(accn_number) like '%#ucase(q)#%'
		order by 
			accn_number
	</cfquery>
	<cfloop query="pn">
		#accn_number# #chr(10)#
	</cfloop>
</cfoutput>