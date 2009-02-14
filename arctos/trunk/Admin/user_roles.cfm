<cfinclude template="/includes/_header.cfm">
<cfif #action# IS "nothing">

<cfoutput>
<cfquery name="current" datasource="#Application.uam_dbo#">
	select * from cf_ctuser_roles order by role_name
</cfquery>
<table border>
	<tr>
		<td>Role Name</td>
		<td>Description</td>
		<td>DB Definition</td>
	</tr>
<cfloop query="current">
	<tr>
		<td>#role_name#</td>
		<td>#Description#</td>
		<td><a href="user_roles.cfm?action=defineRole&role_name=#role_name#">[&nbsp;Def&nbsp;]</a></td>
	</tr>
</cfloop>
</table>
</cfoutput>

</cfif>

<!---------------------------------------------------------------------->

<!---------------------------------------------------------------------->
<cfif #action# IS "defineRole">
	<cfoutput>
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
