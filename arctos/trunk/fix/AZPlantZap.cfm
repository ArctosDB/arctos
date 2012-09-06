<cfinclude template="/includes/_header.cfm">

<cfoutput>
	HI
	<!-------
<cfset variables.fn="#Application.webDirectory#/bnhmMaps/tabfiles/test.xml">
<cfset variables.encoding="UTF-8">

	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fn, variables.encoding, 32768);
		a='test test bla testy'; 
		variables.joFileWriter.writeLine(a);
		variables.joFileWriter.close();
	</cfscript>


	<a href="/bnhmMaps/tabfiles/test.xml">/bnhmMaps/tabfiles/test.xml</a>
	
	-------->
	
</cfoutput>
