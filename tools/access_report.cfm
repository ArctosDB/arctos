<cfinclude template="/includes/_header.cfm">
<cfset title="Access Report">
<style>
.nopn{
	font-size:smaller;
	color:darkgray;
}
</style>


<!----excludeBuiltInJunk---->
<cfset ebij="APEX_030200,AQ_USER_ROLE,AQ_ADMINISTRATOR_ROLE">
<cfset ebij=ebij & ",BI,">
<cfset ebij=ebij & ",CTXSYS,CWM_USER,CTXAPP,CONNECT">
<cfset ebij=ebij & ",DBSNMP,DBA">
<cfset ebij=ebij & ",EXFSYS,EXP_FULL_DATABASE">
<cfset ebij=ebij & ",HR,">
<cfset ebij=ebij & ",IX,IMP_FULL_DATABASE">
<cfset ebij=ebij & ",JAVA_ADMIN,JAVAUSERPRIV">
<cfset ebij=ebij & ",MDSYS,MDDATA,">
<cfset ebij=ebij & ",OE,OUTLN,OLAPSYS,OWB_USER,OWBSYS,OWB_DESIGNCENTER_VIEW,OWB$CLIENT,OLAP_USER,OLAP_DBA,OEM_MONITOR">
<cfset ebij=ebij & ",">
<cfset ebij=ebij & ",">
<cfset ebij=ebij & ",PM">
<cfset ebij=ebij & ",RESOURCE">
<cfset ebij=ebij & ",SELECT_CATALOG_ROLE,SYSMAN,SH,SPATIAL_CSW_ADMIN_USR,SPATIAL_WFS_ADMIN,SPATIAL_WFS_ADMIN_USR,SYSTEM,SYSMAN,SYS">
<cfset ebij=ebij & ",TEST_ROLE,TROLE">
<cfset ebij=ebij & ",UAM">
<cfset ebij=ebij & ",WKSYS,WMSYS,WM_ADMIN_ROLE,WK_TEST,WKUSER">
<cfset ebij=ebij & ",XDB,XDBWEBSERVICES,XDBADMIN">


<cfoutput>
	<cfparam name="excl_locked" default="">
	<cfparam name="excl_pub_usr" default="true">
	<cfparam name="excl_admin" default="true">
	<cfparam name="role_srch" default="">
	<cfparam name="usr_srch" default="">

	<form method="get" action="access_report.cfm">
		<label for="excl_locked">Locked?</label>
		<select name="excl_locked">
			<option value=""></option>
			<option <cfif excl_locked is "true">selected="selected"</cfif> value="true">exclude</option>
		</select>
		<label for="excl_pub_usr">PUB_USR...?</label>
		<select name="excl_pub_usr">
			<option value=""></option>
			<option <cfif excl_pub_usr is "true">selected="selected"</cfif> value="true">exclude</option>
		</select>
		<label for="excl_admin">Admin stuff?</label>
		<select name="excl_admin">
			<option value=""></option>
			<option <cfif excl_admin is "true">selected="selected"</cfif> value="true">exclude</option>
		</select>

		<label for="role_srch">Role</label>
		<input type="text" name="role_srch" value='#role_srch#' size="60">

		<label for="usr_srch">User</label>
		<input type="text" name="usr_srch" value='#usr_srch#' size="60">

		<br><input type="submit" value="filter">
	</form>
	<cfquery name="roles" datasource="uam_god">
		select
			GRANTED_ROLE
		from
			DBA_ROLE_PRIVS
		where
			1=1
			<cfif excl_admin is "true">
				and GRANTED_ROLE not in (#listqualify(ebij,"'",",")#)
			</cfif>
			<cfif len(role_srch) gt 0>
				and GRANTED_ROLE like '%#ucase(role_srch)#%'
			</cfif>
		group by
			GRANTED_ROLE
		order by
			GRANTED_ROLE
	</cfquery>
	<cfloop query="roles">
		<cfquery name="hasrole" datasource="uam_god">
			select
				GRANTEE ,
				ACCOUNT_STATUS
			from
				DBA_ROLE_PRIVS,
				dba_users
			 where
			 	DBA_ROLE_PRIVS.GRANTEE=dba_users.USERNAME and
			 	GRANTED_ROLE='#GRANTED_ROLE#'
			 	<cfif excl_pub_usr is "true">
					and grantee not like 'PUB_USR%'
				</cfif>
				<cfif excl_pub_usr is "true">
					and grantee not like 'PUB_USR%'
				</cfif>
				<cfif excl_admin is "true">
					and grantee not in (#listqualify(ebij,"'",",")#)
				</cfif>
				<cfif excl_locked is "true">
					and ACCOUNT_STATUS='OPEN'
				</cfif>
				<cfif len(usr_srch) gt 0>
					and GRANTEE like '%#ucase(usr_srch)#%'
				</cfif>
			group by
				GRANTEE,
				ACCOUNT_STATUS
			order by
				GRANTEE
		</cfquery>
		<cfif hasRole.recordcount gt 0>
			<hr>
			#GRANTED_ROLE#
			<ul>
				<cfloop query="hasrole">
					<cfif ACCOUNT_STATUS neq 'OPEN'>
						<cfset tcls='nopn'>
					<cfelse>
						<cfset tcls=''>
					</cfif>
					<li class="#tcls#">#GRANTEE# (#ACCOUNT_STATUS#)</li>
				</cfloop>
			</ul>
		</cfif>
	</cfloop>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
