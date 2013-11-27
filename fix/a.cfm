<cfinclude template="/includes/_header.cfm">

	<cfset obj = CreateObject("component","component.functions")>

<cfoutput>
	
					<cfset signedURL = obj.googleSignURL(
						urlPath="/maps/api/geocode/json",
						urlParams="address=#URLEncodedFormat(addr)#")>
					<cfhttp method="get" url="#signedURL#" timeout="1"></cfhttp>
					<cfdump var=#cfhttp#>
</cfoutput>

<cfinclude template="/includes/_footer.cfm">

