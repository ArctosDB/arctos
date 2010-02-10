<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			taxonomy.taxon_name_id,
			scientific_name
		from 
			project_taxonomy, 
			taxonomy
		where
			taxonomy.taxon_name_id=project_taxonomy.taxon_name_id and
			project_id = #project_id#
	</cfquery>
	<cfif d.recordcount gt 0>
		<h2>Taxonomy</h2>
		<ul>
			<cfloop query="d">
				<li><a href="/name/#scientific_name#">#scientific_name#</a></li>
			</cfloop>
		</ul>
	</cfif>
</cfoutput>