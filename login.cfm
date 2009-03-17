<cfinclude template = "includes/_header.cfm">
<cfif isdefined("session.username") and len(#session.username#) gt 0 and #action# neq "signOut">
	<cflocation url="myArctos.cfm">
</cfif>
<span class="pageHelp">
	<a href="javascript:void(0);" 
		onClick="pageHelp('customize'); return false;"
		onMouseOver="self.status='Click for Customization help.';return true;"
		onmouseout="self.status='';return true;"><img src="/images/what.gif" border="0">
	</a>					
</span>
<!------------------------------------------------------------>
<!--- sign them out and start over --->

<!------------------------------------------------------------>
<cfif #action# is "signOut">

<!--- Clear anything they might have had hang around 	--->
	<cfset initSession()>
	you are logged out.
				<cflocation url="login.cfm">
				<!---

<cfdump var="#session#">
	---->
</cfif>
<!------------------------------------------------------------>
<cfif  #action# is "newUser">
	<!--- see if they selected a valid user name --->
	<cfquery name="uUser" datasource="cf_dbuser">
		select * from cf_users where username = '#username#'
	</cfquery>
	<cfset err="">
	<cfif len(#password#) is 0>
		<cfset err="Your password must be at least one character long.">
	</cfif>
	<cfquery name="dbausr" datasource="uam_god">
		select username from dba_users where upper(username) = '#ucase(username)#'
	</cfquery>
	<cfif len(dbausr.username) gt 0>
		<cfset err="That username is not available.">
	</cfif>
	<cfif len(#username#) is 0>
		<cfset err="Your user name must be at least one character long.">
	</cfif>	
	<cfif #uUser.recordcount# gt 0>
		<cfset err="That username is already in use.">
	</cfif>
	<!--- create their account --->
	<cfif len(err) gt 0>
		<cflocation url="login.cfm?username=#username#&badPW=true&err=#err#" Addtoken="false">
	</cfif>
	<cfquery name="nextUserID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(user_id) + 1 as nextid from cf_users
	</cfquery>
	<!--- handle collection-specific links to this page --->
	<cfoutput>
		<cfset sql = "INSERT INTO cf_users (user_id, username, password,PW_CHANGE_DATE,last_login) VALUES
			(#nextUserID.nextid#, '#username#', '#hash(password)#',sysdate,sysdate)">
	
	
		<cfquery name="newUser" datasource="cf_dbuser">
			#preservesinglequotes(sql)#
		</cfquery>
		
		<!--- and send them back to this form as a logged-in user --->
		<form name="siUser" id="siUser" method="post" action="login.cfm">
			<input type="hidden" name="action" value="signIn" />
			<input type="hidden" name="username" value="#username#" />
			<input type="hidden" name="password" value="#password#" />
		</form>
		
		<script>
			document.getElementById('siUser').submit();
		</script>
		</cfoutput>
		<!---
		<cflocation url="login.cfm">
		--->
</cfif>
<!------------------------------------------------------------>

<CFIF  #action# is "signIn">
	<cfoutput>
	<cfset initSession('#username#','#password#')>
	<cfif session.roles contains "coldfusion_user">
		<!--- 
			make sure they have a valid email address 
			If not, let them in for now, but set variable for use in annoying
			them in _header.cfm
		--->
		<cfquery name="getUserData" datasource="#application.web_user#">
			SELECT   
				cf_users.user_id,
				first_name,
		        middle_name,
		        last_name,
		        affiliation,
				email
			FROM 
				cf_user_data,
				cf_users
			WHERE
				cf_users.user_id = cf_user_data.user_id (+) AND
				username = '#session.username#'
		</cfquery>
		<cfif len(getUserData.email) is 0>
			<cfset session.needEmailAddr=1>
		</cfif>
	</cfif>
	<!--- redirect to personal home --->
	<cfif not isdefined("gotopage") or len(#gotopage#) is 0>
		<cfif isdefined("cgi.HTTP_REFERER") and left(cgi.HTTP_REFERER,(len(application.serverRootUrl))) is application.serverRootUrl>
			<cfset gotopage=replace(cgi.HTTP_REFERER,application.serverRootUrl,'')>
			<cfset junk="CFID,CFTOKEN">
			<cfloop list="#gotopage#" index="e" delimiters="?&">
				<cfloop list="#junk#" index="j">
					<cfif left(e,len(j)) is j>
						<cfset rurl=replace(gotopage,e,'','all')>
					</cfif>
				</cfloop>
			</cfloop>
			<cfset t=1>
			<cfset rurl=replace(gotopage,"?&","?","all")>
			<cfset rurl=replace(gotopage,"&&","&","all")>
			<cfset nogo="login.cfm,errors/">
			<cfloop list="#nogo#" index="n">
				<cfif gotopage contains n>
					<cfset gotopage = "/SpecimenSearch.cfm">
				</cfif>
			</cfloop>
		<cfelse>
			<cfset gotopage = "/SpecimenSearch.cfm">
		</cfif>
	</cfif>
	<cflocation url="#gotopage#" addtoken="no">
	</cfoutput>
</cfif>
<!------------------------------------------------------------>

<cfif #action# is "nothing">
<cfset title="Log In or Create Account">

<!--- kick them over here anytime they come in from anywhere if username are not set --->

	<table cellpadding="0" cellspacing="0" width="600">
		<tr>
			<td>
			 <b><font size="+1">Customize Arctos</font></b>			    
			
		<p>
			Logging in enables you to turn on, turn off, or otherwise customize many features of 
			this database. To create an account and log in, simply supply a username and 
			password here and click Create Account.
		</p>	
	
	<form action="login.cfm" method="post" name="signIn">
	<input name="action" value="signIn" type="hidden">
<table>
	<tr>
		<td>
		<cfoutput>
			<table>
				<tr>
					<td>Username:</td>
					<cfparam name="username" default="">
					<td><input name="username" type="text" tabindex="1" value="#username#" id="username"></td>
					
				</tr>
				
				<tr>
					<td valign="top">Password:</td>
					<td valign="top"><input name="password" type="password" tabindex="2" value="" id="password">
					<cfif isdefined("badPW") and #badPW# is "true">
						<cfif not isdefined("err") or len(err) is 0>
							<cfset err="Your username or password was not recognized. Please try again.">
						</cfif>
						<div style="background-color:##FF0000; font-size:smaller; font-style:italic;">
							#err#
							<script>
								var un  = document.getElementById('username');
								var ps = document.getElementById('password');
											ps.value='some big long string';
											ps.value='';
											ps.style.backgroundColor='##FF0000';
											un.style.backgroundColor='##FF0000';
											un.select();
											un.focus();
							</script>
						</div>
					</cfif>
					</td>
					
				</tr>
			</table>
			</cfoutput>
		</td>
		<td>
			<table style="border-left-style:solid; border-left-width:thin " cellpadding="0" cellspacing="0">
				<tr>
					<td nowrap>
					&nbsp;&nbsp;<input type="submit" value="Sign In" class="savBtn"
		   onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'"
		   onClick="signIn.action.value='signIn';submit();" tabindex="3">
		            <font size="-1">to your previously set preferences</font>		  </td>
		  </tr>
		  
		  <tr>
		  <td>&nbsp;&nbsp;OR, enter a username and password and</td>
		  </tr>
		   <tr>
		  <td nowrap>
		  <script>
		  		function isInfo() {
					var uname = document.signIn.username.value;
					var pword = document.signIn.password.value;
					if (uname.length == 0 || pword.length == 0) {
						alert('Enter a username and a password in this form to create an account.');
						return false;
						}
						else {
						document.signIn.action.value='newUser';
						document.signIn.submit();
						}
					}
					// get rid of password default
					
		  </script>
		   &nbsp;&nbsp;<input type="button" value="Create an Account" class="insBtn"
		   				onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'"
		   				onClick="isInfo();" tabindex="4">
		   <font size="-1">so you can set and save preferences.</font>					</td>
				</tr>
				
			</table>
		</td>
	</tr>
</table>

	
	</form>
	
	<hr>
	<a href="login.cfm?action=lostPass">Lost your password?</a>
	
	<P>You can explore Arctos using basic options without signing in.
	
		  </td>
		</tr>
	
	</table>

</cfif>
<!-------------------------------------------------------------------------------------->
<cfif #action# is "lostPass">
	<cflocation url="ChangePassword.cfm">
</cfif>
<!-------------------------------------------------------------------------------------->

<!------------------------------------------------------------>

<cfinclude template = "includes/_footer.cfm">
