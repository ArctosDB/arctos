<cfoutput>
<cfsavecontent variable="loginfo">
------------------------------------------------------------------------------------------------------------------------------
LOG ENTRY: #dateformat(now(),"yyyy-mm-dd")# #TimeFormat(now(), "HH:mm:ss")#

<cfif isdefined("request")>

Request Dump:
<cfloop item="key" collection="#request#">
<cfif len(request[key]) gt 0>
#chr(10)##chr(9)##key# - #request[key]#
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
<cfif isdefined("exception")>

Exception Dump:
<cfloop item="key" collection="#exception#">
<cfif len(exception[key]) gt 0>
#chr(10)##chr(9)##key#: #exception[key]#
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
</cfsavecontent>

	<!----------
	<cfset loginfo="LOG ENTRY: #dateformat(now(),"yyyy-mm-dd")# #TimeFormat(now(), "HH:mm:ss")#">
	<cfset loginfo=loginfo & chr(10) & "Problem: 404">

	<cfset loginfo=loginfo & chr(10) & "Referrer: #cgi.HTTP_REFERER#">
		<cfset loginfo=loginfo & chr(10) & "cgi: " & cfdump var="cgi" format="text">

	-------->
	<cffile action="append" file="#Application.webDirectory#/log/log.txt" output="#loginfo#">
</cfoutput>
