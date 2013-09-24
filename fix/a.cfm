	<cfinclude template="/includes/_header.cfm">

<cfoutput>

		<cfquery name="d" datasource="uam_god">
				select locality from dmns where locality is not null group by locality
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
				<cfif right(g,1) is ";">
					<cfset g=left(g,len(g)-1)>
				</cfif>
				<br>#g#
				
				<br>#l#
						<cfquery name="i" datasource="uam_god">
						insert into  dmns_geog_split (orig ,geog,locality ) values ('#locality#','#g#','#l#)
						</cfquery>

				
			</cfloop>
			
			</cfoutput>
		<cfinclude template="/includes/_footer.cfm">

