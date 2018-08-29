<!----

test only
do not create this in prod


create table cf_test_users (
  username varchar2(255) not null,
  pwd varchar2(255) not null,
  collections varchar2(4000) not null,
  rights varchar2(4000) not null,
  descr varchar2(4000) not null
);


delete from cf_test_users;

insert into cf_test_users (
  username,
  pwd,
  rights,
  collections,
  descr
) values (
  'i_am_tester',
  'seekrut.passwerd123',
  'manage_agents,manage_container,manage_collection,manage_geography,manage_locality,manage_publications,manage_specimens,manage_transactions,manage_codetables,global_admin,manage_taxonomy,coldfusion_user,data_entry,dgr_locator,public,manage_documentation,manage_media',
  'CUMV_AMPH,CRCM_BIRD,CUMV_MAMM,DMNS_INV,UMNH_BIRD,DGR_MAMM,CHAS_MAMM,UCM_FISH,PSU_MAMM,DGR_BIRD,NBSB_BIRD,MVZ_EGG,MVZ_IMG,UMNH_MAMM,COA_EGG,MVZ_PAGE,UTEP_INV,HWML_PARA,UCM_HERP,MSB_FISH,MVZOBS_MAMM,UTEP_ZOO,MVZOBS_HERP,UAMOBS_ENTO,CUMV_REPT,COA_HERP,KNWR_HERB,CUMV_BIRD,NMU_ENTO,UAMOBS_MAMM,UAM_ARC,UAM_EH,MVZ_BIRD,MVZ_MAMM,WNMU_BIRD,UWBM_MAMM,UNR_MAMM,UMNH_MALA,WNMU_FISH,UAMB_HERB,MSB_HOST,UTEPOBS_HERP,DGR_ENTO,UTEP_ENTO,UMNH_ENTO,MSB_PARA,MSB_MAMM,UAM_MAMM,UTEP_FISH,DMNS_EGG,WNMU_MAMM,MVZOBS_FISH,NMU_MAMM,MLZ_MAMM,UWYMV_HERP,DMNS_MAMM,NMU_FISH,UAMOBS_BIRD,CHAS_INV,UTEP_MAMM,UTEP_BIRD,UAM_ART,UAM_HERB,CHAS_FISH,MLZ_EGG,MLZ_BIRD,UNR_HERP,UAM_ENTO,CUMV_FISH,CHAS_EGG,MVZ_HERP,KNWR_ENTO,COA_BIRD,DMNS_BIRD,USNPC_PARA,UCM_BIRD,UNR_BIRD,UTEP_HERP,MSBOBS_MAMM,MSB_BIRD,UNR_FISH,NMU_HERB,UAMOBS_EH,UAM_FISH,COA_ENTO,MSB_HERP,CHAS_BIRD,UWBM_HERP,MVZOBS_BIRD,UAM_ALG,UCM_MAMM,UTEP_HERPOS,COA_REPT,UTEP_HERB,DMNS_PARA,UWYMV_BIRD,UWYMV_MAMM,UAM_INV,UAM_ES,UAM_BIRD,NMU_BIRD,UCM_OBS,CHAS_ENTO,UTEPOBS_ENTO,UMNH_HERP,CHAS_HERB,COA_MAMM,UCM_EGG,UAM_HERP,UTEP_ARC,DMNS_HERP,MVZ_HILD,UTEP_ES,UAMOBS_FISH,KWP_ENTO,CHAS_EH,UWYMV_FISH,UNR_EGG',
  'all access to everything'
);

insert into cf_test_users (
  username,
  pwd,
  rights,
  collections,
  descr
) values (
  'demo_tester',
  'seekrut.passwerd123',
  'manage_agents,manage_container,manage_collection,manage_geography,manage_locality,manage_publications,manage_specimens,manage_transactions,manage_codetables,global_admin,manage_taxonomy,coldfusion_user,data_entry,dgr_locator,public,manage_documentation,manage_media',
  'DEMO:Bird,DEMO:Mamm,DEMO:Herp,DEMO:Fish,DEMO:Ento,DEMO:ES',
  'all access to DEMO collections and admin tools'
);




---->
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
				select username,descr from cf_test_users order by username
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

	<cfdump var=#usr_template#>
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

	<cfdump var=#alreadyGotOne#>

	<br>alreadyGotOne.recordcount::#alreadyGotOne.recordcount#
	<cfif alreadyGotOne.c lt 1>


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
			grant #i# to #u#
		</cfquery>
	</cfloop>
	<cfloop list="#usr_template.collections#" index="i">
		<cfquery name="g" datasource="uam_god">
			grant #i# to #u#
		</cfquery>
	</cfloop>
	<cflocation url="/login.cfm?action=signIn&username=#u#&password=#usr_template.pwd#" addtoken="false">








</cfif>
<cfinclude template="/includes/_footer.cfm">