<cfinclude template="/includes/_header.cfm">

<cfif not isdefined("log")>
	<cfset log="log">
</cfif>
<a href="errorLogViewer.cfm?log=log">log</a>
<a href="errorLogViewer.cfm?log=404log">404log</a>
<a href="errorLogViewer.cfm?log=missingGUIDlog">missingGUIDlog</a>
<a href="errorLogViewer.cfm?log=blacklistlog">blacklistlog</a>
<a href="errorLogViewer.cfm?log=emaillog">emaillog</a>


<cffile action="read" file="#Application.webDirectory#/log/#log#.txt" variable="logtxt">



<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <xsl:output omit-xml-declaration="yes" indent="yes"/>

    <xsl:template match="node()|@*">
      <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:template>
</xsl:stylesheet>


<cfoutput>
#logtxt#


</cfoutput>
<!----
<cfoutput>	
	<cfset x=xmlparse("<logs>" & logtxt & "</logs>")>
	<cfdump var=#x#>
</cfoutput>
------>
<cfinclude template="/includes/_footer.cfm">
