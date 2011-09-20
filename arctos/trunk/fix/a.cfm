
<cfoutput>


<cfhttp method="post" url="http://www.museum.tulane.edu/webservices/geolocatesvcv2/geolocatesvc.asmx/Georef2">
    <cfhttpparam name="Country" type="header" value="United States">
    <cfhttpparam name="County" type="header" value="">
    <cfhttpparam name="LocalityString" type="header" value="north pole">
    <cfhttpparam name="State" type="header" value="Alaska">
    <cfhttpparam name="HwyX" type="header" value="">
    <cfhttpparam name="FindWaterbody" type="header" value="false">
    <cfhttpparam name="RestrictToLowestAdm" type="header" value="false">
    <cfhttpparam name="doUncert" type="header" value="true">
    <cfhttpparam name="doPoly" type="header" value="false">
    <cfhttpparam name="displacePoly" type="header" value="false">
    <cfhttpparam name="polyAsLinkID" type="header" value="false">
    <cfhttpparam name="LanguageKey" type="header" value="0">
</cfhttp>
<cfdump var=#cfhttp#>
</cfoutput>
