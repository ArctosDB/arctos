<cfinclude template="/service/uBio.cfc">
<cfset bla = namebank_search_canonical()>
namebank_search_canonical:
<p></p>
<cfdump var=#bla#>
<hr>
<cfset bla = namebank_search()>
namebank_search:
<p></p>
<cfset MyXml = xmlparse(bla)>
<cfloop index="c" from="1" to="#ArrayLen(MyXml.results.scientificNames)#">

<br>#MyXml.results.scientificNames[c].nameString.XmlText# 
	<br>#BinaryDecode(MyXml.results.scientificNames[c].nameString.XmlText,"base64")#
	<hr>
</cfloop>

