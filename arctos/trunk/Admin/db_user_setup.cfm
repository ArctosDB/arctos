<cfinclude template="/includes/_header.cfm">
<cfinclude template="/includes/functionLib.cfm">
<!-------------------->
<cfif #action# is "makeUser">
	<cfoutput>
			<cfquery name="c" datasource="#Application.uam_dbo#">
				select temp_allow_cf_user.user_id,allow from temp_allow_cf_user,cf_users where
				temp_allow_cf_user.user_id=cf_users.user_id and
				 username='#un#' and
				 password='#hash(pw)#'
			</cfquery>
			<cfif #len(c.user_id)# is 0 OR #c.allow# is not 1>
				Bad name or password.
				<cfabort>
			</cfif>
		<cfif passwordCheck(pw)>
				<cfif isnumeric(left(pw,1))>
					Passwords may not begin with an integer.
					<br />
					<a href="/ChangePassword.cfm">Change your password</a>
					<cfabort>
				</cfif>
				<cfquery name="makeUser" datasource="uam_god">
					create user #un# identified by "#pw#"
				</cfquery>
				<cfquery name="grantConn" datasource="uam_god">
					grant create session to #un#
				</cfquery>
				<cfquery name="makeUser" datasource="uam_god">
					update temp_allow_cf_user set allow=2 where user_id=#c.user_id#
				</cfquery>
				
			
			<cflocation url="/myArctos.cfm">
			
		<cfelse>
			Your password is not complex enough. It should:
			<ul>
				<li>Contain at least six characters</li>
				<li>Contain at least one numeric character</li>
				<li>Contain at least one letter OR</li>
				<li>Contain at least one non alpha-numeric character</li>
			</ul>
			<a href="/ChangePassword.cfm">Change your password</a>
		</cfif>
	</cfoutput>
</cfif>	
<!------------------------------------>
<cfif #action# is "nothing">
<cfif isdefined("unm") and len(#unm#) gt 0>
	<cfquery name="c" datasource="#Application.uam_dbo#">
		select temp_allow_cf_user.user_id,allow from temp_allow_cf_user,cf_users where
		temp_allow_cf_user.user_id=cf_users.user_id and
		 username='#unm#'
	</cfquery>
	<cfif #c.allow# is 0>
		bad you.
		<cfoutput>
		<br>
		#cgi.REMOTE_ADDR#
		</cfoutput>
		<cfabort>
	<cfelse>
		Good Authentication.
		<form name="getUserData" method="post" action="db_user_setup.cfm">
			<input type="hidden" name="action" value="makeUser">
			<label for="un">Enter your Username:</label>
			<input type="text" name="un" id="un">
			<label for="pw">Enter your password:</label>
			<input type="password" name="pw" id="pw">
			<br><input type="submit" value="Continue...">
		</form>
	</cfif>
<cfelse>
bad you.
<cfoutput>
<br>
#cgi.REMOTE_ADDR#
</cfoutput>
<cfabort>
</cfif>
</cfif>
<cfinclude template="/includes/_footer.cfm">
