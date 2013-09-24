	<cfinclude template="/includes/_header.cfm">

<cfoutput>

		<cfquery name="d" datasource="uam_god">
				select locality from dmns group by locality
			</cfquery>
			
			<cfloop query="d">
				<cfset l="">
				<cfset g="">
				<hr>
				#locality#
				<br>#l#
				<br>#g#
				<cfif locality contains ";">
					<cfset l=listlast(locality,";")>
					<cfset g=replace(locality,l,"","all")>
				</cfif>
			</cfloop>
			
			</cfoutput>
		<cfinclude template="/includes/_footer.cfm">

