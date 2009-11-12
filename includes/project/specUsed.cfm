<cfoutput>
	<cfquery name="getUsed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			collection.collection,
			collection.collection_id,
			count(distinct(cataloged_item.collection_object_id)) c
		FROM 
			cataloged_item,
			collection,
			specimen_part,
			loan_item,
			project_trans
		WHERE
			specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
			cataloged_item.collection_id=collection.collection_id and
			specimen_part.collection_object_id = loan_item.collection_object_id AND
			loan_item.transaction_id = project_trans.transaction_id AND
			project_trans.project_id = #project_id#
		group by
			collection.collection,
			collection.collection_id
	</cfquery>
	<cfquery name="ts" dbtype="query">
		select sum(c) totspec from getUsed
	</cfquery>
	<cfquery name="nc" dbtype="query">
			select collection from getUsed group by collection
		</cfquery>
	<cfif getUsed.recordcount gt 0>
		<h2>Specimens Used</h2>
		<ul>
			<cfloop query="getUsed">
				<li>
					<a href="/SpecimenResults.cfm?loan_project_id=#project_id#&collection_id=#collection_id#">
						#c# #collection# Specimens
					</a>
				</li>
				<cfif nc.recordcount gt 1>
					<li><a href="SpecimenResults.cfm?project_id=#project_id#">#ts.totspec# total specimens</a></li>
				</cfif>
			</cfloop>
		</ul>
	</cfif>
</cfoutput>