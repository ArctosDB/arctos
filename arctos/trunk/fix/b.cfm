<cfinclude template="/includes/_header.cfm">

<cfoutput>


<cfset remark="this makes [[guid/MVZ:Mamm:1|guid links]] to specimens [[guid/MVZ:Mamm:2]]">

<cfdump var=#remark#>



	<cfif remark contains "[[" and remark contains "]]">
		<cfset remark=replace(remark,"[[","#chr(7)#*" ,"all")>
		<cfset remark=replace(remark,"]]", "*#chr(7)#" ,"all")>
		<br>#remark#
		<cfloop list="#remark#" delimiters="#chr(7)#" index="x">
			
			<p>
				listelem: #x#
			</p>
			<cfif left(x,1) is "*" and right(x,1) is "*">
				<br>#x# is a link....
				<cfset x=left(x,len(x)-1)>
				<cfset x=right(x,len(x)-1)>
				<br>nostars: #x#
				<cfif x contains "|">
					<cfset theLink=listfirst(x,"|")>
				<cfelse>
					<cfset theLink=x>
				</cfif>
				<cfif left(theLink,5) is "guid/">
					<cfif x contains "|">
						<cfset linktext=listlast(x,"|")>
					<cfelse>
						<cfset linktext=replace(x,"guid/","","all")>
					</cfif>
					<cfset htmlLink='<a href="#link#">#linktext#</a>'>
				</cfif>
				
				<cfdump var=#htmltext#>
			</cfif>
		</cfloop>
	</cfif>

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
