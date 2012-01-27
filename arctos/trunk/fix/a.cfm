<cfinclude template = "/includes/_header.cfm">
<cfif action is "signIn">
	<cfoutput>
		<br>your clear-text password is #password#
		<br>Your hashed password is #hash(password)#
		<br>Your stored hash is 
		<cfquery name="p" datasource="uam_god">
			select password from cf_users where username='#username#'
		</cfquery>
		#p.password#
		<br>trying to connect to Oracle....
		<cftry>
			<cfquery name="getDump" datasource="user_login" username="#username#" password="#password#">
				select 'pass' s from dual
			</cfquery>
			pass!
		<cfcatch>
			fail
			<cfdump var=#cfcatch#>
		</cfcatch>
		</cftry>
	</cfoutput>
</cfif>
<!------------------------------------------------------------>
<cfif action is "nothing">
<script>
	function isInfo() {
		var uname = document.signIn.username.value;
		var pword = document.signIn.password.value;
		if (uname.length == 0 || pword.length == 0) {
			alert('Enter a username and a password in this form to create an account.');
			return false;
		} else {
			document.signIn.action.value='newUser';
			document.signIn.submit();
		}
	}	
</script>
<cfoutput>
	<cfparam name="username" default="">
	<cfset title="Log In or Create Account">
	<p><strong>Log In or Create an Account</strong></p>
	<p>
		Logging in enables you to turn on, turn off, or otherwise customize many features of 
		this database. To create an account and log in, simply supply a username and 
		password here and click Create Account.
	</p>	
	<cfif not isdefined("gotopage")>
		<cfset gotopage=''>
	</cfif>
	<form action="a.cfm" method="post" name="signIn">
		<input name="action" value="signIn" type="hidden">
		<label for="username">Username</label>
		<input name="username" type="text" tabindex="1" value="#username#" id="username">
		<label for="password">Password</label>
		<input name="password" type="password" tabindex="2" value="" id="password">
		
		<br>
		<input type="submit" value="Check" class="savBtn" onClick="signIn.action.value='signIn';submit();" tabindex="3">
	</form>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------->
<cfinclude template = "/includes/_footer.cfm">