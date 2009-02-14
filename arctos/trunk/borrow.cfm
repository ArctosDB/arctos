<cfinclude template = "/includes/_header.cfm">
<cfquery name="ctStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select borrow_status from ctborrow_status
	</cfquery>
	<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(institution_acronym)  from collection
	</cfquery>
<cfquery name="cttrans_agent_role" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(trans_agent_role)  from cttrans_agent_role order by trans_agent_role
</cfquery>
<cfset title="Borrow">
<cfif #action# is "nothing">
	Find Borrows:
	<form name="borrow" method="post" action="borrow.cfm">
		<input type="hidden" name="action" value="findEm">
		<input type="submit" 
				class="schBtn"
				onmouseover="this.className='schBtn btnhov'" 
   				onmouseout="this.className='schBtn'"
				value="Find matches">
	</form>
</cfif>
<!------------------------------------------------------------------------------------------------------->
<cfif #action# is "findEm">
	<cfoutput>
		<cfquery name="getBorrow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select
				borrow.TRANSACTION_ID,
				LENDERS_TRANS_NUM_CDE,
				BORROW_NUM,
				LENDERS_INVOICE_RETURNED_FG,
				RECEIVED_DATE,
				DUE_DATE,
				LENDERS_LOAN_DATE,
				BORROW_STATUS,
				LENDERS_INSTRUCTIONS,
				authAgent.agent_name AuthorizedBy,
				TRANS_DATE,
				enteredAgent.agent_name EnteredBy,
				recAgent.agent_name ReceivedBy,
				CORRESP_FG,
				NATURE_OF_MATERIAL,
				TRANS_REMARKS,
				lender_loan_type
			FROM
				trans,
				borrow,
				preferred_agent_name authAgent,
				preferred_agent_name enteredAgent,
				preferred_agent_name recAgent
			WHERE
				trans.transaction_id = borrow.transaction_id AND
				trans.auth_agent_id = authAgent.agent_id (+) AND
				trans.trans_entered_agent_id = enteredAgent.agent_id AND
				trans.RECEIVED_AGENT_ID = recAgent.agent_id
		</cfquery>
		<table border>
			<tr>
				<td>
					Number
				</td>
				<td>
					Loan Type
				</td>
				<td>
					RECEIVED_DATE
				</td>
				<td>
					DUE_DATE
				</td>
				<td>
					BORROW_STATUS
				</td>
				<td>
					ReceivedBy
				</td>
				<td>
					NATURE_OF_MATERIAL
				</td>
			</tr>
		<cfloop query="getBorrow">
			<tr>
				<td>
					<a href="borrow.cfm?action=edit&transaction_id=#transaction_id#">
					#BORROW_NUM#
					</a>
				</td>
				<td>
					#lender_loan_type#
				</td>
				<td>
					#dateformat(RECEIVED_DATE,"dd mmm yyyy")#
				</td>
				<td>
					#dateformat(DUE_DATE,"dd mmm yyyy")#
				</td>
				<td>
					#BORROW_STATUS#
				</td>
				<td>
					#ReceivedBy#
				</td>
				<td>
					#NATURE_OF_MATERIAL#
				</td>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------->
<cfif #action# is "edit">
<cfoutput>
	
		<cfquery name="getBorrow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select
				borrow.TRANSACTION_ID,
				LENDERS_TRANS_NUM_CDE,
				BORROW_NUM,
				LENDERS_INVOICE_RETURNED_FG,
				RECEIVED_DATE,
				DUE_DATE,
				LENDERS_LOAN_DATE,
				BORROW_STATUS,
				LENDERS_INSTRUCTIONS,
				concattransagent(trans.transaction_id,'entered by') enteredby,
				TRANS_DATE,
				CORRESP_FG,
				NATURE_OF_MATERIAL,
				TRANS_REMARKS,
				lender_loan_type
			FROM
				trans,
				borrow
			WHERE
				trans.transaction_id = borrow.transaction_id and
				borrow.transaction_id=#transaction_id#
		</cfquery>
		<cfquery name="transAgents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				trans_agent_id,
				trans_agent.agent_id, 
				agent_name,
				trans_agent_role
			from
				trans_agent,
				preferred_agent_name
			where
				trans_agent.agent_id = preferred_agent_name.agent_id and
				trans_agent_role != 'entered by' and
				trans_agent.transaction_id=#transaction_id#
			order by
				trans_agent_role,
				agent_name
		</cfquery>
<table border>
<tr>
	<td colspan="4"><strong>Borrow Number: #getBorrow.BORROW_NUM#</strong>
	Entered By: #getBorrow.EnteredBy# on #getBorrow.TRANS_DATE#</td>
</tr>

		<form name="borrow" method="post" action="borrow.cfm">
			<input type="hidden" name="action" value="update">
			<input type="hidden" name="transaction_id" value="#getBorrow.transaction_id#">
			<tr>
			<td colspan="2">
			<table border>
				<tr>
					<th>Agent Name</th>
					<th>Role</th>
					<th>Delete?</th>
				</tr>
				<cfloop query="transAgents">
					<tr>
						<td>
							<input type="text" name="trans_agent_#trans_agent_id#" class="reqdClr" size="50" value="#agent_name#"
			  					onchange="getAgent('trans_agent_id_#trans_agent_id#','trans_agent_#trans_agent_id#','borrow',this.value); return false;"
			  					onKeyPress="return noenter(event);">
			  				<input type="hidden" name="trans_agent_id_#trans_agent_id#" value="#agent_id#">
						</td>
						<td>
							<cfset thisRole = #trans_agent_role#>
							<select name="trans_agent_role_#trans_agent_id#">
								<cfloop query="cttrans_agent_role">
									<option 
										<cfif #trans_agent_role# is #thisRole#> selected="selected"</cfif>
										value="#trans_agent_role#">#trans_agent_role#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="checkbox" name="del_agnt_#trans_agent_id#">
						</td>
					</tr>
				</cfloop>
					<tr class="newRec">
						<td>
							<label for="new_trans_agent">Add Agent:</label>
							<input type="text" name="new_trans_agent" id="new_trans_agent" class="reqdClr" size="50"
			  					onchange="getAgent('new_trans_agent_id','new_trans_agent','borrow',this.value); return false;"
			  					onKeyPress="return noenter(event);">
			  				<input type="hidden" name="new_trans_agent_id">
						</td>
						<td>
							<label for="new_trans_agent_role">&nbsp;</label>
							<select name="new_trans_agent_role" id="new_trans_agent_role">
								<cfloop query="cttrans_agent_role">
									<option value="#trans_agent_role#">#trans_agent_role#</option>
								</cfloop>
							</select>
						</td>
						<td>&nbsp;</td>
					</tr>				
			</table>
					</td>
				</tr>
			<tr>
				<td>
					<label for="LENDERS_TRANS_NUM_CDE">Lender's Transaction Number</label>
					<input type="text" name="LENDERS_TRANS_NUM_CDE" id="LENDERS_TRANS_NUM_CDE"
						value="#getBorrow.LENDERS_TRANS_NUM_CDE#">
				</td>
				<td>
					<label for="LENDERS_INVOICE_RETURNED_FG">Lender acknowledged returned?</label>
					<select name="LENDERS_INVOICE_RETURNED_FG" id="LENDERS_INVOICE_RETURNED_FG" size="1">
						<option <cfif #getBorrow.LENDERS_INVOICE_RETURNED_FG# IS 1> selected </cfif>
							value="1">yes</option>
						<option <cfif #getBorrow.LENDERS_INVOICE_RETURNED_FG# IS 0> selected </cfif>
							value="0">no</option>
					</select>
				</td>
			</tr>
			<tr>
				<td>
					<label for="lender_loan_type">Lender's Loan Type</label>
					<input type="text" name="lender_loan_type" id="lender_loan_type"
						value="#getBorrow.lender_loan_type#">
				</td>
			</tr>
			<tr>
				<td>
					<label for="RECEIVED_DATE">Received Date</label>
					<input type="text" name="RECEIVED_DATE" id="RECEIVED_DATE" value="#dateformat(getBorrow.RECEIVED_DATE,"dd mmm yyyy")#">
				</td>
				<td>
					<label for="DUE_DATE">Due Date</label>
					<input type="text" name="DUE_DATE" id="DUE_DATE" value="#dateformat(getBorrow.DUE_DATE,"dd mmm yyyy")#">
				</td>
			</tr>
			<tr>
				<td>
					<label for="LENDERS_LOAN_DATE">Lender's Loan Date</label>
					<input type="text" name="LENDERS_LOAN_DATE" id="LENDERS_LOAN_DATE" value="#dateformat(getBorrow.LENDERS_LOAN_DATE,"dd mmm yyyy")#">
				</td>
				<td>
					<label for="borrow_status">Status</label>
					<select name="borrow_status" id="borrow_status" size="1" class="reqdCld">
						<cfloop query="ctStatus">
							<option 
								<cfif #ctStatus.borrow_status# is "#getBorrow.BORROW_STATUS#"> selected </cfif>
							value="#ctStatus.borrow_status#">#ctStatus.borrow_status#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<label for="LENDERS_INSTRUCTIONS">Lender's Instructions</label>
					<textarea name="LENDERS_INSTRUCTIONS" id="LENDERS_INSTRUCTIONS" rows="3" cols="90">#getBorrow.LENDERS_INSTRUCTIONS#</textarea>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<label for="NATURE_OF_MATERIAL">Nature of Material</label>
					<textarea name="NATURE_OF_MATERIAL" id="NATURE_OF_MATERIAL" rows="3" cols="90">#getBorrow.NATURE_OF_MATERIAL#</textarea>
				</td>
			</tr>
			<tr>
				<td colspan="4">
					<label for="TRANS_REMARKS">Remarks</label>
					<textarea name="TRANS_REMARKS" id="TRANS_REMARKS" rows="3" cols="90">#getBorrow.TRANS_REMARKS#</textarea>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<input type="submit" 
				class="schBtn"
				onmouseover="this.className='schBtn btnhov'" 
   				onmouseout="this.className='schBtn'"
				value="Save Edits">
				<input type="button" 
				class="delBtn"
				onmouseover="this.className='delBtn btnhov'" 
   				onmouseout="this.className='delBtn'"
				value="Delete"
				onclick="borrow.action.value='delete';confirmDelete('borrow');">
				</td>
			</tr>
			
		</form>
</table>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------->
<cfif #action# is "update">
<cfoutput>
<cftransaction>
	<cfquery name="setBorrow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE borrow SET
				LENDERS_INVOICE_RETURNED_FG = #LENDERS_INVOICE_RETURNED_FG#,
				<cfif len(#LENDERS_TRANS_NUM_CDE#) gt 0>
					LENDERS_TRANS_NUM_CDE = '#LENDERS_TRANS_NUM_CDE#',
				<cfelse>
					LENDERS_TRANS_NUM_CDE = NULL,
				</cfif>
				<cfif len(#RECEIVED_DATE#) gt 0>
					RECEIVED_DATE = '#RECEIVED_DATE#',
				<cfelse>
					RECEIVED_DATE = NULL,
				</cfif>
				<cfif len(#DUE_DATE#) gt 0>
					DUE_DATE = '#DUE_DATE#',
				<cfelse>
					DUE_DATE = NULL,
				</cfif>
				<cfif len(#LENDERS_LOAN_DATE#) gt 0>
					LENDERS_LOAN_DATE = '#LENDERS_LOAN_DATE#',
				<cfelse>
					LENDERS_LOAN_DATE = NULL,
				</cfif>
				<cfif len(#LENDERS_INSTRUCTIONS#) gt 0>
					LENDERS_INSTRUCTIONS = '#LENDERS_INSTRUCTIONS#',
				<cfelse>
					LENDERS_INSTRUCTIONS = NULL,
				</cfif>
				BORROW_STATUS = '#BORROW_STATUS#'
			WHERE
				TRANSACTION_ID=#TRANSACTION_ID#
		</cfquery>
		<cfquery name="setTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE trans SET
				NATURE_OF_MATERIAL = '#NATURE_OF_MATERIAL#',
				<cfif len(#TRANS_REMARKS#) gt 0>
					TRANS_REMARKS = '#TRANS_REMARKS#'
				<cfelse>
					TRANS_REMARKS = NULL
				</cfif>
			WHERE
				TRANSACTION_ID=#TRANSACTION_ID#
		</cfquery>
		<cfquery name="wutsThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from trans_agent where transaction_id=#transaction_id#
			and trans_agent_role !='entered by'
		</cfquery>
		<cfloop query="wutsThere">
			<!--- first, see if the deleted - if so, nothing else matters --->
			<cfif isdefined("del_agnt_#trans_agent_id#")>
				<cfquery name="wutsThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					delete from trans_agent where trans_agent_id=#trans_agent_id#
				</cfquery>
			<cfelse>
				<!--- update, just in case --->
				<cfset thisAgentId = evaluate("trans_agent_id_" & trans_agent_id)>
				<cfset thisRole = evaluate("trans_agent_role_" & trans_agent_id)>
				<cfquery name="wutsThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					update trans_agent set
						agent_id = #thisAgentId#,
						trans_agent_role = '#thisRole#'
					where
						trans_agent_id=#trans_agent_id#
				</cfquery>
			</cfif>
		</cfloop>
		<cfif isdefined("new_trans_agent_id") and len(#new_trans_agent_id#) gt 0>
			<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into trans_agent (
					transaction_id,
					agent_id,
					trans_agent_role
				) values (
					#transaction_id#,
					#new_trans_agent_id#,
					'#new_trans_agent_role#'
				)
			</cfquery>
		</cfif>
		</cftransaction>
		<cflocation url="borrow.cfm?action=edit&transaction_id=#transaction_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------->
<cfif #action# is "new">
<cfoutput>
<table border>
		<form name="borrow" method="post" action="borrow.cfm">
			<input type="hidden" name="action" value="makeNew">
			<tr>
				<td align="right">
					Lender's Transaction Number:
				</td>
				<td>
					<input type="text" name="LENDERS_TRANS_NUM_CDE">
				</td>
				<td align="right">
					Lender acknowledged returned?
				</td>
				<td>
					<select name="LENDERS_INVOICE_RETURNED_FG" size="1">
						<option value="1">yes</option>
						<option value="0">no</option>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right">
					Received Date:
				</td>
				<td>
					<input type="text" name="RECEIVED_DATE">
				</td>
				<td align="right">
					Due Date:
				</td>
				<td>
					<input type="text" name="DUE_DATE">
				</td>
			</tr>
			<tr>
				<td align="right">
					Transaction Date:
				</td>
				<td>
					<input type="text" name="trans_date">
				</td>
				<td align="right">
					Institution
				</td>
				<td>
					<select name="institution_acronym" size="1" id="institution_acronym" class="reqdClr">
							<cfloop query="ctInst">
								<option value="#ctInst.institution_acronym#">#ctInst.institution_acronym#</option>
							</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right">
					Lender's Loan Date:
				</td>
				<td>
					<input type="text" name="LENDERS_LOAN_DATE">
				</td>
				<td align="right">
					Status:
				</td>
				<td>
					<select name="borrow_status" size="1" class="reqdCld">
						<cfloop query="ctStatus">
							<option value="#ctStatus.borrow_status#">#ctStatus.borrow_status#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right">
					Lender's Instructions:
				</td>
				<td colspan="3">
					<textarea name="LENDERS_INSTRUCTIONS" rows="3" cols="90"></textarea>
				</td>
			</tr>
			<tr>
				<td align="right">
					Authorized By:
				</td>
				<td>
					<input type="text" 
						name="AuthorizedBy" 
						class="reqdClr"
						onchange="getAgent('auth_agent_id','AuthorizedBy','borrow',this.value); return false;"
		 				onKeyPress="return noenter(event);"
						size="50">
					<input type="hidden" name="auth_agent_id">
				</td>
				<td align="right">
					Received By:
				</td>
				<td>
					<input type="text" 
						name="ReceivedBy" 
						class="reqdClr"
						onchange="getAgent('received_agent_id','ReceivedBy','borrow',this.value); return false;"
		 				onKeyPress="return noenter(event);"
						size="50">
					<input type="hidden" name="received_agent_id">
				</td>
			</tr>
			<tr>
				<td align="right">
					Nature of Material:
				</td>
				<td colspan="3">
					<textarea name="NATURE_OF_MATERIAL" rows="3" cols="90" class="reqdClr"></textarea>
				</td>
			</tr>
			<tr>
				<td align="right">
					Remarks:
				</td>
				<td colspan="4">
					<textarea name="TRANS_REMARKS" rows="3" cols="90"></textarea>
				</td>
			</tr>
			<tr>
				<td colspan="4">
					<input type="submit" 
				class="schBtn"
				onmouseover="this.className='schBtn btnhov'" 
   				onmouseout="this.className='schBtn'"
				value="Create Borrow">
				</td>
			</tr>
			
		</form>
</table>
	</cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------------------->
<cfif #action# is "delete">
<cfoutput>
	
	<cftransaction>
	<cfquery name="killBorrow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from borrow where transaction_id=#transaction_id#
		</cfquery>
		<cfquery name="killTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from trans where transaction_id=#transaction_id#
		</cfquery>
		</cftransaction>
		<cflocation url="transactions.cfm">
	</cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------------------->
<cfif #action# is "makeNew">
<cfoutput>
	<cfquery name="nextTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(transaction_id) transaction_id from trans
	</cfquery>
	<cfquery name="nextBorrow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(borrow_num) borrow_num from borrow
	</cfquery>
	<cfset nextTransId = #nextTrans.transaction_id# + 1>
	<cfset nextBorrowNum = #nextBorrow.borrow_num# + 1>
	<cfset thisDate = dateformat(now(),"dd-mmm-yyyy")>
	<cftransaction>
	<cfquery name="newTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO trans (
				 TRANSACTION_ID,
				<cfif len(#TRANS_DATE#) gt 0>
					TRANS_DATE,
				</cfif>
				<cfif len(#TRANS_REMARKS#) gt 0>
					TRANS_REMARKS,
				</cfif>
				TRANSACTION_TYPE,
				NATURE_OF_MATERIAL,
				institution_acronym)
			VALUES (
				#nextTransId#,				
				<cfif len(#TRANS_DATE#) gt 0>
					'#TRANS_DATE#',
				</cfif>
				<cfif len(#TRANS_REMARKS#) gt 0>
					'#TRANS_REMARKS#',
				</cfif>
				'borrow',
				'#NATURE_OF_MATERIAL#',
				'#institution_acronym#')
		</cfquery>
		<cfquery name="newBorrow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			INSERT INTO borrow (
				TRANSACTION_ID,
				<cfif len(#LENDERS_TRANS_NUM_CDE#) gt 0>
					LENDERS_TRANS_NUM_CDE,
				</cfif>
				BORROW_NUM,
				LENDERS_INVOICE_RETURNED_FG,
				<cfif len(#RECEIVED_DATE#) gt 0>
					RECEIVED_DATE,
				</cfif>
				<cfif len(#DUE_DATE#) gt 0>
					DUE_DATE,
				</cfif>
				<cfif len(#LENDERS_LOAN_DATE#) gt 0>
					LENDERS_LOAN_DATE,
				</cfif>
				<cfif len(#LENDERS_INSTRUCTIONS#) gt 0>
					LENDERS_INSTRUCTIONS,
				</cfif>
                 BORROW_STATUS)
			VALUES (
				#nextTransId#,
				<cfif len(#LENDERS_TRANS_NUM_CDE#) gt 0>
					'#LENDERS_TRANS_NUM_CDE#',
				</cfif>
				#nextBorrowNum#,
				#LENDERS_INVOICE_RETURNED_FG#,
				<cfif len(#RECEIVED_DATE#) gt 0>
					'#RECEIVED_DATE#',
				</cfif>
				<cfif len(#DUE_DATE#) gt 0>
					'#DUE_DATE#',
				</cfif>
				<cfif len(#LENDERS_LOAN_DATE#) gt 0>
					'#LENDERS_LOAN_DATE#',
				</cfif>
				<cfif len(#LENDERS_INSTRUCTIONS#) gt 0>
					'#LENDERS_INSTRUCTIONS#',
				</cfif>
                 '#BORROW_STATUS#')
		</cfquery>
		<cfquery name="authBy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO trans_agent (
				    transaction_id,
				    agent_id,
				    trans_agent_role
				) values (
					#nextTransId#,
					#AUTH_AGENT_ID#,
					'authorized by')
			</cfquery>
			<cfquery name="newLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO trans_agent (
				    transaction_id,
				    agent_id,
				    trans_agent_role
				) values (
					#nextTransId#,
					#RECEIVED_AGENT_ID#,
					'received by')
			</cfquery>				
		</cftransaction>
		<cflocation url="borrow.cfm?action=edit&transaction_id=#nextTransId#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------->


<cfinclude template = "/includes/_footer.cfm">