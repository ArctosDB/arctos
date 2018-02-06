<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Permit Pick">
<cfquery name="ctPermitType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from ctpermit_type order by permit_type
</cfquery>
<cfoutput>
	Search for permits. Any part of dates and names accepted, case isn't important.<br>
	<form name="findPermit" action="PermitPick.cfm" method="post">
		<input type="hidden" name="action" value="search">
		<input type="hidden" name="transaction_id" value="#transaction_id#">
		<input type="hidden" name="callbackfunction" value="#callbackfunction#">
		<cfinclude template="/includes/forms/permit_search.cfm">
	</form>
</cfoutput>
<cfif action is "search">
	<cfoutput>
		<p>
			<a href="/Permit.cfm?action=newPermit" target="_blank">Create a new Permit (new window)</a>
		</p>
		<!--- assemble sqlstring (variable "sqlstring") --->
		<cfinclude template="/includes/forms/permit_search_results.cfm">
		<cfquery name="matchPermit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(sqlstring)#
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
						<cfset jpd="Permit ID #permit_Num# (#permit_Type#)">
						<cfset jpd=jpd & " issued to #IssuedToAgent# by #IssuedByAgent#">
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
			parent.#callbackfunction#('#permit_id#','#jpd#');
			parent.$(".ui-dialog-titlebar-close").trigger('click');
		</script>
		Added permit #permit_id# to transaction #transaction_id#.
	</cfoutput>
</cfif>
<cfinclude template="../includes/_pickFooter.cfm">