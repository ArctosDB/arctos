<cfoutput>
		<cfquery name="pn" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select accn_number
			from accn,tran
			where accn.transaction_id=tran.transaction_id and
			collection_id=21
			order by accn_number
		</cfquery>
	</cfif>	
	<cfloop query="pn">
		#accn_number# #chr(10)#
	</cfloop>
</cfoutput>