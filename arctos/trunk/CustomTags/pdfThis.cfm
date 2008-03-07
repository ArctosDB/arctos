<cfoutput>
<cfpdfform action="populate" destination="#application.webDirectory#/Reports/templates/#attributes.cFile#" 
	source="#application.webDirectory#/Reports/templates/alaLabelTemplate.pdf" overwrite="true">
	<cfloop list="#attributes.fVals#" index="i">
		<cfset name=listgetat(i,1,"|")>
		<cfset val=listgetat(i,2,"|")>
		<cfpdfformparam name="#name#" value="#val#">
	</cfloop>
 </cfpdfform>
</cfoutput>