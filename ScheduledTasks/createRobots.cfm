<cfoutput>
<cfinclude template="/includes/_header.cfm">
<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="dir">
<cfset variables.fileName="#Application.webDirectory#/robots.txt">
<cfset variables.encoding="US-ASCII">
<cfscript>
	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
</cfscript>



<cfset robotscontent="User-agent: *">
<cfset robotscontent=robotscontent & chr(10) & "crawl-delay: 10">


<cfset dad="">



<cfif application.version is "test">




	<cfset allowedDirectories="Collections">
	<cfquery name="portals" datasource="cf_dbuser">
		select portal_name from cf_collection
	</cfquery>
	<cfset allowedDirectories=listappend(allowedDirectories,valuelist(portals.portal_name))>

    <cfset allowedDirectories=listappend(allowedDirectories,"contact.cfm,/digir/,/m/")>


<cfdump var=#allowedDirectories#>

	<cfloop query="q">
		<cfif not listfindnocase(allowedDirectories,name)>
			<cfset dad=dad & chr(10) & "Disallow: /" & name & "/">
		</cfif>
	</cfloop>

<cfdump var=#dad#>


	<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="file">
	<cfset allowedFileList="favicon.ico,robots.txt">
	<cfloop query="q">
		<cfquery name="current" datasource="cf_dbuser">
			select count(*) c from cf_form_permissions where form_path='/#name#' and role_name='public'
		</cfquery>
		<cfif current.c is 0 and right(name,7) is not ".xml.gz" and not listfindnocase(allowedFileList,name)>
			<cfset dad=dad & chr(10) & "Disallow: /" & name>
		</cfif>
	</cfloop>
	<cfscript>


		variables.joFileWriter.writeLine(robotscontent);
		variables.joFileWriter.writeLine(dad);
		variables.joFileWriter.writeLine('Sitemap: ' & application.serverRootUrl & '/sitemapindex.xml.gz');
	</cfscript>
<cfelse>
	<!---- not prod ---->
	<cfscript>
		variables.joFileWriter.writeLine('Disallow: /');
	</cfscript>
</cfif>
<cfscript>
	variables.joFileWriter.close();
</cfscript>
</cfoutput>