<cfif not isdefined("url.file") or url.file does not contain ".">
	Bad call.
	<cfabort>
</cfif>
<cfoutput>
	<cfset ext=right(url.file,len(url.file)-find(".",url.file))>
	<cfheader name="Content-Disposition" value="attachment; filename=#url.file#">
	<cfcontent type="application/#ext#" file="#Application.webDirectory#/download/#url.file#">
</cfoutput>