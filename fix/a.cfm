
<cfoutput>


<cfhttp method="post" url="http://www.museum.tulane.edu/webservices/geolocatesvcv2/geolocatesvc.asmx/Georef2">
    <cfhttpparam name="Country" type="body" value="United States">
    <cfhttpparam name="County" type="body" value="">
    <cfhttpparam name="LocalityString" type="body" value="north pole">
    <cfhttpparam name="State" type="body" value="Alaska">
    <cfhttpparam name="HwyX" type="body" value="">
    <cfhttpparam name="FindWaterbody" type="body" value="false">
    <cfhttpparam name="RestrictToLowestAdm" type="body" value="false">
    <cfhttpparam name="doUncert" type="body" value="true">
    <cfhttpparam name="doPoly" type="body" value="false">
    <cfhttpparam name="displacePoly" type="body" value="false">
    <cfhttpparam name="polyAsLinkID" type="body" value="false">
    <cfhttpparam name="LanguageKey" type="body" value="0">
</cfhttp>
<cfdump var=#cfhttp#>
</cfoutput>
