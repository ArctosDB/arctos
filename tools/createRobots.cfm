<cfoutput>
<cffunction name="d" returntype="query">
	<cfargument name="p" type="string">
	<cfargument name="n" type="string">
	<cfdirectory directory="#application.webDirectory#/#p#" action="list" name="q" sort="name" recurse="true">
	<cfreturn q>
</cffunction>
<cfinclude template="/includes/_header.cfm">

<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="dir">



<cfset variables.fileName="#Application.webDirectory#/temp/test.txt">
<cfset variables.encoding="UTF-8">
<cfscript>
	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	variables.joFileWriter.writeLine('User-agent: *');
</cfscript>
	
<cfset allowedDirectories="Collections">
<cfloop query="q">
	<cfif not listfindnocase(allowedDirectories,name)>
		<cfscript>
			a='Disallow: /' & name & '/';
			variables.joFileWriter.writeLine(a);
		</cfscript>		
	</cfif>
</cfloop>

<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="file">

<cfdump var="#q#">
<cfloop query="q">
	<cfquery name="current" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) c from cf_form_permissions where form_path='/#name#' and role_name='public'
	</cfquery>
	<cfif current.c is 0>
		<cfscript>
			a='Disallow: /' & name;
			variables.joFileWriter.writeLine(a);
		</cfscript>		
	</cfif>
	<br>#name#: #current.c#
</cfloop>

<cfscript>
	variables.joFileWriter.close();
</cfscript>
<a href="/temp/test.txt">file</a>

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