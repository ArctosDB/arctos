<cfset title="Review Loan Items">
<cfinclude template="includes/_header.cfm">
<script type='text/javascript' src='/includes/_loanReview.js'></script>
<script src="/includes/sorttable.js"></script>
<cfquery name="ctDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select coll_obj_disposition from ctcoll_obj_disp
</cfquery>
<cfif not isdefined("transaction_id")>
	You did something very naughty.<cfabort>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "delete">
	<cfoutput>
		<cfif isdefined("coll_obj_disposition") AND coll_obj_disposition is "on loan">
			<!--- see if it's a subsample --->
			<cfquery name="isSSP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select SAMPLED_FROM_OBJ_ID from specimen_part where collection_object_id = #partID#
			</cfquery>
			<cfif isSSP.SAMPLED_FROM_OBJ_ID gt 0>
				You cannot remove this item from a loan while it's disposition is "on loan." 
				<br />Use the form below if you'd like to change the disposition and remove the item 
				from the loan, or to delete the item from the database completely.
				<form name="cC" method="post" action="a_loanItemReview.cfm">
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
						value="Remove Item from Loan" 
						onclick="cC.action.value='saveDisp'; submit();" />
					<p /><input type="button" 
						class="delBtn"
						value="Delete Subsample From Database" 
						onclick="cC.action.value='killSS'; submit();"/>
						<p /><input type="button" 
						class="qutBtn"
						value="Discard Changes" 
						onclick="cC.action.value='nothing'; submit();"/>
				</form>
				<cfabort>
			<cfelse><!--- not a subsample; disallow delete ---->
				You cannot remove this item from a loan while it's disposition is "on loan." 
				<br />Use the form below if you'd like to change the disposition and remove the item 
				from the loan.
				<form name="cC" method="post" action="a_loanItemReview.cfm">
					<input type="hidden" name="action" />
					<input type="hidden" name="transaction_id" value="#transaction_id#" />
					<input type="hidden" name="item_instructions" value="#item_instructions#" />
					<input type="hidden" name="loan_item_remarks" value="#loan_item_remarks#" />
					<input type="hidden" name="partID" id="partID" value="#partID#" />
					<input type="hidden" name="spRedirAction" value="delete" />
					<br />Change disposition to: <select name="coll_obj_disposition" size="1">
						<cfloop query="ctDisp">
							<option value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
						</cfloop>				
					</select>
					<br /><input type="button" 
						class="delBtn"
						value="Remove Item from Loan" 
						onclick="cC.action.value='saveDisp'; submit();" />
					<br /><input type="button" 
						class="qutBtn"
						value="Discard Changes" 
						onclick="cC.action.value='nothing'; submit();"/>
				</form>
				<cfabort>
			</cfif>
		</cfif>
		<cfquery name="deleLoanItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			DELETE FROM loan_item where collection_object_id = #partID#
			and transaction_id = #transaction_id#
		</cfquery>
		<cflocation url="a_loanItemReview.cfm?transaction_id=#transaction_id#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "killSS">
	<cfoutput>
		<cftransaction>
			<cfquery name="deleLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM loan_item WHERE collection_object_id = #partID#
				and transaction_id=#transaction_id#
			</cfquery>
			<cfquery name="delePart" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM specimen_part WHERE collection_object_id = #partID#
			</cfquery>
			<cfquery name="delePartCollObj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM coll_object WHERE collection_object_id = #partID#
			</cfquery>
			<cfquery name="delePartRemark" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM coll_object_remark WHERE collection_object_id = #partID#
			</cfquery>
			<cfquery name="getContID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select container_id from coll_obj_cont_hist where
				collection_object_id = #partID#
			</cfquery>
			
			<cfquery name="deleCollCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM coll_obj_cont_hist WHERE collection_object_id = #partID#
			</cfquery>
			<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM container_history WHERE container_id = #getContID.container_id#
			</cfquery>
			<cfquery name="deleCont" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				DELETE FROM container WHERE container_id = #getContID.container_id#
			</cfquery>
		</cftransaction>
		<cflocation url="a_loanItemReview.cfm?transaction_id=#transaction_id#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "BulkUpdateDisp">
	<cfoutput>
		<cfquery name="getCollObjId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select collection_object_id FROM loan_item where transaction_id=#transaction_id#
		</cfquery>
		<cfloop query="getCollObjId">
			<cfquery name="upDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE coll_object SET coll_obj_disposition = '#coll_obj_disposition#'
			where collection_object_id = #collection_object_id#
			</cfquery>
		</cfloop>
	<cflocation url="a_loanItemReview.cfm?transaction_id=#transaction_id#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "saveDisp">
	<cfoutput>
		<cftransaction>
			<cfquery name="upDisp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				UPDATE coll_object SET coll_obj_disposition = '#coll_obj_disposition#'
				where collection_object_id = #partID#
			</cfquery>
			<cfquery name="upItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfif isdefined("spRedirAction") and len(spRedirAction) gt 0>
			<cfset action=spRedirAction>
		<cfelse>
			<cfset action="nothing">
		</cfif>
		<cflocation url="a_loanItemReview.cfm?transaction_id=#transaction_id#&item_instructions=#item_instructions#&partID=#partID#&loan_item_remarks=#loan_item_remarks#&action=#action#">
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------->
<cfif action is "nothing">
	<cfquery name="getPartLoanRequests" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			guid_prefix || cat_num guid, 
			cataloged_item.collection_object_id,
			collection,
			part_name,
			condition,
			 sampled_from_obj_id,
			 item_descr,
			 item_instructions,
			 loan_item_remarks,
			 coll_obj_disposition,
			 scientific_name,
			 Encumbrance,
			 agent_name,
			 loan_number,
			 specimen_part.collection_object_id as partID,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID		 			 
		 from 
			loan_item, 
			loan,
			specimen_part, 
			coll_object,
			cataloged_item,
			coll_object_encumbrance,
			encumbrance,
			agent_name,
			identification,
			collection
		WHERE
			loan_item.collection_object_id = specimen_part.collection_object_id AND
			loan.transaction_id = loan_item.transaction_id AND
			specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
			specimen_part.collection_object_id = coll_object.collection_object_id AND
			coll_object.collection_object_id = coll_object_encumbrance.collection_object_id (+) and
			coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id (+) AND
			encumbrance.encumbering_agent_id = agent_name.agent_id (+) AND
			cataloged_item.collection_object_id = identification.collection_object_id AND
			identification.accepted_id_fg = 1 AND
			cataloged_item.collection_id=collection.collection_id AND
		  	loan_item.transaction_id = #transaction_id#
		ORDER BY cat_num
	</cfquery>
	<cfquery name="getDataLoanRequests" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select 
			flat.collection_object_id,
			guid,
			concatSingleOtherId(flat.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			flat.scientific_name,
			flat.encumbrances
		 from 
			flat,
			loan,
			loan_item
		WHERE
			loan.transaction_id = loan_item.transaction_id AND
			loan_item.collection_object_id = flat.collection_object_id AND
		  	loan_item.transaction_id = #transaction_id#
	</cfquery>
	<cfquery name="theLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			loan_number,
			collection,
			loan_type
		from
			loan,
			trans,
			collection
		where
			loan.transaction_id=trans.transaction_id and
			trans.collection_id=collection.collection_id and
			trans.transaction_id=#transaction_id#
	</cfquery>
	<cfoutput>
		Review Loan Items for #theLoan.collection# #theLoan.loan_number# (#theLoan.loan_type#)
		<br><a href="a_loanItemReview.cfm?action=nothing&transaction_id=#transaction_id#&Ijustwannadownload=yep">Download (csv)</a> - non-data loans only!
		<br><a href="Loan.cfm?action=editLoan&transaction_id=#transaction_id#">back to Edit Loan</a>
		<cfif getDataLoanRequests.recordcount gt 0>
			<p>
				This loan contains #getDataLoanRequests.recordcount# data loan items.
			</p>
			<form name="dcli" method="post" action="a_loanItemReview.cfm">
				<input type="hidden" name="action" value="deleteCatItemLoanItem">
				<input type="hidden" name="transaction_id" value="#transaction_id#">
				<table border id="t" class="sortable">
					<tr>
						<th>GUID</th>
						<th>#session.CustomOtherIdentifier#</th>
						<th>Scientific Name</th>
						<th>Encumbrances</th>
						<th>remove</th>
					</tr>
					<cfloop query="getDataLoanRequests">
						<tr>
							<td>
								<a href="/guid/#guid#">#guid#</a>
							</td>
							<td>
								#CustomID#&nbsp;
							</td>	
							<td>
								<em>#scientific_name#</em>&nbsp;
							</td>
							<td>
								#encumbrances#
							</td>
							<td>
								<input type="checkbox" name="collection_object_id" value="#collection_object_id#">
							</td>
						</tr>
					</cfloop>
				</table>
				<input type="submit" class="delBtn" value="remove checked items">
			</form>
			<p>
				<input type="button" class="delBtn" value="remove ALL items" onclick="removeAllDataLoanItems();">
				<script>
					function removeAllDataLoanItems(){
						var yesno=confirm('Are you sure you want to REMOVE ALL specimens from the data loan?');
						if (yesno==true) {
							document.location='/a_loanItemReview.cfm?action=removeAllDataLoanItems&transaction_id=#transaction_id#';  		
					 	} else {
						  	return false;
					  	}
					}
				</script>
			</p>
		</cfif>
		<cfif getPartLoanRequests.recordcount gt 0>
			<cfif isdefined("Ijustwannadownload") and Ijustwannadownload is "yep">
				<cfset fileName = "ArctosLoanData_#getPartLoanRequests.loan_number#.csv">
				<cfset ac=getPartLoanRequests.columnlist>
				<cfset header=trim(ac)>
				<cffile action="write" file="#Application.webDirectory#/download/#fileName#" addnewline="yes" output="#header#">
				<cfloop query="getPartLoanRequests">
					<cfset oneLine = "">
					<cfloop list="#ac#" index="c">
						<cfset thisData = evaluate(c)>
						<cfif len(oneLine) is 0>
							<cfset oneLine = '"#thisData#"'>
						<cfelse>
							<cfset oneLine = '#oneLine#,"#thisData#"'>
						</cfif>
					</cfloop>
					<cfset oneLine = trim(oneLine)>
					<cffile action="append" file="#Application.webDirectory#/download/#fileName#" addnewline="yes" output="#oneLine#">
				</cfloop>
				<cflocation url="/download.cfm?file=#fileName#" addtoken="false">
				<a href="/download/#fileName#">Click here if your file does not automatically download.</a>
				<cfabort>
			</cfif>
			<cfquery name="catCnt" dbtype="query">
				select count(distinct(collection_object_id)) c from getPartLoanRequests
			</cfquery>
			<cfquery name="prtItemCnt" dbtype="query">
				select count(distinct(partID)) c from getPartLoanRequests
			</cfquery>
			<br>There are #prtItemCnt.c# non-data loan items from #catCnt.c# specimens in this loan.
			<form name="BulkUpdateDisp" method="post" action="a_loanItemReview.cfm">
				<br>Change disposition of all these items to:
				<input type="hidden" name="Action" value="BulkUpdateDisp">
				<input type="hidden" name="transaction_id" value="#transaction_id#" id="transaction_id">
				<select name="coll_obj_disposition" size="1">
					<cfloop query="ctDisp">
						<option value="#coll_obj_disposition#">#ctDisp.coll_obj_disposition#</option>
					</cfloop>				
				</select>
				<input type="submit" value="Update Disposition" class="savBtn">	
			</form>
			<p>
				View 
				<a href="/findContainer.cfm?loan_trans_id=#transaction_id#">Part Locations</a>
				or <a href="loanFreezerLocn.cfm?transaction_id=#transaction_id#">Print Freezer Locations</a>
			</p>
			<table border id="t" class="sortable">
				<tr>
					<th>GUID</th>
					<th>#session.CustomOtherIdentifier#</th>
					<th>Scientific Name</th>
					<th>Item</th>
					<th>Condition</th>
					<th>Subsample?</th>
					<th>Item Instructions</th>
					<th>Item Remarks</th>
					<th>Disposition</th>
					<th>Encumbrance</th>
					<th>&nbsp;</th>
				</tr>
				<cfset i=1>
				<cfloop query="getPartLoanRequests">
					<tr id="rowNum#partID#">
						<td>
							<a href="/guid/#guid#">#guid#</a>
						</td>
						<td>
							#CustomID#&nbsp;
						</td>	
						<td>
							<em>#scientific_name#</em>&nbsp;
						</td>
						<td>
							<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#part_name#</a>
						</td>
						<td>
							<textarea name="condition#partID#" 
								rows="2" cols="20"
								id="condition#partID#"
								onchange="this.className='red';updateCondition('#partID#')">#condition#</textarea>
								<span class="infoLink" onClick="chgCondition('#partID#')">History</span>
						</td>
						<td>
							<cfif len(sampled_from_obj_id) gt 0>
								yes
							<cfelse>
								no
							</cfif>
							<input type="hidden" name="isSubsample#partID#" id="isSubsample#partID#" value="#sampled_from_obj_id#" />
						</td>	
						<td valign="top">
							<textarea name="item_instructions#partID#" id="item_instructions#partID#" rows="2" cols="20" onchange="this.className='red';updateInstructions('#partID#')">#Item_Instructions#</textarea>
						</td>
						<td valign="top">
							<textarea name="loan_Item_Remarks#partID#" id="loan_Item_Remarks#partID#" rows="2" cols="20"
							onchange="this.className='red';updateLoanItemRemarks('#partID#')">#loan_Item_Remarks#</textarea>
						</td>
						<td>
							<cfset thisDisp = #coll_obj_disposition#>
							<select name="coll_obj_disposition#partID#"
								id="coll_obj_disposition#partID#"
								 size="1" onchange="this.className='red';updateDispn('#partID#')">
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
							<img src="/images/del.gif" class="likeLink" onclick="remPartFromLoan(#partID#);" />
						</td>
					</tr>
					<cfset i=#i#+1>
				</cfloop>
			</table>
		</cfif>
	</cfoutput>
</cfif>
<!------------------------------------------------------>
<cfif action is "deleteCatItemLoanItem">
	<cfquery name="buhBye" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from loan_item where transaction_id=#transaction_id# and
		collection_object_id in (#collection_object_id#)
	</cfquery>
	<cflocation url="a_loanItemReview.cfm?transaction_id=#transaction_id#" addtoken="false">
</cfif>
<cfinclude template="includes/_footer.cfm">