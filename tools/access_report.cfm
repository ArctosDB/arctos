<cfinclude template="/includes/_header.cfm">
<cfset title="Access Report">
<style>
.tcls{
	font-size:smaller;
	color:darkgray;
}
</style>
<cfoutput>
	<cfparam name="locked" default="">
	<form method="get" action="access_report.cfm">
		<label for="locked">Locked?</label>
		<select name="locked">
			<option value=""></option>
			<option <cfif locked is "OPEN">selected="selected"</cfif><value="OPEN">open</option>
		</select>
		<br><input type="submit" value="filter">
	</form>
	<cfquery name="roles" datasource="uam_god">
		select GRANTED_ROLE from DBA_ROLE_PRIVS group by GRANTED_ROLE order by GRANTED_ROLE
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
			 	GRANTED_ROLE='#GRANTED_ROLE#' and
			 	grantee not like 'PUB_USR%' and
			 	grantee != 'SYS'
			 	and grantee != 'UAM'
			 	<cfif len(locked) gt 0>
					and ACCOUNT_STATUS='#locked#'
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
