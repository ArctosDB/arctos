<cfcomponent>
<cfset This.name = "Arctos">
<cfset This.SessionManagement="True">
<cfset This.ClientManagement="true">
<cfset This.ClientStorage="Cookie">

<cffunction name="onMissingTemplate" returnType="boolean" output="false">
   <cfargument name="thePage" type="string" required="true">
	<cfscript>
		getPageContext().forward("/errors/404.cfm");
	</cfscript>
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
	<cfif #showerr# is 1>
		<cfsavecontent variable="errortext">
			<CFIF isdefined("CGI.HTTP_X_Forwarded_For") and #len(CGI.HTTP_X_Forwarded_For)# gt 0>
				<CFSET ipaddress="#CGI.HTTP_X_Forwarded_For#">
			<CFELSEif  isdefined("CGI.Remote_Addr") and #len(CGI.Remote_Addr)# gt 0>
				<CFSET ipaddress="#CGI.Remote_Addr#">
			<cfelse>
				<cfset ipaddress='unknown'>
			</CFIF>
			<cfoutput>
			<p>ipaddress: <a href="http://network-tools.com/default.asp?prog=network&host=#ipaddress#">#ipaddress#</a></p>
			<cfif isdefined("session.username")>
				<br>Username: #session.username#
			</cfif>
			<cfif isdefined("exception.Sql")>
				<p>Sql: #exception.Sql#</p>
			</cfif>			
			</cfoutput>
			<hr>
			Exceptions:
			<hr>
			<cfdump var="#exception#" label="exception">
			<hr>
			<cfif isdefined("session")>
				Session Dump:
				<hr>
				<cfdump var="#session#" label="session">
			</cfif>
			Client Dump:
			<hr>
			<cfdump var="#client#" label="client">
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
		<cfif isdefined("session.username") and 
			(#session.username# is "fselm10" or
			#session.username# is "brandy" or
			#session.username# is "dlm" or
			#session.username# is "sumy" or
			#session.username# is "Rhiannon" or
			#session.username# is "dusty")>
			<cfoutput>
				#errortext#
			</cfoutput>		
		</cfif>
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
					<p>This message has been logged. Please submit a <a href="/info/bugs.cfm">bug report</a> 
					with any information that might help us to resolve this problem.</p>
				</td>
			</tr>
		</table>
		<cfinclude template="/includes/_footer.cfm">
	</cfif>
	<cfreturn/>
</cffunction>
<!-------------------------->
<cffunction name="onApplicationStart" returnType="boolean" output="false">
	<cfset Application.session_timeout=90>
	<cfset Application.serverRootUrl = "http://#HTTP_HOST#">
	<cfset Application.user_login="user_login">
	<cfset Application.max_pw_age = 90>
	<cfset Application.fromEmail = "#HTTP_HOST#">
	<cfset Application.domain = replace(Application.serverRootUrl,"http://",".")>
	<cfset Application.fromEmail = "#HTTP_HOST#">
	<cfquery name="d" datasource="uam_god">
		select ip from uam.blacklist
	</cfquery>
	<cfset Application.blacklist=valuelist(d.ip)>
	<cfif #cgi.HTTP_HOST# is "arctos.database.museum">
		<cfset application.gmap_api_key="ABQIAAAAO1U4FM_13uDJoVwN--7J3xRmuGmxQ-gdo7TWENOfdvPP48uvgxS1Mi5095Z-7DsupXP1SWQjdYKK_w">	
		<cfset Application.svn = "/usr/local/bin/svn">
		<cfset Application.webDirectory = "/usr/local/apache2/htdocs">
		<cfset Application.DownloadPath = Application.webDirectory & "/download/">
		<cfset Application.bugReportEmail = "dustymc@gmail.com,gordon.jarrell@gmail.com,lkv@berkeley.edu">
		<cfset Application.technicalEmail = "dustymc@gmail.com,gordon.jarrell@gmail.com,lkv@berkeley.edu">
		<cfset Application.mapHeaderUrl = "#Application.serverRootUrl#/images/nada.gif">
		<cfset Application.mapFooterUrl = "#Application.serverRootUrl#/bnhmMaps/BerkMapFooter.html">
		<cfset Application.genBankPrid = "3849">
		<cfset Application.genBankUsername="uam">
		<cfset Application.convertPath = "/usr/local/bin/convert">
		<cfset Application.genBankPwd=encrypt("bU7$f%Nu","genbank")>
		<cfset Application.BerkeleyMapperConfigFile = "/bnhmMaps/UamConfig.xml">
		<cfset Application.Google_uacct = "UA-315170-1">
		<cfset Application.InstitutionBlurb = "">
		<cfset Application.DataProblemReportEmail = "dustymc@gmail.com,lkv@berkeley.edu">
		<cfset Application.PageProblemEmail = "dustymc@gmail.com,lkv@berkeley.edu">
	<cfelseif #cgi.HTTP_HOST# is "arctos-test.arctos.database.museum">
		<cfset application.gmap_api_key="ABQIAAAAO1U4FM_13uDJoVwN--7J3xRt-ckefprmtgR9Zt3ibJoGF3oycxTHoy83TEZbPAjL1PURjC9X2BvFYg">
        <cfset Application.svn = "/usr/local/bin/svn">
		<cfset Application.webDirectory = "/usr/local/apache2/htdocs">
		<cfset Application.DownloadPath = "#Application.webDirectory#/download/">
		<cfset Application.bugReportEmail = "dustymc@gmail.com">
		<cfset Application.technicalEmail = "dustymc@gmail.com,lkv@berkeley.edu">
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
    <cfelseif #cgi.HTTP_HOST# contains "harvard.edu">
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
	<cfif listfindnocase(application.blacklist,cgi.REMOTE_ADDR)>
		<cfif cgi.script_name is not "/errors/gtfo.cfm">
			<cfscript>
				getPageContext().forward("/errors/gtfo.cfm");
			</cfscript>
			<cfabort>
		</cfif>
	</cfif>
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
	<cfif currentPath contains "/CustomTags/" OR
		currentPath contains "/binary_stuff/" OR
		currentPath contains "/log/">
			<cfset r=replace(currentPath,application.webDirectory,"")>
			<cflocation url="/errors/forbidden.cfm?ref=#r#" addtoken="false">
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
			<cfset r=replace(#currentPath#,#application.webDirectory#,"")>
			<cfscript>
				getPageContext().forward("/errors/forbidden.cfm");
			</cfscript>
			<cfabort>
			<!---
			<cflocation url="/errors/forbidden.cfm?ref=#r#" addtoken="false">
			----->
			@fail - abort, etc.
	</cfif>
	<cfif cgi.HTTP_HOST is "arctos-test.arctos.database.museum" and 
			#GetTemplatePath()# does not contain "/errors/dev_login.cfm" and
			#GetTemplatePath()# does not contain "/login.cfm" and
			#GetTemplatePath()# does not contain "/ChangePassword.cfm" and
			len(session.username) is 0>
		<cflocation url="/errors/dev_login.cfm">	
	<cfelseif cgi.HTTP_HOST is "mvzarctos.berkeley.edu">
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