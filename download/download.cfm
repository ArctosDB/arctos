<cfif not isdefined("file") or not isdefined("filetype")>
	Bad call.
	<cfabort>
</cfif>
<cfoutput>
	<cfset fn=evaluate(file)>
	<cfheader name="Content-Disposition" value="attachment; filename=#fn#">
	<cfcontent type="application/#filetype#" file="#Application.serverRootUrl#/download/#fileName#">
</cfoutput>