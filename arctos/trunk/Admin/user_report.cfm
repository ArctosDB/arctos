<!--- no security --->
<cfinclude template="/includes/_header.cfm">
<cfset title="User Report">
<cfoutput>
<cfquery name="addDbUsers" datasource="uam_god">
	 select username from dba_users order by username
</cfquery>
<table border>
	<tr>
		<th>Username</th>
		<th>ReportedName</th>
		<th>ReportedAffiliation</th>
		<th>ReportedEmail</th>
		<th>AssignedRoles</th>
	</tr>
<cfloop query="addDbUsers">
	<cfquery name="cfUser" datasource="uam_god">
		 select 
		 	FIRST_NAME,
		 	MIDDLE_NAME,
		 	LAST_NAME,
		 	AFFILIATION,
		 	EMAIL
		 FROM
		 	cf_users,
		 	cf_user_data
		 WHERE
		 	cf_users.user_id = cf_user_data.user_id AND
		 	upper(cf_users.username) = '#username#'
	</cfquery>
	<cfquery name="roles" datasource="uam_god">
		select granted_role role_name
		from 
		dba_role_privs,
		cf_ctuser_roles
		where
		upper(dba_role_privs.granted_role) = upper(cf_ctuser_roles.role_name) and
		upper(grantee) = '#ucase(username)#'
	</cfquery>
	<tr>
		<td>#addDbUsers.username#</td>
		<td>#cfUser.FIRST_NAME# #cfUser.MIDDLE_NAME# #cfUser.LAST_NAME#</td>
		<td>#cfUser.AFFILIATION#</td>
		<td>#cfUser.EMAIL#</td>
		<td>
			<cfloop query="roles">
				#role_name#<br>
			</cfloop>
		</td>
	</tr>
</cfloop>
</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">