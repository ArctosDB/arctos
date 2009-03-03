<cfif not isdefined("file")>
	Bad call.
	<cfabort>
</cfif>
<cfoutput>
	<cfif url.file does not contain ".">
		Bad call.
		<cfabort>
	</cfif>
	<cfset ext=right(url.file,len(url.file)-find(".",ur.file))>
	<cfheader name="Content-Disposition" value="attachment; filename=#url.file#">
	<cfcontent type="application/#ext#" file="#Application.serverRootUrl#/download/#file#">
</cfoutput>