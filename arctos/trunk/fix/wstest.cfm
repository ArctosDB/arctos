
<cfinvoke 
  webservice="http://arctos.database.museum/service/documentation.cfc?wsdl"
  method="getDefinition"
  returnvariable="aString">
 	<cfinvokeargument name="fld" value="identification.scientific_name" />
</cfinvoke> 
<cfoutput>
<cfdump var="#aString#">
<cfset x = xmlParse(aString)>
<cfdump var="#x#">
</cfoutput>






<cfinvoke 
  webservice="http://arctos.database.museum/service/documentation.cfc?wsdl"
  method="getDefinition"
  returnvariable="aString">
 <cfinvokeargument name="fld" value="identification.notThereDummy" />
</cfinvoke> 
<cfoutput>
<cfset x = xmlParse(aString)>
<cfdump var="#x#">
</cfoutput>

<cfinvoke 
  webservice="http://arctos.database.museum/service/documentation.cfc?wsdl"
  method="getDefinition"
  returnvariable="aString">
 <cfinvokeargument name="fld" value="identification.scientific_name,taxonomy.scientific_name" />
</cfinvoke>
<cfoutput>
<cfset x = xmlParse(aString)>
<cfdump var="#x#">
</cfoutput>

<cfinvoke 
  webservice="http://arctos.database.museum/service/documentation.cfc?wsdl"
  method="getDefinition"
  returnvariable="aString">
 <cfinvokeargument name="fld" value="apos'trophe" />
</cfinvoke>
<cfoutput>
<cfset x = xmlParse(aString)>
<cfdump var="#x#">
</cfoutput>

