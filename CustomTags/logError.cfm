<cfoutput>
<!-------
<cftry>

-------->
<cfif isdefined("attributes.cause.message")>
	<cfset exception.message=replace(attributes.cause.message,'[Macromedia][Oracle JDBC Driver][Oracle]','','all')>
</cfif>
<cfif isdefined("attributes.sql")>
	<cfset exception.sql=attributes.sql>
</cfif>

<cfif isdefined("attributes.cause") and structKeyExists(attributes.cause,"tagcontext")>
<cftry>
	<cfset exception.line=attributes.cause.tagContext[1].line>
<cfcatch></cfcatch>
</cftry>
</cfif>

<!---- see if we can figure out why there's an error ---->
<!--- first, just see if it's being explicitly handed in ---->
<cfif isdefined("attributes.subject") and len(attributes.subject) gt 0>
	<cfset exception.subject=attributes.subject>
<cfelse>
	<cfset exception.subject='unknown error'>
</cfif>
<!--- 
	now see if we can figure out an appropriate logfile
	make sure all these are initiated in application start
----->
<cfif exception.subject is "404">
	<cfset theLogFile="404log.txt">
<cfelseif exception.subject is "missing GUID">
	<cfset exception.theLogFile="missingGUIDlog.txt">
<cfelseif exception.subject is "autoblacklist">
	<cfset theLogFile="blacklistlog.txt">
<cfelse>
	<cfset theLogFile="log.txt">
</cfif>
<cfset exception.logfile=theLogFile>
<cfset exception.date='#dateformat(now(),"yyyy-mm-dd")#T#TimeFormat(now(), "HH:mm:ss")#'>


<cfif isdefined("form")>
	<cfloop item="key" collection="#form#">
		<cfif len(form[key]) gt 0>
			<cfset "exception.#key#"="#form[key]#">
		</cfif>
	</cfloop>
</cfif>
<cfif isdefined("request")>
	<cfloop item="key" collection="#request#">
		<cfif len(request[key]) gt 0>
			<cfset "exception.#key#"="#request[key]#">
		</cfif>
	</cfloop>
</cfif>
<cfif isdefined("cgi")>
	<cfloop item="key" collection="#cgi#">
		<cfif len(cgi[key]) gt 0>
			<cfset "exception.#key#"="#cgi[key]#">
		</cfif>
	</cfloop>
</cfif>
<cfif isdefined("URL")>
	<cfloop item="key" collection="#URL#">
		<cfif len(URL[key]) gt 0>
			<cfset "exception.#key#"="#URL[key]#">
		</cfif>
	</cfloop>
</cfif>
<cfif isdefined("session")>
	<cfloop item="key" collection="#session#">
		<cfif len(session[key]) gt 0>
			<cfset "exception.#key#"="#session[key]#">
		</cfif>
	</cfloop>
</cfif>
<cfsavecontent variable="rawexc">
<cfdump var=#attributes# format="text">
</cfsavecontent>
<cfset exception.rawExceptionDump=rawexc>
<!--- clean up the stuff we don't really care about --->
<cfif structkeyexists(exception,"HTTPS")>
	<cfset StructDelete(exception, "HTTPS")>
</cfif>
<cfif structkeyexists(exception,"header_color")>
	<cfset StructDelete(exception, "header_color")>
</cfif>
<cfif structkeyexists(exception,"header_image")>
	<cfset StructDelete(exception, "header_image")>
</cfif>
<cfif structkeyexists(exception,"institution_url")>
	<cfset StructDelete(exception, "institution_url")>
</cfif>
<cfif structkeyexists(exception,"mediasrchtab")>
	<cfset StructDelete(exception, "mediasrchtab")>
</cfif>	
<cfif structkeyexists(exception,"meta_description")>
	<cfset StructDelete(exception, "meta_description")>
</cfif>
<cfif structkeyexists(exception,"meta_keywords")>
	<cfset StructDelete(exception, "meta_keywords")>
</cfif>
<cfif structkeyexists(exception,"sessionid")>
	<cfset StructDelete(exception, "sessionid")>
</cfif>
<cfif structkeyexists(exception,"sessionkey")>
	<cfset StructDelete(exception, "sessionkey")>
</cfif>
<cfif structkeyexists(exception,"specsrchtab")>
	<cfset StructDelete(exception, "sesspecsrchtabsionkey")>
</cfif>
<cfif structkeyexists(exception,"taxsrchtab")>
	<cfset StructDelete(exception, "taxsrchtab")>
</cfif>
<cfif structkeyexists(exception,"SERVER_NAME")>
	<cfset StructDelete(exception, "SERVER_NAME")>
</cfif>
<cfif structkeyexists(exception,"SERVER_PORT")>
	<cfset StructDelete(exception, "SERVER_PORT")>
</cfif>
<cfif structkeyexists(exception,"SERVER_PORT_SECURE")>
	<cfset StructDelete(exception, "SERVER_PORT_SECURE")>
</cfif>
<cfif structkeyexists(exception,"SERVER_PROTOCOL")>
	<cfset StructDelete(exception, "SERVER_PROTOCOL")>
</cfif>
<cfif structkeyexists(exception,"downloadfilename")>
	<cfset StructDelete(exception, "downloadfilename")>
</cfif>
<cfif structkeyexists(exception,"epw")>
	<cfset StructDelete(exception, "epw")>
</cfif>
<cfif structkeyexists(exception,"flattablename")>
	<cfset StructDelete(exception, "flattablename")>
</cfif>
<cfif structkeyexists(exception,"getjulianday")>
	<cfset StructDelete(exception, "getjulianday")>
</cfif>
<cfif structkeyexists(exception,"urltoken")>
	<cfset StructDelete(exception, "urltoken")>
</cfif>
<cfif structkeyexists(exception,"institution_link_text")>
	<cfset StructDelete(exception, "institution_link_text")>
</cfif>
<!--- log as XML ---->
<cfset log="<logEntry>">
<cfloop item="key" collection="#exception#">
	<cfset log=log & "<#key#>#exception[key]#</#key#>">
</cfloop>
<cfset log="</logEntry>">
	<cffile action="append" file="#Application.webDirectory#/log/#theLogFile#" output="#log#">

<cfdump var=#exception#>
<cfmail subject="#exception.subject#" to="#Application.PageProblemEmail#" from="logs@#application.fromEmail#" type="html">
	<a href="http://network-tools.com/default.asp?prog=network&host=#exception.ipaddress#">[ lookup #exception.ipaddress# ]</a>
	<a href="http://arctos.database.museum/Admin/blacklist.cfm?action=ins&ip=#exception.ipaddress#">[ blacklist #exception.ipaddress# ]</a>
	<cfif structKeyExists(exception,"username")>
		Username: #exception.username#
	</cfif>
</cfmail>
	

	<!-----------
</summary>
<cfif isdefined("exception")>
	<exception>
		<cfloop item="key" collection="#exception#">
			<cfif len(exception[key]) gt 0>
			<#key#>#exception[key]#</#key#>
			</cfif>
		</cfloop>
	</exception>
</cfif>
<cfif isdefined("form")>

Form Dump:
<cfloop item="key" collection="#form#">
<cfif len(form[key]) gt 0>
#chr(10)##chr(9)##key#: #form[key]#
</cfif>
</cfloop>
</cfif>
<cfif isdefined("request")>

Request Dump:
<cfloop item="key" collection="#request#">
<cfif len(request[key]) gt 0>
#chr(10)##chr(9)##key#: #request[key]#
</cfif>
</cfloop>
</cfif>
<cfif isdefined("CGI")>

CGI Dump:
<cfloop item="key" collection="#cgi#">
<cfif len(cgi[key]) gt 0>
#chr(10)##chr(9)##key#: #cgi[key]#
</cfif>
</cfloop>
</cfif>
<cfif isdefined("URL")>

URL Dump:
<cfloop item="key" collection="#URL#">
<cfif len(URL[key]) gt 0>
#chr(10)##chr(9)##key#: #URL[key]#
</cfif>
</cfloop>
</cfif>

<cfif isdefined("session")>

Session Dump:
<cfloop item="key" collection="#session#">
<cfif len(session[key]) gt 0>
#chr(10)##chr(9)##key#: #session[key]#
</cfif>
</cfloop>
</cfif>

Attributes rawfile:

<cfdump var=#attributes# format="text">
</logEntry>
</cfsavecontent>

	<!----------
	<cfset loginfo="LOG ENTRY: #dateformat(now(),"yyyy-mm-dd")# #TimeFormat(now(), "HH:mm:ss")#">
	<cfset loginfo=loginfo & chr(10) & "Problem: 404">

	<cfset loginfo=loginfo & chr(10) & "Referrer: #cgi.HTTP_REFERER#">
		<cfset loginfo=loginfo & chr(10) & "cgi: " & cfdump var="cgi" format="text">

	-------->
	<cfset htmlLogInfo=replace(loginfo,chr(10),"<br>","all")>
	
	
	
	<!---------
	<cfcatch>
		<cfmail subject="error logging exception" to="#Application.PageProblemEmail#" from="logsproblem@#application.fromEmail#" type="html">
			<a href="http://network-tools.com/default.asp?prog=network&host=#request.ipaddress#">[ lookup #request.ipaddress# ]</a>
			<a href="http://arctos.database.museum/Admin/blacklist.cfm?action=ins&ip=#request.ipaddress#">[ blacklist #request.ipaddress# ]</a>
			<cfdump var=#form#>
			<cfdump var=#exception#>
			<cfdump var=#session#>
			<cfdump var=#url#>
			<cfdump var=#request#>
			<cfdump var=#CGI#>
	
		</cfmail>
	</cfcatch>
	</cftry>
	-------->
	
	----------->
</cfoutput>
