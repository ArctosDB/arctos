<cfinclude template="/includes/_header.cfm">
<cfparam name="uname" default="">
<cfparam name="date" default="">
<cfparam name="sql" default="">
<table>
<cfoutput>
	<form name="srch" method="post" action="ActivityLog.cfm">
		<input type="hidden" name="action" value="search">
		<tr>
			<td align="right">
				Username
			</td>
			<td><input type="text" name="uname" value="#uname#"></td>
		</tr>
		<tr>
			<td align="right">
				Date
			</td>
			<td><input type="text" name="date" value="#date#"></td>
		</tr>
		<tr>
			<td align="right">
				SQL
			</td>
			<td><input type="text" name="sql" value="#sql#"></td>
		</tr>
		<tr>
			<td colspan="2">
				 <input type="submit" 
				 	value="Filter" 
					class="lnkBtn"
   					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'">	
			</td>
		</tr>
	</form>
</table>
</cfoutput>
<cfif #action# is "search">
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
<table border>
	<tr>
		<td>username</td>
		<td>date_stamp</td>
		<td>sql_statement</td>
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