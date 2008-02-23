<cfinclude template="/service/uBio.cfc">
<cfoutput>
<cfset bla = namebank_search_canonical()>
namebank_search_canonical:
<p></p>
<cfdump var=#bla#>
<hr>
<cfset bla = namebank_search()>
namebank_search:
<p>
<cfdump var=#bla#>
</p>
<cfset MyXml = xmlparse(bla)>
<!------->
<cfloop index="c" from="1" to="#ArrayLen(MyXml.results.scientificNames.value)#">
	<cfset nameString=MyXml.results.scientificNames.value[c].nameString.XmlText>
	<cfset nameString= ToString(ToBinary(nameString))>
	<br>nameString: #nameString#
	<cfset nameString=MyXml.results.scientificNames.value[c].fullNameString.XmlText>
	<cfset fullNameString= ToString(ToBinary(fullNameString))>
	<br>fullNameString: #fullNameString#


<!---


#binky#

	<br>#BinaryDecode(MyXml.results.scientificNames[c].nameString.XmlText,"base64")#
	--->
	<hr>
</cfloop>

</cfoutput>