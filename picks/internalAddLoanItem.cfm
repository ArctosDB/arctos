
<cfset title = "Add loan item">
<cfinclude template="../includes/_pickHeader.cfm"><body bgcolor="#FFFBF0" text="midnightblue" link="blue" vlink="midnightblue">
 <cfif not isdefined("collection_object_id")>
	Didn't get a collection_object_id.<cfabort>
</cfif>

<cfif  isdefined("transaction_id")>

<cfif #Action# is "nothing">
<cfoutput>
<cfquery name="getLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select loan_num_prefix, loan_num, loan_num_suffix from loan where transaction_id = #transaction_id#
</cfquery>
<cfset thisLoan = "#getLoan.loan_num_prefix# #getLoan.loan_num# #getLoan.loan_num_suffix#">
<cfquery name="details" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection_cde, cat_num from cataloged_item, specimen_part where
	cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
	specimen_part.collection_object_id = #collection_object_id#
</cfquery>
Add #details.collection_cde# #details.cat_num# #item# to loan #thisLoan#


<form name="additems" method="post" action="internalAddLoanItem.cfm">
	<input type="hidden" name="Action" value="AddItem">
	<input type="hidden" name="isSubsample">
	<input type="hidden" name="transaction_id" value="#transaction_id#">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<input type="hidden" name="cat_num" value="#details.cat_num#">
	<input type="hidden" name="item" value="#item#">
	<input type="hidden" name="thisLoan" value="#thisLoan#">
	<input type="hidden" name="collection_cde" value="#details.collection_cde#">
	
	<br>Item instructions: 
	<textarea name="ITEM_INSTRUCTIONS" cols="40" rows="4"></textarea>
	<br>Item remarks: 
	<textarea name="LOAN_ITEM_REMARKS" cols="40" rows="4"></textarea>
	<br>
	<input type="button"  class="insBtn"
   						onmouseover="this.className='insBtn btnhov'" onMouseOut="this.className='insBtn'"
						onClick="additems.isSubsample.value='n';submit();" value="Add whole item">
						
<input type="button"  class="insBtn"
   						onmouseover="this.className='insBtn btnhov'" onMouseOut="this.className='insBtn'"
						 onClick="additems.isSubsample.value='y';submit();" value="Add subsample">										
												
												
</form>



</cfoutput>
</cfif>

<cfif #Action# is "AddItem">
	<cfoutput>
	<cfquery name="details" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_cde, cat_num from cataloged_item, specimen_part where
		cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
		specimen_part.collection_object_id = #collection_object_id#
	</cfquery>
	<cfquery name="RECONCILED_BY_PERSON_ID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_id from agent_name where agent_name = '#session.username#'
		</cfquery>
		<cfif len(#RECONCILED_BY_PERSON_ID.agent_id#) is 0>
			You are not logged in as a recognized agent. Your login ID (#session.username#)
			must be entered in the agent names table as type 'login'.
			<cfabort>
		</cfif>
		<cfset RECONCILED_DATE = #dateformat(now(),"dd-mmm-yyyy")#>
<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>

	<cfif #isSubsample# is "y">
		<!--- make a subsample --->
		<cfquery name="parentData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				coll_obj_disposition, 
				condition,
				part_name,
				derived_from_cat_item
			FROM
				coll_object, specimen_part
			WHERE 
				coll_object.collection_object_id = specimen_part.collection_object_id AND
				coll_object.collection_object_id = #collection_object_id#
		</cfquery>
		<cfquery name="newCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
				(sq_collection_object_id.nextval,
				'SS',
				#RECONCILED_BY_PERSON_ID.agent_id#,
				'#RECONCILED_DATE#',
				#RECONCILED_BY_PERSON_ID.agent_id#,
				'#RECONCILED_DATE#',
				'#parentData.coll_obj_disposition#',
				1,
				'#parentData.condition#')
		</cfquery>
		<cfquery name="newPart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO specimen_part (
				COLLECTION_OBJECT_ID
				,PART_NAME
				,SAMPLED_FROM_OBJ_ID
				,DERIVED_FROM_CAT_ITEM)
			VALUES (
				sq_collection_object_id.currval
				,'#parentData.part_name#'
				,#collection_object_id#
				,#parentData.derived_from_cat_item#)				
		</cfquery>
		
	
	</cfif>
	<cfquery name="addLoanItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	
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
		<cfif #isSubsample# is "y">
			#nextID.nextID#,
		<cfelse>
			#COLLECTION_OBJECT_ID#,
		</cfif>		
		#RECONCILED_BY_PERSON_ID.agent_id#,
		'#RECONCILED_DATE#'
		,'#details.collection_cde# #details.cat_num# #item#'
		<cfif isdefined("ITEM_INSTRUCTIONS") AND len(#ITEM_INSTRUCTIONS#) gt 0>
			,'#ITEM_INSTRUCTIONS#'
		</cfif>
		<cfif isdefined("LOAN_ITEM_REMARKS") AND len(#LOAN_ITEM_REMARKS#) gt 0>
			,'#LOAN_ITEM_REMARKS#'
		</cfif>
		)
		</cfquery>
		
		<cfquery name="setDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE coll_object SET coll_obj_disposition = 'on loan'
			where collection_object_id = 
			<cfif #isSubsample# is "y">
				#nextID.nextID#
			<cfelse>
				#COLLECTION_OBJECT_ID#
			</cfif>
		</cfquery>

	<cfif isdefined("selfClose") and #selfClose# is "y">
		<script language="JavaScript">
		self.close();
	</script>
	<cfabort>
	</cfif>
	
		You have added #collection_cde# #cat_num# #item# to loan #thisLoan#.
		<br> Click <a href="##" onClick="self.close();">here</a> to close this window.
</cfoutput>
</cfif>
</cfif>

<cfinclude template="../includes/_pickFooter.cfm">