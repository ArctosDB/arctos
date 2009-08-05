<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfparam name="uname" default="">
<cfparam name="date" default="">
<cfparam name="sql" default="">
<cfoutput>
<p><strong>This form accesses after approximately 7 August 2009</strong></p>	
	<form name="srch" method="post" action="ActivityLog.cfm">
		<input type="hidden" name="action" value="search">
		<label for="uname">Username</label>
		<input type="text" name="uname" id="uname" value="#uname#">
		<label for="date">Date</label>
		<input type="text" name="date" id="date" value="#date#">
		<label for="sql">SQL</label>
		<input type="text" name="sql" id="sql" value="#sql#">
		<br>
		<input type="submit" 
		 	value="Filter" 
			class="lnkBtn">	
	</form>
<p><strong>This form accesses data previous to approximately 7 August 2009</strong></p>	
	<form name="srch" method="post" action="ActivityLog.cfm">
		<input type="hidden" name="action" value="search_old">
		<label for="uname">Username</label>
		<input type="text" name="uname" id="uname" value="#uname#">
		<label for="date">Date</label>
		<input type="text" name="date" id="date" value="#date#">
		<label for="sql">SQL</label>
		<input type="text" name="sql" id="sql" value="#sql#">
		<br>
		<input type="submit" 
		 	value="Filter" 
			class="lnkBtn">	
	</form>
</cfoutput>
<cfif action is "search">
	<cfoutput>
		<p><strong>Data previous to approximately 7 August 2009</strong></p>
		<cfquery name="activity" datasource="#Application.uam_dbo#">
			select 
				to_char(date_stamp,'dd-mon-yyyy') date_stamp, 
				sql_statement, 
				username
			from 
				cf_database_activity, 
				cf_users 
			where
				cf_database_activity.user_id = cf_users.user_id
				<cfif len(#uname#) gt 0>
					AND upper(username) like '%#ucase(uname)#%'
				</cfif>
				<cfif len(#date#) gt 0>
					AND upper(to_char(date_stamp,'dd-mon-yyyy')) like '%#ucase(date)#%'
				</cfif>
				<cfif len(#sql#) gt 0>
					AND upper(sql_statement) like '%#ucase(sql)#%'
				</cfif>
			ORDER BY 
				username,
				date_stamp,
				sql_statement
		</cfquery>
	</cfoutput>
</cfif>
<cfif #action# is "search_old">
	<cfquery name="activity" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			to_char(date_stamp,'dd-mon-yyyy') date_stamp, 
			sql_statement, 
			username
		from 
			cf_database_activity, 
			cf_users 
		where
			cf_database_activity.user_id = cf_users.user_id
			<cfif len(#uname#) gt 0>
				AND upper(username) like '%#ucase(uname)#%'
			</cfif>
			<cfif len(#date#) gt 0>
				AND upper(to_char(date_stamp,'dd-mon-yyyy')) like '%#ucase(date)#%'
			</cfif>
			<cfif len(#sql#) gt 0>
				AND upper(sql_statement) like '%#ucase(sql)#%'
			</cfif>
		ORDER BY 
			username,
			date_stamp,
			sql_statement
	</cfquery>
	<p><strong>Data previous to approximately 7 August 2009</strong></p>	
	<table border id="t_old" class="sortable">
		<tr>
			<th>username</th>
			<th>date_stamp</th>
			<th>sql_statement</th>
		</tr>
		<cfoutput>
		<cfloop query="activity">
			<tr>
				<td>#username#</td>
				<td>#date_stamp#</td>
				<td>#sql_statement#</td>
			</tr>
		</cfloop>
		</cfoutput>
	</table>
</cfif>
<cfinclude template="/includes/_footer.cfm">