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
<cfif isdefined("session.username")>
	<cfset exception.username=session.username>
</cfif>
<cfset exception.ipaddress=request.ipaddress>




<cfif isdefined("form")>
	<cfloop item="key" collection="#form#">
		<cfif len(form[key]) gt 0>
			<cfset "exception.#key#"="#form[key]#">
		</cfif>
	</cfloop>
</cfif>


<cfdump var=#exception#>
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
	<cffile action="append" file="#Application.webDirectory#/log/#theLogFile#" output="#loginfo#">
	<cfset htmlLogInfo=replace(loginfo,chr(10),"<br>","all")>
	
	<cfmail subject="#subject#" to="#Application.PageProblemEmail#" from="logs@#application.fromEmail#" type="html">
		<a href="http://network-tools.com/default.asp?prog=network&host=#request.ipaddress#">[ lookup #request.ipaddress# ]</a>
		<a href="http://arctos.database.museum/Admin/blacklist.cfm?action=ins&ip=#request.ipaddress#">[ blacklist #request.ipaddress# ]</a>
		#htmlLogInfo#
	</cfmail>
	
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
