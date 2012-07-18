<cfoutput>

	
	<cfquery datasource="uam_god" name="cols">
		select * from taxonomy where 1=2		
	</cfquery>
	<cfset c=cols.columnlist>
	<cfdump var=#c#>
	
	---#listfindnocase(c,"taxon_name_id")#---
	
	=#listfindnocase(c,"VALID_CATALOG_TERM_FG")#===
	
	<cfset c=listdeleteat(c,listfindnocase(c,"taxon_name_id"))>
		<cfset c=listdeleteat(c,listfindnocase(c,"VALID_CATALOG_TERM_FG"))>

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