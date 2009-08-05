<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfparam name="uname" default="">
<cfparam name="date" default="">
<cfparam name="sql" default="">
<cfparam name="object" default="">
<cfoutput>
<p><strong>This form accesses after approximately 7 August 2009</strong></p>	
	<form name="srch" method="post" action="ActivityLog.cfm">
		<label for="action">Data to search</label>
		<select name="action">
			<option <cfif action is 'search'> selected="selected"></cfif> value="search">7 Aug 2009-present</option>
			<option <cfif action is 'search_old'> selected="selected"></cfif> value="search_old">before 7 Aug 2009</option>
		</select>
		<label for="uname">Username</label>
		<input type="text" name="uname" id="uname" value="#uname#">
		<label for="date">Date</label>
		<input type="text" name="date" id="date" value="#date#">
		<label for="sql">SQL</label>
		<input type="text" name="sql" id="sql" value="#sql#">
		<label for="form">Object</label>
		<input type="text" name="object" id="form" value="#object#">
		<br>
		<input type="submit" 
		 	value="Filter" 
			class="lnkBtn">	
	</form>
</cfoutput>
<cfif action is "search">
	<cfoutput>
		<p><strong>Data after approximately 7 August 2009</strong></p>
		<cfquery name="activity" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				to_char(TIMESTAMP,'dd-mon-yyyy') date_stamp, 
				SQL_TEXT sql_statement, 
				DB_USER username,
				OBJECT_NAME object
			from 
				uam.arctos_audit
			where
				1=1
				<cfif len(#uname#) gt 0>
					AND upper(DB_USER) like '%#ucase(uname)#%'
				</cfif>
				<cfif len(#date#) gt 0>
					AND upper(to_char(TIMESTAMP,'dd-mon-yyyy')) like '%#ucase(date)#%'
				</cfif>
				<cfif len(#sql#) gt 0>
					AND upper(SQL_TEXT) like '%#ucase(sql)#%'
				</cfif>
				<cfif len(#object#) gt 0>
					AND upper(object_name) like '%#ucase(object)#%'
				</cfif>
			ORDER BY 
				username,
				date_stamp,
				sql_statement
		</cfquery>
		<table border id="t" class="sortable">
		<tr>
			<th>username</th>
			<th>object</th>
			<th>date_stamp</th>
			<th>sql_statement</th>
		</tr>
		<cfloop query="activity">
			<tr>
				<td>#username#</td>
				<td>#object#</td>
				<td>#date_stamp#</td>
				<td>#sql_statement#</td>
			</tr>
		</cfloop>
	</table>
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