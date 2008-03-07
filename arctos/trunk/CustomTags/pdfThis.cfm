<cfoutput>
<cfpdfform action="populate" destination="#application.webDirectory#/Reports/templates/#attributes.cFile#" 
	source="#application.webDirectory#/Reports/templates/alaLabelTemplate.pdf" overwrite="true">
	<cfloop list="#attributes.fVals#" index="i">
		<cfif listlen(i,"|") is 2>
			<cfset name=listgetat(i,1,"|")>
			<cfset val=listgetat(i,2,"|")>
			<cfpdfformparam name="#name#" value="#val#">
		</cfif>
	</cfloop>
 </cfpdfform>
</cfoutput>