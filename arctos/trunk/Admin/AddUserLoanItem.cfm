<cfoutput>
	<cfif len(#rejection_reason#) gt 0 OR len(#default_rejection_reason#) gt 0>
		<cfif len(#rejection_reason#) gt 0>
			<cfset reason = "#rejection_reason#">
		<cfelse>
			<cfset reason = "#default_rejection_reason#">
		</cfif>
		<cfquery name="nope" datasource="#Application.uam_dbo#">
		UPDATE cf_loan_item SET rejection_reason = '#reason#'
		WHERE loan_id = #loan_id# AND
		collection_object_id=#collection_object_id#
		</cfquery>
	<cfelse><!--- loan item approved ---->
	
		<cfquery name="recBy" datasource="#Application.uam_dbo#">
			select agent_id from agent_name where agent_name = '#client.username#'
		</cfquery>
		<cfif #recBy.recordcount# is not 1>
			Something hinky happened with your username!
			<cfabort>
		</cfif>
		<cfif len(#ITEM_DESCR#) is 0>
			<cfquery name="desc" datasource="#Application.uam_dbo#">
				SELECT 
					cat_num,
					collection.collection_cde,
					institution_acronym,
					coll_obj_disposition, 
					condition,
					part_name,
					part_modifier,
					PRESERVE_METHOD,
					derived_from_cat_item
				FROM
					coll_object, specimen_part,cataloged_item,collection
				WHERE 
					coll_object.collection_object_id = specimen_part.collection_object_id AND
					coll_object.collection_object_id = #collection_object_id# AND
					specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and
					cataloged_item.collection_cde=collection.collection_cde
			</cfquery>
			<cfset ITEM_DESCR = "#desc.institution_acronym# #desc.collection_cde# #desc.cat_num#">
			<cfif len(#desc.part_modifier#) gt 0>
				<cfset ITEM_DESCR = "#ITEM_DESCR# #desc.part_modifier#">
			</cfif>
				<cfset ITEM_DESCR = "#ITEM_DESCR# #desc.part_name#">
			<cfif len(#desc.PRESERVE_METHOD#) gt 0>
				<cfset ITEM_DESCR = "#ITEM_DESCR# (#desc.PRESERVE_METHOD#)">
			</cfif>
		</cfif>
	<cfset thisDate = #dateformat(now(),"dd-mmm-yyyy")#>
		<!--- reverse any previous rejections --->
		<cfquery name="nomakeupmind" datasource="#Application.uam_dbo#">
			UPDATE cf_loan_item SET rejection_reason = null
			WHERE loan_id = #loan_id# AND
			collection_object_id=#collection_object_id#
		</cfquery>
		
		<cfif #use_type# is "subsample">
			<!--- make a new part --->
			<cfquery name="nextID" datasource="#Application.uam_dbo#">
			select max(collection_object_id) + 1 as nextID from coll_object
		</cfquery>
		<cfquery name="parentData" datasource="#Application.uam_dbo#">
			SELECT 
				coll_obj_disposition, 
				condition,
				part_name,
				part_modifier,
				PRESERVE_METHOD,
				derived_from_cat_item
			FROM
				coll_object, specimen_part
			WHERE 
				coll_object.collection_object_id = specimen_part.collection_object_id AND
				coll_object.collection_object_id = #collection_object_id#
		</cfquery>
		<cfquery name="newCollObj" datasource="#Application.uam_dbo#">
			INSERT INTO coll_object (
				COLLECTION_OBJECT_ID,
				COLL_OBJECT_TYPE,
				ENTERED_PERSON_ID,
				COLL_OBJECT_ENTERED_DATE,
				LAST_EDITED_PERSON_ID,
				LAST_EDIT_DATE,
				COLL_OBJ_DISPOSITION,
				LOT_COUNT,
				CONDITION)
			VALUES
				(#nextID.nextID#,
				'SS',
				#RECONCILED_BY_PERSON_ID.agent_id#,
				'#RECONCILED_DATE#',
				#RECONCILED_BY_PERSON_ID.agent_id#,
				'#RECONCILED_DATE#',
				'on loan',
				1,
				'#parentData.condition#')
		</cfquery>
		<cfquery name="newPart" datasource="#Application.uam_dbo#">
			INSERT INTO specimen_part (
				COLLECTION_OBJECT_ID
				,PART_NAME
				<cfif len(#parentData.PART_MODIFIER#) gt 0>
					,PART_MODIFIER,
				</cfif>
				,SAMPLED_FROM_OBJ_ID
				<cfif len(#parentData.PRESERVE_METHOD#) gt 0>
					,PRESERVE_METHOD
				</cfif>
				,DERIVED_FROM_CAT_ITEM)
			VALUES (
				#nextID.nextID#
				,'#parentData.part_name#'
				<cfif len(#parentData.PART_MODIFIER#) gt 0>
					,'#parentData.PART_MODIFIER#'
				</cfif>
				,#collection_object_id#
				<cfif len(#parentData.PRESERVE_METHOD#) gt 0>
					,'#parentData.PRESERVE_METHOD#'
				</cfif>
				,'#parentData.DERIVED_FROM_CAT_ITEM#')				
		</cfquery>
		<cfquery name="yep" datasource="#Application.uam_dbo#">
					INSERT INTO loan_item (
						TRANSACTION_ID ,
						COLLECTION_OBJECT_ID,
						RECONCILED_BY_PERSON_ID,
						RECONCILED_DATE,
						ITEM_DESCR
							<cfif len(#item_instructions#) gt 0>
								,item_instructions
							</cfif>
							<cfif len(#loan_item_remarks#) gt 0>
								,loan_item_remarks
							</cfif>    
					) VALUES (
						#transaction_id#,
						#nextID.nextID#,
						#recBy.agent_id#,
						'#thisDate#',
						'#ITEM_DESCR#'
							<cfif len(#item_instructions#) gt 0>
								,'#item_instructions#'
							</cfif>
							<cfif len(#loan_item_remarks#) gt 0>
								,'#loan_item_remarks#'
							</cfif>                            
						)
				</cfquery>
		<cfelse>
			<cfquery name="yep" datasource="#Application.uam_dbo#">
					INSERT INTO loan_item (
						TRANSACTION_ID ,
						COLLECTION_OBJECT_ID,
						RECONCILED_BY_PERSON_ID,
						RECONCILED_DATE,
						ITEM_DESCR
							<cfif len(#item_instructions#) gt 0>
								,item_instructions
							</cfif>
							<cfif len(#loan_item_remarks#) gt 0>
								,loan_item_remarks
							</cfif>    
					) VALUES (
						#transaction_id#,
						#collection_object_id#,
						#recBy.agent_id#,
						'#thisDate#',
						'#ITEM_DESCR#'
							<cfif len(#item_instructions#) gt 0>
								,'#item_instructions#'
							</cfif>
							<cfif len(#loan_item_remarks#) gt 0>
								,'#loan_item_remarks#'
							</cfif>                            
						)
				</cfquery>
		</cfif>
		
	</cfif>
	<script>
		self.close();
	</script>
</cfoutput>