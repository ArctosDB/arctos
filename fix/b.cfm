<cfinclude template="/service/uBio.cfc">
<cfoutput>
<p>
namebank_search_canonical(2038379)
</p>
<cfset bla = namebank_search_canonical(2038379)>
<cfset MyXml = xmlparse(bla)>
<cfdump var=#MyXml#>
<hr>
<p>
namebank_search('Alces alces')
</p>
<cfset bla = namebank_search(2038379)>
<cfset MyXml = xmlparse(bla)>
<cfdump var=#MyXml#>
<hr>

<p>
classificationbank_search(3070378)
</p>
<cfset bla = namebank_search(3070378)>
<cfset MyXml = xmlparse(bla)>
<cfdump var=#MyXml#>
<hr>


<!---
<cfloop index="c" from="1" to="#ArrayLen(MyXml.results.scientificNames.value)#">
	<cfset nameString=MyXml.results.scientificNames.value[c].nameString.XmlText>
	<cfset nameString= ToString(ToBinary(nameString))>
	<br>nameString: #nameString#
	<cfset fullNameString=MyXml.results.scientificNames.value[c].fullNameString.XmlText>
	<cfset fullNameString= ToString(ToBinary(fullNameString))>
	<br>fullNameString: #fullNameString#


<!---


#binky#

	<br>#BinaryDecode(MyXml.results.scientificNames[c].nameString.XmlText,"base64")#
	--->
	<hr>
</cfloop>
---->


</cfoutput>