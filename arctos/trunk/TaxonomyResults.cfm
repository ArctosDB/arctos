<cfoutput>
	<cfif isdefined("full_taxon_name") and len(full_taxon_name) gt 0>
		<br>going to /taxonomy.cfm?taxon_name=#full_taxon_name#
	<cfelse>
		<br>you lost
	</cfif>
</cfoutput>

