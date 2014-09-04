<cfinclude template = "/includes/_header.cfm">
<cfif application.version is not "test">
	no<cfabort>
</cfif>

<cfoutput>
<cfquery name="ctRoleName" datasource="uam_god">
	select 
		role_name 
	from 
		cf_ctuser_roles 
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
	<!----	
	<cfdump var=#ctRoleName#>

<cfdump var=#croles#>
---->		
Make a test account.
<form name="f" method="post" action="makeTestAccounts.cfm">
<input type="hidden" name="action" value="magic">
<label for="username">username (will be created as test_{whateverYouType}</label>
<input type="text" name="username" required>


<label for="password">password</label>
<input type="text" name="password" required>



<label for="firstname">firstname</label>
<input type="text" name="firstname" required>

<label for="lastname">lastname</label>
<input type="text" name="lastname" required>


<label for="email">email</label>
<input type="text" name="email" required>


<label for="userroles">userroles</label>


<select name="userroles" size="10" multiple required>
	<cfloop query="ctRoleName">
		<option value="#role_name#">#role_name#</option>
	</cfloop>
</select>
									
									
<label for="collections">collections</label>

	<select name="role_name" size="10" multiple required>
		<cfloop query="croles">
			
				<option value="#role_name#">#role_name#</option>
		</cfloop>
	</select>

<br>
<input type="submit">
</form>


<cfif action is 'magic'>
	<cftry>
		<cfquery name="die"  datasource="uam_god">
			delete from cf_user_data where user_id=(select user_id from cf_users where username='test_#username#')
		</cfquery>
		<cfcatch><br>no userdata to roll back</cfcatch>
	</cftry>
	
	<cfquery name="die"  datasource="uam_god">
		delete from cf_users where username='test_#username#'
	</cfquery>
	<cfquery name="an"  datasource="uam_god">
		select agent_id from agent_name where agent_name='test_#username#'
	</cfquery>
	<cfif len(an.agent_id) gt 0>
		<cfquery name="die"  datasource="uam_god">
			delete from agent_name where agent_id =#an.agent_id#
		</cfquery>
		<cfquery name="die"  datasource="uam_god">
			delete from agent where agent_id #an.agent_id#
		</cfquery>
	</cfif>
	<cftry>
		<cfquery name="die"  datasource="uam_god">
			drop user 'test_#username#')
		</cfquery>
		<cfcatch><br>no user to drop</cfcatch>
	</cftry>

	

	
	<cfdump var=#form#>
<cftransaction>
	<cfquery name="uid"  datasource="uam_god">
		select max(USER_ID) + 1 as x from cf_users
	</cfquery>
	<cfquery name="usr"  datasource="uam_god">
		insert into cf_users (
			USERNAME,
			PASSWORD,
			USER_ID,
			PW_CHANGE_DATE
		) values (
			'test_#username#',
			'#password#',
			'#uid.x#',
			sysdate
		)
	</cfquery>
	<cfquery name="usr2"  datasource="uam_god">
		insert into cf_user_data (
			USER_ID,
			FIRST_NAME,
			LAST_NAME,
			AFFILIATION,
			DOWNLOAD_FORMAT,
			ASK_FOR_FILENAME,
			EMAIL
		) values (
			'#uid.x#',
			'#firstname#',
			'#lastname#',
			'testing',
			'csv',
			1,
			'#email#'
		)
	</cfquery>
	<cfquery name="a"  datasource="uam_god">
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
	<cfquery name="an"  datasource="uam_god">
		insert into agent_name(
			AGENT_NAME_ID,
			AGENT_ID,
			AGENT_NAME_TYPE,
			AGENT_NAME
		) values (
			sq_agent_name_id.nextval,
			sq_agent_id.currval,
			'login',
			'test_#username#'
		)
	</cfquery>
	<cfquery name="an"  datasource="uam_god">
		create user test_#username# identified by "#password#"
	</cfquery>


	<cfloop list="#userroles#" index="i">
	<br>#i#
	
	<!----
			<cfquery name="r" datasource="uam_god">
				grant #i# to test_#username#
			</cfquery>
			---->

	</cfloop>
	
	<cfloop list="#collections#" index="i">
			<cfquery name="r" datasource="uam_god">
				grant #i# to test_#username#
			</cfquery>
			

	</cfloop>
</cftransaction>
	spiffy, made user - use your back button to do it again:
	<cfdump var=#form#>
	
	
	
</cfif>


</cfoutput>
<cfinclude template = "/includes/_footer.cfm">
