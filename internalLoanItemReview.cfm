 <cf_security access_level="student0">
 
 <cfinclude template="includes/_header.cfm">
<cfquery name="ctDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select coll_obj_disposition from ctcoll_obj_disp
			</cfquery>
<cfif not isdefined("transaction_id")>
	You did something very naughty.<cfabort>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif #Action# is "delete">
	<cfoutput>
	<cfif isdefined("coll_obj_disposition") AND #coll_obj_disposition# is "on loan">
		<!--- see if it's a subsample --->
		<cfquery name="isSSP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select SAMPLED_FROM_OBJ_ID from specimen_part where collection_object_id = #partID#
		</cfquery>
		<cfif #isSSP.SAMPLED_FROM_OBJ_ID# gt 0>
					You cannot remove this item from a loan while it's disposition is "on loan." 
			<br />Use the form below if you'd like to change the disposition and remove the item 
			from the loan, or to delete the item from the database completely.
			
			<form name="cC" method="post" action="internalLoanItemReview.cfm">
				<input type="hidden" name="action" />
				<input type="hidden" name="transaction_id" value="#transaction_id#" />
				<input type="hidden" name="item_instructions" value="#item_instructions#" />
				<input type="hidden" name="loan_item_remarks" value="#loan_item_remarks#" />
				<input type="hidden" name="partID" value="#partID#" />
				<input type="hidden" name="spRedirAction" value="delete" />
				Change disposition to: <select name="coll_obj_disposition" size="1">
					<cfloop query="ctDisp">
						<option value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
					</cfloop>				
				</select>
				<p />
				<input type="button" 
					class="delBtn"
					onmouseover="this.className='delBtn btnhov'"
					onmouseout="this.className='delBtn'"
					value="Remove Item from Loan" 
					onclick="cC.action.value='saveDisp'; submit();" />
				
				<p /><input type="button" 
					class="delBtn"
					onmouseover="this.className='delBtn btnhov'"
					onmouseout="this.className='delBtn'"
					value="Delete Subsample From Database" 
					onclick="cC.action.value='killSS'; submit();"/>
					<p /><input type="button" 
					class="qutBtn"
					onmouseover="this.className='qutBtn btnhov'"
					onmouseout="this.className='qutBtn'"
					value="Discard Changes" 
					onclick="cC.action.value='nothing'; submit();"/>
			</form>
			<cfabort>
			<cfabort>
		<cfelse>
			You cannot remove this item from a loan while it's disposition is "on loan." 
			<br />Use the form below if you'd like to change the disposition and remove the item 
			from the loan.
			
			<form name="cC" method="post" action="internalLoanItemReview.cfm">
				<input type="hidden" name="action" />
				<input type="hidden" name="transaction_id" value="#transaction_id#" />
				<input type="hidden" name="item_instructions" value="#item_instructions#" />
				<input type="hidden" name="loan_item_remarks" value="#loan_item_remarks#" />
				<input type="hidden" name="partID" value="#partID#" />
				<input type="hidden" name="spRedirAction" value="delete" />
				<br />Change disposition to: <select name="coll_obj_disposition" size="1">
					<cfloop query="ctDisp">
						<option value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
					</cfloop>				
				</select>
				<br /><input type="button" 
					class="delBtn"
					onmouseover="this.className='delBtn btnhov'"
					onmouseout="this.className='delBtn'"
					value="Remove Item from Loan" 
					onclick="cC.action.value='saveDisp'; submit();" />
				<br /><input type="button" 
					class="qutBtn"
					onmouseover="this.className='qutBtn btnhov'"
					onmouseout="this.className='qutBtn'"
					value="Discard Changes" 
					onclick="cC.action.value='nothing'; submit();"/>
			</form>
			<cfabort>
		</cfif>
	</cfif>
	<cfquery name="deleLoanItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	DELETE FROM loan_item where collection_object_id = #partID#
		and transaction_id = #transaction_id#
	</cfquery>
		<cflocation url="internalLoanItemReview.cfm?transaction_id=#transaction_id#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->

<cfif #Action# is "killSS">
	<cfoutput>
<cftransaction>
	<cfquery name="deleLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM loan_item WHERE collection_object_id = #partID#
		and transaction_id=#transaction_id#
	</cfquery>
	<cfquery name="delePart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM specimen_part WHERE collection_object_id = #partID#
	</cfquery>
	<cfquery name="delePartCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM coll_object WHERE collection_object_id = #partID#
	</cfquery>
	<cfquery name="delePartRemark" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM coll_object_remark WHERE collection_object_id = #partID#
	</cfquery>
	<cfquery name="getContID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select container_id from coll_obj_cont_hist where
		collection_object_id = #partID#
	</cfquery>
	
	<cfquery name="deleCollCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM coll_obj_cont_hist WHERE collection_object_id = #partID#
	</cfquery>
	<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM container_history WHERE container_id = #getContID.container_id#
	</cfquery>
	<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		DELETE FROM container WHERE container_id = #getContID.container_id#
	</cfquery>
</cftransaction>
	<cflocation url="internalLoanItemReview.cfm?transaction_id=#transaction_id#">
	</cfoutput>

</cfif>
<!-------------------------------------------------------------------------------->

<cfif #Action# is "BulkUpdateDisp">
	<cfoutput>
		<cfquery name="getCollObjId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select collection_object_id FROM loan_item where transaction_id=#transaction_id#
		</cfquery>
		<cfloop query="getCollObjId">
			<cfquery name="upDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE coll_object SET coll_obj_disposition = '#coll_obj_disposition#'
			where collection_object_id = #collection_object_id#
			</cfquery>
		</cfloop>
	<cflocation url="internalLoanItemReview.cfm?transaction_id=#transaction_id#">
	</cfoutput>
</cfif>

<!-------------------------------------------------------------------------------->
<cfif #Action# is "saveDisp">
	<cfoutput>
	<cftransaction>
		<cfquery name="upDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE coll_object SET coll_obj_disposition = '#coll_obj_disposition#'
			where collection_object_id = #partID#
		</cfquery>
		<cfquery name="upItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE loan_item SET
				 transaction_id=#transaction_id#
				<cfif len(#item_instructions#) gt 0>
					,item_instructions = '#item_instructions#'
				<cfelse>
					,item_instructions = null
				</cfif>
				<cfif len(#loan_item_remarks#) gt 0>
					,loan_item_remarks = '#loan_item_remarks#'
				<cfelse>
					,loan_item_remarks = null
				</cfif>
			WHERE
				collection_object_id = #partID# AND
				transaction_id=#transaction_id#
		</cfquery>
	</cftransaction>
	<cfif isdefined("spRedirAction") and len(#spRedirAction#) gt 0>
		<cfset action=#spRedirAction#>
	<cfelse>
		<cfset action="nothing">
	</cfif>
	<cflocation url="internalLoanItemReview.cfm?transaction_id=#transaction_id#&item_instructions=#item_instructions#&partID=#partID#&loan_item_remarks=#loan_item_remarks#&action=#action#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "nothing">
<cfquery name="getPartLoanRequests" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		cat_num, 
		cataloged_item.collection_object_id,
		collection_cde,
		af_num.af_num,
		part_name,
		 part_modifier,
		 preserve_method,
		condition,
		 sampled_from_obj_id,
		 item_descr,
		 item_instructions,
		 loan_item_remarks,
		 coll_obj_disposition,
		 scientific_name,
		 Encumbrance,
		 agent_name,
		 loan_num,
		 loan_num_prefix,
		 loan_num_suffix,
		 specimen_part.collection_object_id as partID,
		 CONCATSINGLEOTHERID(cataloged_item.collection_object_id,'Field Num') as fieldnum	 
	 from 
		loan_item, 
		loan,
		af_num,
		specimen_part, 
		coll_object,
		cataloged_item,
		coll_object_encumbrance,
		encumbrance,
		agent_name,
		identification
	WHERE
		loan_item.collection_object_id = specimen_part.collection_object_id AND
		loan.transaction_id = loan_item.transaction_id AND
		specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
		specimen_part.collection_object_id = coll_object.collection_object_id AND
		coll_object.collection_object_id = coll_object_encumbrance.collection_object_id (+) and
		coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND
		encumbrance.encumbering_agent_id = agent_name.agent_id (+) AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		cataloged_item.collection_object_id = af_num.collection_object_id (+) AND
		identification.accepted_id_fg = 1 AND
	  loan_item.transaction_id = #transaction_id#
	 ORDER BY af_num,cat_num
</cfquery>
<cfquery name="prtCnt" dbtype="query">
	select distinct(collection_object_id) from getPartLoanRequests
</cfquery>
<cfquery name="prtItemCnt" dbtype="query">
	select distinct(partID) from getPartLoanRequests
</cfquery>


<cfset itemcnt=prtItemCnt.recordcount>
<cfset cnt=prtCnt.recordcount>



<cfoutput>
Review items in loan<b>
	<cfif len(#getPartLoanRequests.loan_num#) gt 0>
		#getPartLoanRequests.loan_num_prefix# #getPartLoanRequests.loan_num# #getPartLoanRequests.loan_num_suffix#
	</cfif>
	</b>
	.
	<br>There are #itemcnt# items from #cnt# specimens in this loan.
	
	<form name="BulkUpdateDisp" method="post" action="internalLoanItemReview.cfm">
		<br>Change disposition of all these items to:
		<input type="hidden" name="Action" value="BulkUpdateDisp">
			<input type="hidden" name="transaction_id" value="#transaction_id#">
			<select name="coll_obj_disposition" size="1">
					<cfloop query="ctDisp">
						<option value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
					</cfloop>				
				</select>
				 <input type="submit" value="Update Disposition" class="savBtn"
   onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">	
	</form>
	<p>
		<form name="showMeDaParts" method="post" action="Container.cfm">
		<br>View part location of these items:
		<input type="hidden" name="srch" value="part">
			<input type="hidden" name="loan_trans_id" value="#transaction_id#">
			<input type="submit" value="Locations" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
	</form>
	</p>
</cfoutput>
<table border>
	<tr>
		<td>
			CN
			
		</td>
		<td>
			AF
		</td>
		<td>
			Field Number
		</td>
		
		<td>
			Scientific Name
		</td>
		<td>
			Item
		</td>
		<td>
			Condition
		</td>
		<td>
			Subsample?
		</td>
		
		<td>
			Item Instructions
		</td>
		<td>
			Item Remarks
		</td>
		<td>
			Disposition
		</td>
		
		<td>
			Encumbrance
		</td>
		<td>&nbsp;
			
		</td>
	</tr>
<!---<cfoutput query="getTissLoanRequests">




	<tr>
		<td>
			#collection_cde# #cat_num# &nbsp;
		</td>
		<td>
			#tissue_type#&nbsp;
		</td>
		<td>
			#Condition#&nbsp;
		</td>
		<td>
			#is_subsample_fg#&nbsp;
		</td>
		<td>
			#Item_Descr#
		</td>
		<td>
			#Item_Instructions#
		</td>
		<td>
			#loan_Item_Remarks#
		</td>
		<td>
			#coll_obj_disposition#&nbsp;
		</td>
		<td>
			#scientific_name#&nbsp;
		</td>
		<td>
			#Encumbrance#&nbsp;
		</td>
		<td>
			<form name="remItem" action="internalLoanItemReview.cfm" method="post">
				<input type="hidden" name="Action" value="delete">
				<input type="hidden" name="collection_object_id" value="#collection_object_id#">
				<input type="hidden" name="transaction_id" value="#transaction_id#">
				<input type="submit" value="Remove this item">
			</form>
		</td>
		
	</tr>

</cfoutput>
--->
<cfoutput>
<cfset i=1>
<cfloop query="getPartLoanRequests">





	<tr>
		<td>
			<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#collection_cde# #cat_num#</a>
			
		</td>
		<td>
			#af_num#&nbsp;
		</td>
		<td>
			#fieldnum#&nbsp;
		</td>		
		<td>
			<em>#scientific_name#</em>&nbsp;
		</td>
		<td>
			<cfset thisPart=#part_name#>
			<cfif len(#part_modifier#) gt 0>
				<cfset thisPart="#part_modifier# #thisPart#">
			</cfif>
			<cfif len(#preserve_method#) gt 0>
				<cfset thisPart="#thisPart# (#preserve_method#)">
			</cfif>
			<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#thisPart#</a>
			&nbsp;
		</td>
		<td>
			#Condition#&nbsp;<img src="/images/info.gif" border="0" class="likeLink" onClick="chgCondition('#partID#')">
		</td>
		<td>
			<cfif len(#sampled_from_obj_id#) gt 0>
				yes
			<cfelse>
				no
			</cfif>
		</td>
	
		<td valign="top">
		<form name="disp#i#" action="internalLoanItemReview.cfm" method="post">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			<input type="hidden" name="partID" value="#partID#">
			<input type="hidden" name="Action" value="saveDisp">
			<input type="hidden" name="transaction_id" value="#transaction_id#">
			
			
			<textarea name="item_instructions" rows="2" cols="20">#Item_Instructions#</textarea>
		</td>
		<td valign="top">
		
			<textarea name="loan_Item_Remarks" rows="2" cols="20">#loan_Item_Remarks#</textarea>
		
		</td>
		<td>
			
			
				
				<cfset thisDisp = #coll_obj_disposition#>
				<select name="coll_obj_disposition" size="1">
					<cfloop query="ctDisp">
						<option 
							<cfif #ctDisp.coll_obj_disposition# is "#thisDisp#"> selected </cfif>
							value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
					</cfloop>				
				</select>
				
				
			
		</td>
		
		<td>
			#Encumbrance# <cfif len(#agent_name#) gt 0> by #agent_name#</cfif>&nbsp;
		</td>
		<td>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
			 <input type="button" value="Remove" class="delBtn"
   onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'"
     onClick="disp#i#.Action.value='delete';submit();">	
	  <input type="button" value="Save" class="savBtn"
   onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'"
     onClick="disp#i#.Action.value='saveDisp';submit();">	
			
			</form>
			
			
			</cfif>&nbsp;
		</td>
		
	</tr>

<cfset i=#i#+1>
</cfloop>
</cfoutput>
<cfoutput query="getCatItemLoanRequests">




	<tr>
		<td>
			#collection_cde# #cat_num#&nbsp;
		</td>
		<td>
			#af_num#&nbsp;
		</td>
		<td>
			#scientific_name#&nbsp;			
		</td>
		
		<td>
			#Item_Descr#
		</td>
		<td>
			N/A
		</td>
		<td>
			N/A
		</td>
		<td>
		#Item_Instructions#&nbsp;
			
		</td>
		<td>
		#loan_Item_Remarks#
		</td>
		<td>
			N/A
		</td>
		<td>
			#Encumbrance# <cfif len(#agent_name#) gt 0> by #agent_name#</cfif>&nbsp;
		</td>
		<td>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
			<form name="remItem" action="internalLoanItemReview.cfm" method="post">
				<input type="hidden" name="Action" value="delete">
				<input type="hidden" name="partID" value="#collection_object_id#">
				<input type="hidden" name="collection_object_id" value="#collection_object_id#">
				<input type="hidden" name="transaction_id" value="#transaction_id#">
				<input type="submit" value="Remove this item">
			</form>
			</cfif>&nbsp;
		</td>
		
	</tr>



</cfoutput>
</table>
<cfoutput>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
	<br><a href="Loan.cfm?action=editLoan&transaction_id=#transaction_id#">Back to Edit Loan</a>
</cfif>
</cfoutput>
</cfif>
<cfinclude template="includes/_footer.cfm">