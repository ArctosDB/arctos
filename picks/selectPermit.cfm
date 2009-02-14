<!---
Title: picks/selectPermit.cfm
Author: Peter DeVore
Email: pdevore@berkeley.edu

Description:
	Allows user to select a permit from a search and returns pertinent information.
Parameters:
	none.
Returns:
	issuedToAgent:
		who the selected permit was issued to.
	issuedByAgent:
		who the selected permit was issued by.
	permit_num:
		the number of the permit.
Based on:
	PermitPick.cfm.
Dependencies:
	report.cfm is dependent on this file.
Notes:
	uses window.opener.document to "return" values.
--->

<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Select Permit">
<body bgcolor="#FFFBF0" text="midnightblue" link="blue" vlink="midnightblue">
 
 <cfif not isdefined("Action")>
	<cfset Action = "nothing">
</cfif>
<cfif action is "test">
	<cfdump var="#form#">
	<cfoutput>
	<cfif isdefined('name1')>
		name1 is defined <br/>
	</cfif>
	<cfif isdefined('name2')>
		name2 is defined <br/>
	</cfif>
	</cfoutput>
</cfif>
<form name="blargh" action="selectPermit.cfm" method="get">
	<input type="hidden" name="action" value="test">
	<input type="submit" name="name1" value="value1">
	<input type="submit" name="name2" value="value2">
</form>

<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from ctpermit_type
</cfquery>
<cfoutput>

Search for permits. Any part of dates and names accepted, case isn't important.<br>
<cfform name="findPermit" action="selectPermit.cfm" method="post">
	<input type="hidden" name="Action" value="search">
	<table>
		<tr>
			<td>Issued By</td>
			<td><input type="text" name="IssuedByAgent"></td>
			<td>Issued To</td>
			<td><input type="text" name="IssuedToAgent"></td>
		</tr>
		<tr>
			<td>Issued Date</td>
			<td><input type="text" name="issued_date"></td>
			<td>Issued Until Date (leave blank otherwise)</td>
			<td><input type="text" name="issued_until_date"></td>
		</tr>
		<tr>
			<td>Renewed Date</td>
			<td><input type="text" name="renewed_date"></td>
			<td>Renewed Until Date (leave blank otherwise)</td>
			<td><input type="text" name="renewed_until_date"></td>
		</tr>
		<tr>
			<td>Expiration Date</td>
			<td><input type="text" name="exp_date"></td>
			<td>Expiration Until Date (leave blank otherwise)</td>
			<td><input type="text" name="exp_until_date"></td>
		</tr>
		<tr>
			<td>Permit Type</td>
			<td colspan='3'>
				<select name="permit_type" size="1">
					<option value=""></option>
					<cfloop query="ctPermitType">
						<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
					</cfloop>
				
				</select>
			</td>
		</tr>
		<tr>
			<td>Permit Number</td>
			<td><input type="text" name="permit_num"></td>
			<td>Remarks</td>
			<td><input type="text" name="permit_remarks"></td>
		</tr>
		<tr>
			<td colspan="4" align="center">
			<input type="submit" 
				value="Search" 
				class="schBtn"
   				onmouseover="this.className='schBtn btnhov'" 
				onmouseout="this.className='schBtn'">	
   
   <img src="../images/nada.gif" width="30">
   			<input type="reset" 
				value="Clear" 
				class="clrBtn"
   				onmouseover="this.className='clrBtn btnhov'" 
				onmouseout="this.className='clrBtn'">
				</td>
		</tr>
	</table>
	
	
	
</cfform>
</cfoutput>
<cfif #Action# is "search">

<!--- set dateformat --->

<cfset sql = "select permit.permit_id,
	issuedBy.agent_name as IssuedByAgent,
	issuedTo.agent_name as IssuedToAgent,
	issued_Date,
	renewed_Date,
	exp_Date,
	permit_Num,
	permit_Type,
	permit_remarks 
from 
	permit,  agent_name issuedTo, agent_name issuedBy 
where 
	permit.issued_by_agent_id = issuedBy.agent_id and
	permit.issued_to_agent_id = issuedTo.agent_id ">
	
	

	

<cfif len(#IssuedByAgent#) gt 0>
	<cfset sql = "#sql# AND upper(issuedBy.agent_name) like '%#ucase(IssuedByAgent)#%'">
</cfif>
<cfif len(#IssuedToAgent#) gt 0>
	<cfset sql = "#sql# AND upper(issuedTo.agent_name) like '%#ucase(IssuedToAgent)#%'">
</cfif>
<cfif len(#issued_date#) gt 0>
	<cfif len(#issued_until_date#) gt 0>
		<cfset sql = "#sql# AND upper(issued_date) between to_date('#issued_date#', 'DD Mon YYYY') 
														and to_date('#issued_until_date#', 'DD Mon YYYY')">
	<cfelse>
		<cfset sql = "#sql# AND upper(issued_date) like to_date('#issued_date#', 'DD Mon YYYY')">
	</cfif>
</cfif>
<cfif len(#renewed_date#) gt 0>
	<cfif len(#renewed_until_date#) gt 0>
		<cfset sql = "#sql# AND upper(renewed_date) between to_date('#renewed_date#', 'DD Mon YYYY') 
														and to_date('#renewed_until_date#', 'DD Mon YYYY')">
	<cfelse>
		<cfset sql = "#sql# AND upper(renewed_date) like to_date('#renewed_date#', 'DD Mon YYYY')">
	</cfif>
</cfif>
<cfif len(#exp_date#) gt 0>
	<cfif len(#exp_until_date#) gt 0>
		<cfset sql = "#sql# AND upper(exp_date) between to_date('#exp_date#', 'DD Mon YYYY') 
														and to_date('#exp_until_date#', 'DD Mon YYYY')">
	<cfelse>
		<cfset sql = "#sql# AND upper(exp_date) like to_date('#exp_date#', 'DD Mon YYYY')">
	</cfif>
</cfif>
<cfif len(#permit_num#) gt 0>
	<cfset sql = "#sql# AND permit_num = '#permit_num#'">
</cfif>
<cfif len(#permit_type#) gt 0>
	<cfset permit_Type = #replace(permit_type,"'","''","All")#>
	<cfset sql = "#sql# AND permit_type = '#permit_type#'">
</cfif>
<cfif len(#permit_remarks#) gt 0>
	<cfset sql = "#sql# AND upper(permit_remarks) like '%#ucase(permit_remarks)#%'">
</cfif>
<cfset sql = "#sql# ORDER BY permit_id">
<hr>
<cfoutput>
<cfif #sql# is "select * from permit, agent_name issuedTo, agent_name issuedBy where permit.issued_by_agent_id = issuedBy.agent_id and permit.issued_to_agent_id = issuedTo.agent_id ">
	Enter some criteria.<cfabort>
</cfif>
<cfquery name="matchPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>

</cfoutput>

<!--- generates one html form for EACH search result --->
<cfoutput query="matchPermit" group="permit_id">
	<form action="selectPermit.cfm" method="post" name="save">
	<input type="hidden" name="permit_id" value="#permit_id#">
	<input type="hidden" name="permit_num" value="#permit_num#">
	<input type="hidden" name="issuedToAgent" value="#issuedToAgent#">
	<input type="hidden" name="issuedByAgent" value="#issuedByAgent#">
	<input type="hidden" name="Action" value="selectThisOne">
	Permit Number #permit_Num# (#permit_Type#) issued to #IssuedToAgent# by #IssuedByAgent# on #dateformat(issued_Date,"dd mmm yyyy")# <cfif len(#renewed_Date#) gt 0> (renewed #dateformat(renewed_Date,"dd mmm yyyy")#)</cfif>. Expires #dateformat(exp_Date,"dd mmm yyyy")#.  <cfif len(#permit_remarks#) gt 0>Remarks: #permit_remarks# </cfif> (ID## #permit_id#)
<br><input type="submit" value="Add this permit">
	</form>

</cfoutput>


	</cfif>
<cfif #Action# is "selectThisOne">
	<cfoutput>
		<cfif not (len(#permit_id#) gt 0)>
			something bad happened <cfabort>
		</cfif>
		stuff to pass back: permit.permit_num, issuedTo.agent_name, issuedBy.agent_name
		<script type="text/javascript">
			var temp;
			temp = window.opener.document.getElementById('permit_num');
			if (temp != null) {
				temp.value='#permit_num#';
				//alert('passed back: #permit_num# as permit_num');
			}
			temp = window.opener.document.getElementById('issuedToAgent');
			if (temp != null) {
				temp.value='#issuedToAgent#';
				//alert('passed back: #issuedToAgent# as issuedToAgent');
			}
			temp = window.opener.document.getElementById('issuedByAgent');
			if (temp != null) {
				temp.value='#issuedByAgent#';
				//alert('passed back: #issuedByAgent# as issuedByAgent');
			}
			self.close();
		</script>
		should have closed by now
	</cfoutput>	
	
	
</cfif>
<cfinclude template="../includes/_pickFooter.cfm">