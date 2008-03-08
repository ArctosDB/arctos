<cfoutput>
	<cfpdfform action="populate" destination="#application.webDirectory#/Reports/templates/#attributes.cFile#" 
	source="#application.webDirectory#/Reports/templates/alaLabelTemplate.pdf" overwrite="true">
		<cfloop collection = #attributes.dArray# item = "k ">
			<cfpdfformparam name="#k#" value="#StructFind(attributes.dArray, k)#">
</cfloop> 
 </cfpdfform>
	<!---
	<cfset bla = StructKeyArray(attributes.dArray)>
	StructKeyArray: <br>
	<cfdump var="#bla#">
	
	
	  <hr>
    <cfset keysToStruct = StructKeyArray(attributes.dArray)>
    <cfloop index = "i" from = "1" to = "#ArrayLen(keysToStruct)#">
        <cfset blabla=attributes.dArray[i]>
		<cfdump var=#blabla#>
		<hr>
		blabla1,1:
		<cfset a=attributes.dArray[i]["key"]>
		key:<cfdump var=a>
		<cfset a=attributes.dArray[i]["value"]>
		value:<cfdump var=a>
		
    </cfloop>
	<p>Key#i# is StructKeyArray[i]</p>
        <p>Value#i# is #attributes.dArray[i[i]]#
        </p>

	<cfloop from="1" to="attributes.dArray.StructCount" index="i">
		<cfif listlen(i,"|") is 2>
			<cfset name=listgetat(i,1,"|")>
			<cfset val=listgetat(i,2,"|")>
			
		</cfif>
	</cfloop>

	--->
</cfoutput>