<cfif not isdefined("file")>
	Bad call.
	<cfabort>
</cfif>
<cfoutput>
	<cfif file does not contain ".">
		Bad call.
		<cfabort>
	</cfif>
	<cfset ext=right(file,len(file)-find(".",file))>
	<cfheader name="Content-Disposition" value="attachment; filename=#url.file#">
	<cfcontent type="application/#ext#" file="#Application.serverRootUrl#/download/#file#">
</cfoutput>