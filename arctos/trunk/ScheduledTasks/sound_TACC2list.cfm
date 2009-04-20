<cfoutput>
<cfhttp url="http://goodnight.corral.tacc.utexas.edu/KNewman" charset="utf-8" method="get">
</cfhttp>
<cfset t="">
<cfif isXML(cfhttp.FileContent)>
	<cfset xStr=cfhttp.FileContent>
	<!--- goddamned xmlns bug in CF --->
	<cfset xStr= replace(xStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
	<cfset xdir=xmlparse(xStr)>
	<cfset dir = xmlsearch(xdir, "//td[@class='n']")>
	<cfset t="">
	
	<cfset variables.fileName="#Application.webDirectory#/temp/soundtacc.txt">
	<cfset variables.encoding="UTF-8">
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
	</cfscript>
	<cfloop index="i" from="1" to="#arrayLen(dir)#">
		<cfset folder = dir[i].XmlChildren[1].xmlText>
		<cfif left(folder,2) is "PU" and #right(folder,4)# is ".aif">
			<cfscript>
				variables.joFileWriter.writeLine(folder);
			</cfscript>	
		</cfif>
	</cfloop>
</cfif>
</cfoutput>
<!---











<cfoutput>
	<cfquery name="all_tacc" datasource="uam_god">
		select barcode from tacc_check order by barcode
	</cfquery>
	<cfset t="">
	<cfloop query="all_tacc">
		<cfset t = t & "#barcode#.dng#chr(10)#">
	</cfloop>

</cfoutput>
--->