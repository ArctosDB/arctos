<cfinclude template="../includes/_header.cfm">
<cfquery name="ctLoanStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select loan_status from ctloan_status
</cfquery>
<cfset thisYear = #dateformat(now(),"yyyy")#>
			<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select collection_cde from ctcollection_cde
			</cfquery>
			<cfquery name="ctLoanType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select loan_type from ctloan_type
			</cfquery>
<cfif #Action# is "nothing">
<form name="filter" method="post" action="user_loan.cfm">
	<input type="hidden" name="action" value="viewList">
	Filter for username: <input type="text" name="username">
	<input type="submit" 
	value="Submit" 
	class="schBtn"
    onmouseover="this.className='schBtn btnhov'" 
    onmouseout="this.className='schBtn'">
	<br> or 
	 to see a <input type="submit" 
	value="list" 
	class="schBtn"
    onmouseover="this.className='schBtn btnhov'" 
    onmouseout="this.className='schBtn'"> of all user projects.
	
	
</form>
</cfif>

<cfif #Action# is "viewList">
<cfquery name="proj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT
		distinct(username)
	FROM
		cf_users,
		cf_user_data,
		cf_project,
		cf_loan
	WHERE
		cf_users.user_id = cf_user_data.user_id AND
		cf_users.user_id = cf_project.user_id AND
		cf_project.trans_id = cf_loan.trans_id AND
		upper(username) like '%#ucase(username)#%'
	ORDER BY
		username
</cfquery>
<cfset i=1>
<table>
<cfoutput query="proj">
	<form name="lnk" method="post" action="user_loan.cfm">
		<input type="hidden" name="action" value="viewProject">
		<input type="hidden" name="username" value="#username#">
	<tr>
	<td>View project and loan(s) for: </td>
	<td>
	
		 <input type="submit" 
	value="#username#" 
	class="lnkBtn"
    onmouseover="this.className='lnkBtn btnhov'" 
    onmouseout="this.className='lnkBtn'">
	
	</td></tr>
	</form>
	<cfset i=#i#+1>
</cfoutput>
</table>
</cfif>
<!------------------------------------------------->
<cfif #Action# is "viewProject">
<cfquery name="proj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT
		username,
		cf_users.user_id user_id,
		first_name,
		middle_name,
		last_name,
		affiliation,
		email,
		proj_title,
		cf_project.trans_id trans_id,
		proj_desc,
		cf_project.project_id  ArctosProjectId,
		cf_project.remarks proj_remark,
		loan_name,
		instructions,
		loan_description,
		cf_loan.loan_id loan_id,
		cf_loan.transaction_id ArctosLoanId
	FROM
		cf_users,
		cf_user_data,
		cf_project,
		cf_loan
	WHERE
		cf_users.user_id = cf_user_data.user_id AND
		cf_users.user_id = cf_project.user_id AND
		cf_project.trans_id = cf_loan.trans_id AND
		upper(username) like '%#ucase(username)#%'
	ORDER BY
		username
</cfquery>
<cfoutput>
got #proj.recordcount# proj <cfflush>
</cfoutput>

<cfquery name="users" dbtype="query">
	select username,
		user_id,
		first_name,
		middle_name,
		last_name,
		affiliation,
		email
	FROM
		proj
	GROUP BY
		  username,
		user_id,
		first_name,
		middle_name,
		last_name,
		affiliation,
		email
</cfquery>

<cfoutput>
<cfif #users.recordcount# neq 1>
	Something bad happened! #users.recordcount# users matched your search!
	<cfabort>
</cfif>
<br>got #users.recordcount# users <cfflush>
<table>

<tr>

	<td>
	<table border>
	<tr>
		<td>User: #users.first_name# #users.last_name# AKA #users.username# from #users.affiliation# (#users.email#)</td>
	</tr>
		
			<cfquery name="p" dbtype="query">
				select 
					proj_title,
					proj_desc,
					proj_remark,
					trans_id,
					ArctosProjectId
				from
					proj
				GROUP BY
					proj_title,
					proj_desc,
					proj_remark,
					trans_id,
					ArctosProjectId
			</cfquery>
			<br>This user has requested #p.recordcount# projects.
			got p <cfflush>
<cfloop query="p">
			
			
	<form name="project" action="user_loan.cfm" method="post">
		<input type="hidden" name="cf_trans_id" value="#trans_id#">
		<input type="hidden" name="username" value="#username#">
		<input type="hidden" name="Action" value="createNewProject">
	<tr>
				<td>
				Project Name:  <textarea name="project_name" cols="50" rows="2" class="reqdClr">#proj_title#</textarea>
				</td>
			</tr>
			<tr>
				<td>
				Start Date: <input type="text" name="start_date">&nbsp;End Date: <input type="text" name="end_date">
				</td>
			</tr>
			<tr>
				<td>
				Description: <textarea name="project_description" cols="50" rows="3">#proj_desc#</textarea>
				</td>
			</tr>
			<tr>
				<td>
				Remarks: <textarea name="project_remarks" cols="50" rows="3">#proj_remark#</textarea>
				</td>
			</tr>
			<tr>
				<td>
			<cfif #ArctosProjectId# gt 0>
				This is already a project. Click <a href="/ProjectList.cfm?src=proj&project_id=#ArctosProjectId#">here</a> to view.
			<cfelse>
					<input type="submit" 
						value="Create Arctos Project" 
						class="savBtn"
						onmouseover="this.className='savBtn btnhov'" 
						onmouseout="this.className='savBtn'">
			</cfif>
end if<cfflush>
				</td>
			</tr>
			
	
</form>
starting 1<cfflush>
				
				<cfquery name="one" dbtype="query">
					select
						*
					FROM proj
						WHERE trans_id = #trans_id#
				</cfquery>
				
				<cfoutput>
					this tid: #trans_id#
				</cfoutput>
				got 1 <cfflush>
				<cfset i=1>
				<!-----
				
				
				
				----->
				<cfloop query="one">
					<tr><td>
					<b>Loan:</b>
					</td></tr>
					<form name="loan#loan_id#" action="user_loan.cfm" method="post">
			<input type="hidden" name="action" value="makeArctosLoan">
			<input type="hidden" name="loan_id" value="loan_id">
			<!--- set loan_number - same code works for accn_num --->
			

			<cfquery name="getLoanNum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select max(loan_num) + 1 as nextLoanNum from loan
				where loan_num_prefix = '#thisYear#'
			</cfquery>
			<cfif #getLoanNum.nextLoanNum# gt 0>
			
				<!--- first loan for this year ---><cfset loanNumber = "#thisYear#.#getLoanNum.nextLoanNum#">
				
			<cfelse>
			
				<cfset loanNumber = "#thisYear#.1">
			</cfif>
			<tr><td>
			Name: #loan_name#
			</td></tr>
			
			<tr>
				<td>
				
			<table>
	<tr>
		<td align="right"><strong>Initiate Loan:</strong> </td>
		<td><input type="text" name="loan_num"value="#loanNumber#" class="reqdClr">
			<select name="loan_num_suffix" size="1">
			<cfloop query="ctcoll">
				<option value="#ctcoll.collection_cde#">#ctcoll.collection_cde#</option>
			</cfloop>
			</select></td>
	</tr>
	<tr>
		<td align="right">To: </td>
		<td><input type="text" name="rec_agent_name"  readonly="yes" size="50" class="reqdClr">
		<input type="hidden" name="rec_agent_id">
			<input type="button" value="Pick" class="picBtn"
   onmouseover="this.className='picBtn btnhov'" onmouseout="this.className='picBtn'"
   onClick="openpopup('rec_agent_id','rec_agent_name','loan#loan_id#'); return false;">	
   
			</a> </td>
	</tr>
	<tr>
		<td align="right">Authorized By: </td>
		<td><input type="text" name="auth_agent_name" readonly="yes" size="50" class="reqdClr">
		<input type="hidden" name="auth_agent_id">
		<input type="button" value="Pick" class="picBtn"
   onmouseover="this.className='picBtn btnhov'" onmouseout="this.className='picBtn'"
   onClick="openpopup('auth_agent_id','auth_agent_name','loan#loan_id#'); return false;">
   </a></td>
	</tr>
	<cfset i=#i#+1>
	<tr>
		<td align="right">Type: </td>
		<td><select name="loan_type" class="reqdClr">
					<cfloop query="ctLoanType">
						<option value="#ctLoanType.loan_type#">#ctLoanType.loan_type#</option>
					</cfloop>
				</select>
	<img src="images/nada.gif" width="60" height="1">
	Status:&nbsp;<select name="loan_status" class="reqdClr">
					<cfloop query="ctLoanStatus">
						<option value="#ctLoanStatus.loan_status#">#ctLoanStatus.loan_status#</option>
					</cfloop>
				</select>
	</td>
	</tr>
	<tr>
		<td align="right">Initiated: </td>
		<td><input type="text" name="initiating_date" value="#dateformat(now(),"dd-mmm-yyyy")#">
		<img src="images/nada.gif" width="60" height="1">Due Date:&nbsp;<input type="text" name="return_due_date">
		</td>
	</tr>
	<tr>
		<td align="right">Nature of Material:</td>
		<td><textarea name="nature_of_material" rows="3" cols="50" class="reqdClr"></textarea></td>
	</tr>
	
	<tr>
		<td align="right">Instructions:</td>
		<td><textarea name="loan_instructions" rows="3" cols="50">#instructions#</textarea></td>
	</tr>
	<tr>
		<td align="right">Description:</td>
		<td><textarea name="loan_description" rows="3" cols="50">#loan_description#</textarea></td>
	</tr>
	
	<tr>
		<td align="right">Remarks: </td>
		<td><textarea name="trans_remarks" rows="3" cols="50"></textarea></td>
	</tr>
	<tr>
		<td colspan="2" align="center">
		<cfif #ArctosLoanId# gt 0>
			This is already a loan. Click <a href="http://arctos.database.museum/Loan.cfm?transaction_id=#ArctosLoanId#&Action=editLoan">here</a> to edit. 
		<cfelse>
			 <input type="submit" value="Create Arctos Loan" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">	
  

		
		</cfif>
		 bla <cfflush>
			
   </td>
	</tr>
</table>

				</td>
			</tr>
</form>
					getting specimens<cfflush>
						<cfquery name="specs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select
							part_name, part_modifier, preserve_method,
							condition,
							collection.collection_cde,
							cat_num,
							institution_acronym,
							scientific_name,
							specimen_part.collection_object_id,
							use_type,
							remark,
							cf_loan.transaction_id ArctosLoanId,
							concatEncumbranceDetails(specimen_part.derived_from_cat_item) encumbrances,
							rejection_reason,
							cf_loan.loan_id
						FROM
							specimen_part,
							coll_object,
							collection,
							cataloged_item,
							identification,
							cf_loan_item,
							cf_loan
						WHERE
							specimen_part.collection_object_id = coll_object.collection_object_id AND
							cataloged_item.collection_object_id = identification.collection_object_id AND
							sampled_from_obj_id is null and
							accepted_id_fg = 1 and
							cataloged_item.collection_id = collection.collection_id and
							cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
							cf_loan_item.loan_id = cf_loan.loan_id AND
							specimen_part.collection_object_id = cf_loan_item.collection_object_id and
							cf_loan_item.loan_id = #loan_id#
						</cfquery>
						<tr><td>
						<b> #specs.recordcount# Specimens: </b>
						<br><a href="/bnhmMaps/bnhmMapData.cfm?loan_id=#loan_id#&action=mapCfUserLoanItems" target="_blank">
							Map using BerkeleyMapper</a>
						</td></tr>
						
						<tr><td>
						<table border>
							<tr>
								<td>Cat Number</td>
								<td>Identification</td>
								<td>Item</td>
								<td>Item Condition</td>
								<td>User Remark</td>
								<td>Use</td>
								<td>Encumbrances</td>
								<td>Arctos Remark</td>
								<td>Arctos Description</td>
								<td>Arctos Instructions</td>
								<td>Rejection Reason</td>
								<td>Status</td>
								<td>&nbsp;</td>
							</tr>
						<cfloop query="specs">
							<cfif len(#ArctosLoanId#) gt 0>
							<cfquery name="thisItemInArctos" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								select * from loan_item where
								collection_object_id = #collection_object_id# and
								transaction_id = #ArctosLoanId#
							</cfquery>
							<cfelse>
								<cfquery name="thisItemInArctos" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								select * from loan_item where
								collection_object_id = #collection_object_id# and
								transaction_id = 0
							</cfquery>
							</cfif>
							<tr>
								<form name="addItem#collection_object_id#" 
										method="post" 
										action="/Admin/AddUserLoanItem.cfm" 
										target="_blank">
									<input type="hidden" name="transaction_id" value="#ArctosLoanId#">
									<input type="hidden" name="collection_object_id" value="#collection_object_id#">
									<input type="hidden" name="loan_id" value="#loan_id#">
									
								<td>#institution_acronym# #collection_cde# #cat_num#</td>
								<td>#scientific_name#</td>
								<td>#preserve_method# #part_modifier# #part_name#</td>
								<td>#condition#</td>
								<td>#remark#</td>
								<cfquery name="ctUse" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
									select * from ctcf_loan_use_type
								</cfquery>
								<td>
									<cfset thisUse = "#use_type#">
									<select name="use_type" size="1">
										<cfloop query="ctUse">
											<option 
												<cfif #use_type# is "#thisUse#"> selected </cfif> value="#use_type#">#use_type#</option>
										</cfloop>
									</select>
								</td>
								<td>#encumbrances#</td>
								<td><input type="text" name="loan_item_remarks" value="#thisItemInArctos.loan_item_remarks#"></td>
								<td><input type="text" name="item_descr" value="#thisItemInArctos.item_descr#"></td>
								<td><input type="text" name="item_instructions" value="#thisItemInArctos.item_instructions#"></td>
								<td><input type="text" name="rejection_reason" value="#rejection_reason#">
									<input type="hidden" name="default_rejection_reason">
								</td>
								<td><cfif len(#rejection_reason#) gt 0>
										Rejected
									<cfelseif len(#thisItemInArctos.transaction_id#) gt 0>
										Approved
									<cfelse>
										Pending
									</cfif>
								</td>
								<td>
								<cfif #ArctosLoanId# gt 0>
									<cfif len(#thisItemInArctos.transaction_id#) is 0>
									<input type="button" value="Approve" class="savBtn"
										onmouseover="this.className='savBtn btnhov'" 
										onmouseout="this.className='savBtn'"
										onclick="submit();">
									
									<input type="button" value="Reject" class="delBtn"
										onmouseover="this.className='savBtn delBtn'" 
										onmouseout="this.className='delBtn'"
										onclick="addItem#collection_object_id#.default_rejection_reason.value='none specified';submit();">
									</cfif>
										</cfif>
								</td>
								</form>
							</tr>
						</cfloop><!--- specs loop ---->
						</table></td></tr>
						
			</cfloop><!----- proj loop ---->
			</td></tr>
	</cfloop><!--- end one loop ---->
	</table>
</cfoutput>
</cfif>
<!-------------------------------------------------------------------------->
<cfif  #action# is "makeArctosLoan">

	<cfoutput>
		<!--- get the next loan_number --->
		<cfquery name="nextTransId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select max(transaction_id) + 1 as nextTransactionId from trans
		</cfquery>
		<cfquery name="TRANS_ENTERED_AGENT_ID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_id from agent_name where agent_name = '#session.username#'
		</cfquery>
		<cfif len(#TRANS_ENTERED_AGENT_ID.agent_id#) is 0>
			You are not logged in as a recognized agent. Your login ID (#session.username#)
			must be entered in the agent names table as type 'login'.
		</cfif>
		<!------#loan_type# - #loan_num# - #initiating_date# - #loan_num_suffix# - #rec_agent_id# - #loan_num# - #auth_agent_id#---
		<cfabort>--->
		<!--- make sure they filled in all the good stuff. --->
		<cfif 
			len(#loan_type#) is 0 OR
			len(#loan_num#) is 0 OR
			len(#initiating_date#) is 0 OR
			len(#loan_num_suffix#) is 0 OR
			len(#rec_agent_id#) is 0 OR
			len(#loan_num#) is 0 OR
			len(#auth_agent_id#) is 0 
		>
			<br>Something bad happened.
			<br>You must fill in loan_type, loannumber, authorizing_agent_name, initiating_date, loan_num_prefix, received_agent_name.
			<br>Use your browser's back button to fix the problem and try again.
			<cfabort>
		</cfif>
		
		<!--- everything is peachy --->
		<!--- Create the trans --->

		<cfif mid(#loan_num#,5,1) is '.'>
			<cfset loanPrefix = left(#loan_num#,4)>
			<cfset loannum = #trim(mid(loan_num,6,3))#>
		<cfelse>
			The loan number you specified is not acceptable. Loan numbers must be 1234.1[2[3]] format.
		</cfif>
	
	<cftransaction>
			<cfquery name="newLoanTrans" datasource="#Application.uam_dbo#">
				INSERT INTO trans (
					TRANSACTION_ID,
					AUTH_AGENT_ID ,
					TRANS_DATE,
					TRANS_ENTERED_AGENT_ID,
					RECEIVED_AGENT_ID,
					CORRESP_FG,
					TRANSACTION_TYPE,
					NATURE_OF_MATERIAL
					<cfif len(#trans_remarks#) gt 0>
						,trans_remarks
					</cfif>)
				VALUES (
					#nextTransId.nextTransactionId#,
					#auth_agent_id#,
					'#initiating_date#',
					#TRANS_ENTERED_AGENT_ID.agent_id#,
					#REC_AGENT_ID#,
					0,
					'loan',
					'#NATURE_OF_MATERIAL#'
					<cfif len(#trans_remarks#) gt 0>
						,'#trans_remarks#'
					</cfif>
					)
					</cfquery> 
			
			<cfquery name="newLoan" datasource="#Application.uam_dbo#">
				INSERT INTO loan (
					TRANSACTION_ID,
					LOAN_TYPE,
					LOAN_NUM_PREFIX,
					LOAN_NUM,
					LOAN_NUM_SUFFIX
					<cfif len(#loan_status#) gt 0>
						,loan_status
					</cfif>
					<cfif len(#return_due_date#) gt 0>
						,return_due_date
					</cfif>
					<cfif len(#LOAN_INSTRUCTIONS#) gt 0>
						,LOAN_INSTRUCTIONS
					</cfif>
					<cfif len(#loan_description#) gt 0>
						,loan_description
					</cfif>
					 )
				values (
					#nextTransId.nextTransactionId#,
					'#loan_type#',
					'#loanPrefix#',
					#loanNum#,
					'#loan_num_suffix#'
					<cfif len(#loan_status#) gt 0>
						,'#loan_status#'
					</cfif>
					<cfif len(#return_due_date#) gt 0>
						,'#dateformat(return_due_date,"dd-mmm-yyyy")#'
					</cfif>
					<cfif len(#LOAN_INSTRUCTIONS#) gt 0>
						,'#LOAN_INSTRUCTIONS#'
					</cfif>
					<cfif len(#loan_description#) gt 0>
						,'#loan_description#'
					</cfif>
					)

			
			</cfquery>
			<cfquery name="link" datasource="#Application.uam_dbo#">
				UPDATE cf_loan SET transaction_id = #nextTransId.nextTransactionId#
				WHERE loan_id = #loan_id#
			</cfquery>
		</cftransaction>
	
		
		You made loan <a href="/Loan.cfm?Action=editLoan&transaction_id=#nextTransId.nextTransactionId#">#loanPrefix# #loanNum# #loan_num_suffix#</a>. You must click the link to complete the transaction.
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!----------------------------------------------------------------->
<cfif #Action# is "createNewProject">
	<cfoutput>
		<cfquery name="nextID" datasource="#Application.uam_dbo#">
			select max(project_id) + 1 as nextid from project
		</cfquery>
		<cfquery name="newProj" datasource="#Application.uam_dbo#">
		INSERT INTO project (
			PROJECT_ID,
			PROJECT_NAME
			<cfif len(#START_DATE#) gt 0>
				,START_DATE
			</cfif>
			
			<cfif len(#END_DATE#) gt 0>
				,END_DATE
			</cfif>
			<cfif len(#PROJECT_DESCRIPTION#) gt 0>
				,PROJECT_DESCRIPTION
			</cfif>
			<cfif len(#PROJECT_REMARKS#) gt 0>
				,PROJECT_REMARKS
			</cfif>
			 )
		VALUES ( 
			#nextID.nextid#,
			'#PROJECT_NAME#'
			<cfif len(#START_DATE#) gt 0>
				,'#dateformat(START_DATE,"dd-mmm-yyyy")#'
			</cfif>
			
			<cfif len(#END_DATE#) gt 0>
				,'#dateformat(END_DATE,"dd-mmm-yyyy")#'
			</cfif>
			<cfif len(#PROJECT_DESCRIPTION#) gt 0>
				,'#PROJECT_DESCRIPTION#'
			</cfif>
			<cfif len(#PROJECT_REMARKS#) gt 0>
				,'#PROJECT_REMARKS#'
			</cfif>
			 )   
	</cfquery>  
	<cfquery name="link" datasource="#Application.uam_dbo#">
		UPDATE cf_project SET project_id = #nextID.nextid# where trans_id = #cf_trans_id#
	</cfquery>
	The project has been added to Arctos. You <i><b>must</b></i> now edit the project to add agents.
	<p>
		Click <a href="/Project.cfm?Action=editProject&project_id=#nextID.nextid#" target="_blank">here</a> to edit in a new widow.
	</p>
	</cfoutput>
</cfif>