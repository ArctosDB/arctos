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

	<!----- DIRECTORIES - DISALLOW BY DEFAULT ---->
		<!---- get a list of all directories ---->
		<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="dir">
		<!---- listify ---->
		<cfset dirlist=valuelist(q.name)>
		<!--- list of directories we DO want to allow ---->
		<cfset forceAllowDir="Collections,m">
		<!--- add portals to the allowed list ---->
		<cfquery name="portals" datasource="cf_dbuser">
			select portal_name from cf_collection
		</cfquery>
		<cfset dirlist=listappend(dirlist,valuelist(portals.portal_name))>
		<!----
			remove anything that we DO want to allow access to
			MAKE SURE THERE IS NOTHING WE DO NOT WANT INDEXED IN THESE DIRS!!!!
		---->
		<cfloop list="#forceAllowDir#" index="i">
			<cfif listfind(dirlist,i)>
				<cfset dirlist=listdeleteat(dirlist,listfind(dirlist,i))>
			</cfif>
		</cfloop>

		<br>dirlist after removal of allowed: #dirlist#
		<!--- add whatever's left to DIALLOW ---->
		<cfloop list="#dirlist#" index="i">
			<cfset robotscontent=robotscontent & chr(10) & "Disallow: /" & i & "/">
		</cfloop>
	<!---- FILES - ALLOW BY DEFAULT ---->
		<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="file">
		<cfset fileList=valuelist(q.name)>
		<!--- files that are open but which we do NOT want indexed ---->
		<cfset forceDisallowFile="contact.cfm">
		<cfloop list="#forceDisallowFile#" index="i">
			<cfif listfind(fileList,i)>
				<cfset fileList=listdeleteat(fileList,listfind(fileList,i))>
			</cfif>
		</cfloop>
		<br>fileList: #fileList#


			<cfset forceAllowFile="favicon.ico,robots.txt">




		<cfloop list="#fileList#" index="i">
			<!---- delete anything that's not public ---->
			<cfquery name="current" datasource="cf_dbuser">
				select count(*) c from cf_form_permissions where form_path='/#name#' and role_name='public'
			</cfquery>
			<cfif current.c is 0 and right(name,7) is not ".xml.gz" and not listfindnocase(forceAllowFile,name)>
				<cfset dad=dad & chr(10) & "Disallow: /" & name>
			</cfif>
		</cfloop>


	<br>forceDisallowFile: #forceDisallowFile#

	<br>forceDisallowDir: #forceDisallowDir#

	<br>forceAllowFile: #forceAllowFile#
	<br>forceAllowDir: #forceAllowDir#

	<br>appended portals now...
	<br>
	<br>forceAllowDir: #forceAllowDir#




	<br>default allowDirs: #allowDirs#
		<cfset allowDirs=listappend(forceDisallowDir,valuelist(portals.portal_name))>


	<cfloop query="q">
		<cfif not listfindnocase(forceDisallowDir,name)>
			<cfset dad=dad & chr(10) & "Disallow: /" & name & "/">
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