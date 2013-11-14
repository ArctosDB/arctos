
	<cfloop item="key" collection="#cgi#">
<br>#key# - #cgi[key]#<br>

</cfloop>
	<cfif isGuid is false>
		<cfset sub="Dead Link">
		<cfset frm="dead.link">
	<cfelse>
		<cfset sub="Missing GUID">
		<cfset frm="dead.guid">
	</cfif>
	<cfif request.rdurl contains 'coldfusion.applets.CFGridApplet.class'>
		<cfset sub="stoopid safari">
		<cfset frm="stoopid.safari">
	</cfif>
<cfsavecontent variable="loginfo">
LOG ENTRY: #dateformat(now(),"yyyy-mm-dd")#T#TimeFormat(now(), "HH:mm:ss")#
Problem: 404
Referrer: #cgi.HTTP_REFERER#
<cfdump var="#cgi#" format="text">
</cfsavecontent>

	<!----------
	<cfset loginfo="LOG ENTRY: #dateformat(now(),"yyyy-mm-dd")# #TimeFormat(now(), "HH:mm:ss")#">
	<cfset loginfo=loginfo & chr(10) & "Problem: 404">

	<cfset loginfo=loginfo & chr(10) & "Referrer: #cgi.HTTP_REFERER#">
		<cfset loginfo=loginfo & chr(10) & "cgi: " & cfdump var="cgi" format="text">

	-------->
	<cffile action="append" file="#Application.webDirectory#/log/log.txt" output="#loginfo#">

