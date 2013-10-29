<cfoutput>
<cfloop item="key" collection="#cgi#">
	<cfif len(cgi[key]) gt 0>
		#key# - #cgi[key]#
	</cfif>
</cfloop>
	
<cfsavecontent variable="loginfo">
LOG ENTRY: #dateformat(now(),"yyyy-mm-dd")# #TimeFormat(now(), "HH:mm:ss")#
Problem: 404
Referrer: #cgi.HTTP_REFERER#
CGI Dump:
<cfloop item="key" collection="#cgi#">
	<cfif len(cgi[key]) gt 0>
		#key# - #cgi[key]# #chr(10)#
	</cfif>
</cfloop>
</cfsavecontent>

	<!----------
	<cfset loginfo="LOG ENTRY: #dateformat(now(),"yyyy-mm-dd")# #TimeFormat(now(), "HH:mm:ss")#">
	<cfset loginfo=loginfo & chr(10) & "Problem: 404">

	<cfset loginfo=loginfo & chr(10) & "Referrer: #cgi.HTTP_REFERER#">
		<cfset loginfo=loginfo & chr(10) & "cgi: " & cfdump var="cgi" format="text">

	-------->
	<cffile action="append" file="#Application.webDirectory#/log/log.txt" output="#loginfo#">
</cfoutput>
