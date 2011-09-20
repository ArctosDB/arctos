
<cfoutput>


<cfhttp method="post" url="http://www.museum.tulane.edu/webservices/geolocatesvcv2/geolocatesvc.asmx/Georef2">
    <cfhttpparam name="Country" type="FormField" value="United States">
    <cfhttpparam name="County" type="FormField" value="">
    <cfhttpparam name="LocalityString" type="FormField" value="north pole">
    <cfhttpparam name="State" type="FormField" value="Alaska">
    <cfhttpparam name="HwyX" type="FormField" value="false">
    <cfhttpparam name="FindWaterbody" type="FormField" value="false">
    <cfhttpparam name="RestrictToLowestAdm" type="FormField" value="false">
    <cfhttpparam name="doUncert" type="FormField" value="true">
    <cfhttpparam name="doPoly" type="FormField" value="false">
    <cfhttpparam name="displacePoly" type="FormField" value="false">
    <cfhttpparam name="polyAsLinkID" type="FormField" value="false">
    <cfhttpparam name="LanguageKey" type="FormField" value="0">
</cfhttp>
<cfdump var=#cfhttp#>
<cfset result=xmlparse(cfhttp.fileContent)>
<cfdump var=#result#>
</cfoutput>
