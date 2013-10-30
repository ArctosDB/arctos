<cfinclude template="/includes/_header.cfm">
<cffile action="read" file="#Application.webDirectory#/log/#theLogFile#" variable="logtxt">
<cfoutput>
	#logtxt#
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
