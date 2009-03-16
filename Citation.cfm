<cfinclude template="includes/_header.cfm">
<script type='text/javascript' src='/includes/checkForm.js'></script>
	<script>
		function getCatalogedItemCitation (id,type) {
			var collection_id = document.getElementById('collection').value;
			var el = document.getElementById(id);
			el.className='red';
			var theNum = el.value;
			DWREngine._execute(_cfscriptLocation, null, 'getCatalogedItemCitation', collection_id, theNum,type,success_getCatalogedItemCitation);
		}
		function success_getCatalogedItemCitation (result) {
			//alert(result);
			if (result.length > 1){
				alert('Multiple matches.');
			} else {
				if (result[0]) {	
					var scientific_name=result[0].SCIENTIFIC_NAME;
					var collection_object_id=result[0].COLLECTION_OBJECT_ID;
					if (collection_object_id < 0) {
						alert('error: ' + scientific_name);
					} else {
						var sn = document.getElementById('scientific_name');
						var co = document.getElementById('collection_object_id');
						var c = document.getElementById('collection');
						var cn = document.getElementById('cat_num');
						cn.className='reqdClr';
						if (document.getElementById('custom_id')) {
						    var cusn = document.getElementById('custom_id');
						    cusn.className='';
						}
						co.value=collection_object_id;
						sn.value=scientific_name;
						//c.style.background-color='green';
						//cn.style.background-color='green';
					}
				} else {
					alert('Specimen not found.');
				}
			}
		}
		
		

	</script>
	
<cfquery name="ctTypeStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select type_status from ctcitation_type_status order by type_status
</cfquery>
<!--- get all cited specimens --->

<!------------------------------------------------------------------------------->
<cfif #Action# is "nothing">
<cfset title="Manage Citations">
<cfoutput>

<cfquery name="getCited" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT
		citation.publication_id,
		citation.collection_object_id,
		collection,
		cat_num, 
		identification.scientific_name, 
		citedTaxa.scientific_name as citSciName,
		occurs_page_number,
		type_status,
		citation_remarks,
		publication_title,
		cited_taxon_name_id,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID
	FROM 
		citation, 
		cataloged_item,
		collection,
		identification,
		taxonomy citedTaxa,
		publication
	WHERE
		citation.collection_object_id = cataloged_item.collection_object_id AND
		cataloged_item.collection_id = collection.collection_id AND
		citation.cited_taxon_name_id = citedTaxa.taxon_name_id (+) AND
		cataloged_item.collection_object_id = identification.collection_object_id (+) AND
		identification.accepted_id_fg = 1 AND
		citation.publication_id = publication.publication_id AND
		citation.publication_id = #publication_id#
	ORDER BY
		occurs_page_number,citSciName,cat_num
</cfquery>

<a href="javascript:void(0);" onClick="getDocs('publication','citation')">Citations</a>
 for 	<b>#getCited.publication_title#</b>:
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
				onmouseover="this.className='delBtn btnhov'"
				onmouseout="this.className='delBtn'"
				onClick="deleCitation#i#.Action.value='deleCitation';submit();">

			
			</td><td>
			<input type="button" 
				value="Edit" 
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
				onmouseout="this.className='lnkBtn'"
				onClick="deleCitation#i#.Action.value='editCitation'; submit();">
				
			</td>
		</form>
		<form name="clone#i#" method="post" action="Citation.cfm">
		
			<td>
			<input type="button" 
				value="Clone" 
				class="insBtn"
				onmouseover="this.className='insBtn btnhov'" 
				onmouseout="this.className='insBtn'"
				onclick = "newCitation.cited_taxon_name.value='#getCited.citSciName#';
				newCitation.cited_taxon_name_id.value='#getCited.cited_taxon_name_id#';
				newCitation.type_status.value='#getCited.type_status#';
				newCitation.occurs_page_number.value='#getCited.occurs_page_number#';
				newCitation.citation_remarks.value='#getCited.citation_remarks#';
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
	
</form>
	</tr>
	<cfset i=#i#+1>
</cfloop>
</tr></table>
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection_id,collection from collection
	order by collection
</cfquery>
<form name="newCitation" id="newCitation" method="post" action="Citation.cfm">
		<input type="hidden" name="Action" value="newCitation">
		<input type="hidden" name="publication_id" value="#publication_id#">
		<input type="hidden" name="collection_object_id" id="collection_object_id">
<table border class="newRec">
<tr>
	<td colspan="2">
	Add Citation to <b>	#getCited.publication_title#</b>:
	</td>
</tr>
<tr>
	<td>
		<label for="collection">Collection</label>
		<select name="collection" id="collection" size="1" class="reqdClr">
			<cfloop query="ctcollection">
				<option value="#collection_id#">#collection#</option>
			</cfloop>
		</select>
	</td>	
	<td>
		<label for="cat_num">Catalog Number</label>
		<input type="text" name="cat_num" id="cat_num" onchange="getCatalogedItemCitation(this.id,'cat_num')" class="reqdClr">
	</td>
	<cfif len(session.CustomOtherIdentifier) gt 0>
		<td>
			<label for="custom_id">#session.CustomOtherIdentifier#</label>
			<input type="text" name="custom_id" id="custom_id" onchange="getCatalogedItemCitation(this.id,'#session.CustomOtherIdentifier#')">
		</td>
	</cfif>
</tr>
<tr>
	</td>

	<td>
		<label for="scientific_name">Current Identification</label>
		<input type="text" name="scientific_name" id="scientific_name" readonly="yes" class="readClr" size="50">
	</td>
	<td colspan="2">
		<label for="cited_taxon_name">
			<a href="javascript:void(0);" onClick="getDocs('publication','cited_as_taxon')">Cited As</a></label>
		<input type="text" name="cited_taxon_name" id="cited_taxon_name" class="reqdClr" size="50" onChange="taxaPick('cited_taxon_name_id','cited_taxon_name','newCitation',this.value); return false;">
		<span class="infoLink"
			onClick = "taxaPick('cited_taxon_name_id','cited_taxon_name','newCitation',document.getElementById('scientific_name').value)">Use Current</span>
		<input type="hidden" name="cited_taxon_name_id">
	</td>
</tr>

<tr>
	<td>
		<label for="type_status">
			<a href="javascript:void(0);" onClick="getDocs('publication','citation_type')">Citation Type</a>
		</label>
		<select name="type_status" id="type_status" size="1">
			<cfloop query="ctTypeStatus">
				<option value="#ctTypeStatus.type_status#">#ctTypeStatus.type_status#</option>
			</cfloop>
		</select>
		<span class="infoLink" onClick="getCtDoc('ctcitation_type_status',newCitation.type_status.value)">Define</span>
	</td>
	<td>
		<label for="occurs_page_number">
			<a href="javascript:void(0);" onClick="getDocs('publication','cited_on_page_number')">Page ##</a>
		</label>
		<input type="text" name="occurs_page_number" id="occurs_page_number" size="4">
	</td>
</tr>
<tr>
	<td colspan="3">
		<label for="citation_remarks">Remarks:</label>
		<input type="text" name="citation_remarks" id="citation_remarks" size="90">
	</td>
</tr>

<tr>
	<td colspan="2" align="center">
		<input type="submit" 
			id="submit"
			title="Insert Citation"
			value="Insert Citation" 
			class="insBtn"
			onmouseover="this.className='insBtn btnhov'" 
			onmouseout="this.className='insBtn'">
	</td>
	
	</form>

</tr></table>

</cfoutput>
</cfif>

<!------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------->
<cfif #Action# is "newCitation">
	<cfoutput>
	<cfquery name="newCite" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="edCit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		<!---
		<cf_ActivityLog sql="
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
			  	, =null
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
		">
		--->
			<cflocation url="Citation.cfm?publication_id=#publication_id#">		
		
	</cfoutput>

</cfif>
<!------------------------------------------------------------------------------->
<cfif #Action# is "editCitation">
<cfset title="Edit Citations">
<cfoutput>

<cfquery name="getCited" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		publication_title,
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

<br>Edit Citation for <b>#getCited.publication_title#</b>:
<form name="editCitation" id="editCitation" method="post" action="Citation.cfm">
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
	
	</form>
</tr></table>

</cfoutput>
</cfif>

<!------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------->
<cfif #Action# is "deleCitation">
<cfoutput>
	<cfquery name="deleCit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	delete from citation where collection_object_id = #collection_object_id# and publication_id = #publication_id#
	</cfquery>
	<cf_ActivityLog sql="delete from citation where collection_object_id = #collection_object_id# and publication_id = #publication_id#">
			<cflocation url="Citation.cfm?publication_id=#publication_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">