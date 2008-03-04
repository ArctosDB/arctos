<cfcomponent>
<cfset This.name = "Arctos">
<cfset This.SessionManagement="True">
<cfset This.ClientManagement="True">

<cffunction name="onError">
    <cfargument name="exception" required="true">
    <cfargument name="EventName" type="String" required="true">
	<cfset showErr=1>
    <cfif isdefined("exception.type") and exception.type eq "coldfusion.runtime.AbortException">
        <cfset showErr=0>
		<cfreturn/>
	</cfif>
	<cfif StructKeyExists(form,"C0-METHODNAME")>
		<!--- cfajax calling cfabort --->
		<cfset showErr=0>
		<cfreturn/>
	</cfif>
	<cfif #showerr# is 1>
		<cfsavecontent variable="errortext">
			Exceptions:
			<hr>
			<cfdump var="#exception#" label="exception">
			<hr>
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
			<CFIF isdefined("CGI.HTTP_X_Forwarded_For") and #len(CGI.HTTP_X_Forwarded_For)# gt 0>
				<CFSET ipaddress="#CGI.HTTP_X_Forwarded_For#">
			<CFELSEif  isdefined("CGI.Remote_Addr") and #len(CGI.Remote_Addr)# gt 0>
				<CFSET ipaddress="#CGI.Remote_Addr#">
			<cfelse>
				<cfset ipaddress='unknown'>
			</CFIF>
			<p>ipaddress: <cfoutput>#ipaddress#</cfoutput></p>
		</cfsavecontent>
		<cfif isdefined("client.username") and #client.username# is "fselm10" or
			#client.username# is "brandy" or
			#client.username# is "dlm" or
			#client.username# is "sumy" or
			#client.username# is "Rhiannon" or
				#client.username# is "dusty">
			<cfoutput>
				#errortext#
			</cfoutput>		
		</cfif>
		<cfmail subject="Error" to="#Application.PageProblemEmail#" from="SomethingBroke@#Application.fromEmail#" type="html">
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
					with any infomation that might help us to resolve this problem.</p>
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
	<cfset Application.web_user = "MCAT_WU">
	<cfset Application.uam_dbo = "MCAT_UD">
	<cfset Application.serverRootUrl = "http://#HTTP_HOST#">
	<cfset Application.user_login="user_login">
	<cfset Application.max_pw_age = 90>
	<cfset Application.fromEmail = "#HTTP_HOST#">
	<cfset Application.header_color = "##E7E7E7">
	<cfset Application.header_image = "/images/genericHeaderIcon.gif">
	<cfset Application.collection_url = "/">
	<cfset Application.collection_link_text = "Arctos">
	<cfset Application.institution_url = "/">
	<cfset Application.stylesheet = "">
	<cfset Application.institution_link_text = "Multi-Institution, Multi-Collection Museum Database">
	<cfset Application.meta_description = "Arctos is a biological specimen database.">
	<cfset Application.meta_keywords = "museum, collection, management, system">
	<cfset Application.domain = replace(Application.serverRootUrl,"http://",".")>
	<cfset Application.fromEmail = "#HTTP_HOST#">
		
	<cfif #cgi.HTTP_HOST# contains "database.museum">		
		<cfset Application.svn = "/usr/local/bin/svn">
		<cfset Application.webDirectory = "/var/www/html">
		<cfset Application.SpecimenDownloadPath = "/var/www/html/download/">
		<cfset Application.bugReportEmail = "dustymc@gmail.com,fnghj@uaf.edu">
		<cfset Application.technicalEmail = "dustymc@gmail.com,fnghj@uaf.edu">
		<cfset Application.mapHeaderUrl = "#Application.serverRootUrl#/images/nada.gif">
		<cfset Application.mapFooterUrl = "#Application.serverRootUrl#/bnhmMaps/BerkMapFooter.html">
		<cfset Application.genBankPrid = "3849">
		<cfset Application.genBankUsername="uam">
		<cfset Application.convertPath = "/usr/bin/convert">
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
	<cfelseif #cgi.HTTP_HOST# contains "berkeley.edu">
		<cfset Application.header_color = "white">
		<cfset Application.header_image = "/images/MVZ_fancy_logo.jpg">
		<cfset Application.collection_url = "http://mvz.berkeley.edu">
		<cfset Application.collection_link_text = "Collections Database">
		<cfset Application.institution_url = "http://mvz.berkeley.edu">
		<cfset Application.institution_link_text = "MUSEUM OF VERTEBRATE ZOOLOGY">
		<cfset Application.svn = "/opt/csw/bin/svn">
		<cfset Application.webDirectory = "/users/mvzarctos/tomcat/webapps/cfusion">
		<cfset Application.SpecimenDownloadPath = "/users/mvzarctos/tomcat/webapps/cfusion/download/">
		<cfset Application.bugReportEmail = "dustymc@gmail.com,ccicero@berkeley.edu,mvzdata@lists.berkeley.edu">
		<cfset Application.technicalEmail = "dustymc@gmail.com,lkvoong@berkeley.edu">
		<cfset Application.mapHeaderUrl = "http://mvz.berkeley.edu/images/nada.gif">
		<cfset Application.mapFooterUrl = "#Application.serverRootUrl#/images/Logos/bnhm_logo_small.gif">
		<cfset Application.genBankPrid = "4537">
		<cfset Application.genBankUsername="mvz">
		<cfset Application.convertPath = "/opt/csw/bin/convert">
		<cfset Application.genBankPwd=encrypt("Uln1OAzy","genbank")>
		<cfset Application.BerkeleyMapperConfigFile = "/bnhmMaps/MvzConfig.xml">
		<cfset Application.Google_uacct = "UA-936774-1">
		<cfset Application.InstitutionBlurb = "<a href=""#Application.serverRootUrl#"">Collections Database, Museum of Vertebrate Zoology, UC Berkeley</a>">
		<cfset Application.DataProblemReportEmail = "dustymc@gmail.com">
		<cfset Application.PageProblemEmail = "dustymc@gmail.com,lkv@berkeley.edu,ccicero@berkeley.edu">
	</cfif>
	<cfreturn true>
</cffunction>
<!-------------------------------------------------------------->
<cffunction name="onRequestStart" returnType="boolean" output="false">
	<cfset currentPath=GetDirectoryFromPath(GetTemplatePath())> 
	<cfif currentPath contains "/CustomTags/" OR
		currentPath contains "/binary_stuff/" OR
		currentPath contains "/includes/" OR
		currentPath contains "/log/">
		<cflocation url="/info/forbidden.cfm" addtoken="false">
	</cfif>
		<cfset Client.SpecimenDownloadFileName = "ArctosData_#cfid##cftoken#.txt">
		<cfif not isdefined("client.target")>
			<cfset client.target="_self">
		</cfif>
		<cfif not isdefined("client.mapSize")>
			<cfset client.mapSize="">
		</cfif>
		<cfif not isdefined("client.roles")>
			<cfset client.roles="public">
			<!--- protect "us" directories --->
			<cfif #currentPath# contains "Admin" or 
				#currentPath# contains "ALA_Imaging" or
				#currentPath# contains "Bulkloader" or
				#currentPath# contains "fix" or
				#currentPath# contains "picks" or
				#currentPath# contains "ScheduledTasks" or
				#currentPath# contains "tools">
			<cflocation url="/info/forbidden.cfm" addtoken="false">
		</cfif>
		<cfif not isdefined("client.showObservations")>
			<cfset client.showObservations="">
		</cfif>
		<cfif not isdefined("client.username")>
			<cfset client.username="">
		</cfif>
		<cfif not isdefined("client.killrow")>
			<cfset client.killrow="0">
		</cfif>
		<cfif not isdefined("client.searchBy")>
			<cfset client.searchBy="">
		</cfif>
		<cfif not isdefined("client.exclusive_collection_id")>
			<cfset client.exclusive_collection_id="">
		</cfif>
		<cfif not isdefined("client.last_login")>
			<cfset client.last_login="">
		</cfif>
		<cfif not isdefined("client.customOtherIdentifier")>
			<cfset client.customOtherIdentifier="">
		</cfif>
		<cfif not isdefined("client.displayrows") or len(client.displayrows) is 0>
			<cfset client.displayrows="20">
		</cfif>
		<cfif not isdefined("client.loan_request_coll_id")>
			<cfset client.loan_request_coll_id="">
		</cfif>
		<cfif not isdefined("client.resultColumnList")>
			<cfset client.resultColumnList="">
		</cfif>
		<cfif not isdefined("client.LastLogin")>
			<cfset client.LastLogin="">
		</cfif>
		<cfif len(#client.username#) gt 0>
			<cfquery name="gcid" datasource="#Application.web_user#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
				select agent_id from agent_name where agent_name='#client.username#'
				and agent_name_type='login'
			</cfquery>
			<cfif gcid.recordcount is 1>
				<cfset client.myAgentId=#gcid.agent_id#>
			</cfif>
		</cfif>
	<cfreturn true>
</cffunction>
</cfcomponent>