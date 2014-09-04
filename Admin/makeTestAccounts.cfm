<cfinclude template = "/includes/_header.cfm">
<cfif application.version is not "test">
	no<cfabort>
</cfif>
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
				upper(dba_role_privs.granted_role) = upper(cf_ctuser_roles.role_name)
		) 
	and upper(role_name) IN (
		select 
				upper(granted_role) role_name
			from 
				dba_role_privs,
				cf_ctuser_roles
			where
				upper(dba_role_privs.granted_role) = upper(cf_ctuser_roles.role_name) 
		)	
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
		
			
Make a test account.
<form name="f" method="post" action="makeTestAccounts.cfm">
<input type="hidden" name="action" value="magic">
<label for="username">username</label>
<input type="text" name="username" required>


<label for="password">password</label>
<input type="text" name="password" required>



<label for="firstname">firstname</label>
<input type="text" name="firstname" required>

<label for="lastname">lastname</label>
<input type="text" name="lastname" required>


<label for="email">email</label>
<input type="text" name="email" required>


<label for="roles">roles</label>


<select name="roles" size="1" required>
	<cfloop query="ctRoleName">
		<option value="#role_name#">#role_name#</option>
	</cfloop>
</select>
									
									
<label for="collections">collections</label>

	<select name="role_name" size="1" required>
		<cfloop query="croles">
			
				<option value="#role_name#">#role_name#</option>
		</cfloop>
	</select>

<br>
<input type="submit">
</form>


<cfif action is 'magic'>


<cftransaction>
	<cfquery name="uid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select max(USER_ID) + 1  uid from cf_users
	</cfquery>
	<cfquery name="usr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into cf_users (
			USERNAME,
			PASSWORD,
			USER_ID,
			PW_CHANGE_DATE
		) values (
			'#username#',
			'#password#',
			'#uid.uid#',
			sysdate
		)
	</cfquery>
	<cfquery name="usr2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into cf_user_data (
			USER_ID,
			FIRST_NAME,
			LAST_NAME,
			AFFILIATION,
			DOWNLOAD_FORMAT,
			ASK_FOR_FILENAME,
			EMAIL
		) values (
			'#uid.uid#',
			'#firstname#',
			'#lastname#',
			'testing',
			'csv',
			1,
			'#email#'
		)
	</cfquery>
	<cfquery name="a" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into agent (
			AGENT_ID,
			AGENT_TYPE,
			PREFERRED_AGENT_NAME
		) values (
			sq_agent_id.nextval,
			'person',
			'#firstname# #lastname#'
		)
	</cfquery>
	<cfquery name="an" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into agent_name(
			AGENT_NAME_ID,
			AGENT_ID,
			AGENT_NAME_TYPE,
			AGENT_NAME
		) values (
			sq_agent_name_id.nextval,
			sq_agent_id.currval,
			'login',
			'#username#'
		)
	</cfquery>
	<cfquery name="an" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		create user #username# identified by "#password#"
	</cfquery>


	<cfloop list="#roles#" index="i">
			<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				grant #i# to #username#
			</cfquery>
			

	</cfloop>
	
	<cfloop list="#collections#" index="i">
			<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				grant #i# to #username#
			</cfquery>
			

	</cfloop>
</cftransaction>
	spiffy, made user - use your back button to do it again:
	<cfdump var=#form#>
	
	
	
</cfif>
<cfinclude template = "/includes/_footer.cfm">
