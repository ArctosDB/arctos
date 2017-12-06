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
<cfoutput>

<p>
	<a href="Permit.cfm?action=newPermit">create permit</a>
</p>

<p>
	Find Permits
</p>
<form name="findPermit" action="Permit.cfm" method="post">
	<input type="hidden" name="Action" value="search">

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

	<label for="permit_num">Permit Identifier</label>
	<input type="text" name="permit_num">

	<label for="permit_remarks">Remarks</label>
	<input type="text" name="permit_remarks">


	<input type="submit" value="Search" class="schBtn">


</form>
</cfoutput>
</cfif>
<!--------------------------------------------------------------------------->
<cfif action is "search">
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
	<cfset sql = "#sql# AND permit_agent.agent_role='issued by' and permit_agent.agent_id in (select agent_id from agent_name where upper(agent_name) like '%#ucase(IssuedByAgent)#%')">
</cfif>

<cfif len(IssuedToAgent) gt 0>
	<cfset sql = "#sql# AND permit_agent.agent_role='issued to' and permit_agent.agent_id in (select agent_id from agent_name where upper(agent_name) like '%#ucase(IssuedToAgent)#%')">
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


<cfif len(permit_remarks) gt 0>
	<cfset sql = "#sql# AND upper(permit_remarks) like '%#ucase(permit_remarks)#%'">
</cfif>

<cfif isdefined("permit_id") and len(permit_id) gt 0>
	<cfset sql = "#sql# AND permit.permit_id = #permit_id#">
</cfif>


<cfquery name="matchPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	#preservesinglequotes(sql)#
</cfquery>

<cfdump var=#matchPermit#>

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
<cfdump var=#base#>
<script src="/includes/sorttable.js"></script>


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
			<tr>
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
				<td>
					<cfif len(exp_Date) gt 0>
						#datediff("d",now(),exp_Date)#
					</cfif>
				</td>
				<td>#permit_remarks#</td>
				<td>
					<div>
						<a href="Permit.cfm?permit_id=#permit_id#&action=editPermit">Edit&nbsp;Permit</a>
					</div>
					<div>
						<a href="editAccn.cfm?permit_id=#permit_id#&action=findAccessions">Accession&nbsp;List</a>
					</div>
				</td>
			</tr>
		</cfloop>
	</table>
	</cfoutput>
	<!----
	</form>
	</tr>
</cfoutput>
<a href="Permit.cfm">Search Again</a>
<cfoutput query="matchPermit" group="permit_id">
	<cfif len(#exp_Date#) gt 0>
		<cfset ExpiresInDays = #datediff("d",now(),exp_Date)#>
		<cfif ExpiresInDays lt 0>
			<cfset tabCol = "##666666">
		<cfelseif ExpiresInDays lt 10>
			<cfset tabCol = "##FF0000">
		<cfelseif ExpiresInDays lt 30>
			<cfset tabCol = "##FF8040">
		<cfelseif ExpiresInDays lt 180>
			<cfset tabCol = "##FFFF00">
		<cfelseif ExpiresInDays gte 180>
			<cfset tabCol = "##00FF00">
		<cfelse>
			<cfset tabCol = "##FFFFFF">
		</cfif>
	<cfelse>
		<!--- there's a permit with no exp date - treat this as bad! --->
		<cfset tabCol = "##FF0000">
	</cfif>
	<tr>
		<td>#permit_Num#</td>
		<td>#permit_Type#</td>
		<td>#IssuedToAgent#</td>
		<td>#IssuedByAgent#</td>
		<td>#dateformat(issued_Date,"yyyy-mm-dd")#</td>
		<td>#dateformat(renewed_Date,"yyyy-mm-dd")#</td>
		<td style="background-color:#tabCol#; ">
			#dateformat(exp_Date,"yyyy-mm-dd")#
			<cfif len(#exp_Date#) is 0>
				not given!
			<cfelseif #ExpiresInDays# lt 0>
				<font size="-2"><br>(expired)</font>
			<cfelse>
				<font size="-2"><br>(exp in #ExpiresInDays# d.)</font>
			</cfif>
		</td>
		<td>#permit_remarks#</td>
		<td>#contactAgent#</td>
		<td>
			<div>
				<a href="Permit.cfm?permit_id=#permit_id#&action=editPermit">Edit&nbsp;Permit</a>
			</div>
			<div>
				<a href="editAccn.cfm?permit_id=#permit_id#&action=findAccessions">Accession&nbsp;List</a>
			</div>
			<!----
			<div>
				<a href="Reports/permit.cfm?permit_id=#permit_id#">Permit Report</a>
			</div>
			---->
		</td>
	</tr>
</cfoutput>
</table>
---->
</cfif>
<!--------------------------------------------------------------------------->
<!--------------------------------------------------------------------------->
<cfif #Action# is "newPermit">
<font size="+1"><strong>New Permit</strong></font><br>
	<cfoutput>
	<cfform name="newPermit" action="Permit.cfm" method="post">
	<input type="hidden" name="Action" value="createPermit">
	<table>
		<tr>
			<td>Issued By</td>
			<td colspan="3">
			<input type="hidden" name="IssuedByAgentId">
			<input type="text" name="IssuedByAgent" class="reqdClr" size="50"
		 onchange="getAgent('IssuedByAgentId','IssuedByAgent','newPermit',this.value); return false;"
			  onKeyUp="return noenter();">


</td>
		</tr>
			<tr>
			<td>Issued To</td>
			<td colspan="3">
			<input type="hidden" name="IssuedToAgentId">
			<input type="text" name="IssuedToAgent" class="reqdClr" size="50"
		 onchange="getAgent('IssuedToAgentId','IssuedToAgent','newPermit',this.value); return false;"
			  onKeyUp="return noenter();">


		</td>
		</tr>
		<tr>
			<td>Contact Person</td>
			<td colspan="3">
			<input type="hidden" name="contact_agent_id">
			<input type="text" name="ContactAgent" size="50"
		 		onchange="getAgent('contact_agent_id','ContactAgent','newPermit',this.value); return false;"
			  	onKeyUp="return noenter();">


		</td>
		</tr>
		<tr>
			<td>Issued Date</td>
			<td><input type="text" name="issued_Date"></td>
			<td>Renewed Date</td>
			<td><input type="text" name="renewed_Date"></td>
		</tr>
		<tr>
			<td>Expiration Date</td>
			<td><input type="text" name="exp_Date"></td>
			<td>Permit Number</td>
			<td><input type="text" name="permit_Num"></td>
		</tr>
		<tr>
			<td>Permit Type</td>
			<td>
				<select name="permit_Type" size="1" class="reqdClr">
					<option value=""></option>
					<cfloop query="ctPermitType">
						<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
					</cfloop>
				</select>
			</td>
			<td>Remarks</td>
			<td><input type="text" name="permit_remarks"></td>
		</tr>
		<tr>
			<td colspan="4" align="center">
				<input type="submit" value="Save this permit" class="insBtn"
   					onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">

					<input type="button" value="Quit" class="qutBtn"
   					onmouseover="this.className='qutBtn btnhov'" onmouseout="this.className='qutBtn'"
					 onClick="document.location='Permit.cfm'">

			</td>
		</tr>
	</table>
</cfform>
	</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------->
<cfif action is "editPermit">
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

				<label for="permit_Num">Permit Number</label>
			  	<input type="text" name="permit_Num" value="#permitInfo.permit_Num#">

				<label for="issued_Date">Issued Date</label>
				<input type="datetime" id="issued_date" name="issued_date" value="#dateformat(permitInfo.issued_Date,"yyyy-mm-dd")#">

			  	<label for="exp_date">Expiration Date</label>
			  	<input type="datetime" id="exp_date" name="exp_date" value="#dateformat(permitInfo.exp_Date,"yyyy-mm-dd")#">

				<label for="permit_remarks">Remarks</label>
			  	<textarea name="permit_remarks" class="largetextarea">#permitInfo.permit_remarks#</textarea>

				<p>
					Type & Regulation
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
						</tr>

					</cfloop>
				</table>

				<p>
					Agents
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
								<input type="hidden" name="permit_agent_id_#permit_agent_id#" value="#agent_id#">
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
						<tr>
							<td>New</td>
							<td>
								<input type="hidden" name="permit_agent_id_new#i#">
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
				$("##renewed_date").datepicker();

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
<cfquery name="updatePermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
UPDATE permit SET
	permit_id = #permit_id#
	<cfif len(#issuedByAgentId#) gt 0>
	 	,ISSUED_BY_AGENT_ID = #issuedByAgentId#
    </cfif>
	 <cfif len(#ISSUED_DATE#) gt 0>
	 	,ISSUED_DATE = '#ISSUED_DATE#'
	 </cfif>
	 <cfif len(#IssuedToAgentId#) gt 0>
	 	,ISSUED_TO_AGENT_ID = #IssuedToAgentId#
	 </cfif>
	 <cfif len(#RENEWED_DATE#) gt 0>
	 	,RENEWED_DATE = '#RENEWED_DATE#'
	 </cfif>
	 <cfif len(#EXP_DATE#) gt 0>
	 	,EXP_DATE = '#EXP_DATE#'
	 </cfif>
	 <cfif len(#PERMIT_NUM#) gt 0>
	 	,PERMIT_NUM = '#PERMIT_NUM#'
	 </cfif>
	 <cfif len(#PERMIT_TYPE#) gt 0>
	 	,PERMIT_TYPE = '#PERMIT_TYPE#'
	 </cfif>
	<cfif len(#PERMIT_REMARKS#) gt 0>
	 	,PERMIT_REMARKS = '#PERMIT_REMARKS#'
    </cfif>
	 <cfif len(#contact_agent_id#) gt 0>
	 	,contact_agent_id = #contact_agent_id#
	<cfelse>
		,contact_agent_id = null
	 </cfif>
	 where  permit_id = #permit_id#
</cfquery>
<cflocation url="Permit.cfm?Action=editPermit&permit_id=#permit_id#" addtoken="false">
</cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "createPermit">
<cfoutput>
<cfquery name="nextPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select sq_permit_id.nextval nextPermit from dual
</cfquery>
<cfquery name="newPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
INSERT INTO permit (
	 PERMIT_ID,
	 ISSUED_BY_AGENT_ID
	 <cfif len(#ISSUED_DATE#) gt 0>
	 	,ISSUED_DATE
	 </cfif>
	 ,ISSUED_TO_AGENT_ID
	  <cfif len(#RENEWED_DATE#) gt 0>
	 	,RENEWED_DATE
	 </cfif>
	 <cfif len(#EXP_DATE#) gt 0>
	 	,EXP_DATE
	 </cfif>
	 <cfif len(#PERMIT_NUM#) gt 0>
	 	,PERMIT_NUM
	 </cfif>
	 ,PERMIT_TYPE
	<cfif len(#PERMIT_REMARKS#) gt 0>
	 	,PERMIT_REMARKS
	 </cfif>
	  <cfif len(#contact_agent_id#) gt 0>
	 	,contact_agent_id
	 </cfif>)
VALUES (
	#nextPermit.nextPermit#,
	 #IssuedByAgentId#
	 <cfif len(#ISSUED_DATE#) gt 0>
	 	,'#dateformat(ISSUED_DATE,"yyyy-mm-dd")#'
	 </cfif>
	 ,#IssuedToAgentId#
	  <cfif len(#RENEWED_DATE#) gt 0>
	 	,'#dateformat(RENEWED_DATE,"yyyy-mm-dd")#'
	 </cfif>
	 <cfif len(#EXP_DATE#) gt 0>
	 	,'#dateformat(EXP_DATE,"yyyy-mm-dd")#'
	 </cfif>
	 <cfif len(#PERMIT_NUM#) gt 0>
	 	,'#PERMIT_NUM#'
	 </cfif>
	 ,'#PERMIT_TYPE#'
	<cfif len(#PERMIT_REMARKS#) gt 0>
	 	<cfset remarks = #replace(permit_remarks,"'","''")#>
		,'#remarks#'
	 </cfif>
	   <cfif len(#contact_agent_id#) gt 0>
	 	,#contact_agent_id#
	 </cfif>)
</cfquery>
	<cflocation url="Permit.cfm?Action=editPermit&permit_id=#nextPermit.nextPermit#" addtoken="false">
  </cfoutput>
</cfif>
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "deletePermit">
<cfoutput>
<cfquery name="deletePermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
DELETE FROM permit WHERE permit_id = #permit_id#
</cfquery>

	<cflocation url="Permit.cfm" addtoken="false">
  </cfoutput>
</cfif>
<cfinclude template = "includes/_footer.cfm">