<cfoutput>
<cfinclude template="/includes/_header.cfm">
<cfset variables.fileName="#Application.webDirectory#/robots.txt">
<cfset variables.encoding="US-ASCII">
<cfscript>
	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
</cfscript>



<cfset robotscontent="User-agent: *">
<cfset robotscontent=robotscontent & chr(10) & "crawl-delay: 10">


<cfset dad="">



<cfif application.version is "test">
	<!---- by default we disallow all directories - list of things we DO want bots to scrape ---->
	<cfset forceDisallowFile="contact.cfm">
	<cfset forceDisallowDir="digir">
	<cfset forceAllowFile="favicon.ico,robots.txt">
	<cfset forceAllowDir="Collections,m">

	<cfquery name="portals" datasource="cf_dbuser">
		select portal_name from cf_collection
	</cfquery>
	<cfset forceDisallowDir=listappend(allowedDirectories,valuelist(portals.portal_name))>





	<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="dir">
	<cfloop query="q">
		<cfif not listfindnocase(forceDisallowDir,name)>
			<cfset dad=dad & chr(10) & "Disallow: /" & name & "/">
		</cfif>
	</cfloop>



	<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="file">
	<cfloop query="q">
		<cfquery name="current" datasource="cf_dbuser">
			select count(*) c from cf_form_permissions where form_path='/#name#' and role_name='public'
		</cfquery>
		<cfif current.c is 0 and right(name,7) is not ".xml.gz" and not listfindnocase(forceAllowFile,name)>
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