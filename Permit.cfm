<cfinclude template = "includes/_header.cfm">
<script>
	$(document).ready(function() {
		$(".reqdClr:visible").each(function(e){
		    $(this).prop('required',true);
		});
		$("input[type='date'], input[type='datetime']" ).datepicker();
	});
</script>
<!--- no security --->
<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select permit_type from ctpermit_type order by permit_type
</cfquery>
<cfquery name="ctPermitRegulation" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select permit_regulation from ctpermit_regulation order by permit_regulation
</cfquery>
<cfquery name="ctPermitAgentRole" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select permit_agent_role from ctpermit_agent_role order by permit_agent_role
</cfquery>
<cfif #action# is "nothing">
	<cfset title="permit search">

<cfoutput>

<p>
	<a href="Permit.cfm?action=newPermit">create permit</a>
</p>

<p>
	Find Permits
</p>
<form name="findPermit" action="Permit.cfm" method="post">
	<input type="hidden" name="Action" value="search">


	<label for="permit_num">Permit Identifier/Number</label>
	<input type="text" name="permit_num">

	<label for="IssuedByAgent">Issued By</label>
	<input type="text" name="IssuedByAgent">

	<label for="IssuedToAgent">Issued To</label>
	<input type="text" name="IssuedToAgent">


	<label for="ContactAgent">Contact Agent</label>
	<input type="text" name="ContactAgent">

	<label for="IssuedAfter">Issued On/After Date</label>
	<input type="datetime" name="IssuedAfter">

	<label for="IssuedBefore">Issued On/Before Date</label>
	<input type="datetime" name="IssuedBefore">


	<label for="ExpiresAfter">Expires On/After Date</label>
	<input type="datetime" name="ExpiresAfter">


	<label for="ExpiresBefore">Expires On/Before Date</label>
	<input type="datetime" name="ExpiresBefore">

	<label for="permit_type">Permit Type</label>
	<select name="permit_type" size="1">
		<option value=""></option>
		<cfloop query="ctPermitType">
			<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
		</cfloop>
	</select>

	<label for="permit_regulation">Permit Regulation</label>
	<select name="permit_regulation" size="1">
		<option value=""></option>
		<cfloop query="ctPermitRegulation">
			<option value = "#ctPermitRegulation.permit_regulation#">#ctPermitRegulation.permit_regulation#</option>
		</cfloop>
	</select>


	<label for="permit_remarks">Remarks</label>
	<input type="text" name="permit_remarks">
	<p>
		<input type="submit" value="Search" class="schBtn">
	</p>
	<p>
		<input type="reset" value="Clear Form" class="clrBtn">
	</p>
</form>
</cfoutput>
</cfif>
<!--------------------------------------------------------------------------->
<cfif action is "search">
<cfset title="permit search results">
<style>
	.noExpDate {border: 8px solid orange;}
	.expired {border: 4px solid gray;}
	.sixmos {border: 4px solid #f4cb42;}
	.onemo {border: 4px solid red;}
	.eventually {border: 4px solid green;}
</style>
<cfoutput>
<cfset sql = "select
	permit.permit_id,
	getPreferredAgentName(permit_agent.agent_id) permit_agent,
	permit_agent.agent_role,
	permit.issued_Date,
	permit.exp_Date,
	permit.permit_Num,
	permit.permit_remarks,
	permit_type.permit_type,
	permit_type.permit_regulation
from
	permit,
	permit_agent,
	permit_type
where
	permit.permit_id = permit_agent.permit_id (+) and
	permit.permit_id = permit_type.permit_id (+) ">



<cfif len(IssuedByAgent) gt 0>
	<cfset sql = "#sql# AND permit.permit_id in (
		select permit_agent.permit_id from
		permit_agent,agent_name
		where
		permit_agent.agent_id=agent_name.agent_id and
		permit_agent.agent_role='issued by' and
		upper(agent_name.agent_name) like '%#ucase(IssuedByAgent)#%')">


</cfif>

<cfif len(IssuedToAgent) gt 0>
	<cfset sql = "#sql# AND permit.permit_id in (
		select permit_agent.permit_id from
		permit_agent,agent_name
		where
		permit_agent.agent_id=agent_name.agent_id and
		permit_agent.agent_role='issued to' and
		upper(agent_name.agent_name) like '%#ucase(IssuedToAgent)#%')">
</cfif>


<cfif len(ContactAgent) gt 0>
	<cfset sql = "#sql# AND permit.permit_id in (
		select permit_agent.permit_id from
		permit_agent,agent_name
		where
		permit_agent.agent_id=agent_name.agent_id and
		permit_agent.agent_role='contact' and
		upper(agent_name.agent_name) like '%#ucase(ContactAgent)#%')">
</cfif>

<cfif len(IssuedAfter) gt 0>
	<cfset sql = "#sql# AND issued_date >= '#issued_date#'">
</cfif>

<cfif len(IssuedBefore) gt 0>
	<cfset sql = "#sql# AND issued_date <= '#IssuedBefore#'">
</cfif>


<cfif len(ExpiresAfter) gt 0>
	<cfset sql = "#sql# AND exp_date >= '#ExpiresAfter#'">
</cfif>


<cfif len(ExpiresBefore) gt 0>
	<cfset sql = "#sql# AND exp_date <= '#ExpiresBefore#'">
</cfif>


<cfif len(permit_num) gt 0>
	<cfset sql = "#sql# AND upper(permit_Num) like '%#ucase(permit_Num)#%'">
</cfif>


<cfif len(permit_type) gt 0>
	<cfset sql = "#sql# AND permit.permit_id in (select permit_id from permit_type where permit_type = '#permit_type#')">
</cfif>
<cfif len(permit_regulation) gt 0>
	<cfset sql = "#sql# AND permit.permit_id in (select permit_id from permit_type where permit_regulation = '#permit_regulation#')">
</cfif>


<cfif len(permit_remarks) gt 0>
	<cfset sql = "#sql# AND upper(permit_remarks) like '%#ucase(permit_remarks)#%'">
</cfif>

<cfif isdefined("permit_id") and len(permit_id) gt 0>
	<cfset sql = "#sql# AND permit.permit_id = #permit_id#">
</cfif>


<cfquery name="matchPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	#preservesinglequotes(sql)#
</cfquery>


<cfquery name="base" dbtype="query">
	select
		permit_id,
		issued_Date,
		exp_Date,
		permit_Num,
		permit_remarks
	from
		matchPermit
	group by
		permit_id,
		issued_Date,
		exp_Date,
		permit_Num,
		permit_remarks
</cfquery>
<script src="/includes/sorttable.js"></script>

<cfset i=1>
<table border id="t" class="sortable">
		<tr>
			<th>Permit Number</th>
			<th>Permit Type/Regulation</th>
			<th>Issued To</th>
			<th>Issued By</th>
			<th>Contact</th>
			<th>Issued Date</th>
			<th>Expires Date</th>
			<th>Expires Days</th>
			<th>Remarks</th>
			<th>ctl</th>
		</tr>
		<cfloop query="base">
			<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<td>#permit_Num#</td>

				<td>
					<cfquery name="ptr" dbtype="query">
						select permit_type,permit_regulation from matchPermit where permit_id=#permit_id# group by permit_type,permit_regulation
					</cfquery>
					<cfloop query="ptr">
						<div>
							#permit_type# - #permit_regulation#
						</div>
					</cfloop>

				</td>
				<td>
					<cfquery name="it" dbtype="query">
						select permit_agent from matchPermit where agent_role='issued to' and permit_id=#permit_id# group by permit_agent
					</cfquery>
					#valuelist(it.permit_agent)#
				</td>
				<td>
					<cfquery name="ib" dbtype="query">
						select permit_agent from matchPermit where agent_role='issued by' and permit_id=#permit_id# group by permit_agent
					</cfquery>
					#valuelist(ib.permit_agent)#
				</td>
				<td>
					<cfquery name="ctc" dbtype="query">
						select permit_agent from matchPermit where agent_role='contact' and permit_id=#permit_id# group by permit_agent
					</cfquery>
					#valuelist(ctc.permit_agent)#
				</td>
				<td>#dateformat(issued_Date,"yyyy-mm-dd")#</td>
				<td>#dateformat(exp_Date,"yyyy-mm-dd")# </td>
				<cfset dte="">
				<cfif len(exp_Date) gt 0>
					<cfset dte=datediff("d",now(),exp_Date)>
				</cfif>
				<cfif len(dte) is 0>
					<cfset dtec="noExpDate">
				<cfelseif dte lt 0>
					<cfset dtec="expired">
				<cfelseif dte gt 0 and dte lte 30>
					<cfset dtec="onemo">
				<cfelseif dte gt 30 and dte lte 180>
					<cfset dtec="sixmos">
				<cfelse>
					<cfset dtec="eventually">
				</cfif>


				<td>
					<div class="#dtec#">#dte#</div>
				</td>
				<td>#permit_remarks#</td>
				<td>
					<div>
						<a href="Permit.cfm?permit_id=#permit_id#&action=editPermit">Edit&nbsp;Permit</a>
					</div>
					<div>
						<a href="editAccn.cfm?permit_id=#permit_id#&action=findAccessions">Accession&nbsp;List</a>
					</div>
					<div>
						<a href="Loan.cfm?permit_id=#permit_id#&action=listLoans">Loan&nbsp;List</a>
					</div>
					<div>
						<a href="borrow.cfm?permit_id=#permit_id#&action=findEm">Borrow&nbsp;List</a>
					</div>
				</td>
			</tr>
			<cfset i=i+1>
		</cfloop>
	</table>
	</cfoutput>

</cfif>
<!--------------------------------------------------------------------------->
<!--------------------------------------------------------------------------->
<cfif action is "newPermit">
	<cfset title="create permit">

	<h2>Create Permit</h2>
	<cfoutput>
		<form name="newPermit" action="Permit.cfm" method="post">
			<input type="hidden" name="action" value="createPermit">
				<p>The Basics</p>

				<label for="permit_Num">Permit Identifier/Number</label>
			  	<input type="text" name="permit_num" id="permit_num" class="reqdClr" required >

				<label for="issued_Date">Issued Date</label>
				<input type="datetime" id="issued_date" name="issued_date" >

			  	<label for="exp_date">Expiration Date</label>
			  	<input type="datetime" id="exp_date" name="exp_date" >

				<label for="permit_remarks">Remarks</label>
			  	<textarea name="permit_remarks" class="largetextarea"></textarea>

				<div style="font-size:small;padding:1em;margin:1em;">
					Create and edit to add more types and regulations.
					<a target="_blank" href="/info/ctDocumentation.cfm?table=CTPERMIT_TYPE">CTPERMIT_TYPE</a>
				</div>

				<label for="permit_type">Permit Type</label>
				<select name="permit_type" id="permit_type" class="reqdClr" required size="1">
					<option value=""></option>
					<cfloop query="ctPermitType">
						<option value="#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
					</cfloop>
				</select>

				<div style="font-size:small;padding:1em;margin:1em;">
					Save and edit to add more Agents
					Code table is
					<a target="_blank" href="/info/ctDocumentation.cfm?table=CTPERMIT_AGENT_ROLE">CTPERMIT_AGENT_ROLE</a>
				</div>
				<label for="issued_by">Issued By</label>
				<input type="hidden" id="issued_by_agent_id" name="issued_by_agent_id">
				<input
					type="text"
					name="issued_by"
					id="issued_by"
					class="minput reqdClr"
					onchange="pickAgentModal('issued_by_agent_id',this.id,this.value); return false;"
					onKeyPress="return noenter(event);"
					placeholder="Issued By Agent"
					required>
				<label for="issued_to">Issued To</label>
				<input type="hidden" id="issued_to_agent_id" name="issued_to_agent_id">
				<input
					type="text"
					name="issued_to"
					id="issued_to"
					class="minput reqdClr"
					onchange="pickAgentModal('issued_to_agent_id',this.id,this.value); return false;"
					onKeyPress="return noenter(event);"
					placeholder="Issued To Agent"
					required>
				<p>
					<input type="submit" value="Create Permit" class="savBtn">
				</p>

			</form>

	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------->
<cfif action is "editPermit">

	<cfset title="edit permit">
<cfoutput>
<cfif not isdefined("permit_id") OR len(permit_id) is 0>
	Something bad happened. You didn't pass this form a permit_id. Go back and try again.<cfabort>
</cfif>
<cfquery name="permitInfo" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		permit.permit_id,
		issued_Date,
		exp_Date,
		permit_Num,
		permit_remarks
	from
		permit
	where
		permit_id=#permit_id#
</cfquery>
<table border width="100%">
	<tr>
		<td width="50%"  valign="top">
			<form name="editPermit" action="Permit.cfm" method="post">
				<input type="hidden" name="action" value="saveChanges">
				<input type="hidden" name="permit_id" value="#permit_id#">

				<p>The Basics</p>

				<label for="permit_Num">Permit Identifier/Number</label>
			  	<input type="text" name="permit_num" id="permit_num" class="reqdClr" required value="#permitInfo.permit_Num#">

				<label for="issued_Date">Issued Date</label>
				<input type="datetime" id="issued_date" name="issued_date" value="#dateformat(permitInfo.issued_Date,"yyyy-mm-dd")#">

			  	<label for="exp_date">Expiration Date</label>
			  	<input type="datetime" id="exp_date" name="exp_date" value="#dateformat(permitInfo.exp_Date,"yyyy-mm-dd")#">

				<label for="permit_remarks">Remarks</label>
			  	<textarea name="permit_remarks" class="largetextarea">#permitInfo.permit_remarks#</textarea>

				<p>
					Type & Regulation
					<div style="font-size:small;padding:1em;margin:1em;">
						Choose TYPE and/or REGULATION, paired or not. Remove both to delete.
						Code tables are
						<a target="_blank" href="/info/ctDocumentation.cfm?table=CTPERMIT_TYPE">CTPERMIT_TYPE</a> and
						<a target="_blank" href="/info/ctDocumentation.cfm?table=CTPERMIT_REGULATION">CTPERMIT_REGULATION</a>
					</div>
				</p>

				<cfquery name="permitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select * from permit_type where permit_id=#permit_id#
				</cfquery>
				<table border>
					<tr>
						<th>Status</th>
						<th>Permit Type</th>
						<th>Regulation</th>
					</tr>
					<cfloop query="permitType">
						<tr>
							<td>Existing</td>
							<td>
								<select name="permit_type_#permit_type_id#" size="1">
									<option value=""></option>
									<cfloop query="ctPermitType">
										<option <cfif #ctPermitType.permit_type# is "#permitType.permit_type#"> selected </cfif>value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
									</cfloop>
								</select>
							</td>
							<td>

								<select name="permit_regulation_#permit_type_id#" size="1">
									<option value=""></option>
									<cfloop query="ctPermitRegulation">
										<option <cfif #ctPermitRegulation.permit_regulation# is "#permitType.permit_regulation#"> selected </cfif>
										value = "#ctPermitRegulation.permit_regulation#">#ctPermitRegulation.permit_regulation#</option>
									</cfloop>
								</select>
							</td>
						</tr>
					</cfloop>
					<cfloop from="1" to="5" index="i">
						<tr class="newRec">
							<td>New (save to add more)</td>
							<td>
								<select name="permit_type_new#i#" size="1">
									<option value=""></option>
									<cfloop query="ctPermitType">
										<option value="#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
									</cfloop>
								</select>
							</td>
							<td>

								<select name="permit_regulation_new#i#" size="1">
									<option value=""></option>
									<cfloop query="ctPermitRegulation">
										<option value = "#ctPermitRegulation.permit_regulation#">#ctPermitRegulation.permit_regulation#</option>
									</cfloop>
								</select>
							</td>
						</tr>

					</cfloop>
				</table>

				<p>
					Agents
					<div style="font-size:small;padding:1em;margin:1em;">
						Provide both an agent and role to create. Choose role DELETE to remove.
						Code table is
						<a target="_blank" href="/info/ctDocumentation.cfm?table=CTPERMIT_AGENT_ROLE">CTPERMIT_AGENT_ROLE</a>
					</div>
				</p>

				<cfquery name="permitAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select permit_agent_id,	permit_id,	agent_id,	agent_role, getPreferredAgentName(agent_id) name from permit_agent where permit_id=#permit_id#
				</cfquery>
				<table border>
					<tr>
						<th>Status</th>
						<th>Agent</th>
						<th>Role</th>
					</tr>
					<cfloop query="permitAgent">
						<tr>
							<td>Existing</td>
							<td>
								<input type="hidden" id="permit_agent_id_#permit_agent_id#" name="permit_agent_id_#permit_agent_id#" value="#agent_id#">
								<input
									type="text"
									name="permit_agent_name_#permit_agent_id#"
									id="permit_agent_name_#permit_agent_id#"
									value="#name#"
									class="minput"
									onchange="pickAgentModal('permit_agent_id_#permit_agent_id#',this.id,this.value); return false;"
									onKeyPress="return noenter(event);"
									placeholder="agent">
							</td>
							<td>
								<select name="permit_agent_role_#permit_agent_id#" size="1">
									<option value="DELETE">DELETE</option>
									<cfloop query="ctPermitAgentRole">
										<option <cfif permitAgent.agent_role is ctPermitAgentRole.permit_agent_role> selected="selected" </cfif> value = "#ctPermitAgentRole.permit_agent_role#">#ctPermitAgentRole.permit_agent_role#</option>
									</cfloop>
								</select>
							</td>
						</tr>
					</cfloop>
					<cfloop from="1" to="5" index="i">
						<tr class="newRec">
							<td>New</td>
							<td>
								<input type="hidden" id="permit_agent_id_new#i#" name="permit_agent_id_new#i#">
								<input
									type="text"
									name="permit_agent_name_new#i#"
									id="permit_agent_name_new#i#"
									class="minput"
									onchange="pickAgentModal('permit_agent_id_new#i#',this.id,this.value); return false;"
									onKeyPress="return noenter(event);"
									placeholder="agent">
							</td>
							<td>
								<select name="permit_agent_role_new#i#" size="1">
									<option value=""></option>
									<cfloop query="ctPermitAgentRole">
										<option value = "#ctPermitAgentRole.permit_agent_role#">#ctPermitAgentRole.permit_agent_role#</option>
									</cfloop>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>

				<p>
					<input type="submit" value="Save changes" class="savBtn">
				</p>
				<p>
					<input type="button" value="Delete" class="delBtn"
				   				onCLick="document.location='Permit.cfm?permit_id=#permit_id#&action=deletePermit';">
				</p>

			</form>
		</td>
		<script>
			jQuery(document).ready(function(){
				$("##issued_date").datepicker();
				$("##exp_date").datepicker();
	            $("##mediaUpClickThis").click(function(){
				    addMedia('permit_id','#permit_id#');
				});
				getMedia('permit','#permit_id#','pMedia','2','1');
			});
		</script>
		<td width="50%" valign="top">
			<h3>Permit Media</h3>
			<cfif listcontainsnocase(session.roles, "manage_media")>
				<a class="likeLink" id="mediaUpClickThis">Attach/Upload Media</a>
			</cfif>
			<div id="pMedia"></div>
		</td>
	</tr>
</table>
</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "saveChanges">
<cfoutput>
	<cftransaction>

		<cfdump var=#form#>
		<cfquery name="updatePermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			UPDATE
				permit
			SET
				ISSUED_DATE = '#ISSUED_DATE#',
				EXP_DATE = '#EXP_DATE#',
				PERMIT_NUM = '#PERMIT_NUM#',
				PERMIT_REMARKS = '#PERMIT_REMARKS#'
			where
				permit_id = #permit_id#
		</cfquery>
		<CFLOOP index="thisfield" list="#FORM.FIELDNAMES#">
			<cfif left(thisfield,12) is 'permit_type_'>
				<br>permit type....
				<cfset thisPermitTypeId=listlast(thisField,"_")>
				<br>thisPermitTypeId: #thisPermitTypeId#
				<cfset thisPermitType=evaluate("permit_type_" & thisPermitTypeId)>
				<br>thisPermitType: #thisPermitType#
				<cfset thisPermitReg=evaluate("permit_regulation_" & thisPermitTypeId)>
				<br>thisPermitReg: #thisPermitReg#
				<cfif left(thisPermitTypeId,3) is "new" and (len(thisPermitType) gt 0 or len(thisPermitReg) gt 0)>
					<cfquery name="ipt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into permit_type (
							permit_id,
							permit_type,
							permit_regulation
						) values (
							#permit_id#,
							'#thisPermitType#',
							'#thisPermitReg#'
						)
					</cfquery>
				<cfelseif left(thisPermitTypeId,3) is not "new" and (len(thisPermitType) gt 0 or len(thisPermitReg) gt 0)>
					<cfquery name="upt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						update permit_type set
							permit_type='#thisPermitType#',
							permit_regulation='#thisPermitReg#'
						where
							permit_type_id=#thisPermitTypeId#
					</cfquery>
				<cfelseif left(thisPermitTypeId,3) is not "new" and len(thisPermitType) is 0 and len(thisPermitReg) is 0>
					<cfquery name="dpt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						delete from permit_type
						where
							permit_type_id=#thisPermitTypeId#
					</cfquery>
				</cfif>
			</cfif>
			<cfif left(thisfield,16) is 'permit_agent_id_'>
				<br>agent....
				<cfset thisPermitAgentId=listlast(thisField,"_")>
				<cfset thisPermitAgent=evaluate("permit_agent_id_" & thisPermitAgentId)>
				<cfset thisPermitAgentRole=evaluate("permit_agent_role_" & thisPermitAgentId)>

				<br>thisPermitAgentId: #thisPermitAgentId#
				<br>thisPermitAgent: #thisPermitAgent#
				<br>thisPermitAgentRole: #thisPermitAgentRole#
				<cfif left(thisPermitAgentId,3) is "new" and len(thisPermitAgent) gt 0 and len(thisPermitAgentRole) gt 0>
					<br>
					<cfquery name="ipag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						insert into permit_agent (
							permit_id,
							agent_id,
							agent_role
						) values (
							#permit_id#,
							#thisPermitAgent#,
							'#thisPermitAgentRole#'
						)
					</cfquery>
				<cfelseif left(thisPermitAgentId,3) is not "new">
					<cfif thisPermitAgentRole is "DELETE">
						<cfquery name="dpag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							delete from permit_agent where permit_agent_id=#thisPermitAgentId#
						</cfquery>
					<cfelse>
						<cfquery name="dpag" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							update permit_agent set agent_id=#thisPermitAgent#,agent_role='#thisPermitAgentRole#' where  permit_agent_id=#thisPermitAgentId#
						</cfquery>
					</cfif>

				</cfif>

			</cfif>


		</CFLOOP>
	</cftransaction>

	<cflocation url="Permit.cfm?Action=editPermit&permit_id=#permit_id#" addtoken="false">

	<!----
		<cfloop query="permitType">
						<tr>
							<td>Existing</td>
							<td>
								<select name="permit_type_#permit_type_id#" size="1">
									<option value=""></option>
									<cfloop query="ctPermitType">
										<option <cfif #ctPermitType.permit_type# is "#permitType.permit_type#"> selected </cfif>value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
									</cfloop>
								</select>
							</td>
							<td>

								<select name="permit_regulation_#permit_type_id#" size="1">
									<option value=""></option>
									<cfloop query="ctPermitRegulation">
										<option <cfif #ctPermitRegulation.permit_regulation# is "#permitType.permit_regulation#"> selected </cfif>
										value = "#ctPermitRegulation.permit_regulation#">#ctPermitRegulation.permit_regulation#</option>
									</cfloop>
								</select>
							</td>
						</tr>
					</cfloop>
					<cfloop from="1" to="5" index="i">
						<tr>
							<td>New (save to add more)</td>
							<td>
								<select name="permit_type_new_#i#" size="1">
									<option value=""></option>
									<cfloop query="ctPermitType">
										<option value="#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
									</cfloop>
								</select>
							</td>
							<td>

								<select name="permit_regulation_new_#i#" size="1">
									<option value=""></option>
									<cfloop query="ctPermitRegulation">
										<option value = "#ctPermitRegulation.permit_regulation#">#ctPermitRegulation.permit_regulation#</option>
									</cfloop>
								</select>
							</td>




    </cfif>
	 <cfif len(#contact_agent_id#) gt 0>
	 	,contact_agent_id = #contact_agent_id#
	<cfelse>
		,contact_agent_id = null
	 </cfif>





---->
</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "createPermit">
<cfoutput>
<cfquery name="nextPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select sq_permit_id.nextval nextPermit from dual
</cfquery>
	<cftransaction>

		<cfquery name="newPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO permit (
		 		PERMIT_ID,
		 		ISSUED_DATE,
				EXP_DATE,
				PERMIT_NUM,
				PERMIT_REMARKS
			) VALUES (
				#nextPermit.nextPermit#,
				<cfif len(ISSUED_DATE) gt 0>
					'#dateformat(issued_date,"yyyy-mm-dd")#',
				<cfelse>
					NULL,
				</cfif>
				<cfif len(EXP_DATE) gt 0>
					'#dateformat(EXP_DATE,"yyyy-mm-dd")#',
				<cfelse>
					NULL,
				</cfif>
				'#PERMIT_NUM#',
				'#escapeQuotes(permit_remarks)#'
			)
		</cfquery>
		<cfquery name="newPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into permit_type (
				permit_type_id,
				permit_id,
				permit_type
			) values (
				sq_permit_type_id.nextval,
				#nextPermit.nextPermit#,
				'#permit_type#'
			)
		</cfquery>
		<cfquery name="newPermitBy" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into permit_agent (
				permit_agent_id,
				permit_id,
				agent_id,
				agent_role
			) values (
				sq_permit_agent_id.nextval,
				#nextPermit.nextPermit#,
				#issued_by_agent_id#,
				'issued by'
			)
		</cfquery>
		<cfquery name="newPermitTo" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into permit_agent (
				permit_agent_id,
				permit_id,
				agent_id,
				agent_role
			) values (
				sq_permit_agent_id.nextval,
				#nextPermit.nextPermit#,
				#issued_to_agent_id#,
				'issued to'
			)
		</cfquery>
	</cftransaction>
	<cflocation url="Permit.cfm?Action=editPermit&permit_id=#nextPermit.nextPermit#" addtoken="false">
  </cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "deletePermit">
<cfoutput>
	<cftransaction>
		<cfquery name="deletePermitA" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from permit_agent WHERE permit_id = #permit_id#
		</cfquery>
		<cfquery name="deletePermitt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from permit_type WHERE permit_id = #permit_id#
		</cfquery>
		<cfquery name="deletePermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			DELETE FROM permit WHERE permit_id = #permit_id#
		</cfquery>
	</cftransaction>

	<cflocation url="Permit.cfm" addtoken="false">
  </cfoutput>
</cfif>
<cfinclude template = "includes/_footer.cfm">