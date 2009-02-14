<cfif #action# is "nothing">
<script>
function setAll(val) {
	 for (var i = 0; i<document.theForm.elements.length; i++) {
      
        if ((document.theForm.elements[i].type == 'radio')) {
        	if (document.theForm.elements[i].value == val) {
				document.theForm.elements[i].checked = true;
			}
			else {
				document.theForm.elements[i].checked = false;
			}
		} 
    }
}
</script>
<cfinclude template="/includes/_header.cfm">
<cfset title = "Manage Print Flag">
<cfoutput>
	<h4>Update Print Flags</h4>
	<cfquery name="getStuff" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT
		cataloged_item.collection_object_id catItemId,
		specimen_part.collection_object_id as partID,
		part_name,
		collection.institution_acronym,
		coll_obj_disposition,
		condition,
		part_modifier,
		preserve_method,
		sampled_from_obj_id,
		collection.collection_cde,
		cat_num,
		lot_count,
		parentContainer.barcode,
		parentContainer.label,
		parentContainer.container_id AS parentContainerId,
		thisContainer.container_id AS partContainerId,
		parentContainer.print_fg,
		coll_object_remarks,
		is_tissue,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#')  CustomID
	FROM
		cataloged_item
		INNER JOIN collection ON (cataloged_item.collection_id = collection.collection_id)
		INNER JOIN specimen_part ON (cataloged_item.collection_object_id = specimen_part.derived_from_cat_item)
		INNER JOIN coll_object ON (specimen_part.collection_object_id = coll_object.collection_object_id)
		INNER JOIN coll_obj_cont_hist ON (specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id)
		INNER JOIN container thisContainer ON (coll_obj_cont_hist.container_id = thisContainer.container_id)
		LEFT OUTER JOIN container parentContainer ON (thisContainer.parent_container_id = parentContainer.container_id)
		LEFT OUTER JOIN coll_object_remark ON (specimen_part.collection_object_id = coll_object_remark.collection_object_id)		
	WHERE
		cataloged_item.collection_object_id IN ( #collection_object_id# )
	ORDER BY sampled_from_obj_id DESC,part_name ASC
</cfquery>
<form name="theForm" method="post" action="printFlag.cfm">
	<input type="hidden" name="action" value="setFlags">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
<table border>
	<tr>
		<th>
			Cat Num
		</th>
		<th>
			#session.CustomOtherIdentifier#
		</th>
		<th>Part Name</th>
		<th>
			Container
			<br><span onclick="setAll(1);" style="font-size:.8em;" class="likeLink">check all</span>
		</th>
		<th>
			Vial
			<br><span onclick="setAll(2);" style="font-size:.8em;" class="likeLink">check all</span>
		</th>
		<th>
			None
			<br><span onclick="setAll(0);" style="font-size:.8em;" class="likeLink">check all</span>
		</th>
	</tr>

<cfloop query="getStuff">
<tr>
	<td>
		<a href="/SpecimenDetail.cfm?collection_object_id=#catItemId#">#institution_acronym# #collection_cde# #cat_num#</a>
	</td>
	<td>#CustomID#&nbsp;</td>
	<td>#part_name#</td>
	
	<td>
		<input type="radio" name="print_fg#partID#"  value="1"
			<cfif #print_fg# is 1>checked</cfif>>
	</td>
	<td>
		<input type="radio" name="print_fg#partID#"  value="2"
			<cfif #print_fg# is 2>checked</cfif>>
	</td>
	<td>
		<input type="radio" name="print_fg#partID#" value="0"
			<cfif #print_fg# neq 1 AND #print_fg# neq 2>checked</cfif>>
	</td>
</tr>
</cfloop>
<tr>
	<td colspan="6" align="center">
		 <input type="submit" value="Save All" class="insBtn"
  			onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">	
		<input type="button" value="Refresh" class="lnkBtn"
  			onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
			onclick="document.location='printFlag.cfm?collection_object_id=#collection_object_id#'";>	
	</td>
</tr>
</table>
</form>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
</cfif>
<cfif #action# is "setFlags">
	<cfdump var="#form#">
	<cfoutput >
		<cfloop list="#form.fieldnames#" index="i">
			<cfif left(i,8) is "print_fg">
				<cfset thisPartId = replace(lcase(i),"print_fg","","all")>
				<cfset thisPrintFlag = evaluate("#i#")>
				<cfquery name="upCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update container set print_fg = #thisPrintFlag#
					where container_id = (select parent_container_id from 
					container,coll_obj_cont_hist where
					container.container_id = coll_obj_cont_hist.container_id and
					collection_object_id = #thisPartId#)
				</cfquery>
			</cfif>
		</cfloop>
	</cfoutput>
	<cflocation url="printFlag.cfm?collection_object_id=#collection_object_id#">
</cfif>