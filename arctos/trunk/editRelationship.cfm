<cfinclude template="/includes/alwaysInclude.cfm">
<script type="text/javascript">
var initVal="";
function chkVal() {
if(document.getElementById("catColl").value!=initVal) {
//alert("value is changed");
var theSaveButton = document.getElementById('saveNewCell');
theSaveButton.style.display='';


}
}
window.setInterval("chkVal()",1000);
</script>
<cfoutput>
<cfquery name="thisRec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT cat_num, cataloged_item.collection_cde,
	institution_acronym from cataloged_item,
	collection WHERE 
	cataloged_item.collection_id = collection.collection_id AND
	collection_object_id=#collection_object_id#
</cfquery>
<cfquery name="getRelns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT cat_num, 
	cataloged_item.collection_object_id,
	cataloged_item.collection_cde, 
	biol_indiv_relationship,
	thisSpecimenId.scientific_name scientific_name,
	relatedSpecimenId.scientific_name CatItemSciName
	<cfif isdefined("customOtherIdentifier") and len(#session.CustomOtherIdentifier#) gt 0>
		,concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#')	CustomID
	</cfif>
	 FROM 
	cataloged_item,
	biol_indiv_relations,
	identification thisSpecimenId,
	identification relatedSpecimenId
	WHERE
	cataloged_item.collection_object_id = biol_indiv_relations.related_coll_object_id AND
	cataloged_item.collection_object_id = thisSpecimenId.collection_object_id AND
	biol_indiv_relations.collection_object_id = relatedSpecimenId.collection_object_id AND
	thisSpecimenId.accepted_id_fg=1 AND
	relatedSpecimenId.accepted_id_fg=1 AND
	biol_indiv_relations.collection_object_id=#collection_object_id#
</cfquery>

<strong>Edit Relationships:</strong>
<cfset thisCollObjId = #collection_object_id#>
<br>Current Relationships:
<cfif #getRelns.recordcount# gt 0>
<cfquery name="ctReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select biol_indiv_relationship from ctbiol_relations
</cfquery>
<cfset i=1>
<table>
<cfloop query="getRelns">
<form name="reln#i#" method="post" action="editRelationship.cfm">
	<input type="hidden" name="collection_object_id" value="#thisCollObjId#">
	<input type="hidden" name="action">
	<input type="hidden" name="origRelCollObjId" value="#getRelns.collection_object_id#">
	<input type="hidden" name="origReln" value="#getRelns.biol_indiv_relationship#">
		<cfset thisReln = #getRelns.biol_indiv_relationship#>
	<tr>
		<td><select name="biol_indiv_relationship" size="1" class="reqdClr">
				<cfloop query="ctReln">
					<option 
						<cfif #thisReln# is "#ctReln.biol_indiv_relationship#"> selected </cfif>value="#ctReln.biol_indiv_relationship#">#ctReln.biol_indiv_relationship#</option>
				</cfloop>
			</select>
			</td>
			<td>
			Cat ## <input type="text" name="related_cat_num" readonly="yes" class="readClr" size="6" value="#getRelns.cat_num#">
			<cfif isdefined("customOtherIdentifier") and len(#session.CustomOtherIdentifier#) gt 0>
				(#session.CustomOtherIdentifier# = #CustomID#)
			</cfif>
				<input type="text" size="20" name="scientific_name" readonly="yes" class="readClr" value="#getRelns.scientific_name#">
				
				<input type="hidden" name="related_coll_object_id" value="#getRelns.collection_object_id#">
				<input type="button" 
					 	value="Pick" 
						class="picBtn"
   						onmouseover="this.className='picBtn btnhov'" 
						onmouseout="this.className='picBtn'"
   						onclick="findCatalogedItem('related_coll_object_id','scientific_name','reln#i#'); return false;">
   						<!---
   							onclick="CatItemPick('related_coll_object_id','related_cat_num','reln#i#','scientific_name');return false;">
   						--->
					<input type="button" 
					 	value="Save" 
						class="savBtn"
   						onmouseover="this.className='savBtn btnhov'" 
						onmouseout="this.className='savBtn'"
						onclick="reln#i#.action.value='saveEdit'; submit();">
					<input type="button" 
					 	value="Delete" 
						class="delBtn"
   						onmouseover="this.className='delBtn btnhov'" 
						onmouseout="this.className='delBtn'"
						onclick="reln#i#.action.value='deleReln'; confirmDelete('reln#i#','this relationship');">
			</td>
			<td valign="middle">
				<a href="SpecimenDetail.cfm?collection_object_id=#getRelns.collection_object_id#" class="infoLink">Related Specimen</a>
				<cfif #biol_indiv_relationship# is "parent of" and (#scientific_name# neq #CatItemSciName#)>
					<a href="/tools/parent_child_taxonomy.cfm?collection_object_id=#thisCollObjId#">
						<img src="/images/oops.gif" border="0" height="20"/>
					</a>
				</cfif>
			</td>
	</tr>
	
				
						
					
					
					
</form>
<cfset i=#i#+1>
</cfloop>
</table>
<cfelse>
None
</cfif>
<cfquery name="ctReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select biol_indiv_relationship from ctbiol_relations
</cfquery>

<!----<form name="newRelation" action="editRelationship.cfm" method="post">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<input type="hidden" name="action" value="saveNew">
		<table class="newRec">
		<tr>
			<td colspan="2">
				Add Relationship:
			</td>
		</tr>
		<tr>
			<td><select name="biol_indiv_relationship" size="1" class="reqdClr">
				<cfloop query="ctReln">
					<option value="#ctReln.biol_indiv_relationship#">#ctReln.biol_indiv_relationship#</option>
				</cfloop>
			</select></td>
			<td>
				Cat ## <input type="text" name="related_cat_num" readonly="yes" class="readClr" size="6">
				<input type="text" size="20" name="scientific_name" readonly="yes" class="readClr">
				<input type="hidden" name="related_coll_object_id">
				<input type="button" 
					 	value="Pick" 
						class="picBtn"
   						onmouseover="this.className='picBtn btnhov'" 
						onmouseout="this.className='picBtn'"
   						onclick="CatItemPick('related_coll_object_id','related_cat_num','newRelation','scientific_name');return false;">
					<input type="submit" 
					 	value="Save" 
						class="savBtn"
   						onmouseover="this.className='savBtn btnhov'" 
						onmouseout="this.className='savBtn'">
						
					


			</td>
		</tr>
	</table>
</form>
---->
<cfquery name="thisCollId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection from cataloged_item,collection where cataloged_item.collection_id=collection.collection_id and
    collection_object_id=#collection_object_id#
</cfquery>
<table class="newRec">
	<tr>
		<td colspan="99">
			Add a relationship:
		</td>
	</tr>
	<tr>
		<form name="newRelationship" method="post" action="editRelationship.cfm">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			<input type="hidden" name="action" value="saveNew" >
			<input type="hidden" name="related_coll_object_id" >
			<td>
				<font size="-2">Relationship:<br>
				</font>				<select name="biol_indiv_relationship" size="1" class="reqdClr">
					<cfloop query="ctReln">
						<option value="#ctReln.biol_indiv_relationship#">#ctReln.biol_indiv_relationship#</option>
					</cfloop>
				</select>
		  </td>
			<td>
			
				<font size="-2">Picked Cataloged Item:<br></font>
				<input onchange="alert('c');"
			 type="text"  
			 id="catColl"
				 	name="catColl" 
					readonly="yes" 
					size="40" 
					style="background-color:transparent;border:none; "
					>
						
		  </td>
		  <td>
		  		<cfquery name="ctColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select collection from collection 
					group by collection order by collection
				</cfquery>
				<font size="-2">Collection:<br></font>
				<select name="collection" size="1">
					<cfloop query="ctColl">
						<option 
							<cfif #thisCollId.collection# is "#ctColl.collection#"> selected </cfif>
							value="#ctColl.collection#">#ctColl.collection#</option>
					</cfloop>
				</select>
		  </td>
		  <td>
		  	<cfquery name="ctOtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select distinct(other_id_type) FROM ctColl_Other_Id_Type ORDER BY other_Id_Type
		</cfquery>
		<font size="-2">Other ID Type:<br></font>
		<select name="other_id_type" size="1">
			<option value="catalog_number">Catalog Number</option>
			<cfloop query="ctOtherIdType">
				<option value="#ctOtherIdType.other_id_type#">#ctOtherIdType.other_id_type#</option>
			</cfloop>
		</select>
		  </td>
		  <td>
				<font size="-2">Other ID Num:<br></font>		
				<input type="text" name="oidNumber" class="reqdClr" size="8" 
					onChange="findCatalogedItem('related_coll_object_id','catColl','newRelationship',other_id_type.value,this.value,collection.value); return false;"
					onKeyPress="return noenter(event);">
		  </td>
		  <td id="saveNewCell" style="display:none;">
		  	<font size="-2">&nbsp;<br></font>		
			<input type="submit" id="theSubmit" 
					 	value="Save" 
						class="savBtn"
   						onmouseover="this.className='savBtn btnhov'" 
						onmouseout="this.className='savBtn'"></td>
		</form>
	
	</tr>
</table>
</cfoutput>

<!------------------------------------------------------------------------------>
<cfif #Action# is "saveNew">
<cfoutput>
	<cfloop list="#related_coll_object_id#" index="relCollObjId" delimiters=",">
		<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO biol_indiv_relations (
			 COLLECTION_OBJECT_ID,
			 RELATED_COLL_OBJECT_ID,
			 BIOL_INDIV_RELATIONSHIP )
			VALUES (     
			#COLLECTION_OBJECT_ID#,
			 #relCollObjId#,
			 '#biol_indiv_relationship#' )
		</cfquery>
	</cfloop>
	<cf_logEdit collection_object_id="#collection_object_id#">
	
		 <cflocation url="editRelationship.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------>
<cfif #Action# is "saveEdit">
<cfoutput>
	<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE biol_indiv_relations
	SET
	collection_object_id = #collection_object_id#,
	RELATED_COLL_OBJECT_ID = #RELATED_COLL_OBJECT_ID#,
		 BIOL_INDIV_RELATIONSHIP='#BIOL_INDIV_RELATIONSHIP#'
		WHERE
		collection_object_id = #collection_object_id# AND
	RELATED_COLL_OBJECT_ID = #origRelCollObjId# AND
		 BIOL_INDIV_RELATIONSHIP='#origReln#'
	</cfquery>
	<cf_logEdit collection_object_id="#collection_object_id#">
		 <cflocation url="editRelationship.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------>
<!------------------------------------------------------------------------------>
<cfif #Action# is "deleReln">
<cfoutput>
	<cfquery name="newReln" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	DELETE FROM biol_indiv_relations WHERE
		collection_object_id = #collection_object_id# AND
	RELATED_COLL_OBJECT_ID = #origRelCollObjId# AND
		 BIOL_INDIV_RELATIONSHIP='#origReln#'
	</cfquery>
	<cf_logEdit collection_object_id="#collection_object_id#">
		 <cflocation url="editRelationship.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------>

<cfoutput>
<script type="text/javascript" language="javascript">
		changeStyle('#thisRec.institution_acronym#');
		parent.dyniframesize();
</script>
</cfoutput>