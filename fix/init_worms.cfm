<!----

see if we can make full records from worms download


first pass: do something with the stuff we just made
---->
<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select * from temp_worms where status='valid' and rownum<2
	</cfquery>
	<cfdump var=#d#>
	<cfloop query="d">
		<cftransaction>

			<cfquery name="tnid" datasource="uam_god">
				select taxon_name_id from taxon_name where scientific_name='#scientificname#'
			</cfquery>
			<cfdump var=#tnid#>
			<p>
				<a href="/name/#scientificname#">#scientificname#</a>
			</p>
			<cfset taxon_name_id=tnid.taxon_name_id>

			<cfset thisClassID='aphiaid::#TAXONID#'>

			<cfquery name="classh" datasource="uam_god">
				select
					scientificname,
					PARENTNAMEUSAGEID,
					TAXONRANK,
					level
				from
					temp_worms
				where
					PARENTNAMEUSAGEID is not null
				connect by
					prior PARENTNAMEUSAGEID=taxonid
				start with
					taxonid='#taxonid#'
			</cfquery>
			<cfdump var=#classh#>
			<cfloop query="classh">
				<cfquery name="meta" datasource="uam_god">
					insert into taxon_term (
						taxon_term_id,
						taxon_name_id,
						term_type,
						term,
						source,
						position_in_classification,
						classification_id
					) values (
						sq_taxon_term_id.nextval,
						#taxon_name_id#,
						'#lcase(TAXONRANK)#',
						'#scientificname#',
						'WoRMS (via Arctos)',
						#level#,
						'#thisClassID#'
					)
				</cfquery>

			</cfloop>


			<!----
			ACCEPTEDNAMEUSAGE 	ACCEPTEDNAMEUSAGEID 	BIBLIOGRAPHICCITATION 	DATASETNAME 	FAMILY 	GENUS 	INFRASPECIFICEPITHET 	IS_IN_ARCTOS 	KINGDOM 	LICENSE 	MODIFIED 	NAMEPUBLISHEDIN 	NAMEPUBLISHEDINID 	NAMEPUBLISHEDINYEAR 	NOMENCLATURALCODE 	PARENTNAMEUSAGE 	PARENTNAMEUSAGEID 	PCLASS 	PHYLUM 	PORDER 	REFERENCES 	RIGHTSHOLDER 	SCIENTIFICNAME 	SCIENTIFICNAMEAUTHORSHIP 	SCIENTIFICNAMEID 	SPECIFICEPITHET 	STATUS 	SUBGENUS 	TAXONID 	TAXONOMICSTATUS 	TAXONRANK
	1


			<cfquery name="meta" datasource="uam_god">
				insert into taxon_term (
					taxon_term_id,
					taxon_name_id,
					term_type,
					term,
					source,
					position_in_classification,
					classification_id
				) values (
					sq_taxon_term_id.nextval,
					#taxon_name_id#,
					'aphiaid',
					'#TAXONID#',
					'WoRMS (via Arctos)',
					NULL,
					'#thisClassID#'
				)
			</cfquery>
			---->


		</cftransaction>
	</cfloop>
</cfoutput>
