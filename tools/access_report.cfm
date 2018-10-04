<cfinclude template="/includes/_header.cfm">
<cfset title="Access Report">
<cfif action is "nothing">
	<a href="access_report.cfm?action=role">Roles</a>
</cfif>
<cfif action is "role">
<cfoutput>
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
			 GRANTED_ROLE='#GRANTED_ROLE#'
			and grantee not like 'PUB_USR%'
			and grantee != 'SYS'
			and grantee != 'UAM'
			group by GRANTEE order by GRANTEE
		</cfquery>
		<cfif hasRole.recordcount gt 0>
			<hr>
			#GRANTED_ROLE#
			<ul>
				<cfloop query="hasrole">
					<li>#GRANTEE# (#ACCOUNT_STATUS#)</li>
				</cfloop>
			</ul>
		</cfif>
	</cfloop>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
