<cfoutput>
	<cfquery name="getUsers" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			 		loan_item,
			 		specimen_part,
			 		cataloged_item 
			 	where 
			 		project_trans.transaction_id = loan_item.transaction_id AND 
			 		loan_item.collection_object_id = specimen_part.collection_object_id AND
			 		specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
			 		project_trans.project_id = project.project_id AND 
			 		cataloged_item.collection_object_id IN (
			 			SELECT 
			 				cataloged_item.collection_object_id 
			 			FROM 
			 				project,
			 				project_trans,
			 				accn,
			 				cataloged_item 
			 			WHERE 
			 				accn.transaction_id = cataloged_item.accn_id AND 
			 				project_trans.transaction_id = accn.transaction_id AND 
			 				project_trans.project_id = project.project_id AND 
			 				project.project_id = #project_id#
			 			)
			 		)
		group by 
			project.project_id,
			project_name
		order by project_name
	</cfquery>
	<cfif getUsers.recordcount gt 0>
		<h2>Projects using contributed specimens</h2>
			#getUsers.recordcount# Projects used specimens contributed by this project.		
		<ul>
		<cfloop query="getUsers">
			<li><a href="ProjectDetail.cfm?project_id=#project_id#">#project_name#</a></li>
		</cfloop>
		</ul>
	</cfif>
</cfoutput>