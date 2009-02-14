<cfinclude template="/includes/_header.cfm">

<div style="padding:10px;">
<script>
	function changeStatus(id,status) {
		var pidstr = 'partID' + id;
		var lidstr = 'user_loan_id' + id;
		var partid = document.getElementById(pidstr).value;
		var loanid = document.getElementById(lidstr).value;
		var sdiv = document.getElementById('statusDiv');
		sdiv.style.backgroundColor="red";
		DWREngine._execute(_user_loan_functions, null, 'changeStatus', partid,loanid,status, success_changeStatus);
	}
	function success_changeStatus(result) {
		if (result != 'success') {
			alert('Your save failed! Please reload this page, make sure nothing is cached, and try again.');
		} else {
			var sdiv = document.getElementById('statusDiv');
			sdiv.style.backgroundColor="green";
		}
	}
	
	function changeRemark(id,remark) {
		var pidstr = 'partID' + id;
		var lidstr = 'user_loan_id' + id;
		var partid = document.getElementById(pidstr).value;
		var loanid = document.getElementById(lidstr).value;
		var rdiv = document.getElementById('remarkDiv');
		rdiv.style.backgroundColor="red";
		DWREngine._execute(_user_loan_functions, null, 'changeRemark', partid,loanid,remark, success_changeRemark);
	}
	function success_changeRemark(result) {
		if (result != 'success') {
			alert('Your save failed! Please reload this page, make sure nothing is cached, and try again.');
		} else {
			var rdiv = document.getElementById('remarkDiv');
			rdiv.style.backgroundColor="green";
		}
	}
	function getLoanDetails () {
	//alert('go');
		var inst = document.getElementById('institution_acronym').value;
		var pre = document.getElementById('loan_num_prefix').value;
		var num = document.getElementById('loan_num').value;
		var suf = document.getElementById('loan_num_suffix').value;
		DWREngine._execute(_user_loan_functions, null, 'getLoanDetails', inst,pre,num,suf, success_getLoanDetails);
	}
	function success_getLoanDetails(result) {
		//alert('back');
		var tid = result[0].TRANSACTION_ID;
		//alert(tid);
		if (tid == 0) {
			alert('zero matches');
		} else if (tid == -99999) {
			alert('lotzo matches');
		} else {
			var ltype = result[0].LOAN_TYPE;
			var linst = result[0].LOAN_INSTRUCTIONS;
			var ldesc = result[0].LOAN_DESCRIPTION;
			var recagnt = result[0].REC_AGENT;
			var authagnt = result[0].AUTH_AGENT;
			var natofma = result[0].NATURE_OF_MATERIAL;
			
			var lt = document.getElementById('loan_type');
			var li = document.getElementById('loan_instructions');
			var ld = document.getElementById('loan_description');
			var ra = document.getElementById('rec_agent');
			var aa = document.getElementById('auth_agent');
			var nom = document.getElementById('nature_of_material');
			var el = document.getElementById('editLoanLink');
			lt.innerHTML=ltype;
			li.innerHTML=linst;
			ld.innerHTML=ldesc;
			ra.innerHTML=recagnt;
			aa.innerHTML=authagnt;
			nom.innerHTML=natofma;
			var theLink = '<a href="/Loan.cfm?Action=editLoan&transaction_id=' + tid + '">Edit This Loan</a>';
			el.innerHTML=theLink;
			var theTab = document.getElementById('loanDetails');
			theTab.style.display='';
			var mfr =  document.getElementById('moveForReal');
			var theID =  document.getElementById('user_loan_id').value;
			var tmvlnk = '<a href="manage_user_loan_request.cfm?action=reallyMoveEmNow&user_loan_id=';
			tmvlnk += theID + "&transaction_id=" + tid + '">Yep, put these specimens in this loan for real</a>';
			mfr.innerHTML = tmvlnk;
		}
	}
</script>
<cfquery name="whoAreYou" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select contact_agent_id from 
	collection_contacts,
	agent_name
	where
	contact_agent_id=agent_id and
	agent_name='#session.username#' and
	contact_role='loan request'		
</cfquery>
<cfif #whoAreYou.recordcount# is 0>
	You are not a loan request contact!
	<p>
		Aborting....<cfabort>
	</p>
</cfif>
<!-------------------->
<cfif #action# is "reallyMoveEmNow">
	<cfoutput>
		<cfquery name="rec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select agent_id from agent_name where 
			agent_name_type='login' and 
			agent_name='#session.username#'
		</cfquery>
		<cfif #rec.recordcount# is 1>
			<cfset RECONCILED_BY_PERSON_ID = #rec.agent_id#>
		<cfelse>
			Bad agent.
			<cfabort>
		</cfif>
	<cfquery name="items" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			 COLLECTION_OBJECT_ID,
			 REMARK,
			 USE_TYPE,
			 ADMIN_REMARK
		from cf_loan_item 
		where user_loan_id = #user_loan_id#
		AND	APPROVAL_STATUS='approve'
	</cfquery>
	<cftransaction>
	<cfloop query="items">
		<cfif #USE_TYPE# is "subsample">
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
					#RECONCILED_BY_PERSON_ID#,
					'#RECONCILED_DATE#',
					#RECONCILED_BY_PERSON_ID.agent_id#,
					'#dateformat(now(),"dd-mmm-yyyy")#',
					'#parentData.coll_obj_disposition#',
					1,
					'#parentData.condition#')
			</cfquery>
			<cfquery name="newPart" datasource="#Application.uam_dbo#">
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
					,#parentData.DERIVED_FROM_CAT_ITEM#)				
			</cfquery>
			<cfset thisCollObjId = #nextID.nextID#>
		<cfelse>
			<cfset thisCollObjId = #COLLECTION_OBJECT_ID#>
		</cfif>
		
		<cfquery name="insItem" datasource="#Application.uam_dbo#">
		INSERT INTO loan_item (
			TRANSACTION_ID,
			COLLECTION_OBJECT_ID,
			RECONCILED_BY_PERSON_ID,
			RECONCILED_DATE,
			ITEM_DESCR
			<cfif len(#ADMIN_REMARK#) gt 0>
				,LOAN_ITEM_REMARKS
			</cfif>
		) values (
			#transaction_id#,
			#thisCollObjId#,
			#RECONCILED_BY_PERSON_ID#,
			'#dateformat(now(),"dd-mmm-yyyy")#',
			'User-selected item to #use_type#.' 
			<cfif len(#ADMIN_REMARK#) gt 0>
				,'#ADMIN_REMARK#'
			</cfif>
			)
		</cfquery>
		<cfquery name="inLoanNow" datasource="#Application.uam_dbo#">
		update cf_loan_item
		set APPROVAL_STATUS = 'in loan'
		where 
		COLLECTION_OBJECT_ID=#COLLECTION_OBJECT_ID# and
		USER_LOAN_ID=#USER_LOAN_ID#
		</cfquery>

	</cfloop>
 		</cftransaction>
		All Done.
		<a href="/Loan.cfm?transaction_id=#transaction_id#&action=editLoan">Go to Loan</a>
	</cfoutput>

</cfif>


<!------------------------------------------->
<cfif #action# is "approveAllItems">
	<cfquery name="appAll" datasource="#Application.uam_dbo#">
		update cf_loan_item set APPROVAL_STATUS='approve'
		where user_loan_id=#user_loan_id#
	</cfquery>
	<cfoutput>
		<cflocation url="manage_user_loan_request.cfm?action=manageSpecs&req_name=#req_name#" addtoken="no">
	</cfoutput>

</cfif>
<!------------------------------------------>
<cfif #action# is "makeRealLoan">
	<cfoutput>
	<cfquery name="meta" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select  
			cf_user_loan.USER_LOAN_ID,
			 PROJECT_TITLE,
			 PROJECT_DESCRIPTION ,
			 username 
		from
			cf_user_loan,
			cf_users,
			cf_loan_item
		where
			IS_ACTIVE=1 and
			APPROVAL_STATUS='approve' and
			cf_user_loan.user_id=cf_users.user_id and
			cf_user_loan.USER_LOAN_ID=cf_loan_item.USER_LOAN_ID and
			cf_user_loan.USER_LOAN_ID='#loan_id#'
	</cfquery>
	<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select distinct(institution_acronym)  from collection
	</cfquery>
	<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_cde from ctcollection_cde
	</cfquery>
	You are adding the <strong>#meta.recordcount#</strong> approved items in User Loan <em><strong>#meta.PROJECT_TITLE#</strong></em> to a Museum loan.
	<p>
		<a href="manage_user_loan_request.cfm?action=manageSpecs&req_name=#meta.username#">review items</a>	
	</p>
	<table border>
	<form name="loan" method="post" action="manage_user_loan.cfm">
		<input type="hidden" name="user_loan_id" id="user_loan_id" value="#meta.USER_LOAN_ID#" />
		<tr>
			<td>
				<label for="institution_acronym">Institution</label>
				<select name="institution_acronym" size="1" id="institution_acronym" >
					<cfloop query="ctInst">
						<option value="#ctInst.institution_acronym#">#ctInst.institution_acronym#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<label for="loan_num_prefix">Prefix</label>
				<input type="text" name="loan_num_prefix" class="reqdClr" size="5" id="loan_num_prefix">
			</td>
			<td>
				<label for="loan_num">Number</label>
				<input type="text" name="loan_num" class="reqdClr" size="6" id="loan_num">
			</td>
			<td>
				<label for="loan_num_suffix">Suffix</label>
				<select name="loan_num_suffix" size="1" id="loan_num_suffix">
					<cfloop query="ctcoll">
						<option value="#ctcoll.collection_cde#">#ctcoll.collection_cde#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="button" value="Get Details" onclick="getLoanDetails()" />
			</td>
		
		</tr>
	</form>
	</table>
	<div id="loanDetails" style="display:none;">
		<table border>
			<tr>
				<td align="right">Loan Type:</td>
				<td><div id="loan_type"></div></td>
			</tr>
			<tr>
				<td align="right">Loan Instructions:</td>
				<td><div id="loan_instructions"></div></td>
			</tr>
			<tr>
				<td align="right">Loan Description:</td>
				<td><div id="loan_description"></div></td>
			</tr>
			<tr>
				<td align="right">To Agent:</td>
				<td><div id="rec_agent"></div></td>
			</tr>
			<tr>
				<td align="right">Authorized By:</td>
				<td><div id="auth_agent"></div></td>
			</tr>
			<tr>
				<td align="right">Nature of Material:</td>
				<td><div id="nature_of_material"></div></td>
			</tr>
			<tr>
				<td colspan="2">
					<div id="editLoanLink" align="center"></div>
				</td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<div id="moveForReal"></div>
				</td>
			</tr>
		</table>
	</div>
	
	</cfoutput>
</cfif>

<!------------------------------------------->
<cfif #action# is "nothing">
	<cfoutput>
	
	<form name="m" method="post" action="manage_user_loan_request.cfm">
		<input type="hidden" name="action" value="manage" />
		<input type="hidden" name="contact_agent_id" value="#whoAreYou.contact_agent_id#" />
		Username: <input type="text" name="req_name" />
		<input type="submit" />
	</form>
	<cfquery name="all" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			username,
			PROJECT_TITLE,
			count(COLLECTION_OBJECT_ID) numReqs
		FROM
			cf_users,
			cf_user_loan,
			cf_loan_item
		WHERE
			cf_users.user_id = cf_user_loan.user_id AND
			cf_user_loan.USER_LOAN_ID = cf_loan_item.USER_LOAN_ID (+)
		GROUP BY
			username,
			PROJECT_TITLE
		ORDER BY
			username,
			PROJECT_TITLE
	</cfquery>
	<table border>
	<tr>
		<td>A Frog</td>
		<td>Username</td>
		<td>Loan Title</td>
		<td>Number Specimens</td>		
	</tr>
	<cfloop query="all">
		<tr>
			<td><img src="/images/rana.gif" class="likeLink" onclick="m.req_name.value='#username#';m.submit();" /></td>
			<td>#username#</td>
			<td>#PROJECT_TITLE#</td>
			<td>#numReqs#</td>		
		</tr>
	</cfloop>
	</table>
	</cfoutput>
</cfif>
<!--------------------------------------------->
<cfif #action# is "manage">
<cfoutput>
	<cfif len(#req_name#) is 0>
		need a req_name <cfabort>
	</cfif>
	<cfquery name="userdata" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from CF_USER_DATA,cf_users
		where
			CF_USER_DATA.user_id=cf_users.user_id and
		 username='#req_name#'
	</cfquery>
	<cfquery name="colls" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			institution_acronym,
			collection_cde,
			collection.collection_id,
			address,
			agent_name
		from 
			collection,
			collection_contacts,
			electronic_address,
			preferred_agent_name
		where 
			collection.collection_id=collection_contacts.collection_id and
			collection_contacts.contact_agent_id=preferred_agent_name.agent_id and
			preferred_agent_name.agent_id = electronic_address.agent_id and
			contact_agent_id=#whoAreYou.contact_agent_id# and
			contact_role='loan request' and
			address_type='e-mail'
	</cfquery>
	You are logged in as #session.username#, the loan request contact for collection(s):
	<br /><span style="font-size:12px; font-style:italic;">
		Note: if you see nothing below, you may not have an email address on file.
	</span>
	<ul>
		<cfloop query="colls">
			<li>#institution_acronym# #collection_cde#</li>
		</cfloop>
	</ul>
	You are managing loan requests for user #req_name#. This user has submitted the following information about themselves:
	 <p>
	 	First Name: #userdata.FIRST_NAME#
		<br />Middle Name: #userdata.MIDDLE_NAME#
		<br />Last Name: #userdata.LAST_NAME#
		<br />Affiliation: #userdata.AFFILIATION#
		<br />Email: #userdata.EMAIL#
	 </p>
	 <cfquery name="prevAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	 	select loan_request_coll_id from cf_users where username='#req_name#'
	 </cfquery>
	
	 <cfif #len(prevAuth.loan_request_coll_id)# is 0>
	 	This user has not been previously approved to request loans from any collection.
	<cfelse>
		 <cfquery name="alreadyGotOne" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select collection_cde,institution_acronym
			from collection
			where collection_id IN (#prevAuth.loan_request_coll_id#)
		 </cfquery>
		This user has already been approved to request loan from the following collections:
		<ul>
		<cfloop query="alreadyGotOne">
			<li>#institution_acronym# #collection_cde#</li>
		</cfloop>
		</ul>
		<cfquery  name="gotSpecs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				institution_acronym,
				cataloged_item.collection_cde,
				count(cataloged_item.collection_object_id) as nspecs		
				FROM
					collection,
					cataloged_item,
					specimen_part,
					cf_loan_item,
					cf_user_loan,
					cf_users
				WHERE
					cataloged_item.collection_id=collection.collection_id AND
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
					specimen_part.collection_object_id = cf_loan_item.collection_object_id AND
					cf_loan_item.USER_LOAN_ID = cf_user_loan.USER_LOAN_ID AND
					cf_user_loan.user_id = cf_users.user_id AND
					username='#req_name#'
				GROUP BY
					institution_acronym,
					cataloged_item.collection_cde
		</cfquery>
		<cfif #gotSpecs.recordcount# is 0>
			This user has no specimens selected.
		<cfelse>
			This user has the following specimens selected.<br />
			<cfloop query="gotSpecs">
				#nspecs# #institution_acronym# #collection_cde#<br />
			</cfloop>	
			<p><a href="manage_user_loan_request.cfm?action=manageSpecs&req_name=#req_name#">Manage Active Loans</a></p>	
		</cfif>
		
	 </cfif>
	 Approving a user here will allow them to select specific loan items in Arctos and submit a request.
	 Items in that request must be individually approved or declined, and may then automatically be added to
	 Arctos loans.
	 <p>
	 Declining requests here will simply not provide them a link to request specific items via Arctos. You may still grant
	 their loan request in other ways.
	 </p>
	 <p>
	 After you submit this form, 
	 you'll be requested to edit and send an email message to the requestor. Include any instructions ("contact me by ....";
	 "submit a request on letterhead...", etc.) that you wish them to follow in that form.
	 </p>
	 <table border>
	 <tr>
	 	<td>Collection</td>
		<td>Approve Requests</td>
		<td>Decline Requests</td>
	 </tr>
	
	 <form name="app" method="post" action="manage_user_loan_request.cfm">
	 	<input type="hidden" name="action" value="goGiveThemAuth" />
		<input type="hidden" name="req_name" value="#req_name#" />
		<input type="hidden" name="email" value="#userdata.EMAIL#" />
		<input type="hidden" name="adminemail" value="#colls.address#" />
		<input type="hidden" name="adminName" value="#colls.agent_name#" />
		<cfloop query="colls">
			<tr>
				<td>#institution_acronym# #collection_cde#</td>
				<td>
					<input type="radio" name="appvFor_#collection_id#" value="1"
					<cfif listcontains(#prevAuth.loan_request_coll_id#,#collection_id#)> checked </cfif> />
				</td>
				<td><input type="radio" name="appvFor_#collection_id#" value="0" 
				<cfif not listcontains(#prevAuth.loan_request_coll_id#,#collection_id#)> checked </cfif> /></td>
			 </tr>
		</cfloop>
		<tr>
			<td colspan="3">
				<input type="submit" />
			</td>
		</tr>
		
	 </form>
	 </table>
</cfoutput>
</cfif>
<!------------------------------------------>

<cfif #action# is "manageSpecs">
<cfoutput>
	<cfquery name="getLoanId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select  
			USER_LOAN_ID,
			 PROJECT_TITLE,
			 PROJECT_DESCRIPTION   
		from
			cf_user_loan,
			cf_users
		where
			IS_ACTIVE=1 and
			cf_user_loan.user_id=cf_users.user_id and
			username='#req_name#'
	</cfquery>
		USER_LOAN_ID,
			 PROJECT_TITLE,
			 PROJECT_DESCRIPTION   
		from
			cf_user_loan,
			cf_users
		where
			IS_ACTIVE=1 and
			cf_user_loan.user_id=cf_users.user_id and
			username='#req_name#'
	<cfif #getLoanId.recordcount# is 1>
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
					concatencumbrances(cataloged_item.collection_object_id) encumbrances,
					coll_obj_disposition,
					approval_status,
					admin_remark,
					 REMARK,
					 USE_TYPE
				FROM
					collection,
					cataloged_item,
					identification,
					collecting_event,
					locality,
					geog_auth_rec,
					specimen_part,
					cf_loan_item,
					coll_object
				WHERE
					cataloged_item.collection_id=collection.collection_id AND
					cataloged_item.collection_object_id = identification.collection_object_id AND
					cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
					collecting_event.locality_id = locality.locality_id AND
					locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
					specimen_part.collection_object_id = cf_loan_item.collection_object_id AND
					specimen_part.collection_object_id = coll_object.collection_object_id AND
					cf_loan_item.USER_LOAN_ID = #getLoanId.USER_LOAN_ID# AND
					accepted_id_fg=1
			</cfquery>
			Active Loan for #req_name#:
			<hr />
			Project Title:
			<br />#getLoanId.project_title#
			<hr />Project Description:
			<br />#getLoanId.project_description#
			<hr />
				<a href="manage_user_loan_request.cfm?action=makeRealLoan&loan_id=#getLoanId.USER_LOAN_ID#">
					Add these specimens to a Museum Loan</a>
				<br /><a href="manage_user_loan_request.cfm?action=approveAllItems&user_loan_id=#getLoanId.USER_LOAN_ID#&req_name=#req_name#">Approve All</a>
			<hr />Specimens: <span style="font-size:12px">Data are saved automatically when you change something. Leave the field to force save. Column header should be briefly red then green when you save something.</span>
			<table border>
				<tr>
					<td>Cat Num</td>
					<td>Scientific Name</td>
					<td>Part</td>
					<td>Date</td>
					<td>Locality</td>
					<td>Geography</td>
					<td>Disposition</td>
					<td>Encumbrances</td>
					<td>Usr Remark</td>
					<td>Use Type</td>
					<td>
						<div id="statusDiv">
							Approve/Reject
						</div>	
					</td>
					<td>
						<div id="remarkDiv">
							Admin Remark
						</div>	
					</td>
				</tr>
				
				<cfloop query="specs">
				<form name="specs#partID#" method="post" action="user_loan_request.cfm">
					<input type="hidden" name="action" />
					<input type="hidden" name="partID" value="#partID#" id="partID#partID#" />
					<input type="hidden" name="collection_object_id" value="#collection_object_id#" />
					<input type="hidden" name="user_loan_id#partID#" id="user_loan_id#partID#" value="#getLoanId.USER_LOAN_ID#" />
					
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
					<td>#coll_obj_disposition#</td>
					<td>#encumbrances#</td>
					<td>#remark#</td>
					<td>#USE_TYPE#</td>
					<td>
						<select name="approval_status" size="1" onchange="changeStatus('#partID#',this.value)">
							<option <cfif #approval_status# is ""> selected </cfif>value=""></option>
							<option <cfif #approval_status# is "approve"> selected </cfif> value="approve">approve</option>
							<option <cfif #approval_status# is "reject"> selected </cfif> value="reject">reject</option>
							<option <cfif #approval_status# is "in loan"> selected </cfif> value="in loan">in loan</option>
						</select>	#encumbrances#
					</td>
					<td>
						<input type="text" name="admin_remark" value="#admin_remark#" onchange="changeRemark('#partID#',this.value)" />
					</td>					
				</tr>
				</form>
				</cfloop>				
			</table>
		<cfelse>
			no active loans found
		</cfif>
</cfoutput>
</cfif>


<!------------------------------------------>
<cfif #action# is "goGiveThemAuth">
	<cfoutput>
	<cfset whatToDo=querynew("collid,yesno")>
		<cfset rownum=1>
		<cfloop list="#form.fieldnames#" index="i">
			<cfif #i# contains "appvFor">
				<cfset yesNo = #evaluate(i)#>
				<cfset instid = #replacenocase(i,"appvFor_","","all")#>
				<!---
				<cfif #yesNo# is 1>
					approve
				<cfelse>
					decline
				</cfif>
				--->
				<cfset newRow = QueryAddRow(whatToDo, 1)>
				<cfset temp = QuerySetCell(whatToDo, "collid", "#instid#", #rownum#)>
				<cfset temp = QuerySetCell(whatToDo, "yesno", "#yesNo#", #rownum#)>
				<cfset rownum=#rownum#+1>
			</cfif>
		</cfloop>
		You have chosen to take the following actions for user #req_name#:
		<table border>
			<tr>
				<td>Collection</td>
				<td>Decision</td>
			</tr>
		<cfset addToLoanAppList = "">
		<cfset remFromLoanAppList = "">
		<cfloop query="whatToDo">
			<cfquery name="coll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select collection_cde,institution_acronym
				from collection
				where collection_id =#collid#
			</cfquery>
			<tr>
				<td>#coll.institution_acronym# #coll.collection_cde#</td>
				<td>
					<cfif #yesno# is 0>
						Decline
						<cfif len(#remFromLoanAppList#) is 0>
							<cfset remFromLoanAppList = "#collid#">
						<cfelse>
							<cfset remFromLoanAppList = "#remFromLoanAppList#,#collid#">
						</cfif>	
					<cfelseif #yesno# is 1>
						<cfif len(#addToLoanAppList#) is 0>
							<cfset addToLoanAppList = "#collid#">
						<cfelse>
							<cfset addToLoanAppList = "#addToLoanAppList#,#collid#">
						</cfif>					
						Approve
					<cfelse>
						ERROR! Please use your back button and try again, or submit a bug report.
					</cfif>
				</td>
			</tr>
		</cfloop>
		</table>
		The following email will be automatically sent to #email#. You MUST edit it before submission.
		<br />You (#adminemail#) will be copied.
		<form name="email" method="post" action="manage_user_loan_request.cfm">
			<input type="hidden" name="req_name" value="#req_name#" />
			<input type="hidden" name="email" value="#email#" />
			<input type="hidden" name="adminemail" value="#adminemail#" />
			<input type="hidden" name="adminName" value="#adminName#" />
			<input type="hidden" name="action" value="sendEmailFinally" />
			<input type="hidden" name="remFromLoanAppList" value="#remFromLoanAppList#" />
			<input type="hidden" name="addToLoanAppList" value="#addToLoanAppList#" />
			
			<cfset thisMsg = "Dear #req_name#,<p>This message is in response to your Loan Authorization Request filed from Arctos, #Application.ServerRootUrl#. A loan Contact Agent has reviewed your User Loan Request.">
			<cfquery name="appCol" dbtype="query">
				select collid from whatToDo where yesno=1
			</cfquery>
			<cfif len(valuelist(appcol.collid)) gt 0>
				<cfquery name="coll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select collection
					from collection
					where collection_id in (#valuelist(appcol.collid)#)
				</cfquery>
				<cfset thisMsg = "#thisMsg#<p></p>You have been approved to request loans from the following collection(s):<p>">
				<cfloop query="coll">
					<cfset thisMsg = "#thisMsg##coll.collection#<br>">
				</cfloop>
			</cfif>
			<cfset thisMsg = "#thisMsg#<p>If you have been approved to request items online, you must fill out the forms at #Application.ServerRootUrl#/user_loan_request.cfm after logging into Arctos.<br>Note that this only allows you to request materials online. All actual loans are made according to the individial collection's policies. Materials may not be accurately represented online, and not all material in Arctos is available for loan. <p>This email was sent courtesy of #adminName# (email: #adminemail#). Please contact them directly or file a bug report if you have any questions or concerns.">
			<cfset dispTxt = replace(thisMsg,"<br>",#chr(10)#,"all")>
			<cfset dispTxt = replace(dispTxt,"<p>","#Chr(10)##Chr(13)#","all")>
			<textarea name="thisMsg" rows="20" cols="100">#dispTxt#</textarea>
			<input type="submit" value="I have reviewed the above and approve sending this email message" />
		</form>
		
	</cfoutput>
</cfif>
<cfif #action# is "sendEmailFinally">
	<cfoutput>
	<cfquery name="curr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select loan_request_coll_id from cf_users,cf_user_loan
		where username='req_name'
	</cfquery>
	<cfset currVal = #curr.loan_request_coll_id#>
	<cfif len(#currVal#) gt 0>
	<cfloop list="#remFromLoanAppList#" index="i">
		<cfset currVal = replace(i,"","all")>
	</cfloop>
	</cfif>
	<cfloop list="#addToLoanAppList#" index="i">
		<cfif len(#currVal#) is 0>
			<cfset currVal = "#i#">
		<cfelse>
			<cfset currVal = "#currVal#,#i#">
		</cfif>
	</cfloop>
	
	<cfquery name="setAppvl" datasource="#Application.uam_dbo#">
		update cf_users set loan_request_coll_id = '#currVal#' where
		username='#req_name#'
	</cfquery>
	
	<cfset thisMsg = replace(thisMsg,#chr(10)#,"<br>","all")>
	<cfset thisMsg = replace(thisMsg,"#Chr(10)##Chr(13)#","<p>","all")>
		<cfmail to="#email#" cc="#adminemail#" subject="Reply: Arctos Loan Request Authorization" from="LoanRequestReply@arctos.database.museum" type="html">
			#thisMsg#
		</cfmail>
		It's all done.
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">