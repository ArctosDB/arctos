<cfoutput>
<cfhttp url="http://wanserver-00.tacc.utexas.edu:8000/KNewman" charset="utf-8" method="get">
</cfhttp>
<cfset t="">
<cfif isXML(cfhttp.FileContent)>
	<cfset xStr=cfhttp.FileContent>
	<!--- goddamned xmlns bug in CF --->
	<cfset xStr= replace(xStr,' xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"','')>
	<cfset xdir=xmlparse(xStr)>
	<cfset dir = xmlsearch(xdir, "//td[@class='n']")>
	<cfset t="">
	<cfloop index="i" from="1" to="#arrayLen(dir)#">
		<cfset folder = dir[i].XmlChildren[1].xmlText>
		<cfif left(folder,2) is "PU" and #right(folder,4)# is ".aif">
			<cfset t = t & "#folder#" & chr(10)>
		</cfif><!--- end 2008..... name --->
	</cfloop>
</cfif>
</cfoutput>
<cffile action="write" file="#application.webDirectory#/temp/soundtacc.txt" output="#t#">
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