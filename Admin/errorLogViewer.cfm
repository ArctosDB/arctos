<cfinclude template="/includes/_header.cfm">

<cfif not isdefined("log")>
	<cfset log="log">
</cfif>
<a href="errorLogView.cfm?log=log">log</a>
<a href="errorLogView.cfm?log=404log">404log</a>
<a href="errorLogView.cfm?log=missingGUIDlog">missingGUIDlog</a>
<a href="errorLogView.cfm?blacklistlog=blacklistlog">log</a>
	
	
<cffile action="read" file="#Application.webDirectory#/log/#log#.txt" variable="logtxt">
<cfoutput>	
	<cfset x=xmlparse("<logs>" & logtxt & "</logs>")>
	<cfdump var=#x#>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
