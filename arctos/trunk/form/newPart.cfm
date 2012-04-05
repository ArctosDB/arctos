<cfinclude template="/includes/_pickHeader.cfm">
<cfoutput>
	<cfquery name="ctcontainer_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select container_type from ctcontainer_type
		order by container_type
	</cfquery>
	<cfquery name="ctcoll_obj_disposition" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select coll_obj_disposition from ctcoll_obj_disp
	</cfquery>
	<cfquery name="thisCC" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection.collection_cde from collection,cataloged_item where cataloged_item.collection_id=collection.collection_id and
		cataloged_item.collection_object_id=#collection_object_id#
	</cfquery>

	<cfquery name="defaults" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			part_name,
			lot_count,
			coll_obj_disposition,
			condition,
			collection.collection_cde
		from
			specimen_part,
			coll_object,
			cataloged_item,
			collection
		where
			specimen_part.collection_object_id=coll_object.collection_object_id and
			specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
			cataloged_item.collection_id=collection.collection_id and
			cataloged_item.collection_id=#collection_object_id# and
			rownum=1
			<cfif isdefined("part") and len(part) gt 0>
				and part_name='#part#'
			</cfif>
	</cfquery>
<form name="newPart" method="post" action="/form/newPart.cfm">
	<input type="hidden" name="action" value="newPart">
	<input type="hidden" name="collection_object_id" id="collection_object_id" value="#collection_object_id#">
	<input type="hidden" name="collection_id" value="#collection_id#">
	<label for="npart_name">Part Name</label>
	<input type="text" name="npart_name" id="npart_name" class="reqdClr"
		value="#defaults.part_name#" size="25"
		onchange="findPart(this.id,this.value,'#thisCC.collection_cde#');" 
		onkeypress="return noenter(event);">
	<label for="lot_count">Lot Count</label>
	<input type="text" name="lot_count" id="lot_count" class="reqdClr" size="2" value="#defaults.lot_count#">
	<label for="coll_obj_disposition">Disposition</label>
	<select name="coll_obj_disposition" id="coll_obj_disposition" size="1"  class="reqdClr">
    	<cfloop query="ctcoll_obj_disposition">
        	<option
				<cfif defaults.coll_obj_disposition is ctcoll_obj_disposition.coll_obj_disposition>selected="selected"</cfif>
				value="#coll_obj_disposition#">#coll_obj_disposition#</option>
        </cfloop>
    </select>
	<label for="condition">Condition</label>
	<input type="text" name="condition" id="condition" class="reqdClr" value="#defaults.condition#">
	<label for="coll_object_remarks">Remarks</label>
	<input type="text" name="coll_object_remarks" id="coll_object_remarks">
	<label for="barcode">Barcode</label>
	<input type="text" name="barcode" id="barcode">
	<label for="new_container_type">Change barcode to Container Type</label>
	<select name="new_container_type" id="new_container_type" size="1">
    	<cfloop query="ctcontainer_type">
        	<option value="#container_type#">#container_type#</option>
        </cfloop>
    </select>
	<br><input type="button" value="Create" class="insBtn" onclick="makePart();">   
  </form>
</cfoutput>