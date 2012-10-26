<cfinclude template="/includes/functionLib.cfm">
<cfoutput>
	<cfquery name="pubs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
			<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			    select distinct 
			        media.media_id,
			        media.media_uri,
			        media.mime_type,
			        media.media_type,
			        media.preview_uri
			     from
			         media,
			         media_relations,
			         media_labels
			     where
			         media.media_id=media_relations.media_id and
			         media.media_id=media_labels.media_id (+) and
			         media_relations.media_relationship like '%publication' and
			         media_relations.related_primary_key = #publication_id#
			</cfquery>
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
					<cfloop query="media">
						<cfinvoke component="/component/functions" method="getMediaPreview" returnVariable="puri">
							<cfinvokeargument name="preview_uri" value="#preview_uri#">
							<cfinvokeargument name="media_type" value="#media_type#">
						</cfinvoke>
		            	<cfquery name="labels"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select
								media_label,
								label_value
							from
								media_labels
							where
								media_id=#media_id#
						</cfquery>
						<cfquery name="desc" dbtype="query">
							select label_value from labels where media_label='description'
						</cfquery>
						<cfset alt="Media Preview Image">
						<cfif desc.recordcount is 1>
							<cfset alt=desc.label_value>
						</cfif>
						<li>
			               <a href="#media_uri#" target="_blank"><img src="#puri#" alt="#alt#" class="theThumb"></a>
		                   	<p>
								#media_type# (#mime_type#)
			                   	<br><a href="/media/#media_id#" target="_blank">Media Details</a>
								<br>#alt#
							</p>
						</li>
					</cfloop>
				</ul>
			<cfset i=i+1>
		</cfloop>
	</cfif>
	</cfoutput>
	
	
	
	