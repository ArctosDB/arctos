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
		<cfset furl="/taxonomy.cfm">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="#furl#">
	</cfif>
</cfoutput>