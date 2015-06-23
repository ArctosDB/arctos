<cfif not isdefined("action")><cfset action="nothing"></cfif>


<a href="processBulkloadClassification.cfm?action=checkValid">checkValid</a>
<br><a href="processBulkloadClassification.cfm?action=getClassificationID">getClassificationID</a>

<cfif action is "checkValid">
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='scientific_name not found' where
		scientific_name not in (select scientific_name from taxon_name)
	</cfquery>
	<cfquery name="d2" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set taxon_name_id=(select taxon_name.taxon_name_id from taxon_name where
			taxon_name.scientific_name = CF_TEMP_CLASSIFICATION.scientific_name)
	</cfquery>
</cfif>


<cfif action is "getClassificationID">
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set classification_id=(
			select
				decode(distinct(classification_id),
					null,'DNE',
					classification_id) from
					taxon_term where
					taxon_term.taxon_name_id=CF_TEMP_CLASSIFICATION.taxon_name_id and
					taxon_term.source=CF_TEMP_CLASSIFICATION.source
			)
	</cfquery>

</cfif>
