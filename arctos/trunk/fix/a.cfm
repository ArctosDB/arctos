<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select USERNAME from dba_users where lock_date is null and profile='ARCTOS_USER' order by username
	</cfquery>
	<cfloop query="d">
		"#username#",
		<cfquery name="r" datasource="uam_god">
			select granted_role from dba_role_privs where grantee='#username#' order by granted_role
		</cfquery>
		"#valuelist(r.granted_role)#"<br>
	</cfloop>
</cfoutput>