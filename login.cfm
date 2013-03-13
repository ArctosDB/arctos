<cfinclude template = "/includes/_header.cfm">
<cfoutput>
	#action#
</cfoutput>

<cfif isdefined("session.username") and len(session.username) gt 0 and action neq "signOut">
	<cflocation url="myArctos.cfm" addtoken="false">
</cfif>
<!------------------------------------------------------------>
<cfif action is "signOut">
	<cfset initSession()>
	<cflocation url="login.cfm" addtoken="false">
</cfif>
<!------------------------------------------------------------>
<cfif  action is "newUser">
	<cfquery name="uUser" datasource="cf_dbuser">
		select * from cf_users where username = '#username#'
	</cfquery>
	<cfset err="">
	<cfif len(password) is 0>
		<cfset err="Your password must be at least one character long.">
	</cfif>
	<cfquery name="dbausr" datasource="uam_god">
		select username from dba_users where upper(username) = '#ucase(username)#'
	</cfquery>
	<cfif len(dbausr.username) gt 0>
		<cfset err="That username is not available.">
	</cfif>
	<cfif len(username) is 0>
		<cfset err="Your user name must be at least one character long.">
	</cfif>
	<cfif uUser.recordcount gt 0>
		<cfset err="That username is already in use.">
	</cfif>
	<!--- create their account --->
	<cfif len(err) gt 0>
		<cflocation url="login.cfm?username=#username#&badPW=true&err=#err#" addtoken="false">
	</cfif>
	<cfquery name="nextUserID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select max(user_id) + 1 as nextid from cf_users
	</cfquery>
	<cfoutput>
		<cfquery name="newUser" datasource="cf_dbuser">
			INSERT INTO cf_users (
				user_id,
				username,
				password,
				PW_CHANGE_DATE,
				last_login
			) VALUES (
				#nextUserID.nextid#,
				'#username#',
				'#hash(password)#',
				sysdate,
				sysdate
			)
		</cfquery>
		<cflocation url="/login.cfm?action=signIn&username=#username#&password=#password#" addtoken="false">
	</cfoutput>
</cfif>
<!------------------------------------------------------------>
<CFIF  action is "signIn">
	<cfoutput>
		<cfset initSession('#username#','#password#')>
		<cfif len(session.username) is 0>
			<cfset u="/login.cfm?badPW=true&username=#username#">
			<cfif isdefined("gotopage") and len(gotopage) gt 0>
				<cfset u=u & '&gotopage=#gotopage#'>
			</cfif>
			<cflocation url="#u#" addtoken="false">
		</cfif>
			gotopage: #gotopage#
		<cfif (not isdefined("gotopage") or len(gotopage) is 0) and len(request.rdurl) gt 0>
			<cfset gotopage=request.rdurl>
		</cfif>
		<cfset junk="session.sessionKey,badPW,username">
		<cfloop list="#gotopage#" index="e" delimiters="?&">
			<br>e: #e#
			<cfloop list="#junk#" index="j" delimiters=",">
				<br>j: #j#
				<cfif left(e,len(j)) is j>
					<br>it is
					<cfset gotopage=replace(gotopage,e,'','all')>
				</cfif>
			</cfloop>
		</cfloop>
		<cfset t=1>
		<cfset gotopage=replace(gotopage,"?&","?","all")>
		<cfset gotopage=replace(gotopage,"&&","&","all")>
		<cfset nogo="login.cfm,errors/">
		<cfloop list="#nogo#" index="n">
			<cfif gotopage contains n>
				<cfset gotopage = "/SpecimenSearch.cfm">
			</cfif>
		</cfloop>
		<cfif trim(gotopage) is "&" or trim(gotopage) is "=">
			<cfset gotopage = "/SpecimenSearch.cfm">
		</cfif>
		<cfif len(gotopage) is 0>
			<cfset gotopage = "/SpecimenSearch.cfm">
		</cfif>


			<p>
			after adjust: gotopage: #gotopage#
					</p>
			<cfabort>


		<cfif session.roles contains "coldfusion_user">
			<cfquery name="getUserData" datasource="cf_dbuser">
				SELECT
					cf_users.user_id,
					first_name,
			        middle_name,
			        last_name,
			        affiliation,
					email,
					PW_CHANGE_DATE
				FROM
					cf_user_data,
					cf_users
				WHERE
					cf_users.user_id = cf_user_data.user_id (+) AND
					username = '#session.username#'
			</cfquery>
			<cfset pwtime =  round(now() - getUserData.pw_change_date)>
			<cfset pwage = Application.max_pw_age - pwtime>
			<cfif pwage lte 7>
				<div style="text-align:center;color:red;font-weight:bold;">
					Your password expires in #pwage# days
					<br>You may <a href="/ChangePassword.cfm">change it now</a>
				</div>
				<a href="#gotopage#">Continue to #gotopage#</a>
			<cfelse>
				<cflocation url="#gotopage#" addtoken="no">
			</cfif>
			<cfif len(getUserData.email) is 0>
				<cfset session.needEmailAddr=1>
			</cfif>
		<cfelse>
			<cflocation url="#gotopage#" addtoken="no">
		</cfif>
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
	<form action="login.cfm" method="post" name="signIn">
		<input name="action" value="signIn" type="hidden">
		<input name="gotopage" value="#gotopage#" type="hidden">
		<label for="username">Username</label>
		<input name="username" type="text" tabindex="1" value="#username#" id="username">
		<label for="password">Password</label>
		<input name="password" type="password" tabindex="2" value="" id="password">
		<cfif isdefined("badPW") and badPW is true>
			<cfif not isdefined("err") or len(err) is 0>
				<cfset err="Your username or password was not recognized. Please try again.">
			</cfif>
			<span style="background-color:##FF0000; font-size:smaller; font-style:italic; margin:.5em;padding:.5em;">
				#err#
				<script>
					$('##username').css('backgroundColor','red');
					$('##password').val('').css('backgroundColor','red').select().focus();
				</script>
			</span>
		</cfif>
		<br>
		<input type="submit" value="Sign In" class="savBtn" onClick="signIn.action.value='signIn';submit();" tabindex="3">
		&nbsp;or&nbsp;<input type="button" value="Create an Account" class="insBtn" onClick="isInfo();" tabindex="4">
	</form>
	<p>
		<a href="/ChangePassword.cfm">Lost your password?</a> If you created a profile with an email address,
		we can send it to you. You can also just create a new account.
	</p>
	<p>
		You can explore Arctos using basic options without signing in.
	</p>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------->
<cfif action is "lostPass">
	<cflocation url="/ChangePassword.cfm" addtoken="false">
</cfif>
<!-------------------------------------------------------------------------------------->
<cfinclude template = "includes/_footer.cfm">