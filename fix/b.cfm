<cfinvoke 
webservice="http://arctos.database.museum/service/documentation.cfc?wsdl"
method="getDefinitionByDispName"
returnvariable="creditrequest">
	<cfinvokeargument name="fld" value="addr.city"/>
</cfinvoke>
<cfdump var=#creditrequest#>