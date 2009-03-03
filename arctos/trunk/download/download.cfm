<cfif not isdefined("file")>
	Bad call.
	<cfabort>
</cfif>
<cfoutput>
	<cfif url.file does not contain ".">
		Bad call.
		<cfabort>
	</cfif>
	<cfset ext=right(url.file,len(url.file)-find(".",url.file))>
	<cfheader name="Content-Disposition" value="attachment; filename=#url.file#">
	<cfcontent type="application/#ext#" file="#Application.webDirectory#/download/ArctosData_1136_10759281.txt">
</cfoutput>