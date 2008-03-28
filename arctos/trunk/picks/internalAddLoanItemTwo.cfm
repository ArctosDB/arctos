<style>
	label {
	display:block;
	font-size:10px;
	font-style:italic;
	text-decoration:underline;
	font-weight:800;}
</style>
<cfset title = "Add loan item">
<cfinclude template="../includes/_pickHeader.cfm">

<cfif #Action# is "nothing">
 <cfif not isdefined("collection_object_id")>
	Didn't get a collection_object_id.<cfabort>
</cfif>

<cfif not isdefined("transaction_id") or len(#transaction_id#) is 0>
 Oops! I didn't get a loan. Aborting...
	<cfabort>
</cfif>
<cfoutput>
<cfquery name="getLoan" datasource="#Application.web_user#">
	select institution_acronym, loan_num_prefix, loan_num, loan_num_suffix from loan,trans where 
	loan.transaction_id=trans.transaction_id and trans.transaction_id = #transaction_id#
</cfquery>
<cfset thisLoan = "#getLoan.institution_acronym# #getLoan.loan_num_prefix# #getLoan.loan_num# #getLoan.loan_num_suffix#">
<cfquery name="details" datasource="#Application.web_user#">
	select 
		cataloged_item.COLLECTION_OBJECT_ID,
		specimen_part.collection_object_id partID,
		CAT_NUM,
		COLLECTION,
		COLL_OBJ_DISPOSITION,
		LOT_COUNT,
		CONDITION,
		PART_NAME,
		PART_MODIFIER,
		SAMPLED_FROM_OBJ_ID,
		PRESERVE_METHOD,
		IS_TISSUE,
		concatSingleOtherId(cataloged_item.collection_object_id,'#Client.CustomOtherIdentifier#') AS CustomID,
		concatEncumbrances(cataloged_item.collection_object_id) as encumbrance_action
	from
		cataloged_item,
		collection,
		coll_object,
		specimen_part
	where
		cataloged_item.COLLECTION_ID=collection.COLLECTION_ID and
		cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
		specimen_part.collection_object_id =coll_object.collection_object_id and
		cataloged_item.collection_object_id = #collection_object_id#
</cfquery>
<div style="font-size:.8em;">
Specimen: <a href="/SpecimenDetails.cfm?collection_object_id=#collection_object_id#" target="_blank"></a>#details.COLLECTION# #details.CAT_NUM#
<br>#Client.CustomOtherIdentifier#: <strong>#details.CustomID#</strong>
<br>Encumbrances: <strong>#details.encumbrance_action#</strong>
<br>Loan: <strong>#thisLoan#</strong>
</div>
<table border="1" style="font-size:.8em;">
	<cfset i=1>
<cfloop query="details">
<form name="additems" method="post" action="internalAddLoanItemTwo.cfm">
	<input type="hidden" name="Action" value="AddItem">
	<input type="hidden" name="transaction_id" value="#transaction_id#">
	<input type="hidden" name="partID" value="#details.partID#">
	<input type="hidden" name="cat_num" value="#details.cat_num#">
	<input type="hidden" name="collection" value="#details.collection#">
	<input type="hidden" name="thisLoan" value="#thisLoan#">
	<input type="hidden" name="PART_NAME" value="#PART_NAME#">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		<td>
			<table border="1" width="100%">
				<tr>
					<td>
						<label for="">Part</label>
						#PART_NAME#
					</td>
					<td>
						<label for="">Modifier</label>
						#PART_MODIFIER#&nbsp;
					</td>
					<td>
						<label for="">PresMeth</label>
						#PRESERVE_METHOD#&nbsp;
					</td>
					<td>
						<label for="">Disposition</label>
						#COLL_OBJ_DISPOSITION#
					</td>
					<td>
						<label for="">Condition</label>
						#CONDITION#
					</td>
					<td rowspan="2" valign="center">
						<input type="submit"  class="insBtn"
			   				onmouseover="this.className='insBtn btnhov'" onMouseOut="this.className='insBtn'"
							 value="Add To Loan">		
					</td>	
				</tr>
				<tr>
					<td>
						<label for="">IsSample?</label>
						<cfif len(#SAMPLED_FROM_OBJ_ID#) gt 0>yes<cfelse>no</cfif>
					</td>
					<td>
						<label for="">Tissue?</label>
						<cfif len(#IS_TISSUE#) is 1>yes<cfelse>no</cfif>
					</td>
					<td>
						<label for="">Instructions</label>
						<input type="text" name="ITEM_INSTRUCTIONS">
					</td>
					<td>
						<label for="">Remarks</label>
						<input type="text" name="LOAN_ITEM_REMARKS">
					</td>	
					<td>
						<label for="">Subsample?</label>
						<cfif len(#SAMPLED_FROM_OBJ_ID#) is 0>
							<input type="checkbox" name="isSubSample" value="y">
						<cfelse>
							<input type="hidden" name="isSubSample" value="n">
						</cfif>
					</td>
				</tr>
			</table>
		</td>		
		
		
					
</form>
	</tr>
	<cfset i=#i#+1>
</cfloop>
</table>






</cfoutput>
</cfif>

<cfif #Action# is "AddItem">
<cftransaction>
	<cfoutput>
		<cfif isdefined("isSubsample") and #isSubsample# is "y">
		<!--- make a subsample --->
		<cfquery name="nextID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			select max(collection_object_id) + 1 as nextID from coll_object
		</cfquery>
		<cfquery name="parentData" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			SELECT 
				coll_obj_disposition, 
				condition,
				part_name,
				part_modifier,
				PRESERVE_METHOD,
				derived_from_cat_item,
				is_tissue
			FROM
				coll_object, specimen_part
			WHERE 
				coll_object.collection_object_id = specimen_part.collection_object_id AND
				coll_object.collection_object_id = #partID#
		</cfquery>
		<cfquery name="newCollObj" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
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
				#client.myAgentId#,
				sysdate,
				#client.myAgentId#,
				sysdate,
				'#parentData.coll_obj_disposition#',
				1,
				'#parentData.condition#')
		</cfquery>
		<cfquery name="newPart" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			INSERT INTO specimen_part (
				COLLECTION_OBJECT_ID
				,PART_NAME
				<cfif len(#parentData.PART_MODIFIER#) gt 0>
					,PART_MODIFIER
				</cfif>
				,SAMPLED_FROM_OBJ_ID
				<cfif len(#parentData.PRESERVE_METHOD#) gt 0>
					,PRESERVE_METHOD
				</cfif>
				,DERIVED_FROM_CAT_ITEM,
				is_tissue)
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
				,#parentData.derived_from_cat_item#,
				#parentData.is_tissue#)				
		</cfquery>
		
	
	</cfif>

		<cfquery name="addLoanItem" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">	
	INSERT INTO loan_item (
		TRANSACTION_ID,
		COLLECTION_OBJECT_ID,
		RECONCILED_BY_PERSON_ID,
		RECONCILED_DATE
		,ITEM_DESCR
		<cfif  isdefined("ITEM_INSTRUCTIONS") AND len(#ITEM_INSTRUCTIONS#) gt 0>
			,ITEM_INSTRUCTIONS
		</cfif>
		<cfif  isdefined("LOAN_ITEM_REMARKS") AND len(#LOAN_ITEM_REMARKS#) gt 0>
			,LOAN_ITEM_REMARKS
		</cfif>
		       )
	VALUES (
		#TRANSACTION_ID#,
		<cfif isdefined("isSubsample") and #isSubsample# is "y">
			#nextID.nextID#,
		<cfelse>
			#partID#,
		</cfif>		
		#client.myAgentId#,
		'#thisDate#'
		,'#collection# #cat_num# #part_name#'
		<cfif isdefined("ITEM_INSTRUCTIONS") AND len(#ITEM_INSTRUCTIONS#) gt 0>
			,'#ITEM_INSTRUCTIONS#'
		</cfif>
		<cfif isdefined("LOAN_ITEM_REMARKS") AND len(#LOAN_ITEM_REMARKS#) gt 0>
			,'#LOAN_ITEM_REMARKS#'
		</cfif>
		)
		</cfquery>
		<cfquery name="setDisp" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">			
			UPDATE coll_object SET coll_obj_disposition = 'on loan'
			where collection_object_id = 
		<cfif isdefined("isSubsample") and #isSubsample# is "y">
				#nextID.nextID#
			<cfelse>
				#partID#
			</cfif>
		</cfquery>

	<cfif isdefined("selfClose") and #selfClose# is "y">
		<script language="JavaScript">
		self.close();
	</script>
	<cfabort>
	</cfif>
	
		You have added #collection# #cat_num# #part_name# 
		<cfif isdefined("isSubsample") and #isSubsample# is "y">
			subsample
		</cfif>to loan #thisLoan#.
		<br> Click <a href="##" onClick="self.close();">here</a> to close this window.
</cfoutput>
</cftransaction>
</cfif>

<cfinclude template="/includes/_pickFooter.cfm">