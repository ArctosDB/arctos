<cfif not isdefined("action")><cfset action="nothing"></cfif>


<a href="processBulkloadClassification.cfm?action=checkValid">checkValid</a>

<cfif action is "checkValid">
	<cfquery name="d" datasource="uam_god">
		update CF_TEMP_CLASSIFICATION set status='scientific_name not found' where
		scientific_name not in (select scientific_name from taxon_name)
	</cfquery>

</cfif>
