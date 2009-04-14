<cfoutput>
<cfquery name="colls" datasource="uam_god">
	select * from collection
</cfquery>
<cfloop query="colls">
	<cfquery name="t" datasource="uam_god">
		select count(*) from cataloged_item where collection_id=#collection_id#
	</cfquery>
	<cfset numSiteMaps=round(50000/t.c)>
	<br>need #numSiteMaps# numSiteMaps for #collection#
</cfloop>
</cfoutput>