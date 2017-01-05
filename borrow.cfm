<cfinclude template = "/includes/_header.cfm">
<cfquery name="ctshipment_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select shipment_type from ctshipment_type where shipment_type like 'borrow%' order by shipment_type
</cfquery>
<cfquery name="ctStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select borrow_status from ctborrow_status
</cfquery>
<cfquery name="cttrans_agent_role" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select distinct(trans_agent_role)  from cttrans_agent_role order by trans_agent_role
</cfquery>
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select * from collection order by guid_prefix
</cfquery>
<script>
	jQuery(document).ready(function() {
		jQuery("#received_date").datepicker();
		jQuery("#lenders_loan_date").datepicker();
		jQuery("#due_date").datepicker();
		jQuery("#trans_date").datepicker();
		jQuery("#received_date_after").datepicker();
		jQuery("#received_date_before").datepicker();
		jQuery("#due_date_after").datepicker();
		jQuery("#due_date_before").datepicker();
		jQuery("#lenders_loan_date_after").datepicker();
		jQuery("#lenders_loan_date_before").datepicker();
		//shipped_date
		$.each($("input[id^='shipped_date']"), function() {
	      $("#" + this.id).datepicker();
   		});
	});
	function setBorrowNum(cid,v){
		$("#borrow_number").val(v);
		$("#collection_id").val(cid);
	}
</script>
<style>
	.nextnum{
		border:2px solid green;
		position:absolute;
		top:10em;
		right:1em;
	}
</style>
<cfset title="Borrow">
<cfif action is "nothing">
	<cfoutput>
	Find Borrows:
	<form name="borrow" method="post" action="borrow.cfm">
		<input type="hidden" name="action" value="findEm">
		<label for="trans_agent_role_1">Agent 1</label>
		<select name="trans_agent_role_1">
			<option value="">Please choose an agent role...</option>
			<cfloop query="cttrans_agent_role">
				<option value="#trans_agent_role#">-> #trans_agent_role#:</option>
			</cfloop>
		</select>
		<label for="agent_1">Agent 1 Name</label>
		<input type="text" name="agent_1"  size="50">
		<label for="trans_agent_role_2">Agent 2</label>
		<select name="trans_agent_role_2">
			<option value="">Please choose an agent role...</option>
			<cfloop query="cttrans_agent_role">
				<option value="#trans_agent_role#">-> #trans_agent_role#:</option>
			</cfloop>
		</select>
		<label for="agent_2">Agent 2 Name</label>
		<input type="text" name="agent_2"  size="50">
		<label for="collection_id">Collection</label>
		<select name="collection_id" size="1" id="collection_id">
			<option value=""></option>
			<cfloop query="ctcollection">
				<option value="#ctcollection.collection_id#">#ctcollection.guid_prefix#</option>
			</cfloop>
		</select>
		<label for="borrow_number">Borrow Number</label>
		<input type="text" name="borrow_number" id="borrow_number">
		<label for="LENDERS_TRANS_NUM_CDE">Lender's Transaction Number</label>
		<input type="text" name="LENDERS_TRANS_NUM_CDE" id="LENDERS_TRANS_NUM_CDE">
		<label for="lender_loan_type">Lender's Loan Type</label>
		<input type="text" name="lender_loan_type" id="lender_loan_type">
		<label for="LENDERS_INVOICE_RETURNED_FG">Lender acknowledged returned?</label>
		<select name="LENDERS_INVOICE_RETURNED_FG" id="LENDERS_INVOICE_RETURNED_FG" size="1">
			<option value=""></option>
			<option value="1">yes</option>
			<option value="0">no</option>
		</select>
		<label for="borrow_status">Status</label>
		<select name="borrow_status" id="borrow_status" size="1" class="reqdCld">
			<option value=""></option>
			<cfloop query="ctStatus">
				<option value="#ctStatus.borrow_status#">#ctStatus.borrow_status#</option>
			</cfloop>
		</select>
		<label for="shipment_type">Shipment Type</label>
		<select name="shipment_type" id="shipment_type" size="1" class="reqdCld">
			<option value=""></option>
			<cfloop query="ctshipment_type">
				<option value="#ctshipment_type.shipment_type#">#ctshipment_type.shipment_type#</option>
			</cfloop>
		</select>
		<label for="received_date">Received Date</label>
		<input type="text" name="received_date_after" id="received_date_after">-
		<input type="text" name="received_date_before" id="received_date_before">
		<span class="infoLink" onclick="$('##received_date_before').val($('##received_date_after').val());">copy</span>
		<label for="due_date_after">Due Date</label>
		<input type="text" name="due_date_after" id="due_date_after">-
		<input type="text" name="due_date_before" id="due_date_before">
		<span class="infoLink" onclick="$('##due_date_before').val($('##due_date_after').val());">copy</span>
		<label for="lenders_loan_date">Lender's Loan Date</label>
		<input type="text" name="lenders_loan_date_after" id="lenders_loan_date_after">-
		<input type="text" name="lenders_loan_date_before" id="lenders_loan_date_before">
		<span class="infoLink" onclick="$('##lenders_loan_date_before').val($('##lenders_loan_date_after').val());">copy</span>
		<label for="LENDERS_INSTRUCTIONS">Lender's Instructions</label>
		<input type="text" name="LENDERS_INSTRUCTIONS" id="LENDERS_INSTRUCTIONS">
		<label for="NATURE_OF_MATERIAL">Nature of Material</label>
		<input type="text" name="NATURE_OF_MATERIAL" id="NATURE_OF_MATERIAL">
		<label for="TRANS_REMARKS">Transaction Remarks</label>
		<input type="text" name="TRANS_REMARKS" id="TRANS_REMARKS">
		<br>
		<input type="submit" class="schBtn"	value="Find matches">
		<input type="reset" class="clrBtn"	value="Clear Form">
	</form>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------->
<cfif action is "findEm">
	<cfoutput>
		<cfset f="trans,
				borrow,
				trans_agent,
				preferred_agent_name,
				shipment">
		<cfset w="trans.transaction_id = borrow.transaction_id and
				trans.transaction_id = shipment.transaction_id  (+) and
				trans.transaction_id = trans_agent.transaction_id (+) and
				trans_agent.agent_id=preferred_agent_name.agent_id (+)">
		<cfif isdefined("shipment_type") and len(shipment_type) gt 0>
			<cfset w=w & " and shipment.shipment_type='#shipment_type#'">
		</cfif>

		<cfif (isdefined("trans_agent_role_1") and len(trans_agent_role_1) gt 0) or (isdefined("agent_1") and len(agent_1) gt 0)>
			<cfset f=f & ", agent_name a1,trans_agent ta1">
			<cfset w=w & " and trans.transaction_id=ta1.transaction_id and ta1.agent_id=a1.agent_id">
			<cfif isdefined("trans_agent_role_1") and len(trans_agent_role_1) gt 0>
				<cfset w=w & " and ta1.trans_agent_role='#trans_agent_role_1#'">
			</cfif>
			<cfif isdefined("agent_1") and len(agent_1) gt 0>
				<cfset w=w & " and upper(a1.agent_name) like '%#ucase(agent_1)#%'">
			</cfif>
		</cfif>
		<cfif (isdefined("trans_agent_role_2") and len(trans_agent_role_2) gt 0) or (isdefined("agent_2") and len(agent_2) gt 0)>
			<cfset f=f & ", agent_name a2,trans_agent ta2">
			<cfset w=w & " and trans.transaction_id=ta2.transaction_id and ta2.agent_id=a2.agent_id">
			<cfif isdefined("trans_agent_role_2") and len(trans_agent_role_2) gt 0>
				<cfset w=w & " and ta2.trans_agent_role='#trans_agent_role_2#'">
			</cfif>
			<cfif isdefined("agent_2") and len(agent_2) gt 0>
				<cfset w=w & " and upper(a2.agent_name) like '%#ucase(agent_2)#%'">
			</cfif>
		</cfif>
		<cfif isdefined("collection_id") and len(collection_id) gt 0>
			<cfset w=w & " and trans.collection_id=#collection_id#">
		</cfif>
		<cfif isdefined("borrow_number") and len(borrow_number) gt 0>
			<cfset w=w & " and upper(borrow_number) like '%#ucase(borrow_number)#%'">
		</cfif>
		<cfif isdefined("LENDERS_TRANS_NUM_CDE") and len(LENDERS_TRANS_NUM_CDE) gt 0>
			<cfset w=w & " and upper(LENDERS_TRANS_NUM_CDE) like '%#ucase(LENDERS_TRANS_NUM_CDE)#%'">
		</cfif>
		<cfif isdefined("lender_loan_type") and len(lender_loan_type) gt 0>
			<cfset w=w & " and lender_loan_type = '#lender_loan_type#'">
		</cfif>
		<cfif isdefined("LENDERS_INVOICE_RETURNED_FG") and len(LENDERS_INVOICE_RETURNED_FG) gt 0>
			<cfset w=w & " and LENDERS_INVOICE_RETURNED_FG = #lender_loan_type#">
		</cfif>
		<cfif isdefined("borrow_status") and len(borrow_status) gt 0>
			<cfset w=w & " and borrow_status = '#borrow_status#'">
		</cfif>
		<cfif isdefined("received_date_after") and len(received_date_after) gt 0>
			<cfset w=w & " and to_char(received_date,'yyyy-mm-dd') >= '#received_date_after#'">
		</cfif>
		<cfif isdefined("received_date_before") and len(received_date_before) gt 0>
			<cfset w=w & " and to_char(received_date,'yyyy-mm-dd') <= '#received_date_before#'">
		</cfif>
		<cfif isdefined("lenders_loan_date_after") and len(lenders_loan_date_after) gt 0>
			<cfset w=w & " and to_char(lenders_loan_date,'yyyy-mm-dd') >= '#lenders_loan_date_after#'">
		</cfif>
		<cfif isdefined("lenders_loan_date_before") and len(lenders_loan_date_before) gt 0>
			<cfset w=w & " and to_char(lenders_loan_date,'yyyy-mm-dd') <= '#lenders_loan_date_before#'">
		</cfif>
		<cfif isdefined("due_date_after") and len(due_date_after) gt 0>
			<cfset w=w & " and to_char(due_date,'yyyy-mm-dd') >= '#due_date_after#'">
		</cfif>
		<cfif isdefined("due_date_before") and len(due_date_before) gt 0>
			<cfset w=w & " and to_char(due_date,'yyyy-mm-dd') <= '#due_date_before#'">
		</cfif>
		<cfif isdefined("LENDERS_INSTRUCTIONS") and len(LENDERS_INSTRUCTIONS) gt 0>
			<cfset w=w & " and upper(LENDERS_INSTRUCTIONS) like '%#ucase(LENDERS_INSTRUCTIONS)#%'">
		</cfif>
		<cfif isdefined("NATURE_OF_MATERIAL") and len(NATURE_OF_MATERIAL) gt 0>
			<cfset w=w & " and upper(NATURE_OF_MATERIAL) like '%#ucase(NATURE_OF_MATERIAL)#%'">
		</cfif>
		<cfif isdefined("TRANS_REMARKS") and len(TRANS_REMARKS) gt 0>
			<cfset w=w & " and upper(TRANS_REMARKS) like '%#ucase(TRANS_REMARKS)#%'">
		</cfif>
		<cfquery name="getBorrow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				borrow.TRANSACTION_ID,
				LENDERS_TRANS_NUM_CDE,
				BORROW_NUMBER,
				LENDERS_INVOICE_RETURNED_FG,
				RECEIVED_DATE,
				DUE_DATE,
				LENDERS_LOAN_DATE,
				BORROW_STATUS,
				LENDERS_INSTRUCTIONS,
				TRANS_DATE,
				CORRESP_FG,
				NATURE_OF_MATERIAL,
				TRANS_REMARKS,
				lender_loan_type,
				preferred_agent_name.agent_name,
				trans_agent.trans_agent_role
			FROM
				#preservesinglequotes(f)#
			WHERE
				#preservesinglequotes(w)#
		</cfquery>
		<cfif getBorrow.recordcount is 0>
			<div class="error">Nothing matched. Use your back button to try again.</div>
			<cfabort>
		</cfif>
		<cfquery name="b" dbtype="query">
			select
				TRANSACTION_ID,
				LENDERS_TRANS_NUM_CDE,
				BORROW_NUMBER,
				LENDERS_INVOICE_RETURNED_FG,
				RECEIVED_DATE,
				DUE_DATE,
				LENDERS_LOAN_DATE,
				BORROW_STATUS,
				LENDERS_INSTRUCTIONS,
				TRANS_DATE,
				CORRESP_FG,
				NATURE_OF_MATERIAL,
				TRANS_REMARKS,
				lender_loan_type
			from
				getBorrow
			group by
				TRANSACTION_ID,
				LENDERS_TRANS_NUM_CDE,
				BORROW_NUMBER,
				LENDERS_INVOICE_RETURNED_FG,
				RECEIVED_DATE,
				DUE_DATE,
				LENDERS_LOAN_DATE,
				BORROW_STATUS,
				LENDERS_INSTRUCTIONS,
				TRANS_DATE,
				CORRESP_FG,
				NATURE_OF_MATERIAL,
				TRANS_REMARKS,
				lender_loan_type
		</cfquery>
		<table border>
			<tr>
				<td>
					Borrow Number
				</td>
				<td>
					Borrow Type
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
					NATURE_OF_MATERIAL
				</td>
				<td>
					Agents
				</td>
			</tr>
		<cfloop query="b">
			<tr>
				<td>
					<a href="borrow.cfm?action=edit&transaction_id=#transaction_id#">
						#BORROW_NUMBER#
					</a>
				</td>
				<td>
					#lender_loan_type#
				</td>
				<td>
					#RECEIVED_DATE#
				</td>
				<td>
					#dateformat(DUE_DATE,"yyyy-mm-dd")#
				</td>
				<td>
					#BORROW_STATUS#
				</td>
				<td>
					#NATURE_OF_MATERIAL#
				</td>
				<cfquery name="a" dbtype="query">
					select
						agent_name,
						trans_agent_role
					from
						getBorrow
					where
						transaction_id=#transaction_id#
					group by
						agent_name,
						trans_agent_role
					order by
						trans_agent_role,
						agent_name
				</cfquery>

				<td>
					<cfloop query="a">
						#trans_agent_role#: #agent_name#<br>
					</cfloop>
				</td>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------->
<cfif action is "edit">
<cfoutput>
		<cfquery name="ctShip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select shipped_carrier_method from ctshipped_carrier_method order by shipped_carrier_method
		</cfquery>
		<cfquery name="getBorrow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				borrow.TRANSACTION_ID,
				LENDERS_TRANS_NUM_CDE,
				BORROW_NUMBER,
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
				lender_loan_type,
				collection.guid_prefix collection
			FROM
				trans,
				borrow,
				collection
			WHERE
				trans.transaction_id = borrow.transaction_id and
				trans.collection_id = collection.collection_id and
				borrow.transaction_id=#transaction_id#
		</cfquery>
		<cfquery name="transAgents" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
	<table><tr><td valign="top">
	<table>
		<form name="borrow" method="post" action="borrow.cfm">
			<input type="hidden" name="action" value="update">
			<input type="hidden" name="transaction_id" value="#getBorrow.transaction_id#">
			<tr>
				<td colspan="3">
					<table border>
						<tr>
							<th>Agent Name</th>
							<th>
								Role
								<span class="infoLink" onclick="getCtDoc('cttrans_agent_role');">Define</span>
							</th>
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
					<label for="collection_id">Collection</label>
					<span id="collection_id">#getBorrow.collection#</span>
				</td>
				<td>
					<label for="borrow_number">Borrow Number</label>
					<input type="text" name="borrow_number" id="borrow_number"
						value="#getBorrow.borrow_number#">
				</td>
				<td>
					<label for="LENDERS_TRANS_NUM_CDE">Lender's Transaction Number</label>
					<input type="text" name="LENDERS_TRANS_NUM_CDE" id="LENDERS_TRANS_NUM_CDE"
						value="#getBorrow.LENDERS_TRANS_NUM_CDE#">
				</td>
			</tr>
			<tr>
				<td>
					<label for="lender_loan_type">Lender's Loan Type</label>
					<input type="text" name="lender_loan_type" id="lender_loan_type"
						value="#getBorrow.lender_loan_type#">
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
				<td>
					<label for="borrow_status">Status</label>
					<select name="borrow_status" id="borrow_status" size="1" class="reqdCld">
						<cfloop query="ctStatus">
							<option
								<cfif #ctStatus.borrow_status# is "#getBorrow.BORROW_STATUS#"> selected </cfif>
							value="#ctStatus.borrow_status#">#ctStatus.borrow_status#</option>
						</cfloop>
					</select><span class="infoLink" onclick="getCtDoc('ctborrow_status');">Define</span>
				</td>
			</tr>
			<tr>
				<td>
					<label for="received_date">Received Date</label>
					<input type="text" name="received_date" id="received_date" value="#getBorrow.RECEIVED_DATE#">
				</td>
				<td>
					<label for="due_date">Due Date</label>
					<input type="text" name="due_date" id="due_date" value="#dateformat(getBorrow.DUE_DATE,"yyyy-mm-dd")#">
				</td>
				<td>
					<label for="lenders_loan_date">Lender's Loan Date</label>
					<input type="text" name="lenders_loan_date" id="lenders_loan_date" value="#dateformat(getBorrow.LENDERS_LOAN_DATE,"yyyy-mm-dd")#">
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
					<textarea name="NATURE_OF_MATERIAL" id="NATURE_OF_MATERIAL" rows="3" cols="90" class="reqdClr">#getBorrow.NATURE_OF_MATERIAL#</textarea>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<label for="TRANS_REMARKS">Transaction Remarks</label>
					<textarea name="TRANS_REMARKS" id="TRANS_REMARKS" rows="3" cols="90">#getBorrow.TRANS_REMARKS#</textarea>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<input type="submit" class="schBtn" value="Save Edits">
					<input type="button" class="delBtn" value="Delete"
						onclick="borrow.action.value='delete';confirmDelete('borrow');">
				</td>
			</tr>

		</form>
</table>
</td>
<td valign="top">
	<cfquery name="getPermits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
			permit.permit_id,
			issuedBy.agent_name as IssuedByAgent,
			issuedTo.agent_name as IssuedToAgent,
			issued_Date,
			renewed_Date,
			exp_Date,
			permit_Num,
			permit_Type,
			permit_remarks
		FROM
			permit,
			permit_trans,
			preferred_agent_name issuedTo,
			preferred_agent_name issuedBy
		WHERE
			permit.permit_id = permit_trans.permit_id AND
			permit.issued_by_agent_id = issuedBy.agent_id AND
			permit.issued_to_agent_id = issuedTo.agent_id AND
			permit_trans.transaction_id = #transaction_id#
	</cfquery>
	<br><strong>Permits:</strong>
	<cfloop query="getPermits">
		<form name="killPerm#currentRow#" method="post" action="borrow.cfm">
			<p>
				<strong>Permit ## #permit_Num# (#permit_Type#)</strong> issued to
			 	#IssuedToAgent# by #IssuedByAgent# on
				#dateformat(issued_Date,"yyyy-mm-dd")#.
				<cfif len(renewed_Date) gt 0>
					(renewed #renewed_Date#)
				</cfif>
				Expires #dateformat(exp_Date,"yyyy-mm-dd")#
				<cfif len(permit_remarks) gt 0>Remarks: #permit_remarks#</cfif>
				<br>
				<input type="hidden" name="transaction_id" value="#transaction_id#">
				<input type="hidden" name="action" value="delePermit">
				<input type="hidden" name="permit_id" value="#permit_id#">
				<input type="submit" value="Remove this Permit" class="delBtn">
			</p>
		</form>
	</cfloop>
	<form name="addPermit" action="borrow.cfm" method="post">
		<input type="hidden" name="transaction_id" value="#transaction_id#">
		<input type="hidden" name="permit_id">
		<label for="">Click to add Permit. Reload to see added permits.</label>
		<input type="button" value="Add a permit" class="picBtn"
		 	onClick="window.open('picks/PermitPick.cfm?transaction_id=#transaction_id#', 'PermitPick',
				'resizable,scrollbars=yes,width=600,height=600')">
	</form>

		<a href="/Reports/report_printer.cfm?transaction_id=#transaction_id#">[ Print ]</a>


		<p>
			<strong>Media associated with this Borrow</strong>
			<br>
			<span class="likeLink" onclick="addMediaHere('#getBorrow.collection# #getBorrow.BORROW_NUMBER#','#transaction_id#');">
				Create Media
			</span>
			<br><a href="/MediaSearch.cfm" target="_blank">Find Media</a> and edit it to create links to this Borrow.
			<div id="mmmsgdiv"></div>
				<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select
						media_uri,
						preview_uri,
						media_type,
						media.media_id,
						mime_type
					from
						media,
						media_relations
					where
						media.media_id=media_relations.media_id and
						media_relations.media_relationship='documents borrow' and
						media_relations.related_primary_key=#transaction_id#
				</cfquery>
				<cfset obj = CreateObject("component","component.functions")>
				<div id="thisLoanMediaDiv">
				<cfloop query="media">
					<cfset preview = obj.getMediaPreview(
						preview_uri="#media.preview_uri#",
						media_type="#media.media_type#")>
						<br>
						<a href="/media/#media_id#?open" target="_blank"><img src="#preview#" class="theThumb"></a>
		                  	<p>
							#media_type# (#mime_type#)
		                   	<br><a href="/media/#media_id#" target="_blank">Media Details</a>
						</p>
				</cfloop>
			</div>



		</p>



</td>
	</tr></table>
<hr>
		<cfquery name="shipment" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				shipment_id,
				PACKED_BY_AGENT_ID,
				pba.agent_name packed_by_agent,
				SHIPPED_CARRIER_METHOD,
				CARRIERS_TRACKING_NUMBER,
				SHIPPED_DATE,
				shipment_type,
				PACKAGE_WEIGHT,
				HAZMAT_FG,
				INSURED_FOR_INSURED_VALUE,
				SHIPMENT_REMARKS,
				CONTENTS,
				FOREIGN_SHIPMENT_FG,
				SHIPPED_TO_ADDR_ID,
				ship_to.address shipped_to_addr,
				SHIPPED_FROM_ADDR_ID,
				ship_from.address shipped_from_addr
			from
				shipment,
				preferred_agent_name pba,
				address ship_to,
				address ship_from
			where
				shipment.PACKED_BY_AGENT_ID=pba.agent_id and
				shipment.SHIPPED_TO_ADDR_ID=ship_to.address_id and
				shipment.SHIPPED_FROM_ADDR_ID=ship_from.address_id and
				shipment.transaction_id=#transaction_id#
		</cfquery>
		<h3>Create Shipment:</h3>
		<div class="newRec">
		<form name="newshipment" method="post" action="borrow.cfm">
			<input type="hidden" name="Action" value="newShip">
			<input type="hidden" name="transaction_id" value="#transaction_id#">
			<label for="packed_by_agent">Packed By Agent</label>
			<input type="text" name="packed_by_agent" class="reqdClr" size="50"
				  onchange="getAgent('packed_by_agent_id','packed_by_agent','newshipment',this.value); return false;"
				  onKeyPress="return noenter(event);">
			<input type="hidden" name="packed_by_agent_id">
			<label for="shipped_carrier_method">Shipped Method</label>
			<select name="shipped_carrier_method" id="shipped_carrier_method" size="1" class="reqdClr">
				<option value=""></option>
				<cfloop query="ctShip">
					<option value="#ctShip.shipped_carrier_method#">#ctShip.shipped_carrier_method#</option>
				</cfloop>
			</select>
			<label for="shipment_type">Shipment Type</label>
			<select name="shipment_type" id="shipment_type" size="1" class="reqdClr">
				<option value=""></option>
				<cfloop query="ctshipment_type">
					<option value="#ctshipment_type.shipment_type#">#ctshipment_type.shipment_type#</option>
				</cfloop>
			</select><span class="infoLink" onclick="getCtDoc('ctshipment_type');">Define</span>
			<label for="packed_by_agent">Shipped To Address (may format funky until save)</label>
			<textarea name="shipped_to_addr" id="shipped_to_addr" cols="60" rows="5"
				readonly="yes" class="reqdClr"></textarea>
			<input type="hidden" name="shipped_to_addr_id">
			<input type="button" value="Pick Address" class="picBtn"
				onClick="addrPick('shipped_to_addr_id','shipped_to_addr','newshipment'); return false;">
			<label for="packed_by_agent">Shipped From Address</label>
			<textarea name="shipped_from_addr" id="shipped_from_addr" cols="60" rows="5"
				readonly="yes" class="reqdClr"></textarea>
			<input type="hidden" name="shipped_from_addr_id">
			<input type="button" value="Pick Address" class="picBtn"
				onClick="addrPick('shipped_from_addr_id','shipped_from_addr','newshipment'); return false;">
			<label for="carriers_tracking_number">Tracking Number</label>
			<input type="text" name="carriers_tracking_number" id="carriers_tracking_number">
			<label for="shipped_date">Ship Date</label>
			<input type="text" name="shipped_date" id="shipped_date">
			<label for="package_weight">Package Weight (TEXT, include units)</label>
			<input type="text" name="package_weight" id="package_weight">
			<label for="hazmat_fg">Hazmat?</label>
			<select name="hazmat_fg" id="hazmat_fg" size="1">
				<option value="0">no</option>
				<option value="1">yes</option>
			</select>
			<label for="insured_for_insured_value">Insured Value (NUMBER, US$)</label>
			<input type="text" name="insured_for_insured_value" id="insured_for_insured_value">
			<label for="shipment_remarks">Remarks</label>
			<input type="text" name="shipment_remarks" id="shipment_remarks">
			<label for="contents">Contents</label>
			<input type="text" name="contents" id="contents" size="60">
			<label for="foreign_shipment_fg">Foreign shipment?</label>
			<select name="foreign_shipment_fg" id="foreign_shipment_fg" size="1">
				<option value="0">no</option>
				<option value="1">yes</option>
			</select>
			<br><input type="submit" value="Create Shipment" class="insBtn">
		</form>
		</div>
		<cfset i=1>
		<cfloop query="shipment">
		<hr>
		<h3>Edit Shipment</h3>
			<form name="shipment#i#" method="post" action="borrow.cfm">
				<input type="hidden" name="action" value="saveShip">
				<input type="hidden" name="transaction_id" value="#transaction_id#">
				<input type="hidden" name="shipment_id" value="#shipment_id#">
				<label for="packed_by_agent">Packed By Agent</label>
				<input type="text" name="packed_by_agent" class="reqdClr" size="50" value="#packed_by_agent#"
					  onchange="getAgent('packed_by_agent_id','packed_by_agent','shipment#i#',this.value); return false;"
					  onKeyPress="return noenter(event);">
				<input type="hidden" name="packed_by_agent_id" value="#packed_by_agent_id#">
				<label for="shipped_carrier_method">Shipped Method</label>
				<select name="shipped_carrier_method" id="shipped_carrier_method" size="1" class="reqdClr">
					<option value=""></option>
					<cfloop query="ctShip">
						<option
							<cfif ctShip.shipped_carrier_method is shipment.shipped_carrier_method> selected="selected" </cfif>
								value="#ctShip.shipped_carrier_method#">#ctShip.shipped_carrier_method#</option>
					</cfloop>
				</select>
				<label for="shipment_type">Shipment Type</label>
				<select name="shipment_type" id="shipment_type" size="1" class="reqdClr">
					<option value=""></option>
					<cfloop query="ctshipment_type">
						<option <cfif ctshipment_type.shipment_type is shipment.shipment_type>
							selected="selected"
						</cfif> value="#ctshipment_type.shipment_type#">#ctshipment_type.shipment_type#</option>
					</cfloop>
				</select><span class="infoLink" onclick="getCtDoc('ctshipment_type');">Define</span>
				<label for="packed_by_agent">Shipped To Address (may format funky until save)</label>
				<textarea name="shipped_to_addr" id="shipped_to_addr" cols="60" rows="5"
					readonly="yes" class="reqdClr">#shipped_to_addr#</textarea>
				<input type="hidden" name="shipped_to_addr_id" value="#shipped_to_addr_id#">
				<input type="button" value="Pick Address" class="picBtn"
					onClick="addrPick('shipped_to_addr_id','shipped_to_addr','shipment#i#'); return false;">
				<label for="packed_by_agent">Shipped From Address</label>
				<textarea name="shipped_from_addr" id="shipped_from_addr" cols="60" rows="5"
					readonly="yes" class="reqdClr">#shipped_from_addr#</textarea>
				<input type="hidden" name="shipped_from_addr_id" value="#shipped_from_addr_id#">
				<input type="button" value="Pick Address" class="picBtn"
					onClick="addrPick('shipped_from_addr_id','shipped_from_addr','shipment#i#'); return false;">
				<label for="carriers_tracking_number">Tracking Number</label>
				<input type="text" value="#carriers_tracking_number#" name="carriers_tracking_number" id="carriers_tracking_number">
				<label for="shipped_date#i#">Ship Date</label>
				<input type="text" value="#dateformat(shipped_date,'yyyy-mm-dd')#" name="shipped_date" id="shipped_date#i#">
				<label for="package_weight">Package Weight (TEXT, include units)</label>
				<input type="text" value="#package_weight#" name="package_weight" id="package_weight">
				<label for="hazmat_fg">Hazmat?</label>
				<select name="hazmat_fg" id="hazmat_fg" size="1">
					<option <cfif hazmat_fg is 0> selected="selected" </cfif>value="0">no</option>
					<option <cfif hazmat_fg is 1> selected="selected" </cfif>value="1">yes</option>
				</select>
				<label for="insured_for_insured_value">Insured Value (NUMBER, US$)</label>
				<input type="text"
					 value="#INSURED_FOR_INSURED_VALUE#" name="insured_for_insured_value" id="insured_for_insured_value">
				<label for="shipment_remarks">Remarks</label>
				<input type="text" value="#shipment_remarks#" name="shipment_remarks" id="shipment_remarks">
				<label for="contents">Contents</label>
				<input type="text" value="#contents#" name="contents" id="contents" size="60">
				<label for="foreign_shipment_fg">Foreign shipment?</label>
				<select name="foreign_shipment_fg" id="foreign_shipment_fg" size="1">
					<option <cfif foreign_shipment_fg is 0> selected="selected" </cfif>value="0">no</option>
					<option <cfif foreign_shipment_fg is 1> selected="selected" </cfif>value="1">yes</option>
				</select>
				<br><input type="button" value="Save Shipment Edits" class="savBtn"
						onClick="shipment#i#.action.value='saveShip';shipment#i#.submit();">
					<input type="button" value="Delete Shipment" class="delBtn"
						onClick="shipment#i#.action.value='deleteShip';confirmDelete('shipment#i#');">
			</form>
			<cfset i=i+1>
		</cfloop>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------------->
<cfif Action is "delePermit">
	<cfquery name="killPerm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		DELETE FROM permit_trans WHERE transaction_id = #transaction_id# and
		permit_id=#permit_id#
	</cfquery>
	<cflocation url="borrow.cfm?Action=edit&transaction_id=#transaction_id#" addtoken="false">
</cfif>
<!------------------------------------------------------------------------------------------------------->
<cfif action is "update">
<cfoutput>
<cftransaction>
	<cfquery name="setBorrow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE borrow SET
		LENDERS_INVOICE_RETURNED_FG = #LENDERS_INVOICE_RETURNED_FG#,
		LENDERS_TRANS_NUM_CDE = '#LENDERS_TRANS_NUM_CDE#',
		RECEIVED_DATE = to_date('#RECEIVED_DATE#','yyyy-mm-dd'),
		DUE_DATE = to_date('#DUE_DATE#','yyyy-mm-dd'),
		LENDERS_LOAN_DATE = to_date('#LENDERS_LOAN_DATE#','yyyy-mm-dd'),
		LENDERS_INSTRUCTIONS = '#LENDERS_INSTRUCTIONS#',
		BORROW_STATUS = '#BORROW_STATUS#'
	WHERE
		TRANSACTION_ID=#TRANSACTION_ID#
	</cfquery>
	<cfquery name="setTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE trans SET
			NATURE_OF_MATERIAL = '#NATURE_OF_MATERIAL#',
			TRANS_REMARKS = '#TRANS_REMARKS#'
		WHERE
			TRANSACTION_ID=#TRANSACTION_ID#
	</cfquery>
	<cfquery name="wutsThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from trans_agent where transaction_id=#transaction_id#
		and trans_agent_role !='entered by'
	</cfquery>
	<cfloop query="wutsThere">
		<!--- first, see if the deleted - if so, nothing else matters --->
		<cfif isdefined("del_agnt_#trans_agent_id#")>
			<cfquery name="wutsThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from trans_agent where trans_agent_id=#trans_agent_id#
			</cfquery>
		<cfelse>
			<!--- update, just in case --->
			<cfset thisAgentId = evaluate("trans_agent_id_" & trans_agent_id)>
			<cfset thisRole = evaluate("trans_agent_role_" & trans_agent_id)>
			<cfquery name="wutsThere" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update trans_agent set
					agent_id = #thisAgentId#,
					trans_agent_role = '#thisRole#'
				where
					trans_agent_id=#trans_agent_id#
			</cfquery>
		</cfif>
	</cfloop>
	<cfif isdefined("new_trans_agent_id") and len(#new_trans_agent_id#) gt 0>
		<cfquery name="newAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
<cflocation url="borrow.cfm?action=edit&transaction_id=#transaction_id#" addtoken="false">
	</cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------------------->
<cfif action is "deleteShip">
	<cfoutput>
		<cfquery name="upShip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			 delete from shipment WHERE
				shipment_id = #shipment_id#
		</cfquery>
		<cflocation url="borrow.cfm?transaction_id=#transaction_id#&action=edit" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------->
<cfif action is "saveShip">
	<cfoutput>
		<cfquery name="upShip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			 UPDATE shipment SET
				PACKED_BY_AGENT_ID = #PACKED_BY_AGENT_ID#
				,SHIPPED_CARRIER_METHOD = '#SHIPPED_CARRIER_METHOD#'
				,CARRIERS_TRACKING_NUMBER='#CARRIERS_TRACKING_NUMBER#'
				,SHIPPED_DATE='#dateformat(SHIPPED_DATE,"yyyy-mm-dd")#'
				,PACKAGE_WEIGHT='#PACKAGE_WEIGHT#'
				,HAZMAT_FG=#HAZMAT_FG#
				,shipment_type='#shipment_type#'
				<cfif len(#INSURED_FOR_INSURED_VALUE#) gt 0>
					,INSURED_FOR_INSURED_VALUE=#INSURED_FOR_INSURED_VALUE#
				<cfelse>
				 	,INSURED_FOR_INSURED_VALUE=null
				</cfif>
				,SHIPMENT_REMARKS='#SHIPMENT_REMARKS#'
				,CONTENTS='#CONTENTS#'
				,FOREIGN_SHIPMENT_FG=#FOREIGN_SHIPMENT_FG#
				,SHIPPED_TO_ADDR_ID=#SHIPPED_TO_ADDR_ID#
				,SHIPPED_FROM_ADDR_ID=#SHIPPED_FROM_ADDR_ID#
			WHERE
				shipment_id = #shipment_id#
		</cfquery>
		<cflocation url="borrow.cfm?transaction_id=#transaction_id#&action=edit" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------->
<cfif action is "newShip">
	<cfoutput>
		<cfquery name="newShip" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO shipment (
					TRANSACTION_ID
					,PACKED_BY_AGENT_ID
					,SHIPPED_CARRIER_METHOD
					,CARRIERS_TRACKING_NUMBER
					,SHIPPED_DATE
					,PACKAGE_WEIGHT
					,HAZMAT_FG
					,INSURED_FOR_INSURED_VALUE
					,SHIPMENT_REMARKS
					,CONTENTS
					,FOREIGN_SHIPMENT_FG
					,SHIPPED_TO_ADDR_ID
					,SHIPPED_FROM_ADDR_ID,
					shipment_type
				) VALUES (
					#TRANSACTION_ID#
					,#PACKED_BY_AGENT_ID#
					,'#SHIPPED_CARRIER_METHOD#'
					,'#CARRIERS_TRACKING_NUMBER#'
					,'#dateformat(SHIPPED_DATE,"yyyy-mm-dd")#'
					,'#PACKAGE_WEIGHT#'
					,#HAZMAT_FG#
					<cfif len(INSURED_FOR_INSURED_VALUE) gt 0>
						,#INSURED_FOR_INSURED_VALUE#
					<cfelse>
					 	,NULL
					</cfif>
					,'#SHIPMENT_REMARKS#'
					,'#CONTENTS#'
					,#FOREIGN_SHIPMENT_FG#
					,#SHIPPED_TO_ADDR_ID#
					,#SHIPPED_FROM_ADDR_ID#,
					'#shipment_type#'
				)
		</cfquery>
		<cflocation url="borrow.cfm?transaction_id=#transaction_id#&action=edit" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------->
<cfif action is "new">
<cfoutput>
	<table border>
		<form name="borrow" method="post" action="borrow.cfm">
			<input type="hidden" name="action" value="makeNew">
			<tr>
				<td>
					<label for="collection_id">Collection</label>
					<select name="collection_id" size="1" id="collection_id"  class="reqdClr">
						<option value=""></option>
						<cfloop query="ctcollection">
							<option value="#ctcollection.collection_id#">#ctcollection.guid_prefix#</option>
						</cfloop>
					</select>
				<td>
					<label for="borrow_num">Local Borrow Number</label>
					<input type="text" id="borrow_number" name="borrow_number" class="reqdClr">
				</td>
				<td>
					<label for="lenders_trans_num_cde">Lender's Transaction Number</label>
					<input type="text" name="lenders_trans_num_cde" id="lenders_trans_num_cde">
				</td>
			</tr>
			<tr>
				<td>
					<label for="LENDERS_INVOICE_RETURNED_FG">Lender acknowledged returned?</label>
					<select name="LENDERS_INVOICE_RETURNED_FG" size="1">
						<option value="0">no</option>
						<option value="1">yes</option>
					</select>
				</td>
				<td>
					<label for="received_date">Received Date</label>
					<input type="text" name="received_date" id="received_date">
				</td>
				<td>
					<label for="due_date">Due Date</label>
					<input type="text" name="due_date" id="due_date">
				</td>
			</tr>

			<tr>
				<td>
					<label for="trans_date">Transaction Date</label>
					<input type="text" name="trans_date" id="trans_date" value="#dateformat(now(),'yyyy-mm-dd')#">
				</td>
				<td>
					<label for="lenders_loan_date">Lender's Loan Date</label>
					<input type="text" name="lenders_loan_date" id="lenders_loan_date">
				</td>
				<td>
					<label for="borrow_status">Status</label>
					<select name="borrow_status" size="1" class="reqdCld">
						<cfloop query="ctStatus">
							<option
								<cfif ctStatus.borrow_status is "open">
									selected="selected"
								</cfif>
							value="#ctStatus.borrow_status#">#ctStatus.borrow_status#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<label for="AuthorizedBy">Authorized By</label>
					<input type="text"
						name="AuthorizedBy"
						class="reqdClr"
						onchange="getAgent('auth_agent_id','AuthorizedBy','borrow',this.value); return false;"
		 				onKeyPress="return noenter(event);"
						size="50">
					<input type="hidden" name="auth_agent_id">
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<label for="ReceivedBy">Received By</label>
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
				<td colspan="3">
					<label for="ReceivedFrom">Received From</label>
					<input type="text"
						name="ReceivedFrom"
						class="reqdClr"
						onchange="getAgent('received_from_agent_id','ReceivedFrom','borrow',this.value); return false;"
		 				onKeyPress="return noenter(event);"
						size="50">
					<input type="hidden" name="received_from_agent_id">
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<label for="LENDERS_INSTRUCTIONS">Lender's Instructions</label>
					<textarea name="LENDERS_INSTRUCTIONS" rows="3" cols="90"></textarea>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<label for="NATURE_OF_MATERIAL">Nature of Material</label>
					<textarea name="NATURE_OF_MATERIAL" rows="3" cols="90" class="reqdClr"></textarea>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<label for="TRANS_REMARKS">Remarks</label>
					<textarea name="TRANS_REMARKS" rows="3" cols="90"></textarea>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<input type="submit" class="schBtn" value="Create Borrow">
				</td>
			</tr>
		</form>
</table>
<div class="nextnum">
			Next Available Borrow Number:
			<br>
			<cfquery name="all_coll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from collection order by collection
			</cfquery>
			<cfloop query="all_coll">
					<cfset stg="'#dateformat(now(),"yyyy")#.' || nvl(lpad(max(to_number(substr(borrow_number,6,3))) + 1,3,0),'001') || '.#collection_cde#'">
					<cfset whr=" AND substr(borrow_number, 1,4) ='#dateformat(now(),"yyyy")#'">
				<hr>
				<cftry>
					<cfquery name="thisq" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select
							 #preservesinglequotes(stg)# nn
						from
							borrow,
							trans,
							collection
						where
							borrow.transaction_id=trans.transaction_id and
							trans.collection_id=collection.collection_id and
							collection.collection_id=#collection_id#
							#preservesinglequotes(whr)#
					</cfquery>
					<cfcatch>
						<hr>
						#cfcatch.detail#
						<br>
						#cfcatch.message#
						<cfquery name="thisq" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select
								 'check data' nn
							from
								dual
						</cfquery>
					</cfcatch>
				</cftry>
				<cfif len(thisQ.nn) gt 0>
					<span class="likeLink" onclick="setBorrowNum('#collection_id#','#thisQ.nn#')">#collection# #thisQ.nn#</span>
				<cfelse>
					<span style="font-size:x-small">
						No data available for #collection#.
					</span>
				</cfif>
				<br>
			</cfloop>
		</div>
	</cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------------------->
<cfif #action# is "delete">
<cfoutput>

	<cftransaction>
		<cfquery name="killAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from trans_agent where transaction_id=#transaction_id#
		</cfquery>
		<cfquery name="killBorrow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from borrow where transaction_id=#transaction_id#
		</cfquery>
		<cfquery name="killTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from trans where transaction_id=#transaction_id#
		</cfquery>
		</cftransaction>
		<cflocation url="borrow.cfm" addtoken="false">
	</cfoutput>
</cfif>

<!------------------------------------------------------------------------------------------------------->
<cfif #action# is "makeNew">
<cfoutput>
	<cfquery name="nextTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select sq_transaction_id.nextval transaction_id from dual
	</cfquery>

	<cfset transaction_id = nextTrans.transaction_id>
	<cftransaction>
	<cfquery name="newTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO trans (
			TRANSACTION_ID,
			TRANS_DATE,
			TRANS_REMARKS,
			TRANSACTION_TYPE,
			NATURE_OF_MATERIAL,
			collection_id)
		VALUES (
			#transaction_id#,
			to_date('#TRANS_DATE#','yyyy-mm-dd'),
			'#escapeQuotes(TRANS_REMARKS)#',
			'borrow',
			'#escapeQuotes(NATURE_OF_MATERIAL)#',
			#collection_id#
		)
	</cfquery>
	<cfquery name="newBorrow" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO borrow (
			TRANSACTION_ID,
			LENDERS_TRANS_NUM_CDE,
			BORROW_NUMBER,
			LENDERS_INVOICE_RETURNED_FG,
			RECEIVED_DATE,
			DUE_DATE,
			LENDERS_LOAN_DATE,
			LENDERS_INSTRUCTIONS,
			BORROW_STATUS
		) VALUES (
			#transaction_id#,
			'#LENDERS_TRANS_NUM_CDE#',
			'#Borrow_Number#',
			#LENDERS_INVOICE_RETURNED_FG#,
			to_date('#RECEIVED_DATE#','yyyy-mm-dd'),
			to_date('#DUE_DATE#','yyyy-mm-dd'),
			to_date('#LENDERS_LOAN_DATE#','yyyy-mm-dd'),
			'#escapeQuotes(LENDERS_INSTRUCTIONS)#',
			'#BORROW_STATUS#'
		)
		</cfquery>
		<cfquery name="authBy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO trans_agent (
			    transaction_id,
			    agent_id,
			    trans_agent_role
			) values (
				#transaction_id#,
				#AUTH_AGENT_ID#,
				'authorized by')
		</cfquery>
		<cfquery name="newLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO trans_agent (
			    transaction_id,
			    agent_id,
			    trans_agent_role
			) values (
				#transaction_id#,
				#RECEIVED_AGENT_ID#,
				'received by'
			)
		</cfquery>
		<cfquery name="recfrom" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO trans_agent (
			    transaction_id,
			    agent_id,
			    trans_agent_role
			) values (
				#transaction_id#,
				#received_from_agent_id#,
				'received from'
			)
		</cfquery>
	</cftransaction>
	<cflocation url="borrow.cfm?action=edit&transaction_id=#transaction_id#" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------->


<cfinclude template = "/includes/_footer.cfm">