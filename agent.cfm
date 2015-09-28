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
	<cfif (not isdefined("agent_name") or len(agent_name) is 0) and (not isdefined("agent_id") or len(agent_id) is 0)>
		<cfabort>
	</cfif>
	<!--- if we don't have an ID we should at this point have a name - search ---->
	<cfif not isdefined("agent_id") or len(agent_id) is 0>
		<cfquery name="srch" datasource="uam_god">
			select
				agent_id,
				preferred_agent_name
			from
				agent,
				agent_name
			where
				agent.agent_id=agent_name.agent_id (+) and
				(
					upper(preferred_agent_name) like '%#ucase(agent_name)#%' or
					upper(agent_name) like '%#ucase(agent_name)#%'
				)
		</cfquery>
		<cfif srch.recordcount is 0>
			<p>
				Nothing found.<cfabort>
			</p>
		<cfelseif srch.recordcount is 1>
			<cflocation url="agent.cfm?agent_id=#srch.agent_id#&agent_name=#srch.preferred_agent_name#" addtoken="false">
		<cfelse>
			<cfloop query="srch">
				<br><a href="agent.cfm?agent_id=#srch.agent_id#&agent_name=#srch.preferred_agent_name#">#srch.preferred_agent_name#</a>
			</cfloop>
		</cfif>
	</cfif>
	<!--- if we don't have an ID here, abort ---->

<cfif not isdefined("agent_id") or len(agent_id) is 0>
	<cfabort>
</cfif>


<div class="importantNotification">
	Please note: your login may prevent you from seeing some linked data. The summary data below are accurate.
</div>
<cfquery name="agent" datasource="uam_god">
	select * FROM agent where agent_id=#agent_id#
</cfquery>
<cfquery name="name" datasource="uam_god">
	select agent_name_id, agent_name, agent_name_type FROM agent_name where agent_id=#agent_id#
</cfquery>
<br>Agent:
<table border>
	<tr>
		<td align="right"><strong>Agent Type:</strong></td>
		<td>#agent.agent_type#</td>
	</tr>
</table>
Agent Names:
	<ul>
		<cfloop query="name">
			<li>
				#name.agent_name# (#agent_name_type#)
			</li>
		</cfloop>
	</ul>
	<cfif agent.agent_type is "group">
		<cfquery name="grpagnt" datasource="uam_god">
			select MEMBER_AGENT_ID,getPreferredAgentName(MEMBER_AGENT_ID) name from group_member where GROUP_AGENT_ID=#agent_id#
		</cfquery>
		<p>
			Group Members:
			<ul>
				<cfloop query="grpagnt">
					<li><a href="/agents.cfm?agent_id=#MEMBER_AGENT_ID#">#name#</a></li>
				</cfloop>
			</ul>
		</p>
	</cfif>
	Agent Relationships:
	<cfquery name="agent_relations" datasource="uam_god">
		select AGENT_RELATIONSHIP,agent_name,RELATED_AGENT_ID
		from agent_relations,preferred_agent_name
		where
		agent_relations.RELATED_AGENT_ID=preferred_agent_name.agent_id and
		agent_relations.agent_id=#agent_id#
	</cfquery>
	<ul>
		<cfloop query="agent_relations">
			<li>#AGENT_RELATIONSHIP# <a href="agentActivity.cfm?agent_id=#RELATED_AGENT_ID#">#agent_name#</a></li>
		</cfloop>
	</ul>
	<cfquery name="agent_relations" datasource="uam_god">
		select AGENT_RELATIONSHIP,agent_name,preferred_agent_name.agent_id
		from agent_relations,preferred_agent_name
		where
		agent_relations.agent_id=preferred_agent_name.agent_id and
		RELATED_AGENT_ID=#agent_id#
	</cfquery>
	<ul>
		<cfloop query="agent_relations">
			<li><a href="agentActivity.cfm?agent_id=#agent_id#">#agent_name#</a> is #AGENT_RELATIONSHIP#</li>
		</cfloop>
	</ul>
Groups:
	<cfquery name="group_member" datasource="uam_god">
		select
			agent_name,
			GROUP_AGENT_ID
		from
			group_member, preferred_agent_name
		where
			group_member.GROUP_AGENT_ID=preferred_agent_name.agent_id and
			MEMBER_AGENT_ID=#agent_id#
		order by agent_name
	</cfquery>
	<ul>
		<cfloop query="group_member">
			<li><a href="agentActivity.cfm?agent_id=#GROUP_AGENT_ID#">#agent_name#</a></li>
		</cfloop>
	</ul>



Collected or Prepared specimens:
	<cfquery name="collector" datasource="uam_god">
		select
			count(distinct(collector.collection_object_id)) cnt,
			collection.guid_prefix,
	        collection.collection_id
		from
			collector,
			cataloged_item,
			collection
		where
			collector.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = collection.collection_id AND
			agent_id=#agent_id#
		group by
			collection.guid_prefix,
	        collection.collection_id
	</cfquery>
	<ul>
		<CFLOOP query="collector">
			<li>
				<a href="/SpecimenResults.cfm?collector_agent_id=#agent_id#&collection_id=#collector.collection_id#">#collector.cnt# #collector.guid_prefix#</a> specimens
			</li>
	  	</CFLOOP>
	</ul>


	Media:


	<cfquery name="collectormedia" datasource="uam_god">
		select count(*) c
		from
			collector,
			media_relations
		where
			collector.collection_object_id = media_relations.related_primary_key AND
			media_relations.media_relationship='shows cataloged_item' AND
			collector.agent_id=#agent_id#
	</cfquery>
	<ul>

		<li>
			<a href="/MediaSearch.cfm?action=search&collected_by_agent_id=#agent_id#">
				Media from #collectormedia.c# collected/prepared specimens
			</a>
		</li>
	</ul>
	<cfquery name="project_agent" datasource="uam_god">
			select
				project_name,
				project.project_id
			from
				project_agent,
				project
			where
				 project.project_id=project_agent.project_id and
				 project_agent.agent_id=#agent_id#
			group by
				project_name,
				project.project_id
		</cfquery>
		<cfif len(project_agent.project_name) gt 0>
			Projects
			<ul>
				<cfloop query="project_agent">
					<li><a href="/ProjectDetail.cfm?project_id=#project_id#">#project_name#</a></li>
				</cfloop>
			</ul>
		</cfif>
		<cfquery name="publication_agent" datasource="uam_god">
			select
				publication.PUBLICATION_ID,
				full_citation
			from
				publication,
				publication_agent
			where
				publication.publication_id=publication_agent.publication_id and
				publication_agent.agent_id=#agent_id#
			group by
				publication.PUBLICATION_ID,
				full_citation
		</cfquery>
		<cfif len(publication_agent.full_citation) gt 0>
			Publications
			<ul>
				<cfloop query="publication_agent">
					<li>
						<a href="/Publication.cfm?PUBLICATION_ID=#PUBLICATION_ID#">#full_citation#</a>
						<cfquery name="citn" datasource="uam_god">
							select count(*) c from citation where publication_id=#publication_id#
						</cfquery>
						<ul><li>#citn.c# citations</li></ul>
					</li>
				</cfloop>
			</ul>
		</cfif>

</cfoutput>
<cfinclude template = "/includes/_footer.cfm">