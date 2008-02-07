
<cfsetting enablecfoutputonly="yes">
    <cfif not isDefined("Attributes.echo")>
        <CFOUTPUT>
            Error, you must provide a string to echo!
        </CFOUTPUT>
        <cfexit method="EXITTAG">
</cfif>
<cfset caller.return_echo = attributes.echo>
<cfsetting enablecfoutputonly="no">