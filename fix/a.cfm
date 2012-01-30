<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select USERNAME from dba_users where lock_date is null and profile='ARCTOS_USER' order by username
	</cfquery>
	<cfloop query="d">
		
		<cfquery name="r" datasource="uam_god">
			select granted_role from dba_role_privs where grantee='#username#' order by granted_role
		</cfquery>
		
		<cfquery name="an" datasource="uam_god">
			select p.agent_name from agent_name,preferred_agent_name p where agent_name.agent_id=p.agent_id and upper(agent_name.agent_name)='#username#'
		</cfquery>
		
		<cfquery name="ll" datasource="uam_god">
			select LAST_LOGIN from cf_users where  upper(username)='#username#'
		</cfquery>
		"#username#","#valuelist(r.granted_role)#","#an.agent_name#","#dateformat(ll.last_login,"yyyy-mm-dd")#"<br>
	</cfloop>
</cfoutput>