<cfinclude template="/includes/_header.cfm">

<cfoutput>

<cfhttp method="get" url="http://api.vertnet-portal.appspot.com/#p#"></cfhttp>

<cfdump var=#cfhttp#>


			</cfoutput>
		<cfinclude template="/includes/_footer.cfm">

