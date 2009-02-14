<cfinclude template="/includes/_header.cfm">
<cfif len(#session.username#) is 0>
	You aren't a registered user. Please sign in.
	<cfabort>
</cfif>
<cfset contactTable = '
<table border>
		<tr>
			<td>Collection</td>
			<td>Contact Name</td>
			<td>Contact/additional information</td>
		</tr>
		<tr>
			<td>UAM Mammal</td>
			<td>Link Olson</td>
			<td><a href="http://www.uaf.edu/museum/af/using.html">Request Guidelines</a></td>
		</tr>
		<tr>
			<td>UAM Plant</td>
			<td>Alan Batten</td>
			<td>{not released}</td>
		</tr>
		<tr>
			<td>KWP Lepidoptera</td>
			<td>Kenelm Philip</td>
			<td>{not released}</td>
		</tr>
		<tr>
			<td>UAM Mollusc</td>
			<td>Gordon Jarrell</td>
			<td><a href="mailto:fnghj@uaf.edu">fnghj@uaf.edu</a></td>
		</tr>
		<tr>
			<td>UAM Bird</td>
			<td>Kevin Winker</td>
			<td>{not released}</td>
		</tr>
		<tr>
			<td>UAM Fish</td>
			<td>Gordon Haas</td>
			<td>{not released}</td>
		</tr>
		<tr>
			<td>UAM Insect</td>
			<td>Gordon Jarrell</td>
			<td><a href="mailto:fnghj@uaf.edu">fnghj@uaf.edu</a></td>
		</tr>
		<tr>
			<td>UAM Bryozoan</td>
			<td>Gordon Jarrell</td>
			<td><a href="mailto:fnghj@uaf.edu">fnghj@uaf.edu</a></td>
		</tr>
		<tr>
			<td>UAM Crustacean</td>
			<td>Gordon Jarrell</td>
			<td><a href="mailto:fnghj@uaf.edu">fnghj@uaf.edu</a></td>
		</tr>
		<tr>
			<td>NBSB Bird</td>
			<td>Gordon Jarrell</td>
			<td><a href="mailto:fnghj@uaf.edu">fnghj@uaf.edu</a></td>
		</tr>
		<tr>
			<td>UAM Herp</td>
			<td>Gordon Jarrell</td>
			<td><a href="mailto:fnghj@uaf.edu">fnghj@uaf.edu</a></td>
		</tr>
	</table>
	'>
<!---- see if they've been pre-approved ---->
<cfquery name="isGood" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select approved_to_request_loans from cf_users where 
	username = '#session.username#'
</cfquery>
<cfif #isGood.approved_to_request_loans# neq 1>
<cfoutput>
	You haven't been approved to request loans.
	<br>The curators of the collection(s) from which you wish to borrow specimens must pre-approve your request.
	<br>Please contact the appropriate curator(s) for instructions on how to proceed with your loan request. You will need to include 
	your Arctos user name (#session.username#) in your request.
	
	#contactTable#
	</cfoutput>
	<p>
		Contact <a href="mailto:fnghj@uaf.edu">Gordon</a> or <a href="mailto:fndlm@uaf.edu">Dusty</a>
		if you are unable to contact the appropriate curator.
	</p>
	<cfabort>
</cfif>
<!---- / see if they've been pre-approved ---->
<div align="center">
	<table width="800">
		<tr>
			<td>
			

<cfif #action# is "nothing">
<cfquery name="getUser" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		username,
		cf_users.user_id,
		first_name,
		middle_name,
		last_name,
		affiliation,
		email,
		proj_title,
		proj_desc,
		cf_project.remarks proj_remark,
		loan_name,
		loan_description,
		instructions,
		cf_project.trans_id
	FROM
		cf_users,
		cf_user_data,
		cf_project,
		cf_loan
	WHERE
		cf_users.user_id = cf_user_data.user_id (+) AND
		cf_users.user_id = cf_project.user_id (+) AND
		cf_project.trans_id = cf_loan.trans_id (+) AND
		cf_users.username = '#session.username#'
</cfquery>
<cfquery name="user" dbtype="query">
	select username, first_name, last_name, affiliation, email from getUser
	group by username, first_name, last_name, affiliation, email
</cfquery>
<cfoutput>
	
	<cfif len(#user.first_name#) is 0 OR 
	len(#user.last_name#) is 0 OR
	len(#user.affiliation#) is 0 OR
	len(#user.email#) is 1>
		You must provide a first name, last name, affiliation, and email before you may request loan items. Please provide those data by clicking <a href="/login.cfm?action=setProfile">here</a>.
		
		<cfabort>
	</cfif>
	You are signed in as <b>#user.first_name# #user.last_name#</b>.
	<br>You are affiliated with <b>#user.affiliation#</b>, and your email address is <b>#user.email#</b>.
	<p>If that is not correct and complete, please <a href="/login.cfm?action=setProfile">update your profile</a>.</p>
	<p>An address is required before any loan requests may be approved. Please <a href="user_addr.cfm">create
	    an address</a> before you submit your loan request.</p>
<p>
	
			You must provide a project description before you may request a loan. A project may request multiple loans. You may view other project descriptions at <a href="/ProjectSearch.cfm">ProjectSearch</a>.
			
			<p>These data will not be published on Arctos before your loans(s) have been approved by the Curator. Please discuss any privacy issues which you might have with the Curator before accepting any loans.</p>
			
			<p>Data in Arctos are not necessarily complete or accurate. Items you request may be unavailable or damaged. Occasionally, items in the Collection may not be listed in Arctos. Please ask if you have any questions about availability.</p>
			
			<p>There are four basic steps to requesting a loan via Arctos:
				<ul>
					<li>Create a project
						<ul>
							<li>Begin by filling out the information on this page. A project is an overview of why you wish to borrow specimens. A project may have many loans (perhaps one for each graduate student working on the project).</li>
						</ul>						
					</li>
					<li>Create a loan request</li>
						<ul>
							<li>Just click the "Manage Loans" button that appears once you've created a project. All that's required to create a loan request is a loan name, which will be used to reference the loan throughout Arctos.</li>
						</ul>
					<li>Find and add items</li>
						<ul>
							<li>Once you've created a loan, you will be provided with a "Make Active" button. Clicking that button will set a cookie in your browser. Once a loan is active, just search for specimens as you normally would. You will be provided a shopping cart icon in SpecimenResults if you have an active loan (just go back to Manage Loans if you don't have the icon - browsers sometimes lose cookies for no apparent reason). Clicking the shopping cart allows you to add specimen parts to your loan request.</li>
						</ul>
					<li>Submit your request to the appropriate curator.</li>
					<ul>
						Once you have everything you wish to borrow in your shopping cart, submit your request by 
						contacting the appropriate curator(s).
					</ul>
				</ul>
			</p>
			Contact Information:
			<cfoutput>
				#contactTable#
			</cfoutput>
			
			<hr>
	<cfquery name="proj" dbtype="query">
		select
		user_id,
		trans_id,
		proj_title,
		proj_desc,
		proj_remark from getUser 
		group by 
		user_id,
		trans_id,
		proj_title,
		proj_desc,
		proj_remark
	</cfquery>
				
		<cfif len(#getUser.trans_id#) gt 0>
		<!--- >1 proj --->
		<font size="+1"><b>Edit existing Projects:</b></font>
		
		<cfset i=1>
		<table>
			
		
		
		<cfloop query="proj">
		<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		<td>
			<form name="Proj#i#" method="post" action="user_project.cfm">
				<input type="hidden" name="action">
				<input type="hidden" name="user_id" value="#user_id#">
				<input type="hidden" name="trans_id" value="#trans_id#">
			<table>
			<table >
			<tr>
				<td align="right">
				Project Title:
				</td>
				<td>
				<input type="text" name="proj_title" size="60" value="#proj_title#" class="reqdClr">
				</td>
			</tr>
			<tr>
				<td align="right">
				Project Description:
				</td>
				<td>
				<textarea name="proj_desc" rows="3" cols="40">#proj_desc#</textarea>
				</td>
			</tr>
			<tr>
				<td align="right">
				Project Remarks:
				</td>
				<td>
				<textarea name="proj_remark" rows="3" cols="40">#proj_remark#</textarea>
				</td>
			</tr>
			<tr>
				<td colspan="2">
				
				<input type="button" value="Delete Project" class="delBtn"
				onmouseover="this.className='delBtn btnhov'" 
				onmouseout="this.className='delBtn'"
				onclick="Proj#i#.action.value='deleteProj';submit();">			
				
				<input type="button" value="Save Edits" class="savBtn"
				onmouseover="this.className='savBtn btnhov'" 
				onmouseout="this.className='savBtn'"
				onclick="Proj#i#.action.value='saveEdits';submit();">
				
				<input type="button" value="Manage Loans" class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
				onmouseout="this.className='lnkBtn'"
				onclick="Proj#i#.action.value='manageLoans';submit();">
				</td>
			</form>
			
			</tr>
		</table>
			<cfset i=#i#+1>
		</cfloop>
		</td>
		</tr>
		</table>
</cfif>

<table class="newRec">
<form name="newProj" method="post" action="user_project.cfm">
				<input type="hidden" name="action" value="newProject">
				<input type="hidden" name="user_id" value="#getUser.user_id#">
			
				<tr>
					<td colspan="2">
						<b><font size="+1">Create a new project:</font></b>
					</td>
				</tr>
				<tr>
					<td align="right">
					<a href="javascript:void(0);" 
										onClick="loanHelp('title'); return false;"
										onMouseOver="self.status='Click for Project Title help.';return true;"
										onmouseout="self.status='';return true;">Project Title:
				  			</a>
					</td>
					<td><input type="text" name="proj_title" size="60" class="reqdClr"></td>
				</tr>
				<tr>
					<td align="right">
					<a href="javascript:void(0);" 
										onClick="loanHelp('descr'); return false;"
										onMouseOver="self.status='Click for Project Description help.';return true;"
										onmouseout="self.status='';return true;">Project Description:
				  			</a>
					</td>
					<td><textarea name="proj_desc" rows="3" cols="40"></textarea></td>
				</tr>
				<tr>
					<td align="right">
					<a href="javascript:void(0);" 
										onClick="loanHelp('remark'); return false;"
										onMouseOver="self.status='Click for Project Description help.';return true;"
										onmouseout="self.status='';return true;">Project Remarks:
				  			</a:
					></td>
					<td><textarea name="proj_remark" rows="3" cols="40"></textarea></td>
				</tr>
				<tr>
					<td colspan="2">
					<input type="reset" value="Clear Form" class="clrBtn"
				onmouseover="this.className='clrBtn btnhov'" 
				onmouseout="this.className='clrBtn'">
				
				<input type="submit" value="Create Project" class="insBtn"
				onmouseover="this.className='insBtn btnhov'" 
				onmouseout="this.className='insBtn'">
					</td>
				</tr>
			
			
	</form>
			</table>
			
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------->
<cfif #action# is "manageLoans">
<cfoutput>
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
		proj_title,
		proj_desc,
		remarks,
		loan_name,
		loan_description,
		instructions,
		cf_project.trans_id,loan_id
	FROM
		cf_project,
		cf_loan
	WHERE
		cf_project.trans_id = cf_loan.trans_id (+)
		AND cf_project.trans_id = #trans_id#
</cfquery>
<cfquery name="proj" dbtype="query">
	select proj_title,
		proj_desc,
		remarks from data group by 
		proj_title,
		proj_desc,
		remarks 
</cfquery>
<font size="+1"><b>You are managing loans for the following project:</b></font>

<blockquote>
	<b>Project Title:</b> #proj.proj_title#
	<br><b>Project Description:</b> #proj.proj_desc#
	<br><b>Project Remarks:</b> #proj.remarks#
</blockquote>
<p><a href="user_project.cfm">Back to Projects</a></p>
<hr>
<cfif len(#data.loan_id#) gt 0>
<font size="+1"><b>Existing Loans:</b></font>
<cfset l=1>
<table>
<cfloop query="data">
<tr	#iif(l MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
<td>
<form name="loan#l#" method="post" action="user_project.cfm">
	<input type="hidden" name="action">
	<input type="hidden" name="loan_id" value="#loan_id#">
	<input type="hidden" name="trans_id" value="#trans_id#">
	<table>
	<tr>
		<td align="right">
		<b>Loan Name:</b>
		</td>
		<td>
		<input type="text" name="loan_name" value="#loan_name#" size="60" class="reqdClr">
		
		</td>
	</tr>
	<tr>
		<td align="right">
		<b>Description:</b>
		</td>
		<td>
		
		<input type="text" name="loan_description" value="#loan_description#" size="60">
		</td>
	</tr>
	<tr>
		<td align="right">
		<b>Instructions:</b>
		</td>
		<td>
	
		<input type="text" name="instructions" value="#instructions#" size="60">
		</td>
	</tr>
	<tr>
		<td align="right">
		<b>Active Loan?</b>
		</td>
		<td>
		
	<cfif #loan_id# is "#session.active_loan_id#">
		Yes, you may now add parts via <a href="/SpecimenSearch.cfm">SpecimenSearch</a>.
		<br><input type="button" value="Make Inactive" class="savBtn"
				onmouseover="this.className='savBtn btnhov'" 
				onmouseout="this.className='savBtn'"
				onclick="loan#l#.action.value='makeInactive';submit();">
	<cfelse>
		No
		<input type="button" value="Make Active" class="savBtn"
				onmouseover="this.className='savBtn btnhov'" 
				onmouseout="this.className='savBtn'"
				onclick="loan#l#.action.value='makeActive';submit();">
	</cfif>
		</td>
	</tr>
	<tr>
		<td colspan="2">
		
				<input type="button" value="Save Edits" class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
				onmouseout="this.className='lnkBtn'"
				onclick="loan#l#.action.value='editLoan';submit();">
			<input type="button" value="Delete" class="delBtn"
				onmouseover="this.className='delBtn btnhov'" 
				onmouseout="this.className='delBtn'"
				onclick="loan#l#.action.value='deleteLoan';submit();">
			<input type="button" value="Items" class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'" 
				onmouseout="this.className='lnkBtn'"
				onclick="loan#l#.action.value='items';submit();">
			
		</td>
		
	</tr>
</table>
</form>
	</td>
		
	</tr>
	<cfset l=#l#+1>
</cfloop>
</table>
</cfif>
<table class="newRec">
						<tr>
							<td colspan="2">
								<b><font size="+1">Create a new loan for this project:</font></b>
							</td>
						</tr>
						<form name="newLoan" method="post" action="user_project.cfm">
							<input type="hidden" name="action" value="newLoan">
							<input type="hidden" name="trans_id" value="#trans_id#">
							<tr>
								<td align="right">
									<b>Loan Name:</b>
								</td>
								<td>
									<input type="text" name="loan_name" class="reqdClr" size="60">
								</td>
							</tr>
							<tr>
								<td align="right">
									<b>Loan Description:</b>
								</td>
								<td>
									<input type="text" name="loan_description" size="60">
								</td>
							</tr>
							<tr>
								<td align="right">
									<b>Loan Instructions:</b>
								</td>
								<td>
									<input type="text" name="instructions" size="60">
								</td>
							</tr>
							<tr>
								<td colspan="2">
								<input type="submit" value="Create Loan" class="insBtn"
				onmouseover="this.className='insBtn btnhov'" 
				onmouseout="this.className='insBtn'">
								</td>
							</tr>
						</form>
	</table>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
<cfif #action# is "items">

<cfoutput>
<cfquery name="loan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select loan_name from cf_loan where loan_id = #loan_id#
</cfquery>

Review loan items for <a href="user_project.cfm?action=manageLoans&trans_id=#trans_id#">#loan.loan_name#</a>.
<cfquery name="items" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select
			part_name, part_modifier, preserve_method,
			condition,
			collection.collection_cde,
			cat_num,
			institution_acronym,
			scientific_name,
			specimen_part.collection_object_id,
			remark,
			use_type
		FROM
			specimen_part,
			coll_object,
			collection,
			cataloged_item,
			identification,
			cf_loan_item
		WHERE
			specimen_part.collection_object_id = coll_object.collection_object_id AND
			cataloged_item.collection_object_id = identification.collection_object_id and
			accepted_id_fg = 1 and
			cataloged_item.collection_id = collection.collection_id and
			cataloged_item.collection_object_id = specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id = cf_loan_item.collection_object_id and
			loan_id = #loan_id#
			order by cat_num
</cfquery>
<cfquery name="ctUse" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from ctcf_loan_use_type
</cfquery>
<table border>
<tr>
	<td>Cat Number</td>
	<td>Identification</td>
	<td>Item</td>
	<td>Item Condition</td>
	<td>Remark</td>
	<td>Use</td>
	<td>&nbsp;</td>
</tr>
<cfset i=1>
<cfloop query="items">
<form name="item#i#">
<input type="hidden" name="action">
<input type="hidden" name="collection_object_id" value="#collection_object_id#">
<input type="hidden" name="loan_id" value="#loan_id#">
<input type="hidden" name="trans_id" value="#trans_id#">
<tr>
	<td>#institution_acronym# #collection_cde# #cat_num#</td>
	<td>#scientific_name#</td>
	<td>#preserve_method# #part_modifier# #part_name#</td>
	<td>#condition#</td>
	<td>
	<input name="remark" value="#remark#" type="text" size="50"></td>
	<td>
		<cfset thisUse = #use_type#>
		<select name="use_type" size="1">
				<cfloop query="ctUse">
					<option 
						<cfif #use_type# is "#thisUse#"> selected </cfif>value="#use_type#">#use_type#</option>
				</cfloop>
			</select>
			</td>
	<td>
	<input type="button" value="Remove" class="delBtn"
				onmouseover="this.className='delBtn btnhov'" 
				onmouseout="this.className='delBtn'"
				onclick="item#i#.action.value='delItem';submit();">
	<input type="button" value="Save Edits" class="savBtn"
				onmouseover="this.className='savBtn btnhov'" 
				onmouseout="this.className='savBtn'"
				onclick="item#i#.action.value='savItemChange';submit();">
	</td>
</tr>
</form>
<cfset i=#i#+1>
</cfloop>
</table>
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------->
<cfif #action# is "savItemChange">
<cfoutput>
<cfquery name="upItem" datasource="#uam_dbo#">
	update cf_loan_item 
	set remark='#remark#',
	use_type='#use_type#'
	where
	collection_object_id = #collection_object_id# and
	loan_id = #loan_id#
</cfquery>

<cflocation url="user_project.cfm?action=items&loan_id=#loan_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------->
<cfif #action# is "delItem">
<cfoutput>
<cfquery name="killItem" datasource="#uam_dbo#">
	delete from cf_loan_item where
	collection_object_id = #collection_object_id# and
	loan_id = #loan_id#
</cfquery>

<cflocation url="user_project.cfm?action=items&loan_id=#loan_id#&trans_id=#trans_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------->
<cfif #action# is "editLoan">
<cfoutput>
<cfquery name="edProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE CF_LOAN
		SET
		loan_name = '#loan_name#',
		loan_description='#loan_description#',
		instructions = '#instructions#'
	where
	loan_id = #loan_id#		
</cfquery>

<cflocation url="user_project.cfm?action=manageLoans&trans_id=#trans_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------->
<cfif #action# is "makeActive">
<cfoutput>
<cfquery name="edProj" datasource="#uam_dbo#">
	UPDATE cf_users SET active_loan_id = #loan_id#
	where username = '#session.username#'
</cfquery>
<cfset session.active_loan_id = #loan_id#>
<cflocation url="user_project.cfm?action=manageLoans&trans_id=#trans_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
<cfif #action# is "makeInactive">
<cfoutput>
<cfquery name="edProj" datasource="#uam_dbo#">
	UPDATE cf_users SET active_loan_id = null
	where username = '#session.username#'
</cfquery>
<cfset session.active_loan_id = "">
<cflocation url="user_project.cfm?action=manageLoans&trans_id=#trans_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------->
<cfif #action# is "deleteLoan">
<cfoutput>
<cfquery name="killItem" datasource="#uam_dbo#">
	DELETE FROM  CF_LOAN_item 
		where loan_id = #loan_id#
</cfquery>
<cfquery name="killLoan" datasource="#uam_dbo#">
	DELETE FROM  CF_LOAN 
		where loan_id = #loan_id#
</cfquery>
<cflocation url="user_project.cfm?action=manageLoans&trans_id=#trans_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------->
<cfif #action# is "newLoan">
<cfoutput>
<cfquery name="nid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select max(loan_id) + 1 as nid from cf_loan
</cfquery>
<cfquery name="edProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	INSERT INTO CF_LOAN (
		loan_id,
		trans_id,
		loan_name,
		loan_description,
		instructions)
	VALUES (
		#nid.nid#,
		#trans_id#,
		'#loan_name#',
		'#loan_description#',
		'#instructions#')
</cfquery>
<cflocation url="user_project.cfm?action=manageLoans&trans_id=#trans_id#">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------->
<cfif #action# is "saveEdits">
<cfoutput>

<cfquery name="edProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE cf_project SET		
		proj_title = '#proj_title#',
		proj_desc = '#proj_desc#',
		remarks = '#proj_remark#'
	WHERE trans_id = #trans_id#
</cfquery>
<cflocation url="user_project.cfm">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------->
<cfif #action# is "deleteProj">
<cfoutput>
<cfquery name="getLoans" datasource="#uam_dbo#">
	select loan_id from cf_loan where trans_id = #trans_id#
</cfquery>
<cftry>
<cfquery name="killItem" datasource="#uam_dbo#">
	DELETE FROM  CF_LOAN_item 
		where loan_id = #loan_id#
</cfquery>
	<cfcatch>
	</cfcatch>
</cftry>
<cfquery name="killLoan" datasource="#uam_dbo#">
	DELETE FROM  CF_LOAN 
		where trans_id = #trans_id#
</cfquery>
	
<cfquery name="killProj" datasource="#uam_dbo#">
	delete from cf_project WHERE
	trans_id = #trans_id#
</cfquery>
<cflocation url="user_project.cfm">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------->
<cfif #action# is "newProject">
<cfoutput>
<cfquery name="nid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select max(trans_id) + 1 as nid from cf_project
</cfquery>
<cfquery name="newProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	INSERT INTO cf_project (
		trans_id,
		user_id,
		proj_title,
		proj_desc,
		remarks)
	VALUES (
		#nid.nid#,
		#user_id#,
		'#proj_title#',
		'#proj_desc#',
		'#proj_remark#')
</cfquery>
<cflocation url="user_project.cfm">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------->
</td>
		</tr>
	</table>
</div>
<cfinclude template="../includes/_footer.cfm">