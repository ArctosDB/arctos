<cfhttp url="http://arctos.database.museum/service/doc_rest.cfc" charset="utf-8" method="get">
	<cfhttpparam type="url" name="method" value="getDefinition">
	<cfhttpparam type="url" name="fld" value="#fld#">
</cfhttp>
<cfoutput>
	-------------------#cfhttp.fileContent#---------------------</cfoutput>