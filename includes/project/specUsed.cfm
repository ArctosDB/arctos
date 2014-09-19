<cfoutput>
	<cfquery name="getUsed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT 
			collection.guid_prefix,
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
			collection.guid_prefix,
			collection.collection_id
		UNION -- data loans
		SELECT 
			collection.guid_prefix,
			collection.collection_id,
			count(distinct(cataloged_item.collection_object_id)) c
		FROM 
			cataloged_item,
			collection,
			loan_item,
			project_trans
		WHERE
			cataloged_item.collection_id=collection.collection_id and
			cataloged_item.collection_object_id = loan_item.collection_object_id AND
			loan_item.transaction_id = project_trans.transaction_id AND
			project_trans.project_id = #project_id#
		group by
			collection.guid_prefix,
			collection.collection_id
	</cfquery>
	<cfquery name="ts" dbtype="query">
		select sum(c) totspec from getUsed
	</cfquery>
	<cfquery name="nc" dbtype="query">
			select guid_prefix from getUsed group by guid_prefix
		</cfquery>
	<cfif getUsed.recordcount gt 0>
		<h2>Specimens Used</h2>
		<ul>
			<cfloop query="getUsed">
				<li>
					<a href="/SpecimenResults.cfm?loan_project_id=#project_id#&collection_id=#collection_id#">
						#c# #guid_prefix# Specimens
					</a>
					<a href="/bnhmMaps/bnhmMapData.cfm?loan_project_id=#project_id#&collection_id=#collection_id#"> [ BerkeleyMapper ]</a>
				</li>
			</cfloop>
			<cfif nc.recordcount gt 1>
				<li>
					<a href="/SpecimenResults.cfm?loan_project_id=#project_id#">#ts.totspec# total specimens</a>
					<a href="/bnhmMaps/bnhmMapData.cfm?loan_project_id=#project_id#"> [ BerkeleyMapper ]</a>				
				</li>
			</cfif>
		</ul>
	</cfif>
</cfoutput>