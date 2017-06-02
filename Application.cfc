<cfcomponent>
<cfset This.name = "Arctos">
<cfset This.SessionManagement=true>
<cfset This.ClientManagement=false>
<cfset utilities = CreateObject("component","component.utilities")>
<!------------------>

<cffunction name="onCFCRequest" access="public"  returntype="any" output="true">
	<cfargument type="string" name="cfc" required="true">
    <cfargument type="string" name="method" required="true">
    <cfargument type="struct" name="args" required="true">
	<!---- log the request  ---->
	<cfset loginfo="#dateformat(now(),'yyyy-mm-dd')#T#TimeFormat(now(), 'HH:mm:ss')#||#session.username#||#request.ipaddress#||#request.rdurl#||#request.uuid#">
	<cffile action="append" file="#Application.requestlog#" output="#loginfo#">
	<cfreturn true>
</cffunction>
<!--------------------------------------------->
<cffunction name="onError">
	<cfargument name="Exception" required=true/>
	<cfargument type="String" name="EventName" required=true/>
	<!--- don't time out the error handler! --->
	<cfsetting requesttimeout="300">
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
		<cfset subject="">
		<cfset x=utilities.checkRequest(exception)>
		<cfif isdefined("exception.errorCode") and exception.errorCode is "403">
			<cfif isdefined("HTTP_REFERER") and HTTP_REFERER contains "http://yandex.ru">
				<cfset bl_reason='referrer is yandex'>
				<cfinclude template="/errors/autoblacklist.cfm">
			<cfelse>
				<cfset subject="403">
				<cfif isdefined("exception.detail") and exception.detail contains "Unsupported browser-specific file request">
					<cfset subject="browser garbage">
				</cfif>
			</cfif>
		<cfelse>
			<cfif isdefined("exception.detail") and len(exception.detail) gt 0>
				<cfif exception.detail contains "[Macromedia][Oracle JDBC Driver][Oracle]ORA-00600">
					<cfset subject="ORA-00600">
				<cfelse>
					<cfset subject="#exception.detail#">
				</cfif>
			<cfelseif isdefined("exception.message") and len(exception.message) gt 0>
				<cfset subject=exception.message>
			</cfif>
		</cfif>
		<cfset subject=replace(subject,'[Macromedia]','','all')>
		<cfset subject=replace(subject,'[Oracle JDBC Driver]','','all')>
		<cfset subject=replace(subject,'[Oracle]','','all')>
		<cf_logError subject="#subject#" attributeCollection=#exception#>
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
					<cfif subject is "Execution timeout expired." and request.rdurl contains "SpecimenResults.cfm">
						<p>
							We impose no strict limits on the number of records that may be returned, but query time is limited. Following are some
							suggestions for dealing with timeout problems. Use the Contact link below if you are unable to get what you need.
							<ul>
								<li>
									After a <a href="/SpecimenResults.cfm?cat_num=1">successful search</a>, Click "Add/Remove Data Fields" and de-select unnecessary columns. Attributes are particularly expensive.
								</li>
								<li>Try a more specific search.
									<ul>
										<li>Scientific Name instead of Higher Taxonomy.</li>
										<li>Use longer substrings. (<em>E.g.</em>, OtherID contains 1 finds >1.5m specimens and will time out.)</li>
									</ul>
								 </li>
								<li>Add search criteria
									<ul>
										<li>include geography</li>
										<li>draw a bounding box on the map</li>
										<li>specify collector agent or other ID type</li>
										<li>Select collection(s)</li>
									</ul>
								</li>
							</ul>
						</p>
					</cfif>
					</cfif>
					<p>This message has been logged. Please <a href="/contact.cfm">contact us</a>
					with any information that might help us to resolve this problem.</p>
				</td>
			</tr>
		</table>
		<cfif isdefined("session.username") and session.username is "dlm">
			<cfdump var=#exception#>
		</cfif>
		<cfinclude template="/includes/_footer.cfm">
		<cfif isdefined("exception.errorCode")>
			<cfif exception.errorCode is "403">
				<cfheader statuscode="403" statustext="Forbidden">
				<cfabort>
			</cfif>
		</cfif>
	</cfif>
	<cfreturn/>
</cffunction>
<!-------------------------->
<cffunction name="onApplicationStart" returnType="boolean" output="true">
	<cfscript>
		serverName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName();
	</cfscript>
	<cfif serverName is "altai.corral.tacc.utexas.edu">
		<cfset serverName='login.corral.tacc.utexas.edu'>
	<cfelseif serverName is 'meta-1.corral.tacc.utexas.edu'>
		<cfset serverName='arctos.database.museum'>
	<cfelseif serverName is 'arctos-test'>
		<cfset serverName='arctos-test.tacc.utexas.edu'>
	<cfelseif serverName is 'arctos.tacc.utexas.edu'>
		<cfset serverName='arctos.database.museum'>
	</cfif>
	<!---
	<cfmail subject="server startingt" to="arctos.database@gmail.com" from="serverStart@arctos.database.museum" type="html">
		<cfoutput>#serverName# is starting</cfoutput>
	</cfmail>
	---->
	<cfset Application.session_timeout=90>
	<cfset Application.serverRootUrl = "https://#serverName#">
	<cfset Application.user_login="user_login">
	<cfset Application.max_pw_age = 180>
	<cfset Application.fromEmail = "#serverName#">
	<cfset Application.domain = replace(Application.serverRootUrl,"https://",".")>
	<cfset Application.mobileURL="/m">
	<cfquery name="cf_global_settings" datasource="uam_god">
		select LOG_EMAIL,BUG_REPORT_EMAIL,DATA_REPORT_EMAIL,GOOGLE_UACCT from cf_global_settings
	</cfquery>
	<cfset Application.bugReportEmail = cf_global_settings.BUG_REPORT_EMAIL>
	<cfset Application.DataProblemReportEmail = cf_global_settings.DATA_REPORT_EMAIL>
	<cfset Application.logEmail = cf_global_settings.LOG_EMAIL>
	<cfset Application.Google_uacct = cf_global_settings.GOOGLE_UACCT>
	<cfset Application.docURL = 'http://handbook.arctosdb.org/documentation'>
	<cfif serverName is "arctos.database.museum">
		<cfset Application.version="prod">
		<cfset Application.webDirectory = "/usr/local/httpd/htdocs/wwwarctos">
		<cfset Application.DownloadPath = "#Application.webDirectory#/download/">
    <cfelseif serverName contains "harvard.edu">
		<cfset Application.svn = "/usr/bin/svn">
		<cfset Application.webDirectory = "/var/www/html/arctosv.2.2.2">
		<cfset Application.SpecimenDownloadPath = "/var/www/html/arctosv.2.2.2/download/">
	<cfelseif serverName is "login.corral.tacc.utexas.edu">
		<cfset Application.webDirectory = "/corral/tg/uaf/wwwarctos">
		<cfset Application.DownloadPath = "#Application.webDirectory#/download/">
	<cfelseif serverName is  "arctos-test.tacc.utexas.edu">
		<cfset Application.version="test">
		<cfset Application.webDirectory = "/usr/local/httpd/htdocs/wwwarctos">
		<cfset Application.DownloadPath = "#Application.webDirectory#/download/">
	<cfelseif serverName is  "arctos.tacc.utexas.edu">
		<cfset Application.webDirectory = "/usr/local/httpd/htdocs/wwwarctos">
		<cfset Application.DownloadPath = "#Application.webDirectory#/download/">
	<cfelse>
		<cfset Application.webDirectory = "/corral/tg/uaf/wwwarctos">
		<cfset Application.DownloadPath = "#Application.webDirectory#/download/">
		<cfmail subject="bad app start" to="arctos.database@gmail.com" from="badAppStart@#application.fromEmail#" type="html">
			I don't know who I am
			serverName=<cfdump var="#serverName#">
			<cfdump var=#cgi# label="cgi">
		</cfmail>
	</cfif>
	<cfmail subject="good app start" to="arctos.database@gmail.com" from="badAppStart@#application.fromEmail#" type="html">
		just started
		serverName=<cfdump var="#serverName#">
		<cfdump var=#cgi# label="cgi">
	</cfmail>
	<cftry>
		<cfset utilities.setAppBL()>
	<cfcatch>
		<cfset Application.blacklist="">
		<cfset Application.subnet_blacklist="">
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

	<cfset Application.logfile="#Application.webDirectory#/../log/log.log">
	<cfif not FileExists("#Application.logfile#")>
	    <cffile action="write" file="#Application.logfile#" output="">
	</cfif>

	<cfset Application.404log="#Application.webDirectory#/../log/404log.log">
	<cfif not FileExists("#Application.404log#")>
	    <cffile action="write" file="#Application.404log#" output="">
	</cfif>

	<cfset Application.missingGUIDlog="#Application.webDirectory#/../log/missingGUIDlog.log">
	<cfif not FileExists("#Application.missingGUIDlog#")>
	    <cffile action="write" file="#Application.missingGUIDlog#" output="">
	</cfif>

	<cfset Application.blacklistlog="#Application.webDirectory#/../log/blacklistlog.log">
	<cfif not FileExists("#Application.blacklistlog#")>
	    <cffile action="write" file="#Application.blacklistlog#" output="">
	</cfif>

	<cfset Application.emaillog="#Application.webDirectory#/../log/emaillog.log">
	<cfif not FileExists("#Application.emaillog#")>
	    <cffile action="write" file="#Application.emaillog#" output="">
	</cfif>

	<cfset Application.requestlog="#Application.webDirectory#/../log/requestlog.log">
	<cfif not FileExists("#Application.requestlog#")>
	    <cffile action="write" file="#Application.requestlog#" output="">
	</cfif>
	<cfset Application.querylog="#Application.webDirectory#/../log/querylog.log">
	<cfif not FileExists("#Application.querylog#")>
	    <cffile action="write" file="#Application.querylog#" output="">
	</cfif>
	<cfreturn true>
</cffunction>
<!-------------------------------------------------------------->
<cffunction name="onSessionStart" output="true">
	<cfif cgi.HTTP_HOST contains "altai.corral.tacc.utexas.edu">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="http://login.corral.tacc.utexas.edu/">
		<cfabort>
	<cfelseif cgi.HTTP_HOST contains "meta-1.corral.tacc.utexas.edu">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="http://arctos.database.museum/">
		<cfabort>
	<cfelseif cgi.HTTP_HOST contains "web.arctos.database.museum">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="http://arctos.database.museum/">
		<cfabort>
	<cfelseif cgi.HTTP_HOST contains "arctos.tacc.utexas.edu">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="http://arctos.database.museum/">
	</cfif>
	<cfinclude template="/includes/functionLib.cfm">
	<cfset initSession()>
	<cfset utilities.getIpAddress()>
</cffunction>
<!-------------------------------------------------------------->
<cffunction name="onRequestStart" returnType="boolean" output="true">
	<!--- uncomment for a break from googlebot
	<cfif cgi.HTTP_USER_AGENT contains "bot" or cgi.HTTP_USER_AGENT contains "slurp" or cgi.HTTP_USER_AGENT contains "spider">
		<cfheader statuscode="503" statustext="Service Temporarily Unavailable"/>
		<cfheader name="retry-after" value="3600"/>
		Down for maintenance
		<cfreturn false>
		<cfabort>
	</cfif>
	---->
	<cfset request.rdurl=replacenocase(cgi.query_string,"path=","","all")>
	<cfset utilities.getIpAddress()>
	<!---
	<cfif isdefined("cgi.HTTP_USER_AGENT") and cgi.HTTP_USER_AGENT contains "CPython">
		<cfabort>
	</cfif>
	<cfif request.ipaddress is "128.227.73.141" or request.ipaddress is "128.227.190.172" or request.ipaddress is "128.227.173.188">
		<!--- iDigBio's horrid bot --->
		<cfabort>
	</cfif>
	 --->
	<cfif cgi.script_name is not "/errors/missing.cfm">
		<cfset request.rdurl=cgi.script_name & "?" & request.rdurl>
	</cfif>
	<cfset request.rdurl=replace("/" & request.rdurl,"//","/","all")>
	<cfif right(request.rdurl,1) is "?">
		<cfset request.rdurl=left(request.rdurl,len(request.rdurl)-1)>
	</cfif>
	<cfif request.rdurl contains chr(195) & chr(151)>
		<cfset request.rdurl=replace(request.rdurl,chr(195) & chr(151),chr(215))>
	</cfif>
	<!--- a unique identifier to tie "short" log entries to the raw dump file ---->
	<cfset request.uuid=CreateUUID()>
	<cfset utilities.checkRequest()>
	<!--- now that we're sanitized, continue with setting up a session etc. ---->
	<cfif not isdefined("session.roles")>
		<cfinclude template="/includes/functionLib.cfm">
		<cfset initSession()>
	</cfif>
    <cfset m=utilities.mobileDesktopRedirect()>
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
	<cfif (CGI.Remote_Addr is not "127.0.0.1" and CGI.Remote_Addr is not "0.0.0.0") and
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

	<!----
	<!--- keep people/bots from browsing a dev server--->

	---->

	<cfif application.version neq "prod" and not (CGI.Remote_Addr is "127.0.0.1" or CGI.Remote_Addr is "0.0.0.0")>
        <cfset cPath=GetTemplatePath()>
        <cfif
            cPath does not contain "/errors/dev_login.cfm" and
            cPath does not contain "/login.cfm" and
            cPath does not contain "/ChangePassword.cfm" and
            cPath does not contain "/contact.cfm" and
            cPath does not contain "/dumpAll.cfm" and
            cPath does not contain "/get_short_doc.cfm" and
            cPath does not contain "/errors/gtfo.cfm" and
            len(session.username) is 0>
            <cflocation url="/errors/dev_login.cfm" addtoken="false">
        </cfif>
    </cfif>


	<cfif listlast(cgi.script_name,".") is "cfm">
		<cfset loginfo="#dateformat(now(),'yyyy-mm-dd')#T#TimeFormat(now(), 'HH:mm:ss')#||#session.username#||#request.ipaddress#||#request.rdurl#||#request.uuid#">
		<cffile action="append" file="#Application.requestlog#" output="#loginfo#">
	</cfif>
	<cfreturn true>
</cffunction>
</cfcomponent>