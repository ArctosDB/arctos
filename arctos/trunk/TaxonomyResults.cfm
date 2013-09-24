<cfoutput>
	<cfif isdefined("full_taxon_name") and len(full_taxon_name) gt 0>
		<cfset furl="/taxonomy.cfm?taxon_name=#full_taxon_name#">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="#furl#">
	<cfelseif isdefined("genus") and len(genus) gt 0>
		<cfset furl="/taxonomy.cfm?taxon_term=#genus#&term_type=genus">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="#furl#">
	<cfelse>
		<cfthrow 
		    detail = "TaxonomyResults problem"
		    errorCode = "90000"
		    extendedInfo = "soft 404: The page has moved and our redirects are broken. We're fixing it!"
		    message = "The page has moved and our redirects are broken. We're fixing it!"
		   >
	</cfif>
	
	
		   
		   
		   
		   
	
</cfoutput>