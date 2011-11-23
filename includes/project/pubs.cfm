<cfoutput>
	<cfquery name="pubs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			publication.publication_id,
			full_citation, 
			count(citation.collection_object_id) numCit
		FROM 
			project_publication,
			publication,
			citation
		WHERE 
			project_publication.publication_id = publication.publication_id AND
			publication.publication_id=citation.publication_id (+) and
			project_publication.project_id = #project_id#
		group by
			publication.publication_id,
			full_citation
		order by
			full_citation
	</cfquery>
	<cfquery name="pub" dbtype="query">
		select
			full_citation,
			publication_id,
			numCit
		from
			pubs
		group by 
			full_citation,
			publication_id,
			numCit
		order by
			formatted_publication
	</cfquery>
	<cfif pub.recordcount gt 0>
		<h2>Publications</h2>
		This project produced #pub.recordcount# publications.
		<cfset i=1>
		<cfloop query="pub">
			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<p class="indent">
					#full_citation#
				</p>
				<ul>
					<li>
						<cfif numCit gt 0>
							<a href="/SpecimenResults.cfm?publication_id=#publication_id#">#numCit# Cited Specimens</a>				
						<cfelse>
							No Citations
						</cfif>
					</li>
					<li><a href="/SpecimenUsage.cfm?action=search&publication_id=#publication_id#">Details</a></li>
				</ul>
			</div>
			<cfset i=i+1>
		</cfloop>
	</cfif>
	</cfoutput>