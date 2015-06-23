<cfif not isdefined("action")><cfset action="nothing"></cfif>

run these in order


<br><a href="processBulkloadClassification.cfm?action=checkMeta">checkMeta</a>
<br><a href="processBulkloadClassification.cfm?action=checkMeta">getTID</a>
<br><a href="processBulkloadClassification.cfm?action=getClassificationID">getClassificationID</a>


<cfif action is "checkMeta">
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='invalid operation' where status is null and operation not in ('update','replace')
	</cfquery>
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='invalid source' where status is null and source not in (
			select source from CTTAXONOMY_SOURCE
		)
	</cfquery><cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='pass_meta' where status is null
	</cfquery>

</cfif>
<!---------------------------------------------------------->

<cfif action is "getTID">
	<cfquery name="getTID" datasource="uam_god">
		update
			CF_TEMP_CLASSIFICATION
		set
			taxon_name_id=(
				select taxon_name.taxon_name_id from taxon_name where
				taxon_name.scientific_name = CF_TEMP_CLASSIFICATION.scientific_name
			)
		where
			status ='pass_meta' and
			taxon_name_id is null
	</cfquery>
	<cfquery name="fail" datasource="uam_god">
		update
			CF_TEMP_CLASSIFICATION
		set
			status='scientific_name not found'
		where
			status ='pass_meta' and
			taxon_name_id is null
	</cfquery>

</cfif>
<!---------------------------------------------------------->

<cfif action is "getClassificationID">
	<cfquery name="getClassificationID" datasource="uam_god">
		update
			CF_TEMP_CLASSIFICATION
		set
			classification_id=(
				select distinct
					classification_id
				from
					taxon_term
				where
					taxon_term.taxon_name_id=CF_TEMP_CLASSIFICATION.taxon_name_id and
					taxon_term.source=CF_TEMP_CLASSIFICATION.source
			)
		where
			status ='pass_meta' and
			taxon_name_id is not null
	</cfquery>
	<cfquery name="fail" datasource="uam_god">
		update
			CF_TEMP_CLASSIFICATION
		set
			classification_id='[NEW]'
		where
			status ='pass_meta' and
			classification_id is null
	</cfquery>

</cfif>
