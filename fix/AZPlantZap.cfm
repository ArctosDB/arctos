<cfoutput >
	<cfquery name="d" datasource="uam_god">
		select taxon_name_id,genus,species,scientific_name from taxonomy where scientific_name like '%A-Z'
	</cfquery>
	<cfloop query="d">
		<br>#scientific_name#
	</cfloop>
	
</cfoutput>