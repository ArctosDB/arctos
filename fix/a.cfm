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
				
				<cfif locality contains ";">
					<cfset l=listlast(locality,";")>
					<cfset g=replace(locality,l,"","all")>
				</cfif>
				
				<br>#l#
				<br>#g#
			</cfloop>
			
			</cfoutput>
		<cfinclude template="/includes/_footer.cfm">

