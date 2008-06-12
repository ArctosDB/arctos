<cfinclude template="/includes/alwaysInclude.cfm">
<script src="/includes/sorttable.js"></script>
<cfoutput>
<cfset sel="select 
		cat_num,
		collection.collection,
		cataloged_item.collection_object_id,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.customOtherIdentifier#') CustomID">
<cfset frm=" FROM
		cataloged_item,
		collection">		
<cfset whr=" WHERE cataloged_item.collection_id = collection.collection_id">	
<cfset grp=" GROUP BY
		cat_num,
		collection.collection,
		cataloged_item.collection_object_id,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.customOtherIdentifier#')">
		
<cfif isdefined("transaction_id") and len(#transaction_id#) gt 0>
	<cfset frm="#frm# ,loan_item,specimen_part">
	<cfset whr="#whr# AND cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id = loan_item.collection_object_id and
			loan_item.transaction_id = #transaction_id#">
<cfelseif isdefined("container_id") and len(#container_id#) gt 0>
	<cfset frm="#frm# ,coll_obj_cont_hist,specimen_part">
	<cfset whr="#whr# AND cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id in (#container_id#)">
<cfelseif isdefined("collection_object_id") and len(#collection_object_id#) gt 0>
	<cfset whr="#whr# AND cataloged_item.collection_object_id in (#container_id#)">
</cfif>		
<cfset sql="#sel# #frm# #whr# #grp#">
<cfquery name="allCatItems" datasource="#Application.web_user#">
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
	<cfquery name="thisItems" datasource="#Application.web_user#">
		select
			part_name,
			coll_obj_cont_hist.container_id,
			COLL_OBJ_DISPOSITION,
			decode(SAMPLED_FROM_OBJ_ID,
				NULL,'no',
				'yes') is_subsample			
		FROM
			specimen_part,
			coll_obj_cont_hist,
			coll_object
		WHERE
			specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id AND
			specimen_part.collection_object_id = coll_object.collection_object_id AND
			specimen_part.derived_from_cat_item = #collection_object_id#	
	</cfquery>
	<cfloop query="thisItems">
		<cfquery name="freezer" datasource="#Application.web_user#">
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
	</cfloop>
</tr>
<cfset a=#a#+1>
</cfloop>
</table>
	</cfoutput>
	
