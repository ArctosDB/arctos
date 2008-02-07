<cfinvoke 
  webservice="http://arctos.database.museum/service/documentation.cfc?wsdl"
  method="getMessage"
  returnvariable="aString">
</cfinvoke>
<cfoutput>
#aString#
</cfoutput>