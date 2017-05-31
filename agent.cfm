<cfinclude template = "/includes/_header.cfm">
<cfoutput>
	<cfset title = "Agent Activity">
	<cfparam name="agent_name" default="">
	<form name="f" method="post" action="agent.cfm">
		<label for="agent_name">Agent Name</label>
		<input type="text" value="#agent_name#" name="agent_name" id="agent_name">
		<br><input type="submit" value="search">
	</form>
	<!---- if we don't have a name or an ID, abort ---->
	<!--- if we DO NOT have an ID and we DO have a name,  search ---->
	<cfif (not isdefined("agent_id") or len(agent_id) is 0) and len(agent_name) gt 0>
		<cfquery name="srch" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				agent.agent_id,
				agent.preferred_agent_name,
				agent_type
			from
				agent,
				agent_name
			where
				agent.agent_id=agent_name.agent_id (+) and
				(
					upper(agent.preferred_agent_name) like '%#trim(ucase(escapeQuotes(agent_name)))#%' or
					upper(agent_name.agent_name) like '%#trim(ucase(escapeQuotes(agent_name)))#%'
				)
			group by
				agent.agent_id,
				agent.preferred_agent_name,
				agent_type
			order by
				agent.preferred_agent_name
		</cfquery>
		<cfif srch.recordcount is 0>
			<p>
				Nothing found.<cfabort>
			</p>
		<cfelseif srch.recordcount is 1>
			<cflocation url="agent.cfm?agent_id=#srch.agent_id#&agent_name=#srch.preferred_agent_name#" addtoken="false">
		<cfelse>
			<cfset title = "Agent Activity: Search Results">
			<p>
				#srch.recordcount# matches found:
				<ul>
					<cfloop query="srch">
						<li>
							<a href="agent.cfm?agent_id=#srch.agent_id#&agent_name=#srch.preferred_agent_name#">
								#srch.preferred_agent_name#
							</a> (#srch.agent_type#)
						</li>
					</cfloop>
				</ul>
			</p>
		</cfif>
	</cfif>
	<!--- If we DO have an ID, show the agent info ---->
	<cfif isdefined("agent_id") and len(agent_id) gt 0>
		<div align="center">
			<div class="ui-state-highlight ui-corner-all" style="display:inline-block;margin:1em;padding:1em;">
				Your login may prevent access to some linked data. The summary data below are accurate, except
				agent-related encumbrances exclude records.
				<cfif session.roles contains "manage_agent">
					<div align="left">
						<br><a href="/info/agentActivity.cfm?agent_id=#agent_id#">Agent Activity</a>
						<br><a href="/agents.cfm?agent_id=#agent_id#">Edit Agent</a>
					</div>
				</cfif>
			</div>
		</div>
		<cfquery name="agent" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				agent.preferred_agent_name,
				agent.agent_type,
				agent.agent_remarks,
				agent_name.agent_name,
				agent_name.agent_name_type
			FROM
				agent,
				agent_name
			where
				agent.agent_id=agent_name.agent_id (+) and
				agent.agent_id=#val(agent_id)#
			order by agent_name
		</cfquery>

		<cfset title = "#agent.preferred_agent_name# - Agent Activity">
		<!--- control what names are released, order what's left --->
		<cfset names=structNew()>
		<!---
			list of name types that we want to display here in order
			EXCLUDE:
				login (nobody cares),
				preferred (we've already got one)
		 ---->
		 	<cfset ordnames=queryNew("name,nametype")>
			<cfset ant='first name,middle name,last name,full,Kew abbr.,maiden,married,initials plus last,last plus initials,last name first'>
			<cfset ant=ant&',abbreviation,aka,alternate spelling,initials,labels,job title'>
			<cfset q=1>
			<cfloop list="#ant#" index="i">
				<cfquery name="p" dbtype="query">
					select agent_name from agent where agent_name_type='#i#' order by agent_name
				</cfquery>
				<cfloop query="p">
					<cfset queryaddrow(ordnames,1)>
					<cfset querysetcell(ordnames,"name",agent_name,q)>
					<cfset querysetcell(ordnames,"nametype",i,q)>
					<cfset q=q+1>
				</cfloop>
			</cfloop>
		<p>
			Agent Summary for <strong>#agent.preferred_agent_name# (#agent.agent_type#)</strong>
		</p>
		<cfif ordnames.recordcount gt 0>
			<p>
				Agent Names:
				<ul>
					<cfloop query="ordnames">
						<li>
							#name# (#nametype#) <a href="agent.cfm?agent_name=#name#" class="infoLink"> [ search ]</a>
						</li>
					</cfloop>
				</ul>
			</p>
		</cfif>
		<cfif len(agent.agent_remarks) gt 0>
			<p>
				Agent Remarks:
				<blockquote>
					#agent.agent_remarks#
				</blockquote>
			</p>
		</cfif>
		<cfif agent.agent_type is "group">
			<cfquery name="grpagnt" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
				select MEMBER_AGENT_ID,getPreferredAgentName(MEMBER_AGENT_ID) name from group_member where GROUP_AGENT_ID=#val(agent_id)#
			</cfquery>
			<p>
				Group Members:
				<ul>
					<cfloop query="grpagnt">
						<li><a href="/agent.cfm?agent_id=#MEMBER_AGENT_ID#">#name#</a></li>
					</cfloop>
				</ul>
			</p>
		</cfif>

		<cfquery name="agent_relations" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				AGENT_RELATIONSHIP,agent_name,RELATED_AGENT_ID
			from agent_relations,preferred_agent_name
			where
			agent_relations.RELATED_AGENT_ID=preferred_agent_name.agent_id and
			agent_relations.agent_id=#val(agent_id)#
		</cfquery>
		<cfif agent_relations.recordcount gt 0>
			<p>
				Relationships FROM #agent.preferred_agent_name#:
				<ul>
					<cfloop query="agent_relations">
						<li>#AGENT_RELATIONSHIP# <a href="agent.cfm?agent_id=#RELATED_AGENT_ID#">#agent_name#</a></li>
					</cfloop>
				</ul>
			</p>
		</cfif>
		<cfquery name="agent_relationsto" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select AGENT_RELATIONSHIP,agent_name,preferred_agent_name.agent_id
			from agent_relations,preferred_agent_name
			where
			agent_relations.agent_id=preferred_agent_name.agent_id and
			RELATED_AGENT_ID=#val(agent_id)#
		</cfquery>
		<cfif agent_relationsto.recordcount gt 0>
			<p>
				Relationships TO #agent.preferred_agent_name#:
				<ul>
					<cfloop query="agent_relationsto">
						<li><a href="agent.cfm?agent_id=#agent_id#">#agent_name#</a> is #AGENT_RELATIONSHIP#</li>
					</cfloop>
				</ul>
			</p>
		</cfif>
		<cfquery name="group_member" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				agent_name,
				GROUP_AGENT_ID
			from
				group_member, preferred_agent_name
			where
				group_member.GROUP_AGENT_ID=preferred_agent_name.agent_id and
				MEMBER_AGENT_ID=#val(agent_id)#
			order by agent_name
		</cfquery>
		<cfif group_member.recordcount gt 0>
			<p>
				Groups:
				<ul>
					<cfloop query="group_member">
						<li><a href="agent.cfm?agent_id=#GROUP_AGENT_ID#">#agent_name#</a></li>
					</cfloop>
				</ul>
			</p>
		</cfif>
		<cfquery name="collector" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				count(distinct(collector.collection_object_id)) cnt,
				collection.guid_prefix,
		        collection.collection_id,
		        collector.collector_role
			from
				collector,
				cataloged_item,
				collection
			where
				collector.collection_object_id = cataloged_item.collection_object_id AND
				cataloged_item.collection_id = collection.collection_id AND
				agent_id=#val(agent_id)# and
				cataloged_item.collection_object_id not in (
					select coll_object_encumbrance.collection_object_id from
						coll_object_encumbrance,
						encumbrance where
						encumbrance.EXPIRATION_DATE > sysdate and
						coll_object_encumbrance.encumbrance_id=encumbrance.encumbrance_id and
						encumbrance.encumbrance_action in ('mask collector','mask preparator','mask record')
				)
			group by
				collection.guid_prefix,
		        collection.collection_id,
		        collector.collector_role
		</cfquery>
		<cfquery name="ssc" dbtype="query">
			select sum(cnt) sc from collector
		</cfquery>
		<cfquery name="cnorole" dbtype="query">
			select
				sum(cnt) cnt,
				guid_prefix,
				collection_id
			from
				collector
			group by
				guid_prefix,
				collection_id
			order by
				guid_prefix,
				collection_id
		</cfquery>
		<cfif collector.recordcount gt 0>
			<p>
				Collected or Prepared <a href="/SpecimenResults.cfm?collector_agent_id=#agent_id#">#ssc.sc# specimens</a>:
				<ul>
					<CFLOOP query="cnorole">
						<li>
							<a href="/SpecimenResults.cfm?collector_agent_id=#agent_id#&collection_id=#cnorole.collection_id#">
								#cnorole.cnt# #cnorole.guid_prefix#
							</a> specimens
							<cfquery name="crole" dbtype="query">
								select collector_role,cnt from collector where collection_id=#collection_id#
							</cfquery>
							<ul>
								<cfloop query="crole">
									<li>
										<a href="/SpecimenResults.cfm?collector_agent_id=#agent_id#&collection_id=#cnorole.collection_id#&coll_role=#crole.collector_role#">
											#crole.collector_role#: #crole.cnt#
										</a>
									</li>
								</cfloop>
							</ul>
						</li>
				  	</CFLOOP>
				</ul>
			</p>
		</cfif>

		<cfquery name="collectormedia" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c
			from
				collector,
				media_relations
			where
				collector.collection_object_id = media_relations.related_primary_key AND
				media_relations.media_relationship='shows cataloged_item' AND
				collector.agent_id=#val(agent_id)#
		</cfquery>
		<cfif collectormedia.c gt 0>
			<p>
				Media:
				<ul>
					<li>
						<a href="/MediaSearch.cfm?action=search&collected_by_agent_id=#agent_id#">
							#collectormedia.c#  Media records referencing collected/prepared specimens
						</a>
					</li>
				</ul>
			</p>
		</cfif>
		<cfquery name="project_agent" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				project_name,
				project.project_id
			from
				project_agent,
				project
			where
				 project.project_id=project_agent.project_id and
				 project_agent.agent_id=#val(agent_id)#
			group by
				project_name,
				project.project_id
		</cfquery>
		<cfif len(project_agent.project_name) gt 0>
			<p>
				Projects
				<ul>
					<cfloop query="project_agent">
						<li><a href="/ProjectDetail.cfm?project_id=#project_id#">#project_name#</a></li>
					</cfloop>
				</ul>
			</p>
		</cfif>
		<cfquery name="publication_agent" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				publication.PUBLICATION_ID,
				full_citation,
				doi
			from
				publication,
				publication_agent
			where
				publication.publication_id=publication_agent.publication_id and
				publication_agent.agent_id=#val(agent_id)#
			group by
				publication.PUBLICATION_ID,
				full_citation,
				doi
			order by
				full_citation
		</cfquery>
		<cfif len(publication_agent.full_citation) gt 0>
			<p>
				Publications
				<ul>
					<cfloop query="publication_agent">
						<li>
							<a href="/publication/#PUBLICATION_ID#">#full_citation#</a>
							<cfquery name="citn" datasource="uam_god">
								select count(*) c from citation where publication_id=#publication_id#
							</cfquery>
							<ul>
								<li>
									<cfif citn.c gt 0>
										<a href="/SpecimenResults.cfm?publication_id=#publication_id#">#citn.c# citations</a>
									<cfelse>
										No citations
									</cfif>
								</li>
								<cfif len(doi) gt 0>
									<li>
										<a href="https://doi.org/#doi#" target="_blank" class="external">#doi#</a>
									</li>
								</cfif>
							</ul>
						</li>
					</cfloop>
				</ul>
			</p>
		</cfif>
		<cfquery name="address" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				address
			from
				address
			where
				address.address_type='url' and
				address.agent_id=#val(agent_id)#
			order by
				address
		</cfquery>
		<cfif len(address.address) gt 0>
			<p>
				Address
				<ul>
					<cfloop query="address">
						<li>
							<a target="_blank" class="external" href="#address#">#address#</a>
						</li>
					</cfloop>
				</ul>
			</p>
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template = "/includes/_footer.cfm">