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
<cfif #action# is "signOut">
<!--- Clear anything they might have had hang around 	--->
	<cfloop collection="#session#" item="i">
		<cfset session[i]="">
	</cfloop>
	<cflogout>
	<fset session.roles="public">
	<cflocation url="login.cfm">	<!---
<cfdump var="#session#">
	---->
</cfif>
<!------------------------------------------------------------>

<cfif  #action# is "newUser">
	<!--- see if they selected a valid user name --->
	<cfquery name="uUser" datasource="#Application.uam_dbo#">
		select * from cf_users where username = '#username#'
	</cfquery>
	<cfif len(#password#) is 0>
			Your password must be at least one character long. 
			Please click <a href="login.cfm">here</a> or use your browser's back button and select another.
			<p>
				To create an account, just enter a username and password in the previous form and click Create Account.
			</p>
		<cfabort>
	</cfif>
	<cfif len(#username#) is 0>
			Your user name must be at least one character long. 
			Please click <a href="login.cfm">here</a> or use your browser's back button and select another.
		<cfabort>
	</cfif>	
	<cfif #uUser.recordcount# gt 0>
		That username is already in use. Please click <a href="login.cfm">here</a> or use your browser's back button and select another user name.
		<cfabort>
	</cfif>
	<!--- create their account --->
	<cfquery name="nextUserID" datasource="#Application.web_user#">
		select max(user_id) + 1 as nextid from cf_users
	</cfquery>
	<!--- handle collection-specific links to this page --->
	<cfoutput>
		<cfif len(#exclusive_collection_id#) gt 0>
			<cfset sql = "INSERT INTO cf_users (user_id, username, password,exclusive_collection_id,PW_CHANGE_DATE,last_login) VALUES
			(#nextUserID.nextid#, '#username#', '#hash(password)#',#exclusive_collection_id#,sysdate,sysdate)">
			<cfset session.exclusive_collection_id = "#exclusive_collection_id#">
		<cfelse>
			<cfset sql = "INSERT INTO cf_users (user_id, username, password,PW_CHANGE_DATE,last_login) VALUES
			(#nextUserID.nextid#, '#username#', '#hash(password)#',sysdate,sysdate)">
		</cfif>
	
	
		<cfquery name="newUser" datasource="#Application.web_user#">
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
<!---- start by making sure they are a registered user --->	
	<cfquery name="getPrefs" datasource="#Application.web_user#">
		select * from cf_users where username = '#username#' and password='#hash(password)#'
	</cfquery>
	<cfif getPrefs.recordcount is 0>
		<!--- flush whatever they had & send them back--->
		<cfset session.username = "">
		<cfset session.epw = "">
        
       	<cflocation url="login.cfm?badPW=true&username=#username#">

	</cfif>
<!--- they made it this far, they are valid users. assign some client stuff to valid users --->
	<cfset session.username = "#getPrefs.username#">
	<cfset session.epw = encrypt(password,cfid)>
	<!--- get their DB roles --->

	<cfquery name="dbrole" datasource="uam_god">
		 select upper(granted_role) role_name
         	from 
         dba_role_privs,
         cf_ctuser_roles
         	where
         upper(dba_role_privs.granted_role) = upper(cf_ctuser_roles.role_name) and
         upper(grantee) = '#ucase(getPrefs.username)#'
	</cfquery>
	
	<cfset session.roles = ''>
	<cfset session.roles = valuelist(dbrole.role_name)>
	<cfset session.roles=listappend(session.roles,"public")>
	<cfif session.roles contains "coldfusion_user">
		<!--- see if their password is valid --->
		<cftry>
			<cfquery name="ckUserName" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,cfid)#">
				select agent_id from agent_name where agent_name='#session.username#' and
				agent_name_type='login'
			</cfquery>
			<cfcatch>
				<div class="error">
					Your Oracle login has issues. Contact a DBA.
				</div>
				<cfabort>
			</cfcatch>
		</cftry>
		<!--- make sure they have a good agent name --->
		<cfif len(ckUserName.agent_id) is 0>
			<div class="error">
				You must have an agent_name of type login that matches your Arctos username.
			</div>
			<cfabort>
		</cfif>
		<cfoutput>
		---ckUserName.agent_id---
		</cfoutput>
		<!--- 
			make sure they have a valid email address 
			If not, let them in for now, but set variable for use in annoying
			them in _header.cfm
		--->
		<cfquery name="getUserData" datasource="#Application.web_user#">
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
<cfinclude template="/includes/setPrefs.cfm">
<!--- don't let them log in without a password change --->
<cfset pwtime =  round(now() - getPrefs.pw_change_date)>
<cfset pwage = Application.max_pw_age - pwtime>
<cfif pwage lte 0>
	<cfset session.force_password_change = "yes">
	<cflocation url="ChangePassword.cfm">
</cfif>
<cfquery name="logLog" datasource="#Application.web_user#">
	update cf_users set last_login = sysdate where username = '#session.username#'
</cfquery>
		<cfif not isdefined("gotopage") or len(#gotopage#) is 0>
			<cfset gotopage = "myArctos.cfm">
		</cfif>
		<cfoutput>
			<!---
			<cflocation url="#gotopage#" addtoken="no">
			---->
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
						<div style="background-color:##FF0000; font-size:smaller; font-style:italic;">
							Your username or password was not recognized. Please try again.
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
