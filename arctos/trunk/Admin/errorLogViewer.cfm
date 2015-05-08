<cfinclude template="/includes/_header.cfm">

toobookoo<cfabort>
<cffunction name="indentXml" output="false" returntype="string">
  <cfargument name="xml" type="string" required="true" />
  <cfargument name="indent" type="string" default="  "
    hint="The string to use for indenting (default is two spaces)." />
  <cfset var lines = "" />
  <cfset var depth = "" />
  <cfset var line = "" />
  <cfset var isCDATAStart = "" />
  <cfset var isCDATAEnd = "" />
  <cfset var isEndTag = "" />
  <cfset var isSelfClose = "" />
  <cfset xml = trim(REReplace(xml, "(^|>)\s*(<|$)", "\1#chr(10)#\2", "all")) />
  <cfset lines = listToArray(xml, chr(10)) />
  <cfset depth = 0 />
  <cfloop from="1" to="#arrayLen(lines)#" index="i">
    <cfset line = trim(lines[i]) />
    <cfset isCDATAStart = left(line, 9) EQ "<![CDATA[" />
    <cfset isCDATAEnd = right(line, 3) EQ "]]>" />
    <cfif NOT isCDATAStart AND NOT isCDATAEnd AND left(line, 1) EQ "<" AND right(line, 1) EQ ">">
      <cfset isEndTag = left(line, 2) EQ "</" />
      <cfset isSelfClose = right(line, 2) EQ "/>" OR REFindNoCase("<([a-z0-9_-]*).*</\1>", line) />
      <cfif isEndTag>
        <!--- use max for safety against multi-line open tags --->
        <cfset depth = max(0, depth - 1) />
      </cfif>
      <cfset lines[i] = repeatString(indent, depth) & line />
      <cfif NOT isEndTag AND NOT isSelfClose>
        <cfset depth = depth + 1 />
      </cfif>
    <cfelseif isCDATAStart>
      <!---
      we don't indent CDATA ends, because that would change the
      content of the CDATA, which isn't desirable
      --->
      <cfset lines[i] = repeatString(indent, depth) & line />
    </cfif>
  </cfloop>
  <cfreturn arrayToList(lines, chr(10)) />
</cffunction>

<cfif not isdefined("log")>
	<cfset log="log">
</cfif>
<a href="errorLogViewer.cfm?log=log">log</a>
<a href="errorLogViewer.cfm?log=404log">404log</a>
<a href="errorLogViewer.cfm?log=missingGUIDlog">missingGUIDlog</a>
<a href="errorLogViewer.cfm?log=blacklistlog">blacklistlog</a>
<a href="errorLogViewer.cfm?log=emaillog">emaillog</a>


<cffile action="read" file="#Application.webDirectory#/log/#log#.txt" variable="logtxt">




<cfoutput>

	<pre>#htmlEditFormat(indentXml('<docroot>' & replace(logtxt,chr(10),'','all') & '</docroot>'))#</pre>

</cfoutput>
<!----
<cfoutput>
	<cfset x=xmlparse("<logs>" & logtxt & "</logs>")>
	<cfdump var=#x#>


	<br />#logtxt#



</cfoutput>
------>
<cfinclude template="/includes/_footer.cfm">
