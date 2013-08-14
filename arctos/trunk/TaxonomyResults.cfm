<cfoutput>
	<cfif isdefined("full_taxon_name") and len(full_taxon_name) gt 0>
		<cfset furl="/taxonomy.cfm?taxon_name=#full_taxon_name#">
	<cfelseif isdefined("genus") and len(genus) gt 0>
		<cfset furl="/taxonomy.cfm?taxon_term=#genus#&term_type=genus">
	<cfelse>
		<cfset furl="/taxonomy.cfm">
	</cfif>
	
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="#furl#">

</cfoutput>
