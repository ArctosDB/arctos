<cfoutput>

	
	<cfquery datasource="uam_god" name="cols">
		select * from taxonomy where 1=2		
	</cfquery>
	<cfset c=cols.columnlist>
	
	<cfset c=listdeleteat(c,listfindnocase(c,"taxon_name_id"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"VALID_CATALOG_TERM_FG"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"display_name"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"scientific_name"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"author_text"))>

	<cfset c=listdeleteat(c,listfindnocase(c,"FULL_TAXON_NAME"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"INFRASPECIFIC_RANK"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"INFRASPECIFIC_AUTHOR"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"NOMENCLATURAL_CODE"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"SOURCE_AUTHORITY"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"TAXON_REMARKS"))>
	<cfset c=listdeleteat(c,listfindnocase(c,"TAXON_STATUS"))>

	<cfloop list="#c#" index="fl">
	
		<cfloop list="#c#" index="sl">
			<cfif sl is not fl>
				
				<cfquery datasource="uam_god" name="ttt">
					select count(*) c from taxonomy where #fl#=#sl#			
				</cfquery>
				<cfif ttt.c gt 0>
					<cfdump var=#ttt#>
				</cfif>
			</cfif>
		</cfloop>
	</cfloop>	
</cfoutput>