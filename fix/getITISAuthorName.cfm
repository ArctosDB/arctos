<cfquery name="d" datasource="uam_god">
	select distinct scientific_name from temp_class_an_lookup2 where itisauth is null and rownum < 20
</cfquery>

<cfoutput>
	<cfloop query="d">
		<p>
			#scientific_name#
		</p>
		<cfhttp url="https://www.itis.gov/ITISWebService/services/ITISService/searchByScientificName?srchKey=#scientific_name#" method="get">

		</cfhttp>

		<cftry>

		<!----
		<cfdump var=#cfhttp#>
		---->
		<cfset xd=xmlparse(cfhttp.filecontent)>
		<!----
		<cfdump var=#xd#>
---->

<!----
		<cfset an=xd.ns:searchByScientificNameResponse.ns:return.ax21:scientificNames.ax21:author.XmlText>
---->


<cfset an=xd['ns:searchByScientificNameResponse']['ns:return']['ax21:scientificNames']['ax21:author'].XmlText>

		<br>author::::<cfdump var=#an#>
		<cfquery name="g1" datasource="uam_god">
			update temp_class_an_lookup2 set itisauth='#an#' where scientific_name='#scientific_name#'
		</cfquery>

		<cfcatch>
			<br>error
			<cfquery name="g1" datasource="uam_god">
				update temp_class_an_lookup2 set itisauth='itis_service_error' where scientific_name='#scientific_name#'
			</cfquery>
		</cfcatch>
		</cftry>


	</cfloop>
</cfoutput>

