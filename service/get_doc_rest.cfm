<cfparam name="action" default="nothing">
<cfparam name="addCtl" default="0">
<cfif #action# is "nothing">
<!--- include search hint --->
<cfhttp url="http://arctos.database.museum/service/doc_rest.cfm" charset="utf-8" method="get">
	<cfhttpparam type="url" name="action" value="getDefinition">
	<cfhttpparam type="url" name="fld" value="#fld#">
	<cfhttpparam type="url" name="addCtl" value="#addCtl#">
</cfhttp>
<cfoutput>
		#cfhttp.fileContent#</cfoutput>
</cfif>
<cfif #action# is "enterDocs">
<!--- include search hint --->
<cfhttp url="http://arctos.database.museum/service/doc_rest.cfm" charset="utf-8" method="get">
	<cfhttpparam type="url" name="action" value="getDefinition">
	<cfhttpparam type="url" name="fld" value="#fld#">
	<cfhttpparam type="url" name="addCtl" value="#addCtl#">
</cfhttp>
<cfoutput>
		enterdocs:#cfhttp.fileContent#</cfoutput>
</cfif>