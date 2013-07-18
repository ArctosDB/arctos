<cfinclude template="../includes/_pickHeader.cfm">
	<cfoutput>
	<cfif len(scientific_name) is 0 or scientific_name is 'undefined'>
		<form name="s" method="post" action="TaxaPick.cfm">
			<input type="hidden" name="formName" value="#formName#">
			<input type="hidden" name="taxonIdFld" value="#taxonIdFld#">
			<input type="hidden" name="taxonNameFld" value="#taxonNameFld#">
			<label for="scientific_name">Scientific Name</label>
			<input type="text" name="scientific_name" id="scientific_name" size="50">
			<br><input type="submit" class="lnkBtn" value="Search">
		</form>
		<cfabort>
	</cfif>
		<cfquery name="getTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from (
				SELECT 
					scientific_name, 
					taxon_name_id
				from 
					taxon_name
				where
					UPPER(scientific_name) LIKE '#ucase(scientific_name)#%'
				UNION
				SELECT 
					a.scientific_name, 
					a.taxon_name_id
				from 
					taxon_name a,
					taxon_relations,
					taxon_name b
				where
					a.taxon_name_id = taxon_relations.taxon_name_id (+) and
					taxon_relations.related_taxon_name_id = b.taxon_name_id (+) and
					UPPER(B.scientific_name) LIKE '#ucase(scientific_name)#%'
				UNION
				SELECT 
					b.scientific_name, 
					b.taxon_name_id
				from 
					taxon_name a,
					taxon_relations,
					taxon_name b
				where
					a.taxon_name_id = taxon_relations.taxon_name_id (+) and
					taxon_relations.related_taxon_name_id = b.taxon_name_id (+) and
					UPPER(a.scientific_name) LIKE '#ucase(scientific_name)#%'
			)
			where taxon_name_id is not null
			group by 
				scientific_name,
				taxon_name_id
			ORDER BY scientific_name
		</cfquery>
	</cfoutput>
	<cfif #getTaxa.recordcount# is 1>
	<cfoutput>
		<script>
			opener.document.#formName#.#taxonIdFld#.value='#getTaxa.taxon_name_id#';opener.document.#formName#.#taxonNameFld#.value='#getTaxa.scientific_name#';self.close();
		</script>
	</cfoutput>
	<cfelseif #getTaxa.recordcount# is 0>
		<cfoutput>
			Nothing matched #scientific_name#. <a href="javascript:void(0);" onClick="opener.document.#formName#.#taxonIdFld#.value='';opener.document.#formName#.#taxonNameFld#.value='';opener.document.#formName#.#taxonNameFld#.focus();self.close();">Try again.</a>
		</cfoutput>
		
	<cfelse>
		<cfoutput query="getTaxa">
<br><a href="##" onClick="javascript: opener.document.#formName#.#taxonIdFld#.value='#taxon_name_id#';opener.document.#formName#.#taxonNameFld#.value='#scientific_name#';self.close();">#scientific_name#</a>
	<!---	
		<br><a href="##" onClick="javascript: document.selectedAgent.agentID.value='#agent_id#';document.selectedAgent.agentName.value='#agent_name#';document.selectedAgent.submit();">#agent_name# - #agent_id#</a> - 
	--->

	</cfoutput>
	</CFIF>

<cfinclude template="../includes/_pickFooter.cfm">