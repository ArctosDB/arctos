<cfinclude template = "includes/_header.cfm">
<cfif action is "nothing">
	<cfif isdefined("publication_id") and len(publication_id) gt 0>
		<cflocation url="SpecimenUsage.cfm?action=search&publication_id=#publication_id#" addtoken="false">
	</cfif>
	<cfset title = "Search for Results">
	<cfquery name="ctColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection,collection_id from collection order by collection
	</cfquery>
	<cfquery name="ctpublication_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select publication_type from ctpublication_type order by publication_type
	</cfquery>
	<cfquery name="ctAgentRole" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select agent_role from (
			select PROJECT_AGENT_ROLE agent_role from CTPROJECT_AGENT_ROLE
			union
			select AUTHOR_ROLE agent_role from CTAUTHOR_ROLE
		) order by agent_role
	</cfquery>
	<cfoutput>
	<h2>Publication / Project Search</h2>
	<form action="SpecimenUsage.cfm" method="post">
		<input name="action" type="hidden" value="search">
		<cfif not isdefined("toproject_id")><cfset toproject_id=""></cfif>
		
			<input name="toproject_id" type="hidden" value="#toproject_id#">
		<table width="90%">
			<tr valign="top">
				<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
					<td>
						<ul>
							<li>
								<a href="/Project.cfm?action=makeNew">New Project</a>
							</li>
							<li>
								<a href="/Publication.cfm?action=newPub">New Publication</a>
							</li>
						</ul>
					</td>
				</cfif>
				<td>
					<h4>Project or Publication</h4>
					<label for="p_title"><span class="helpLink" id="project_publication_title">Title or Full Citation</span></label>
					<input name="p_title" id="p_title" type="text">
					<label for="author"><span class="helpLink" id="project_publication_agent">Participant</span></label>
					<input name="author" id="author" type="text">
					<label for="agent_role">Agent Role</label>
					<select name="agent_role" id="agent_role">
						<option value="">anything</option>
						<cfloop query="ctAgentRole">
							<option value="#agent_role#">#agent_role#</option>
						</cfloop>
					</select>
					<label for="year"><span class="helpLink" id="project_publication_year">Year</span></label>
					<input name="year" id="year" type="text">
					<label for="year"><span class="helpLink" id="proj_pub_remark">Remark</span></label>
					<input name="proj_pub_remark" id="proj_pub_remark" type="text">
				</td>
				<td>
					<h4>Project</h4>	
					<label for="project_type"><span class="helpLink" id="project_type">Project Type</span></label>
					<select name="project_type" id="project_type">
						<option value=""></option>
						<option value="loan">Uses Specimens</option>
						<option value="loan_no_pub">Uses Specimens, no publication</option>
						<option value="accn">Contributes Specimens</option>
						<option value="both">Uses and Contributes</option>
						<option value="neither">Neither Uses nor Contributes</option>
					</select>
					<label for="descr_len">Project Description Minimum Length</label>
					<input name="descr_len" id="descr_len" type="text" value="100">
				</td>
				<td>
					<h4>Publication</h4>
					<label for="doi"><span class="helpLink" id="_doi">DOI</span></label>
					<input name="doi" id="doi" type="text">
					<label for="publication_type"><span class="helpLink" id="publication_type">Publication Type</span></label>
					<select name="publication_type" id="publication_type" size="1">
						<option value=""></option>
						<cfloop query="ctpublication_type">
							<option value="#publication_type#">#publication_type#</option>
						</cfloop>
					</select>
					<label for="collection_id">Cites Collection</label>
					<select name="collection_id" id="collection_id" size="1">
						<option value="">All</option>
						<cfloop query="ctColl">
							<option value="#collection_id#">#collection#</option>
						</cfloop>
					</select>
					<label for="onlyCitePubs">
						<span class="helpLink" id="pub_cites_specimens">Cites specimens?</span>
					</label>
					<select name="onlyCitePubs" id="onlyCitePubs">
						<option value=""></option>
						<option value="1">Cites Specimens</option>
						<option value="0">Cites no Specimens</option>
					</select>
					<label for="cited_sci_Name">
						<span class="helpLink" id="cited_sci_Name">Cited Scientific Name</span>
					</label>
					<input name="cited_sci_Name" id="cited_sci_Name" type="text">
					<label for="current_sci_Name">
						<span class="helpLink" id="accepted_sci_name">Accepted Scientific Name</span>
					</label>
					<input name="current_sci_Name" id="current_sci_Name" type="text">
					<label for="is_peer_reviewed_fg"><span class="helpLink" id="is_peer_reviewed_fg">Peer Reviewed only?</span></label>
					<select name="is_peer_reviewed_fg" id="is_peer_reviewed_fg">
						<option value=""></option>
						<option value="1">yes</option>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="99" align="center">
					<input type="submit" value="Search" class="schBtn">
					<input type="reset" value="Clear Form" class="clrBtn">
				</td>
			</tr>
		</table>
	</form>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------->
<cfif action is "search">
	<cfoutput>
		<cfset title = "Usage Search Results">
		<cfset sel = "
					SELECT 
						project.project_id,
						project.project_name,
						project.start_date,
						project.end_date,
						preferred_agent_name.agent_name,
						PROJECT_AGENT_REMARKS,
						project_agent_role,
						agent_position">
		<cfset frm="
					FROM 
						project,
						project_agent,
						preferred_agent_name">
		<cfset whr="
					WHERE
						project.project_id = project_agent.project_id (+) AND
						project_agent.agent_id = preferred_agent_name.agent_id (+)">
		<cfset go="no">	
		<cfif (isdefined("doi") AND len(doi) gt 0) or 
			(isdefined("publication_type") AND len(publication_type) gt 0) or
			(isdefined("collection_id") AND len(collection_id) gt 0) or 
			(isdefined("onlyCitePubs") AND len(onlyCitePubs) gt 0) or
			(isdefined("collection_id") AND len(collection_id) gt 0) or
			(isdefined("cited_sci_Name") AND len(cited_sci_Name) gt 0) or
			(isdefined("current_sci_Name") AND len(current_sci_Name) gt 0) or
			(isdefined("is_peer_reviewed_fg") AND len(is_peer_reviewed_fg) gt 0)>
			<cfset whr = "#whr# AND 1=2">
			<cfset go="yes">
		</cfif>	
		<cfif isdefined("agent_role") AND len(agent_role) gt 0>
			<cfset title = "#agent_role#">
			<cfset go="yes">
			<cfset whr = "#whr# AND project_agent.project_agent_role='#agent_role#'">
		</cfif>	
		<cfif isdefined("p_title") AND len(p_title) gt 0>
			<cfset title = "#p_title#">
			<cfset go="yes">
			<cfset whr = "#whr# AND upper(regexp_replace(project.project_name,'<[^>]*>')) like '%#ucase(escapeQuotes(p_title))#%'">
		</cfif>
		<cfif isdefined("descr_len") AND len(descr_len) gt 0>
			<cfset go="yes">
			<cfset whr = "#whr# AND project.project_description is not null and length(project.project_description) >= #descr_len#">
		</cfif>
		<cfif isdefined("author") AND len(author) gt 0>
			<cfset go="yes">
			<cfset whr = "#whr# AND project.project_id IN 
				( select project_id FROM project_agent,agent_name WHERE 
					project_agent.agent_id=agent_name.agent_id and upper(agent_name) like '%#escapeQuotes(ucase(author))#%' )">
		</cfif>
		<cfif isdefined("project_type") AND len(project_type) gt 0>
			<cfset go="yes">
			<cfif project_type is "loan">
				<cfset whr = "#whr# AND 
					project.project_id in (
						select project_id from project_trans,loan_item 
						where project_trans.transaction_id=loan_item.transaction_id)">
			<cfelseif project_type is "accn">
				<cfset whr = "#whr# AND 
					project.project_id in (
						select project_id from project_trans,cataloged_item 
						where project_trans.transaction_id=cataloged_item.accn_id)">
			<cfelseif project_type is "both">
				<cfset whr = "#whr# AND
					project.project_id in (
						select project_id from project_trans,loan_item 
						where project_trans.transaction_id=loan_item.transaction_id)
					and project.project_id in (
						select project_id from project_trans,cataloged_item 
						where project_trans.transaction_id=cataloged_item.accn_id)">
			<cfelseif project_type is "neither">
				<cfset whr = "#whr# AND
					project.project_id not in (
						select project_id from project_trans,loan_item 
						where project_trans.transaction_id=loan_item.transaction_id)
					and project.project_id not in (
						select project_id from project_trans,cataloged_item 
						where project_trans.transaction_id=cataloged_item.accn_id)">
			<cfelseif project_type is "loan_no_pub">
				<cfset whr = "#whr# AND
					project.project_id in (
						select project_id from project_trans,loan_item 
						where project_trans.transaction_id=loan_item.transaction_id) and
					project.project_id not in (
						select project_id from project_publication
						)">
			</cfif>
		</cfif>
		<cfif isdefined("year") AND isnumeric(year)>
			<cfset go="yes">
			<cfset whr = "#whr# AND (
				#year# between to_number(to_char(start_date,'YYYY')) AND to_number(to_char(end_date,'YYYY'))
				)">
		</cfif>
		<cfif isdefined("proj_pub_remark") AND len(proj_pub_remark) gt 0>
			<cfset go="yes">
			<cfset whr = "#whr# AND upper(PROJECT_REMARKS) like '%#escapeQuotes(ucase(proj_pub_remark))#%' )">
		</cfif>
		<cfif isdefined("publication_id") AND len(publication_id) gt 0>
			<cfset whr = "#whr# AND project.project_id in
				(select project_id from project_publication where publication_id=#publication_id#)">
			<cfset go="yes">
		</cfif>
		<cfif isdefined("project_id") AND len(project_id) gt 0>
			<cfset whr = "#whr# AND project.project_id = #project_id#">
			<cfset go="yes">
		</cfif>
		<cfif go is "no">
			<cfset whr = "#whr# and 1=2">
		</cfif>
		<cfset sql = "#sel# #frm# #whr# ORDER BY project_name">
		<cfset checkSql(sql)>
		<cfquery name="projects" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfquery name="projNames" dbtype="query">
			SELECT 
				project_id,
				project_name,
				start_date,
				end_date
			FROM
				projects
			GROUP BY
				project_id,
				project_name,
				start_date,
				end_date
			ORDER BY
				project_name
		</cfquery>
		<cfset i=1>
		<cfset go="no">
		<cfset basSQL = "SELECT 
			publication.publication_id,
			publication.publication_type,
			publication.full_citation,
			publication.doi,
			publication.pmid,
			count(distinct(citation.collection_object_id)) numCits,
			taxonomy.display_name,
			taxonomy.scientific_name">
		<cfset basFrom = "
			FROM 
			publication,
			publication_agent,
			project_publication,
			agent_name,
			citation,
			taxonomy_publication,
			taxonomy">
		<cfset basWhere = "
			WHERE 
				publication.publication_id = project_publication.publication_id (+) and
				publication.publication_id = citation.publication_id (+) 
				AND publication.publication_id = publication_agent.publication_id (+) 
				AND publication_agent.agent_id = agent_name.agent_id (+) and
				publication.publication_id=taxonomy_publication.publication_id (+) and
				taxonomy_publication.taxon_name_id=taxonomy.taxon_name_id (+)">
		<cfif (isdefined("project_type") AND len(project_type) gt 0)>
			<cfset basWhere = "#basWhere# AND 1=2">
		</cfif>
		<cfif isdefined("doi") AND len(doi) gt 0>
			<cfset basWhere = "#basWhere# AND doi ='#doi#'">
			<cfset go="yes">
		</cfif>
		<cfif isdefined("p_title") AND len(#p_title#) gt 0>
			<cfset basWhere = "#basWhere# AND UPPER(regexp_replace(publication.full_citation,'<[^>]*>')) LIKE '%#ucase(escapeQuotes(p_title))#%'">
			<cfset go="yes">
		</cfif>
		<cfif isdefined("agent_role") AND len(agent_role) gt 0>
			<cfset basWhere = "#basWhere# AND publication_agent.author_role='#agent_role#'">
			<cfset go="yes">
		</cfif>
		<cfif isdefined("publication_type") AND len(#publication_type#) gt 0>
			<cfset basWhere = "#basWhere# AND publication.publication_type = '#publication_type#'">
			<cfset go="yes">
		</cfif>
		<cfif isdefined("publication_id") AND len(#publication_id#) gt 0>
			<cfset basWhere = "#basWhere# AND publication.publication_id=#publication_id#">
			<cfset go="yes">
		</cfif>
		<cfif isdefined("collection_id") AND len(#collection_id#) gt 0>
			<cfset go="yes">
			<cfset basFrom = "#basFrom#,cataloged_item">
			<cfif #basFrom# does not contain "citation">
				<cfset basFrom = "#basFrom#,citation">
			</cfif>
			<cfset basWhere = "#basWhere# AND publication.publication_id = citation.publication_id 
				AND citation.collection_object_id = cataloged_item.collection_object_id AND
				cataloged_item.collection_id = #collection_id#">
		</cfif>
		<cfif isdefined("author") AND len(#author#) gt 0>
			<cfset go="yes">
			<cfset author = #replace(author,"'","''","all")#>
			<cfset basWhere = "#basWhere# AND UPPER(agent_name.agent_name) LIKE '%#ucase(author)#%'">
		</cfif>
		<cfif isdefined("year") AND isnumeric(year)>
			<cfset go="yes">
			<cfset basWhere = "#basWhere# AND publication.PUBLISHED_YEAR = #year#">
		</cfif>
		<cfif isdefined("onlyCitePubs") AND len(onlyCitePubs) gt 0>
			<cfset go="yes">
			<cfif onlyCitePubs is "0">
				<cfif basFrom does not contain "citation">
					<cfset basFrom = "#basFrom#,citation">
				</cfif>
				<cfset basWhere = "#basWhere# AND publication.publication_id = citation.publication_id (+) and citation.collection_object_id is null">
			<cfelse>
				<cfif #basFrom# does not contain "citation">
					<cfset basFrom = "#basFrom#,citation">
				</cfif>
				<cfset basWhere = "#basWhere# AND publication.publication_id = citation.publication_id">
			</cfif>
		</cfif>
		<cfif isdefined("is_peer_reviewed_fg") AND is_peer_reviewed_fg is 1>
			<cfset go="yes">
			<cfset basWhere = "#basWhere# AND publication.is_peer_reviewed_fg=1">
		</cfif>
		<cfif isdefined("current_Sci_Name") AND len(#current_Sci_Name#) gt 0>
			<cfset go="yes">
			<cfset basFrom = "#basFrom# ,
				citation CURRENT_NAME_CITATION, 
				cataloged_item ci_current,
				identification catItemTaxa">
			<cfset basWhere = "#basWhere# AND publication.publication_id = CURRENT_NAME_CITATION.publication_id (+)
				AND CURRENT_NAME_CITATION.collection_object_id = ci_current.collection_object_id (+)
				AND ci_current.collection_object_id = catItemTaxa.collection_object_id
				AND catItemTaxa.accepted_id_fg = 1
				AND upper(catItemTaxa.scientific_name) LIKE '%#ucase(current_Sci_Name)#%'">
		</cfif>
		<cfif isdefined("cited_Sci_Name") AND len(cited_Sci_Name) gt 0>
			<cfset go="yes">
			<cfset basFrom = "#basFrom# ,
				citation CITED_NAME_CITATION, identification CitTaxa">
				<cfset basWhere = "#basWhere# AND publication.publication_id = CITED_NAME_CITATION.publication_id (+)
					AND CITED_NAME_CITATION.identification_id = CitTaxa.identification_id (+)
					AND upper(CitTaxa.scientific_name) LIKE '%#ucase(cited_Sci_Name)#%'">
		</cfif>
		
		
		<cfif isdefined("proj_pub_remark") AND len(proj_pub_remark) gt 0>
			<cfset go="yes">
			<cfset whr = "#whr# AND upper(PUBLICATION_REMARKS) like '%#escapeQuotes(ucase(proj_pub_remark))#%' )">
		</cfif>
		
		
		<cfif go is "no">
			<cfset basWhere = "#basWhere# AND 1=2">
		</cfif>
		<cfset basSql = "#basSQL# #basFrom# #basWhere#
			group by
				publication.publication_id,
				publication.publication_type,
				publication.full_citation,
				publication.doi,
				publication.pmid,
				taxonomy.display_name,
				taxonomy.scientific_name
			ORDER BY 
				publication.full_citation,
				publication.publication_id">
		<cfquery name="publication" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(basSQL)#
		</cfquery>
		<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
			<a href="/Reports/SpecUsageReport.cfm?project_id=#valuelist(projects.project_id)#&publication_id=#valuelist(publication.publication_id)#">Create Report Data</a>
		</cfif>
		<table border width="90%"><tr><td width="50%" valign="top">
			<h3>
				Projects
				<cfif projNames.recordcount is 0>
					<div class="notFound">
						No projects matched your criteria.
					</div>
				<cfelse>
					(#projNames.recordcount# results)
				</cfif>
			</h3>
			<cfset i=1>
			<cfloop query="projNames">
				<cfquery name="thisAuth" dbtype="query">
					SELECT 
						agent_name, 
						project_agent_role 
					FROM 
						projects 
					WHERE 
						project_id = #project_id# 
					GROUP BY 
						agent_name, 
						project_agent_role 
					ORDER BY 
						agent_position
				</cfquery>
				<cfquery name="thisSponsor" dbtype="query">
					SELECT 
						PROJECT_AGENT_REMARKS,
						agent_name
					FROM 
						projects 
					WHERE 
						project_id = #project_id# and
						PROJECT_AGENT_ROLE='Sponsor'
					GROUP BY 
						PROJECT_AGENT_REMARKS,
						agent_name
					ORDER BY 
						agent_name
				</cfquery>
				<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<a href="/ProjectDetail.cfm?project_id=#project_id#">
						<div class="indent">
						#project_name#
						</div>
					</a>
					<cfloop query="thisSponsor">
						Sponsored by #agent_name# <cfif len(PROJECT_AGENT_REMARKS) gt 0>: #PROJECT_AGENT_REMARKS#</cfif><br>
					</cfloop>
					<cfloop query="thisAuth">
						#agent_name# (#project_agent_role#)<br>
					</cfloop>
					#dateformat(start_date,"yyyy-mm-dd")# - #dateformat(end_date,"yyyy-mm-dd")#
					<br><a href="javascript: openAnnotation('project_id=#project_id#')">Annotate</a>
					<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
						<br><a href="/Project.cfm?Action=editProject&project_id=#project_id#">Edit</a>
					</cfif>
				</div>
				<cfset i=i+1>
			</cfloop>
		</td><td width="50%" valign="top">
		<h3>
			Publications
			<cfif publication.recordcount is 0>
				<div class="notFound">
					No publications matched your criteria.
				</div>
			<cfelseif publication.recordcount is 1>
				<cfset title = "#publication.full_citation#">	
			<cfelse>
				(#publication.recordcount# results)
			</cfif>
		</h3>
		<cfquery name="pubs" dbtype="query">
			SELECT
				publication_id,
				publication_type,
				full_citation,
				numCits,
				doi,
				pmid
			FROM
				publication
			GROUP BY
				publication_id,
				publication_type,
				full_citation,
				numCits,
				doi,
				pmid
			ORDER BY
				full_citation
		</cfquery>
		<cfloop query="pubs">
			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<p class="indent">
					#full_citation#
				</p>	
				<ul>
					<li><a href="javascript: openAnnotation('publication_id=#publication_id#')">Annotate</a></li>
					<li>
						<cfif numCits gt 0>
							<a href="/SpecimenResults.cfm?publication_id=#publication_id#">#numCits# Cited Specimens</a>
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
					<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_publications")>
						<li><a href="/Publication.cfm?publication_id=#publication_id#">Edit</a></li>
						<li><a href="/Citation.cfm?publication_id=#publication_id#">Manage Citations</a></li>
						<cfif isdefined("toproject_id") and len(toproject_id) gt 0>
							<li><a href="/Project.cfm?action=addPub&publication_id=#publication_id#&project_id=#toproject_id#">Add to Project</a></li>
						</cfif>
					</cfif>
					<cfquery name="pubmedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select 
							media.media_id,
							media_type,
							mime_type,
							media_uri,
							preview_uri
						from 
							media,
							media_relations
						where 
							media.media_id=media_relations.media_id and
							media_relationship like '% publication' and
							related_primary_key=#publication_id#
					</cfquery>
					<cfif len(pubmedia.media_id) gt 0>
						<div class="thumbs">
							<div class="thumb_spcr">&nbsp;</div>
								<cfloop query="pubmedia">
									<cfset puri=getMediaPreview(preview_uri,media_type)>
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
					               <div class="one_thumb">
						               <a href="#media_uri#" target="_blank"><img src="#getMediaPreview(preview_uri,media_type)#" alt="#alt#" class="theThumb"></a>
					                   	<p>
											#media_type# (#mime_type#)
						                   	<br><a href="/media/#media_id#" target="_blank">Media Details</a>
											<br>#alt#
										</p>
									</div>
								</cfloop>
								<div class="thumb_spcr">&nbsp;</div>
							</div>
					</cfif>
					<cfquery name="ptax" dbtype="query">
						select 
							display_name,
							scientific_name 
						from 
							publication
						where 
							publication_id=#publication_id# and
							scientific_name is not null
						group by 
							display_name,
							scientific_name
						order by 
							scientific_name
					</cfquery>
					<cfloop query="ptax">
						<li><a href="/name/#scientific_name#">#display_name#</a></li>
					</cfloop>
				</ul>
			</div>
			<cfset i=#i#+1>
		</cfloop>
		</td></tr></table>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------->
<cfinclude template = "/includes/_footer.cfm">