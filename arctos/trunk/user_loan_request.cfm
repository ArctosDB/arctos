<script>
	function addColls (data,status) {
		//alert(status);
		var theCheck = document.getElementById(status);
		var inp = document.getElementById('collections');
		var curr = inp.value;
		if (theCheck.checked == true) {
			if (curr.length > 0) {
				inp.value=curr + ", " + data;
			} else {
				inp.value=data;
			}
		} else { 
			var nVal = curr.replace(data,'');
			inp.value=nVal;
		}
		/*
		// strip out double commas and spaces
		var ncurr = inp.value;
		var nVal = ncurr.replace(", ",',');
		inp.value=nVal;
		var ncurr = inp.value;
		var swc = ncurr.charAt(0);
		alert("'" + swc + "'");
		if (swc == ",") {
			alert('comma1');
			var nlen = ncurr.length;
			noStartComma = ncurr.substring(1,nlen-1);
			alert(noStartComma);
			inp.value=noStartComma;
			alert(noStartComma);
		}
		var ncurr = inp.value;
		var nVal = ncurr.replace(",,",', ');
		*/
	}
</script>
<cfinclude template="includes/_header.cfm">

<!------------------------------------------------------->
<!--- see if they've been approved for an active loan--->
	<cfif not isdefined("session.username") or len(#session.username#) is 0>
		You must sign in before using this form. 
		You may <a href="login.cfm">create an Arctos account here</a>.
		<cfabort>
	</cfif>
	
	<cfquery name="isApp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			loan_request_coll_id,
			email
		from 
			cf_users,
			cf_user_data
		where
			cf_users.user_id = cf_user_data.user_id and
			username='#session.username#' 
	</cfquery>
	<cfif not isdefined("isApp.email") or len(#isApp.email#) is 0>
		You must provide contact information, including an email address, before using this form.  
		You may <a href="myArctos.cfm">fill out your profile here</a>.
		<cfabort>
	</cfif>
	<cfset session.loan_request_coll_id = #isApp.loan_request_coll_id#>
	<cfset loan_request_coll_id = #session.loan_request_coll_id#>
	
	<!----
	<cflocation addtoken="no" url="user_loan_request.cfm?loan_request_coll_id=#loan_request_coll_id#">
	
	
	<cfoutput>select loan_request_coll_id from 
		cf_users,cf_user_loan where
		username='#session.username#' and
		cf_users.user_id = cf_user_loan.user_id and
		is_active = 1
---------#loan_request_coll_id#---------

</cfoutput>
	---->
	
	
	

<cfset title='Loan Request Authorization'>
<!------------------------------------------------------->
<cfif #action# is "allLoans">
All your loans:
<cfquery name="allLoans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		cf_user_loan.user_loan_id,
		IS_ACTIVE,
		PROJECT_TITLE,
		PROJECT_DESCRIPTION 
		 from 
		cf_users,cf_user_loan where
		username='#session.username#' and
		cf_users.user_id = cf_user_loan.user_id 
</cfquery>
<cfoutput>
<table border>
	<tr>
		<td>Title</td>
		<td>Active?</td>
	</tr>
	<cfloop query="allLoans">
		<tr>
		<td> #PROJECT_TITLE#</td>
		<td>#IS_ACTIVE#</td>
	</tr>
	</cfloop>
	
</table>
</cfoutput>
</cfif>




<!-------------------------------------------->
<cfif #action# is "finalize">
	<cfoutput>
	<cfquery name="who" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
					agent_name,
					address,
					institution_acronym,
					collection.collection_cde				
				from
					preferred_agent_name,
					electronic_address,
					collection_contacts,
					cf_loan_item,
					specimen_part,
					cataloged_item,
					collection
				where
					preferred_agent_name.agent_id=electronic_address.agent_id and
					preferred_agent_name.agent_id = collection_contacts.CONTACT_AGENT_ID AND
					collection_contacts.collection_id = collection.collection_id AND
					collection.collection_id = cataloged_item.collection_id AND
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
					specimen_part.collection_object_id = cf_loan_item.collection_object_id AND				
					contact_role='loan request' and
					address_type='e-mail'
					and USER_LOAN_ID = #USER_LOAN_ID#
				group by 
					agent_name,
					address	,
					institution_acronym,
					collection.collection_cde
	</cfquery>
	
	
		
	<cfset mailto = "">
	<cfset contacts = "">
	<cfloop query="who">
		<cfset mailto = "#address#,#mailto#">
		<cfset contacts = "#contacts##agent_name#  (#institution_acronym# #collection_cde#)<br />">		
	</cfloop>
	<form name="m" method="post" action="user_loan_request.cfm">
		<input type="hidden" name="action" value="mailFinal" />
		<input type="hidden" name="mailto" value="#mailto#" />
		<input type="hidden" name="contacts" value="#contacts#" />
		An email requesting that this loan request be finalized will be sent to:
		<br />#contacts#
		<p>You may add any additional comments here:</p>
		<textarea rows="15" cols="60" name="userInput"></textarea>
		<br /><input type="submit" value="Send Email" />
	</form>	
	</cfoutput>
</cfif>
<!-------------------------->
<cfif #action# is "mailFinal">
		<cfoutput>
			<cfmail to="#mailto#" 
				subject="Arctos: Finalize this Loan Request Authorization" 
				from="LoanAuthorizationRequest@#Application.fromEmail#" 
				type="html">
				<br />A user, <B><I>#session.username#</I></B>, wishes to finalize their user loan request and activate a Museum loan.
				<br />Log into Arctos and click 
				<a href="#Application.ServerRootUrl#/Admin/manage_user_loan_request.cfm?action=manageSpecs&req_name=#session.username#">
				this link</a> to review their request.
				<cfif len(#userInput#) gt 0>
					The user provided these comments:
					<br />#userInput#
				</cfif>
				<br />This email has been sent to the loan request contacts listed below:
				<br />#contacts#
			</cfmail>
			Your request has been sent. A curator will contact you. Thank you for using Arctos! 
			
		</cfoutput>
</cfif>
<!-------------------------->
<cfif #action# is "makeReq">
<cfoutput>
<ul>
	<li>
		This form serves as a method to contact the appropriate Curator. It is not a guarantee that you will receive items. 
		Loan approvals are at the Curator's discretion and subject to their loan policy.
	</li>
	<li>
		Your request will not be granted unless you have filled out an accurate
		<a href="/login.cfm?action=setProfile">user profile</a>. Your personal information will not be shared 
		except as necessary to consider your request. Curators will ask for additional information about you 
		and your project before approving any loan request authorizations.
	</li>
	<li>
		File a <a href="/info/bugs.cfm">Bug Report</a> if you have and questions or concerns 
		about this application.
	</li>
	<li>
		Be sure to submit your request to the proper collection!
	</li>
</ul>		<cfquery name="instcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				collection_id,
				collection_cde,
				institution_acronym,
				web_link,
				web_link_text
			FROM
				collection
			ORDER BY
					 collection_id,institution_acronym,collection_cde
		</cfquery>
		<table border>
			<tr>
			<td>Collection</td>
			<td>Loan Request Contact</td>
			<td>Web Site</td>
			<td>Request Authorization?</td>
			</tr>
			<form  name="reqLoanAuth" method="post" action="user_loan_request.cfm">
				<input type="hidden" name="action" value="submitLoanAuthReq" />
				<input type="hidden" name="collections" id="collections"/>
		<cfloop query="instcoll">
			<cfquery name="contacts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					agent_name,
					address					
				from
					preferred_agent_name,
					electronic_address,
					collection_contacts
				where
					preferred_agent_name.agent_id=electronic_address.agent_id and
					collection_contacts.CONTACT_AGENT_ID = preferred_agent_name.agent_id
					and contact_role='loan request' and
					address_type='e-mail'
					and collection_id=#collection_id#				
			</cfquery>
			<cfset thisName = "">
			<cfset thisAddr = "">
			<cfloop query="contacts">
				<cfif len(#thisName#) is 0>
					<cfset thisName = "#agent_name#">
				<cfelse>
					<cfset thisName = "#thisName#, #agent_name#">
				</cfif>
				<cfif len(#thisAddr#) is 0>
					<cfset thisAddr = "#address#">
				<cfelse>
					<cfset thisAddr = "#thisAddr#, #address#">
				</cfif>
			</cfloop>
			<tr>
				<td>#institution_acronym# #collection_cde#</td>
				<td>
					<cfif len(#thisName#) gt 0>
						#thisName#
					<cfelse>
						NONE (use #Application.DataProblemReportEmail#)
					</cfif>
				</td>
				<td>
					<cfif len(#web_link#) gt 0 and len(#web_link_text#) gt 0>
						<a href="#web_link#" target="_blank">#web_link_text#</a>
					<cfelse>
						NONE
					</cfif>
				</td>
				<td>
					<cfif len(#thisAddr#) gt 0>
						<input type="checkbox" name="emails" value="#thisAddr#" onclick="addColls('#institution_acronym# #collection_cde#',this.id)" id="check#collection_id#"/>
					<cfelse>
						<input type="checkbox" name="emails" value="#Application.DataProblemReportEmail#" onclick="addColls('#institution_acronym# #collection_cde#',this.id)" id="check#collection_id#"/>
					</cfif>
				</td>
				
			</tr>
		</cfloop>	
		<tr>
			<td colspan="4" align="right">
					<input type="submit" value="Request Access" />
				</td>
		</tr>	
		</form>
		</table>
		</cfoutput>
</cfif>
<!---------------------------------------------------------->
<cfif #action# is "nothing">
	<cfoutput>
	
	<cfif not isdefined("loan_request_coll_id") OR len(#loan_request_coll_id#) is 0>
		<cflocation url="user_loan_request.cfm?action=makeReq">
	</cfif>
	<!-----------------------------they've been approved for something -------------------------->
		<cfquery name="meta" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select * from cf_user_loan,
			cf_users
			where 
			cf_users.user_id=cf_user_loan.user_id and
			is_active=1 and
			username='#session.username#'
		</cfquery>
		<cfquery name="whatColls" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select institution_acronym,collection_cde from collection
			where collection_id IN (#isApp.loan_request_coll_id#) 
		</cfquery>
		You have been approved to request loans from the following collections:
		<ul>
		<cfloop query="whatColls">
			<li>#institution_acronym# #collection_cde#</li>
		</cfloop>
		</ul>
		<p></p>
		<a href="user_loan_request.cfm?action=makeReq">Request Others</a>
		<p></p>
		<cfif #meta.recordcount# gt 0>
			You may edit your loan details below:
			<table>
				<form name="editLoan" method="post" action="user_loan_request.cfm">
					<input type="hidden" name="action" value="makeNewMeta" />
					<input type="hidden" name="USER_LOAN_ID" value="#meta.USER_LOAN_ID#" />
					<tr>
						<td>
							<label for="project_title">Project Title</label>
							<textarea name="project_title" id="project_title" rows="3" cols="100" class="reqdClr">#meta.project_title#</textarea>
						</td>
					</tr>
					<tr>
						<td>
							<label for="project_description">Project Description</label>
							<textarea name="project_description" id="project_description" rows="15" cols="100" class="reqdClr">#meta.project_description#</textarea>
						</td>
					</tr>
					<tr>
						<td colspan="2"><input type="submit" value="save edits" /></td>
					</tr>
				</form>
			</table>
			<!--- specimens they've already selected --->
			<cfquery name="specs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					institution_acronym,
					cataloged_item.collection_cde,
					cataloged_item.collection_object_id,
					cat_num,
					scientific_name,
					verbatim_date,
					spec_locality,
					higher_geog,
					part_name,
					specimen_part.collection_object_id partID,
					approval_status
				FROM
					collection,
					cataloged_item,
					identification,
					collecting_event,
					locality,
					geog_auth_rec,
					specimen_part,
					cf_loan_item
				WHERE
					cataloged_item.collection_id=collection.collection_id AND
					cataloged_item.collection_object_id = identification.collection_object_id AND
					cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
					collecting_event.locality_id = locality.locality_id AND
					locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
					specimen_part.collection_object_id = cf_loan_item.collection_object_id AND
					cf_loan_item.USER_LOAN_ID = #meta.USER_LOAN_ID# AND
					accepted_id_fg=1
			</cfquery>
			<br />Use <a href="/SpecimenSearch.cfm">SpecimenSearch</a> to add items to your loan request.<br />
<br />
			Specimens Requested:
			<table border>
				<tr>
					<td>Cat Num</td>
					<td>Scientific Name</td>
					<td>Part</td>
					<td>Date</td>
					<td>Locality</td>
					<td>Geography</td>
					<td>Status</td>
					<td>Delete</td>
				</tr>
				
				<cfloop query="specs">
				<form name="specs#partID#" method="post" action="user_loan_request.cfm">
					<input type="hidden" name="action" />
					<input type="hidden" name="partID" value="#partID#" />
					<input type="hidden" name="collection_object_id" value="#collection_object_id#" />
					<input type="hidden" name="USER_LOAN_ID" value="#meta.USER_LOAN_ID#" />
				<tr>
					<td>
						<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
							#institution_acronym# #collection_cde# #cat_num#</a>
					</td>
					<td><em>#scientific_name#</em></td>
					<td>#part_name#</td>
					<td>#verbatim_date#</td>
					<td>#spec_locality#</td>
					<td>#higher_geog#</td>
					<td>#APPROVAL_STATUS#</td>
					<td><img src="/images/del.gif" border="0" class="likeLink" onclick="specs#partID#.action.value='delete';specs#partID#.submit();" /></td>
				</tr>
				</form>
				</cfloop>				
			</table>
			<input type="button" value="Finalize This Loan Request" onclick="document.location='user_loan_request.cfm?action=finalize&user_loan_id=#meta.USER_LOAN_ID#'" />
		<cfelse><!--- new --->
			Please provide additional information about your loan request:
			<table class="newRec">
				<form name="newLoanSetup" method="post" action="user_loan_request.cfm">
					<input type="hidden" name="action" value="makeNewMeta" />
					<tr>
						<td>
							<label for="project_title">Project Title</label>
							<textarea name="project_title" id="project_title" rows="3" cols="100" class="reqdClr"></textarea>
						</td>
					</tr>
					<tr>
						<td>
							<label for="project_description">Project Description</label>
							<textarea name="project_description" id="project_description" rows="15" cols="100" class="reqdClr"></textarea>
						</td>
					</tr>
					<tr>
						<td colspan="2"><input type="submit" /></td>
					</tr>
				</form>
			</table>
		</cfif><!--- end new --->
	</cfoutput>
</cfif>

<!-------------------------------------------->
<cfif #action# is "delete">
	<cfoutput>
	<cfquery name="killOne" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		delete from cf_loan_item where  
			USER_LOAN_ID = #USER_LOAN_ID# AND
 			COLLECTION_OBJECT_ID = #partID#    
	</cfquery>
	<cflocation url="user_loan_request.cfm">
	</cfoutput>
</cfif>
<!-------------------------------------------->

<cfif #action# is "makeNewMeta">
	<cfoutput>
	<cfif len(#project_title#) is 0 or len(#project_description#) is 0>
		You must supply a Project Title and Project Description.
		<cfabort>
	</cfif>
	<cfquery name="userid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select user_id from cf_users where username='#session.username#'
	</cfquery>
	<cfquery name="addOne" datasource="#Application.uam_dbo#">
		insert into cf_user_loan (
        	user_loan_id,
        	user_id,
        	is_active,
       		project_title,
        	project_description
		) VALUES (
			SOMERANDOMSEQUENCE.nextval,
			#userid.user_id#,
			1,
			'#project_title#',
			'#project_description#'
		)
	</cfquery>
	<cflocation url="user_loan_request.cfm">
	</cfoutput>
</cfif>
<!-------------------------------------------->

<cfif #action# is "submitLoanAuthReq">
<cfoutput>
	<!---
	
	--->
	<cfset collections = replace(collections, ", ",",","all")>
	<cfloop condition="#collections# contains ',,'">
		<cfset collections = replace(collections, ",,",",","all")>
	</cfloop>
	<cfif left(collections,1) is ",">
		<cfset collections = right(collections,len(collections)-1)>
	</cfif>
		<cfset c = "<ul>">
		<cfloop list="#collections#" index="i">
			<cfset c="#c#<li>#i#</li>">
		</cfloop>
		<cfset c = "#c#</ul>">
		<cfset collections =#c#>
	<cfmail to="#emails#" 
			subject="Arctos Loan Request Authorization" 
			from="LoanAuthorizationRequest@#Application.fromEmail#" 
			type="html">		
		An Arctos user, <b><i>#session.username#</i></b>, wishes to borrow material from the following collection(s):
		#collections# 
		for which you have been designated loan request contact.
			<p>
				<a href="#Application.ServerRootUrl#/Admin/manage_user_loan_request.cfm?req_name=#session.username#&action=manage">
					Go the the User Loan Request form
				</a>
			</p>
		</cfmail>
		
		<!---#emails#--->
		An email has been sent to the appropriate Curator(s). Additional details may be available from their web page, 
		linked from <a href="#Application.ServerRootUrl#/Collections/">#Application.ServerRootUrl#/Collections/Collections/</a>, 
		if available. You will be notified when we've taken action on your request. Thanks for using Arctos!
		<p>
			Please use the tabs above to continue navigating Arctos.
		</p>
</cfoutput>
</cfif>

<cfinclude template="includes/_footer.cfm">