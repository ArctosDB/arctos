<cfoutput>
	<h2>Specimens Contributed</h2>
	<cfquery name="getContSpecs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			collection,
			collection.collection_id,
			count(*) c
		FROM 
			project,
			project_trans,
			accn,
			cataloged_item,
			collection
		WHERE 
			accn.transaction_id = cataloged_item.accn_id AND
			cataloged_item.collection_id=collection.collection_id and
			project_trans.transaction_id = accn.transaction_id AND 
			project.project_id = project_trans.project_id AND 
			project.project_id = #project_id#
		group by
			collection,
			collection.collection_id
	</cfquery>
	<cfif getContSpecs.recordcount is 0>
		<div class="notFound">
			This project contributed no specimens.
		</div>
	<cfelse>
		<cfquery name="ts" dbtype="query">
			select sum(c) totspec from getContSpecs
		</cfquery>
		This project contributed <a href="SpecimenResults.cfm?project_id=#project_id#">#ts.totspec# Specimens</a>
		<ul>
			<cfloop query="getContSpecs">
				<li>#c# #collection# <a href="SpecimenResults.cfm?project_id=#project_id#&collection_id=#collection_id#">Specimens</a></li>
			</cfloop>
		</ul>
	</cfif>
</cfoutput>