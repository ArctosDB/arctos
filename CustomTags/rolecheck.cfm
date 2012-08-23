<cfif (isdefined("session.roles") and 
	session.roles contains "coldfusion_user") and 
	(isdefined("session.force_password_change") and 
	session.force_password_change is "yes" and 
	cgi.script_name is not "/ChangePassword.cfm")>
	<cflocation url="/ChangePassword.cfm">	
</cfif>	
<cfif fileexists(application.webDirectory & cgi.script_name)>
	<!----   ----->
	<cfquery name="isValid" datasource="uam_god" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
		select ROLE_NAME from cf_form_permissions 
		where form_path = '#replace(cgi.script_name,"//","/","all")#'
	</cfquery>
	<cfdump var=#isValid#>
	<cfif isValid.recordcount is 0>
		<cfthrow message="uncontrolled form" detail="This is an uncontrolled/locked form." errorCode="403">
	<cfelseif valuelist(isValid.role_name) is not "public">
		<cfloop query="isValid">
			<cfif not listfindnocase(session.roles,role_name)>
				<cfthrow message="not authorized" detail="You are not authorized to access this form." errorCode="403">
			</cfif>
		</cfloop>
	</cfif>
</cfif>