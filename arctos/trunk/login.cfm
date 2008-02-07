<cfinclude template = "includes/_header.cfm">
<cfif isdefined("client.username") and len(#client.username#) gt 0 and #action# neq "signOut">
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
<!--- Clear anything they might have had hang around --->
	<cfloop collection="#session#" item="i">
		<cfset temp = StructDelete(session,i)>
	</cfloop>
	<cfloop collection="#client#" item="i">
		<cfset temp = StructDelete(client,i)>
	</cfloop>
	<cflogout>
	<!---- defeat goofy BUG that puts 500 NULL at the bottom of every page --->
	<cfset client.HitCount=0>
	<cflocation url="login.cfm">
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
			<cfset sql = "INSERT INTO cf_users (user_id, username, password,exclusive_collection_id,PW_CHANGE_DATE) VALUES
			(#nextUserID.nextid#, '#username#', '#hash(password)#',#exclusive_collection_id#),sysdate">
			<cfset client.exclusive_collection_id = "#exclusive_collection_id#">
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
		select * from cf_users where username = '#form.username#' and password='#hash(form.password)#'
	</cfquery>
	<cfif getPrefs.recordcount is 0>
		<!--- flush whatever they had & send them back--->
		<cfset client.username = "">
		<cfset client.epw = "">
		<cflocation url="login.cfm?badPW=true&username=#username#">
	</cfif>
<!--- they made it this far, they are valid users. assign some client stuff to valid users --->
	<cfset client.username = "#getPrefs.username#">
	<cfset client.epw = encrypt(password,cfid)>
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
	
	<cfset client.roles = ''>
	<cfset client.roles = valuelist(dbrole.role_name)>
<!--- redirect to personal home --->
<cfinclude template="/includes/setPrefs.cfm">
<!--- don't let them log in without a password change --->
<cfset pwtime =  round(now() - getPrefs.pw_change_date)>
<cfset pwage = Application.max_pw_age - pwtime>
<cfif pwage lte 0>
	<cfset client.force_password_change = "yes">
	<cflocation url="ChangePassword.cfm">
</cfif>
<cfquery name="logLog" datasource="#Application.web_user#">
	update cf_users set last_login = sysdate where username = '#client.username#'
</cfquery>
		<cfif not isdefined("gotopage") or len(#gotopage#) is 0>
			<cfset gotopage = "myArctos.cfm">
		</cfif>
		<cfoutput>
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
<cfset title="Find Password">
Passwords are stored in an encrypted format and cannot be recovered. 
<br>If you have saved your email address in your profile, enter it here to reset your password. 
<br>If you have not saved your email address, please submit a bug report to that effect and we will reset your password for you.
<form name="pw" method="post" action="login.cfm?action=findPass">
	Username:&nbsp;<input type="text" name="username" />
	Email Address:&nbsp;<input type="text" name="email">
	 <input type="submit" value="Request Password" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
</form>
</cfif>
<!-------------------------------------------------------------------------------------->
<cfif #action# is "findPass">
<cfoutput>
	<cfquery name="isGoodEmail" datasource="#Application.web_user#">
		select cf_user_data.user_id, email,username from cf_user_data,cf_users
		 where cf_user_data.user_id = cf_users.user_id and
		 email = '#email#' and username= '#username#'
	</cfquery>
	<cfif #isGoodEmail.recordcount# neq 1>
		Sorry, that email wasn't found or your username isn't "#username#."
		<cfabort>
	  <cfelse>
			<cfset charList = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,z,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,1,2,3,4,5,6,7,8,9,0">
			<cfset newPass = "">
			<cfloop index="i" from="1" to ="10">
				<cfset thisCharNum = RandRange(1,listlen(charList))>
				<cfset thisChar = ListGetAt(charList,#thisCharNum#)>
				<cfset newPass = "#newPass##thisChar#">
			</cfloop>
			<cfquery name="setNewPass" datasource="#Application.uam_dbo#">
				UPDATE cf_users SET password = '#hash(newPass)#'
				where user_id = #isGoodEmail.user_id#
			</cfquery>
			
			<cfmail to="#email#" subject="Arctos password" from="LostFound@#Application.fromEmail#" type="text">
				Your Arctos username/password is #username#/#newPass#. Log in, then change it at:
			
				#Application.ServerRootUrl#/ChangePassword.cfm
				
				or from your Preferences.
				
				If you did not request this change, please email fndlm@uaf.edu immediately.
			</cfmail>
		An email containing your new password has been sent.
	</cfif>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------->
<!------------------------------------------------------------>

<cfinclude template = "includes/_footer.cfm">
