<cfinclude template="includes/_header.cfm">
<script type='text/javascript' src='/includes/_editIdentification.js'></script>

	<script>
		jQuery(document).ready(function() {
			$("#made_date").datepicker();
			$("input[id^='made_date_']").each(function(){
				$("#" + this.id).datepicker();
			});
		});
		function getCatalogedItemCitation (id,type) {
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "getCatalogedItemCitation",
					collection_id : $("#collection").val(),
					theNum : $("#" + id).val(),
					type : type,
					returnformat : "json",
					queryformat : 'column'
				},
				success_getCatalogedItemCitation
			);
		}
		function success_getCatalogedItemCitation (r) {
			var result=r.DATA;
			//alert(result);
			if (r.ROWCOUNT > 1){
				alert('Multiple matches.');
			} else {
				if (r.ROWCOUNT==1) {	
					if (result.COLLECTION_OBJECT_ID[0] < 0) {
						alert('error: ' + scientific_name);
					} else {
						$("#collection_object_id").val(result.COLLECTION_OBJECT_ID[0]);
						var ltxt='<a target="_blank" href="/guid/' + result.GUID[0] + '">' + result.GUID[0] + ' - ' + result.SCIENTIFIC_NAME[0] + '</a>';
						$("#resulttext").html(ltxt);
						
						
						$("#taxa_formula").val(result.TAXA_FORMULA[0]);
						$("#taxona").val(result.SCIENTIFIC_NAME[0]);
						$("#taxona_id").val(result.TAXON_NAME_ID[0]);
						$("#nature_of_id").val(result.NATURE_OF_ID[0]);
						
					
					
					}
				} else {
					alert('Specimen not found.');
				}
			}
		}
	</script>
	<style>
		#lsp {min-width:1em;
		padding: 0 1;
		border:2px solid green;
		}
	</style>
<cfquery name="ctTypeStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select type_status from ctcitation_type_status order by type_status
</cfquery>
<!--- get all cited specimens --->

<!------------------------------------------------------------------------------->
<cfif action is "nothing">
<cfset title="Manage Citations">
<cfoutput>

<cfquery name="getCited" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	SELECT
		citation.citation_id,
		citation.publication_id,
		citation.collection_object_id,
		collection,
		PUBLISHED_YEAR,
		guid_prefix,
		collection.collection_id,
		cat_num, 
		identification.scientific_name, 
		citedid.scientific_name as citSciName,
		occurs_page_number,
		type_status,
		citation_remarks,
		full_citation,
		citedid.identification_id citedidid,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID
	FROM 
		citation, 
		cataloged_item,
		collection,
		identification,
		identification citedid,
		publication
	WHERE
		citation.collection_object_id = cataloged_item.collection_object_id AND
		cataloged_item.collection_id = collection.collection_id AND
		citation.identification_id = citedid.identification_id AND
		cataloged_item.collection_object_id = identification.collection_object_id (+) AND
		identification.accepted_id_fg = 1 AND
		citation.publication_id = publication.publication_id AND
		citation.publication_id = #publication_id#
	ORDER BY
		occurs_page_number,citSciName,cat_num
</cfquery>
<cfquery name="auth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select rownum r,preferred_agent_name.agent_id, agent_name from preferred_agent_name, publication_agent
	where publication_agent.agent_id=preferred_agent_name.agent_id and
	publication_agent.publication_id = #publication_id#
</cfquery>

<a href="javascript:void(0);" onClick="getDocs('publication','citation')">Citations</a>
 for 	<b>#getCited.full_citation#</b>
<a href="/Publication.cfm?publication_id=#publication_id#">[ Edit Publication ]</a>
<a href="/SpecimenUsage.cfm?action=search&publication_id=#publication_id#">[ View Publication ]</a>
<table border cellpadding="0" cellspacing="0"><tr>
	<td>&nbsp;</td>
	<td nowrap>Cat Num</td>
	<td nowrap>#session.CustomOtherIdentifier#</td>
	<td nowrap>
	Cited As
	</td>
	<td>Current ID</td>
	<td nowrap>Citation Type</td>
	<td nowrap>Page ##</td>
	<td>Remarks</td>
</tr>


<cfset i=1>
<cfloop query="getCited">
	<tr>
	<td nowrap>
		<table cellpadding="0" cellspacing="0">
		<form name="deleCitation#i#" method="post" action="Citation.cfm">
		<input type="hidden" name="Action">
			<input type="hidden" value="#publication_id#" name="publication_id">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			<tr><td>
			<input type="button" 
				value="Delete"
				class="delBtn"
				onClick="deleCitation#i#.Action.value='deleCitation';submit();">
			</td><td>
			<input type="button" 
				value="Edit" 
				class="lnkBtn"
				onClick="deleCitation#i#.Action.value='editCitation'; submit();">
				
			</td>
		</form>
		
			<td>
			<input type="button" 
				value="Clone" 
				class="insBtn"
				onclick = "newCitation.cited_taxon_name.value='#getCited.citSciName#';
				newCitation.identification_id.value='#getCited.citedidid#';
				newCitation.type_status.value='#getCited.type_status#';
				newCitation.occurs_page_number.value='#getCited.occurs_page_number#';
				newCitation.citation_remarks.value='#getCited.citation_remarks#';
				newCitation.collection.value='#getCited.collection_id#';
				">
			</td></tr>
		</table>
	</td>
	<td>
		<a href="/SpecimenDetail.cfm?collection_object_id=#getCited.collection_object_id#">
			#getCited.collection#&nbsp;#getCited.cat_num#</a></td>
	<td nowrap="nowrap">#customID#</td>
	<td nowrap><i>#getCited.citSciName#</i>&nbsp;</td>
	<td nowrap><i>#getCited.scientific_name#</i>&nbsp;</td>
	<td nowrap>#getCited.type_status#&nbsp;</td>
	<td>#getCited.occurs_page_number#&nbsp;</td>
	<td nowrap>#getCited.citation_remarks#&nbsp;</td>
	
	</tr>
	<cfset i=#i#+1>
</cfloop>
</tr></table>
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select collection_id,collection from collection order by collection
</cfquery>

<cfquery name="ctnature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select nature_of_id from ctnature_of_id
</cfquery>
<cfquery name="ctFormula" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select taxa_formula from cttaxa_formula order by taxa_formula
</cfquery>
<form name="newCitation" id="newCitation" method="post" action="Citation.cfm">
		<input type="hidden" name="Action" value="newCitation">
		<input type="hidden" name="publication_id" value="#publication_id#">
		<input type="hidden" name="collection_object_id" id="collection_object_id">

<div class="newRec">
	<h3>Add Citation/ID</h3>
	Lots of citations? Try the <a href="/tools/BulkloadCitations.cfm">bulkloader</a>.
	<label for="lsp">Find a specimen</label>
	<label for="collection">Collection</label>
	<select name="collection" id="collection" size="1" class="reqdClr">
		<cfloop query="ctcollection">
			<option value="#collection_id#">#collection#</option>
		</cfloop>
	</select>
	<label for="cat_num">Catalog Number</label>
	<input type="text" name="cat_num" id="cat_num" onchange="getCatalogedItemCitation(this.id,'cat_num')">
	<cfif len(session.CustomOtherIdentifier) gt 0>
		<td>
			<label for="custom_id">OR #session.CustomOtherIdentifier#</label>
			<input type="text" name="custom_id" id="custom_id" onchange="getCatalogedItemCitation(this.id,'#session.CustomOtherIdentifier#')">
		</td>
	</cfif>
	<p>Fill the above in, then <input type="button" class="schLink" onclick="getCatalogedItemCitation('cat_num','cat_num');" value="click this button to find a specimen">.</p>
	<div id="resulttext">[ This will be a link when the lookup is successful. ]</div>
	<label class="likeLink" for="type_status" onClick="getDocs('publication','citation_type')">
		Citation Type
	</label>
		<select name="type_status" id="type_status" size="1">
			<cfloop query="ctTypeStatus">
				<option value="#ctTypeStatus.type_status#">#ctTypeStatus.type_status#</option>
			</cfloop>
		</select>
		<span class="infoLink" onClick="getCtDoc('ctcitation_type_status',newCitation.type_status.value)">Define</span>
	
		<label for="occurs_page_number">
			<a href="javascript:void(0);" onClick="getDocs('publication','cited_on_page_number')">Page ##</a>
		</label>
		<input type="text" name="occurs_page_number" id="occurs_page_number" size="4">

		<label for="citation_remarks">Remarks:</label>
		<input type="text" name="citation_remarks" id="citation_remarks" size="90">

		<label for="taxa_formula"><span class="helpLink" id="taxa_formula">ID Formula:</span></label>
		<select name="taxa_formula" id="taxa_formula" size="1" class="reqdClr"
			onchange="newIdFormula(this.value);">
				<cfloop query="ctFormula">
					<option value="#ctFormula.taxa_formula#">#taxa_formula#</option>
				</cfloop>
		</select>
		<label for="taxona"><span class="helpLink" id="scientific_name">Taxon A:</span></label>
		
		<input type="text" name="taxona" id="taxona" class="reqdClr" size="50" 
				onChange="taxaPick('taxona_id','taxona','newCitation',this.value); return false;"
				onKeyPress="return noenter(event);">
			<input type="hidden" name="taxona_id" id="taxona_id" class="reqdClr"> 
		
	<div id="userID" style="display:none;">
    		<label for="user_id"><span class="helpLink" id="user_identification">Identification:</span></label>
		<input type="text" name="user_id" id="user_id" size="50">
		</div>

	<div id="taxon_b_row" style="display:none;">
			<label for="taxonb"><span class="helpLink" id="scientific_name">Taxon B:</span></label>

			<input type="text" name="taxonb" id="taxonb"  size="50" 
				onChange="taxaPick('taxonb_id','taxonb','newCitation',this.value); return false;"
				onKeyPress="return noenter(event);">
			<input type="hidden" name="taxonb_id" id="taxonb_id">
	</div>
			<cfquery name="a1" dbtype="query">
				select * from auth where r=1
			</cfquery>
			<cfquery name="a2" dbtype="query">
				select * from auth where r=2
			</cfquery>
			<cfquery name="a3" dbtype="query">
				select * from auth where r=3
			</cfquery>	
	publication_id = #publication_id#			
				<label for="newIdBy"><span class="helpLink" id="id_by">ID Agent 1 (save and edit for more agents)</span></label>
<input type="text" name="newIdBy" id="newIdBy" class="reqdClr" size="50" value="#a1.agent_name#"
				onchange="getAgent('newIdBy_id',this.id,'newCitation',this.value);">
            <input type="hidden" name="newIdBy_id" id="newIdBy_id" class="reqdClr" value="#a1.agent_id#"> 
			<span class="infoLink" onclick="addNewIdBy('two');">more...</span>
			
    					<label for="newIdBy_two"><span class="helpLink" id="id_by">ID Agent 2</span></label>
			<input type="text" name="newIdBy_two" id="newIdBy_two" size="50"  value="#a2.agent_name#"
				onchange="getAgent('newIdBy_two_id',this.id,'newCitation',this.value);">
            <input type="hidden" name="newIdBy_two_id" id="newIdBy_two_id" value="#a2.agent_id#"> 
			
	
    					<label for="newIdBy_three"><span class="helpLink" id="id_by">ID Agent 3</span></label>
				<input type="text" name="newIdBy_three" id="newIdBy_three" size="50" value="#a3.agent_name#" 
				onchange="getAgent('newIdBy_three_id',this.id,'newCitation',this.value);">
            <input type="hidden" name="newIdBy_three_id" id="newIdBy_three_id" value="#a3.agent_id#"> 	
	
    					<label for="made_date"><span class="helpLink" id="identification.made_date">ID Date:</span></label>
	<input type="text" name="made_date" id="made_date" value='#getCited.PUBLISHED_YEAR#'>
	
    					<label for="nature_of_id"><span class="helpLink" id="nature_of_id">Nature of ID</span></label>
			<select name="nature_of_id" id="nature_of_id" size="1" class="reqdClr">
            	<cfloop query="ctnature">
                	<option  value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
                </cfloop>
            </select>
			<span class="infoLink" onClick="getCtDoc('ctnature_of_id',newID.nature_of_id.value)">Define</span>
			
	    					<label for="identification_remarks"><span class="helpLink" id="identification_remarks">Remarks</span></label>
			<input type="text" name="identification_remarks" id="identification_remarks" size="50">
    	
            	<input type="submit" id="newID_submit" value="Create" class="insBtn reqdClr" title="Create Identification">	
        






	
	
</div>



<table border class="newRec">
<tr>
	<td colspan="2">
	Add Citation to <b>	#getCited.full_citation#</b>:
	</td>
</tr>
<tr>
	<td>
		
	</td>	
	<td>
		
	</td>
	
</tr>
<tr>
	</td>

	<td>
		<label for="scientific_name">Current Identification</label>
		
	</td>
	<td colspan="2">
		<label for="cited_taxon_name">
			<a href="javascript:void(0);" onClick="getDocs('publication','cited_as_taxon')">Cited As</a></label>
		<input type="text" name="CitedIdentification" id="CitedIdentification" class="reqdClr" size="50" 
			onChange="getIdentification('identification_id','CitedIdentification'); return false;">
		
		
		<span class="infoLink"
			onClick = "getIdentification('identification_id','ididfld','newCitation',document.getElementById('scientific_name').value)">Use Current</span>
		<input type="hidden" name="identification_id">
	</td>
</tr>




<tr>
	<td>
		
</tr>

<tr>
	<td colspan="2" align="center">
		<input type="submit" 
			id="submit"
			title="Insert Citation"
			value="Insert Citation" 
			class="insBtn">
	</td>
	
	</form>

</tr></table>

</cfoutput>
</cfif>

<!------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------->
<cfif #Action# is "newCitation">
	<cfoutput>
	<cfquery name="newCite" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO citation (
			publication_id,
			collection_object_id,
			cit_current_fg
			<cfif len(#cited_taxon_name_id#) gt 0>
				,cited_taxon_name_id
			</cfif>
			<cfif len(#occurs_page_number#) gt 0>
				,occurs_page_number
			</cfif>
			<cfif len(#type_status#) gt 0>
				,type_status
			</cfif>
			<cfif len(#citation_remarks#) gt 0>
				,citation_remarks
			</cfif>
			) 
			VALUES (
			#publication_id#,
			#collection_object_id#,
			1
			<cfif len(#cited_taxon_name_id#) gt 0>
				,#cited_taxon_name_id#
			</cfif>
			<cfif len(#occurs_page_number#) gt 0>
				,#occurs_page_number#
			</cfif>
			<cfif len(#type_status#) gt 0>
				,'#type_status#'
			</cfif>
			<cfif len(#citation_remarks#) gt 0>
				,'#citation_remarks#'
			</cfif>
			) 
			</cfquery>
			<cflocation url="Citation.cfm?publication_id=#publication_id#">
	</cfoutput>

</cfif>
<!------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------->
<cfif #Action# is "saveEdits">
	<cfoutput>
	<cfquery name="edCit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE citation SET
			cit_current_fg = 1
			<cfif len(#cited_taxon_name_id#) gt 0>
				,cited_taxon_name_id = #cited_taxon_name_id#
			  <cfelse>
			  	,cited_taxon_name_id = null
			</cfif>
			<cfif len(#occurs_page_number#) gt 0>
				,occurs_page_number = #occurs_page_number#
			  <cfelse>
			  	,occurs_page_number = null
			</cfif>
			<cfif len(#type_status#) gt 0>
				,type_status = '#type_status#'
			  <cfelse>
				,type_status = null
			</cfif>
			<cfif len(#citation_remarks#) gt 0>
				,citation_remarks = '#citation_remarks#'
			  <cfelse>
			  	,citation_remarks = null
			</cfif>
			
		WHERE 
			publication_id = #publication_id# AND
			collection_object_id = #collection_object_id#
		</cfquery>
		<cflocation url="Citation.cfm?publication_id=#publication_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif #Action# is "editCitation">
<cfset title="Edit Citations">
<cfoutput>

<cfquery name="getCited" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	SELECT
		citation.publication_id,
		citation.collection_object_id,
		cat_num,
		collection,
		identification.scientific_name, 
		citedTaxa.scientific_name as citSciName,
		occurs_page_number,
		type_status,
		citation_remarks,
		full_citation,
		cited_taxon_name_id
	FROM 
		citation, 
		cataloged_item,
		identification,
		taxonomy citedTaxa,
		publication,
		collection
	WHERE
		cataloged_item.collection_id = collection.collection_id AND
		citation.collection_object_id = cataloged_item.collection_object_id AND
		citation.cited_taxon_name_id = citedTaxa.taxon_name_id (+) AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		citation.publication_id = publication.publication_id AND
		citation.publication_id = #publication_id# AND 
		citation.collection_object_id = #collection_object_id#
</cfquery>


</cfoutput>
<cfoutput query="getCited">

<br>Edit Citation for <b>#getCited.full_citation#</b>:
<cfform name="editCitation" id="editCitation" method="post" action="Citation.cfm">
		<input type="hidden" name="Action" value="saveEdits">
		<input type="hidden" name="publication_id" value="#publication_id#">

		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
<table border>

<tr>
	<td>
		<label for="citem">Cataloged Item</label>
		<span id="citem">#collection# #cat_num#</span>
	</td>
	<td>
		<label for="scientific_name">Identified As</label>
		<span id="scientific_name">#scientific_name#</span>
	</td>
</tr>

<tr>
	<td>
		<label for="cited_taxon_name">Cited As</label>
		<input type="text" 
			name="cited_taxon_name"
			id="cited_taxon_name" 
			value="#citSciName#"
			class="reqdClr" 
			size="50" 
			onChange="taxaPick('cited_taxon_name_id','cited_taxon_name','editCitation',this.value); return false;">
		<input type="hidden" name="cited_taxon_name_id" value="#cited_taxon_name_id#" class="reqdClr">
	</td>
	<td>
		<label for="type_status">Citation Type</label>
		<select name="type_status" id="type_status" size="1">
			<cfloop query="ctTypeStatus">
				<option 
					<cfif #getCited.type_status# is "#ctTypeStatus.type_status#"> selected </cfif>value="#ctTypeStatus.type_status#">#ctTypeStatus.type_status#</option>
			</cfloop>
		</select>
	</td>
</tr>

<tr>
	<td>
		<label for="occurs_page_number">Page</label>
		<input type="text" name="occurs_page_number" id="occurs_page_number" size="4" value="#occurs_page_number#">
	</td>
	<td>
		<label for="citation_remarks">Remarks</label>
		<input type="text" name="citation_remarks" id="citation_remarks" size="50" value="#citation_remarks#">
	</td>
</tr>
<tr>
	<td colspan="2" align="center">
		<input type="submit" 
			value="Save Edits" 
			class="savBtn"
			id="sBtn"
			title="Save Edits"
			onmouseover="this.className='savBtn btnhov'" 
			onmouseout="this.className='savBtn'">	

	</td>
	
	</cfform>
</tr></table>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfif #Action# is "deleCitation">
<cfoutput>
	<cfquery name="deleCit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from citation where collection_object_id = #collection_object_id# and publication_id = #publication_id#
	</cfquery>
	<cflocation url="Citation.cfm?publication_id=#publication_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">