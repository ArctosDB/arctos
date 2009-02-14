<cfinvoke 
  webservice="http://mvzarctos-dev.berkeley.edu/service/documentation.cfc?wsdl"
  method="getMessage"
  returnvariable="aString">
</cfinvoke>
<cfoutput>
#aString#
</cfoutput>