<cfoutput>
<cfinclude template="/includes/_header.cfm">
<cfset variables.fileName="#Application.webDirectory#/robots.txt">
<cfset variables.encoding="US-ASCII">
<cfscript>
	variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
</cfscript>



<cfset robotscontent="User-agent: *">
<cfset robotscontent=robotscontent & chr(10) & "crawl-delay: 10">





<cfif application.version is "test">

	<!----- DIRECTORIES
				these are disallowed by default, so just eliminate from the default list
				anything we DO want to allow and DIALLOW whatever's left
	---->
		<!---- get a list of all directories ---->
		<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="dir">
		<!---- listify ---->
		<cfset dirlist=valuelist(q.name)>


		<br>all directories: #dirlist#
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
	<!---- FILES
				these are allow by default, so
				create a list of things that are NOT allowed.
				This only has to happen in the root directory
	------>
		<!---- all files ---->
		<cfdirectory directory="#application.webDirectory#" action="list" name="q" sort="name" recurse="false" type="file">
		<!---- listify ---->
		<cfset fileList=valuelist(q.name)>
		<!--- remove sitemaps, which should be the only .xml.gz things in the dir ---->
		<cfloop condition = "ListContains(fileList,'.xml.gz')">
			<br>loopity
			<cfset fileList=listdeleteat(fileList,ListContains(fileList,'.xml.gz'))>
		</cfloop>
		<!---- find "public" forms ---->
		<cfquery name="notpublic" datasource="cf_dbuser">
			select substr(form_path,2) rootform from cf_form_permissions where substr(form_path,2) not like '%/%' and role_name='public'
		</cfquery>
		<!---- remove public forms from our list ---->
		<cfloop query="notpublic">
			<cfif listfind(fileList,rootform)>
				<cfset fileList=listdeleteat(fileList,listfind(fileList,rootform))>
			</cfif>
		</cfloop>
		<!--- anything that's somehow wonky and should be indexed ---->
		<cfset forceAllowFiles="robots.txt">
		<cfloop list="#forceAllowFiles#" index="i">
			<cfif listfind(fileList,i)>
				<cfset fileList=listdeleteat(fileList,listfind(fileList,i))>
			</cfif>
		</cfloop>



		<!--- files that are open but which we do NOT want indexed ---->
		<!--- append if not exists ---->
		<cfset forceDisallowFile="contact.cfm">
		<cfloop list="#forceDisallowFile#" index="i">
			<cfif not listfind(fileList,i)>
				<cfset fileList=listappend(fileList,i)>
			</cfif>
		</cfloop>


		<br>fileList: #fileList#

		<!---- disallow whatever's left ---->
		<cfloop list="#fileList#" index="i">
			<cfset robotscontent=robotscontent & chr(10) & "Disallow: /" & i>
		</cfloop>

		<cfscript>


			variables.joFileWriter.writeLine(robotscontent);
			variables.joFileWriter.writeLine('Sitemap: ' & application.serverRootUrl & '/sitemapindex.xml.gz');
		</cfscript>


<!-------------

	<cfloop query="q">
		<cfif not listfindnocase(forceDisallowDir,name)>
			<cfset dad=dad & chr(10) & "Disallow: /" & name & "/">
		</cfif>
	</cfloop>






	------------>
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