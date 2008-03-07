<cfoutput>
	<cfdump var="#attributes.dArray#">
	<cfset bla = StructKeyArray(attributes.dArray)>
	<cfdump var="#bla#">
	
	
	  <hr>
    <cfset keysToStruct = StructKeyArray(attributes.dArray)>
    <cfloop index = "i" from = "1" to = "#ArrayLen(keysToStruct)#">
        <p>Key#i# is #keysToStruct[i]#</p>
        <p>Value#i# is #attributes.dArray[keysToStruct[i]]#
        </p>
    </cfloop>
	<!---
<cfpdfform action="populate" destination="#application.webDirectory#/Reports/templates/#attributes.cFile#" 
	source="#application.webDirectory#/Reports/templates/alaLabelTemplate.pdf" overwrite="true">
	<cfloop from="1" to="attributes.dArray.StructCount" index="i">
		<cfif listlen(i,"|") is 2>
			<cfset name=listgetat(i,1,"|")>
			<cfset val=listgetat(i,2,"|")>
			<cfpdfformparam name="#name#" value="#val#">
		</cfif>
	</cfloop>
 </cfpdfform>
	--->
</cfoutput>