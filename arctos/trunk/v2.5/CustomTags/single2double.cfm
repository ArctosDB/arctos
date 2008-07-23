
<cfsetting enablecfoutputonly="yes">
    <cfif not isDefined("Attributes.b")>
        <CFOUTPUT>
            Error, you must provide a string to echo!
        </CFOUTPUT>
        <cfexit method="EXITTAG">
</cfif>
<cfset caller.b = "joe">
<cfsetting enablecfoutputonly="no">
