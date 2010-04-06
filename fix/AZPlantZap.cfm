<cfoutput >
	<cfquery name="d" datasource="uam_god">
		select taxon_name_id,genus,species,scientific_name from taxonomy where scientific_name like '%A-Z'
	</cfquery>
	<cfloop query="d">
		<hr>
		<br>#scientific_name#
		<cfquery name="id" datasource="uam_god">
			select identification_id from identification_taxonomy where taxon_name_id=#taxon_name_id#
		</cfquery>
		<cfquery name="gen" datasource="uam_god">
			select taxon_name_id,scientific_name from taxonomy where scientific_name='#genus#'
		</cfquery>
		<br>replacewith: #gen.scientific_name#
		<cfloop query="id">
			update identification_taxonomy set taxon_name_id=#gen.taxon_name_id# where identification_id=#id.identification_id#
			<br>
			update identification set TAXA_FORMULA='A sp.',
			scientific_name='#gen.scientific_name# sp.'
			IDENTIFICATION_REMARKS=decode(IDENTIFICATION_REMARKS,
			null,'Originally entered as ' || scientific_name,
			IDENTIFICATION_REMARKS || '; Originally entered as ' || scientific_name
			where identification_id=#id.identification_id#
		</cfloop>
	</cfloop>
	
</cfoutput>