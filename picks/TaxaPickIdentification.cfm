<cfthrow message = "TaxaPickIdentification is deprecated.">
<cfabort>
<!---
	Unlike TaxaPick.cfm, this form accepts formulaic identifications

	This form does NOT return taxon_name_id (it can be multiples)
---->
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
		function goExample(term) {
			$("#scientific_name").val(term);
			$("#blockAutoSubmit").val('true');
			$("#s").submit();
		}
		function showFormulaHelp() {
			$("#formulaHelp").show();
			$("#showHideFormulaHelp").hide();
		}
	</script>
	<style>
		#srchingFor {
			font-size:small;
			border:1px dashed green;
			margin:.6em;
			padding:.6em;
		}
		#formulaHelp {
			font-size:small;
			border:1px dashed green;
			margin:.6em;
			padding:.6em;
		}
	</style>
	<cfoutput>
		<span id="showHideFormulaHelp" onclick="showFormulaHelp();" class="likeLink">Show Usage and Formula Help</span>
		<div id="formulaHelp" style="display:none;">
			This form will accept the following <a href="/info/ctDocumentation.cfm?table=CTTAXA_FORMULA">formulaic taxonomy</a>.
			<li>
				<ul>
					<li>
						Formula "A": An exact match to any accepted taxonomy.scientific_name. Just type the start of (or entire) taxon name. Examples:
						<ul>
							<li><span class="likeLink" onclick="goExample('Sorex cinereus')">Sorex cinereus</span></li>
							<li><span class="likeLink" onclick="goExample('Soricidae')">Soricidae</span></li>
						</ul>
					</li>
					<li>
						Formula "A sp.": Any scientific name followed by space then "sp."
						No substring matching; "Filter Results by..." is ignored. Results only include names without spaces. Examples:
						<ul>
							<li><span class="likeLink" onclick="goExample('Sorex sp.')">Sorex sp.</span></li>
						</ul>
					</li>
					<li>
						Formula "A cf.": Any scientific name followed by space then "cf." No substring matching; "Filter Results by..." is ignored. Examples:
						<ul>
							<li><span class="likeLink" onclick="goExample('Sorex cf.')">Sorex cf.</span></li>
						</ul>
					</li>
					<li>
						Formula "A ?": Any scientific name followed by space then "?"  No substring matching; "Filter Results by..." is ignored. Examples:
						<ul>
							<li><span class="likeLink" onclick="goExample('Sorex ?')">Sorex ?.</span></li>
							<li><span class="likeLink" onclick="goExample('Sorex cinereus ?')">Sorex cinereus ?</span></li>
						</ul>
					</li>
					<li>
						Formula "A x B": Any scientific name followed by space then "x" then another scientific name.
						No substring matching; "Filter Results by..." is ignored. Examples:
						<ul>
							<li><span class="likeLink" onclick="goExample('Sorex x Alces')">Sorex x Alces</span></li>
							<li><span class="likeLink" onclick="goExample('Sorex cinereus x Alces alces')">Sorex cinereus x Alces alces</span></li>
						</ul>
					</li>
					<li>
						Formula "A or B": Any scientific name followed by space then "or" then another scientific name.
						 No substring matching; ; "Filter Results by..." is ignored. Examples:
						<ul>
							<li><span class="likeLink" onclick="goExample('Sorex or Alces')">Sorex or Alces</span></li>
							<li><span class="likeLink" onclick="goExample('Sorex cinereus or Alces alces')">Sorex cinereus or Alces alces</span></li>
						</ul>
					</li>
					<li>
						Formula "A {string}": Any scientific name followed by space then "{" then any string then "}".
						 No substring matching; ; "Filter Results by..." is ignored. Examples:
						<ul>
							<li><span class="likeLink" onclick="goExample('Sorex {Sorex n. sp. workingname}')">Sorex {Sorex n. sp. workingname}</span></li>
							<li><span class="likeLink" onclick="goExample('Sorex cinereus {you can type anything here}')">Sorex cinereus {you can type anything here}</span></li>
						</ul>
					</li>
				</ul>
			</li>
		</div>
		<cfif not isdefined("session.taxaPickPrefs") or len(session.taxaPickPrefs) is 0>
			<cfset session.taxaPickPrefs="anyterm">
		</cfif>
		<cfset taxaPickPrefs=session.taxaPickPrefs>
		<form name="s" id="s" method="post" action="TaxaPickIdentification.cfm">
			<input type="hidden" name="formName" value="#formName#">
			<input type="hidden" name="taxonIdFld" value="#taxonIdFld#">
			<input type="hidden" name="taxonNameFld" value="#taxonNameFld#">
			<input type="hidden" id="blockAutoSubmit" name="blockAutoSubmit" value="false">
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
		<cfif right(scientific_name,4) is " sp.">
			<cfset thisName=left(scientific_name,len(scientific_name)-4)>
			<cfset formula="A sp.">
			<div id="srchingFor">
				formula: #formula#
				<br>Namestring IS: #thisName#
			</div>
			<cfset sql="SELECT
					scientific_name || ' sp.' scientific_name
				from
					taxon_name
				where
					UPPER(scientific_name) LIKE '#ucase(thisName)#%'
					 and scientific_name not like '% %'
				order by
				  		scientific_name">
		<cfelseif  right(scientific_name,4) is " cf.">
			<cfset thisName=left(scientific_name,len(scientific_name)-4)>
			<cfset formula="A cf.">
			<div id="srchingFor">
				formula: #formula#
				<br>Namestring IS: #thisName#
			</div>
			<cfset sql="SELECT
					scientific_name || ' cf.' scientific_name
				from
					taxon_name
				where
					UPPER(scientific_name) LIKE '#ucase(thisName)#'
				order by
				  		scientific_name">
		<cfelseif  right(scientific_name,2) is " ?">
			<cfset thisName=left(scientific_name,len(scientific_name)-2)>
			<cfset formula="A ?">
			<div id="srchingFor">
				formula: #formula#
				<br>Namestring IS: #thisName#
			</div>
			<cfset sql="SELECT
					scientific_name || ' ?' scientific_name
				from
					taxon_name
				where
					UPPER(scientific_name) LIKE '#ucase(thisName)#%'
				order by
				  		scientific_name">
		<cfelseif  scientific_name contains " or ">
			<cfset theSplit=find(" or ",scientific_name)>
			<cfset thisName1=left(scientific_name,theSplit-1)>
			<cfset thisName2=replace(scientific_name,"#thisName1# or ","","first")>
			<cfset formula="A or B">
			<div id="srchingFor">
				formula: #formula#
				<br>Namestring1 IS: #thisName1#
				<br>Namestring2 IS: #thisName2#
			</div>
			<cfset sql="SELECT
					a.scientific_name || ' or ' || b.scientific_name scientific_name
				from
					taxon_name a,
					taxon_name b
				where
					UPPER(a.scientific_name) = '#ucase(thisName1)#' and
					UPPER(b.scientific_name) = '#ucase(thisName2)#'
			">
		<cfelseif  scientific_name contains " and ">
			<cfset theSplit=find(" and ",scientific_name)>
			<cfset thisName1=left(scientific_name,theSplit-1)>
			<cfset thisName2=replace(scientific_name,"#thisName1# and ","","first")>
			<cfset formula="A and B">
			<div id="srchingFor">
				formula: #formula#
				<br>Namestring1 IS: #thisName1#
				<br>Namestring2 IS: #thisName2#
			</div>
			<cfset sql="SELECT
					a.scientific_name || ' and ' || b.scientific_name scientific_name
				from
					taxon_name a,
					taxon_name b
				where
					UPPER(a.scientific_name) = '#ucase(thisName1)#' and
					UPPER(b.scientific_name) = '#ucase(thisName2)#'
			">
		<cfelseif  scientific_name contains "{" and scientific_name contains "}">
			<cfset theSplit=find("{",scientific_name)>
			<cfset thisName=left(scientific_name,theSplit-2)>
			<cfset theString=trim(replace(scientific_name,thisName,"","first"))>
			<cfset formula="A {string}">
			<div id="srchingFor">
				formula: #formula#
				<br>Namestring IS: #thisName#
			</div>
			<cfset sql="SELECT
					scientific_name || ' #theString#' scientific_name
				from
					taxon_name
				where
					UPPER(scientific_name) = '#ucase(thisName)#'
			">
		<cfelse>
			<!--- formula A --->
			<cfset thisName=scientific_name>
			<cfset formula="A">
			<div id="srchingFor">
				formula: #formula#
				<br>Namestring STARTS WITH: #thisName#
			</div>
			<cfif taxaPickPrefs is "anyterm">
				<cfset sql="SELECT
					scientific_name
				from
					taxon_name
				where
					UPPER(scientific_name) LIKE '#ucase(thisName)#%'
				order by
				  		scientific_name">
			<cfelseif taxaPickPrefs is "usedbymycollections">
				<!--- VPD limits users to seeing only their collections, so just make the joins --->
				<cfset sql="select scientific_name,taxon_name_id from (
					SELECT
						taxon_name.scientific_name
					from
						taxon_name,
						identification_taxonomy,
						identification,
						cataloged_item
					where
						taxon_name.taxon_name_id=identification_taxonomy.taxon_name_id and
						identification_taxonomy.identification_id=identification.identification_id and
						identification.collection_object_id=cataloged_item.collection_object_id and
						UPPER(taxon_name.scientific_name) LIKE '#ucase(thisName)#%'
					)
					group by
						scientific_name
					order by
				  		scientific_name">
			<cfelseif taxaPickPrefs is "mycollections">
				<!--- VPD limits users to seeing only their collections, so just make the joins --->
				<cfset sql="select scientific_name from (
					SELECT
				 		taxon_name.scientific_name
					from
				  		taxon_name,
				  		taxon_term,
				  		collection
					where
						taxon_name.taxon_name_id=taxon_term.taxon_name_id and
						taxon_term.SOURCE=collection.PREFERRED_TAXONOMY_SOURCE and
				  		UPPER(taxon_name.scientific_name) LIKE '#ucase(thisName)#%'
				  	)
				  	group by
				  		scientific_name
				  	order by
				  		scientific_name">
			<cfelseif taxaPickPrefs is "relatedterm">
				<cfset sql="select * from (
					SELECT
						scientific_name
					from
						taxon_name
					where
						UPPER(taxon_name.scientific_name) LIKE '#ucase(thisName)#%'
					UNION
					SELECT
						a.scientific_name
					from
						taxon_name a,
						taxon_relations,
						taxon_name b
					where
						a.taxon_name_id = taxon_relations.taxon_name_id (+) and
						taxon_relations.related_taxon_name_id = b.taxon_name_id (+) and
						UPPER(B.scientific_name) LIKE '#ucase(thisName)#%'
					UNION
					SELECT
						b.scientific_name
					from
						taxon_name a,
						taxon_relations,
						taxon_name b
					where
						a.taxon_name_id = taxon_relations.taxon_name_id (+) and
						taxon_relations.related_taxon_name_id = b.taxon_name_id (+) and
						UPPER(a.scientific_name) LIKE '#ucase(thisName)#%'
				)
				group by
					scientific_name
				ORDER BY
					scientific_name
			">
			</cfif>
		</cfif>
		<a name="results"></a>
		<cfquery name="getTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#PreserveSingleQuotes(sql)#
		</cfquery>
		<cfif not isdefined("blockAutoSubmit")>
			<cfset blockAutoSubmit=false>
		</cfif>
		<cfif blockAutoSubmit is "true">
			<!--- the only way to get here is through examples/help, so turn that back on --->
			<script>
				jQuery(document).ready(function() {
					showFormulaHelp();
					scrollToAnchor('results');
				});
			</script>
		</cfif>
		<cfif getTaxa.recordcount is 1 and blockAutoSubmit is false>
			<cfoutput>
				<script>
					opener.document.#formName#.#taxonNameFld#.value='#getTaxa.scientific_name#';self.close();
				</script>
			</cfoutput>
		<cfelseif getTaxa.recordcount is 0>
			<cfoutput>
				Nothing matched #scientific_name#. <a href="javascript:void(0);" onClick="opener.document.#formName#.#taxonIdFld#.value='';opener.document.#formName#.#taxonNameFld#.value='';opener.document.#formName#.#taxonNameFld#.focus();self.close();">Try again.</a>
			</cfoutput>
		<cfelse>
			<cfloop query="getTaxa">
				<br><a href="##" onClick="javascript: ;opener.document.#formName#.#taxonNameFld#.value='#scientific_name#';self.close();">#scientific_name#</a>
			</cfloop>
		</cfif>
	</cfoutput>
<cfinclude template="/includes/_pickFooter.cfm">