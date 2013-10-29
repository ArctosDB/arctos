<cfoutput>
<!---- see if we can figure out why there's an error ---->
<!--- first, just see if it's being explicitly handed in ---->
<cfif isdefined("caller.subject") and len(caller.subject) gt 0>
	<cfset subject=caller.subject>
<cfelse>
	<cfset caller.subject='unknown error'>
</cfif>

<!------






<table border width="800px;">
					<tr>
						<td colspan="2" align="center">
							<strong>Summary</strong>
						</td>
					</tr>
					<cfif isdefined("exception.cause.message")>
						<tr>
							<td>Message</td>
							<td>#replace(exception.cause.message,'[Macromedia][Oracle JDBC Driver][Oracle]','')#</td>
						</tr>
					<cfelseif isdefined("exception.Message")>
						<tr>
							<td>Message</td>
							<td>#exception.Message#</td>
						</tr>
					</cfif>
					<tr>
						<td>IP</td>
						<td>
							#request.ipaddress#
							<a href="http://network-tools.com/default.asp?prog=network&host=#request.ipaddress#">[ lookup ]</a>
							<a href="http://arctos.database.museum/Admin/blacklist.cfm?action=ins&ip=#request.ipaddress#">[ blacklist ]</a>
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
							<td>SQL</td>
							<td>#exception.Sql#</td>
						</tr>
					</cfif>

					<cfif structKeyExists(exception,"tagcontext")>
						<!----
						<cfloop index="stack" from="1" to="#arrayLen(exception.tagContext)#">
						<tr>
							<td>Line</td>
							<td>#exception.tagContext[stack].line#</td>
						</tr>
						</cfloop>
						---->
						<tr>
							<td>Line</td>
							<td>
								<cftry>
									#exception.tagContext[1].line#
								<cfcatch>
									-no line - see exception dump -
								</cfcatch>
								</cftry>
							</td>
						</tr>
					</cfif>



					<cfif isdefined("cgi.redirect_url")>
						<tr>
							<td>Path</td>
							<td>#cgi.redirect_url#</td>
						</tr>
					</cfif>
					<cfif isdefined("cgi.PATH_TRANSLATED")>
						<tr>
							<td>Path</td>
							<td>#cgi.PATH_TRANSLATED#</td>
						</tr>
					</cfif>
					<cfif isdefined("form")>
						<tr>
							<td colspan="2" align="center">
								<strong>Form</strong>
							</td>
						</tr>
						<cfloop collection="#form#" item="key">
							<cfif len(form[key]) gt 0>
								<tr>
									<td>#key#</td>
									<td>#rereplace(form[key],'(.),(.)','\1, \2','all')#</td>
								</tr>
							</cfif>
						</cfloop>
					</cfif>
					<cfif isdefined("url")>
						<tr>
							<td colspan="2" align="center">
								<strong>URL</strong>
							</td>
						</tr>
						<cfloop collection="#url#" item="key">
							<cfif len(url[key]) gt 0>
								<tr>
									<td>#key#</td>
									<td>#rereplace(url[key],'(.),(.)','\1, \2','all')#</td>
								</tr>
							</cfif>
						</cfloop>
					</cfif>
					<cfif isdefined("cgi")>
						<tr>
							<td colspan="2" align="center">
								<strong>CGI</strong>
							</td>
						</tr>
						<cfloop collection="#cgi#" item="key">
							<cfif len(cgi[key]) gt 0>
								<tr>
									<td>#key#</td>
									<td>#rereplace(cgi[key],'(.),(.)','\1, \2','all')#</td>
								</tr>
							</cfif>
						</cfloop>
					</cfif>
					<cfif isdefined("session")>
						<tr>
							<td colspan="2" align="center">
								<strong>Session</strong>
							</td>
						</tr>
						<cfloop collection="#session#" item="key">
							<cfif len(session[key]) gt 0>
								<tr>
									<td>#key#</td>
									<td>#rereplace(session[key],'(.),(.)','\1, \2','all')#</td>
								</tr>
							</cfif>
						</cfloop>
					</cfif>
					<tr>
						<td colspan="2" align="center">
							<strong>Exception Structure</strong>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<cfdump var="#exception#" label="exception">
						</td>
					</tr>
				</table>
				
				
				






------------->
<cfsavecontent variable="loginfo">
------------------------------------------------------------------------------------------------------------------------------
LOG ENTRY: #dateformat(now(),"yyyy-mm-dd")# #TimeFormat(now(), "HH:mm:ss")#

SUBJECT: #subject#

				

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
