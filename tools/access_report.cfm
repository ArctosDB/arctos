<cfinclude template="/includes/_header.cfm">
<cfset title="Access Report">
<cfif action is "nothing">
	<a href="access_report.cfm?action=role">Roles</a>
</cfif>
<cfif action is "role">
	<cfquery name="roles" datasource="uam_god">
		select GRANTED_ROLE from DBA_ROLE_PRIVS order by GRANTED_ROLE group by GRANTED_ROLE 
	</cfquery>
	<cfloop query="roles">
		<cfquery name="hasrole" datasource="uam_god">
			select GRANTEE from DBA_ROLE_PRIVS where GRANTED_ROLE='#GRANTED_ROLE#'
		</cfquery>
		<cfif hasRole.recordcount gt 0>
			<hr>
			#GRANTED_ROLE#
			<ul>
				<cfloop query="hasrole">
					<li>#GRANTEE#</li>
				</cfloop>
			</ul>
		</cfif>
	</cfloop>
</cfif>
<cfinclude template="/includes/_header.cfm">
