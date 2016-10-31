<cfquery name="d" datasource="uam_god">
	select * from temp_class_an_lookup2 where itisauth is null and rownum < 10
</cfquery>

<cfoutput>
	<cfloop query="d">
		<p>
			#scientific_name#
		</p>
		<cfhttp url="https://www.itis.gov/ITISWebService/services/ITISService/searchByScientificName?srchKey=#scientific_name#" method="get">

		</cfhttp>
		<cfdump var=#cfhttp#>
		<cfset xd=xmlparse(cfhttp.filecontent)>
		<cfdump var=#xd#>
	</cfloop>
</cfoutput>

