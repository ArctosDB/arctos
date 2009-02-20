<cfinclude template = "includes/_header.cfm">
<!---------------------------------------------------------------------------------->
<script>
	function orapwCheck(p,u) {
		var regExp = /^[A-Za-z0-9!$%&_?(\-)<>=/:;*\.]$/;
		var minLen=6;
		var msg='Password is acceptable';
		var elem=document.getElementById('pwstatus');
		var clas='goodPW';
		if (p.indexOf(u) > -1) {
			msg='Password may not contain your username.';
			clas='badPW';
		}
		if (p.length<minLen || p.length>30) {
			msg='Password must be between ' + minLen + ' and 30 characters.';
			clas='badPW';
		}
		if (!p.match(/[a-zA-Z]/)) {
			msg='Password must contain at least one letter.'
			clas='badPW';
		}
		if (!p.match(/\d+/)) {
			msg='Password must contain at least one number.'
			clas='badPW';
		}
		if (!p.match(/[!,$,%,&,*,?,_,-,(,),<,>,=,/,:,;,.]/) ) {
			msg='Password must contain at least one of: !,$,%,&,*,?,_,-,(,),<,>,=,/,:,;.';
			clas='badPW';
		}
		for(var i = 0; i < p.length; i++) {
			if (!p.charAt(i).match(regExp)) {
				msg='Password may contain only A-Z, a-z, 0-9, and !$%&()`*+,-/:;<=>?_.';
				clas='badPW';
			}
		}
		elem.innerHTML=msg;
		elem.className=clas;
	}
	function pwc(p){
		DWREngine._execute(_catalog_func, null, 'changeAttDetr', p, success_upwc);
	}
	function success_upwc(r) {
		alert(r);
	}
</script>
<cfif #action# is "nothing">
    <cfset title = "Change Password">
    <cfif len(#session.username#) is 0>
        <cflocation url="ChangePassword.cfm?action=lostPass" addtoken="false">
    </cfif>
    <cfoutput>
	 	<cfquery name="pwExp" datasource="uam_god">
			select pw_change_date from cf_users where username = '#session.username#'
		</cfquery>
		<cfset pwtime =  round(now() - pwExp.pw_change_date)>
		<cfset pwage = Application.max_pw_age - pwtime>
		<cfif #session.username# is "guest">
			Guests are not allowed to change passwords.<cfabort>
		</cfif>
	    You are logged in as #session.username#. 
	    <br>Operators must change password every #Application.max_pw_age# days. 
	    <br>Your password is #pwtime# days old.
	    <cfquery name="isDb" datasource="uam_god">
			select
			(select count(*) c from all_users where
			username='#ucase(session.username)#')
			+
			(select count(*) C from temp_allow_cf_user,
			cf_users where temp_allow_cf_user.user_id = cf_users.user_id and cf_users.username='#session.username#')
			cnt
			from dual
		</cfquery>
		<cfif #isDb.cnt# gt 0>
			<br>Password rules:
			<ul>
				<li>At least six characters</li>
				<li>May not contain some special characters</li>
				<li>May not contain your username</li>
				<li>Must contain at least
					<ul>
						<li>One letter</li>
						<li>One number</li>
						<li>One special character</li>
					</ul>
				</li>
			</ul>
		</cfif>	
		<form action="ChangePassword.cfm" method="post">
	        <input type="hidden" name="action" value="update">
			<label for="oldpassword">Old password</label>
	        <input name="oldpassword" id="oldpassword" type="password">
			<label for="newpassword">New password</label>
	        <input name="newpassword" id="newpassword" type="password"
	        		<cfif #isDb.cnt# gt 0>
						onkeyup="pwc(this.value)"
					</cfif>	>
	        <span id="pwstatus"></span>
			<label for="newpassword2">Retype new password</label>
	        <input name="newpassword2" id="newpassword2" type="password">
			<br>
	        <input type="submit" value="Save Password Change" class="savBtn">
	    </form>
	</cfoutput>
</cfif>
<!----------------------------------------------------------->
<cfif #action# is "lostPass">
	Lost your password? Passwords are stored in an encrypted format and cannot be recovered. 
<br>If you have saved your email address in your profile, enter it here to reset your password. 
<br>If you have not saved your email address, please submit a bug report to that effect 
    and we will reset your password for you.

	<form name="pw" method="post" action="ChangePassword.cfm">
        <input type="hidden" name="action" value="findPass">
        <label for="username">Username</label>
	    <input type="text" name="username" id="username">
        <label for="email">Email Address</label>
	    <input type="text" name="email" id="email">
        <br>
	    <input type="submit" value="Request Password" class="lnkBtn">	
    </form>
</cfif>
<!-------------------------------------------------------------------->
<cfif #action# is "update">
	<cfoutput>
	<cfquery name="getPass" datasource="cf_dbuser">
		select password from cf_users where username = '#session.username#'
	</cfquery>
	<cfif hash(oldpassword) is not getpass.password>
		<span style="background-color:red;">
			Incorrect password. <a href="ChangePassword.cfm">Go Back</a>
		</span>
		<cfabort>
	<cfelseif getpass.password is hash(newpassword)>
		<span style="background-color:red;">
			You must pick a new password. <a href="ChangePassword.cfm">Go Back</a>
		</span>		
		<cfabort>
	<cfelseif #newpassword# neq #newpassword2#>
		<span style="background-color:red;">
			New passwords do not match. <a href="ChangePassword.cfm">Go Back</a>
		</span>
		<cfabort>			
	</cfif>
	<!--- Passwords check out for public users, now see if they're a database user --->
	<cfquery name="isDb" datasource="uam_god">
		select * from all_users where
		username='#ucase(session.username)#'
	</cfquery>
	<cfif #isDb.recordcount# is 0>
		<cfquery name="setPass" datasource="cf_dbuser">
			UPDATE cf_users SET password = '#hash(newpassword)#',
			PW_CHANGE_DATE=sysdate			
			WHERE username = '#session.username#'
		</cfquery>
	<cfelse>
		<cftry>
			<cftransaction>
				<cfquery name="dbUser" datasource="uam_god">
					alter user #session.username# 
					identified by "#newpassword#"
				</cfquery>
				<cfquery name="setPass" datasource="uam_god">
					UPDATE cf_users 
					SET password = '#hash(newpassword)#',
					PW_CHANGE_DATE=sysdate			
					WHERE username = '#session.username#'
				</cfquery>
			</cftransaction>
			<cfcatch>
				<cfsavecontent variable="errortext">
					<h3>Error in creating user.</h3>
					<p>#cfcatch.Message#</p>
					<p>#cfcatch.Detail#"</p>
					<CFIF isdefined("CGI.HTTP_X_Forwarded_For") and #len(CGI.HTTP_X_Forwarded_For)# gt 0>
						<CFSET ipaddress="#CGI.HTTP_X_Forwarded_For#">
					<CFELSEif  isdefined("CGI.Remote_Addr") and #len(CGI.Remote_Addr)# gt 0>
						<CFSET ipaddress="#CGI.Remote_Addr#">
					<cfelse>
						<cfset ipaddress='unknown'>
					</CFIF>
					<p>ipaddress: <cfoutput><a href="http://network-tools.com/default.asp?prog=network&host=#ipaddress#">#ipaddress#</a></cfoutput></p>
					<hr>
					<p>Client Dump:</p>
					<hr>
					<cfdump var="#client#" label="client">
					<hr>
					<p>URL Dump:</p>
					<hr>
					<cfdump var="#url#" label="url">
					<p>CGI Dump:</p>
					<hr>
					<cfdump var="#CGI#" label="CGI">
				</cfsavecontent>
				<cfmail subject="Error" to="#Application.PageProblemEmail#" from="SomethingBroke@#Application.fromEmail#" type="html">
					#errortext#
				</cfmail>	
				<h3>Error in changing password user.</h3>
				<p>#cfcatch.Message#</p>
				<p>#cfcatch.Detail#"</p>
				<cfabort>
			</cfcatch>	
		</cftry>
		<cfset session.epw = encrypt(newpassword,cfid)>
	</cfif>
Your password has successfully been changed.
<cfset session.password = #hash(newpassword)#>
<cfset session.force_password_change = "">
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
	<cfquery name="isGoodEmail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select cf_user_data.user_id, email,username from cf_user_data,cf_users
		 where cf_user_data.user_id = cf_users.user_id and
		 email = '#email#' and username= '#username#'
	</cfquery>
	<cfif #isGoodEmail.recordcount# neq 1>
		Sorry, that email wasn't found with your username.
		<cfabort>
	  <cfelse>
			<cfset charList = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,z,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,1,2,3,4,5,6,7,8,9,0">
			<cfset numList="1,2,3,4,5,6,7,8,9,0">
			<cfset specList="!,$,%,&,_,*,?,-,(,),<,>,=,/,:,;,.">
			<cfset newPass = "">
			<cfset cList="#charList#,#numList#,#specList#">
			<cfset c=0>
			<cfset i=1>
			<!---
			<cfloop condition="c LESS THAN 1">
				<cfset thisCharNum = RandRange(1,listlen(cList))>
				<cfset thisChar = ListGetAt(cList,#thisCharNum#)>
				<cfset newPass = "#thisChar##newPass#">
				<cfflush>
				<cfset i=i+1>
				<cfif passwordCheck(newPass)>
					<cfset c=2>
				</cfif>
				<cfif i gt 20>
					<cfset newPass="">
					<cfset i=1>
				</cfif>
			</cfloop>
			--->
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
			<cftransaction>
				<cfquery name="stopTrg" datasource="uam_god">
					alter trigger CF_PW_CHANGE disable
				</cfquery>
				<cfquery name="setNewPass" datasource="uam_god">
					UPDATE cf_users SET password = '#hash(newPass)#',
					pw_change_date=sysdate-91
					where user_id = #isGoodEmail.user_id#
				</cfquery>
				<cftry>
				<cfquery name="db" datasource="uam_god">
					alter user #isGoodEmail.username# identified by "#newPass#"
				</cfquery>
				<cfcatch><!--- not a DB user - whatever ---></cfcatch>
				</cftry>
				<cfquery name="stopTrg" datasource="uam_god">
					alter trigger CF_PW_CHANGE enable
				</cfquery>
			</cftransaction>	
			<cfmail to="#email#" subject="Arctos password" from="LostFound@#Application.fromEmail#" type="text">
				Your Arctos username/password is 
				
				#username# / #newPass#
				
				You will be required to change your password 
				after logging in.
			
				#Application.ServerRootUrl#/login.cfm
				
				If you did not request this change, please reply to #Application.technicalEmail#.
			</cfmail>
		An email containing your new password has been sent.
	</cfif>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------->
<cfinclude template = "includes/_footer.cfm">

