<cfinclude template="/includes/_header.cfm">
<cfinclude template="/service/uBio.cfc">
<cfoutput>
	<p>Action: #action#</p>
	<cfif not isdefined("v") or len(v) is 0>
		<cfset v="Alces alces">
	</cfif>
	<form name="t" method="post" action="ubio.cfm">
	<input type="hidden" name="action" value="namebank_search">
	namebank_search: <input type="text" name="v" value="#v#">
	<input type="submit">
</form>
<cfif #action# is "namebank_search">
<cfset bla = namebank_search('#v#')>
<cfset MyXml = xmlparse(bla)>
<cfloop index="c" from="1" to="#ArrayLen(MyXml.results.scientificNames.value)#">
	<cfset namebankID=MyXml.results.scientificNames.value[c].namebankID.XmlText>
	<br>namebankID: #namebankID#
	<a href="ubio.cfm?action=namebank_object&v=#namebankID#">namebank_object</a>
	<a href="ubio.cfm?action=classificationbank_search&v=#namebankID#">classificationbank_search</a>
	
		<a href="ubio.cfm?action=classificationbank_object&v=#namebankID#">classificationbank_object</a>
	classificationbank_object
	
	<cfset packageID=MyXml.results.scientificNames.value[c].packageID.XmlText>
	<br>packageID: #packageID#
	<cfset packageName=MyXml.results.scientificNames.value[c].packageName.XmlText>
	<br>packageName: #packageName#
	<cfset basionymUnit=MyXml.results.scientificNames.value[c].basionymUnit.XmlText>
	<br>basionymUnit: #basionymUnit#
	<cfset rankName=MyXml.results.scientificNames.value[c].rankName.XmlText>
	<br>rankName: #rankName#
	
	<cfset nameString=MyXml.results.scientificNames.value[c].nameString.XmlText>
	<cfset nameString= ToString(ToBinary(nameString))>
	<br>nameString: #nameString#
	<cfset fullNameString=MyXml.results.scientificNames.value[c].fullNameString.XmlText>
	<cfset fullNameString= ToString(ToBinary(fullNameString))>
	<br>fullNameString: #fullNameString#
	<hr>
</cfloop>
</cfif>
<cfif #action# is "namebank_object">
	<cfset bla = namebank_object(#v#)>
	<cfset MyXml = xmlparse(bla)>
	<cfdump var=#MyXml#>
</cfif>
<cfif #action# is "classificationbank_search">
	<cfset bla = classificationbank_search(#v#)>
	<cfset MyXml = xmlparse(bla)>
	<cfdump var=#MyXml#>
</cfif>

<cfif #action# is "classificationbank_object">
	<cfset bla = classificationbank_object(#v#)>
	<cfset MyXml = xmlparse(bla)>
	<cfdump var=#MyXml#>
</cfif>

	<!---
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
<cfset bla = namebank_search('Alces alces')>
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
---->--->


</cfoutput>
<cfinclude template="/includes/_footer.cfm">