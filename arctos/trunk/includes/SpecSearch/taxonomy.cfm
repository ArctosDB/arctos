<script type="text/javascript" language="javascript">
	jQuery(document).ready(function() {	
		$("#begin_made_date").datepicker();
		$("#end_made_date").datepicker();
	});
</script>
<cfquery name="ctNatureOfId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	SELECT DISTINCT(nature_of_id) FROM ctnature_of_id ORDER BY nature_of_id
</cfquery>
<cfquery name="CTTAXA_FORMULA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	SELECT DISTINCT(TAXA_FORMULA) FROM CTTAXA_FORMULA ORDER BY TAXA_FORMULA
</cfquery>
<cfquery name="ct_taxon_term_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select 
		source,
		PREFERRED_TAXONOMY_SOURCE
	from 
		mv_u_taxonterm_source,
		collection
	where
		source=PREFERRED_TAXONOMY_SOURCE (+)
	group by 
		source,PREFERRED_TAXONOMY_SOURCE 
	order by 
		source
</cfquery>
<!--- list of taxonomy columns in FLAT ----><cfset colnterms="PHYLCLASS,KINGDOM,PHYLUM,PHYLORDER,FAMILY,GENUS,SPECIES,SUBSPECIES">
<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select 
		term_type
	from 
		taxon_term
	where
		term_type is not null and 
		POSITION_IN_CLASSIFICATION is not null
	group by term_type order by term_type
</cfquery>

<cfoutput>
<table id="t_identifiers" class="ssrch">
	<!----
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_scientific_name">Scientific&nbsp;Name:</span>
		</td>
		<td class="srch">
			<select name="sciNameOper" id="sciNameOper" size="1">
				<option value="">contains</option>
				<option value="NOT LIKE">does not contain</option>
				<option value="=">is exactly</option>
				<option value="was">is/was/cited/related</option>
				<option value="OR">in list</option>
		  	</select>
			<input type="text" name="scientific_name" id="scientific_name" size="28">
		</td>
	</tr>
	
	
	<select multiple size="3">
	<option selected>Current Scientific Name</option>
	<option>Previous Scientific Name(s)</option>
	<option>Higher Taxonomy</option>
</select>



	---->
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_taxon_name">Taxon Name:</span>
		</td>
		<td class="srch" style="border:1px solid green;">
			<table>
				<tr>
					<td><input type="text" name="taxon_name" id="taxon_name" size="50" placeholder="Taxon Name (Animalia; Soricidae)"></td>
				</tr>
				<!----
				<tr>
					<td>
						<table width="100%">
							<tr>
								<td width="50%">
									<label for="taxon_term_scope">Match taxonomy from</label>
									<select name="taxon_term_scope" id="taxon_term_scope">
										<option value="currentID">Current ID only</option>
										<option value="allID">Any ID</option>
									</select>
								</td>
								<td>
										<label for="taxon_term_match_type">Match Type</label>
										<select name="taxon_term_match_type" id="taxon_term_match_type">
											<option value="contains">contains</option>
											<option value="exact">is (case insensitive)</option>
											<option value="notcontains">does not contain</option>
											<option value="inlist">comma-list</option>
										</select>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<label for="">Taxonomy Source (*=preferred by 1 or more collections)</label>
						<select name="taxon_source" id="taxon_source">
							<option value="collection_preferred"><strong>current taxonomy only</strong></option>
							<option value="all"><strong>any related or webservice taxonomy</strong></option>
							<cfloop query="ct_taxon_term_source">
								<option value="#source#"><cfif len(PREFERRED_TAXONOMY_SOURCE) gt 0>* </cfif>#source#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<label>Term Rank (*= available as collection's taxonomy)</label>
						<select name="taxon_rank" id="taxon_rank">
							<option value="">ignore rank</option>
							<cfloop query="r">
								<option value="#term_type#">
								<cfif listcontainsnocase(colnterms,term_type)>* </cfif>
								#term_type#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				---------->
			</table>
		 	
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_common_name">Common Name:</span>
		</td>
		<td class="srch">
			<input name="common_name" id="common_name" type="text" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_nature_of_id">Nature of ID:</span>
		</td>
		<td class="srch">
			<select name="nature_of_id" id="nature_of_id" size="1">
				<option value=""></option>
				<cfloop query="ctNatureOfId">
					<option value="#ctNatureOfId.nature_of_id#">#ctNatureOfId.nature_of_id#</option>
				</cfloop>
			</select><span class="infoLink" 
							onclick="getCtDoc('ctnature_of_id',SpecData.nature_of_id.value);">Define</span>
		</td>
	</tr>
	
	<tr>
		<td class="lbl">
			<span class="helpLink" id="identifier">ID Determiner:</span>
		</td>
		<td class="srch">
			<input type="text" name="identified_agent" id="identified_agent">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="made_date">ID Made Date:</span>
		</td>
		<td class="srch">
			<input type="text" name="begin_made_date" id="begin_made_date" size="10" />-
			<input type="text" name="end_made_date" id="end_made_date" size="10" />
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_taxa_formula">ID Taxa Formula:</span>
		</td>
		<td class="srch">
			<select name="taxa_formula" id="taxa_formula" size="1">
				<option value=""></option>
				<cfloop query="cttaxa_formula">
					<option value="#cttaxa_formula.taxa_formula#">#cttaxa_formula.taxa_formula#</option>
				</cfloop>
			</select><span class="infoLink" onclick="getCtDoc('cttaxa_formula',SpecData.taxa_formula.value);">Define</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_identification_remarks">ID Remarks:</span>
		</td>
		<td class="srch">
			<input type="text" name="identification_remarks" id="identification_remarks">
		</td>
	</tr>
	
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_phylclass">Class:</span>
		</td>
		<td class="srch">
		 	<input type="text" name="phylclass" id="phylclass" size="50">
			<span class="infoLink" onclick="var e=document.getElementById('phylclass');e.value='='+e.value;">Add = for exact match</span>		
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_family">Family:</span>
		</td>
		<td class="srch">
			<input type="text" name="family" id="family" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_genus">Genus:</span>
		</td>
		<td class="srch">
			<input type="text" name="genus" id="genus" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_species">Species:</span>
		</td>
		<td class="srch">
			<input type="text" name="species" id="species" size="50">
			<span class="infoLink" onclick="var e=document.getElementById('species');e.value='='+e.value;">Add = for exact match</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_subspecies">Subspecies:</span>
		</td>
		<td class="srch">
			<input type="text" name="subspecies" id="subspecies" size="50">
			<span class="infoLink" onclick="var e=document.getElementById('subspecies');e.value='='+e.value;">Add = for exact match</span>
		</td>
	</tr>
	
</table>
</cfoutput>	