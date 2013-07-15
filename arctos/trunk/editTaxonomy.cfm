<cfinclude template="includes/_header.cfm">
<cfif action is "editClassification">
	<style>
		.dragger {
			cursor:move;
		}
	</style>
	<script>
		$(function() {
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
			x+='<td><input size="60" class="ac_isclass_tt" type="text" id="term_type_' + n + '" name="term_type_' + n + '"></td>';
			x+='<td><input size="60" type="text" id="term_' + n + '" name="term_' + n + '"></td>';
			x+='<td><span class="likeLink" onclick="deleteThis(\'' + n + '\');">[ Delete this row ]</span></td>';
			x+='</tr>';
			$("#sortable").append(x);
			$("#maxposn").val(n);
		}
		function nc_addARow() {
			var n=parseInt($("#numnoclassrs").val());
			++n;
			var x='<tr id="nccell_' + n + '">';
			x+='<td><input class="ac_noclass_tt" size="60" type="text" id="ncterm_type_' + n + '" name="ncterm_type_' + n + '"></td>';
			x+='<td><input size="60" type="text" id="ncterm_' + n + '" name="ncterm_' + n + '"></td>';
			x+='<td><span class="likeLink" onclick="nc_deleteThis(\'' + n + '\');">[ Delete this row ]</span></td>';
			x+='</tr>';
			$("#notsortable").append(x);
			$("#numnoclassrs").val(n);
		}
	</script>
	<cfoutput>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from taxon_name,taxon_term where 
			taxon_name.taxon_name_id=taxon_term.taxon_name_id and
			classification_id='#classification_id#'
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
			select * from d where POSITION_IN_CLASSIFICATION is null order by term_type
		</cfquery>
		<cfquery name="hasclass" dbtype="query">
			select * from d where POSITION_IN_CLASSIFICATION is not null order by  POSITION_IN_CLASSIFICATION
		</cfquery>		
		<cfquery name="maxclass" dbtype="query">
			select max(POSITION_IN_CLASSIFICATION) m from hasclass
		</cfquery>
		<cfquery name="maxnoclass" dbtype="query">
			select count(*) m from noclass
		</cfquery>
		<p>
			Editing <strong>#thisName.source#</strong> classification for <strong>#thisName.scientific_name#</strong> (classification_id=#classification_id#)
			<br><a href="/editTaxonomy.cfm?action=editnoclass&taxon_name_id=#thisname.taxon_name_id#">Edit Non-Classification Data</a>
			<br><a href="/name/#thisname.scientific_name#">View Taxon Page</a>
		</p>
		<p>
			<strong>Firm Rules About These Data:</strong>
			<br>There are none. You can mess this up for everyone. Please don't.
		</p>
		<p>
			<strong>Guidelines for editing these data:</strong>
			<br>You should probably only edit classifications whose source is set as your collection's preferred classification.
			<br>Term Type will autosuggest. Just hit ESCAPE to type in new values. Be extra cautious if you are creating new values, and 
			new values may take an hour or so to get into the autosuggest list.
			<br>Term "display_value" should include HTML markup.
			<ul>
				<li>&lt;i&gt;Alces alces&lt;/i&gt; (Linnaeus, 1758)</li>
				will display as
				<li><i>Alces alces</i> (Linnaeus, 1758)</li>
			</ul>
		</p>
		
		<form name="f1" id="f1" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="action" value="saveClassEdits">
			<input type="hidden" name="classification_id" id="classification_id" value="#classification_id#">
			<input type="hidden" name="taxon_name_id" id="taxon_name_id" value="#thisname.taxon_name_id#">
			<input type="hidden" name="source" id="source" value="#thisname.source#">
			<input type="hidden" name="maxposn" id="maxposn" value="#maxclass.m#">
			<input type="hidden" name="numnoclassrs" id="numnoclassrs" value="#maxnoclass.m#">
			<input type="hidden" name="classificationRowOrder" id="classificationRowOrder">
			<input type="hidden" name="noclassrows" id="noclassrows">
			<label for="clastbl">Edit Non-Classification information</label>
			<table id="clastbl" border="1">
				<thead>
					<tr><th>Term Type</th><th>Term</th><th>Delete</th></tr>
				</thead>
				<tbody id="notsortable">
					<cfset i=1>
					<cfloop query="noclass">
						<tr id="nccell_#i#">
							<td>
								<input class="ac_noclass_tt" size="60" type="text" id="ncterm_type_#i#" name="ncterm_type_#i#" value="#term_type#">
							</td>
							<td>
								<input size="60" type="text" id="ncterm_#i#" name="ncterm_#i#" value="#term#">
							</td>
							<td>
								<span class="likeLink" onclick="nc_deleteThis('#i#');">[ Delete this row ]</span>
							</td>
						</tr>
						<cfset i=i+1>
					</cfloop>
				</tbody>
			</table>
			<span class="likeLink" onclick="nc_addARow();">Add a Row</span>
			<p>&nbsp;</p>
			<label for="clastbl">Edit Classification: Drag rows to sort.</label>
			<table id="clastbl" border="1">
				<thead>
					<tr><th>Drag Handle</th><th>Term Type</th><th>Term</th><th>Delete</th></tr>
				</thead>
				<tbody id="sortable">
					<cfloop query="hasclass">
						<tr id="cell_#POSITION_IN_CLASSIFICATION#">
							<td class="dragger">
								(drag row here)
							</td>
							<td>
								<input size="60" class="ac_isclass_tt" type="text" id="term_type_#POSITION_IN_CLASSIFICATION#" name="term_type_#POSITION_IN_CLASSIFICATION#" value="#term_type#">
							</td>
							<td>
								<input size="60" type="text" id="term_#POSITION_IN_CLASSIFICATION#" name="term_#POSITION_IN_CLASSIFICATION#" value="#term#">
							</td>
							<td>
								<span class="likeLink" onclick="deleteThis('#POSITION_IN_CLASSIFICATION#');">[ Delete this row ]</span>
							</td>
						</tr>
					</cfloop>
				</tbody>
			</table>
			<span class="likeLink" onclick="addARow();">Add a Row</span>
			<p>
				<input type="button" onclick="submitForm();" value="Save Edits">
			</p>
			<p>
				If you haven't yet saved, you can <a href="/editTaxonomy.cfm?action=editClassification&classification_id=#classification_id#">refresh this page</a>
			</p>
		</form>
	</cfoutput>
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
			</cfloop>
			<!--- these MUST be saved in the order they were drug to -------->
			<cfloop from="1" to="#listlen(CLASSIFICATIONROWORDER)#" index="listpos">
				<cfset x=listgetat(CLASSIFICATIONROWORDER,listpos)>
				<cfset i=listlast(x,"_")>
				<cfset thisterm=evaluate("TERM_" & i)>
				<cfset thistermtype=evaluate("TERM_TYPE_" & i)>
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
			</cfloop>
		</cftransaction>
		<cflocation url="/editTaxonomy.cfm?action=editClassification&classification_id=#classification_id#" addtoken="false">
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
<cfif action is "editnoclass">
	<cfoutput>		
		<cfquery name="thisname" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select scientific_name  from taxon_name where taxon_name_id=#taxon_name_id#
		</cfquery>
		
		<p>Editing non-classification data for <strong><em>#thisname.scientific_name#</em></strong></p>
		<br><a href="/name/#thisname.scientific_name#">Return to taxon overview</a>
		
		<form name="name" method="post" action="editTaxonomy.cfm">
			<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
			<input type="hidden" name="action" value="saveEditScientificName">
			<label for="scientific_name">Scientific Name</label>
			<input type="text" id="scientific_name" name="scientific_name" value="#thisname.scientific_name#" size="80">
			<input type="submit" value="Save Change">
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
				scientific_name, 
				taxon_relationship,
				relation_authority,
				related_taxon_name_id
			FROM 
				taxon_relations,
				taxonomy
			WHERE
				taxon_relations.related_taxon_name_id = taxonomy.taxon_name_id 
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
				<input type="hidden" name="Action" value="newTaxaRelation">
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
				<form name="relation#i#" method="post" action="Taxonomy.cfm">
					<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
					<input type="hidden" name="Action">
					<input type="hidden" name="related_taxon_name_id" value="#related_taxon_name_id#">
					<input type="hidden" name="origTaxon_Relationship" value="#taxon_relationship#">
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
								onChange="taxaPick('newRelatedId','relatedName','relation#i#',this.value); return false;"
								onKeyPress="return noenter(event);">
							<input type="hidden" name="newRelatedId">
						</td>
						<td>
							<input type="text" name="relation_authority" value="#relations.relation_authority#">
						</td>
						<td>
							<input type="button" value="Save" class="savBtn" onclick="relation#i#.Action.value='saveRelnEdit';submit();">	
							<input type="button" value="Delete" class="delBtn" onclick="relation#i#.Action.value='deleReln';confirmDelete('relation#i#');">
						</td>
					</tr>
				</form>
				<cfset i = #i#+1>
			</cfloop>
		</table>
		<cfquery name="common" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select common_name from common_name where taxon_name_id = #taxon_name_id#
		</cfquery>
		<span class="likeLink" onClick="getDocs('taxonomy','common_names');">Common Names</span>
		<cfset i=1>
		<cfloop query="common">
			<form name="common#i#" method="post" action="Taxonomy.cfm">
				<input type="hidden" name="Action">
				<input type="hidden" name="origCommonName" value="#common_name#">
				<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
				<input type="text" name="common_name" value="#common_name#" size="50">
				<input type="button" value="Save" class="savBtn" onClick="common#i#.Action.value='saveCommon';submit();">	
		   		<input type="button" value="Delete" class="delBtn" onClick="common#i#.Action.value='deleteCommon';confirmDelete('common#i#');">
			</form>
			<cfset i=i+1>
		</cfloop>
		<table class="newRec">
			<tr>
				<td>
					<form name="newCommon" method="post" action="Taxonomy.cfm">
						<input type="hidden" name="Action" value="newCommon">
						<input type="hidden" name="taxon_name_id" value="#taxon_name_id#">
						<label for="common_name">New Common Name</label>
						<input type="text" name="common_name" size="50">
						<input type="submit" value="Create" class="insBtn">	
					</form>
				</td>
			</tr>
		</table>
	</cfoutput>
</cfif>


<!------------
<cfquery name="ctInfRank" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select infraspecific_rank from ctinfraspecific_rank order by infraspecific_rank
</cfquery>
<cfquery name="ctSourceAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select source_authority from CTTAXONOMIC_AUTHORITY order by source_authority
</cfquery>
<cfquery name="ctnomenclatural_code" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select nomenclatural_code from ctnomenclatural_code order by nomenclatural_code
</cfquery>
<cfquery name="cttaxon_status" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select taxon_status from cttaxon_status order by taxon_status
</cfquery>
<cfset title="Edit Taxonomy">
<style>
	.warning{border:5px solid red;}
</style>
<script>
	window.setInterval(chkTax, 1000);
	function chkTax(){
		if ($("#nomenclatural_code").val()=='unknown'){
			$("#nomenclatural_code").addClass('warning');
		} else {
			$("#nomenclatural_code").removeClass('warning');
		}
		if ($("#kingdom").val()==''){
			$("#kingdom").addClass('warning');
		} else {
			$("#kingdom").removeClass('warning');
		}
	}
</script>
<!------------------------------------------------>
<cfif action is "nothing">
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="TaxonomySearch.cfm">
	<cfabort>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "edit">
	<cfset title="Edit Taxonomy">
	<cfquery name="getTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from taxonomy where taxon_name_id=#taxon_name_id#
	</cfquery>
<cfoutput>
	<span style="font-size:large;font-weight:bold">Edit Taxonomy: <em>#getTaxa.scientific_name#</em></span>
	<span class="infoLink" onClick="getDocs('taxonomy');">What's this?</span>
	<a class="infoLink" href="/name/#getTaxa.scientific_name#">Detail Page</a>
    <table border>
	<form name="taxa" method="post" action="Taxonomy.cfm">
    	<input type="hidden" name="taxon_name_id" value="#getTaxa.taxon_name_id#">
        <input type="hidden" name="Action">
		<tr>
			<td>
				<label for="source_authority">
					<span class="likeLink" onClick="getDocs('taxonomy','source_authority');">Source</span>
				</label>
				<select name="source_authority" id="source_authority" size="1"  class="reqdClr">
		             <cfloop query="ctSourceAuth">
		               <option <cfif gettaxa.source_authority is ctsourceauth.source_authority> selected="selected" </cfif>
							value="#ctSourceAuth.source_authority#">#ctSourceAuth.source_authority#</option>
		             </cfloop>
		        </select>
			</td>
			<td>
				<label for="valid_catalog_term_fg"><span class="likeLink" onClick="getDocs('taxonomy','valid_term');">ValidForCatalog?</span></label>
				<select name="valid_catalog_term_fg" id="valid_catalog_term_fg" size="1" class="reqdClr">
			    	<option <cfif getTaxa.valid_catalog_term_fg is "1"> selected="selected" </cfif> value="1">yes</option>
			        <option <cfif getTaxa.valid_catalog_term_fg is "0"> selected="selected" </cfif> value="0">no</option>
			    </select>
			</td>
		</tr>
      	<tr>
			<td>
				<label for="nomenclatural_code"><span class="likeLink" onClick="getDocs('taxonomy','nomenclatural_code');">Nomenclatural Code</span></label>
				<select name="nomenclatural_code" id="nomenclatural_code" size="1" class="reqdClr">
			    	<cfloop query="ctnomenclatural_code">
			        	<option <cfif gettaxa.nomenclatural_code is ctnomenclatural_code.nomenclatural_code> selected="selected" </cfif>
			            	value="#ctnomenclatural_code.nomenclatural_code#">#ctnomenclatural_code.nomenclatural_code#</option>
			        </cfloop>
				</select>
			</td>
			<td>
				<label for="genus">Genus <span class="likeLink" onClick="taxa.genus.value='&##215;' + taxa.genus.value;">Add &##215;</span></label>
				<input size="25" name="genus" id="genus" maxlength="40" value="#gettaxa.genus#">
			</td>
		</tr>
		<tr>
			<td>
				<label for="species">Species <span class="likeLink" 
					onClick="taxa.species.value='&##215;' + taxa.species.value;">Add &##215;</span></label>
				<input size="25" name="species" id="species" maxlength="40" value="#gettaxa.species#">
			</td>
			<td>
				<label for="author_text"><span class="likeLink" onClick="getDocs('taxonomy','author_text');">Species Author</span></label>
				<input type="text" name="author_text" id="author_text" value="#gettaxa.author_text#" size="30">
				<span class="infoLink" 
					onclick="window.open('/picks/KewAbbrPick.cfm?tgt=author_text','picWin','width=700,height=400, resizable,scrollbars')">
					Find Kew Abbr
				</span>
			</td>
		</tr>
		<tr>
			<td>
				<label for="infraspecific_rank"><span class="likeLink" onClick="getDocs('taxonomy','infraspecific_rank');">Infraspecific Rank</span></label>
				<select name="infraspecific_rank" id="infraspecific_rank" size="1">
                	<option value=""></option>
	                <cfloop query="ctInfRank">
	                  <option 
							<cfif gettaxa.infraspecific_rank is ctinfrank.infraspecific_rank> selected="selected" </cfif>value="#ctInfRank.infraspecific_rank#">#ctInfRank.infraspecific_rank#</option>
	                </cfloop>
              	</select>
			</td>
			<td>
				<label for="taxon_status"><span class="likeLink" onClick="getDocs('taxonomy','taxon_status');">Taxon Status</span></label>
				<select name="taxon_status" id="taxon_status" size="1">
			    	<option value=""></option>
			    	<cfloop query="cttaxon_status">
			        	<option <cfif gettaxa.taxon_status is cttaxon_status.taxon_status> selected="selected" </cfif>
			            	value="#cttaxon_status.taxon_status#">#cttaxon_status.taxon_status#</option>
			        </cfloop>
				</select>
				<span class="infoLink" onclick="getCtDoc('cttaxon_status');">Define</span>
			</td>
		</tr>
		<tr>
			<td>
				<label for="subspecies">Subspecies</label>
				<input size="25" name="subspecies" id="subspecies" maxlength="40" value="#gettaxa.subspecies#">
			</td>
			<td>
				<label for="author_text"><span class="likeLink" onClick="getDocs('taxonomy','infraspecific_author');">
					Infraspecific Author</span></label>
				<input type="text" name="infraspecific_author" id="infraspecific_author" value="#gettaxa.infraspecific_author#" size="30">
				<span class="infoLink" 
					onclick="window.open('/picks/KewAbbrPick.cfm?tgt=infraspecific_author','picWin','width=700,height=400, resizable,scrollbars')">
						Find Kew Abbr
					</span>
			</td>
		</tr>
		<tr>
			<td>
				<label for="kingdom">Kingdom</label>
				<input type="text" name="kingdom" id="kingdom" value="#gettaxa.kingdom#" size="30">
			</td>
			<td>
				<label for="phylum">Phylum</label>
				<input type="text" name="phylum" id="phylum" value="#gettaxa.phylum#" size="30">
			</td>
		</tr>
		<tr>
			<td>
				<label for="phylclass">Class</label>
				<input type="text" name="phylclass" id="phylclass" value="#gettaxa.phylclass#" size="30">
			</td>
			<td>
				<label for="subclass">SubClass</label>
				<input type="text" name="subclass" id="subclass" value="#gettaxa.subclass#" size="30">
			</td>
		</tr>
		<tr>
			<td>
				<label for="phylorder">Order</label>
				<input type="text" name="phylorder" id="phylorder" value="#gettaxa.phylorder#" size="30">
			</td>
			<td>
				<label for="suborder">Suborder</label>
				<input type="text" name="suborder" id="suborder" value="#gettaxa.suborder#" size="30">
			</td>
		</tr>
		<tr>
			<td>
				<label for="superfamily">Superfamily</label>
				<input type="text" name="superfamily" id="superfamily" value="#gettaxa.superfamily#" size="30">
			</td>
			<td>
				&nbsp;
			</td>
		</tr>
		<tr>
			<td>
				<label for="family">Family</label>
				<input type="text" name="family" id="family" value="#gettaxa.family#" size="30">
			</td>
			<td>
				<label for="subfamily">Subfamily</label>
				<input type="text" name="subfamily" id="subfamily" value="#gettaxa.subfamily#" size="30">
			</td>
		</tr>
		<tr>
			<td>
				<label for="tribe">Tribe</label>
				<input type="text" name="tribe" id="tribe" value="#gettaxa.tribe#" size="30">
			</td>
			<td>
				<label for="subfamily">Subgenus</label>
				<input type="text" name="subgenus" id="subgenus" value="#gettaxa.subgenus#" size="30">
			</td>
		</tr>
        <tr>
			<td colspan="2">
				<label for="taxon_remarks">Remarks</label>
				<textarea name="taxon_remarks" id="taxon_remarks" rows="3" cols="60">#gettaxa.taxon_remarks#</textarea>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<div align="center">
					<input type="button" value="Save" class="savBtn" onclick="taxa.Action.value='saveTaxaEdits';submit();">
              		<input type="button" value="Clone" class="insBtn" onclick="taxa.Action.value='newTaxa';submit();">
   					<input type="button" value="Delete" class="delBtn"	onclick="taxa.Action.value='deleTaxa';confirmDelete('taxa');">
				</div>
			</td>
		</tr>
      </form>
    </table>
	
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newCommon">
<cfoutput>
	<cfquery name="newCommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO common_name (common_name, taxon_name_id)
		VALUES ('#common_name#', #taxon_name_id#)
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif Action is "deleTaxa">
<cfoutput>
	<cfquery name="deleTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		DELETE FROM 
			taxonomy
		WHERE 
			taxon_name_id=#taxon_name_id#
	</cfquery>
	You killed it!
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "deleteCommon">
<cfoutput>
	<cfquery name="killCommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		DELETE FROM 
			common_name
		WHERE 
			common_name='#origCommonName#' AND taxon_name_id=#taxon_name_id#
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveCommon">
<cfoutput>
	<cfquery name="upCommon" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE
			common_name
		SET 
			common_name = '#common_name#'
		WHERE 
			common_name='#origCommonName#' AND taxon_name_id=#taxon_name_id#
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newTaxa">
<cfset title = "Add Taxonomy">
<cfoutput>
	<table border>
		<form name="taxa" method="post" action="Taxonomy.cfm">
			<input type="hidden" name="Action" value="saveNewTaxa">
			<tr>
				<td>
					<label for="source_authority"><span class="likeLink" onClick="getDocs('taxonomy','source_authority');">Source</span></label>
					<select name="source_authority" id="source_authority" size="1"  class="reqdClr">
		              <cfloop query="ctSourceAuth">
		                <option 
							<cfif form.source_authority is ctsourceauth.source_authority> selected="selected" </cfif>
								value="#ctSourceAuth.source_authority#">#ctSourceAuth.source_authority#</option>
		              </cfloop>
		            </select>
				</td>
				<td>
					<label for="valid_catalog_term_fg"><span class="likeLink" onClick="getDocs('taxonomy','valid_term');">Valid?</span></label>
					<select name="valid_catalog_term_fg" id="valid_catalog_term_fg" size="1" class="reqdClr">
		              <option <cfif valid_catalog_term_fg is "1"> selected="selected" </cfif> value="1">yes</option>
		              <option <cfif valid_catalog_term_fg is "0"> selected="selected" </cfif> value="0">no</option>
		            </select>
				</td>
	        </tr>
	        <tr>
				<td>
					<label for="nomenclatural_code"><span class="likeLink" onClick="getDocs('taxonomy','nomenclatural_code');">Nomenclatural Code</span></label>
					<select name="nomenclatural_code" id="nomenclatural_code" size="1" class="reqdClr">
		               <cfloop query="ctnomenclatural_code">
		                <option 
								<cfif #form.nomenclatural_code# is "#ctnomenclatural_code.nomenclatural_code#"> selected </cfif>value="#ctnomenclatural_code.nomenclatural_code#">#ctnomenclatural_code.nomenclatural_code#</option>
		              </cfloop>
		            </select>
				</td>
				<td>
					<label for="genus">Genus <span class="likeLink" 
						onClick="taxa.genus.value='&##215;' + taxa.genus.value;">Add &##215;</span></label>
					<input size="25" name="genus" id="genus" maxlength="40" value="#genus#">
				</td>
			</tr>
	        <tr>
				<td>
					<label for="species">Species <span class="likeLink" 
						onClick="taxa.species.value='&##215;' + taxa.species.value;">Add &##215;</span></label>
					<input size="25" name="species" id="species" maxlength="40" value="#species#">
				</td>
				<td>
					<label for="author_text"><span class="likeLink" onClick="getDocs('taxonomy','author_text');">Species Author</span></label>
					<input type="text" name="author_text" id="author_text" value="#author_text#" size="30">
					<span class="infoLink" 
						onclick="window.open('/picks/KewAbbrPick.cfm?tgt=author_text','picWin','width=700,height=400, resizable,scrollbars')">
							Find Kew Abbr
					</span>
				</td>
			</tr>
			<tr>
				<td>
					<label for="infraspecific_rank"><span class="likeLink" onClick="getDocs('taxonomy','infraspecific_rank');">Infraspecific Rank</span></label>
					<select name="infraspecific_rank" id="infraspecific_rank" size="1">
	                	<option <cfif form.infraspecific_rank is ""> selected </cfif>  value=""></option>
		                <cfloop query="ctInfRank">
		                  <option 
								<cfif form.infraspecific_rank is ctinfrank.infraspecific_rank> selected="selected" </cfif>value="#ctInfRank.infraspecific_rank#">#ctInfRank.infraspecific_rank#</option>
		                </cfloop>
	              	</select>
				</td>
				<td>
					<label for="taxon_status"><span class="likeLink" onClick="getDocs('taxonomy','taxon_status');">Taxon Status</span></label>
					<select name="taxon_status" id="taxon_status" size="1">
				    	<option value=""></option>
				    	<cfloop query="cttaxon_status">
				        	<option <cfif form.taxon_status is cttaxon_status.taxon_status> selected="selected" </cfif>
				            	value="#cttaxon_status.taxon_status#">#cttaxon_status.taxon_status#</option>
				        </cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td>
					<label for="subspecies">Subspecies</label>
					<input size="25" name="subspecies" id="subspecies" maxlength="40" value="#subspecies#">
				</td>
				<td>
					<label for="author_text"><span class="likeLink" onClick="getDocs('taxonomy','infraspecific_author');">
						Infraspecific Author</span></label>
					<input type="text" name="infraspecific_author" id="infraspecific_author" value="#infraspecific_author#" size="30">
					<span class="infoLink" 
						onclick="window.open('/picks/KewAbbrPick.cfm?tgt=infraspecific_author','picWin','width=700,height=400, resizable,scrollbars')">
							Find Kew Abbr
						</span>
				</td>
			</tr>
			<tr>
				<td>
					<label for="kingdom">Kingdom</label>
					<input type="text" name="kingdom" id="kingdom" value="#kingdom#" size="30">
				</td>
				<td>
					<label for="phylum">Phylum</label>
					<input type="text" name="phylum" id="phylum" value="#phylum#" size="30">
				</td>
			</tr>
			<tr>
				<td>
					<label for="phylclass">Class</label>
					<input type="text" name="phylclass" id="phylclass" value="#phylclass#" size="30">
				</td>
				<td>
					<label for="subclass">Sublass</label>
					<input type="text" name="subclass" id="subclass" value="#subclass#" size="30">
				</td>
			</tr>
			<tr>
				<td>
					<label for="phylorder">Order</label>
					<input type="text" name="phylorder" id="phylorder" value="#phylorder#" size="30">
				</td>
				<td>
					<label for="suborder">Suborder</label>
					<input type="text" name="suborder" id="suborder" value="#suborder#" size="30">
				</td>
			</tr>
			<tr>
				<td>
					<label for="superfamily">Superamily</label>
					<input type="text" name="superfamily" id="superfamily" value="#superfamily#" size="30">
				</td>
			</tr>
			<tr>
				<td>
					<label for="family">Family</label>
					<input type="text" name="family" id="family" value="#family#" size="30">
				</td>
				<td>
					<label for="subfamily">Subfamily</label>
					<input type="text" name="subfamily" id="subfamily" value="#subfamily#" size="30">
				</td>
			</tr>
			<tr>
				<td>
					<label for="tribe">Tribe</label>
					<input type="text" name="tribe" id="tribe" value="#tribe#" size="30">
				</td>
				<td>
					<label for="subfamily">Subgenus</label>
					<input type="text" name="subgenus" id="subgenus" value="#subgenus#" size="30">
				</td>
			</tr>
	        <tr>
				<td colspan="2">
					<label for="taxon_remarks">Remarks</label>
					<textarea name="taxon_remarks" id="taxon_remarks" rows="3" cols="60">#taxon_remarks#</textarea>
				</td>
			</tr>
			<tr>
				<td align="center" colspan="2">
 					<input type="submit" value="Create" class="insBtn">
				</td>
			</tr>
		</form>
	</table>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveNewtaxa">
<cfoutput>
<cfquery name="nextID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select sq_taxon_name_id.nextval nextID from dual
</cfquery>
	<cfquery name="newTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO taxonomy (
			taxon_name_id,
			valid_catalog_term_fg,
			source_authority,
			author_text,
			tribe,
			infraspecific_rank,
			phylclass,
			phylorder,
			suborder,
			family,
			subfamily,
			genus,
			subgenus,
			species,
			subspecies,
			taxon_remarks,
			phylum,
			infraspecific_author,
			kingdom,
			nomenclatural_code,
			taxon_status,
			subclass,
			superfamily
		) VALUES (
			#nextID.nextID#,
			#valid_catalog_term_fg#,
			'#source_authority#',
			'#escapeQuotes(author_text)#',
			'#tribe#',
			'#infraspecific_rank#',
			'#phylclass#',
			'#phylorder#',
			'#suborder#',
			'#family#',
			'#subfamily#',
			'#genus#',
			'#subgenus#',
			'#species#',
			'#subspecies#',
			'#escapeQuotes(taxon_remarks)#',
			'#phylum#',
			'#escapeQuotes(infraspecific_author)#',
			'#kingdom#',
			'#nomenclatural_code#',
			'#taxon_status#',
			'#subclass#',
			'#superfamily#'
		)
	</cfquery>
	<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#nextID.nextID#" addtoken="false">	
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif Action is "deleReln">
<cfoutput>
<cfquery name="deleReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	DELETE FROM 
		taxon_relations
	WHERE
		taxon_name_id = #taxon_name_id#
		AND Taxon_relationship = '#origtaxon_relationship#'
		AND related_taxon_name_id=#related_taxon_name_id#
		</cfquery>
		<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "saveRelnEdit">
<cfoutput>
<cfquery name="edRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	UPDATE taxon_relations SET
		taxon_relationship = '#taxon_relationship#'
		<cfif len(#newRelatedId#) gt 0>
			,related_taxon_name_id = #newRelatedId#
		<cfelse>
			,related_taxon_name_id = #related_taxon_name_id#
		</cfif>
		<cfif len(#relation_authority#) gt 0>
			,relation_authority = '#relation_authority#'
		<cfelse>
			,relation_authority = null
		</cfif>
	WHERE
		taxon_name_id = #taxon_name_id#
		AND Taxon_relationship = '#origTaxon_relationship#'
		AND related_taxon_name_id=#related_taxon_name_id#
</cfquery>
<cflocation url="Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" addtoken="false">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->


------------------>
<cfinclude template="includes/_footer.cfm">