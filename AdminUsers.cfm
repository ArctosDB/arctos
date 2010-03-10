<cfinclude template = "includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Administer Users">
<form action="AdminUsers.cfm" method="post">
	<input type="hidden" name="Action" value="list">
	Find a user: <input name="username">&nbsp;<input type="submit" value="Find">
</form>
<cfif #Action# is "list">
	<cfquery name="getUsers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			username,
			upper(username) as ucasename,
			approved_to_request_loans,
			FIRST_NAME,
			MIDDLE_NAME,
			LAST_NAME,
			AFFILIATION,
			EMAIL
		FROM cf_users
		left outer join cf_user_data on (cf_users.user_id = cf_user_data.user_id)
		 where upper(username) like '%#ucase(username)#%'
		ORDER BY
			rights, ucasename
	</cfquery>
	<br>Select a user to administer<br>
<table border="1" id="t" class="sortable">
		<tr>
			<th>Username</th>
			<th>Collections</th>
			<th>Info</th>
		</tr>
	<cfoutput query="getUsers">
		  <cfquery name="roles" datasource="uam_god">
			select 
				granted_role role_name
			from 
				dba_role_privs,
				collection
			where
				upper(dba_role_privs.granted_role) = upper(collection.institution_acronym) || '_' || upper(collection.collection_cde) and
				upper(grantee) = '#ucasename#'
		</cfquery>
		<tr>
			 	<td><a href="AdminUsers.cfm?action=edit&username=#username#">#username#</a></td>
			 	<td>#valuelist(roles.role_name)#</td>
				<td>#FIRST_NAME# #MIDDLE_NAME# #LAST_NAME#: #AFFILIATION# (#EMAIL#)</td>
			 </tr>
	</cfoutput>
	</table>
</cfif>

<!-------------------------------------------------->
<cfif #Action# is "addRole">
	<cfoutput>
		<cfquery name="g" datasource="uam_god">
			grant #role_name# to #username#
		</cfquery>
		<cflocation url="AdminUsers.cfm?action=edit&username=#username#" addtoken="no">		
	</cfoutput>
</cfif>
<!-------------------------------------------------->
<cfif #Action# is "remrole">
	<cfoutput>
		<cfquery name="t" datasource="uam_god">
			revoke #role_name# from #username#
		</cfquery>
		<cflocation url="AdminUsers.cfm?action=edit&username=#username#" addtoken="no">
	</cfoutput>
</cfif>
<!-------------------------------------------------->
<cfif #Action# is "edit">
	<cfquery name="getUsers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT * FROM cf_users
		left outer join cf_user_data on (cf_users.user_id = cf_user_data.user_id)
		 where username = '#username#'
	</cfquery>
	<cfquery name="ctRoleName" datasource="uam_god">
				select role_name from cf_ctuser_roles where upper(role_name) not in (
					select upper(granted_role) role_name
					from 
					dba_role_privs,
					cf_ctuser_roles
					where
					upper(dba_role_privs.granted_role) = upper(cf_ctuser_roles.role_name) and
					upper(grantee) = '#ucase(username)#'
				)
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
	
	<cfoutput>
	<form action="AdminUsers.cfm" method="post">
		<input type="hidden" name="Action" value="runUpdate">
		<input type="hidden" name="orig_username" value="#getUsers.username#">
<table>
	<tr>
		<td valign="top">
		
<table border="1">
  <tr>
    <td>Username</td>
	<td>
		<input type="text" name="username" value="#getUsers.username#">
				
	</td>
  </tr>
  
  <tr>
    <td>Password</td>
    <td>
	<input type="password" name="password">
	</td>
  </tr>
     <tr>
          <td>Approved to request loans?</td>
    <td>
		<select name="approved_to_request_loans" size="1">
			<option <cfif #getUsers.approved_to_request_loans# is "0"> selected </cfif>value="0">no</option>
			<option <cfif #getUsers.approved_to_request_loans# is "1"> selected </cfif>value="1">yes</option>
		</select>
	</td>
  </tr>
  <tr>
          <td><font color="##FF0000">Delete this user</font></td>
    <td>
		<input type="text" name="delete">(type 'delete' to delete the user)
	</td>
  </tr>
  <tr>
  	<td>Info</td>
	<td>
		#getUsers.FIRST_NAME# #getUsers.MIDDLE_NAME# #getUsers.LAST_NAME# #getUsers.AFFILIATION# #getUsers.EMAIL#
	</td>
  </tr>
  <tr>
  	<td colspan="2">
		<input type="submit" value="update">		
	</td>
  </tr>
</table>
</form>

<cfquery name="isDbUser" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select username from all_users where username='#ucase(username)#'
</cfquery>
<cfquery name="hasInvite" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select user_id,allow from temp_allow_cf_user where user_id=#getUsers.user_id#
</cfquery>
		</td>
		<td valign="top">
		<table border>
			<tr>
				<td>Database User Status:</td>
				<td>
					<cfif len(#isDbUser.username#) gt 0 and hasInvite.recordcount is 0>
						Is User
						<a href="AdminUsers.cfm?username=#username#&action=lockUser">Lock Account</a>
					</cfif>
						<cfif #len(hasInvite.user_id)# is 0 and isDbUser.recordcount is 0>
							<a href="AdminUsers.cfm?action=makeNewDbUser&username=#username#&user_id=#getUsers.user_id#">Invite</a>
						<cfelse>
							<cfif #hasInvite.allow# is 1>
								Awaiting User Action (#hasInvite.allow#)
							<cfelseif #hasInvite.allow# is 2>
								Awaiting Admin Action (#hasInvite.allow#) <a href="AdminUsers.cfm?action=adminSet&username=#username#&user_id=#getUsers.user_id#">Finished</a>
							</cfif>
						</cfif>
					
				</td>
			</tr>
			<tr>
				<td colspan="2">Roles <a href="AdminUsers.cfm?username=#username#&action=dbRole"><img src="/images/info.gif" border="0" /></a></td>
			</tr>
			
			<tr class="newRec">
				<td>
					<form name="ar" method="post" action="AdminUsers.cfm">
						<input type="hidden" name="action" value="addRole" />
						<input type="hidden" name="username" value="#getUsers.username#" />
						<select name="role_name" size="1">
							<cfloop query="ctRoleName">
								<option value="#role_name#">#role_name#</option>
							</cfloop>
						</select>
				</td>
				<td>
					<input type="submit" 
						value="Grant Role" 
						class="savBtn"
						onmouseover="this.className='savBtn btnhov'"
						onmouseout="this.className='savBtn'">
					<a href="Admin/user_roles.cfm"><img src="/images/info.gif" border="0" /></a>
				</td>
			</form>
			</tr>
			<cfloop query="roles">
				<tr>
					<td>
						#role_name# 
					</td>
					<td>
						<a href="AdminUsers.cfm?action=remrole&role_name=#role_name#&username=#username#&user_id=#getUsers.user_id#"><img src="/images/del.gif" border="0" /></a>
					</td>
				</tr>
			</cfloop>
		</table>
		</td>
		<cfquery name="user_croles" datasource="uam_god">
			select granted_role role_name
			from 
			dba_role_privs,
			cf_collection
			where
			upper(dba_role_privs.granted_role) = upper(cf_collection.portal_name) and
			upper(grantee) = '#ucase(username)#'
			order by granted_role
		</cfquery>
		<cfquery name="croles" datasource="uam_god">
			select granted_role role_name
			from 
			dba_role_privs,
			cf_collection
			where
			upper(dba_role_privs.granted_role) = upper(cf_collection.portal_name) 
			group by granted_role
			order by granted_role
		</cfquery>
		
		<cfquery name="myroles" datasource="uam_god">
			select granted_role role_name
			from 
			dba_role_privs,
			cf_collection
			where
			upper(dba_role_privs.granted_role) = upper(cf_collection.portal_name) and
			upper(grantee) = '#ucase(session.username)#'
			group by granted_role
			order by granted_role
		</cfquery>
		
		
		<td valign="top">
			<table border>
				<tr>
					<th>Collection</th>
					<th>Access</th>
				</tr>
				
				<form name="ar" method="post" action="AdminUsers.cfm">
					<input type="hidden" name="action" value="addRole" />
					<input type="hidden" name="username" value="#getUsers.username#" />
					<tr>
						<td>
							<select name="role_name" size="1">
								<cfloop query="croles">
									<cfif not listfindnocase(valuelist(user_croles.role_name),role_name)
											and listfindnocase(valuelist(myroles.role_name),role_name)>
										<option value="#role_name#">#role_name#</option>
									</cfif>
								</cfloop>
							</select>
						</td>
						<td>
							<input type="submit" 
								value="Grant Access" 
								class="savBtn">
						</td>
					</tr>
				</form>
				<cfloop query="user_croles">
						<tr>
							<td>#role_name#</td>
							<td>
								<a href="AdminUsers.cfm?action=remrole&role_name=#role_name#&username=#username#&user_id=#getUsers.user_id#"><img src="/images/del.gif" border="0" /></a>
							</td>
						</tr>
				</cfloop>					
			</table>
		</td>
	</tr>
</table>
	</cfoutput>

</cfif>
<!---------------------------------------------------->
<cfif #Action# is "lockUser">
	<cfoutput>
		<cfquery name="lock" datasource="uam_god">
			alter user #username# account lock
		</cfquery>
		
		The account for #username# is now locked. Contact a DBA to unlock it.
		<a href="AdminUsers.cfm?username=#username#&action=edit">Continue</a>
	</cfoutput>
</cfif>

						
<!---------------------------------------------------->
<cfif #Action# is "adminSet">
	<cfoutput>
		<cfquery name="gpw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from temp_allow_cf_user where user_id=#user_id#
		</cfquery>
		<cflocation url="AdminUsers.cfm?Action=edit&username=#username#">
	</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif #Action# is "makeNewDbUser">
	<cfoutput>
		<!--- see if they have all the right stuff to be a user --->
		<!---
			alter table temp_allow_cf_user add invited_by_email varchar2(255);
			update temp_allow_cf_user set invited_by_email='dustymc@gmail.com';
			alter table temp_allow_cf_user modify invited_by_email varchar2(255) not null;
		--->
		<cfquery name="getTheirEmail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				EMAIL,
				username
			FROM 
				cf_users,
				cf_user_data
			where 
				cf_users.user_id=cf_user_data.user_id and
				cf_users.user_id=#user_id#
		</cfquery>
		<cfif getTheirEmail.email is "">
			<div class="error">
				The user needs a valid email address in their profile before you can continue.
			</div>
			<cfabort>
		</cfif>
		<cfquery name="getMyEmail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				EMAIL
			FROM 
				cf_users,
				cf_user_data
			where 
				cf_users.user_id=cf_user_data.user_id and
				username='#session.username#'
		</cfquery>
		<cfif getMyEmail.email is "">
			<div class="error">
				You need a valid email address in your profile before you can continue.
			</div>
			<cfabort>
		</cfif>
		<cfquery name="getAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT 
				agent_id
			FROM 
				agent_name,
				cf_users
			where 
				agent_name.agent_name_type='login' and
				agent_name.agent_name=cf_users.username and
				cf_users.user_id=#user_id#
		</cfquery>
		<cfif getAgent.agent_id is "" or getAgent.recordcount is not 1>
			<div class="error">
				The user needs a unique agent name of type login (found #getAgent.recordcount# matches).
			</div>
			<cfabort>
		</cfif>
		<cfif len(getTheirEmail.EMAIL) gt 0 and len(getMyEmail.EMAIL) gt 0 and getAgent.recordcount is 1>
			<cfquery name="gpw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into temp_allow_cf_user (user_id,allow,invited_by_email) 
				values (#user_id#,1,'#getMyEmail.EMAIL#')
			</cfquery>
			<cfmail to="#getTheirEmail.EMAIL#" from="welcome@#Application.fromEmail#" subject="operator invitation" cc="#getMyEmail.EMAIL#,#Application.PageProblemEmail#" type="html">
				Hello, #getTheirEmail.username#.
				<br>
				You have been invited to become an Arctos Operator by #session.username#.
				<br>The next time you log in, your Profile page (#application.serverRootUrl#/myArctos.cfm)
				will contain an authentication form.
				<br>You must complete this form. If your password does not meet our rules you may be required
				to create a new password by following the link from your Profile page. 
				You will then be required to fill out the authentication form again.
				The form will be replaced with a message when you have successfully authenticated.
				<br>
				Please email #getMyEmail.EMAIL# if you have any questions, or 
				#Application.PageProblemEmail# if you believe you have received this message in error.
			</cfmail>
			An invitation has been sent. <a href="AdminUsers.cfm?Action=edit&username=#username#">continue</a>			
		</cfif>
	</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif #Action# is "dbRole">
	<cfoutput>
	<a href="AdminUsers.cfm?action=edit&username=#username#">back</a>
	<br />
		<cfquery name="rd" datasource="uam_god">
			select
			  lpad(' ', 2*level) || granted_role role
			from
			  (
			  /* THE USERS */
				select 
				  null     grantee, 
				  username granted_role
				from 
				  dba_users
				where
				  username like upper('#ucase(username)#')
			  /* THE ROLES TO ROLES RELATIONS */ 
			  union
				select 
				  grantee,
				  granted_role
				from
				  dba_role_privs
			  /* THE ROLES TO PRIVILEGE RELATIONS */ 
			  union
				select
				  grantee,
				  privilege
				from
				  dba_sys_privs
			  )
			start with grantee is null
			connect by grantee = prior granted_role
		</cfquery>
		<cfloop query="rd">
			#replace(role," ","&nbsp;","all")#<br />
		</cfloop>
	</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif #Action# is "runUpdate">
	<cfoutput>
	<cfif isdefined("delete") AND #delete# is "delete">
		<cfquery name="deleteUser" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			DELETE FROM cf_users where username = '#username#'
		</cfquery>
		<cftry>
			<cfquery name="killDB" datasource="uam_god">
				drop user #username#
			</cfquery>
		<cfcatch>
			There may have been a problem dropping this user.
			<br>If the user had no Oracle account, everything is probable OK.
			<br>If the user had an Oracle account, they are probably still connected. Contact your systems administrator.
			<cfabort>
		</cfcatch>
		</cftry>
		<cflocation url="AdminUsers.cfm">
	<cfelse>
		<cfquery name="updateUser" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE cf_users SET
				<cfif len(#username#) gt 0>
					username = '#username#'
				<cfelse>
					username='#orig_username#'
				</cfif>
				<cfif len(#password#) gt 0>
					,password = '#hash(password)#'
				</cfif>
				<cfif isdefined("approved_to_request_loans") and len(#approved_to_request_loans#) gt 0>
					,approved_to_request_loans = '#approved_to_request_loans#'
				</cfif>			
				WHERE username = '#orig_username#'
		</cfquery>
        <cfif len(#password#) gt 0>
            <cftry>
	            <cfquery name="g" datasource="uam_god">
					alter user #username# identified by "#password#" 
				</cfquery>
                <cfcatch>
                    There may have been a problem updating this user's Oracle password.
                    <cfabort>
                </cfcatch>
	        </cftry>
        </cfif>
		<cflocation url="AdminUsers.cfm?Action=edit&username=#username#">
	</cfif>
	</cfoutput>
</cfif>
<cfinclude template = "includes/_footer.cfm">