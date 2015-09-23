<cfinclude template="/includes/_pickHeader.cfm">
	<script>
		function settaxaPickPrefs (v) {
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "setSessionTaxaPickPrefs",
					val : v,
					returnformat : "json",
					queryformat : 'column'
				}
			);
		}
	</script>
	<cfoutput>
		<cfif not isdefined ("scientific_name")>
			<cfset scientific_name="">
		</cfif>
		<cfif not isdefined("session.taxaPickPrefs") or len(session.taxaPickPrefs) is 0>
			<cfset session.taxaPickPrefs="anyterm">
		</cfif>
		<cfset taxaPickPrefs=session.taxaPickPrefs>
		<form name="s" method="post" action="demo.cfm">
			<label for="scientific_name">Scientific Name (STARTS WITH)</label>
			<input type="text" name="scientific_name" id="scientific_name" size="50" value="#scientific_name#">
			<label for="taxaPickPrefs">Filter Results by...</label>
			<select name="taxaPickPrefs" id="taxaPickPrefs" onchange="settaxaPickPrefs(this.value);">
				<option <cfif session.taxaPickPrefs is "anyterm"> selected="selected" </cfif> value="anyterm">Any Term (best performance)</option>
				<option <cfif session.taxaPickPrefs is "relatedterm"> selected="selected" </cfif> value="relatedterm">Include terms from relationships</option>
				<option <cfif session.taxaPickPrefs is "mycollections"> selected="selected" </cfif> value="mycollections">Include only terms with classifications preferred by my collections</option>
				<option <cfif session.taxaPickPrefs is "usedbymycollections"> selected="selected" </cfif> value="usedbymycollections">Include only terms used by my collections</option>
			</select>
			<br><input type="submit" class="lnkBtn" value="Search">
		</form>
		<cfif len(scientific_name) is 0 or scientific_name is 'undefined'>
			<cfabort>
		</cfif>

		<hr>

		<p>
			Basic, names only.
		</p>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				SELECT
					scientific_name,
					taxon_name_id
				from
					taxon_name
				where
					UPPER(scientific_name) LIKE '#ucase(scientific_name)#%'
				order by
				  		scientific_name
			</cfquery>
		<p>
		ExecutionTime: #d.ExecutionTime#
		</p>
		<div style="max-height:20em;">
			<cfloop query="d">
				<br>#scientific_name#
			</cfloop>
		</div>
	</cfoutput>



		<!----- oldstuff
		<cfif taxaPickPrefs is "anyterm">
			<cfset sql="SELECT
				scientific_name,
				taxon_name_id
			from
				taxon_name
			where
				UPPER(scientific_name) LIKE '#ucase(scientific_name)#%'
			order by
			  		scientific_name">
		<cfelseif taxaPickPrefs is "usedbymycollections">
			<!--- VPD limits users to seeing only their collections, so just make the joins --->
			<cfset sql="select scientific_name,taxon_name_id from (
				SELECT
					taxon_name.scientific_name,
					taxon_name.taxon_name_id
				from
					taxon_name,
					identification_taxonomy,
					identification,
					cataloged_item
				where
					taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
					identification_taxonomy.identification_id=identification.identification_id and
					identification.collection_object_id=cataloged_item.collection_object_id and
					UPPER(taxon_name.scientific_name) LIKE '#ucase(scientific_name)#%'
				)
				group by
					scientific_name,
					taxon_name_id
				order by
			  		scientific_name">
		<cfelseif taxaPickPrefs is "mycollections">
			<!--- VPD limits users to seeing only their collections, so just make the joins --->
			<cfset sql="select scientific_name,taxon_name_id from (
				SELECT
			 		taxon_name.scientific_name,
			  		taxon_name.taxon_name_id
				from
			  		taxon_name,
			  		taxon_term,
			  		collection
				where
					taxon_name.taxon_name_id=taxon_term.taxon_name_id and
					taxon_term.SOURCE=collection.PREFERRED_TAXONOMY_SOURCE and
			  		UPPER(taxon_name.scientific_name) LIKE '#ucase(scientific_name)#%'
			  	)
			  	group by
			  		scientific_name,
			  		taxon_name_id
			  	order by
			  		scientific_name">
		<cfelseif taxaPickPrefs is "relatedterm">
			<cfset sql="select * from (
				SELECT
					scientific_name,
					taxon_name_id
				from
					taxon_name
				where
					UPPER(taxon_name.scientific_name) LIKE '#ucase(scientific_name)#%'
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
			where
				taxon_name_id is not null
			group by
				scientific_name,
				taxon_name_id
			ORDER BY
				scientific_name
		">
		</cfif>



		<cfquery name="getTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#PreserveSingleQuotes(sql)#
		</cfquery>
		<cfif getTaxa.recordcount is 0>
			<p>
				No Match
			</p>
		<cfelse>
			<cfloop query="getTaxa">
				<br>#scientific_name#
			</cfloop>
		</cfif>
	</cfoutput>
	<!----
	<cfif getTaxa.recordcount is 1>
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
	---->

oldstuff ---->
<cfinclude template="/includes/_pickFooter.cfm">