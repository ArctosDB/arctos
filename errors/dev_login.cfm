
<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfheader statuscode="401" statustext="Not authorized">
This is a development server. You may log in or create an account
for testing purposes. You may not access this machine without logging in.
Data available from this machine are for testing purposes only and are not
valid specimen data.

<p>
<a href="/login.cfm">Log In</a>
</p>
<p>
	<a href="http://arctos.database.museum">Go to Arctos</a>
</p>
<cfif action is "nothing">
	<cfif not isdefined("application.version") or application.version is not "test">
		nope<cfabort>
	</cfif>

	<cfset f = CreateObject("component","component.utilities")>
	<cfset captcha = f.makeCaptchaString()>
	<cfset captchaHash = hash(captcha)>
	<cfform name="g" id="g" method="post" action="/errors/dev_login.cfm">
		<input type="hidden" name="action" value="crufl">
	    <cfimage
	    	action="captcha"
	    	width="300"
	    	height="50"
	    	text="#captcha#"
	    	overwrite="yes"
	    	difficulty="high"
	    	destination="#application.webdirectory#/download/captcha.png">

	    <img src="/download/captcha.png">
	   	<br>
	    <label for="captcha">Enter the text above (required)</label>
	    <input type="text" name="captcha" id="captcha" class="reqdClr">
	    <p></p>
	    	<cfquery name="usr_template" datasource="uam_god">
				select username,descr from cf_test_users where username='#u#'
			</cfquery>
	    <label for="u">Who do you want to be?</label><br>
	    <select name="u">
			<option></option>
			<cfloop query="usr_template">
				<option value="#usr_template.username#">#usr_template.username# - #usr_template.descr#</option>
			</cfloop>
		</select>
        <br>
	    <input type="hidden" name="captchaHash" value="#captchaHash#">
		<br><input type="submit" value="log in as user">
	</cfform>



</cfif>

</cfoutput>
<cfif action is "crufl">
	<cfdump var=#form#>

	<cfif hash(ucase(form.captcha)) neq form.captchaHash>
		You did not enter the correct text; use your back button.
		<cfabort>
	</cfif>
	<!--- option? --->
	<cfquery name="usr_template" datasource="uam_god">
		select * from cf_test_users where username='#u#'
	</cfquery>
	<cfif usr_template.recordcount is not 1>
		bad request<cfabort>
	</cfif>
	<cfquery name="x" datasource="uam_god">
		select count(*) from cf_users where username='#u#'
	</cfquery>
	<cfif x.recordcount is 1>
		<cfquery name="uu" datasource="cf_dbuser">
			update cf_users set
				PW_CHANGE_DATE=sysdate,
				last_login=sysdate,
				password='#hash(usr_template.pwd)#'
			where username='#u#'
		</cfquery>
	<cfelse>
		<cfquery name="nextUserID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select max(user_id) + 1 as nextid from cf_users
		</cfquery>
		<cfquery name="newUser" datasource="cf_dbuser">
			INSERT INTO cf_users (
				user_id,
				username,
				password,
				PW_CHANGE_DATE,
				last_login
			) VALUES (
				#nextUserID.nextid#,
				'#u#',
				'#hash(usr_template.pwd)#',
				sysdate,
				sysdate
			)
		</cfquery>
	</cfif>
	<cfquery name="alreadyGotOne" datasource="uam_god">
		select count(*) c from dba_users where upper(username)='#u#'
	</cfquery>
	<cfif alreadyGotOne.recordcount lt 1>
		<cfquery name="makeUser" datasource="uam_god">
			create user #u# identified by "#usr_template.pwd#" profile "ARCTOS_USER" default TABLESPACE users QUOTA 1G on users
		</cfquery>
		<cfquery name="grantConn" datasource="uam_god">
			grant create session to #u#
		</cfquery>
		<cfquery name="grantTab" datasource="uam_god">
			grant create table to #u#
		</cfquery>
		<cfquery name="grantVPD" datasource="uam_god">
			grant execute on app_security_context to #u#
		</cfquery>
		<cfquery name="usrInfo" datasource="uam_god">
			select * from temp_allow_cf_user,cf_users where temp_allow_cf_user.user_id=cf_users.user_id and
			cf_users.username='#u#'
		</cfquery>
		<cfquery name="makeUser" datasource="uam_god">
			delete from temp_allow_cf_user where user_id=#u#
		</cfquery>
	<cfelse>
		<!--- force reset the pwd --->
		<cfquery name="uact" datasource="uam_god">
			alter user #u# account unlock
		</cfquery>
		<cfquery name="dbUser" datasource="uam_god">
			alter user #u# identified by "#usr_template.pwd#"
		</cfquery>
	</cfif>

	<cfquery name="roles" datasource="uam_god">
		select
			granted_role role_name
		from
			dba_role_privs,
			collection
		where
			upper(dba_role_privs.granted_role) = upper(replace(collection.guid_prefix,':','_')) and
			upper(grantee) = '#u#'
	</cfquery>
	<cfloop query="roles">
		<cfquery name="t" datasource="uam_god">
			revoke #role_name# from #u#
		</cfquery>
	</cfloop>
	<cfloop list="#usr_template.rights#" index="i">
		<cfquery name="g" datasource="uam_god">
			grant #u# to #u#
		</cfquery>
	</cfloop>
	<cfloop list="#usr_template.collections#" index="i">
		<cfquery name="g" datasource="uam_god">
			grant #u# to #u#
		</cfquery>
	</cfloop>
	<cflocation url="/login.cfm?action=signIn&username=#u#&password=#usr_template.pwd#" addtoken="false">








</cfif>
<cfinclude template="/includes/_footer.cfm">