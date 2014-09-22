<cfinclude template="/includes/_pickHeader.cfm">
<cfoutput>
	<cfif not isdefined("ret_val_id")>
	<cfset ret_val_id =''>
</cfif>
<cfif not isdefined("ret_id_id")>
	<cfset ret_id_id =''>
</cfif>
<cfif not isdefined("guid_prefix")>
	<cfset guid_prefix =''>
</cfif>
<cfif not isdefined("collection_id")>
	<cfset collection_id =''>
</cfif>
<cfif not isdefined("part")>
	<cfset part =''>
</cfif>
<cfif not isdefined("id_type")>
	<cfset id_type =''>
</cfif>
<cfif not isdefined("id_value")>
	<cfset id_value =''>
</cfif>
</cfoutput>
<div id="thisWholePage">
<cfif action is "nothing">
<cfoutput>
	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select guid_prefix,collection_id from collection group by guid_prefix,collection_id order by guid_prefix,collection_id 
	</cfquery>
	<cfquery name="ctOID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select other_id_type from ctcoll_other_id_type group by other_id_type order by other_id_type 
	</cfquery>
	<cfif isdefined("institution_acronym") and len(institution_acronym) gt 0 
		and isdefined("collection_cde") and len(collection_cde) gt 0>
		<cfquery name="cidl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select collection_id from collection where 
			guid_prefix='#guid_prefix#'
		</cfquery>
		
		<cfdump var=#cidl#>
		<cfif cidl.recordcount is 1>
			<cfset collection_id=cidl.collection_id>
		</cfif>
	</cfif>
	<form action="/picks/partPick.cfm" method="post" id="theForm" onsubmit="return false">
		<input type="hidden" name="action" id="action" value="srch">
		<input type="hidden" name="ret_val_id" id="ret_val_id" value="#ret_val_id#">
		<input type="hidden" name="ret_id_id" id="ret_id_id" value="#ret_id_id#">
		<label for="collection_id">Collection</label>
		<select name="collection_id" id="collection_id" size="1">
			<cfloop query="ctcollection">
				<option 
					<cfif ctcollection.collection_id is cidl.collection_id> selected="selected" </cfif> 
					value="#collection_id#">#guid_prefix#</option>
			</cfloop>
		</select>
		<label for="part">Part</label>
		<input type="text" name="part" id="part" class="reqdClr"
			value="#part#" size="25"
			onchange="findPart(this.id,this.value,'#collection_cde#');" 
			onkeypress="return noenter(event);">
		<label for="id_type">Identifier Type</label>
		<select name="id_type" id="id_type" size="1">
			<option <cfif id_type is 'catalog_number'> selected="selected" </cfif> 
					value="catalog_number">catalog_number</option>
			<cfloop query="ctOID">
				<option 
					<cfif ctOID.other_id_type is id_type> selected="selected" </cfif> 
					value="#other_id_type#">#other_id_type#</option>
			</cfloop>
		</select>
		<label for="id_value">Identifier Number</label>
		<input type="text" name="id_value" id="id_value" value="#id_value#">
		<br><input type="button" class="lnkBtn" value="Find Part" onclick="locationSubmit('theForm')">
		<input type="button" class="qutBtn" value="nevermind..." onclick="thisOne('#ret_val_id#','#ret_id_id#','','')">
	</form>
</cfoutput>
</cfif>
<cfif action is "srch">
<cfoutput>
	<cfset s="select 
			cat_num,
			collection.guid_prefix,
			cataloged_item.collection_object_id,
			specimen_part.collection_object_id partID,
			COLL_OBJECT_REMARKS,
			COLL_OBJ_DISPOSITION,
			CONDITION,
			DISPOSITION_REMARKS,
			LOT_COUNT,
			PART_NAME,
			SAMPLED_FROM_OBJ_ID,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			nvl(p1.barcode,'NOBARCODE') barcode 
		from 
			collection,
			cataloged_item,
			specimen_part,
			coll_object,
			coll_object_remark,
			coll_obj_other_id_num,
			coll_obj_cont_hist,
			container p0,
			container p1">
			
	<cfset s=s & " where collection.collection_id=cataloged_item.collection_id and ">
	<cfset s=s & " cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and ">
	<cfset s=s & " specimen_part.collection_object_id=coll_object.collection_object_id and ">
	<cfset s=s & " coll_object.collection_object_id=coll_object_remark.collection_object_id (+) and ">
	<cfset s=s & " cataloged_item.collection_object_id=coll_obj_other_id_num.collection_object_id (+) and 
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id (+) and
			coll_obj_cont_hist.container_id=p0.container_id (+) and
			p0.parent_container_id=p1.container_id (+)">
	<cfset s=s & " and rownum < 100 ">
	<cfif isdefined("collection_id") and len(#collection_id#) gt 0>
		<cfset s=s & " and collection.collection_id=#collection_id# ">
	</cfif>
	<cfif isdefined("part") and len(#part#) gt 0>
		<cfset s=s & " and specimen_part.part_name='#part#' ">
	</cfif>
	<cfif isdefined("id_type") and len(#id_type#) gt 0>
		<cfif isdefined("collection_id") and id_type is not "catalog_number">
			<cfset s=s & " and coll_obj_other_id_num.other_id_type='#id_type#' ">
		</cfif>
	</cfif>
	<cfif isdefined("id_value") and len(#id_value#) gt 0>
		<cfif isdefined("id_type") and id_type is "catalog_number">
			<cfset s=s & " and cataloged_item.cat_num='#id_value#' ">
		<cfelse>
			<cfset s=s & " and upper(coll_obj_other_id_num.display_value) like '%#ucase(id_value)#%' ">
		</cfif>
	</cfif>
	<cfset s=s & " group by
			cat_num,
			collection.guid_prefix,
			cataloged_item.collection_object_id,
			specimen_part.collection_object_id,
			COLL_OBJECT_REMARKS,
			COLL_OBJ_DISPOSITION,
			CONDITION,
			DISPOSITION_REMARKS,
			LOT_COUNT,
			PART_NAME,
			SAMPLED_FROM_OBJ_ID,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#'),
			p1.barcode">
	<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(s)#
	</cfquery>
	<cfif data.recordcount is 0>
		No results.
	<cfelse>
		<table border>
			<tr>
				<th>Part</th>
				<cfif len(#session.CustomOtherIdentifier#) gt 0 >
					<th>#session.CustomOtherIdentifier#</th>
				</cfif>
				<th></th>
			</tr>
			<cfloop query="data">
				<tr>
					<td>
						#guid_prefix# #cat_num# #PART_NAME# [#barcode#]				
					</td>
					<cfif len(#session.CustomOtherIdentifier#) gt 0 >
						<td>#CustomID#</td>
					</cfif>
					
					<td>
						<span class="likeLink" onclick="thisOne('#ret_val_id#','#ret_id_id#','#partID#','#part_name#')">Select</span>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cfoutput>
</cfif>
</div>
<cfinclude template="../includes/_pickFooter.cfm">
