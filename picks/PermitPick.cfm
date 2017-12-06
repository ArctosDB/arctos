<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Permit Pick">
<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from ctpermit_type order by permit_type
</cfquery>
<cfoutput>

Search for permits. Any part of dates and names accepted, case isn't important.<br>
<form name="findPermit" action="PermitPick.cfm" method="post">
	<input type="hidden" name="Action" value="search">
	<input type="hidden" name="transaction_id" value="#transaction_id#">
	<input type="hidden" name="callbackfunction" value="#callbackfunction#">

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
	<p>
		<input type="submit" value="Search" class="schBtn">
	</p>
	<p>
		<input type="reset" value="Clear Form" class="clrBtn">
	</p>

</form>
</cfoutput>
<cfif Action is "search">

<cfoutput>

<cfset sql = "select
		permit.permit_id,
		issued_Date,
		exp_Date,
		permit_Num,
		permit_remarks,
		getPermitAgents(permit.permit_id, 'issued to') IssuedToAgent,
		getPermitAgents(permit.permit_id, 'issued by') IssuedByAgent,
		getPermitAgents(permit.permit_id, 'contact') ContactAgent,
		getPermitTypeReg(permit.permit_id) permit_Type
from
	permit
where
	">



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


<cfif len(permit_remarks) gt 0>
	<cfset sql = "#sql# AND upper(permit_remarks) like '%#ucase(permit_remarks)#%'">
</cfif>

<cfif isdefined("permit_id") and len(permit_id) gt 0>
	<cfset sql = "#sql# AND permit.permit_id = #permit_id#">
</cfif>


<cfquery name="matchPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	#preservesinglequotes(sql)#
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
		<cfloop query="matchPermit">
			<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<td>#permit_Num#</td>

				<td>
					#permit_Type#
				</td>
				<td>
					#IssuedToAgent#
				</td>
				<td>
					#IssuedByAgent#
				</td>
				<td>
					#ContactAgent#
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
					<cfset jpd="Permit ID #permit_Num# (#valuelist(ptr.permit_type)# - #valuelist(ptr.permit_regulation)#)">
					<cfset jpd=jpd & " issued to #valuelist(it.permit_agent)# by #valuelist(ib.permit_agent)#">
					<cfset jpd=jpd & "on #dateformat(issued_date,'yyyy-mm-dd')#, expires #dateformat(exp_date,'yyyy-mm-dd')#">
					<cfif len(permit_remarks) gt 0>
						<cfset jpd=jpd & " Remarks: #permit_remarks#">
					 </cfif>
					 <cfset jpd=replace(jpd,"'","`","all")>
					 <cfset jpd=replace(jpd,'"',"`","all")>
					<form action="PermitPick.cfm" method="post" name="save">
						<input type="hidden" value="#transaction_id#" name="transaction_id">
						<input type="hidden" value="#callbackfunction#" name="callbackfunction">
						<input type="hidden" value="#jpd#" name="jpd">
						<input type="hidden" name="permit_id" value="#permit_id#">
						<input type="hidden" name="Action" value="addThisOne">
						<input type="submit" value="Add this permit">
					</form>
				<!----
					<input type="button" value="add permit to transaction" onclick="useThisOne('#permit_id#','#transaction_id#','#jpd#')">
					---->
				</td>
			</tr>
			<cfset i=i+1>
		</cfloop>
	</table>
</cfoutput>


	</cfif>
<cfif action is "AddThisOne">
	<cfoutput>
		<cfif not (len(transaction_id) gt 0 and len(permit_id) gt 0 and len(callbackfunction) gt 0)>
			something bad happened <cfabort>
		</cfif>
		<cfquery name="addPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			INSERT INTO permit_trans (permit_id, transaction_id) VALUES (#permit_id#, #transaction_id#)
		</cfquery>
		<script>
			//console.log('triggering callbackfunction');
			parent.#callbackfunction#('#permit_id#','#jpd#');
			//console.log('triggered callbackfunction');
			parent.$(".ui-dialog-titlebar-close").trigger('click');

		</script>
		Added permit #permit_id# to transaction #transaction_id#.
	</cfoutput>


</cfif>
<cfinclude template="../includes/_pickFooter.cfm">