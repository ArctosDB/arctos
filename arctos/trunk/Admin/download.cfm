<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<script language="JavaScript" src="/includes/CalendarPopup.js" type="text/javascript"></script>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
	var cal1 = new CalendarPopup("theCalendar");
	cal1.showYearNavigation();
	cal1.showYearNavigationInput();
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" type="text/javascript">document.write(getCalendarStyles());</SCRIPT>
<cfset title="Download Statistics">
<cfif action is "nothing">
	<h2>Download Statistics</h2>
	<cfquery name="ctusername" datasource="cf_dbuser">
		select username,affiliation 
		from cf_users, cf_download,cf_user_data
		where cf_users.user_id = cf_user_data.user_id and
		cf_users.user_id = cf_download.user_id 
		group by username,affiliation 
		order by username
	</cfquery>
	<cfoutput>
	<form name="srch" method="post" action="download.cfm">
		<input type="hidden" name="action" id="action" value="show">
		<label for="username">Username (affiliation)</label>
		<select name="username" id="username">
			<option value=""></option>
			<cfloop query="ctusername">
				<option value="#username#">#username# (#affiliation#)</option>
			</cfloop>
		</select>
		<label for="bdate">Begin Date</label>
		<input type="text" name="bdate" id="bdate">
		<img src="/images/pick.gif" 
			class="likeLink" 
			border="0" 
			alt="[calendar]"
			name="anchor1"
			id="anchor1"
			onClick="cal1.select(document.srch.bdate,'anchor1','dd-MMM-yyyy'); return false;"/>
		<label for="edate">Ended Date</label>
		<input type="text" name="edate" id="edate">
		<img src="/images/pick.gif" 
			class="likeLink" 
			border="0" 
			alt="[calendar]"
			name="anchor1"
			id="anchor1"
			onClick="cal1.select(document.srch.edate,'anchor1','dd-MMM-yyyy'); return false;"/>	
		<br>
		<input type="button" value="show table" class="lnkBtn" onclick="srch.action.value='table';srch.submit();">
		<input type="reset" class="clrBtn" value="reset form">
	</form>
	</cfoutput>
</cfif>
<cfif action is "table">
	<cfif isdefined("bdate") and len(bdate) gt 0 and (not isdefined("edate") or len(edate) is 0)>
		<cfset edate=bdate>
	</cfif>
	<cfoutput>
	<cfquery name="dl" datasource="cf_dbuser">
		select 
			username,
			first_name,
			last_name,
			affiliation,
			download_purpose,
			to_char(download_date,'dd Mon yyyy') download_date,
			num_records,
			agree_to_terms
		from cf_users, cf_user_data, cf_download
		where cf_users.user_id = cf_user_data.user_id and
		cf_users.user_id = cf_download.user_id
		<cfif isdefined("username") and len(username) gt 0>
			and cf_users.username='#username#'
		</cfif>
		<cfif isdefined("bdate") and len(bdate) gt 0>
			AND (
				to_date(to_char(cf_download.DOWNLOAD_DATE,'dd-mon-yyy')) between to_date('#dateformat(bdate,"dd-mmm-yyyy")#')
				and to_date('#dateformat(edate,"dd-mmm-yyyy")#')
			)
		</cfif>		
	</cfquery>
	<table border id="t" class="sortable">
		<tr>
			<th>Username</th>
			<th>First Name</th>
			<th>Last Name</th>
			<th>Affiliation</th>
			<th>Purpose</th>
			<th>Date</th>
			<th>Count</th>
			<th>Agree?</th>
		</tr>
		<cfloop query="dl">
			<tr>
				<td>#username#</td>
				<td>#first_name#</td>
				<td>#last_name#</td>
				<td>#affiliation#</td>
				<td>#download_purpose#</td>
				<td>#download_date#</td>
				<td>#num_records#</td>
				<td>#agree_to_terms#</td>
			</tr>
		</cfloop>
	</table>
	</cfoutput>
</cfif>
<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>
<cfinclude template="/includes/_footer.cfm">