<cfinclude template = "includes/_header.cfm">

<cfif action is "nothing">
	<cfif isdefined("publication_id") and len(publication_id) gt 0>
		<cflocation url="SpecimenUsage.cfm?action=search&publication_id=#publication_id#" addtoken="false">
	</cfif>
	<cfset title = "Search for Results">
	<cfquery name="ctColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection,collection_id from collection order by collection_id
	</cfquery>
	<cfquery name="ctjournal_name" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select journal_name from ctjournal_name order by journal_name
	</cfquery>
	<cfquery name="ctpublication_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select publication_type from ctpublication_type order by publication_type
	</cfquery>
	<h2>Publication / Project Search</h2>
	<form action="SpecimenUsage.cfm" method="post">
		<input name="action" type="hidden" value="search">
		<cfif not isdefined("toproject_id")><cfset toproject_id=""></cfif>
		<cfoutput>
			<input name="toproject_id" type="hidden" value="#toproject_id#">
		</cfoutput>
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
					<label for="p_title">Title</label>
					<input name="p_title" id="p_title" type="text">
					<label for="author">Participant</label>
					<input name="author" id="author" type="text">
					<label for="year">Year</label>
					<input name="year" id="year" type="text">
				</td>
				<td>
					<h4>Project</h4>					
					<label for="sponsor">Project Sponsor</label>
					<input name="sponsor" id="sponsor" type="text">
				</td>
				<td>
					<h4>Publication</h4>
					<cfoutput>
						<label for="publication_type">Publication Type</label>
						<select name="publication_type" id="publication_type" size="1">
							<option value=""></option>
							<cfloop query="ctpublication_type">
								<option value="#publication_type#">#publication_type#</option>
							</cfloop>
						</select>
						<label for="journal">Journal Name</label>
						<select name="journal" id="journal" size="1">
							<option value=""></option>
							<cfloop query="ctjournal_name">
								<option value="#journal_name#">#journal_name#</option>
							</cfloop>
						</select>
						<label for="collection_id">Cites Collection</label>
						<select name="collection_id" id="collection_id" size="1">
							<option value="">All</option>
							<cfloop query="ctColl">
								<option value="#collection_id#">#collection#</option>
							</cfloop>
						</select>
					</cfoutput>					
					<label for="onlyCitePubs">
						<span class="likeLink" onclick="getHelp('onlyCited');">Cites specimens?</span>
					</label>
					<select name="onlyCitePubs" id="onlyCitePubs">
						<option value=""></option>
						<option value="1">Cites Specimens</option>
						<option value="0">Cites no Specimens</option>
					</select>
					<label for="cited_sci_Name">
						<span class="likeLink" onclick="getHelp('cited_sci_name');">Cited Scientific Name</span>
					</label>
					<input name="cited_sci_Name" id="cited_sci_Name" type="text">
					<label for="current_sci_Name">
						<span class="likeLink" onclick="getHelp('accepted_sci_name');">Accepted Scientific Name</span>
					</label>
					<input name="current_sci_Name" id="current_sci_Name" type="text">
					<label for="is_peer_reviewed_fg">Peer Reviewed only?</label>
					<select name="is_peer_reviewed_fg" id="is_peer_reviewed_fg">
						<option value=""></option>
						<option value="1">yes</option>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="99" align="center">
					<input type="submit" 
						value="Search" 
						class="schBtn">
					<input type="reset" 
						value="Clear Form" 
						class="clrBtn">
				</td>
			</tr>
		</table>
	</form>
</cfif>
<!-------------------------------------------------------------------------------------->
<cfif #action# is "search">
<cfoutput>
	<cfset title = "Usage Search Results">
	<cfset i=1>
	<table border width="90%"><tr><td width="50%" valign="top">
		<cfset sel = "
				SELECT 
					project.project_id,
					project.project_name,
					project.start_date,
					project.end_date,
					agent_name.agent_name,
					project_agent_role,
					agent_position,
					ACKNOWLEDGEMENT,
					s_name.agent_name sponsor_name">
		<cfset frm="
				FROM 
					project,
					project_agent,
					agent_name,
					project_sponsor,
					agent_name s_name">
		<cfset whr="
				WHERE 
					project.project_id = project_agent.project_id (+) AND
					project.project_id = project_sponsor.project_id (+) AND
					project_sponsor.agent_name_id = s_name.agent_name_id (+) AND	
					project_agent.agent_name_id = agent_name.agent_name_id (+)">
					
					
		<cfset go="no">		
		<cfif isdefined("p_title") AND len(#p_title#) gt 0>
			<cfset title = "#p_title#">
			<cfset go="yes">
			<cfset whr = "#whr# AND upper(regexp_replace(project.project_name,'<[^>]*>')) like '%#ucase(escapeQuotes(p_title))#%'">
		</cfif>
		<cfif isdefined("author") AND len(#author#) gt 0>
			<cfset go="yes">
			<cfset whr = "#whr# AND project.project_id IN 
				( select project_id FROM project_agent
					WHERE agent_name_id IN 
						( select agent_name_id FROM agent_name WHERE 
						upper(agent_name) like '%#ucase(author)#%' ))">
				
		</cfif>
		<cfif isdefined("sponsor") AND len(#sponsor#) gt 0>
			<cfset go="yes">
			<cfset whr = "#whr# AND project.project_id IN 
				( select project_id FROM project_sponsor
					WHERE agent_name_id IN 
						( select agent_name_id FROM agent_name WHERE 
						upper(agent_name) like '%#ucase(sponsor)#%' ))">
				
		</cfif>
		<cfif isdefined("year") AND isnumeric(#year#)>
			<cfset go="yes">
			<cfset whr = "#whr# AND (
				#year# between to_number(to_char(start_date,'YYYY')) AND to_number(to_char(end_date,'YYYY'))
				)">
		</cfif>
		<cfif isdefined("publication_id") AND len(#publication_id#) gt 0>
			<cfset whr = "#whr# AND project.project_id in
				(select project_id from project_publication where publication_id=#publication_id#)">
			<cfset go="yes">
		</cfif>
		<cfif isdefined("project_id") AND len(#project_id#) gt 0>
			<cfset whr = "#whr# AND project.project_id = #project_id#">
			<cfset go="yes">
		</cfif>
		<cfif go is "no">
			<cfset whr = "#whr# and 1=2">
		</cfif>
		<cfset sql = "#sel# #frm# #whr# ORDER BY project_name">
		<cftry>
			<cfquery name="projects" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				#preservesinglequotes(sql)#
			</cfquery>
			<cfcatch>
				<cfset sql=cfcatch.sql>
				<cfset message=cfcatch.message>
				<cfset queryError=cfcatch.queryError>
				<cf_queryError>
			</cfcatch>
		</cftry>
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
		<h3>Projects</h3>
		<cfif projNames.recordcount is 0>
			<div class="notFound">
				No projects matched your criteria.
			</div>
		</cfif>
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
					ACKNOWLEDGEMENT,
					sponsor_name
				FROM 
					projects 
				WHERE 
					project_id = #project_id# and
					sponsor_name is not null
				GROUP BY 
					ACKNOWLEDGEMENT,
					sponsor_name
				ORDER BY 
					sponsor_name
			</cfquery>
			<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<a href="/ProjectDetail.cfm?project_id=#project_id#">
					<div class="indent">
					#project_name#
					</div>
				</a>
				<cfloop query="thisSponsor">
					Sponsored by #sponsor_name# <cfif len(ACKNOWLEDGEMENT) gt 0>: #ACKNOWLEDGEMENT#</cfif><br>
				</cfloop>
				<cfloop query="thisAuth">
					#agent_name# (#project_agent_role#)<br>
				</cfloop>
				#dateformat(start_date,"dd mmm yyyy")# - #dateformat(end_date,"dd mmm yyyy")#
				<br><a href="javascript: openAnnotation('project_id=#project_id#')">Annotate</a>
				<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
					<br><a href="/Project.cfm?Action=editProject&project_id=#project_id#">Edit</a>
				</cfif>
			</div>
			<cfset i=#i#+1>
		</cfloop>
	</td><td width="50%" valign="top">
	<cfset i=1>
	<cfset go="no">
	<cfset basSQL = "SELECT 
			publication.publication_title,
			publication.publication_id,
			publication.publication_type,
			formatted_publication,
			description,
			link,
			count(distinct(citation.collection_object_id)) numCits">
	<cfset basFrom = "
		FROM 
			publication,
			publication_author_name,
			project_publication,
			agent_name pubAuth,
			agent_name searchAuth,
			formatted_publication,
			publication_url,
			citation">
	<cfset basWhere = "
		WHERE 
		publication.publication_id = project_publication.publication_id (+) and
		publication.publication_id = citation.publication_id (+) 
		AND publication.publication_id = publication_author_name.publication_id (+) 
		AND publication.publication_id = publication_url.publication_id (+) 
		AND publication_author_name.agent_name_id = pubAuth.agent_name_id (+)
		AND pubAuth.agent_id = searchAuth.agent_id
		AND formatted_publication.publication_id (+) = publication.publication_id 
		AND formatted_publication.format_style = 'long'">
		
	<cfif isdefined("p_title") AND len(#p_title#) gt 0>
		<cfset basWhere = "#basWhere# AND UPPER(regexp_replace(publication_title,'<[^>]*>')) LIKE '%#ucase(escapeQuotes(p_title))#%'">
		<cfset go="yes">
	</cfif>
	<cfif isdefined("publication_type") AND len(#publication_type#) gt 0>
		<cfset basWhere = "#basWhere# AND publication_type = '#publication_type#'">
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
		<cfset basWhere = "#basWhere# AND UPPER(searchAuth.agent_name) LIKE '%#ucase(author)#%'">
	</cfif>
	<cfif isdefined("year") AND isnumeric(#year#)>
		<cfset go="yes">
		<cfset basWhere = "#basWhere# AND PUBLISHED_YEAR = #year#">
	</cfif>
	<cfif isdefined("journal") AND len(journal) gt 0>
		<cfset go="yes">
		<cfset basFrom = "#basFrom# ,publication_attributes jname">
		<cfset basWhere = "#basWhere# AND publication.publication_id=jname.publication_id and
			upper(jname.pub_att_value) like '%#ucase(escapeQuotes(journal))#%'">
	</cfif>
	<cfif isdefined("onlyCitePubs") AND len(onlyCitePubs) gt 0>
		<cfset go="yes">
		<cfif onlyCitePubs is "0">
			<cfif #basFrom# does not contain "citation">
				<cfset basFrom = "#basFrom#,citation">
			</cfif>
			<cfset basWhere = "#basWhere# AND publication.publication_id = citation.publication_id (+)
					and citation.collection_object_id is null">
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
			cataloged_item,
			identification catItemTaxa">
		<cfset basWhere = "#basWhere# AND publication.publication_id = CURRENT_NAME_CITATION.publication_id (+)
			AND CURRENT_NAME_CITATION.collection_object_id = cataloged_item.collection_object_id (+)
			AND cataloged_item.collection_object_id = catItemTaxa.collection_object_id
			AND catItemTaxa.accepted_id_fg = 1
			AND upper(catItemTaxa.scientific_name) LIKE '%#ucase(current_Sci_Name)#%'">
	</cfif>
	<cfif isdefined("cited_Sci_Name") AND len(#cited_Sci_Name#) gt 0>
		<cfset go="yes">
		<cfset basFrom = "#basFrom# ,
			citation CITED_NAME_CITATION, taxonomy CitTaxa">
			<cfset basWhere = "#basWhere# AND publication.publication_id = CITED_NAME_CITATION.publication_id (+)
				AND CITED_NAME_CITATION.cited_taxon_name_id = CitTaxa.taxon_name_id (+)
				AND upper(CitTaxa.scientific_name) LIKE '%#ucase(cited_Sci_Name)#%'">
	</cfif>
	<cfif go is "no">
		<cfset basWhere = "#basWhere# AND 1=2">
	</cfif>
	<cfset basSql = "#basSQL# #basFrom# #basWhere#
			group by
				publication.publication_title,
			publication.publication_id,
			publication.publication_type,
			formatted_publication,
			description,
			link ORDER BY formatted_publication,publication_id">
	<cfquery name="publication" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(basSQL)#
	</cfquery>
	<h3>Publications</h3>
	<cfif publication.recordcount is 0>
		<div class="notFound">
			No publications matched your criteria.
		</div>
	<cfelseif publication.recordcount is 1>
		<cfset title = "#publication.publication_title#">	
	</cfif>
	<cfquery name="pubs" dbtype="query">
		SELECT
			publication_id,
			publication_type,
			formatted_publication,
			numCits
		FROM
			publication
		GROUP BY
			publication_id,
			publication_type,
			formatted_publication,
			numCits
		ORDER BY
			formatted_publication
	</cfquery>
	<cfloop query="pubs">
		<div #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
			<p class="indent">
				#formatted_publication#
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
				<cfif isdefined("session.roles") and listfindnocase(session.roles,"manage_publications")>
					<li><a href="/Publication.cfm?publication_id=#publication_id#">Edit</a></li>
					<li><a href="/Citation.cfm?publication_id=#publication_id#">Manage Citations</a></li>
					<cfif isdefined("toproject_id") and len(toproject_id) gt 0>
						<li><a href="/Project.cfm?action=addPub&publication_id=#publication_id#&project_id=#toproject_id#">Add to Project</a></li>
					</cfif>
				</cfif>
				<cfquery name="links" dbtype="query">
					select description,
					link from publication
					where publication_id=#publication_id#
				</cfquery>
				<cfif len(#links.description#) gt 0>
					<cfloop query="links">
						<li>View at <a href="#link#" target="_blank" class="external">#description#</a></li>
					</cfloop>
				</cfif>
				<cfquery name="pubmedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select media_id from media_relations where media_relationship like '% publication' and
					related_primary_key=#publication_id#
				</cfquery>
				<cfif len(#pubmedia.media_id#) gt 0>
					<li><a href="/MediaSearch.cfm?action=search&media_id=#valuelist(pubmedia.media_id)#" target="_blank">Media</a></li>
				</cfif>
			</ul>
			
			
		</div>
		<cfset i=#i#+1>
	</cfloop>
</td></tr></table>
</cfoutput>
</cfif>
<!-------------------------------------------------------------------------------------->
<cfinclude template = "/includes/_footer.cfm">