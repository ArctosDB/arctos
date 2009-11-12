<cfoutput>
	<cfquery name="getContributors" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			project.project_id,
			project_name
		FROM 
			project
		WHERE 
			project.project_id IN (
				SELECT 
					project_trans.project_id 
				FROM 
					project, 
					project_trans, 
					accn, 
					cataloged_item 
				where 
					project_trans.transaction_id = accn.transaction_id AND 
					accn.transaction_id = cataloged_item.accn_id AND 
					project_trans.project_id = project.project_id AND 
					cataloged_item.collection_object_id IN (
						SELECT 
							cataloged_item.collection_object_id 
						FROM 
							project,
							project_trans,
							loan_item,
							specimen_part,
							cataloged_item 
						WHERE 
							loan_item.collection_object_id = specimen_part.collection_object_id AND
							specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
							project_trans.transaction_id = loan_item.transaction_id AND 
							project_trans.project_id = project.project_id AND 
							project.project_id = #project_id#
						)
					)  
			ORDER BY 
				project_name
	</cfquery>
	<cfif getContributors.recordcount gt 0>
		<h2>Projects contributing specimens</h2>
		#getContributors.recordcount# projects contributed specimens used by this project.
		<ul>
			<cfloop query="getContributors">
				<li><a href="ProjectDetail.cfm?project_id=#project_id#">#project_name#</a></li>
			</cfloop>
		</ul>
	</cfif>
</cfoutput>