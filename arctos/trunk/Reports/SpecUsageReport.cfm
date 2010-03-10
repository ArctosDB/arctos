<cfinclude template="/includes/_header.cfm">
<cfoutput>
	
	<cfset session.projectReportTable="projTable#cfid##cftoken#">
	<cftry>
		<cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			drop table #session.projectReportTable#
		</cfquery>
	<cfcatch><!--- not there, so what? ---></cfcatch>
	</cftry>
	<cfquery name="buildIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		create table #session.projectReportTable# (
			project_id number,
			project_name varchar2(4000),
			project_dates varchar2(4000),
			project_agents varchar2(4000),
			project_sponsors varchar2(4000),
			numberProjectAccnSpecimens number,
			numberProjectLoanSpecimens number,
			publication_id number,
			formatted_publication varchar2(4000),
			numberOfCitations number,
			publication_media varchar2(4000)
		)
	</cfquery>
	<cfif len(project_id) gt 0>
		<cfquery name="p" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select
				project.project_id,
				project.project_name,
				to_char(project.start_date,'DD Mon YYYY') start_date,
				to_char(project.end_date,'DD Mon YYYY') end_date
			from
				project
			where
				project_id in (#project_id#)
		</cfquery>
		<cfloop query="p">
			<cfquery name="pa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					agent_name
				from
					project_agent,
					agent_name
				where
					project_agent.agent_name_id=agent_name.agent_name_id and
					project_id=#p.project_id#
				order by
					AGENT_POSITION
			</cfquery>
			<cfquery name="ps" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					agent_name,
					ACKNOWLEDGEMENT
				from
					project_sponsor,
					agent_name
				where
					project_sponsor.agent_name_id=agent_name.agent_name_id and
					project_id=#p.project_id#
			</cfquery>
			<cfquery name="pan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					count(distinct(cataloged_item.collection_object_id)) numSpec
				from
					project_trans,
					accn,
					cataloged_item
				where
					project_trans.TRANSACTION_ID=accn.TRANSACTION_ID and
					accn.TRANSACTION_ID=cataloged_item.accn_id and
					project_id=#p.project_id#
			</cfquery>
			<cfquery name="plo" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					count(distinct(specimen_part.derived_from_cat_item)) numSpec
				from
					project_trans,
					loan,
					loan_item,
					specimen_part
				where
					project_trans.TRANSACTION_ID=loan.TRANSACTION_ID and
					loan.TRANSACTION_ID=loan_item.TRANSACTION_ID and
					loan_item.collection_object_id=specimen_part.collection_object_id and
					project_id=#p.project_id#
			</cfquery>
			<cfif pa.recordcount is 1>
				<cfset project_agents=pa.agent_name>
			<cfelseif pa.recordcount is 2>
				<cfset project_agents=valuelist(pa.agent_name," and ")>
			<cfelseif pa.recordcount gt 2>
				<cfset project_agents=valuelist(pa.agent_name,",")>
				<cfset lval = "and " & trim(ListLast(project_agents))>
				<cfset project_agents=listdeleteat(project_agents,listlen(project_agents))>
				<cfset project_agents=listappend(project_agents,lval)>
				<cfset project_agents=listchangedelims(project_agents,", ")>
			<cfelse>
				<cfset project_agents="">
			</cfif>
			<cfif ps.recordcount is 1>
				<cfset project_sponsors=ps.agent_name>
			<cfelseif ps.recordcount is 2>
				<cfset project_sponsors=valuelist(ps.agent_name," and ")>
			<cfelseif ps.recordcount gt 2>
				<cfset project_sponsors=valuelist(ps.agent_name,",")>
				<cfset lval = "and " & trim(ListLast(project_sponsors))>
				<cfset project_sponsors=listdeleteat(project_sponsors,listlen(project_sponsors))>
				<cfset project_sponsors=listappend(project_sponsors,lval)>
				<cfset project_sponsors=listchangedelims(project_sponsors,", ")>
			<cfelse>
				<cfset project_sponsors="">
			</cfif>
			<cfif p.start_date is p.end_date>
				<cfset project_dates=p.start_date>
			<cfelseif len(p.start_date) gt 0 and len(p.end_date) gt 0>
				<cfset project_dates=p.start_date & '-' & p.end_date>
			<cfelseif len(p.start_date) gt 0>
				<cfset project_dates=p.start_date>
			<cfelseif len(p.end_date) gt 0>
				<cfset project_dates=p.end_date>			
			</cfif>
			<cfquery name="insProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				insert into #session.projectReportTable# (
					project_id,
					project_name,
					project_dates,
					project_agents,
					project_sponsors,
					numberProjectAccnSpecimens,
					numberProjectLoanSpecimens
				) values (
					#p.project_id#,
					#p.project_name#
					'#project_dates#',
					'#project_agents#',
					'#project_sponsors#',
					#pan.numSpec#,
					#plo.numSpec#
				)
			</cfquery>
		</cfloop>
	</cfif>
	<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from #session.projectReportTable#
	</cfquery>
	<cfdump var="#r#">

</cfoutput>
	<!----------
	<cfabort>
	<cfset i=1>
	<cfset sel = "
			SELECT 
				project.project_id,
				project.project_name,
				project.start_date,
				project.end_date,
				agent_name.agent_name,
				project_agent_role,
				agent_position,
				,
				s_name.agent_name sponsor_name">
		<cfset frm="
				FROM 
					project,
					project_agent,
					agent_name,
					,
					agent_name s_name">
		<cfset whr="
				WHERE 
					project.project_id = project_agent.project_id (+) AND
					project.project_id = project_sponsor.project_id (+) AND
					project_sponsor.agent_name_id = s_name.agent_name_id (+) AND	
					project_agent.agent_name_id = agent_name.agent_name_id (+)">
		<cfset go="no">		
		<cfif isdefined("p_title") AND len(p_title) gt 0>
			<cfset go="yes">
			<cfset whr = "#whr# AND upper(regexp_replace(project.project_name,'<[^>]*>')) like '%#ucase(escapeQuotes(p_title))#%'">
		</cfif>
		<cfif isdefined("author") AND len(author) gt 0>
			<cfset go="yes">
			<cfset whr = "#whr# AND project.project_id IN 
				( select project_id FROM project_agent
					WHERE agent_name_id IN 
						( select agent_name_id FROM agent_name WHERE 
						upper(agent_name) like '%#ucase(author)#%' ))">
				
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
			</cfif>
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
		<cfset checkSql(sql)>
		
		<cfquery name="projects" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			
			project_id number,
			project_name varchar2(4000),
			start_date date,
			end_date date,
			project_agents varchar2(4000),
			project_sponsors varchar2(4000),
			project_media varchar2(4000),
			numberProjectAccnSpecimens number,
			numberProjectLoanSpecimens number,
			publication_id number,
			publication_title varchar2(4000),
			publication_type varchar2(4000),
			
			
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
			<cfset i=i+1>
		</cfloop>
	</td><td width="50%" valign="top">
	<cfset i=1>
	<cfset go="no">
	<cfset basSQL = "SELECT 
			publication.publication_title,
			publication.publication_id,
			publication.publication_type,
			formatted_publication.formatted_publication,
			count(distinct(citation.collection_object_id)) numCits">
	<cfset basFrom = "
		FROM 
			publication,
			publication_author_name,
			project_publication,
			agent_name pubAuth,
			agent_name searchAuth,
			formatted_publication,
			citation">
	<cfset basWhere = "
		WHERE 
		publication.publication_id = project_publication.publication_id (+) and
		publication.publication_id = citation.publication_id (+) 
		AND publication.publication_id = publication_author_name.publication_id (+) 
		AND publication_author_name.agent_name_id = pubAuth.agent_name_id (+)
		AND pubAuth.agent_id = searchAuth.agent_id
		AND formatted_publication.publication_id = publication.publication_id 
		AND formatted_publication.format_style = 'long'">
		
	<cfif isdefined("p_title") AND len(#p_title#) gt 0>
		<cfset basWhere = "#basWhere# AND UPPER(regexp_replace(publication.publication_title,'<[^>]*>')) LIKE '%#ucase(escapeQuotes(p_title))#%'">
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
		<cfset basWhere = "#basWhere# AND UPPER(searchAuth.agent_name) LIKE '%#ucase(author)#%'">
	</cfif>
	<cfif isdefined("year") AND isnumeric(#year#)>
		<cfset go="yes">
		<cfset basWhere = "#basWhere# AND publication.PUBLISHED_YEAR = #year#">
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
			cataloged_item ci_current,
			identification catItemTaxa">
		<cfset basWhere = "#basWhere# AND publication.publication_id = CURRENT_NAME_CITATION.publication_id (+)
			AND CURRENT_NAME_CITATION.collection_object_id = ci_current.collection_object_id (+)
			AND ci_current.collection_object_id = catItemTaxa.collection_object_id
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
				formatted_publication.formatted_publication
			ORDER BY 
				formatted_publication.formatted_publication,
				publication.publication_id">
	<!---<cfset checkSql(basSQL)>--->	
	<cfquery name="publication" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(basSQL)#
	</cfquery>
	
	<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
		<a href="/Reports/SpecUsageReport.cfm">Create Report Data</a>
		<cfset params="">
		<cfloop list="#StructKeyList(form)#" index="key">
			<cfif len(form[key]) gt 0 and key is not "FIELDNAMES" and key is not "ACTION">
					<cfset params=listappend(params,"#key#=#form[key]#","&")>
			</cfif>
		</cfloop>
		<cfloop list="#StructKeyList(url)#" index="key">
			<cfif len(url[key]) gt 0 and key is not "FIELDNAMES" and key is not "ACTION">
					<cfset params=listappend(params,"#key#=#url[key]#","&")>
			</cfif>
		</cfloop>
		<a href="/Reports/SpecUsageReport.cfm?p=#params#">Create Report Data</a>
	</cfif>	
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
				<cfquery name="pubmedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
				<cfif len(#pubmedia.media_id#) gt 0>
					<div class="thumbs">
						<div class="thumb_spcr">&nbsp;</div>
							<cfloop query="pubmedia">
								<cfset puri=getMediaPreview(preview_uri,media_type)>
				            	<cfquery name="labels"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
					
			
			<!---
					
					<li><a href="/MediaSearch.cfm?action=search&media_id=#valuelist(pubmedia.media_id)#" target="_blank">Media</a></li>
					
					--->
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
</cfoutput>

--------->