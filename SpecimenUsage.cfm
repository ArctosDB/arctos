<cfinclude template = "includes/_header.cfm">
<cfset maxNumberOfRows=500>
<cfif action is "nothing">
	<cfif isdefined("publication_id") and len(publication_id) gt 0>
		<cflocation url="SpecimenUsage.cfm?action=search&publication_id=#publication_id#" addtoken="false">
	</cfif>
	<cfset title = "Search for Results">
	<cfquery name="ctColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select guid_prefix,collection_id from collection order by guid_prefix
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
					<label for="descr_len">
						<span class="helpLink" id="project_min_len">Project Description Minimum Length</span>
					</label>
					<input name="descr_len" id="descr_len" type="number" value="100" style="border:1px solid red;">
				</td>
				<td>
					<h4>Publication</h4>
					<label for="doi">
						<span class="helpLink" id="_doi">DOI</span>
						<cfif session.roles contains "manage_publications">
							<span class="likeLink" onclick='$("##doi").val("NULL")'>[ find NULL ]</span>
						</cfif>
					</label>
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
							<option value="#collection_id#">#guid_prefix#</option>
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
					<label for="publication_remarks">
						Publication Remark
						<cfif session.roles contains "manage_publications">
							<span class="likeLink" onclick='$("##publication_remarks").val("!Unable to locate suitable DO")'>[ ! "Unable to locate suitable DOI" ]</span>
						</cfif>
					</label>
					<input name="publication_remarks" id="publication_remarks" type="text">

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
						getPreferredAgentName(parslt.agent_id) agent_name,
						PROJECT_AGENT_REMARKS,
						project_agent_role,
						agent_position">
		<cfset frm="
					FROM
						project,
						project_agent parslt">
		<cfset whr="
					WHERE
						project.project_id = parslt.project_id (+) ">
		<cfset go="no">
		<cfif (isdefined("doi") AND len(doi) gt 0) or
			(isdefined("publication_type") AND len(publication_type) gt 0) or
			(isdefined("collection_id") AND len(collection_id) gt 0) or
			(isdefined("onlyCitePubs") AND len(onlyCitePubs) gt 0) or
			(isdefined("cited_sci_Name") AND len(cited_sci_Name) gt 0) or
			(isdefined("current_sci_Name") AND len(current_sci_Name) gt 0) or
			(isdefined("is_peer_reviewed_fg") AND len(is_peer_reviewed_fg) gt 0 or
			(isdefined("publication_remarks") AND len(publication_remarks) gt 0))
			>
			<cfset whr = "#whr# AND 1=2">
			<cfset go="yes">
		</cfif>
		<cfif isdefined("agent_role") AND len(agent_role) gt 0>
			<cfset title = "#agent_role#">
			<cfset go="yes">
			<cfset frm=frm & ", project_agent pasrch">
			<cfset whr = "#whr# AND project.project_id=pasrch.project_id and pasrch.project_agent_role='#agent_role#'">
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
				'#year#' between start_date AND end_date or start_date like '#year#%' or end_date like '#year#%'
				)">
		</cfif>
		<cfif isdefined("proj_pub_remark") AND len(proj_pub_remark) gt 0>
			<cfset go="yes">
			<cfset whr = "#whr# AND upper(PROJECT_REMARKS) like '%#escapeQuotes(ucase(proj_pub_remark))#%' ">
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

		<cfdump var=#projects#>


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
			publication.full_citation,
			publication.publication_remarks,
			publication.doi,
			publication.pmid,
			count(distinct(citation.collection_object_id)) numCits,
			getPreferredAgentName(pauth.AGENT_ID) authn">
		<cfset basFrom = "
			FROM
			publication,
			citation,
			publication_agent pauth">
		<cfset basWhere = "
			WHERE
				publication.publication_id = citation.publication_id (+) and
				publication.publication_id = pauth.publication_id (+)
				">
		<cfif (isdefined("project_type") AND len(project_type) gt 0)>
			<cfset basWhere = "#basWhere# AND 1=2">
		</cfif>
		<cfif isdefined("publication_remarks") AND len(publication_remarks) gt 0>
			<cfset title = "#publication_remarks#">
			<cfset go="yes">
			<cfif left(publication_remarks,1) is "!">
				<cfset basWhere = "#basWhere# AND (
					publication.publication_remarks is null or
					upper(publication.publication_remarks) not like
						'%#escapeQuotes(ucase(right(publication_remarks,len(publication_remarks)-1)))#%')
				">
			<cfelse>
				<cfset basWhere = "#basWhere# AND upper(publication.publication_remarks) like '%#escapeQuotes(ucase(publication_remarks))#%' ">
			</cfif>
		</cfif>
		<cfif isdefined("doi") AND len(doi) gt 0>
			<cfif compare(doi,"NULL") is 0>
				<cfset basWhere = " #basWhere# AND doi is null">
			<cfelse>
				<cfset basWhere = "#basWhere# AND doi ='#doi#'">
			</cfif>
			<cfset go="yes">
		</cfif>
		<cfif isdefined("p_title") AND len(#p_title#) gt 0>
			<cfset basWhere = "#basWhere# AND UPPER(regexp_replace(publication.full_citation,'<[^>]*>')) LIKE '%#ucase(escapeQuotes(p_title))#%'">
			<cfset go="yes">
		</cfif>
		<cfif isdefined("agent_role") AND len(agent_role) gt 0>
			<cfif basFrom does not contain "pubAgentSrch">
				<cfset basFrom = "#basFrom#,publication_agent pubAgentSrch">
			</cfif>
			<cfset basWhere = "#basWhere# AND publication.publication_id = pubAgentSrch.publication_id
				AND pubAgentSrch.author_role='#agent_role#'">
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
		<cfif isdefined("collection_id") AND len(collection_id) gt 0>
			<cfset go="yes">
			<cfset basFrom = "#basFrom#,cataloged_item">

			<!----
			<cfif basFrom does not contain "spcitation">
				<p>
				basFrom does not contain "spcitation"
				</p>
				<cfset basFrom = "#basFrom#,citation spcitation">
				<cfset basWhere = "#basWhere# AND publication.publication_id = spcitation.publication_id ">
			</cfif>
			---->
			<cfset basWhere = "#basWhere#
				AND citation.collection_object_id = cataloged_item.collection_object_id AND
				cataloged_item.collection_id = #collection_id#">
		</cfif>
		<cfif isdefined("author") AND len(#author#) gt 0>
			<cfset go="yes">
			<cfset author = replace(author,"'","''","all")>
			<cfif basFrom does not contain "pubAgentSrch">
				<cfset basFrom = "#basFrom#,publication_agent pubAgentSrch">
				<cfset basWhere = "#basWhere# AND publication.publication_id = pubAgentSrch.publication_id">
			</cfif>
			<cfif basFrom does not contain "agent_name">
				<cfset basFrom = "#basFrom#,agent_name">
				<cfset basWhere = "#basWhere# AND pubAgentSrch.agent_id=agent_name.agent_id">
			</cfif>
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
			<cfset basWhere = "#basWhere# AND upper(PUBLICATION_REMARKS) like '%#escapeQuotes(ucase(proj_pub_remark))#%'">
		</cfif>
		<cfif go is "no">
			<cfset basWhere = "#basWhere# AND 1=2">
		</cfif>
		<cfset basSql = "#basSQL# #basFrom# #basWhere#
			group by
				publication.publication_id,
				publication.full_citation,
				publication.doi,
				publication.pmid,
				publication.publication_remarks,
				getPreferredAgentName(pauth.AGENT_ID)
			ORDER BY
				publication.full_citation,
				publication.publication_id">

		<cfquery name="publication" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from (#preservesinglequotes(basSQL)#) where rownum<=#maxNumberOfRows#
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
						project_agent_role,
						PROJECT_AGENT_REMARKS
					FROM
						projects
					WHERE
						project_id = #project_id#
					GROUP BY
						agent_name,
						project_agent_role,
						PROJECT_AGENT_REMARKS
					ORDER BY
						agent_position
				</cfquery>

				<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
					<a href="/ProjectDetail.cfm?project_id=#project_id#">
						<div class="indent">
						#project_name#
						</div>
					</a>

					<cfloop query="thisAuth">
						<div style="margin-left:1em;">
							<a target="_blank" href="/agent.cfm?agent_name=#agent_name#">#agent_name#</a> (#project_agent_role#)
							<div style="margin-left:1em;font-size:x-small;font-style:italics">#PROJECT_AGENT_REMARKS#</div>
						</div>
					</cfloop>
					#dateformat(start_date,"yyyy-mm-dd")# - #dateformat(end_date,"yyyy-mm-dd")#
					<br><a href="javascript: openAnnotation('project_id=#project_id#')">Report Problem</a>
					<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
						<br><a href="/Project.cfm?Action=editProject&project_id=#project_id#">Edit</a>
					</cfif>
				</div>
				<cfset i=i+1>
			</cfloop>
		</td><td width="50%" valign="top">
		<h3>
			Publications
			<cfquery name="pubs" dbtype="query">
				SELECT
					publication_id,
					full_citation,
					doi,
					pmid,
					publication_remarks,
					NUMCITS
				FROM
					publication
				GROUP BY
					publication_id,
					full_citation,
					doi,
					pmid,
					publication_remarks,
					NUMCITS
				ORDER BY
					full_citation
			</cfquery>
			<cfif pubs.recordcount is 0>
				<div class="notFound">
					No publications matched your criteria.
				</div>
			<cfelseif pubs.recordcount is 1>
				<cfset title = "#pubs.full_citation#">
			<cfelse>
				<cfif pubs.recordcount is maxNumberOfRows>
					(CAUTION: This form will only return #maxNumberOfRows# results; you may not be seeing everything.)
				<cfelse>
					(#pubs.recordcount# results)
				</cfif>
			</cfif>
		</h3>


		<cfloop query="pubs">
			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<p class="indent">
					<a href="/publication/#publication_id#">#full_citation#</a>
				</p>
				<ul>
					<li><a href="javascript: openAnnotation('publication_id=#publication_id#')">Report Problem</a></li>
					<li>
						<cfif numCits gt 0>
							<a href="/SpecimenResults.cfm?publication_id=#publication_id#">#numCits# Cited Specimens</a>
						<cfelse>
							No Citations
						</cfif>
					</li>
					<li>
						<cfquery name="sensu" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
							select count(*) numSensu from identification where publication_id=#publication_id#
						</cfquery>

						<cfif sensu.numSensu gt 0>
							<a href="/SpecimenResults.cfm?id_pub_id=#publication_id#">#sensu.numSensu# <em>sensu</em> Identifications</a>
						<cfelse>
							No <em>sensu</em> Identifications
						</cfif>
					</li>
					<cfif len(doi) gt 0>
						<li><a class="external" target="_blank" href="http://dx.doi.org/#doi#">http://dx.doi.org/#doi#</a></li>
					<cfelse>
						<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_publications")>
							<li><a href="/Publication.cfm?publication_id=#publication_id#">NO DOI! Please edit and add.</a></li>
						</cfif>
					</cfif>
					<cfif len(pmid) gt 0>
						<li><a class="external" target="_blank" href="http://www.ncbi.nlm.nih.gov/pubmed/#pmid#">PubMed</a></li>
					</cfif>
					<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_publications")>
						<cfif len(publication_remarks) gt 0>
							<li>#publication_remarks#</li>
						</cfif>
						<li><a href="/Publication.cfm?publication_id=#publication_id#">Edit</a></li>
						<li><a href="/Citation.cfm?publication_id=#publication_id#">Manage Citations</a></li>
						<cfif isdefined("toproject_id") and len(toproject_id) gt 0>
							<li><a href="/Project.cfm?action=addPub&publication_id=#publication_id#&project_id=#toproject_id#">Add to Project</a></li>
						</cfif>
					</cfif>
					<cfquery name="pauths" dbtype="query">
						select authn from publication where authn is not null and publication_id=#publication_id# group by authn order by authn
					</cfquery>

					<cfif pauths.recordcount gt 0>
						<li>
							Publication Agents
							<ul>
								<cfloop query="pauths">
									<li><a target="_blank" href="/agent.cfm?agent_name=#authn#">#authn#</a></li>
								</cfloop>
							</ul>

						</li>
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
					               <div class="one_thumb">
						               <a href="/media/#media_id#?open" target="_blank"><img src="#puri#" alt="#alt#" class="theThumb"></a>
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
					<cfquery name="ptax"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select
							scientific_name
						from
							taxonomy_publication,
							taxon_name
						where
							taxonomy_publication.taxon_name_id=taxon_name.taxon_name_id and
							taxonomy_publication.publication_id=#publication_id#
						group by
							scientific_name
						order by
							scientific_name
					</cfquery>
					<cfloop query="ptax">
						<li><a href="/name/#scientific_name#">#scientific_name#</a></li>
					</cfloop>
				</ul>
			</div>
			<cfset i=i+1>
		</cfloop>
		</td></tr></table>
	</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------->
<cfinclude template = "/includes/_footer.cfm">