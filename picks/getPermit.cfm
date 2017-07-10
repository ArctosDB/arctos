<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Permit Pick">
<!---
	latest version
	accept:
		PermitIDFld: ID of field to write permit_id
		PermitNumberFld: ID of field to write summary (permit ID or whatever, it's just text)
		permit_number: search parameter
---->
<script>
	$(document).ready(function() {
		$( "#findPermit" ).submit(function( event ) {
			event.preventDefault();

			console.log('triggered');
			var q=$( this ).serialize();
			$.getJSON("/component/functions.cfc",
				{
					method : "pickPermit",
					q : q,
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					console.log('back');

					console.log(r);
					if (r.ROWCOUNT==0){
						$("#psRes").html('Searh found no permits.');
					} else {
						var h='<table border>';
						h+='<tr>';
						h+='<th>PermitNumber</th>';
						h+='<th>PermitType</th>';
						h+='<th>IssuedTo</th>';
						h+='<th>IssuedBy</th>';
						h+='<th>IssuedDate</th>';
						h+='<th>RenewedDate</th>';
						h+='<th>ExpireDate</th>';
						h+='<th>Remark</th>';
						h+='<th>clicky</th>';
						h+='</tr>';
						for (i=0;i<r.ROWCOUNT;i++) {
							console.log(r.DATA.PERMIT_ID[i]);

							h+='<tr>';
							h+='<td>' + r.DATA.PERMIT_NUM[i] + '</td>';
							h+='<td>' + r.DATA.PERMIT_TYPE[i] + '</td>';
							h+='<td>' + r.DATA.ISSUEDTOAGENT[i] + '</td>';
							h+='<td>' + r.DATA.ISSUEDBYAGENT[i] + '</td>';
							h+='<td>' + r.DATA.ISSUED_DATE[i] + '</td>';
							h+='<td>' + r.DATA.RENEWED_DATE[i] + '</td>';
							h+='<td>' + r.DATA.EXP_DATE[i] + '</td>';
							h+='<td>' + r.DATA.PERMIT_REMARKS[i] + '</td>';
							h+='<td>' + r.DATA.PERMIT_ID[i] + '</td>';
							h+='</tr>';
						}
						h+='</table>';
						$("#psRes").html(h);
					}
				}
			);
		});
	});


</script>
<!----
	WCOUNT":33,"COLUMNS":["PERMIT_ID","","","","","","","",""],"DATA":{"PERMIT_ID":

---->
<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from ctpermit_type order by permit_type
</cfquery>
<cfoutput>
	Search for permits. Any part of dates and names accepted, case isn't important.<br>
	<form name="findPermit" id="findPermit" action="" method="post">
		<input type="hidden" name="PermitIDFld" value="#PermitIDFld#">
		<input type="hidden" name="PermitNumberFld" value="#PermitNumberFld#">
		<label for="permit_number">Permit Number</label>
		<input type="text" id="permit_number" name="permit_number" value="#permit_number#">
		<label for="IssuedByAgent">Issued By</label>
		<input type="text" id="IssuedByAgent" name="IssuedByAgent" >
		<label for="IssuedToAgent">Issued To</label>
		<input type="text" id="IssuedToAgent" name="IssuedToAgent" >
		<label for="issued_Date">Issued Date</label>
		<input type="text" id="issued_Date" name="issued_Date" >
		<label for="renewed_Date">Renewed Date</label>
		<input type="text" id="renewed_Date" name="renewed_Date" >
		<label for="exp_Date">Expiration Date</label>
		<input type="text" id="exp_Date" name="exp_Date" >
		<label for="permit_remarks">Remarks</label>
		<input type="text" id="permit_remarks" name="permit_remarks" >
		<label for="permit_Type">Permit Type</label>
		<select name="permit_Type" size="1">
			<option value=""></option>
			<cfloop query="ctPermitType">
				<option value = "#ctPermitType.permit_type#">#ctPermitType.permit_type#</option>
			</cfloop>
		</select>
		<br><input type="submit" value="Search" class="schBtn">
	</form>

	<div id="psRes">

	</div>
</cfoutput>

<!----
<cfset sql = "select permit.permit_id,
	issuedByPref.agent_name IssuedByAgent,
	issuedToPref.agent_name IssuedToAgent,
	issued_Date,
	renewed_Date,
	exp_Date,
	permit_Num,
	permit_Type,
	permit_remarks
from
	permit,
	preferred_agent_name issuedToPref,
	preferred_agent_name issuedByPref,
	agent_name issuedTo,
	agent_name issuedBy
where
	permit.issued_by_agent_id = issuedBy.agent_id and
	permit.issued_to_agent_id = issuedTo.agent_id and
		permit.issued_by_agent_id = issuedByPref.agent_id and
	permit.issued_to_agent_id = issuedToPref.agent_id ">

<cfif len(IssuedByAgent) gt 0>
	<cfset sql = "#sql# AND upper(issuedBy.agent_name) like '%#ucase(IssuedByAgent)#%'">
</cfif>
<cfif len(#IssuedToAgent#) gt 0>
	<cfset sql = "#sql# AND upper(issuedTo.agent_name) like '%#ucase(IssuedToAgent)#%'">
</cfif>
<cfif len(#issued_Date#) gt 0>
	<cfset sql = "#sql# AND upper(issued_Date) like '%#ucase(issued_Date)#%'">
</cfif>
<cfif len(#renewed_Date#) gt 0>
	<cfset sql = "#sql# AND upper(renewed_Date) like '%#ucase(renewed_Date)#%'">
</cfif>
<cfif len(#exp_Date#) gt 0>
	<cfset sql = "#sql# AND upper(exp_Date) like '%#ucase(exp_Date)#%'">
</cfif>
<cfif len(#permit_number#) gt 0>
	<cfset sql = "#sql# AND permit_Num = '#permit_number#'">
</cfif>
<cfif len(#permit_Type#) gt 0>

		<cfset permit_Type = #replace(permit_type,"'","''","All")#>


	<cfset sql = "#sql# AND permit_Type = '#permit_Type#'">
</cfif>
<cfif len(#permit_remarks#) gt 0>
	<cfset sql = "#sql# AND upper(permit_remarks) like '%#ucase(permit_remarks)#%'">
</cfif>
<cfset sql = "#sql# ORDER BY permit_id">
<hr>
<cfif #sql# is "select * from permit, agent_name issuedTo, agent_name issuedBy where permit.issued_by_agent_id = issuedBy.agent_id and permit.issued_to_agent_id = issuedTo.agent_id ">
	<cfabort>
</cfif>
<cfquery name="matchPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	#preservesinglequotes(sql)#
</cfquery>

</cfoutput>
<cfset i=1>
<cfoutput query="matchPermit" group="permit_id">
<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
	<form action="PermitPick.cfm" method="post" name="save">
	<input type="hidden" value="#transaction_id#" name="transaction_id">
	<input type="hidden" name="permit_id" value="#permit_id#">
	<input type="hidden" name="Action" value="addThisOne">
	Permit Number #permit_Num# (#permit_Type#) issued to #IssuedToAgent# by #IssuedByAgent# on #dateformat(issued_Date,"yyyy-mm-dd")# <cfif len(#renewed_Date#) gt 0> (renewed #dateformat(renewed_Date,"yyyy-mm-dd")#)</cfif>. Expires #dateformat(exp_Date,"yyyy-mm-dd")#.  <cfif len(#permit_remarks#) gt 0>Remarks: #permit_remarks# </cfif> (ID## #permit_id#)
<br><input type="submit" value="Add this permit">
	</form>
</div>
<cfset i=i+1>
</cfoutput>


<cfif #Action# is "AddThisOne">
	<cfoutput>
		<cfif not (len(#transaction_id#) gt 0 and len(#permit_id#) gt 0)>
			something bad happened <cfabort>
		</cfif>
		<cfquery name="addPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO permit_trans (permit_id, transaction_id) VALUES (#permit_id#, #transaction_id#)
		</cfquery>



		Added permit #permit_id# to transaction #transaction_id#.
		<br>Search to add another permit to this accession or click
		<a href="##" onclick="javascript: self.close();">here</a> to close this window.
	</cfoutput>


</cfif>
---->
<cfinclude template="../includes/_pickFooter.cfm">