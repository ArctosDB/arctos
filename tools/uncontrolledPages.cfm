<cfoutput>
<cffunction name="d" returntype="query">
	<cfargument name="p" type="string">
	<cfargument name="n" type="string">
	<cfdirectory directory="#application.webDirectory#/#p#" action="list" name="q" sort="name" recurse="true">
	<cfreturn q>
</cffunction>
<cfinclude template="/includes/_header.cfm">
<cfset dl=d('/',"root")>
<cfset q = querynew("path,privs,type")>
<cfset r=1>
<cfloop query="q">
	<cfif #directory# does not contain ".svn" and #name# is not ".svn"
		and #directory# does not contain "CFIDE" and #name# is not "CFIDE"
		and #directory# does not contain "fix" and #name# is not "fix"
		and #directory# does not contain "WEB-INF" and #name# is not "WEB-INF"
		and #directory# does not contain "cfdocs" and #name# is not "cfdocs"			
		and #directory# does not contain "WEB-INF" and #name# is not "META-INF" and
		#name# contains ".cfm">
		<cfset thisPath=replace(directory,application.webDirectory,"","all")>
		<cfset thisName="#thisPath#/#name#">
		<cfquery name="current" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select ROLE_NAME, count(*) c from cf_form_permissions where form_path='#thisName#'
			group by ROLE_NAME
		</cfquery>
		<cfset temp = queryaddrow(q,1)>
		<cfset temp = QuerySetCell(q, "path", "#thisPath#/#name#", r)>
		<cfset temp = QuerySetCell(q, "privs", "#valuelist(current.role_name)#", r)>
		<cfset temp = QuerySetCell(q, "type", "#type#", r)>	
		<cfset r=r+1>
	</cfif>
</cfloop>

<cfdump var=#q#>
<!----
<table border>
	
	
	

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
---->
</cfoutput>
<!---
<cfdump var="#dl#">
<cfdirectory directory="#application.webDirectory#" action="list" name="dir" sort="name" recurse="true">

<table width="100%" cellpadding="0" cellspacing="0" border>
	<tr>
<th>Name <a href="?sort=name" class="sort" title="Sort By Name">v</a></th>


		<th>Size (bytes) <a href="?sort=size" class="sort" title="Sort By Size">v</a></th>
		<th>Last Modified <a href="?sort=datelastmodified+desc" class="sort" title="Sort By Date">v</a></th>
	</tr>
	<cfoutput query="dir">
	<tr>
		<td><a href="#dir.name#">#dir.name#</a></td>
		<td>#dir.size#</td>
		<td>#dir.datelastmodified#</td>
	</tr>
	</cfoutput>
</table>
<p>Directory Browser by <a href="http://www.petefreitag.com/">Pete Freitag</a></p>
</body>
</html>
--->