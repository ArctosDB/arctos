<cfinvoke 
webservice="http://arctos.database.museum/service/documentation.cfc?wsdl"
method="getDefinition"
returnvariable="creditrequest">
	<cfinvokeargument name="fld" value="addr.city"/>
</cfinvoke>
<cfdump var=#creditrequest#>