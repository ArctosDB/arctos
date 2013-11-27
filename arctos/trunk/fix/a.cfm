<cfinclude template="/includes/_header.cfm">

<cfoutput>
	<cfhttp method="get" url="#u#">
	</cfhttp>
	
	<cfdump var=#cfhttp#>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">

