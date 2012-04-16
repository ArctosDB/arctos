<cfcomponent>	
<cfset This.name = "Arctos">
<cfset This.SessionManagement="True">
<cfset This.ClientManagement="false">
<cffunction name="onMissingTemplate" returnType="boolean" output="false">
	<cfargument name="thePage" type="string" required="true">
	<cfinclude template="/errors/404.cfm">
	<cfabort>
</cffunction>

<cffunction name="onError">	
	<cfargument name="exception" required="true">
    <cfargument name="EventName" type="String" required="true">
	<cfset showErr=1>
    <cfif isdefined("exception.type") and exception.type eq "coldfusion.runtime.AbortException">
        <cfset showErr=0>
		<cfreturn/>
	</cfif>
	<cfif StructKeyExists(form,"C0-METHODNAME")>
		<cfset showErr=0>
		<cfreturn/>
	</cfif>
	<cfif showErr is 1>
		<cfsavecontent variable="errortext">
			<CFIF isdefined("CGI.HTTP_X_Forwarded_For") and len(CGI.HTTP_X_Forwarded_For) gt 0>
				<CFSET ipaddress=CGI.HTTP_X_Forwarded_For>
			<CFELSEif  isdefined("CGI.Remote_Addr") and len(CGI.Remote_Addr) gt 0>
				<CFSET ipaddress=CGI.Remote_Addr>
			<cfelse>
				<cfset ipaddress='unknown'>
			</CFIF>
			<cfoutput>
				<table border>
					<tr>
						<td colspan="2">
							Exception
						</td>
					</tr>
					<tr>
						<td>
							IP
						</td>
						<td>
							#ipaddress# 
							<a href="http://network-tools.com/default.asp?prog=network&host=#ipaddress#">[ lookup ]</a>
							<a href="http://arctos.database.museum/Admin/blacklist.cfm?action=ins&ip=#ipaddress#">[ blacklist ]</a>
						</td>
					</tr>
					<cfif isdefined("session.username")>
						<tr>
							<td>Username</td>
							<td>#session.username#</td>
						</tr>
					</cfif>
					<cfif isdefined("exception.Sql")>
						<tr>
							<td>exception.Sql</td>
							<td>#exception.Sql#</td>
						</tr>
					</cfif>
					<cfif isdefined("exception.Message")>
						<tr>
							<td>exception.Message</td>
							<td>#exception.Message#</td>
						</tr>
					</cfif>
					<cfif isdefined("exception.ErrorCode")>
						<tr>
							<td>exception.ErrorCode</td>
							<td>#exception.ErrorCode#</td>
						</tr>
					</cfif>
					
				</table>
					#exception.cause.message#
			</cfoutput>
			<hr>
			Exceptions:
			<hr>
			
			<cfdump var="#exception#" label="exception">
			<cfloop collection="#session#" item="key">
				<cfif len(session[key]) gt 0>
					#key#: #session[key]#<br />
				</cfif>
			</cfloop>



			
			<hr>
			<cfif isdefined("session")>
				Session Dump:
				<hr>
				<cfdump var="#session#" label="session">
			</cfif>
			<hr>
			Form Dump:
			<hr>
			<cfdump var="#form#" label="form">
			<hr>
			URL Dump:
			<hr>
			<cfdump var="#url#" label="url">
			CGI Dump:
			<hr>
			<cfdump var="#CGI#" label="CGI">
		</cfsavecontent>
		<cfif isdefined("exception.errorCode") and exception.errorCode is "403">
			<cfset subject="locked form">
		<cfelse>
			<cfif isdefined("exception.detail")>
				<cfif exception.detail contains "[Macromedia][Oracle JDBC Driver][Oracle]ORA-00600">
					<cfset subject="[Macromedia][Oracle JDBC Driver][Oracle]ORA-00600">
				<cfelse>
					<cfset subject="#exception.detail#">
				</cfif>
			<cfelse>
				<cfset subject="Unknown Error">
			</cfif>
		</cfif>
		<cfif isdefined("session.username") and session.username is "dlm">
			<cfoutput>
				#errortext#
			</cfoutput>
		</cfif>
		<cfmail subject="#subject#" to="#Application.PageProblemEmail#" from="SomethingBroke@#Application.fromEmail#" type="html">
			#errortext#
		</cfmail>	
		<table cellpadding="10">
			<tr>
				<td valign="top">
					<img src="/images/blowup.gif">
				</td>
				<td>
    				<font color="##FF0000" size="+1"><strong>An error occurred while processing this page!</strong></font>
					<cfif isdefined("exception.message")>
						<br><i><cfoutput>#exception.message#
						<cfif isdefined("exception.detail")>
							<br>#exception.detail#
						</cfif>
						</cfoutput></i>
					</cfif>
					<p>This message has been logged. Please <a href="/contact">contact us</a> 
					with any information that might help us to resolve this problem.</p>
				</td>
			</tr>
		</table>
		<cfinclude template="/includes/_footer.cfm">
	</cfif>
	<cfreturn/>
</cffunction>
<!-------------------------->
<cffunction name="onApplicationStart" returnType="boolean" output="true">
	<cfscript>
		serverName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName();
	</cfscript>
	<!---
	<cfmail subject="server startingt" to="arctos.database@gmail.com" from="serverStart@arctos.database.museum" type="html">
		<cfoutput>#serverName# is starting</cfoutput>
	</cfmail>
	---->
	<cfset Application.session_timeout=90>
	<cfset Application.serverRootUrl = "http://#serverName#">
	<cfset Application.user_login="user_login">
	<cfset Application.max_pw_age = 90>
	<cfset Application.fromEmail = "#serverName#">
	<cfset Application.domain = replace(Application.serverRootUrl,"http://",".")>
	<cfif serverName is "arctos.database.museum">
		<cfset Application.serverRootUrl="http://arctos.database.museum">
		<cfset Application.fromEmail="arctos.database.museum">
		<cfset application.gmap_api_key="AIzaSyA7u0Kb5JlhHlkdgsTmG0zYtg1LXxpn8HY">
		<cfset Application.webDirectory = "/corral/tg/uaf/arctos_prod">
		<cfset Application.DownloadPath = "#Application.webDirectory#/download/">
		<cfset Application.bugReportEmail = "arctos.database@gmail.com,gordon.jarrell@gmail.com">
		<cfset Application.technicalEmail = "arctos.database@gmail.com,gordon.jarrell@gmail.com">
		<cfset Application.mapHeaderUrl = "#Application.serverRootUrl#/images/nada.gif">
		<cfset Application.mapFooterUrl = "#Application.serverRootUrl#/bnhmMaps/BerkMapFooter.html">
		<cfset Application.genBankPrid = "3849">
		<cfset Application.genBankUsername="uam">
		<cfset Application.convertPath = "/usr/local/bin/convert">
		<cfset Application.genBankPwd=encrypt("bU7$f%Nu","genbank")>
		<cfset Application.BerkeleyMapperConfigFile = "/bnhmMaps/UamConfig.xml">
		<cfset Application.Google_uacct = "UA-315170-1">
		<cfset Application.InstitutionBlurb = "">
		<cfset Application.DataProblemReportEmail = "arctos.database@gmail.com">
		<cfset Application.PageProblemEmail = "arctos.database@gmail.com">
	<cfelseif serverName is "arctos-test.arctos.database.museum">
		<cfset application.gmap_api_key="ABQIAAAAO1U4FM_13uDJoVwN--7J3xRt-ckefprmtgR9Zt3ibJoGF3oycxTHoy83TEZbPAjL1PURjC9X2BvFYg">
		<cfset Application.webDirectory = "/usr/local/apache2/htdocs">
		<cfset Application.DownloadPath = "#Application.webDirectory#/download/">
		<cfset Application.bugReportEmail = "arctos.database@gmail.com">
		<cfset Application.technicalEmail = "arctos.database@gmail.com">
		<cfset Application.mapHeaderUrl = "#Application.serverRootUrl#/images/nada.gif">
		<cfset Application.mapFooterUrl = "#Application.serverRootUrl#/bnhmMaps/BerkMapFooter.html">
		<cfset Application.genBankPrid = "3849">
		<cfset Application.genBankUsername="uam">
		<cfset Application.convertPath = "/usr/local/bin/convert">
		<cfset Application.genBankPwd=encrypt("bU7$f%Nu","genbank")>
		<cfset Application.BerkeleyMapperConfigFile = "/bnhmMaps/UamConfig.xml">
		<cfset Application.Google_uacct = "UA-315170-1">
		<cfset Application.InstitutionBlurb = "">
		<cfset Application.DataProblemReportEmail = "arctos.database@gmail.com">
		<cfset Application.PageProblemEmail = "arctos.database@gmail.com">
    <cfelseif serverName contains "harvard.edu">
		<cfset Application.svn = "/usr/bin/svn">
		<cfset Application.webDirectory = "/var/www/html/arctosv.2.2.2">
		<cfset Application.SpecimenDownloadPath = "/var/www/html/arctosv.2.2.2/download/">
		<cfset Application.bugReportEmail = "bhaley@oeb.harvard.edu">
		<cfset Application.technicalEmail = "bhaley@oeb.harvard.edu">
		<cfset Application.mapHeaderUrl = "#Application.serverRootUrl#/images/nada.gif">
		<cfset Application.mapFooterUrl = "#serverRootUrl#/bnhmMaps/BerkMapFooter.html">
		<cfset Application.genBankPrid = "">
		<cfset Application.genBankUsername="">
		<cfset Application.convertPath = "/usr/bin/convert">
		<cfset Application.genBankPwd=encrypt("Uln1OAzy","genbank")>
		<cfset Application.BerkeleyMapperConfigFile = "/bnhmMaps/UamConfig.xml">
		<cfset Application.Google_uacct = "">
		<cfset Application.InstitutionBlurb = "Collections Database, Museum of Comparative Zoology, Harvard University">
		<cfset Application.DataProblemReportEmail = "bhaley@oeb.harvard.edu">
		<cfset Application.PageProblemEmail = "bhaley@oeb.harvard.edu">
    <cfelseif serverName is "login.corral.tacc.utexas.edu" or serverName is "altai.corral.tacc.utexas.edu">
		<cfset application.gmap_api_key="AIzaSyA7u0Kb5JlhHlkdgsTmG0zYtg1LXxpn8HY">
		<cfset Application.webDirectory = "/corral/tg/uaf/wwwarctos">
		<cfset Application.DownloadPath = "#Application.webDirectory#/download/">
		<cfset Application.bugReportEmail = "dustymc@gmail.com">
		<cfset Application.technicalEmail = "dustymc@gmail.com">
		<cfset Application.mapHeaderUrl = "#Application.serverRootUrl#/images/nada.gif">
		<cfset Application.mapFooterUrl = "#Application.serverRootUrl#/bnhmMaps/BerkMapFooter.html">
		<cfset Application.genBankPrid = "3849">
		<cfset Application.genBankUsername="uam">
		<cfset Application.convertPath = "/usr/local/bin/convert">
		<cfset Application.genBankPwd=encrypt("bU7$f%Nu","genbank")>
		<cfset Application.BerkeleyMapperConfigFile = "/bnhmMaps/UamConfig.xml">
		<cfset Application.Google_uacct = "UA-315170-1">
		<cfset Application.InstitutionBlurb = "">
		<cfset Application.DataProblemReportEmail = "dustymc@gmail.com">
		<cfset Application.PageProblemEmail = "dustymc@gmail.com">
	<cfelseif serverName is "meta-1.corral.tacc.utexas.edu">
		<cfset Application.serverRootUrl="http://arctos.database.museum">
		<cfset Application.fromEmail="arctos.database.museum">
		<cfset application.gmap_api_key="AIzaSyA7u0Kb5JlhHlkdgsTmG0zYtg1LXxpn8HY">
		<cfset Application.webDirectory = "/corral/tg/uaf/arctos_prod">
		<cfset Application.DownloadPath = "#Application.webDirectory#/download/">
		<cfset Application.bugReportEmail = "arctos.database@gmail.com,gordon.jarrell@gmail.com">
		<cfset Application.technicalEmail = "arctos.database@gmail.com,gordon.jarrell@gmail.com">
		<cfset Application.mapHeaderUrl = "#Application.serverRootUrl#/images/nada.gif">
		<cfset Application.mapFooterUrl = "#Application.serverRootUrl#/bnhmMaps/BerkMapFooter.html">
		<cfset Application.genBankPrid = "3849">
		<cfset Application.genBankUsername="uam">
		<cfset Application.convertPath = "/usr/local/bin/convert">
		<cfset Application.genBankPwd=encrypt("bU7$f%Nu","genbank")>
		<cfset Application.BerkeleyMapperConfigFile = "/bnhmMaps/UamConfig.xml">
		<cfset Application.Google_uacct = "UA-315170-1">
		<cfset Application.InstitutionBlurb = "">
		<cfset Application.DataProblemReportEmail = "arctos.database@gmail.com">
		<cfset Application.PageProblemEmail = "arctos.database@gmail.com">
	</cfif>
	<cftry>
		<cfquery name="d" datasource="uam_god">
			select ip from uam.blacklist
		</cfquery>
		<cfset Application.blacklist=valuelist(d.ip)>
	<cfcatch>
		<cfset Application.blacklist="">
		<cfmail subject="bad app start" to="#Application.PageProblemEmail#" from="badAppStart@#application.fromEmail#" type="html">
			caught DB connect exception
			<cfdump var=#servername#>
			<cfdump var=#cfcatch#>
			<cfdump var="#variables#" label="variables">
			<cfdump var=#application# label="application">
			<cfdump var=#cgi# label="cgi">
		</cfmail>
	</cfcatch>
	</cftry>
	<!--- 
		sandbox is a 700-mode directory (necessary for CF to write) used for user-uploaded files.
		onRequestStart prevents CF executing contents
	--->	
	<cfset Application.sandbox = "#Application.webDirectory#/sandbox">
	<cfif not directoryExists(Application.sandbox)>
		<cfdirectory action="create" directory="#Application.sandbox#" mode="700">
	</cfif>
	<!--- just some disk swap space --->
	<cfif not directoryExists("#Application.webDirectory#/temp")>
		<cfdirectory action="create" directory="#Application.webDirectory#/temp" mode="744">
	</cfif>
	<!--- longer-lived temp, primarily for KML file cache --->
	<cfif not directoryExists("#Application.webDirectory#/cache")>
		<cfdirectory action="create" directory="#Application.webDirectory#/cache" mode="744">
	</cfif>
	<!--- user-demand downloads go here --->
	<cfif not directoryExists("#Application.webDirectory#/download")>
		<cfdirectory action="create" directory="#Application.webDirectory#/download" mode="744">
	</cfif>
	<cfreturn true>
</cffunction>
<!-------------------------------------------------------------->
<cffunction name="onSessionStart" output="false">
	<cfinclude template="/includes/functionLib.cfm">
	<cfset initSession()>
</cffunction>
<!-------------------------------------------------------------->
<cffunction name="onRequestStart" returnType="boolean" output="true">
	<!--- uncomment for a break from googlebot ---->
	<!----
	<cfif cgi.HTTP_USER_AGENT contains "bot" or cgi.HTTP_USER_AGENT contains "slurp" or cgi.HTTP_USER_AGENT contains "spider">
		<cfheader statuscode="503" statustext="Service Temporarily Unavailable"/>
		<cfheader name="retry-after" value="3600"/>
		Down for maintenance
		<cfreturn false>
		<cfabort>
	</cfif>
	---->
	<cfif not isdefined("application.blacklist")>
		<cfset application.blacklist="">
	</cfif>
	<cfif listfindnocase(application.blacklist,cgi.REMOTE_ADDR)>
		<cfif cgi.script_name is not "/errors/gtfo.cfm">
			<cfscript>
				getPageContext().forward("/errors/gtfo.cfm");
			</cfscript>
			<cfabort>
		</cfif>
	</cfif>
	<cfset nono="passwd,etc,proc">
	<cfloop list="#cgi.query_string#" delimiters="./," index="i">
		<cfif listfindnocase(nono,i)>
			<cfinclude template="/errors/autoblacklist.cfm">
			<cfabort>
		</cfif>
	</cfloop>
	<cfparam name="request.fixAmp" type="boolean" default="false">
	<cfif (NOT request.fixAmp) AND (findNoCase("&amp;", cgi.query_string ) gt 0)>
		<cfscript>
			request.fixAmp = true;
			queryString = replace(cgi.query_string, "&amp;", "&", "all");
			getPageContext().forward(cgi.script_Name & "?" & queryString);
		</cfscript>
		<cfabort>
	<cfelse>
		<cfscript>
			StructDelete(request, "fixAmp");
		</cfscript>
	</cfif> 
	<cfif not isdefined("session.roles")>
		<cfinclude template="/includes/functionLib.cfm">
		<cfset initSession()>
	</cfif>
	<cfset currentPath=GetDirectoryFromPath(GetTemplatePath())> 
	<!--- no reason for anyone to be in these, ever --->
	<cfif currentPath contains "/CustomTags/">
		<cfset r=replace(currentPath,application.webDirectory,"")>
		<cfscript>
			getPageContext().forward("/errors/forbidden.cfm?ref=#r#");
		</cfscript>
		<cfabort>
	</cfif>
	<!--- protect "us" directories --->
	<cfif (CGI.Remote_Addr is not "127.0.0.1") and 
		(not isdefined("session.roles") or session.roles is "public" or len(session.roles) is 0) and 
		(currentPath contains "/Admin/" or
		currentPath contains "/ALA_Imaging/" or
		currentPath contains "/Bulkloader/" or
		currentPath contains "/fix/" or
		currentPath contains "/picks/" or
		currentPath contains "/tools/" or
		currentPath contains "/ScheduledTasks/")>
			<cfset r=replace(currentPath,application.webDirectory,"")>
			<cfscript>
				getPageContext().forward("/errors/forbidden.cfm?ref=#r#");
			</cfscript>
			<cfabort>
	</cfif>
	<!--- disallow CF execution --->
	<cfif currentPath contains "/images/" or
		 currentPath contains "/download/" or
		 currentPath contains "/cache/" or
		 currentPath contains "/temp/" or
		 currentPath contains "/sandbox/">
		<cfset r=replace(currentPath,application.webDirectory,"")>
		<cfscript>
			getPageContext().forward("/errors/forbidden.cfm?ref=#r#");
		</cfscript>
		<cfabort>
	</cfif>
	<!--- keep people/bots from browsing a dev server 
	--->
	<cfif cgi.HTTP_HOST is "login.corral.tacc.utexas.edu" or cgi.HTTP_HOST is "altai.corral.tacc.utexas.edu">
		<cfset cPath=GetTemplatePath()>
		<cfif
			cPath does not contain "/errors/dev_login.cfm" and
			cPath does not contain "/login.cfm" and
			cPath does not contain "/ChangePassword.cfm" and
			cPath does not contain "/contact.cfm" and
			cPath does not contain "/dumpAll.cfm" and
			cPath does not contain "/get_short_doc.cfm" and
			len(session.username) is 0>
			<cflocation url="/errors/dev_login.cfm">
		</cfif>
	</cfif>
	<!--- people still have this thing bookmarked --->
	<cfif cgi.HTTP_HOST is "mvzarctos.berkeley.edu">
		<cfset rurl="http://arctos.database.museum">
		<cfif isdefined("cgi.redirect_url") and len(cgi.redirect_url) gt 0>
			<cfset rurl=rurl & cgi.redirect_url>
		<cfelseif isdefined("cgi.script_name") and len(cgi.script_name) gt 0>
			<cfif cgi.script_name is "/SpecimenSearch.cfm">
				<cfset rurl=rurl & "/mvz_all">
			<cfelse>
				<cfset rurl=rurl & cgi.script_name>
			</cfif>
		</cfif>
		<cfif len(cgi.query_string) gt 0>
			<cfset rurl=rurl & "?" & cgi.query_string>
		</cfif>
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfoutput><cfheader name="Location" value="#rurl#"></cfoutput>
	</cfif>
	<cfreturn true>
</cffunction>
</cfcomponent>