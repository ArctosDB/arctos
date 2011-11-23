<cfoutput>
	<cfquery name="pubs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			publication.publication_id,
			full_citation,
			doi,
			pmid,
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
			full_citation,
			doi,
			pmid
		order by
			full_citation
	</cfquery>
	<cfif pubs.recordcount gt 0>
		<h2>Publications</h2>
		This project produced #pubs.recordcount# publications.
		<cfset i=1>
		<cfloop query="pubs">
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
					<cfif len(doi) gt 0>
						<li><a class="external" target="_blank" href="http://dx.doi.org/#doi#">http://dx.doi.org/#doi#</a></li>
					</cfif>
					<cfif len(pmid) gt 0>
						<li><a class="external" target="_blank" href="http://www.ncbi.nlm.nih.gov/pubmed/#pmid#">PubMed</a></li>
					</cfif>
					<li><a href="/SpecimenUsage.cfm?action=search&publication_id=#publication_id#">Details</a></li>
				</ul>
			</div>
			<cfset i=i+1>
		</cfloop>
	</cfif>
	</cfoutput>