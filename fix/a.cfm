<cfinclude template="/includes/_header.cfm">

<cfoutput>

<cfhttp method="get" url="http://api.vertnet-portal.appspot.com/#p#"></cfhttp>

<cfset x=deserializejson(cfhttp.filecontent)>
<cfdump var=#x#>

			</cfoutput>
		<cfinclude template="/includes/_footer.cfm">

