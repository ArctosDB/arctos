<cfoutput>
	<cfquery name="pubs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			formatted_publication.publication_id,
			formatted_publication, 
			DESCRIPTION,
			LINK
		FROM 
			project_publication,
			formatted_publication,
			publication_url
		WHERE 
			project_publication.publication_id = formatted_publication.publication_id AND
			project_publication.publication_id = publication_url.publication_id (+) AND
			format_style = 'long' and
			project_publication.project_id = #project_id#
		order by
			formatted_publication
	</cfquery>
	<cfquery name="pub" dbtype="query">
		select
			formatted_publication,
			publication_id
		from
			pubs
		group by 
			formatted_publication,
			publication_id
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
					#formatted_publication#
				</p>
				<a href="/SpecimenUsage.cfm?action=search&publication_id=#publication_id#">Details</a>
				&nbsp;~&nbsp;
				<a href="/SpecimenResults.cfm?publication_id=#publication_id#">Cited Specimens</a>
				<cfquery name="links" dbtype="query">
					select description,
					link from pubs
					where publication_id=#publication_id#
				</cfquery>
				<cfif len(#links.description#) gt 0>
					<ul>
						<cfloop query="links">
							<li><a href="#link#" target="_blank">#description#</a></li>
						</cfloop>
					</ul>
				</cfif>			
			</div>
			<cfset i=i+1>
		</cfloop>
	</cfif>
	</cfoutput>