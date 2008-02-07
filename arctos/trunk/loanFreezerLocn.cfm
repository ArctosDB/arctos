<cfinclude template="/includes/alwaysInclude.cfm">
<cfoutput>
<cfquery name="allCatItems" datasource="#Application.web_user#">
	select 
		cat_num,
		institution_acronym,
		collection.collection_cde,
		cataloged_item.collection_object_id,
		concatSingleOtherId(cataloged_item.collection_object_id,'#Client.customOtherIdentifier#') CustomID
	FROM	
		loan_item,
		specimen_part,
		cataloged_item,
		collection
	where 
		cataloged_item.collection_id = collection.collection_id AND
		cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
		loan_item.collection_object_id = specimen_part.collection_object_id AND
		loan_item.transaction_id = #transaction_id#
	GROUP BY
		cat_num,
		institution_acronym,
		collection.collection_cde,
		cataloged_item.collection_object_id,
		concatSingleOtherId(cataloged_item.collection_object_id,'#Client.customOtherIdentifier#')
	ORDER BY cat_num
</cfquery>
<cfset a=1>
<table border="1">
	<th>
		Cataloged Item
	</th>
	<th>
		#Client.customOtherIdentifier#
	</th>
	<th>
		Part Name
	</th>
	<th>
		Location
	</th>
<cfloop query="allCatItems">
	 <tr	#iif(a MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
		<cfquery name="thisItems" datasource="#Application.web_user#">
			select
				part_name,
				coll_obj_cont_hist.container_id,
				decode(loan_item.collection_object_id,
					NULL,'no',
					'yes') is_loan_item,
				decode(SAMPLED_FROM_OBJ_ID,
					NULL,'no',
					'yes') is_subsample			
			FROM
				specimen_part,
				coll_obj_cont_hist,
				(select collection_object_id,transaction_id from loan_item where transaction_id = #transaction_id#) loan_item
			WHERE
				specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id AND
				specimen_part.collection_object_id = loan_item.collection_object_id (+) AND
				specimen_part.derived_from_cat_item = #collection_object_id#	
		</cfquery>
	
		<td rowspan="#thisItems.recordcount#">
			#institution_acronym# #collection_cde# #cat_num#
		</td>
		<td rowspan="#thisItems.recordcount#">
			#CustomID#
		</td>
		<cfset i=1>
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
			<cfif #i# gt 1>
				<tr	#iif(a MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
			</cfif>
				<cfif #is_loan_item# is "yes">
					<cfset thisStyle = "">
				<cfelse>
					<cfset thisStyle = 'style="font-size:small;font-style:italic;"'>
				</cfif>
				<td>
					<span #thisStyle#>
						#part_name# <cfif #is_subsample# is "yes">subsample</cfif>
					</span>
				</td>
				<td>
					<span #thisStyle#>
			<cfloop query="freezer">
				
					<cfif #CONTAINER_TYPE# is "position">
						<span style="font-weight:bold;">
					</cfif>
							[#label#]
					<cfif #CONTAINER_TYPE# is "position">
						</span>
					</cfif>
				
			</cfloop>
				</span>
			</td>
			<cfif #i# gt 1>
				</tr>
			</cfif>
			<cfset i=#i#+1>
		</cfloop>
	</tr>
	<cfset a=#a#+1>
</cfloop>
</table>
	</cfoutput>
	
