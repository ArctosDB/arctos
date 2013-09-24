<cfoutput>
	<cfif isdefined("taxon_name_id") and len(taxon_name_id) gt 0>
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="/taxonomy.cfm?taxon_name_id=#taxon_name_id#">
	
	<cfelse>
		<cfthrow 
		    detail = "TaxonomyDetails problem"
		    errorCode = "90000"
		    extendedInfo = "soft 404: The page has moved and our redirects are broken. We're fixing it!"
		    message = "The page has moved and our redirects are broken. We're fixing it!"
		   >
	
	</cfif>

</cfoutput>