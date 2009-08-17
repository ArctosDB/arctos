<cfoutput>
<cffunction name="d" returntype="query">
	<cfargument name="p" type="string">
	<cfargument name="n" type="string">
	<cfdirectory directory="#application.webDirectory#/#p#" action="list" name="q" sort="name" recurse="true">
	<cfreturn q>
</cffunction>
<cfinclude template="/includes/_header.cfm">

<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="dir">

<cfdump var=#q#>


<!----------------------
<cfset dl=d('/',"root")>
<table border>
<cfloop query="q">
	<cfif #directory# does not contain ".svn" and #name# is not ".svn"
		and #directory# does not contain "CFIDE" and #name# is not "CFIDE"
		and #directory# does not contain "WEB-INF" and #name# is not "WEB-INF"
		and #directory# does not contain "WEB-INF" and #name# is not "META-INF" and
		#name# contains ".cfm">
	<cfset thisPath=replace(directory,application.webDirectory,"","all")>
	<cfset thisName="#thisPath#/#name#">
	<cfquery name="current" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select ROLE_NAME, count(*) c from cf_form_permissions where form_path='#thisName#'
		group by ROLE_NAME
	</cfquery>
		<tr>
			<td>
				<span <cfif current.c is 0> style="color:red;"</cfif>>#thisPath#/#name# (#type#)</span>
			</td>
			<td>
				#valuelist(current.role_name)#
			</td>
			<td>
				<a href="/Admin/form_roles.cfm?action=setRoles&filter=#thisPath#/#name#">set permissions</a>
			</td>
			<td>
				<a href="#thisPath#/#name#">Visit Form</a>
			</td>
		</tr>
</cfif>
</cfloop>
</table>

----------------->


</cfoutput>