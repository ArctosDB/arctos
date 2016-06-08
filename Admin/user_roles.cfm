<cfinclude template="/includes/_header.cfm">
<!-------------

https://github.com/ArctosDB/arctos/issues/849#issuecomment-224385884

update cf_ctuser_roles set DESCRIPTION='"Good student" basics. Manipulate most things at SpecimenDetail; manage Citations' where
	ROLE_NAME='manage_specimens';
	
grant insert,update,delete on citation to manage_specimens;



------------------------>
<cfset title="User Roles">
<cfif action IS "nothing">
	<cfoutput>
		<cfquery name="current" datasource="uam_god">
			select * from cf_ctuser_roles order by role_name
		</cfquery>
		The following table summarizes Arctos Operator Roles, and may be out of date. Please use the contact link in the footer if you notice errors.
		<br>The [def] link is the ONLY authoritative "description" of Arctos user roles. Note that roles are additive; "manage_geography" does NOT include SELECT 
		access to table geog_auth_rec; all users already have such access through the PUBLIC role.
		<br>
		<div class="importantNotification">
			Before assigning roles to users, provide them with the "required reading" link from the table below, and ensure that they 
			understand the responsibilities of working in a shared system.
		</div>
		
		<table border>
			<tr>
				<td>Role Name</td>
				<td>Description</td>
				<td>Required Reading</td>
				<td>DB Definition</td>
			</tr>
		<cfloop query="current">
			<tr>
				<td>#role_name#</td>
				<td>#Description#</td>
				<td>#required_reading#</td>
				<td><a href="user_roles.cfm?action=defineRole&role_name=#role_name#">[&nbsp;Def&nbsp;]</a></td>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------->
<cfif action IS "defineRole">
	<cfoutput>
		The following table is authoritative as of #dateformat(now(), 'YYYY-MM-DD')#.

		<cfquery name="d" datasource="uam_god">
			 SELECT table_name, grantee,
				MAX(DECODE(privilege, 'SELECT', 'yes','no')) AS select_priv,
				MAX(DECODE(privilege, 'DELETE', 'yes','no')) AS delete_priv,
				MAX(DECODE(privilege, 'UPDATE', 'yes','no')) AS update_priv,
				MAX(DECODE(privilege, 'INSERT', 'yes','no')) AS insert_priv
				FROM dba_tab_privs
				WHERE grantee IN (
				  SELECT role
				  FROM dba_roles)
				  and upper(grantee)='#ucase(role_name)#'
				GROUP BY table_name, grantee
		</cfquery>
		<table border>
			<tr>
				<td>Role</td>
				<td>Table Name</td>
				<td>Select?</td>
				<td>Delete?</td>
				<td>Insert?</td>
				<td>Update?</td>
			</tr>
			<cfloop query="d">
				<tr>
					<td>#grantee#</td>
					<td>#table_name#</td>
					<td>#select_priv#</td>
					<td>#delete_priv#</td>
					<td>#update_priv#</td>
					<td>#insert_priv#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">