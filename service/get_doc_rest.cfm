<cfparam name="addCtl" default="0">
<cfhttp url="http://arctos.database.museum/service/doc_rest.cfm" charset="utf-8" method="get">
	<cfhttpparam type="url" name="action" value="getDefinition">
	<cfhttpparam type="url" name="fld" value="#fld#">
	<cfhttpparam type="url" name="addCtl" value="#addCtl#">
</cfhttp>
<cfoutput>
	<cfif isdefined("addCtl") and #addCtl# is "1">
		<span class="docControl" onclick="removeHelpDiv()">X</span>
	</cfif>#cfhttp.fileContent#</cfoutput>