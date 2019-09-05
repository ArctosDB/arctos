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
		<br> Note that roles are additive; "manage_geography" does NOT include SELECT
		access to table geog_auth_rec; all users already have such access through the PUBLIC role.
		<br>
		<div class="importantNotification">
			<ul>
				<li>
					Before assigning roles to users
					<ul>
						<li>provide them with appropriate "required reading" link from the table below</li>
						<li>ensure that they understand the responsibilities of working in a shared system
							(see http://handbook.arctosdb.org/documentation/sharing-data-and-resources.html)</li>
					</ul>
				</li>
				<li>
					The [def] link is the ONLY authoritative description of user roles. Click and review before
					granting roles.
				</li>
			</ul>
		</div>
		<br>
		<cfif isdefined("session.roles") and session.roles contains "manage_documentation">
			<a href="user_roles.cfm?action=editSummaryTable">Edit this table</a>
		</cfif>
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
<cfif action is "editSummaryTable">
	<cfoutput>
		<cfquery name="d" datasource="uam_god">
			select * from cf_ctuser_roles order by role_name
		</cfquery>
		<cfdump var=#d#>

			<cfset i=1>
			<table border>
				<tr>
					<th>ROLE_NAME</th>
					<th>USER_TYPE</th>
					<th>SHARED</th>
					<th>DESCRIPTION</th>
					<th>REQUIRED_READING</th>
					<th>TEXT_DOCUMENTATION</th>
					<th>AV_DOCUMENTATION</th>
					<th>Save</th>
				</tr>
				<cfloop query="d">
					<form name="f" method="post" action="user_roles.cfm">
						<input type="hidden" name="action" value="saveEditSumTbl">
						<input type="hidden" name="role_name" value="#role_name#">
					<tr>
						<td>#ROLE_NAME#</td>
						<td>
							<input type="text" name="USER_TYPE" value="#USER_TYPE#">
						</td>
						<td>
							<input type="text" name="SHARED" value="#SHARED#">
						</td>
						<td>
							<textarea name="DESCRIPTION" class="largetextarea">#DESCRIPTION#</textarea>
						</td>
						<td>
						<td>
							<textarea name="REQUIRED_READING" class="largetextarea">#REQUIRED_READING#</textarea>
						</td>
						<td>
							<textarea name="TEXT_DOCUMENTATION" class="largetextarea">#TEXT_DOCUMENTATION#</textarea>
						</td>
						<td>
							<textarea name="AV_DOCUMENTATION" class="largetextarea">#AV_DOCUMENTATION#</textarea>
						</td>
						<td>
							<input type="submit" value="Save Row" class="savBtn">
						</td>
					</tr>
				</cfloop>
			</table>

		</form>
	</cfoutput>
</cfif>
<cfif action IS "defineRole">
	<cfoutput>
		The following table is authoritative as of #dateformat(now(), 'YYYY-MM-DD')#.

		<p>
			Note: EXECUTE applies to stored procedures, which may perform various operations on behalf of users.
			See <a href="https://github.com/ArctosDB/DDL" target="_blank" class="external">https://github.com/ArctosDB/DDL</a> for more information.
		</p>

		<cfquery name="d" datasource="uam_god">
			 SELECT table_name,OBJECT_TYPE, grantee,
				MAX(DECODE(privilege, 'SELECT', 'yes','no')) AS select_priv,
				MAX(DECODE(privilege, 'DELETE', 'yes','no')) AS delete_priv,
				MAX(DECODE(privilege, 'UPDATE', 'yes','no')) AS update_priv,
				MAX(DECODE(privilege, 'INSERT', 'yes','no')) AS insert_priv,
				MAX(DECODE(privilege, 'EXECUTE', 'yes','no')) AS execute_priv
				FROM
					dba_tab_privs,
					all_objects
				WHERE
					dba_tab_privs.table_name=all_objects.OBJECT_NAME and
					grantee IN ( SELECT role  FROM dba_roles) and
					OBJECT_TYPE!='SYNONYM' and
					upper(grantee)='#ucase(role_name)#'
				GROUP BY table_name, grantee,OBJECT_TYPE
				order by table_name
		</cfquery>
		<table border>
			<tr>
				<td>Role</td>
				<td>Object Name</td>
				<td>Object Type</td>
				<td>Select?</td>
				<td>Delete?</td>
				<td>Insert?</td>
				<td>Update?</td>
				<td>Execute?</td>
				<td>TableBrowser</td>
			</tr>
			<cfloop query="d">
				<tr>
					<td>#grantee#</td>
					<td>#table_name#</td>
					<td>#OBJECT_TYPE#</td>
					<td>#select_priv#</td>
					<td>#delete_priv#</td>
					<td>#update_priv#</td>
					<td>#insert_priv#</td>
					<td>#execute_priv#</td>
					<td><a href="/tblbrowse.cfm?action=tbldetail&tbl=#table_name#" target="_blank">[ new tab ]</a></td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">