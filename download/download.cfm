<cfif not isdefined("file") or not isdefined("filetype")>
	Bad call.
	<cfabort>
</cfif>
<cfoutput>
	<cfheader name="Content-Disposition" value="attachment; filename=#file#">
	<cfcontent type="application/#filetype#" file="#Application.serverRootUrl#/download/#fileName#">
</cfoutput>