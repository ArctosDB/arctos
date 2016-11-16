<cfinclude template="includes/_header.cfm">
<cfset noCloneTerms="author_text,display_name,infraspecific_author,remark,scientific_name,source_authority,species,subspecies,taxon_status">
<a target="_blank" class="external" href="http://arctosdb.org/documentation/identification/taxonomy/#edit">editing guidelines</a>
<!------------------------------------------------------------------------------->
<cfif action is "cloneClassificationNewName">
	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source order by source
	</cfquery>
	<cfquery name="CTTAXON_TERM" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select taxon_term from CTTAXON_TERM where taxon_term not in (#listqualify(noCloneTerms,"'")#) order by taxon_term
	</cfquery>
	<cfoutput>
		<p>
		Use this form to create a clone of a name and classification as another (e.g., local and editable) Source.
		</p>
		<p>
			You are creating a new namestring.
		</p>
		<p>
			You should not do that if the namestring (scientific name) exists, even if it's currently used for some other
			biological entity. That is, Diptera (flies) and Diptera (plants) share a namestring, and a new name is not necessary (or possible).
		</p>
		<p>
			Pick a source below, enter the new namestring, click the button, and then you'll have a chance to edit the classification you've created.
		</p>
		<form name="x" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="action" value="cloneClassificationNewName_insert">
			<input type="hidden" name="classification_id" value="#classification_id#">
			<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
			<label for="newName">New Namestring/Scientific Name</label>
			<input type="text" name="newName" id="newName" class="reqdClr">
			<label for="source">Clone into Source</label>
			<select name="source" id="source" class="reqdClr">
				<cfloop query="cttaxonomy_source">
					<option value="#source#">#source#</option>
				</cfloop>
			</select>
			<p>
				IMPORTANT: Only select terms from <a target="_blank" href="/info/ctDocumentation.cfm?table=CTTAXON_TERM">CTTAXON_TERM</a>
				will be cloned. Anything not in the list below will be ignored.

				<ul>
					<cfloop query="CTTAXON_TERM">
						<li>#taxon_term#</li>
					</cfloop>
				</ul>

				This may include terms that you do not wish to clone, and it may exclude terms which you do wish to clone. Please
				carefully check everything before saving.
			</p>

			<input type="submit" value="create name and classification">
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "cloneClassificationNewName_insert">
	<cfoutput>

		<cfquery name="seedClassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select distinct
				TAXON_NAME_ID,
				CLASSIFICATION_ID,
				TERM,
				TERM_TYPE,
				POSITION_IN_CLASSIFICATION
			from
				taxon_term
			where
				classification_id='#classification_id#' and
				TERM_TYPE in (select taxon_term from CTTAXON_TERM where taxon_term not in (#listqualify(noCloneTerms,"'")#))
			order by
				POSITION_IN_CLASSIFICATION
		</cfquery>
		<!----
		<cfdump var=#seedClassification#>

		<cfabort>
		---->
		<cfset thisSourceID=CreateUUID()>
		<cftransaction>
			<!---  new name --->
			<cfquery name="nnID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_taxon_name_id.nextval tnid from dual
			</cfquery>
			<cfquery name="newName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into taxon_name (taxon_name_id,scientific_name) values (#nnID.tnid#,'#newName#')
			</cfquery>
			<cfset pic=1>

			<cfloop query="seedClassification">
				<cfquery name="seedClassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into taxon_term (
						TAXON_NAME_ID,
						CLASSIFICATION_ID,
						TERM,
						TERM_TYPE,
						SOURCE,
						POSITION_IN_CLASSIFICATION
					) values (
						#nnID.tnid#,
						'#thisSourceID#',
						'#TERM#',
						'#TERM_TYPE#',
						'#SOURCE#',
						<cfif len(POSITION_IN_CLASSIFICATION) is 0>
							NULL
						<cfelse>
							#pic#
							<cfset pic=pic+1>
						</cfif>
					)
				</cfquery>
			</cfloop>
			<cfquery name="scientific_name" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into taxon_term (
					TAXON_NAME_ID,
					CLASSIFICATION_ID,
					TERM,
					TERM_TYPE,
					SOURCE,
					POSITION_IN_CLASSIFICATION
				) values (
					#nnID.tnid#,
					'#thisSourceID#',
					'#newName#',
					'scientific_name',
					'#SOURCE#',
					#pic#
				)
			</cfquery>
		</cftransaction>
		<cflocation url="/editTaxonomy.cfm?action=editClassification&classification_id=#thisSourceID#&taxon_name_id=#nnID.tnid#" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "cloneClassification">
	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source order by source
	</cfquery>
	<cfoutput>
		<p>
		Use this form to create a clone of a classification as another (e.g., local and editable) Source.
		</p>
		<p>
			Do NOT try to use this form to create names - use "create name" or "clone classification into new name" for that.
		</p>
		<p>
			Do NOT use this form to assert taxon relationships - use "edit non-classification data" for that.
		</p>
		<p>
			Pick a source below, click the button, and then you'll have a chance to edit the classification you've created.
		</p>
		<form name="x" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="action" value="cloneClassification_insert">
			<input type="hidden" name="classification_id" value="#classification_id#">
			<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
			<label for="source">Clone into Source</label>
			<select name="source" id="source" class="reqdClr">
				<cfloop query="cttaxonomy_source">
					<option value="#source#">#source#</option>
				</cfloop>
			</select>
			<input type="submit" value="create classification">
		</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "cloneClassification_insert">
	<cfoutput>
		<cfquery name="seedClassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select
				TAXON_NAME_ID,
				CLASSIFICATION_ID,
				TERM,
				TERM_TYPE,
				POSITION_IN_CLASSIFICATION
			from
				taxon_term
			where
				taxon_name_id=#taxon_name_id# and
				classification_id='#classification_id#'
			group by
				TAXON_NAME_ID,
				CLASSIFICATION_ID,
				TERM,
				TERM_TYPE,
				POSITION_IN_CLASSIFICATION
		</cfquery>
		<cfset thisSourceID=CreateUUID()>
		<cftransaction>
			<cfloop query="seedClassification">
				<cfquery name="seedClassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into taxon_term (
						TAXON_NAME_ID,
						CLASSIFICATION_ID,
						TERM,
						TERM_TYPE,
						SOURCE,
						POSITION_IN_CLASSIFICATION
					) values (
						#TAXON_NAME_ID#,
						'#thisSourceID#',
						'#TERM#',
						'#TERM_TYPE#',
						'#SOURCE#',
						<cfif len(POSITION_IN_CLASSIFICATION) is 0>
							NULL
						<cfelse>
							#POSITION_IN_CLASSIFICATION#
						</cfif>
					)
				</cfquery>
			</cfloop>
		</cftransaction>
		<cflocation url="/editTaxonomy.cfm?action=editClassification&classification_id=#thisSourceID#&TAXON_NAME_ID=#TAXON_NAME_ID#" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "forceDeleteNonLocal">
	<cfoutput>
		Are you sure you want to delete all source-derived metadata?

		<p>
			You should probably use the "refresh from globalnames" link when you're done here.
		</p>
		<p>
			Use your back button to get out of here.
		</p>
		<p>
			<a href="editTaxonomy.cfm?action=yesReally_forceDeleteNonLocal&taxon_name_id=#taxon_name_id#">
				Click here to finalize the delete of all non-local metadata
			</a>
		</p>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "yesReally_forceDeleteNonLocal">
	<cfoutput>
		<cfquery name="insRow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from taxon_term where source not in (select source from cttaxonomy_source) and taxon_name_id=#taxon_name_id#
		</cfquery>
		<cflocation url="/taxonomy.cfm?taxon_name_id=#taxon_name_id#" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif action is "saveNewClass">
	<cfoutput>
		<cfif len(source) is 0>
			Source is required.
			<cfabort>
		</cfif>
		<cfset thisSourceID=CreateUUID()>
		<cftransaction>
			<cfloop from="1" to="10" index="i">
				<cfset thisTerm=evaluate("ncterm_" & i)>
				<cfset thisTermType=evaluate("ncterm_type_" & i)>
				<cfif len(thisTerm) gt 0 and len(thisTermType) gt 0>
					<cfquery name="insRow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into taxon_term (
							taxon_term_id,
							taxon_name_id,
							term,
							term_type,
							source,
							classification_id
						) values (
							sq_taxon_term_id.nextval,
							#taxon_name_id#,
							'#thisTerm#',
							'#thisTermType#',
							'#Source#',
							'#thisSourceID#'
						)
					</cfquery>
				</cfif>
			</cfloop>
			<cfset pos=1>
			<cfloop from="1" to="10" index="i">
				<!--- deal with yahoos leaving empty cells.... ---->
				<cfset thisTerm=evaluate("term_" & i)>
				<cfset thisTermType=evaluate("term_type_" & i)>
				<cfif len(thisTerm) gt 0>
					<cfquery name="insRow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into taxon_term (
							taxon_term_id,
							taxon_name_id,
							term,
							term_type,
							source,
							position_in_classification,
							classification_id
						) values (
							sq_taxon_term_id.nextval,
							#taxon_name_id#,
							'#thisTerm#',
							'#lcase(thisTermType)#',
							'#source#',
							#pos#,
							'#thisSourceID#'
						)
					</cfquery>
					<cfset pos=pos+1>
				</cfif>
			</cfloop>
		</cftransaction>
		<cflocation url="/editTaxonomy.cfm?action=editClassification&classification_id=#thisSourceID#" addtoken="false">
		<!----
		---->
	</cfoutput>
</cfif>



<!----
<!--------------------------------------------->
<cfif action is "newClassification">
	<script>
		// copy this with edit classification
		$(function() {
			// suggest some defaults
			$("#ncterm_type_1").val('author_text');
			$("#ncterm_type_2").val('display_name');
			$("#ncterm_type_3").val('nomenclatural_code');
			$("#ncterm_type_4").val('taxon_status');
			$("#ncterm_type_5").val('infraspecific_author');
			$( "#sortable" ).sortable({
				handle: '.dragger'
			});
			var ac_isclass_ttoptions = {
	       		source: '/component/functions.cfc?method=ac_isclass_tt',
				width: 320,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
		    };
			var ac_noclass_ttoptions = {
	       		source: '/component/functions.cfc?method=ac_noclass_tt',
				width: 320,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
		    };
		    $("input.ac_isclass_tt").live("keydown.autocomplete", function() {
		        $(this).autocomplete(ac_isclass_ttoptions);
		    });
			$("input.ac_noclass_tt").live("keydown.autocomplete", function() {
		        $(this).autocomplete(ac_noclass_ttoptions);
		    });

		});
		function requirePair(i){
			var tt=$("#ncterm_type_" + i).val().length;
			var t=$("#ncterm_" + i).val().length;
			if (tt>0 || t>0){
				$("#ncterm_type_" + i).addClass('reqdClr');
				$("#ncterm_" + i).addClass('reqdClr');
			} else {
				$("#ncterm_type_" + i).removeClass('reqdClr');
				$("#ncterm_" + i).removeClass('reqdClr');
			}
		}
	</script>
	<p>
		Create classifications here. This form is limited - you can edit classifications (after creating them here) to do more.
	</p>
	<p>"Classifications" consist of hierarchical "taxonomy" data and nonhierarchical, non-classification data attributable to a Source.

	"Nomenclatural code according to Arctos" is part of a Clasification (so it can be linked to the potentially-ranked taxonomy) but is NOT part of the
	taxonomic classification.</p>
	<p>
		There are no true hierarchies, and there are no data rules. You can type anything here. Be exceedingly careful.
	</p>
	<cfquery name="thisName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select scientific_name from taxon_name where taxon_name_id=#taxon_name_id#
	</cfquery>
	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source order by source
	</cfquery>
	<cfoutput>
		<cfset title="Create Classification for #thisName.scientific_name#">
		<h3>Create Classification for #thisName.scientific_name#</h3>

		<form name="f1" id="f1" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="action" value="saveNewClass">
			<input type="hidden" name="taxon_name_id" id="taxon_name_id" value="#taxon_name_id#">

			<label for="source">Source</label>
			<select name="source" id="source" class="reqdClr">
				<cfloop query="cttaxonomy_source">
					<option value="#source#">#source#</option>
				</cfloop>
			</select>
			<h3>
				Non-Classification Terms
			</h3>
			<p style="font-size:small;">
				These are paired terms; unpaired terms will be ignored. That means you can ignore the defaulted-in suggestions if you want.
			</p>
			<table id="clastbl" border="1">
				<thead>
					<tr>
						<th>
							Term Type
							<a target="_blank" href="/component/functions.cfc?method=ac_noclass_tt&term">[ view all (JSON)]</a>
						</th>
						<th>Term</th>
					</tr>
				</thead>
				<tbody id="notsortable">
					<cfloop from="1" to="10" index="i">
						<tr id="nccell_#i#">
							<td>
								<input class="ac_noclass_tt" size="60" type="text" id="ncterm_type_#i#" name="ncterm_type_#i#" onchange="requirePair(#i#);">
							</td>
							<td>
								<input size="60" type="text" id="ncterm_#i#" name="ncterm_#i#" onchange="requirePair(#i#);">
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<h3>
				Classification Terms
			</h3>
			<p style="font-size:small;">
				 Order is important here - "large" (eg, kingdom) at top to "small" (eg, subspecies) at bottom.
				Use as many cells as you need; leave the rest empty.
				 TermType will be ignored if Term is empty. Term will be saved regardless of TermType; unranked terms are OK.
				 Add more via Edit (after you save here) if necessary.
			</p>
			<table id="clastbl" border="1">
				<thead>
					<tr><th>Term Type
					<a target="_blank" href="/component/functions.cfc?method=ac_isclass_tt&term">[ view all (JSON)]</a>
					</th><th>Term</th></tr>
				</thead>
				<tbody id="sortable">
					<cfloop from="1" to="10" index="i">

							<td>
								<input size="60" class="ac_isclass_tt" type="text" id="term_type_#i#" name="term_type_#i#">
							</td>
							<td>
								<input size="60" type="text" id="term_#i#" name="term_#i#" >
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<p>
				<input type="submit" value="Create Classification">
			</p>
		</form>
	</cfoutput>
</cfif>
---->


<!--------------------------------------------->
<cfif action is "newClassification">
	<!---- edit: don't suggest, force, using cttaxon_term ---->
	<script>
		// copy this with edit classification
		$(function() {
			// suggest some defaults
			$("#ncterm_type_1").val('author_text');
			$("#ncterm_type_2").val('display_name');
			$("#ncterm_type_3").val('nomenclatural_code');
			$("#ncterm_type_4").val('taxon_status');
			$("#ncterm_type_5").val('infraspecific_author');
			$( "#sortable" ).sortable({
				handle: '.dragger'
			});


			/*
			var ac_isclass_ttoptions = {
	       		source: '/component/functions.cfc?method=ac_isclass_tt',
				width: 320,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
		    };
			var ac_noclass_ttoptions = {
	       		source: '/component/functions.cfc?method=ac_noclass_tt',
				width: 320,
				max: 50,
				autofill: false,
				multiple: false,
				scroll: true,
				scrollHeight: 300,
				matchContains: true,
				minChars: 1,
				selectFirst:false
		    };
		    $("input.ac_isclass_tt").live("keydown.autocomplete", function() {
		        $(this).autocomplete(ac_isclass_ttoptions);
		    });
			$("input.ac_noclass_tt").live("keydown.autocomplete", function() {
		        $(this).autocomplete(ac_noclass_ttoptions);
		    });
			*/
		});
		function requirePair(i){
			var tt=$("#ncterm_type_" + i).val().length;
			var t=$("#ncterm_" + i).val().length;
			if (tt>0 || t>0){
				$("#ncterm_type_" + i).addClass('reqdClr');
				$("#ncterm_" + i).addClass('reqdClr');
			} else {
				$("#ncterm_type_" + i).removeClass('reqdClr');
				$("#ncterm_" + i).removeClass('reqdClr');
			}
		}
	</script>
	<p>
		Create classifications here. This form is limited - you can edit classifications (after creating them here) to do more.
	</p>
	<p>"Classifications" consist of hierarchical "taxonomy" data and nonhierarchical, non-classification data attributable to a Source.

	"Nomenclatural code according to Arctos" is part of a Clasification (so it can be linked to the potentially-ranked taxonomy) but is NOT part of the
	taxonomic classification.</p>
	<p>
		There are no true hierarchies, and there are no data rules. You can type anything here. Be exceedingly careful.
	</p>
	<cfquery name="thisName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select scientific_name from taxon_name where taxon_name_id=#taxon_name_id#
	</cfquery>
	<cfquery name="cttaxonomy_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select source from cttaxonomy_source order by source
	</cfquery>
	<cfquery name="cttaxon_term_noclass" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select taxon_term from cttaxon_term where is_classification=0 order by taxon_term
	</cfquery>
	<cfquery name="cttaxon_term_isclass" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select taxon_term from cttaxon_term where is_classification=1 order by taxon_term
	</cfquery>

	<cfoutput>
		<cfset title="Create Classification for #thisName.scientific_name#">
		<h3>Create Classification for #thisName.scientific_name#</h3>

		<form name="f1" id="f1" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="action" value="saveNewClass">
			<input type="hidden" name="taxon_name_id" id="taxon_name_id" value="#taxon_name_id#">

			<label for="source">Source</label>
			<select name="source" id="source" class="reqdClr">
				<cfloop query="cttaxonomy_source">
					<option value="#source#">#source#</option>
				</cfloop>
			</select>
			<h3>
				Non-Classification Terms
			</h3>
			<p style="font-size:small;">
				These are paired terms; unpaired terms will be ignored. That means you can ignore the defaulted-in suggestions if you want.
			</p>
			<table id="clastbl" border="1">
				<thead>
					<tr>
						<th>
							Term Type
							<a target="_blank" href="/component/functions.cfc?method=ac_noclass_tt&term">[ view all (JSON)]</a>
						</th>
						<th>Term</th>
					</tr>
				</thead>
				<tbody id="notsortable">
					<cfloop from="1" to="10" index="i">
						<tr id="nccell_#i#">
							<td>
								<select  class="ac_noclass_tt" id="ncterm_type_#i#" name="ncterm_type_#i#" onchange="requirePair(#i#);">
									<option value=""></option>
									<cfloop query="cttaxon_term_noclass">
										<option value="#taxon_term#">#taxon_term#</option>
									</cfloop>
								</select>
								<!----
								<input class="ac_noclass_tt" size="60" type="text" id="ncterm_type_#i#" name="ncterm_type_#i#" onchange="requirePair(#i#);">
								---->
							</td>
							<td>
								<input size="60" type="text" id="ncterm_#i#" name="ncterm_#i#" onchange="requirePair(#i#);">
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<h3>
				Classification Terms
			</h3>
			<p style="font-size:small;">
				 Order is important here - "large" (eg, kingdom) at top to "small" (eg, subspecies) at bottom.
				Use as many cells as you need; leave the rest empty.
				 TermType will be ignored if Term is empty. Term will be saved regardless of TermType; unranked terms are OK.
				 Add more via Edit (after you save here) if necessary.
			</p>
			<table id="clastbl" border="1">
				<thead>
					<tr><th>Term Type
					<a target="_blank" href="/component/functions.cfc?method=ac_isclass_tt&term">[ view all (JSON)]</a>
					</th><th>Term</th></tr>
				</thead>
				<tbody id="sortable">
					<cfloop from="1" to="10" index="i">
							<td>
								<select  class="ac_isclass_tt" id="term_type_#i#" name="term_type_#i#">
									<option value=""></option>
									<cfloop query="cttaxon_term_isclass">
										<option value="#taxon_term#">#taxon_term#</option>
									</cfloop>
								</select>

								<!----

								<input size="60" class="ac_isclass_tt" type="text" id="term_type_#i#" name="term_type_#i#">
								---->
							</td>
							<td>
								<input size="60" type="text" id="term_#i#" name="term_#i#" >
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<p>
				<input type="submit" value="Create Classification">
			</p>
		</form>
	</cfoutput>
</cfif>

<!------------------------------------------------------------------->
<cfif action is "editClassification">
<!----= edit: force, don't suggest, using cttaxon_term ---->
	<style>
		.dragger {
			cursor:move;
		}
		.isterm {
			font-weight:bold;
			font-style:italics;
		}
		.warningDiv {color:red;font-size:x-small;}
	</style>
	<script>
		// copy this with create classification
		$(function() {
			$( "#sortable" ).sortable({
				handle: '.dragger'
			});

			guessAtDisplayName();
		});
		function submitForm() {
			var linkOrderData=$("#sortable").sortable('toArray').join(',');
			$( "#classificationRowOrder" ).val(linkOrderData);
			var nccellary = new Array();
			$.each($("tr[id^='nccell_']"), function() {
				nccellary.push(this.id);
		    });
			var ncls=nccellary.join(',');
			$( "#noclassrows" ).val(ncls);
			$( "#f1" ).submit();
		}
		function deleteThis(r) {
			$( "#cell_" + r ).remove();
		}
		function nc_deleteThis(r) {
			$( "#nccell_" + r ).remove();
		}
		function addARow() {
			var n=parseInt($("#maxposn").val());
			++n;
			var x='<tr id="cell_' + n + '">';
			x+='<td class="dragger">(drag row here)</td>';
			x+='<td><select class="ac_isclass_tt" id="term_type_' + n + '" name="term_type_' + n + '" onchange="guessAtDisplayName(this.id)"></select></td>';
			x+='<td><input size="60" type="text" id="term_' + n + '" name="term_' + n + '" onchange="guessAtDisplayName(this.id)"></td>';
			x+='<td><span class="likeLink" onclick="deleteThis(\'' + n + '\');">[ Delete this row ]</span></td>';
			x+='</tr>';
			$("#sortable").append(x);
			$("#maxposn").val(n);
			$('#term_type_1').find('option').clone().appendTo('#term_type_' + n);
			$('#term_type_' + n).val('');
		}
		function nc_addARow() {
			var n=parseInt($("#numnoclassrs").val());
			++n;
			var x='<tr id="nccell_' + n + '">';
			x+='<td><select class="ac_noclass_tt"  id="ncterm_type_' + n + '" name="ncterm_type_' + n + '" onchange="guessAtDisplayName(this.id)"></select></td>';
			x+='<td><input size="60" type="text" id="ncterm_' + n + '" name="ncterm_' + n + '" onchange="guessAtDisplayName(this.id)"></td>';
			x+='<td><span class="likeLink" onclick="nc_deleteThis(\'' + n + '\');">[ Delete this row ]</span></td>';
			x+='</tr>';
			$("#notsortable").append(x);
			$("#numnoclassrs").val(n);
			$('#template_ncterm_type_template').find('option').clone().appendTo('#ncterm_type_' + n);
			$('#ncterm_type_' + n).val('');

		}
		function deleteClassification(cid,tnid) {
			var msg='Are you sure you want to delete this classification?\nDo NOT delete classifications because you do not agree with them or because they';
			msg+=' do not fit your collection or taxonomy preferences.\nDeleted classifications from GlobalNames will come back; fix them at the source.';
			msg+='\nIf you did not create the classification you are trying to delete, you should probably click "cancel" now.';
			var r=confirm(msg);
			if (r==true) {
				document.location='/editTaxonomy.cfm?action=deleteClassification&classification_id=' + cid + '&taxon_name_id=' + tnid;
			}
		}

		function guessAtDisplayName(caller) {
			// if this is being called by an element, check if that element is the value
			// of display_name. If so, just exit. Otherwise, rock on.
			if(caller && caller.substring(0, 2) == "nc") {
				var cary=caller.split('_');
				var theIdInt=cary[cary.length-1];
				var theType=$("#ncterm_type_" + theIdInt).val();
				if (theType == 'display_name'){
					return false;
				}
			}
			var genus; // just so that we can italicize @fallback
			var species;
			var infraspecific_term;
			var infraspecific_rank;
			var speciesauthor;
			var subspeciesauthor;
			var dv_element=""; // element of the term type
			var dv_value=""; // contents of the term
			var dv_value_element=""; // element of the term
			var formatstyle = 'iczn'; // default to simple....
			var formattedname; // with HTML
			var lowestclassificationterm;
			$(":input[name^='ncterm_type_']").each(function() {
				var thisval = $(this).val();
				var relatedElementID=this.id.replace("type_","");
				var relatedElement=$("#" + relatedElementID).val();
				if(thisval == "author_text") {
					speciesauthor=relatedElement;
			    }
				if(thisval == "infraspecific_author") {
					subspeciesauthor=relatedElement;
			    }
				if(thisval == "nomenclatural_code" && relatedElement=='ICBN') {
					formatstyle='icbn';
				}
			});
			// and this point, there should be a display_name and we should know it's ID.
			$(":input[name^='term_type_']").each(function() {
		    	var thisval = $(this).val();
				var relatedElementID=this.id.replace("type_","");
				var relatedElement=$("#" + relatedElementID).val();
				if(thisval == "kingdom" && relatedElement=='Plantae') {
					formatstyle='icbn';
				}
				if(thisval == "species" || thisval == "sp" || thisval == "sp.") {
					species=relatedElement;
				}
				if(thisval == "genus" || thisval == "gen.") {
					genus=relatedElement;
				}
				if(thisval == "subsp." || thisval == "variety" || thisval == "var." || thisval == "varietas" || thisval == "subvar." || thisval == "subspecies") {
					infraspecific_term=relatedElement;
					infraspecific_rank=thisval;
				}
				lowestclassificationterm=relatedElement;
			});
			if (species) {
				formattedname = ' <i>' + species + '</i>';
				if (formatstyle=='icbn'){
					if (speciesauthor) {
						formattedname += ' ' + speciesauthor;
					}
					if (infraspecific_rank) {
						formattedname += ' ' + infraspecific_rank;
					}
					if (infraspecific_term) {
						infraspecific_term=infraspecific_term.replace(species,"").trim();
						infraspecific_term=infraspecific_term.replace(infraspecific_rank,"").trim();
						formattedname += ' <i>' + infraspecific_term + '</i>';
					}
					if (subspeciesauthor) {
						formattedname += ' ' + subspeciesauthor;
					}
				}
				if (formatstyle=='iczn'){
					if (infraspecific_term) {
						infraspecific_term=infraspecific_term.replace(species,"").trim();
						formattedname += ' <i>' + infraspecific_term + '</i>';
					}
					if (speciesauthor) {
						formattedname += ' ' + speciesauthor;
					}
				}
			}
			if (! formattedname) {
				if (genus) {
					formattedname='<i>' + genus + '</i>';
					if (speciesauthor) {
						formattedname += ' ' + speciesauthor;
					}
				} else {
					formattedname=lowestclassificationterm;
				}
			}
			if (formattedname) {
				formattedname=formattedname.replace(/<\/i> <i>/g, ' ').trim();
				$("#dng").val(formattedname);
			}
		}
		function useDNG(){
			var dn=$("#dng").val();
			var idOfDisplayRow;
			$("select").each(function(){
				 if( $(this).val()=='display_name' ){
   				 	idOfDisplayRow=this.id;
   				 }
   			});
			if(typeof idOfDisplayRow === 'undefined'){
				nc_addARow();
				var n=parseInt($("#numnoclassrs").val());
				$('#ncterm_type_' + n).val('display_name');
				idOfDisplayRow='ncterm_type_' + n;
			}
			var vc=idOfDisplayRow.replace('type_','');
			$("#" + vc).val(dn);
		}
		function scrollDNW () {
		    $('html, body').animate({
		        scrollTop: $("#dnWarning").offset().top
		    }, 1000);
		}


	</script>

	<cffunction name="getAppPosn">
		<cfargument name="rank" type="string" required="yes">



		<cfquery name="tt_relp" dbtype="query">
			select relative_position from cttaxon_term where taxon_term='#rank#'
		</cfquery>

		<cfdump var=#tt_relp#>

		<cfquery name="trms" dbtype="query">
			select taxon_term,relative_position from cttaxon_term where is_classification=1 order by relative_position
		</cfquery>

		<!--- find the row in hasclass where the term_type is ranked lower than the passed-in term ---->


		<cfdump var=#trms#>



		<p>
			h
		</p>
		<cfset newPosition=0.001>
		<cfoutput>
		<cfloop query="hasclass">
			<br>#term# == #POSITION_IN_CLASSIFICATION#
			<cfquery name="compRank" dbtype="query">
				select relative_position from cttaxon_term where taxon_term='#TERM_TYPE#'
			</cfquery>

			<cfdump var=#compRank#>

			<cfif compRank.relative_position gt tt_relp.relative_position>
				<br>the new term is ABOVE this one....
				<cfset newPosition=POSITION_IN_CLASSIFICATION - .1>
			</cfif>
		</cfloop>
</cfoutput>
		<p>
			Final result: #newPosition#
		</p>

		<cfquery name="d" dbtype="query">
			select * from d
		</cfquery>
		<cfreturn newPosition>

	</cffunction>

	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				taxon_name.taxon_name_id,
				taxon_name.scientific_name,
				taxon_term.CLASSIFICATION_ID,
				taxon_term.TERM,
				taxon_term.TERM_TYPE,
				taxon_term.SOURCE,
				taxon_term.GN_SCORE,
				taxon_term.POSITION_IN_CLASSIFICATION,
				to_char(taxon_term.LASTDATE,'yyyy-mm-dd') LASTDATE,
				taxon_term.MATCH_TYPE
			from
				taxon_name,
				taxon_term
			where
				taxon_name.taxon_name_id=taxon_term.taxon_name_id and
				classification_id='#classification_id#' and
				taxon_name.taxon_name_id=#taxon_name_id#
			group by
				taxon_name.taxon_name_id,
				taxon_name.scientific_name,
				taxon_term.CLASSIFICATION_ID,
				taxon_term.TERM,
				taxon_term.TERM_TYPE,
				taxon_term.SOURCE,
				taxon_term.GN_SCORE,
				taxon_term.POSITION_IN_CLASSIFICATION,
				to_char(taxon_term.LASTDATE,'yyyy-mm-dd'),
				taxon_term.MATCH_TYPE
		</cfquery>


		<cfquery name="thisname" dbtype="query">
			select
				source,
				scientific_name,
				taxon_name_id
			from
				d
			group by
				source,
				scientific_name,
				taxon_name_id
		</cfquery>

		<cfquery name="noclass" dbtype="query">
			select term_type,term from d where POSITION_IN_CLASSIFICATION is null group by term_type,term order by term_type
		</cfquery>
		<cfquery name="hasclass" dbtype="query">
			select
				term_type,
				term,
				POSITION_IN_CLASSIFICATION,
				'orig' src
			from
				d
			where
				POSITION_IN_CLASSIFICATION is not null
			group by
				term_type,
				term,
				POSITION_IN_CLASSIFICATION
			order by
				POSITION_IN_CLASSIFICATION
		</cfquery>

		<!----------
		<cfquery name="maxclass" dbtype="query">
			select max(POSITION_IN_CLASSIFICATION) m from hasclass
		</cfquery>
		------------->
		<cfquery name="maxnoclass" dbtype="query">
			select count(*) m from noclass
		</cfquery>
		<cfquery name="cttaxon_term" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cttaxon_term
		</cfquery>

		<cfquery name="cttaxon_term_noclass" dbtype="query">
			select taxon_term from cttaxon_term where is_classification=0 order by taxon_term
		</cfquery>
		<cfquery name="cttaxon_term_isclass" dbtype="query">
			select taxon_term from cttaxon_term where is_classification=1 order by relative_position
		</cfquery>
		<cfset pterms=valuelist(cttaxon_term_noclass.taxon_term)>
		<cfset pterms=listappend(pterms,valuelist(cttaxon_term_isclass.taxon_term))>
		<cfset x=ListQualify(valuelist(cttaxon_term.taxon_term),"'")>

		<cfquery name="noct" dbtype="query">
			select distinct term_type,TERM from d where term_type not in
			(#PreserveSingleQuotes(x)#)
		</cfquery>

		<cfif len(noct.term_type) gt 0>
			<div style="border:10px solid red; padding:2em; margin:2em;">
				Caution: The following term(s) are used in this classification and are not
				available from the code table. They will (not) show up as blank cells below
				and may be difficult to distinguish from unranked terms.
				Make sure you know what you're doing before saving!
				Use the contact link in the footer BEFORE saving anything if this is not clear.
				<ul>
					<cfloop query="noct">
						<li>#term_type#=#term#</li>
					</cfloop>
				</ul>
			</div>
		</cfif>

		<p>
			Editing <strong>#thisName.source#</strong> classification for <strong>#thisName.scientific_name#</strong> (classification_id=#classification_id#)
			<cfset title="Edit Classification: #thisName.scientific_name#">
			<br>
			<a href="/name/#thisname.scientific_name#">[ View Taxon Page ]</a>
			<a href="/editTaxonomy.cfm?action=editnoclass&taxon_name_id=#thisname.taxon_name_id#">[ Edit Non-Classification Data ]</a>
			<span class="likeLink" onclick="deleteClassification('#classification_id#','#thisname.taxon_name_id#');">[ Delete Classification ]</span>
		</p>
		<p>
			Important randomness:
			<ul>
				<li>
					<span class="isterm">Species</span> are binomials, not specific epithets: "Poa abbreviata" rather than "abbreviata."
				</li>
				<li>
					ICZN-like subspecific terms (which should with rare exception be <span class="isterm">subspecies</span>) are trinomials:
					"Alces alces shirasi," not "shirasi."
				</li>
				<li>
					ICBN-like subspecific terms (<span class="isterm">subspecies</span>, <span class="isterm">subsp.</span>, <span class="isterm">var.</span>, etc.)
					are ranked trinomials: "Poa abbreviata subsp. jordalii," not "jordalii."
				</li>
				<li>
					There is no enforced order for classification terms. subspecies-->kingdom-->genus is possible. Do not use this
					form if you're not sure of how to correctly order ranked terms. (Why? Usage varies. Animal people think "section" is somewhere
					between order and family, while plant people think it's a subdivision of subgenus.)
				</li>
			</ul>
		</p>
		<form name="f1" id="f1" method="post" action="editTaxonomy.cfm">
			<input type="button" class="savBtn" onclick="submitForm();" value="Save Edits">
			<input type="button" class="lnkBtn" onclick="scrollDNW();" value="See display_name suggestions">
			<input type="hidden" name="action" value="saveClassEdits">
			<input type="hidden" name="classification_id" id="classification_id" value="#classification_id#">
			<input type="hidden" name="taxon_name_id" id="taxon_name_id" value="#thisname.taxon_name_id#">
			<input type="hidden" name="source" id="source" value="#thisname.source#">
			<!------------
			<cfif len(maxclass.m) is 0>
				<cfset mc=0>
			<cfelse>
				<cfset mc=maxclass.m>
			</cfif>
			------------>
			<cfif len(maxnoclass.m) is 0>
				<cfset mc=0>
			<cfelse>
				<cfset mc=maxnoclass.m>
			</cfif>
			<input type="hidden" name="numnoclassrs" id="numnoclassrs" value="#mc#">
			<input type="hidden" name="classificationRowOrder" id="classificationRowOrder">
			<input type="hidden" name="noclassrows" id="noclassrows">
			<select style="display: none"
				id="template_ncterm_type_template">
				<option value=""></option>
				<cfloop query="cttaxon_term_noclass">
					<option value="#taxon_term#">#taxon_term#</option>
				</cfloop>
			</select>
			<h3>
				Non-Classification Terms <span class="likeLink" onclick="getCtDoc('cttaxon_term');">code table</span>
			</h3>
			<p style="font-size:small;font-weight:bold;color:red;">
				These are paired terms; unpaired terms - those with either side blank - will be DELETED.
			</p>
			<table id="clastbl" border="1">
				<thead>
					<tr><th>Term Type</th><th>Term</th><th>Delete</th></tr>
				</thead>
				<tbody id="notsortable">
					<cfset thisrow=1>
					<cfloop query="noclass">
						<tr id="nccell_#thisrow#">
							<td>
								<select
									class="ac_noclass_tt"
									id="ncterm_type_#thisrow#"
									name="ncterm_type_#thisrow#"
									onchange="guessAtDisplayName(this.id)">
									<option value=""></option>
									<cfloop query="cttaxon_term_noclass">
										<option
											<cfif cttaxon_term_noclass.taxon_term is noclass.term_type> selected="selected" </cfif>
											value="#taxon_term#">#taxon_term#</option>
									</cfloop>
								</select>

								<!----
								<input class="ac_noclass_tt" size="60"
								type="text" id="ncterm_type_#thisrow#" name="ncterm_type_#thisrow#"
								value="#term_type#" onchange="guessAtDisplayName(this.id)">
								---->
							</td>
							<td>
								<input size="60" type="text" id="ncterm_#thisrow#" name="ncterm_#thisrow#" value="#stripQuotes(term)#" onchange="guessAtDisplayName(this.id)">
							</td>
							<td>
								<span class="likeLink" onclick="nc_deleteThis('#thisrow#');">[ Delete this row ]</span>
							</td>
						</tr>
						<cfset thisrow=thisrow+1>
					</cfloop>
				</tbody>
			</table>
			<span class="likeLink" onclick="nc_addARow();">[ add a row ]</span>
			<cfset shouldUsuallyHave="display_name,author_text,nomenclatural_code">
			<cfset aterms=valuelist(noclass.TERM_TYPE)>
			<cfloop list="#aterms#" index="i">
				<cfif listfind(shouldUsuallyHave,i)>
					<cfset shouldUsuallyHave=listdeleteat(shouldUsuallyHave,listfind(shouldUsuallyHave,i))>
				</cfif>
			</cfloop>
			<cfif len(shouldUsuallyHave) gt 0>
				<div class="warningDiv">
					Possibly missing:
					<ul>
						<cfloop list="#shouldUsuallyHave#" index="i">
							<li>#i#</li>
						</cfloop>
					</ul>
				</div>
			</cfif>
			<h3>
				Classification Terms <span class="likeLink" onclick="getCtDoc('cttaxon_term');">code table</span>
			</h3>
			<p style="font-size:small;">
				 Order is important here - "large" (eg, kingdom) at top to "small" (eg, subspecies) at bottom. Drag rows to sort.
				 TermType will be ignored if Term is empty. Term will be saved regardless of TermType; unranked terms are OK.
			</p>

			<!--- this must be ordered from "lowest" to "highest"---->

			<!--- see if we have a kingdom. If not, add a blank row for it ---->
			<cfquery name="hasterm" dbtype="query">
				select term from hasclass where term_type='kingdom'
			</cfquery>
			<cfif hasterm.recordcount neq 1>
				<p>
					no kingdom do something
				</p>
			</cfif>
			<!--- see if we have a genus. If not, add a blank row for it ---->
			<cfquery name="hasterm" dbtype="query">
				select term from hasclass where term_type='genus'
			</cfquery>
			<cfif hasterm.recordcount neq 1>
				<p>
					no genus do something
				</p>
			</cfif>
			<!--- see if we have a genus. If not, add a blank row for it ---->
			<cfquery name="hasterm" dbtype="query">
				select term from hasclass where term_type='genus'
			</cfquery>
			<cfif hasterm.recordcount neq 1>
				<p>
					no genus do something (maybe?)
				</p>
			</cfif>
			<!---- see if this looks like a multinomial ---->
			<cfif listlen(thisname.scientific_name,' ') gt 1>
				<p>
					is multinomial
				</p>
				<!--- see if we have a genus. If not, add a blank row for it ---->
				<cfquery name="hasterm" dbtype="query">
					select term from hasclass where term_type='species'
				</cfquery>
				<cfif hasterm.recordcount neq 1>
					<p>
						no species do something
					</p>
				</cfif>
				<!--- >bi-nomial? ---->
				<cfif listlen(thisname.scientific_name,' ') eq 3>
					<!--- looks like animal subspecies ---->
					<cfquery name="hasterm" dbtype="query">
						select term from hasclass where term_type='subspecies'
					</cfquery>
					<cfif hasterm.recordcount neq 1>
						<p>
							no subspecies do something
						</p>
					</cfif>
				<cfelseif listlen(thisname.scientific_name,' ') eq 4>
					<!---- botanical ---->
					<cfif thisname.scientific_name contains "subsp.">
						<p>
							no subspecies do something
						</p>
					<cfelseif thisname.scientific_name contains "var.">

						<p>
							no variety do something #thisname.scientific_name# is suggested variety
						</p>


						<cfset x=getAppPosn('variety')>

						<!--- all other sub-specific terms are almost certainly mis-ranked ---->
						<cf_qoq>
						    UPDATE
						        hasclass
						    SET
						        src='probably_misrank'
						    WHERE
						        term_type='var.'
						</cf_qoq>
						<cf_qoq>
						    UPDATE
						        hasclass
						    SET
						        src='probably_misrank'
						    WHERE
						        term_type='subpsecies'
						</cf_qoq>
						<cf_qoq>
						    UPDATE
						        hasclass
						    SET
						        src='probably_misrank'
						    WHERE
						        term_type='subsp.'
						</cf_qoq>



						<p>
							x: #x#
						</p>
						<!--- get the position_in_classification of the term which ranks higher than variety --->




						<!--- see if it's erroneously listed as something else --->


					<cfelseif thisname.scientific_name contains "f.">
						<p>
							no forma do something
						</p>
					</cfif>

				</cfif>
			</cfif>


<p>

	post-manipulation hasclass dump

	<cfdump var=#hasclass#>

			END
	post-manipulation hasclass dump
</p>
















			<cfset shouldUsuallyHave="scientific_name,subspecies,species,genus,kingdom">

			<!--- get what we have in a structure ---->





			<!--- see what we can glean from what we have ---->

			<cfset probGenus="">
			<cfset probSpecies="">
			<cfset probSubSpecies="">
			<cfset probSciName="">





			<cfquery name="gsciname" dbtype="query">
				select * from hasclass where term_type='scientific_name'
			</cfquery>
			<cfif len(gsciname.term) gt 0>
				<cfset probSciName=gsciname.term>

				<cfset psh.sccientific_name=gsciname.term>

			<cfelse>
				<cfset probSciName=thisname.scientific_name>

				<cfset psh.sccientific_name=thisname.scientific_name>

			</cfif>
			<cfif listlen(thisname.scientific_name,' ') gt 1>
				<!--- looks like species/subspecies ---->
				<cfquery name="gspecies" dbtype="query">
					select * from hasclass where term_type='species'
				</cfquery>
				<cfif len(gspecies.term) gt 0>
					<cfset probSpecies=gspecies.term>


					<cfset psh.species=gspecies.term>

				<cfelse>

					<cfset psh.species=listGetAt(thisname.scientific_name,1,' ') & ' ' & listGetAt(thisname.scientific_name,2,' ')>


					<cfset probSpecies=listGetAt(thisname.scientific_name,1,' ') & ' ' & listGetAt(thisname.scientific_name,2,' ')>
				</cfif>
				<cfif listlen(thisname.scientific_name,' ') gt 2>

					<!--- grab all possible below-species terms, see if something sticks

						valiant idea, but this stuff is all weird and abbreviated and etc.
						probably gonna have to be hard-coded
						yay taxonomic tradition....

						<cfquery name="sprank" dbtype="query">
							select relative_position from cttaxon_term where taxon_term='species'
						</cfquery>

						<cfdump var=#sprank#>
						<cfquery name="belsp" dbtype="query">
							select taxon_term from cttaxon_term where is_classification=1 and relative_position > #sprank.relative_position#
						</cfquery>

						<cfdump var=#belsp#>

					 ---->

					<cfquery name="gsspecies" dbtype="query">
						select * from hasclass where term_type='subspecies'
					</cfquery>

					<cfif len(gsspecies.term) gt 0>
						<cfset probSubSpecies=gsspecies.term>


					<cfset psh.subspecies=gsspecies.term>


					<cfelse>
						<!--- is plant? ---->
						<cfif gsciname.term contains "var.">
							<cfset psh.variety=gsciname.term>
						<cfelseif gsciname.term contains "subsp.">
							<cfset psh.subspecies=gsciname.term>

						</cfif>


						<!--- probably the whole shebang
						<cfset probSubSpecies=listGetAt(thisname.scientific_name,1,' ')	 & ' ' & listGetAt(thisname.scientific_name,2,' ')>
						<cfif listlen(thisname.scientific_name,' ') gt 2>
							<cfset probSubSpecies=probSubSpecies & ' ' &  listGetAt(thisname.scientific_name,3,' ')>
						</cfif>
						---->
						<cfset probSubSpecies=thisname.scientific_name>
					</cfif>
				</cfif>
			</cfif>



			<cfdump var=#hasclass#>




			<!--- if for some crazy reason we got here and don't have genus....---->

			<cfquery name="ggen" dbtype="query">
				select * from hasclass where term_type='genus'
			</cfquery>
			<cfif len(ggen.term) gt 0>
				<cfset probGenus=ggen.term>
			<cfelse>
				<cfset probGenus=listGetAt(thisname.scientific_name,1,' ')>
			</cfif>
			<!--- make a table I can mess with, leave some gaps ---->
			<cfquery name="mClassTerms" dbtype="query">
				select
					POSITION_IN_CLASSIFICATION * 10 POSITION_IN_CLASSIFICATION,
					TERM,
					TERM_TYPE,
					'exist' STATUS
				from
					hasclass
			</cfquery>
			<cfloop list="#shouldUsuallyHave#" index="shouldHaveTermType">
				<cfquery name="ttchk" dbtype="query">
					select * from mClassTerms where TERM_TYPE='#shouldHaveTermType#'
				</cfquery>
				<cfif ttchk.recordcount is 0>
					<!--- get ordered terms starting with what we're looking for ---->
					<cfquery name="thisRelPosn" dbtype="query">
						select relative_position from cttaxon_term where is_classification=1 and taxon_term='#shouldHaveTermType#'
					</cfquery>
					<cfquery name="possNextTerm" dbtype="query">
						select
							taxon_term
						from
							cttaxon_term
						where
							is_classification=1 and
							relative_position >= #thisRelPosn.relative_position#
						order by
							relative_position
					</cfquery>
					<cfset findit=valuelist(possNextTerm.taxon_term)>
					<cfset availablePosition=0>
					<cfloop list="#findit#" index="tt">
						<cfquery name="fnt" dbtype="query">
							select min(POSITION_IN_CLASSIFICATION)  up from mClassTerms where term_type='#tt#'
						</cfquery>
						<cfif fnt.recordcount gt 0>
							<cfset availablePosition=fnt.up>
							<cfloop from="1" to="10" index="l">
								<cfquery name="ckPosn" dbtype="query">
									select * from mClassTerms where POSITION_IN_CLASSIFICATION=#availablePosition#
								</cfquery>
								<cfif ckPosn.recordcount is 0>
									<cfbreak>
								<cfelse>
									<cfset availablePosition=availablePosition-1>
								</cfif>
							</cfloop>
							<cfbreak>
						</cfif>
					</cfloop>
					<!--- if we didn't find anything, it's the so-far largest POSITION_IN_CLASSIFICATION ---->
					<cfif availablePosition is 0>
						<cfquery name="map" dbtype="query">
							select max(POSITION_IN_CLASSIFICATION) +100 ap from mClassTerms
						</cfquery>
						<cfset availablePosition=map.ap>
					</cfif>
					<!---- insert the should-be-there value one place before the next found value ---->
					<!--- use anything we guess at, if we can ---->
					<cfset thisTermVal=''>
					<cfif shouldHaveTermType is "scientific_name" and len(probSciName) gt 0>
						<cfset thisTermVal=probSciName>
					</cfif>
					<cfif shouldHaveTermType is "species" and len(probSpecies) gt 0>
						<cfset thisTermVal=probSpecies>
					</cfif>
					<cfif shouldHaveTermType is "subspecies" and len(probSubSpecies) gt 0>
						<cfset thisTermVal=probSubSpecies>
					</cfif>
					<cfif shouldHaveTermType is "genus" and len(probGenus) gt 0>
						<cfset thisTermVal=probGenus>
					</cfif>
					<cfset queryAddRow(mClassTerms,{
						"POSITION_IN_CLASSIFICATION"="#availablePosition#",
						"TERM_TYPE"="#shouldHaveTermType#",
						"STATUS"="autoins",
						"TERM"="#thisTermVal#"})>
				</cfif>
			</cfloop>
			<!---- now get the ordered stuff ---->
			<cfquery name="orderedClassTermsWithBlanks" dbtype="query">
				select * from mClassTerms where
				CAST(term AS varchar) <> ''  order by position_in_classification
			</cfquery>




			<cfdump var=#psh#>

			<table id="clastbl" border="1">
				<thead>
					<tr><th>Drag Handle</th><th>Term Type</th><th>Term</th><th>Delete</th></tr>
				</thead>
				<tbody id="sortable">
					<cfset thisrowinc=0>
					<cfloop query="orderedClassTermsWithBlanks">
						<!--- increment rowID ---->
						<cfset thisrowinc=thisrowinc+1>
						<tr id="cell_#thisrowinc#">
							<td class="dragger">
								(drag row here)
							</td>
							<td>
								<select	class="ac_isclass_tt"
									id="term_type_#thisrowinc#" name="term_type_#thisrowinc#"
									onchange="guessAtDisplayName(this.id)">
									<option value=""></option>
									<cfloop query="cttaxon_term_isclass">
										<option
											<cfif cttaxon_term_isclass.taxon_term is orderedClassTermsWithBlanks.term_type> selected="selected" </cfif>
											value="#taxon_term#">#taxon_term#</option>
									</cfloop>
								</select>
							</td>
							<td	<cfif orderedClassTermsWithBlanks.status is "autoins" >
									class="importantNotification"
								</cfif>>
								<input size="60" type="text" id="term_#thisrowinc#" name="term_#thisrowinc#" value="#orderedClassTermsWithBlanks.term#" onchange="guessAtDisplayName(this.id)">
							</td>
							<td>
								<span class="likeLink" onclick="deleteThis('#thisrowinc#');">[ Delete this row ]</span>
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<span class="likeLink" onclick="addARow();">[ add a row ]</span>
			<cfset aterms=valuelist(hasclass.TERM_TYPE)>
			<cfloop list="#aterms#" index="i">
				<cfif listfind(shouldUsuallyHave,i)>
					<cfset shouldUsuallyHave=listdeleteat(shouldUsuallyHave,listfind(shouldUsuallyHave,i))>
				</cfif>
			</cfloop>
			<cfif len(shouldUsuallyHave) gt 0>
				<div class="warningDiv">
					Possibly missing:
					<ul>
						<cfloop list="#shouldUsuallyHave#" index="i">
							<li>#i#</li>
						</cfloop>
					</ul>
				</div>
			</cfif>
			<p>
				<div id="dnWarning" style="border:2px solid red;padding:2em;margin:2em;">
					<ul>
						<li>
							IMPORTANT!! Each classification should generally have a (one!) non-classification term
							"display_name" with corresponding HTML-formatted, discipline-specific value,
							including authors, infraspecific rank, etc. This is stored in FLAT.FORMATTED_SCIENTIFIC_NAME and used on many forms and
							labels. This suggestion is based on other data, including kingdom, nomenclatural_code, genus, species,
							"subspecies" (including var., forma, etc.), infraspecific rank (such as var., forma, etc.), and infraspecific_author.
							<strong>Bad suggestions here are an indication of missing or malformed data.</strong>
							<label for="dng">Our guess at display_name</label>
							<input id="dng" size="80">
							<input type="button" class="lnkBtn" onclick="useDNG();" value="Use this suggestion">
							<input type="button" class="lnkBtn" onclick="guessAtDisplayName();" value="Refresh suggestion">
						</li>
						<li>
							Red borders around classification terms indicate suspected important missing data, and may
							include suggested values;
							review them and anything their insertion may have misplaced very carefully before saving.
						</li>
					</ul>
				</div>
				<!--- needs to live somewhere after thisrowinc is set and not where it can mess with the flaky JS that is sortable ---->
				<input type="hidden" name="maxposn" id="maxposn" value="#thisrowinc#">
				<input type="button"  class="savBtn" onclick="submitForm();" value="Save Edits">
			</p>
			<p>
				If you haven't yet saved, you can <a href="/editTaxonomy.cfm?action=editClassification&classification_id=#classification_id#">refresh this page</a>
			</p>
		</form>
	</cfoutput>
</cfif>
<!------------------------------------->
<cfif action is "deleteClassification">
	<cfoutput>
		<cfquery name="deleteallclassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from taxon_term where classification_id='#classification_id#'
		</cfquery>
	</cfoutput>
	<cflocation url="/taxonomy.cfm?TAXON_NAME_ID=#TAXON_NAME_ID#" addtoken="false">
</cfif>
<!------------------------------------->
<cfif action is "saveClassEdits">
	<cfoutput>
		<cftransaction>
			<!---- clear everything out, start over - just easier this way ---->
			<cfquery name="deleteallclassification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from taxon_term where classification_id='#classification_id#'
			</cfquery>
			<!---- these are in no particular order but some may be missing ---->
			<cfloop from="1" to="#listlen(noclassrows)#" index="listpos">
				<cfset x=listgetat(noclassrows,listpos)>
				<cfset i=listlast(x,"_")>
				<cfset thisterm=evaluate("NCTERM_" & i)>
				<cfset thistermtype=evaluate("NCTERM_TYPE_" & i)>
				<!---- just ignore non-paired terms ---->
				<cfif len(thisterm) gt 0 and len(thistermtype) gt 0>


					<cfquery name="insNCterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into taxon_term (
							TAXON_NAME_ID,
							CLASSIFICATION_ID,
							TERM,
							TERM_TYPE,
							SOURCE,
							LASTDATE
						) values (
							#TAXON_NAME_ID#,
							'#CLASSIFICATION_ID#',
							'#thisterm#',
							'#thistermtype#',
							'#SOURCE#',
							sysdate
						)
					</cfquery>
				</cfif>
			</cfloop>
			<!--- these MUST be saved in the order they were drug to -------->
			<cfloop from="1" to="#listlen(CLASSIFICATIONROWORDER)#" index="listpos">
				<cfset x=listgetat(CLASSIFICATIONROWORDER,listpos)>
				<cfset i=listlast(x,"_")>
				<cfset thisterm=evaluate("TERM_" & i)>
				<cfset thistermtype=evaluate("TERM_TYPE_" & i)>
				<cfif len(thisterm) gt 0>
					<cfquery name="insCterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into taxon_term (
							TAXON_NAME_ID,
							CLASSIFICATION_ID,
							TERM,
							TERM_TYPE,
							SOURCE,
							LASTDATE,
							POSITION_IN_CLASSIFICATION
						) values (
							#TAXON_NAME_ID#,
							'#CLASSIFICATION_ID#',
							'#thisterm#',
							'#thistermtype#',
							'#SOURCE#',
							sysdate,
							#listpos#
						)
					</cfquery>
				</cfif>
			</cfloop>
		</cftransaction>
		<cflocation url="/editTaxonomy.cfm?action=editClassification&TAXON_NAME_ID=#TAXON_NAME_ID#&classification_id=#classification_id#" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveEditScientificName">
<cfoutput>
<cftransaction>
	<cfquery name="edTaxa" datasource="user_login" username='#session.username#' password="#decrypt(session.epw,session.sessionKey)#">
	UPDATE taxon_name SET scientific_name='#scientific_name#' where taxon_name_id=#taxon_name_id#
	</cfquery>
	</cftransaction>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newTaxonPub">
	<cfquery name="newTaxonPub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO taxonomy_publication (taxon_name_id,publication_id)
		VALUES (#taxon_name_id#,#new_publication_id#)
	</cfquery>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "removePub">
	<cfquery name="removePub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from taxonomy_publication where taxonomy_publication_id=#taxonomy_publication_id#
	</cfquery>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newTaxaRelation">
<cfoutput>
	<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO taxon_relations (
			 TAXON_NAME_ID,
			 RELATED_TAXON_NAME_ID,
			 TAXON_RELATIONSHIP,
			 RELATION_AUTHORITY
		  )	VALUES (
			#TAXON_NAME_ID#,
			 #newRelatedId#,
			 '#TAXON_RELATIONSHIP#',
		 	'#RELATION_AUTHORITY#'
		)
	</cfquery>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveRelnEdit">
<cfoutput>
<cfquery name="edRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	UPDATE taxon_relations SET
		taxon_relationship = '#taxon_relationship#',
		related_taxon_name_id = #related_taxon_name_id#,
		relation_authority = '#relation_authority#'
	WHERE
		taxon_relations_id = #taxon_relations_id#
</cfquery>
<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "deleReln">
<cfoutput>
<cfquery name="deleReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	DELETE FROM
		taxon_relations
	WHERE
		taxon_relations_id = #taxon_relations_id#
		</cfquery>
		<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveCommon">
<cfoutput>
	<cfloop list="#structKeyList(form)#" index="key">
		<cfif left(key,11) is "COMMON_NAME">
			<cfset thisCommonNameID=listlast(key,"_")>
			<cfset thisCommonName=form["COMMON_NAME_#thisCommonNameID#"]>
			<cfif left(thisCommonNameID,3) is "new">
				<cfif len(thisCommonName) gt 0>
					<cfquery name="nwcommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into common_name(TAXON_NAME_ID,COMMON_NAME) values (#TAXON_NAME_ID#,'#escapeQuotes(thisCommonName)#')
					</cfquery>
				</cfif>
			<cfelse>
				<cfif len(thisCommonName) gt 0>
					<cfquery name="ucommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update common_name set common_name='#escapeQuotes(thisCommonName)#' where common_name_id=#thisCommonNameID#
					</cfquery>
				<cfelse>
					<cfquery name="dcommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						delete from common_name where common_name_id=#thisCommonNameID#
					</cfquery>
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	<cflocation url="editTaxonomy.cfm?Action=editnoclass&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>

<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveNewName">
<cfoutput>
	<cfquery name="saveNewName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO taxon_name (TAXON_NAME_ID,SCIENTIFIC_NAME) VALUES (sq_TAXON_NAME_ID.nextval,'#scientific_name#')
	</cfquery>
	<br>
	<cflocation url="/name/#SCIENTIFIC_NAME#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newName">
	<p>Use this form to create "namestrings."</p>
	<p>
		"Namestrings" are (more or less) formal taxa produced by publication. "Sorex cinereus" is a namestring. "Sorex sp." and "Sorex sp. nov. 41" are not.
		Namestrings are rankless - "Animalia" is acceptable. Namestrings are not tied to singular classifications - namestring "Diptera" refers to
		insects and plants and no duplication is necessary.
	</p>
	<p>
		Make sure you've searched before using this form. Errors make us nervous....
	</p>
	<p>
		When you successfully create a namestring here, you'll be redirected to the main taxonomy page, where you can
		<ul>
			<li>Pull information from GlobalNames, and then clone those into other classifications if necessary.</li>
			<li>"Edit non-classification data" to create relationships, common names, etc.</li>
			<li>Manually create classifications and non-classificatoin metadata</li>
		</ul>
	</p>
	<p>
		If you want to bring an Arctos classification over, use your back button, find a similar name, and then "clone classification into new name."
	</p>
	<form name="name" method="post" action="editTaxonomy.cfm">
		<input type="hidden" name="action" value="saveNewName">
		<label for="scientific_name">Scientific Name</label>
		<input type="text" id="scientific_name" name="scientific_name" size="80">
		<input type="submit" value="Create Name" class="insBtn">
	</form>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "editnoclass">
	<script>
		function deleteCommon(i){
			$("#common_name_" + i).val('');
		}
		function addCommonName(){
			var cid=$("#newCommonNames input:last").attr("id");
			var nid=parseInt(cid.replace('common_name_new','')) + 1;
			var h='<div><input placeholder="new common name" type="text" id="common_name_new' + nid + '" name="common_name_new' + nid + '" size="50">';
			h+='<span class="infoLink" onclick="deleteCommon(\'new'+nid+'\');">delete</span></div>';
			$("#" + cid).parent().after(h);
		}

	</script>
	<cfoutput>
		<cfquery name="thisname" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select scientific_name  from taxon_name where taxon_name_id=#taxon_name_id#
		</cfquery>
		<cfset title="Edit non-classification data for #thisname.scientific_name#">
		<p>Editing non-classification data for <strong><em>#thisname.scientific_name#</em></strong></p>
		<br><a href="/name/#thisname.scientific_name#">Return to taxon overview</a> to edit classifications

		<form name="name" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
			<input type="hidden" name="action" value="saveEditScientificName">
			<label for="scientific_name">Scientific Name</label>
			<input type="text" id="scientific_name" name="scientific_name" value="#thisname.scientific_name#" size="80">
			<input type="submit" value="Save Change" class="savBtn">
		</form>
		<cfquery name="ctRelation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select taxon_relationship from cttaxon_relation order by taxon_relationship
		</cfquery>
		<cfquery name="tax_pub" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				taxonomy_publication_id,
				short_citation,
				taxonomy_publication.publication_id
			from
				taxonomy_publication,
				publication
			where
				taxonomy_publication.publication_id=publication.publication_id and
				taxonomy_publication.taxon_name_id=#taxon_name_id#
		</cfquery>
		<cfset i = 1>
		<span class="likeLink" onClick="getDocs('taxonomy','taxonomy_publication');">Related Publications</span>
			<form name="newPub" method="post" action="editTaxonomy.cfm">
				<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
				<input type="hidden" name="Action" value="newTaxonPub">
				<input type="hidden" name="new_publication_id" id="new_publication_id">
				<label for="new_pub">Pick Publication</label>
				<input type="text" id="newPub" onchange="getPublication(this.id,'new_publication_id',this.value,'newPub')" size="80">
				<input type="submit" value="Add Publication" class="insBtn">
			</form>
			<cfif tax_pub.recordcount gt 0>
				<ul>
			</cfif>
			<cfloop query="tax_pub">
				<li>
					#short_citation#
					<ul>
						<li>
							<a href="editTaxonomy.cfm?action=removePub&taxonomy_publication_id=#taxonomy_publication_id#&taxon_name_id=#taxon_name_id#">[ remove ]</a>
						</li>
						<li>
							<a href="/SpecimenUsage.cfm?publication_id=#publication_id#">[ details ]</a>
						</li>
					</ul>
				</li>
			</cfloop>
			<cfif tax_pub.recordcount gt 0>
				</ul>
			</cfif>
		</table>
		<cfquery name="relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				taxon_relations_id,
				scientific_name,
				taxon_relationship,
				relation_authority,
				related_taxon_name_id
			FROM
				taxon_relations,
				taxon_name
			WHERE
				taxon_relations.related_taxon_name_id = taxon_name.taxon_name_id
				AND taxon_relations.taxon_name_id = #taxon_name_id#
		</cfquery>
		<cfset i = 1>
		<span class="likeLink" onClick="getDocs('taxonomy','taxon_relations');">Related Taxa:</span>
		<table border="1">
			<tr>
				<th>Relationship</th>
				<th>Related Taxa</th>
				<th>Authority</th>
			</tr>
			<form name="newRelation" method="post" action="editTaxonomy.cfm">
				<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
				<input type="hidden" name="action" value="newTaxaRelation">
				<tr class="newRec">
					<td>
						<label for="taxon_relationship">Add Relationship</label>
						<select name="taxon_relationship" size="1" class="reqdClr">
							<cfloop query="ctRelation">
								<option value="#ctRelation.taxon_relationship#">#ctRelation.taxon_relationship#</option>
							</cfloop>
						</select>
					</td>
					<td>
						<input type="text" name="relatedName" class="reqdClr" size="50"
							onChange="taxaPick('newRelatedId','relatedName','newRelation',this.value); return false;"
							onKeyPress="return noenter(event);">
						<input type="hidden" name="newRelatedId">
					</td>
					<td>
						<input type="text" name="relation_authority">
					</td>
					<td>
						<input type="submit" value="Create" class="insBtn">
		   			</td>
				</tr>
			</form>
			<cfloop query="relations">
				<form name="relation#i#" method="post" action="editTaxonomy.cfm">
					<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
					<input type="hidden" name="taxon_relations_id" value="#taxon_relations_id#">
					<input type="hidden" name="action">
					<input type="hidden" name="related_taxon_name_id" value="#related_taxon_name_id#">
					<tr>
						<td>
							<select name="taxon_relationship" size="1" class="reqdClr">
								<cfloop query="ctRelation">
									<option <cfif ctRelation.taxon_relationship is relations.taxon_relationship>
										selected="selected" </cfif>value="#ctRelation.taxon_relationship#">#ctRelation.taxon_relationship#
									</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="text" name="relatedName" class="reqdClr" size="50" value="#relations.scientific_name#"
								onChange="taxaPick('related_taxon_name_id','relatedName','relation#i#',this.value); return false;"
								onKeyPress="return noenter(event);">
						</td>
						<td>
							<input type="text" name="relation_authority" value="#relations.relation_authority#">
						</td>
						<td>
							<input type="button" value="Save" class="savBtn" onclick="relation#i#.action.value='saveRelnEdit';submit();">
							<input type="button" value="Delete" class="delBtn" onclick="relation#i#.action.value='deleReln';confirmDelete('relation#i#');">
						</td>
					</tr>
				</form>
				<cfset i = i+1>
			</cfloop>
		</table>
		<cfquery name="common" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				common_name,
				common_name_id
			from common_name where taxon_name_id = #taxon_name_id#
			order by common_name
		</cfquery>
		<span class="likeLink" onClick="getDocs('taxonomy','common_names');">Common Names</span>
		<form name="commonname" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
			<input type="hidden" name="action" value="saveCommon">
			<cfloop query="common">
				<div>
					<input placeholder="common name" type="text" id="common_name_#common_name_id#" name="common_name_#common_name_id#" value="#common_name#" size="50">
					<span class="infoLink" onclick="deleteCommon(#common_name_id#);">delete</span>
				</div>
			</cfloop>
			<div id="newCommonNames" class="newRec">
				<div class="likeLink" onclick="addCommonName()">Add a Row</div>
				<div>
					<input placeholder="new common name" type="text" id="common_name_new1" name="common_name_new1" size="50">
					<span class="infoLink" onclick="deleteCommon('new1');">delete</span>
				</div>
			</div>
			<br><input type="submit" value="save common name changes">
		</form>
	</cfoutput>
</cfif>
<cfinclude template="includes/_footer.cfm">