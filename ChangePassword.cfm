<cfinclude template = "includes/_header.cfm">
<!---- this is an internal use page and needs a (light) security wrapper --->
<cfif len(#client.username#) lt 1>
	You must log in first.
	<cfabort>
</cfif>

<cfset title = "Change Password">
<cfif not isdefined("URL.action")>
	<cfset url.action = "set">
</cfif>

<cfoutput>
	<cfquery name="pwExp" datasource="#Application.web_user#">
		select pw_change_date from cf_users where username = '#client.username#'
	</cfquery>
	<cfset pwtime =  round(now() - pwExp.pw_change_date)>
	<cfset pwage = Application.max_pw_age - pwtime>

	
<cfif #client.username# is "guest">
	Guests are not allowed to change passwords.<cfabort>
</cfif>
<table><tr><td>
You are logged in as #client.username#. You must change your password every #Application.max_pw_age# days. 
	Your password is #pwtime# days old.
 <form action="ChangePassword.cfm?action=update" method="post">
	<table>
		<tr>
			<td align="right">Old password: </td>
			<td><input name="oldpassword" type="password"></td>
		</tr>
		<tr>
			<td align="right">New Password: </td>
			<td><input name="newpassword" type="password"></td>
		</tr>
		<tr>
			<td align="right">Retype New Password: </td>
			<td><input name="newpassword2" type="password"></td>
		</tr>
		<tr>
			<td align="center" colspan="2"> <input type="submit" value="Save Password Change" class="savBtn"
   onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">	</td>
			
		</tr>
	</table>
	</form>
	</td>
	<td>
	Lost your password? Passwords are stored in an encrypted format and cannot be recovered. 
<br>If you have saved your email address in your profile, enter it here to reset your password. 
<br>If you have not saved your email address, please submit a bug report to that effect and we will reset your password for you.

	<form name="pw" method="post" action="?action=findPass">
	Username:&nbsp;<input type="text" name="username" />
	Email Address:&nbsp;<input type="text" name="email">
	 <input type="submit" value="Request Password" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
</form>
</td></tr></table>
</cfoutput>
<cfif #url.action# is "update">
	<cfoutput>
	<cfquery name="getPass" datasource="#Application.uam_dbo#">
		select password from cf_users where username = '#client.username#'
	</cfquery>
	<cfif hash(oldpassword) is not getpass.password>
		<span style="background-color:red;">
			Incorrect password.
		</span>
		<cfabort>
	<cfelseif getpass.password is hash(newpassword)>
		<span style="background-color:red;">
			You must pick a new password.
		</span>		
		<cfabort>
	<cfelseif #newpassword# neq #newpassword2#>
		<span style="background-color:red;">
			New passwords do not match.
		</span>
		<cfabort>			
	</cfif>
	<!--- Passwords check out for public users, now see if they're a database user --->
	<cfquery name="isDb" datasource="uam_god">
		select * from all_users where
		username='#ucase(client.username)#'
	</cfquery>
	<cfif #isDb.recordcount# is 0>
		<cfquery name="setPass" datasource="#Application.uam_dbo#">
			UPDATE cf_users SET password = '#hash(newpassword)#'
			WHERE username = '#client.username#'
		</cfquery>
	<cfelse>
		<cfinclude template="/includes/functionLib.cfm">
		<cfif not passwordCheck(newpassword)>
			<span style="background-color:red;">
			Your password is not complex enough, or contains special characters not allowed by Oracle.
				It should:
				<ul>
					<li>Contain at least six characters</li>
					<li>Contain at least one numeric character</li>
					<li>Contain at least one letter OR</li>
					<li>Contain at least one non alpha-numeric character</li>
					<li>Not contain shift-number characters (e.g., !,@,##,$,%)</li>
					<li>Not contain CTRL characters</li>
					<li>Begin with an alpha (A-Z) character</li>
				</ul>
			</span>
			<cfabort>
		<cfelse>
			<cfquery name="dbUser" datasource="uam_god">
				alter user #client.username# identified by #newpassword#
			</cfquery>
			<cfquery name="setPass" datasource="#Application.uam_dbo#">
				UPDATE cf_users SET password = '#hash(newpassword)#'
				WHERE username = '#client.username#'
			</cfquery>
			<cfset client.epw = encrypt(newpassword,cfid)>
		</cfif>
	</cfif>	
	Your password has successfully been changed.
	<cfset client.password = #hash(newpassword)#>
	<cfset client.force_password_change = "">
	You will be redirected soon, or you may use the menu above now.	
	<script>
		setTimeout("go_now()",5000);
		function go_now () {
			document.location='#Application.ServerRootUrl#/myArctos.cfm';
			//alert('go');
		}
	</script>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------->
<cfif #action# is "findPass">
<cfoutput>
	<cfquery name="isGoodEmail" datasource="#Application.web_user#">
		select cf_user_data.user_id, email,username from cf_user_data,cf_users
		 where cf_user_data.user_id = cf_users.user_id and
		 email = '#email#' and username= '#username#'
	</cfquery>
	<cfif #isGoodEmail.recordcount# neq 1>
		Sorry, that email wasn't found with your username.
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
<cfinclude template = "includes/_footer.cfm">

