<cfinclude template="includes/_header.cfm">
<cfset title="Edit Accession">
<cfif not isdefined("project_id")>
	<cfset project_id = -1>
</cfif>
<cfquery name="cttrans_agent_role" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(trans_agent_role)  from cttrans_agent_role order by trans_agent_role
</cfquery>
<cfquery name="ctcoll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection,collection_id from collection order by collection
</cfquery>
<cfquery name="ctStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select accn_status from ctaccn_status order by accn_status
</cfquery>
<cfquery name="ctType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select accn_type from ctaccn_type order by accn_type
</cfquery>
<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from ctpermit_type order by permit_type
</cfquery>
<!-------------------------------------------------------------------->
<cfif #Action# is "edit">
	<cfoutput>
	<cfset title="Edit Accession">
		<cfquery name="accnData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT
				trans.transaction_id,
				accn_number,
			 	accn_status,
				accn_type,
				received_date,
				nature_of_material,
				received_agent_id,
				trans_remarks,
				trans_date,
				collection,
				trans.collection_id,
				CORRESP_FG,
				concattransagent(trans.transaction_id,'entered by') enteredby
			FROM
				trans, 
				accn,
				collection
			WHERE
				trans.transaction_id = accn.transaction_id AND
				trans.collection_id=collection.collection_id and
				trans.transaction_id = #transaction_id#
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
	</cfoutput>
	
	
<strong>Edit Accession</strong>

<cfoutput query="accnData">
<form action="editAccn.cfm" method="post" name="editAccn">
<input type="hidden" name="Action" value="saveChanges">
<input type="hidden" name="transaction_id" value="#transaction_id#">
<cfset tIA=collection_id>
<table>
	<tr>
		<td align="right">
			<label for="collection_id">Collection:</label>
			<select name="collection_id" size="1"  class="reqdClr" id="collection_id">
				<cfloop query="ctcoll">
					<option <cfif #ctcoll.collection_id# is #tIA#> selected </cfif>
					value="#ctcoll.collection_id#">#ctcoll.collection#</option>
				</cfloop>
			</select>
		</td>
		<td>
			<label for="accn_number">Accn Number:</label>
			<input type="text" name="accn_number" value="#accn_number#"  id="accn_number" class="reqdClr">
		</td>
		<td>
			<label for="accn_type">How Obtained?</label>
			<select name="accn_type" size="1"  class="reqdClr" id="accn_type">
				<cfloop query="cttype">
					<option <cfif #cttype.accn_type# is "#accnData.accn_type#"> selected </cfif>
					value="#cttype.accn_type#">#cttype.accn_type#</option>
				</cfloop>
			</select>
		</td>
		<td>
			<label for="accn_status">Status:</label>
			<select name="accn_status" size="1"  class="reqdClr" id="accn_status">
				<cfloop query="ctStatus">
					<option <cfif #ctStatus.accn_status# is "#accnData.accn_status#">selected </cfif>
					value="#ctStatus.accn_status#">#ctStatus.accn_status#</option>
				</cfloop>
			</select>
		</td>
		<td>
			<label for="rec_date">Received Date:</label>
			<input type="text" name="rec_date" value="#DateFormat(received_date, 'dd mmm yyyy')#" size="10" id="rec_date">
		</td>
		<td rowspan="99" valign="top">
			<strong>Projects associated with this Accn:</strong>
			<ul>
				<cfquery name="projs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select project_name, project.project_id from project,
					project_trans where 
					project_trans.project_id =  project.project_id
					and transaction_id=#transaction_id#
				</cfquery>
				<cfif #projs.recordcount# gt 0>
					<cfloop query="projs">
						<li>
							<a href="/Project.cfm?Action=editProject&project_id=#project_id#"><strong>#project_name#</strong></a><br>
						</li>
					</cfloop>
				<cfelse>
					<li>None</li>
				</cfif>
			</ul>
				<table class="newRec" width="100%">
				<tr>
					<td>
							<label for="project_name">New Project</label>
							<input type="hidden" name="project_id">
							<input type="text" 
								size="50"
								name="project_name"
								id="project_name" 
								class="reqdClr" 
								onchange="getProject('project_id','project_name','editAccn',this.value); return false;"
								onKeyPress="return noenter(event);">
						
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="5">
			<label for="nature_of_material">Nature of Material:</label>
			<textarea name="nature_of_material" rows="5" cols="90"  class="reqdClr" 
				id="nature_of_material">#accnData.nature_of_material#</textarea>
		</td>
	</tr>
	<tr>
	<td colspan="5">
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
			  					onchange="getAgent('trans_agent_id_#trans_agent_id#','trans_agent_#trans_agent_id#','editAccn',this.value); return false;"
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
			  					onchange="getAgent('new_trans_agent_id','new_trans_agent','editAccn',this.value); return false;"
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
		<td colspan="5">
			<label for="remarks">Remarks:</label>
			<textarea name="remarks" rows="5" cols="90" id="remarks">#accnData.trans_remarks#</textarea>
		</td>
	</tr>
	<tr>
		<td colspan="3">
			<em>Entered by</em> <strong>#enteredby#</strong> <em>on</em> <strong>#dateformat(trans_date,'dd mmm yyyy')#</strong>
		</td>
		<td colspan="2">
			<label for="">Has Correspondence?</label>
			<select name="CORRESP_FG" size="1" id="CORRESP_FG">
				<option <cfif #CORRESP_FG# is "1">selected</cfif> value="1">Yes</option>
				<option <cfif #CORRESP_FG# is "0">selected</cfif> value="0">No</option>
			</select>
		</td>
	</tr>
	<tr>
		<td colspan="5" align="center">
		<input type="submit" value="Save Changes" class="savBtn"
   onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">	
 
 <input type="button" value="Quit without saving" class="qutBtn"
   onmouseover="this.className='qutBtn btnhov'" onmouseout="this.className='qutBtn'" onclick = "document.location = 'editAccn.cfm'">	
		
		 <input type="button" value="Specimen List" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
   onclick = "window.open('SpecimenResults.cfm?accn_trans_id=#transaction_id#');">	
   
    <input type="button" value="BerkeleyMapper" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
   onclick = "window.open('/bnhmMaps/bnhmMapData.cfm?accn_number=#accn_number#','_blank');">	
		</td>
	</tr>
</table>

</form>
</cfoutput>
<cfquery name="getPermits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
		permit_trans.transaction_id = #accnData.transaction_id#
</cfquery>
<br><strong>Permits:</strong>  
<cfoutput query="getPermits">
<form name="killPerm#currentRow#" method="post" action="editAccn.cfm">
<p><strong>Permit ## #permit_Num# (#permit_Type#)</strong> issued to #IssuedToAgent# by #IssuedByAgent# on #dateformat(issued_Date,"dd mmm yyyy")#. <cfif len(#renewed_Date#) gt 0> (renewed #renewed_Date#)</cfif>Expires #dateformat(exp_Date,"dd mmm yyyy")#  <cfif len(#permit_remarks#) gt 0>Remarks: #permit_remarks# </cfif> 
<br>
<input type="hidden" name="transaction_id" value="#accnData.transaction_id#">
	<input type="hidden" name="action" value="delePermit">
	<input type="hidden" name="permit_id" value="#permit_id#">
	 <input type="submit" value="Remove this Permit" class="delBtn"
   onmouseover="this.className='delBtn btnhov'" onmouseout="this.className='delBtn'">	
</form>
<!---<input type='button' value='Permit Report' class='lnkBtn'
	onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
	onclick="document.location=--->
</cfoutput>
<cfform name="addPermit" action="editAccn.cfm" method="post">
	<input type="hidden" name="transaction_id" value="#accnData.transaction_id#">
	<input type="hidden" name="permit_id">
	<cfoutput>
	  <input type="button" value="Add a permit" class="picBtn"
   onmouseover="this.className='picBtn btnhov'" onmouseout="this.className='picBtn'"
   onClick="javascript: window.open('picks/PermitPick.cfm?transaction_id=#transaction_id#', 'PermitPick', 
'resizable,scrollbars=yes,width=600,height=600')">	

</cfoutput>
</cfform>
</cfif>
<!-------------------------------------------------------------------->
<cfif #action# is "nothing">
<strong>Find Accession

<cfset title = "Find Accession">
<cfhtmlhead text="<title>#variables.title#</title>">
<cfif #project_id# gt 0>
to add to project # <cfoutput>#project_id#</cfoutput></cfif></strong>

<cfoutput>
<form action="editAccn.cfm" method="post" name="SpecData" preservedata="yes">
<input type="hidden" name="Action" value="findAccessions">
<input type="hidden" name="project_id" <cfif #project_id# gt 0> value = "#project_id#" </cfif>>
<table border>
	<tr>
		<td>
			<label  for="accn_number">Accn Number</label>
			<input type="text" name="accn_number" id="accn_number">
			<span class="smaller">&nbsp;Exact Match?</span> <input type="checkbox" name="exactAccnNumMatch" value="1">
		</td>
		<td align="right">
			<label  for="collection_id">Collection</label>
			<select name="collection_id" size="1" id="collection_id">
				<option value=""></option>
					<cfloop query="ctcoll">
						<option value="#ctcoll.collection_id#">#ctcoll.collection#</option>
					</cfloop>
			</select>
		</td>
		<td>
			<label  for="accn_status">Status</label>
			<select name="accn_status" id="accn_status" size="1">
				<option value=""></option>
					<cfloop query="ctStatus">
						<option value="#ctStatus.accn_status#">#ctStatus.accn_status#</option>
					</cfloop>
			</select>
			
		</td>
	</tr>
	<tr>
		<td align="right">
			Agent:<select name="trans_agent_role_1">
				<option value=""></option>
				<cfloop query="cttrans_agent_role">
					<option value="#trans_agent_role#">#trans_agent_role#</option>
				</cfloop>
			</select>
		</td>
		<td colspan="2">
			<input type="text" name="agent_1"  size="50">
		 </td>
	</tr>
	
	<tr>
		<td align="right">
			Agent:<select name="trans_agent_role_2">
				<option value=""></option>
				<cfloop query="cttrans_agent_role">
					<option value="#trans_agent_role#">#trans_agent_role#</option>
				</cfloop>
			</select>
		</td>
		<td colspan="2">
			<input type="text" name="agent_2"  size="50">
		 </td>
	</tr>
	<tr>
		<td align="right">
			Agent:<select name="trans_agent_role_3">
				<option value=""></option>
				<cfloop query="cttrans_agent_role">
					<option value="#trans_agent_role#">#trans_agent_role#</option>
				</cfloop>
			</select>
		</td>
		<td colspan="2">
			<input type="text" name="agent_3"  size="50">
		 </td>
	</tr>
	
	<tr>
		<td colspan="3">
			<label  for="nature_of_material">Nature of Material</label>
			<textarea name="nature_of_material" id="nature_of_material" rows="5" cols="90"><cfif isdefined("accnNumber")>#nature_of_material#</cfif></textarea>
		</td>
	</tr>
	<tr>
			<td >
				<label  for="accn_type">Accn Type</label>
				<select name="accn_type" id="accn_type" size="1">
				<option value=""></option>
				<cfloop query="cttype">
					<option value="#cttype.accn_type#">#cttype.accn_type#</option>
				</cfloop>
			</select>
		</td>
	
	</tr>
	
	<tr>
		<td colspan="3">
			<label  for="remarks">Remarks</label>
			<textarea name="remarks" id="remarks" rows="5" cols="90"><cfif isdefined("remarks")>#remarks#</cfif></textarea>
		</td>
	</tr>
	<tr>
		<td>
			<label for="ent_Date">Entry Date</label>
		<select name="entDateOper" id="entDateOper" size="1">
			<option value="<=">Before</option>
			<option selected value="=" >Is</option>
			<option value=">=">After</option>
		</select><input type="text" name="ent_Date" id="ent_Date">
		<!---<img src="images/nada.gif" width="60" height="1">--->
		</td>
		<td colspan=2 nowrap>
			<table cellspacing='0' cellpadding='0'>
				<td>
		<label  for="rec_date">Received Date:</label>
		<input type="text" name="rec_date" id="rec_date">
				</td> <td>
		<label for="rec_until_date">Until: (leave blank otherwise)</label>
		<input type='text' name='rec_until_date' id='rec_until_date'>
				</td>
			</table>
		</td>
		
	</tr>
	
	<tr>
		<td><strong>Permits:</strong></td>
	</tr>
	<tr>
			<td>
				<label  for="IssuedByAgent">Issued By</label>
				<input type="text" name="IssuedByAgent" id="IssuedByAgent">
			</td>
			<td>
				<label  for="IssuedByAgent">Issued To</label>
				<input type="text" name="IssuedToAgent" id="IssuedToAgent">
			</td>
	  </tr>
		<tr>
			<td>
				<label  for="IssuedByAgent">Issued Date</label>
				<input type="text" name="issued_Date" id="issued_Date">
			</td>
			<td>
				<label  for="IssuedByAgent">Renewed Date</label>
				<input type="text" name="renewed_Date" id="renewed_Date">
			</td>
		</tr>
		<tr>
			<td>
				<label  for="IssuedByAgent">Expiration Date</label>
				<input type="text" name="exp_Date" id="exp_Date">
			</td>
			<td>
				<label  for="IssuedByAgent">Permit Number</label>
				<input type="text" name="permit_num" id="permit_num">			
			 <span class="infoLink" 
				 onclick="getHelp('get_permit_number');">Pick</span>
			</td>
		</tr>
		<tr>
			<td>
				<label  for="permit_Type">Permit Type</label>
				<select name="permit_Type" size="1" id="permit_Type">
					<option value=""></option>
					<cfloop query="ctPermitType">
						<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
					</cfloop>				
				</select>
			</td>
			<td>
				<label  for="permit_remarks">Remarks</label>
				<input type="text" name="permit_remarks" id="permit_remarks">
			</td>		
	<tr>
		<td colspan="4" align="center">
		 <input type="submit" value="Find Accession" class="schBtn"
   onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">	

 <input type="button" value="Create a new accession" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'"
    onClick="document.location = 'newAccn.cfm';">	


 <input type="button" value="Clear Form" class="clrBtn"
   onmouseover="this.className='clrBtn btnhov'" onmouseout="this.className='clrBtn'"
   onClick="document.location='editAccn.cfm';">	

<input type="button" value="Add Specimens to an Accn" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
   onclick = "window.open('SpecimenSearch.cfm?Action=addAccn');">	

	
		</td>
	</tr>
	
</table>

</form>

</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "findAccessions">
<cfset title = "Accession Search Results">
<cfoutput>
	<cfset sel = "SELECT 
		trans.transaction_id,
		accn_number,
		nature_of_material,
		received_date,
		accn_status,
		trans_remarks,
		issuedTo.agent_name as issuedTo,
		issuedBy.agent_name as issuedBy,
		collection,
		concattransagent(trans.transaction_id,'entered by') ENTAGENT,
		concattransagent(trans.transaction_id,'received from') RECFROMAGENT">
	<cfset frm=" from 
	 	accn, 
		trans,
		permit_trans,
		permit,
		preferred_agent_name issuedBy,
		preferred_agent_name issuedTo,
		collection
		">
	<cfset sql = "where accn.transaction_id = trans.transaction_id
		and trans.transaction_id = permit_trans.transaction_id (+)
		and permit_trans.permit_id = permit.permit_id (+)
		and permit.issued_by_agent_id = issuedBy.agent_id (+)
		and permit.issued_to_agent_id = issuedTo.agent_id (+)
		and trans.collection_id=collection.collection_id
	">
		
	<cfif isdefined("trans_agent_role_1") AND len(#trans_agent_role_1#) gt 0>
		<cfset frm="#frm#,trans_agent trans_agent_1">
		<cfset sql="#sql# and trans.transaction_id = trans_agent_1.transaction_id">
		<cfset sql = "#sql# AND trans_agent_1.trans_agent_role = '#trans_agent_role_1#'">
	</cfif>
	<cfif isdefined("agent_1") AND len(#agent_1#) gt 0>
		<cfif #sql# does not contain "trans_agent_1">
			<cfset frm="#frm#,trans_agent trans_agent_1">
			<cfset sql="#sql# and trans.transaction_id = trans_agent_1.transaction_id">
		</cfif>
		<cfset frm="#frm#,preferred_agent_name trans_agent_name_1">
		<cfset sql="#sql# and trans_agent_1.agent_id = trans_agent_name_1.agent_id">
		<cfset sql = "#sql# AND upper(trans_agent_name_1.agent_name) like '%#ucase(agent_1)#%'">
	</cfif>
	<cfif isdefined("trans_agent_role_2") AND len(#trans_agent_role_2#) gt 0>
		<cfset frm="#frm#,trans_agent trans_agent_2">
		<cfset sql="#sql# and trans.transaction_id = trans_agent_2.transaction_id">
		<cfset sql = "#sql# AND trans_agent_2.trans_agent_role = '#trans_agent_role_2#'">
	</cfif>
	<cfif isdefined("agent_2") AND len(#agent_2#) gt 0>
		<cfif #sql# does not contain "trans_agent_2">
			<cfset frm="#frm#,trans_agent trans_agent_2">
			<cfset sql="#sql# and trans.transaction_id = trans_agent_2.transaction_id">
		</cfif>
		<cfset frm="#frm#,preferred_agent_name trans_agent_name_2">
		<cfset sql="#sql# and trans_agent_2.agent_id = trans_agent_name_2.agent_id">
		<cfset sql = "#sql# AND upper(trans_agent_name_2.agent_name) like '%#ucase(agent_2)#%'">
	</cfif>
	<cfif isdefined("trans_agent_role_3") AND len(#trans_agent_role_3#) gt 0>
		<cfset frm="#frm#,trans_agent trans_agent_3">
		<cfset sql="#sql# and trans.transaction_id = trans_agent_3.transaction_id">
		<cfset sql = "#sql# AND trans_agent_3.trans_agent_role = '#trans_agent_role_3#'">
	</cfif>
	<cfif isdefined("agent_3") AND len(#agent_3#) gt 0>
		<cfif #sql# does not contain "trans_agent_3">
			<cfset frm="#frm#,trans_agent trans_agent_3">
			<cfset sql="#sql# and trans.transaction_id = trans_agent_3.transaction_id">
		</cfif>
		<cfset frm="#frm#,preferred_agent_name trans_agent_name_3">
		<cfset sql="#sql# and trans_agent_3.agent_id = trans_agent_name_3.agent_id">
		<cfset sql = "#sql# AND upper(trans_agent_name_3.agent_name) like '%#ucase(agent_3)#%'">
	</cfif>
	
		<cfif isdefined("collection_id") and len(#collection_id#) gt 0>
			<cfset sql = "#sql# AND trans.collection_id = #collection_id#">
		</cfif>
		<cfif  isdefined("accn_number") and len(#accn_number#) gt 0>
			<cfif isdefined("exactAccnNumMatch") and #exactAccnNumMatch# is 1>
				<cfset sql = "#sql# AND accn_number = '#accn_number#'">
			<cfelse>
				<cfset sql = "#sql# AND upper(accn_number) LIKE '%#ucase(accn_number)#%'">
			</cfif>				
		</cfif>
		<cfif  isdefined("accn_status") and len(#accn_status#) gt 0>
			<cfset sql = "#sql# AND accn_status = '#accn_status#'">
		</cfif>
		<cfif  isdefined("rec_date") and len(#rec_date#) gt 0>
			<cfif isdefined("rec_until_date") and len(#rec_until_date#) gt 0>
				<cfset sql = "#sql# AND upper(received_date) between to_date('#rec_date#', 'DD Mon YYYY') 
																and to_date('#rec_until_date#', 'DD Mon YYYY')">
			<cfelse>
				<cfset sql = "#sql# AND upper(received_date) like to_date('#rec_date#', 'DD Mon YYYY')">
			</cfif>
		</cfif>
		<cfif  isdefined("NATURE_OF_MATERIAL") and len(#NATURE_OF_MATERIAL#) gt 0>
			<cfset sql = "#sql# AND upper(NATURE_OF_MATERIAL) like '%#ucase(NATURE_OF_MATERIAL)#%'">
		</cfif>
		<cfif  isdefined("rec_agent") and len(#rec_agent#) gt 0>
			<cfset frm = "#frm#,agent_name">
			<cfset sql = "#sql# AND upper(agent_name.agent_name) like '%#ucase(rec_agent)#%' 
				AND trans.received_agent_id = agent_name.agent_id">
		</cfif>
		<cfif  isdefined("trans_agency") and len(#trans_agency#) gt 0>
			<cfset sql = "#sql# AND upper(transAgent.agent_name) LIKE  '%#ucase(trans_agency)#%'">
		</cfif>
		<cfif  isdefined("accn_type") and len(#accn_type#) gt 0>
			<cfset sql = "#sql# AND accn_type = '#accn_type#'">
		</cfif>
		<cfif isdefined("remarks") and  len(#remarks#) gt 0>
			<cfset sql = "#sql# AND upper(trans_remarks) like '%#ucase(remarks)#%'">
		</cfif>
		<cfif  isdefined("ent_date") and len(#ent_date#) gt 0>
			<cfset sql = "#sql# AND TRANS_DATE #entDateOper# '#ucase(dateformat(ent_date,"dd-mmm-yyyy"))#'">
		</cfif>
		
		
		<!------------------------------------------------------------------>
		<cfif isdefined("IssuedByAgent") and len(#IssuedByAgent#) gt 0>
	<cfset sql = "#sql# AND upper(issuedBy.agent_name) like '%#ucase(IssuedByAgent)#%'">
</cfif>
<cfif isdefined("IssuedToAgent") and len(#IssuedToAgent#) gt 0>
	<cfset sql = "#sql# AND upper(issuedTo.agent_name) like '%#ucase(IssuedToAgent)#%'">
</cfif>
<cfif  isdefined("issued_Date") and len(#issued_Date#) gt 0>
	<cfset sql = "#sql# AND upper(issued_Date) like '%#ucase(issued_Date)#%'">
</cfif>
<cfif  isdefined("renewed_Date") and len(#renewed_Date#) gt 0>
	<cfset sql = "#sql# AND upper(renewed_Date) like '%#ucase(renewed_Date)#%'">
</cfif>
<cfif isdefined("exp_Date") and  len(#exp_Date#) gt 0>
	<cfset sql = "#sql# AND upper(exp_Date) like '%#ucase(exp_Date)#%'">
</cfif>
<cfif isdefined("permit_id") and len(#permit_id#) gt 0>
	<cfset sql = "#sql# AND permit.permit_id = '#permit_id#'">
</cfif>
<cfif isdefined("permit_Num") and len(#permit_Num#) gt 0>
	<cfset sql = "#sql# AND permit_Num = '#permit_Num#'">
</cfif>
<cfif  isdefined("permit_Type") and len(#permit_Type#) gt 0>
	
		<cfset permit_Type = #replace(permit_type,"'","''","All")#>
	
	
	<cfset sql = "#sql# AND permit_Type = '#permit_Type#'">
</cfif>
<cfif  isdefined("permit_remarks") and len(#permit_remarks#) gt 0>
	<cfset sql = "#sql# AND upper(permit_remarks) like '%#ucase(permit_remarks)#%'">
</cfif>
		<!------------------------------------------------------------------>
		<cfset thisSQL  = "#sel# #frm# #sql# ORDER BY accn_number, trans.transaction_id ">
<!---
<hr />
	
<hr />	
--->

	<cfquery name="getAccns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(thisSQL)#
	</cfquery>
		
  </cfoutput>
  <table cellpadding="0" cellspacing="0">
  <cfif #getAccns.recordcount# is 0>
		Nothing matched your search criteria.
	<cfelse>
		<cfoutput>
		<a href="/SpecimenResults.cfm?accn_trans_id=#valuelist(getAccns.transaction_id)#">
			View all items in these Accessions</a>
		</cfoutput>
	</cfif>
  <cfset i=1>
<cfoutput query="getAccns" group="transaction_id">
		<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
		  <td>
		  	<table>
				<tr>
		  			<td colspan="3">
						<cfif #project_id# gt 0>
							<input type="button" value="Add Accn #accn_number# to Project" 
								class="lnkBtn"
								onmouseover="this.className='lnkBtn btnhov'" 
								onmouseout="this.className='lnkBtn'"
								 onclick = "window.open('Project.cfm?Action=addTrans&project_id=#project_id#&transaction_id=#transaction_id#');">	
						<cfelse>
							<a href="editAccn.cfm?Action=edit&transaction_id=#transaction_id#"
								><strong>#collection# #accn_number#</strong></a>
							<font size="-1">(#accn_status#)</font>
						</cfif> 
					</td>
				</tr>
				<tr>
					<td><img src="images/nada.gif" width="30" height="1"></td>
					<td nowrap align="right">Received from:</td>
					<td>
						<strong>#recFromAgent#</strong>
					</td>
				</tr>			
				<tr>
					<td><img src="images/nada.gif" width="30" height="1"></td>
					<td nowrap align="right">Received Date:</td>
					<td><strong>#DateFormat(received_date, "dd mmm yyyy")#</strong></td>
				</tr>
				<tr>
					<td><img src="images/nada.gif" width="30" height="1"></td>
					<td align="right" valign="top">Nature of Material:</td>
					<td><strong>#nature_of_material#</strong></td>
				</tr>
				<cfif len(#trans_remarks#) gt 0>
					<tr>
						<td><img src="images/nada.gif" width="30" height="1"></td>
						<td align="right" valign="top">Remarks:</td>
						<td><strong>#trans_remarks#</strong></td>
					</tr>
				</cfif>
				<tr>
					<td><img src="images/nada.gif" width="30" height="1"></td>
					<td nowrap align="right">Entered by:</td>
					<td><strong>#entAgent#</strong></td>
				</tr>	
			</table>
		<cfset i=#i#+1>
		</td></tr></cfoutput>
		
		
	</table>
</cfif>
<!------------------------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "delePermit">
	<cfoutput>
		<cfquery name="killPerm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM permit_trans WHERE transaction_id = #transaction_id# and 
			permit_id=#permit_id#
		</cfquery>
		<cflocation url="editAccn.cfm?Action=edit&transaction_id=#transaction_id#">
	</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------->
<cfif #Action# is "saveChanges">
	<cfoutput>
		<cftransaction>
			<!--- see if they're adding project --->
			<cfif isdefined("project_id") and len(#project_id#) gt 0>
				<cfquery name="newProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					INSERT INTO project_trans (
						project_id, transaction_id)
					VALUES (
						#project_id#,#transaction_id#)
				</cfquery>
			</cfif>
			<cfquery name="updateAccn" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE accn SET
					ACCN_TYPE = '#accn_type#',
					ACCN_NUMber = '#ACCN_NUMber#',
					RECEIVED_DATE='#rec_date#',
					ACCN_STATUS = '#accn_status#' 
					WHERE transaction_id = #transaction_id#
			</cfquery>
			<cfquery name="updateTrans" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE trans SET
			 		transaction_id = #transaction_id#
					,TRANSACTION_TYPE = 'accn',
					collection_id=#collection_id#
					<cfif len(#NATURE_OF_MATERIAL#) gt 0>
						,NATURE_OF_MATERIAL = '#NATURE_OF_MATERIAL#'
					</cfif>
					<cfif len(#REMARKS#) gt 0>
						,TRANS_REMARKS = '#REMARKS#'
					<cfelse>
						,TRANS_REMARKS = NULL
					</cfif> 
				WHERE transaction_id = #transaction_id#
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
		
	<cflocation url="editAccn.cfm?Action=edit&transaction_id=#transaction_id#">
		
  </cfoutput>
</cfif>

<cfinclude template="includes/_footer.cfm">