<cfinclude template="/includes/_header.cfm">

<cfoutput>
	<cfhttp action="get" url="http://en.wikipedia.org/wiki/Multi-Use_Radio_Service">
	</cfhttp>
	
	<cfdump var=#cfhttp#>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">

