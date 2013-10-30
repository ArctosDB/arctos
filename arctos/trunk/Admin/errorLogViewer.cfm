<cfinclude template="/includes/_header.cfm">
<cffile action="read" file="#Application.webDirectory#/log/log.txt" variable="logtxt">
<cfoutput>
	#logtxt#
	
	<cfset x=xmlparse("<logs>" & logtxt & "</logs>")>
	
	<cfdump var=#x#>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
