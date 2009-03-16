<cfinclude template="../includes/_pickHeader.cfm">
 <!--- no security --->


	<!--- make sure we're searching for something --->
	<cfif len(#scientific_name#) is 0>
		You must enter search criteria.
		<cfabort>
	</cfif>
	<cfoutput>
		<cfquery name="getTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				scientific_name, 
				taxon_name_id, 
				valid_catalog_term_fg
			from 
				taxonomy
			where
				UPPER(scientific_name) LIKE '#ucase(scientific_name)#%'
			UNION
			SELECT 
				a.scientific_name, 
				a.taxon_name_id, 
				a.valid_catalog_term_fg
			from 
				taxonomy a,
				taxon_relations,
				taxonomy b
			where
				a.taxon_name_id = taxon_relations.taxon_name_id (+) and
				taxon_relations.related_taxon_name_id = b.taxon_name_id (+) and
				UPPER(B.scientific_name) LIKE '#ucase(scientific_name)#%'
			UNION
			SELECT 
				a.scientific_name, 
				a.taxon_name_id, 
				a.valid_catalog_term_fg
			from 
				taxonomy a,
				taxon_relations,
				taxonomy b
			where
				a.taxon_name_id = taxon_relations.taxon_name_id (+) and
				taxon_relations.related_taxon_name_id = b.taxon_name_id (+) and
				UPPER(a.scientific_name) LIKE '#ucase(scientific_name)#%'
			ORDER BY scientific_name
		</cfquery>
	</cfoutput>
	<cfif #getTaxa.recordcount# is 1>
	<cfoutput>
		<cfif #getTaxa.valid_catalog_term_fg# is "1">
		<script>
			opener.document.#formName#.#taxonIdFld#.value='#getTaxa.taxon_name_id#';opener.document.#formName#.#taxonNameFld#.value='#getTaxa.scientific_name#';self.close();
		</script>
		<cfelse>
			<a href="##" onClick="javascript: opener.document.#formName#.#taxonIdFld#.value='#getTaxa.taxon_name_id#';opener.document.#formName#.#taxonNameFld#.value='#getTaxa.scientific_name#';self.close();"><font color="##FF0000">#getTaxa.scientific_name# (unaccepted)</font></a>
		</cfif>
	</cfoutput>
	<cfelseif #getTaxa.recordcount# is 0>
		<cfoutput>
			Nothing matched #scientific_name#. <a href="javascript:void(0);" onClick="opener.document.#formName#.#taxonIdFld#.value='';opener.document.#formName#.#taxonNameFld#.value='';opener.document.#formName#.#taxonNameFld#.focus();self.close();">Try again.</a>
		</cfoutput>
		
	<cfelse>
		<cfoutput query="getTaxa">
		<cfif #getTaxa.valid_catalog_term_fg# is "1">
<br><a href="##" onClick="javascript: opener.document.#formName#.#taxonIdFld#.value='#taxon_name_id#';opener.document.#formName#.#taxonNameFld#.value='#scientific_name#';self.close();">#scientific_name#</a>
	<!---	
		<br><a href="##" onClick="javascript: document.selectedAgent.agentID.value='#agent_id#';document.selectedAgent.agentName.value='#agent_name#';document.selectedAgent.submit();">#agent_name# - #agent_id#</a> - 
	--->
	<cfelse>
	<br><a href="##" onClick="javascript: opener.document.#formName#.#taxonIdFld#.value='#taxon_name_id#';opener.document.#formName#.#taxonNameFld#.value='#scientific_name#';self.close();"><font color="##FF0000">#scientific_name# (unaccepted)</font></a>
	</cfif>
	</cfoutput>
	</CFIF>

<cfinclude template="../includes/_pickFooter.cfm">