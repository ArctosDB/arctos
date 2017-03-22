<cfinclude template = "includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Administer Users">
<form action="AdminUsers.cfm" method="post">
	<input type="hidden" name="Action" value="list">
	<label for="username">Search by Arctos Username</label>
	<input name="username">&nbsp;<input type="submit" value="Find">
</form>
<hr>
<cfif action is "unlockOracleAccount">
	<cfoutput>
		<p>
			<strong><em>Do</em></strong> unlock accounts that have timed out due to inactivity, and those that the account owner has
			guessed at their forgotton password too many times; these are almost always safe.
		</p>
		<p>
			<strong><em>Do not</em></strong> unlock an account if there are any security concerns, suspicious activity, or not indication of
			why the account was locked.	Search the arctos.database gmail account for information; do not assume anything.
		</p>
		<p>
			The account owner will be required to select a new password, and must have a valid email address in their
			user profile or agent record.
		</p>
		<p>
			If you want to proceed to unlock account #username#, <a href="AdminUsers.cfm?action=submitUnlockOracleAccount&username=#username#">click this</a>.
		</p>
	</cfoutput>
</cfif>
<cfif action is "submitUnlockOracleAccount">
	<cfoutput>
		<cfset charList = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,z,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,1,2,3,4,5,6,7,8,9,0">
		<cfset numList="1,2,3,4,5,6,7,8,9,0">
		<cfset specList="!,$,%,&,_,*,?,-,(,),<,>,=,/,:,;,.">
		<cfset newPass = "">
		<cfset cList="#charList#,#numList#,#specList#">
		<cfset c=0>
		<cfset i=1>
		<cfset thisChar = ListGetAt(charList,RandRange(1,listlen(charList)))>
		<cfset newPass=newPass & thisChar>
		<cfset thisChar = ListGetAt(numList,RandRange(1,listlen(numList)))>
		<cfset newPass=newPass & thisChar>
		<cfset thisChar = ListGetAt(specList,RandRange(1,listlen(specList)))>
		<cfset newPass=newPass & thisChar>
		<cfloop from="1" to="6" index="i">
			<cfset thisChar = ListGetAt(cList,RandRange(1,listlen(cList)))>
			<cfset newPass=newPass & thisChar>
		</cfloop>
		<cfquery name="userEmail" datasource="uam_god">
			select distinct adr from (
				select
					EMAIL adr
				from
					cf_user_data,
					cf_users
				where
					cf_user_data.USER_ID=cf_users.USER_ID and
					cf_users.username='#username#'
				union
				select
					ADDRESS adr
				from
					ADDRESS,
					agent_name
				where
					ADDRESS.agent_id=agent_name.agent_id and
					ADDRESS.VALID_ADDR_FG=1 and
					ADDRESS_TYPE='email' and
					AGENT_NAME_TYPE='login' and
					AGENT_NAME='#username#'
				union
				select
					ADDRESS adr
				from
					ADDRESS,
					agent_name
				where
					ADDRESS.agent_id=agent_name.agent_id and
					ADDRESS.VALID_ADDR_FG=1 and
					ADDRESS_TYPE='email' and
					AGENT_NAME_TYPE='login' and
					AGENT_NAME='#session.username#'
			)
		</cfquery>
		<cftransaction>
			<cfquery name="uact" datasource="uam_god">
				alter user #username# account unlock
			</cfquery>
			<cfquery name="db" datasource="uam_god">
				alter user #username# identified by "#newPass#"
			</cfquery>
			<cfquery name="stopTrg" datasource="uam_god">
				alter trigger CF_PW_CHANGE disable
			</cfquery>
			<cfquery name="setNewPass" datasource="uam_god">
				UPDATE cf_users SET password = '#hash(newPass)#',
				pw_change_date=sysdate-91
				where USERNAME = '#username#'
			</cfquery>
			<cfquery name="stopTrg" datasource="uam_god">
				alter trigger CF_PW_CHANGE enable
			</cfquery>
			<cfmail
				to="#valuelist(userEmail.adr)#"
				cc="#Application.logEmail#"
				subject="Arctos Account Unlocked"
				from="AccountUnlock@#Application.fromEmail#"
				type="html">
				Dear #username#,

				<p>Your Arctos account has been unlocked and reset by #session.username#.</p>
					<p>
					Your one-time username/password is
					<blockquote>
						#username# / #newPass#
					</blockquote>
					Use that information to log into Arctos. You will be required to change your password.
				</p>
				<p>
					You may log in at <a href="#Application.ServerRootUrl#/login.cfm">#Application.ServerRootUrl#/login.cfm</a>
				</p>
				<p>
					If you did not request this change, please reply to #Application.bugReportEmail#.
				</p>
			</cfmail>
			Success - #username# is now unlocked. Please direct them to check their email for a new password.
		</cftransaction>
	</cfoutput>
</cfif>
<cfif Action is "list">
	<cfquery name="getUsers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
			username,
			upper(username) as ucasename,
			approved_to_request_loans,
			FIRST_NAME,
			MIDDLE_NAME,
			LAST_NAME,
			AFFILIATION,
			EMAIL
		FROM
			cf_users,
			cf_user_data
		where
			cf_users.user_id = cf_user_data.user_id (+) and
			upper(username) like '%#ucase(username)#%'
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
					upper(dba_role_privs.granted_role) = upper(replace(collection.guid_prefix,':','_')) and
					upper(grantee) = '#ucasename#'
			</cfquery>
			<tr>
				 <td><a href="AdminUsers.cfm?action=edit&username=#username#">#username#</a></td>
				 <td>#replace(valuelist(roles.role_name),",",", ","all")#</td>
				<td>#FIRST_NAME# #MIDDLE_NAME# #LAST_NAME#: #AFFILIATION# (#EMAIL#)</td>
			</tr>
		</cfoutput>
	</table>
</cfif>
<!-------------------------------------------------->
<cfif action is "addRole">
	<cfoutput>
		<cfquery name="g" datasource="uam_god">
			grant #role_name# to #username#
		</cfquery>
		<cflocation url="AdminUsers.cfm?action=edit&username=#username#" addtoken="false">
	</cfoutput>
</cfif>
<!-------------------------------------------------->
<cfif action is "remrole">
	<cfoutput>
		<cfquery name="t" datasource="uam_god">
			revoke #role_name# from #username#
		</cfquery>
		<cflocation url="AdminUsers.cfm?action=edit&username=#username#" addtoken="no">
	</cfoutput>
</cfif>
<!-------------------------------------------------->
<cfif action is "edit">
	<cfoutput>
		<cfquery name="getUsers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				username,
				FIRST_NAME,
				MIDDLE_NAME,
				LAST_NAME,
				AFFILIATION,
				EMAIL,
				cf_users.USER_ID
			FROM
				cf_users,
				cf_user_data
			where
				cf_users.user_id = cf_user_data.user_id (+) and
			 	upper(username) = '#ucase(username)#'
		</cfquery>
		<cfquery name="isAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			SELECT
				agent_id
			FROM
				agent_name
			where
				agent_name_type='login' and
			 	upper(agent_name) = '#ucase(username)#'
		</cfquery>
		<cfif getUsers.recordcount is not 1>
			<div class="error">
				#getUsers.recordcount# records found for username #username#.
			</div>
			<cfabort>
		</cfif>
		<!--- grantables: roles that the user does not have but the administrator DOES have --->
		<cfquery name="ctRoleName" datasource="uam_god">
			select
				role_name
			from
				cf_ctuser_roles
			where
				upper(role_name) not in (
					select
						upper(granted_role) role_name
					from
						dba_role_privs,
						cf_ctuser_roles
					where
						upper(dba_role_privs.granted_role) = upper(cf_ctuser_roles.role_name) and
						upper(grantee) = '#ucase(username)#'
				)
			and upper(role_name) IN (
				select
						upper(granted_role) role_name
					from
						dba_role_privs,
						cf_ctuser_roles
					where
						upper(dba_role_privs.granted_role) = upper(cf_ctuser_roles.role_name) and
						upper(grantee) = '#ucase(session.username)#'
				)
		</cfquery>
		<!---- roles that the user already has ---->
		<cfquery name="roles" datasource="uam_god">
			select
				granted_role role_name
			from
				dba_role_privs,
				cf_ctuser_roles
			where
				upper(dba_role_privs.granted_role) = upper(cf_ctuser_roles.role_name) and
				upper(grantee) = '#ucase(username)#'
		</cfquery>
		<cfquery name="isDbUser" datasource="uam_god">
			select username,account_status from dba_users where username='#ucase(username)#'
		</cfquery>
		<cfquery name="hasInvite" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select user_id,allow from temp_allow_cf_user where user_id=#getUsers.user_id#
		</cfquery>
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
		<cfset title="edit user #username#">
		<h3>Editing User #username#</h3>
		<table>
			<tr>
				<td colspan="2">
					<table border>
						<tr>
							<td align="right">Arctos username:</td>
							<td>#username#</td>
						</tr>
						<tr>
							<td align="right">Agent:</td>
							<td>
								<cfif len(isAgent.agent_id) gt 0>
									<a href="/agents.cfm?agent_id=#isAgent.agent_id#"> [ edit Agent ] </a>
								<cfelse>
									Agent not found
								</cfif>
							</td>
						</tr>
						<tr>
							<td align="right">Reported First/Middle/Last:</td>
							<td>#getUsers.FIRST_NAME# #getUsers.MIDDLE_NAME# #getUsers.LAST_NAME# </td>
						</tr>
						<tr>
							<td align="right">Reported Affiliation:</td>
							<td>#getUsers.AFFILIATION#</td>
						</tr>
						<tr>
							<td align="right">Reported Email:</td>
							<td>#getUsers.EMAIL#</td>
						</tr>
						<tr>
							<td align="right">Database User Status:</td>
							<td>
								<cfif isDbUser.account_status is "OPEN">
									Account open and active <a href="AdminUsers.cfm?username=#username#&action=lockUser">[ Lock Account ]</a>
								<cfelseif len(isDbUser.account_status) gt 0>
									#isDbUser.account_status#
									<cfif session.roles contains "global_admin">
										<a href="AdminUsers.cfm?action=unlockOracleAccount&username=#username#">unlock</a>
									<cfelse>
										Use the <a href="/contact.cfm">contact</a> link if you need this account unlocked.
									</cfif>
								<cfelseif hasInvite.allow is 1>
									Awaiting User Action
								<cfelse>
									<a href="AdminUsers.cfm?action=makeNewDbUser&username=#username#&user_id=#getUsers.user_id#">Invite as Operator</a>
									<span class="helpLink" id="_users">READ THIS FIRST!</span>
								</cfif>
							</td>
						</tr>
					</table>
				</td>
			</tr><tr>
				<td colspan="2">
					<ul>
						<li>Users must have both functional roles and access to collections to use Arctos</li>
						<li>All operators require the coldfusion_user role</li>
						<li>Give role "public" to everyone, just because Oracle is goofy</li>
						<li>Be very cautious in assigning access to shared information, such as agents and places</li>
						<li>Only members of the Arctos Advisory Committee or their designated representatives should have access to code tables, geography, and taxonomy</li>
						<li>
							<div class="importantNotification">
								<a href="Admin/user_roles.cfm">Read this before assigning roles to users</a>
							</div>
						</li>
					</ul>
				</td>
			<tr>
				<td valign="top">
					<table border>
						<tr>
							<td colspan="3">Roles <a href="AdminUsers.cfm?username=#username#&action=dbRole" class="infoLink">[ show roles ]</td>
						</tr>
						<tr class="newRec">
							<form name="ar" method="post" action="AdminUsers.cfm">
								<td>
									<input type="hidden" name="action" value="addRole" />
									<input type="hidden" name="username" value="#getUsers.username#" />
									<select name="role_name" size="1">
										<cfloop query="ctRoleName">
											<option value="#role_name#">#role_name#</option>
										</cfloop>
									</select>
								</td>
								<td>
									<input type="submit" value="Grant Role" class="savBtn">
								</td>
							</form>
						</tr>
						<cfloop query="roles">
							<tr>
								<td>#role_name#</td>
								<td>
									<a href="AdminUsers.cfm?action=remrole&role_name=#role_name#&username=#username#&user_id=#getUsers.user_id#">[ revoke ]</a>
								</td>
							</tr>
						</cfloop>
					</table>
				</td>
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
									<input type="submit" value="Grant Access" class="savBtn">
								</td>
							</tr>
						</form>
						<cfloop query="user_croles">
								<tr>
									<td>#role_name#</td>
									<td>
										<a href="AdminUsers.cfm?action=remrole&role_name=#role_name#&username=#username#&user_id=#getUsers.user_id#">[ revoke ]</a>
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
<cfif action is "lockUser">
	<cfoutput>
		<cfquery name="lock" datasource="uam_god">
			alter user #username# account lock
		</cfquery>
		The account for #username# is now locked. Contact a DBA to unlock it.
		<a href="AdminUsers.cfm?username=#username#&action=edit">Continue</a>
	</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif action is "adminSet">
	<cfoutput>
		<cfquery name="gpw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from temp_allow_cf_user where user_id=#user_id#
		</cfquery>
		<cflocation url="AdminUsers.cfm?Action=edit&username=#username#" addtoken="false">
	</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif action is "makeNewDbUser">
	<cfoutput>
		<!--- see if they have all the right stuff to be a user --->
		<cfquery name="getTheirEmail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfquery name="getMyEmail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		<cfquery name="getAgent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
			<cfquery name="gpw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into temp_allow_cf_user (user_id,allow,invited_by_email)
				values (#user_id#,1,'#getMyEmail.EMAIL#')
			</cfquery>
			<cfmail to="#getTheirEmail.EMAIL#" from="welcome@#Application.fromEmail#" subject="operator invitation" cc="#getMyEmail.EMAIL#,#Application.bugReportEmail#" type="html">
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
				#Application.bugReportEmail# if you believe you have received this message in error.
				<br>
				See <a href="http://dx.doi.org/10.7299/X75B02M5">http://dx.doi.org/10.7299/X75B02M5</a> for Arctos resources.
			</cfmail>
			An invitation has been sent. <a href="AdminUsers.cfm?Action=edit&username=#username#">continue</a>
		</cfif>
	</cfoutput>
</cfif>
<!---------------------------------------------------->
<cfif action is "dbRole">
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
<cfinclude template = "includes/_footer.cfm">