<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfoutput>
<cfset sel="select 
		cat_num,
		collection.collection,
		cataloged_item.collection_object_id,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.customOtherIdentifier#') CustomID,
		part_name,
		coll_obj_cont_hist.container_id,
		COLL_OBJ_DISPOSITION,
		decode(SAMPLED_FROM_OBJ_ID,
			NULL,'no',
			'yes') is_subsample	">
<cfset frm=" FROM
		cataloged_item,
		collection,
		specimen_part,
		coll_obj_cont_hist,
		coll_object">		
<cfset whr=" WHERE cataloged_item.collection_id = collection.collection_id AND
		cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
		specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id and
		specimen_part.collection_object_id = coll_object.collection_object_id ">	

		
<cfif isdefined("transaction_id") and len(#transaction_id#) gt 0>
	<cfset frm="#frm# ,loan_item">
	<cfset whr="#whr# AND specimen_part.collection_object_id = loan_item.collection_object_id and
			loan_item.transaction_id = #transaction_id#">
<cfelseif isdefined("container_id") and len(#container_id#) gt 0>
	<cfset whr="#whr# AND coll_obj_cont_hist.container_id in (#container_id#)">
<cfelseif isdefined("collection_object_id") and len(#collection_object_id#) gt 0>
	<cfset whr="#whr# AND cataloged_item.collection_object_id in (#container_id#)">
</cfif>		
<cfset sql="#sel# #frm# #whr#">
<cfquery name="allCatItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
<cfset a=1>
<table border id="t" class="sortable">
	<th>
		Cataloged Item
	</th>
	<th>
		#session.customOtherIdentifier#
	</th>
	<th>
		Part Name
	</th>
	<th>
		Location
	</th>
	<th>Disposition</th>
<cfloop query="allCatItems">
	<cfquery name="freezer" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			CONTAINER_ID,
			PARENT_CONTAINER_ID,
			CONTAINER_TYPE,
			DESCRIPTION,
			PARENT_INSTALL_DATE,
			CONTAINER_REMARKS,
			label,
			level
		 from container
		start with container_id=#container_id#
		connect by prior parent_container_id = container_id 
		order by level DESC
	</cfquery>
		<tr	#iif(a MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
			<td>#collection# #cat_num#</td>
			<td>#CustomID#&nbsp;</td>
			<td>
				#part_name# <cfif #is_subsample# is "yes">(subsample)</cfif>
			</td>
			<td>
				<cfloop query="freezer">
					<cfif #CONTAINER_TYPE# is "position">
						<span style="font-weight:bold;">[#label#]</span>
					<cfelse>
						[#label#]
					</cfif>
				</cfloop>
			</td>
			<td>#coll_obj_disposition#</td>
		</tr>
		<cfset a=#a#+1>
</cfloop>
</table>
</cfoutput>