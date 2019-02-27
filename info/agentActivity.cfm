<cfinclude template = "/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title = "Agent Activity">
<cfoutput>
<a href="/agents.cfm?agent_id=#agent_id#" target="_top">Edit Agent</a>
<div class="importantNotification">
	Please note: your login may prevent you from seeing some linked data. The summary data below are accurate.
</div>
<cfquery name="agent" datasource="uam_god">
	select AGENT_ID,
	AGENT_TYPE,
	AGENT_REMARKS,
	PREFERRED_AGENT_NAME,
	getPreferredAgentName(CREATED_BY_AGENT_ID) createdby,
	CREATED_DATE
 	FROM agent where agent_id=#agent_id#
</cfquery>
<cfquery name="name" datasource="uam_god">
	select agent_name_id, agent_name, agent_name_type FROM agent_name where agent_id=#agent_id#
</cfquery>
<h3>
	#agent.PREFERRED_AGENT_NAME# (#agent.agent_type#)
	<div style="font-size:small; margin-left:1em;">created by #agent.createdby#, #agent.CREATED_DATE#</div>
</h3>
<p>
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
</p>
<p>
	Remarks:

	<div>#agent.AGENT_REMARKS#</div>
</p>
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
 Address:
	<cfquery name="address" datasource="uam_god">
		select * from address where agent_id=#agent_id#
	</cfquery>
	<ul>
		<cfloop query="address">
			<li>
				#ADDRESS_TYPE#:
				<cfif ADDRESS_TYPE is "url" or ADDRESS_TYPE is "ORCID" or ADDRESS_TYPE is "Wikidata">
					<a href="#ADDRESS#" class="external" target="_blank">#ADDRESS#</a>
				<cfelse>
					#ADDRESS#
				</cfif>
			</li>
		</cfloop>
	</ul>
	<cfquery name="collector" datasource="uam_god">
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
				agent_id=#val(agent_id)#
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
			where
				guid_prefix is not null
			group by
				guid_prefix,
				collection_id
			order by
				guid_prefix,
				collection_id
		</cfquery>
		<cfquery name="cnorolenc" dbtype="query">
			select
				sum(cnt) cnt,
				collector_role
			from
				collector
			where
				guid_prefix is not null
			group by
				collector_role
			order by
				collector_role
		</cfquery>
		Collector [<span class="infoLink" onclick="getCtDoc('ctcollector_role');">Define</span>]
		<cfif cnorole.recordcount gt 0>
			<table border id="t" class="sortable">
				<tr>
					<th>Role</th>
					<th>Collection</th>
					<th>SpecimenCount</th>
					<th>Link</th>
				</tr>
				<tr>
					<td>(any)</td>
					<td>(all)</td>
					<td>#ssc.sc#</td>
					<td><a href="/SpecimenResults.cfm?collector_agent_id=#agent_id#">Open Specimen Results</a></td>
				</tr>
				<CFLOOP query="cnorolenc">
					<tr>
						<td>#cnorolenc.collector_role#</td>
						<td>(all)</td>
						<td>#cnorolenc.cnt#</td>
						<td>
							<a href="/SpecimenResults.cfm?collector_agent_id=#agent_id#&coll_role=#cnorolenc.collector_role#">
								Open Specimen Results
							</a>
						</td>
					</tr>
				</CFLOOP>
				<CFLOOP query="cnorole">
					<tr>
						<td>(any)</td>
						<td>#cnorole.guid_prefix#</td>
						<td>#cnorole.cnt#</td>
						<td>
							<a href="/SpecimenResults.cfm?collector_agent_id=#agent_id#&collection_id=#cnorole.collection_id#">
								Open Specimen Results
							</a>
						</td>
					</tr>
					<cfquery name="crole" dbtype="query">
						select collector_role,cnt from collector where collection_id=#collection_id#
					</cfquery>
					<cfloop query="crole">
						<tr>
							<td>#crole.collector_role#</td>
							<td>#cnorole.guid_prefix#</td>
							<td>#crole.cnt#</td>
							<td>
								<a href="/SpecimenResults.cfm?collector_agent_id=#agent_id#&collection_id=#cnorole.collection_id#&coll_role=#crole.collector_role#">
									Open Specimen Results
								</a>
							</td>
						</tr>
					</cfloop>
				</CFLOOP>
			</table>
		</cfif>




	Media:
	<cfquery name="media" datasource="uam_god">
		select
			media_relationship,
			count(*) c
		from
			media_relations
		where
			media_relationship like '% agent' and
			related_primary_key=#agent_id#
		group by
			media_relationship
		order by
			media_relationship
	</cfquery>
	<cfquery name="media_assd_relations" datasource="uam_god">
		select media_id from media_relations where CREATED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<cfquery name="media_labels" datasource="uam_god">
		select media_id from media_labels where ASSIGNED_BY_AGENT_ID=#agent_id#
	</cfquery>

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
		<cfloop query="media">
			<li>
				#media.c#
				<a href="/MediaSearch.cfm?action=search&relationshiptype1=#media.media_relationship#&relationship1=#agent.preferred_agent_name#">
					#media.media_relationship#
				</a>
				entries.
			</li>
		</cfloop>
		<li>
			<a href="/MediaSearch.cfm?action=search&collected_by_agent_id=#agent_id#">
				Media from #collectormedia.c# collected/prepared specimens
			</a>
		</li>
		<li>
			Assigned #media_assd_relations.recordcount# Media Relationships.
		</li>
		<li>
			Assigned #media_labels.recordcount# Media Labels.
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
					<li><a href="/project/#project_id#">#project_name#</a></li>
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



Entered Specimens:
	<cfquery name="entered" datasource="uam_god">
		select
			count(*) cnt,
			guid_prefix,
			collection.collection_id
		from
			coll_object,
			cataloged_item,
			collection
		where
			coll_object.collection_object_id = cataloged_item.collection_object_id and
			cataloged_item.collection_id=collection.collection_id and
			ENTERED_PERSON_ID =#agent_id#
		group by
			guid_prefix,
			collection.collection_id
	</cfquery>
	<ul>
		<cfloop query="entered">
			<li>
				<a href="/SpecimenResults.cfm?entered_by_id=#agent_id#&collection_id=#collection_id#">#cnt# #guid_prefix#</a> specimens
			</li>
		</cfloop>
	</ul>
Edited Specimens:
	<cfquery name="last_edit" datasource="uam_god">
		select
			count(*) cnt,
			guid_prefix,
			collection.collection_id
		from
			coll_object,
			cataloged_item,
			collection
		where
			coll_object.collection_object_id = cataloged_item.collection_object_id and
			cataloged_item.collection_id=collection.collection_id and
			LAST_EDITED_PERSON_ID=#agent_id#
		group by
			guid_prefix,
			collection.collection_id
	</cfquery>
	<ul>
		<cfloop query="last_edit">
			<li>
				<a href="/SpecimenResults.cfm?edited_by_id=#agent_id#&collection_id=#collection_id#">#cnt# #guid_prefix#</a> specimens
			</li>
		</cfloop>
	</ul>
Specimen Attribute Determiner:
	<cfquery name="attributes" datasource="uam_god">
		select
			count(attributes.collection_object_id) c,
			count(distinct(cataloged_item.collection_object_id)) s,
			collection.collection_id,
			guid_prefix
		from
			attributes,
			cataloged_item,
			collection
		where
			cataloged_item.collection_object_id=attributes.collection_object_id and
			cataloged_item.collection_id=collection.collection_id and
			determined_by_agent_id=#agent_id#
		group by
			collection.collection_id,
			guid_prefix
	</cfquery>
	<ul>
		<cfloop query="attributes">
			<li>
				#c# attributes for #s#
				<a href="/SpecimenResults.cfm?attributed_determiner_agent_id=#agent_id#&collection_id=#attributes.collection_id#">
					#attributes.guid_prefix#</a> specimens
			</li>
		</cfloop>
	</ul>

Specimen Encumbrances:
	<ul>
		<cfquery name="encumbrance" datasource="uam_god">
			select count(*) cnt from encumbrance where encumbering_agent_id=#agent_id#
		</cfquery>
		<cfquery name="coll_object_encumbrance" datasource="uam_god">
			select
				count(distinct(coll_object_encumbrance.collection_object_id)) specs,
				guid_prefix,
				collection.collection_id
			 from
			 	encumbrance,
			 	coll_object_encumbrance,
			 	cataloged_item,
			 	collection
			 where
			 	encumbrance.encumbrance_id = coll_object_encumbrance.encumbrance_id and
			 	coll_object_encumbrance.collection_object_id=cataloged_item.collection_object_id and
			 	cataloged_item.collection_id=collection.collection_id and
			 	encumbering_agent_id=#agent_id#
			 group by
			 	guid_prefix,
				collection.collection_id
		</cfquery>
		<li>Owns #encumbrance.cnt# encumbrances</li>
		<cfloop query="coll_object_encumbrance">
			<li>Encumbered <a href="/SpecimenResults.cfm?encumbering_agent_id=#agent_id#&collection_id=#collection_id#">
				#specs# #guid_prefix#</a> records</li>
		</cfloop>
	</ul>
Identification:
	<cfquery name="identification" datasource="uam_god">
		select
			count(*) cnt,
			count(distinct(identification.collection_object_id)) specs,
			collection.collection_id,
			collection.guid_prefix
		from
        	identification,
        	identification_agent,
			cataloged_item,
			collection
        where
        	cataloged_item.collection_id=collection.collection_id and
			cataloged_item.collection_object_id=identification.collection_object_id and
			identification.identification_id=identification_agent.identification_id and
        	identification_agent.agent_id=#agent_id#
		group by
			collection.collection_id,
			collection.guid_prefix
	</cfquery>
	<ul>
		<cfloop query="identification">
			<li>
				#cnt# identifications for <a href="/SpecimenResults.cfm?identified_agent_id=#agent_id#&collection_id=#collection_id#">
					#specs# #guid_prefix#</a> specimens
			</li>
		</cfloop>
	</ul>
Specimen-Events:
	<cfquery name="assigned_by_agent_id" datasource="uam_god">
		select
			count(*) cnt,
			count(distinct(collection_object_id)) specs from SPECIMEN_EVENT where assigned_by_agent_id=#agent_id#
	</cfquery>
	<ul>
		<li>Assigned #assigned_by_agent_id.cnt# events for #assigned_by_agent_id.specs# specimens</li>
	</ul>
	<cfquery name="VERIFIED_BY_AGENT_ID" datasource="uam_god">
		select
			count(*) cnt,
			count(distinct(collection_object_id)) specs from SPECIMEN_EVENT where VERIFIED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<ul>
		<li>Verified #VERIFIED_BY_AGENT_ID.cnt# events for #VERIFIED_BY_AGENT_ID.specs# specimens</li>
	</ul>

Collecting Event Edits:
	<cfquery name="collecting_event_archive" datasource="uam_god">
		select
			count(*) cnt,
			count(distinct(collecting_event_id)) dct from collecting_event_archive where CHANGED_AGENT_ID=#agent_id#
	</cfquery>
	<ul>
		<li><a href="/info/collectingEventArchive.cfm?who=Anna+Chinn">#collecting_event_archive.cnt# edits for for #collecting_event_archive.dct# Collecting Events</a></li>
	</ul>


Locality Edits:
	<cfquery name="locality_archive" datasource="uam_god">
		select
			count(*) cnt,
			count(distinct(locality_id)) dct from locality_archive where CHANGED_AGENT_ID=#agent_id#
	</cfquery>
	<ul>
		<li>#locality_archive.cnt# edits for for #locality_archive.dct# localities</li>
	</ul>


Geology Edits:
	<cfquery name="geology_archive" datasource="uam_god">
		select
			count(*) cnt,
			count(distinct(locality_id)) dct from geology_archive where CHANGED_AGENT_ID=#agent_id#
	</cfquery>
	<ul>
		<li>#geology_archive.cnt# edits for for #geology_archive.dct# geology attributes</li>
	</ul>






Permits:
	<cfquery name="permit_to" datasource="uam_god">
		select
			permit.permit_id,
			permit.PERMIT_NUM,
			getPermitTypeReg(permit.permit_id) permit_Type,
			permit_agent.AGENT_ROLE
		from
			permit,
			permit_type,
			permit_agent
		where
			permit.permit_id=permit_type.permit_id (+) and
			permit.permit_id=permit_agent.permit_id and
			permit_agent.agent_id=#agent_id#
		order by
			PERMIT_NUM,
			AGENT_ROLE
	</cfquery>
	<cfquery name="basepermit" dbtype="query">
		select
			permit_id,
			permit_num,
			permit_Type
		from
			permit_to
		group by
			permit_id,
			permit_num,
			permit_Type
	</cfquery>
	<ul>
		<cfloop query="basepermit">
			<li>
				<a href="/Permit.cfm?action=search&permit_id=#permit_id#">#PERMIT_NUM#</a>
				<ul>
					<li>Type(s) & Regulation(s) #permit_type#</li>
					<cfquery name="tpa" dbtype="query">
						select AGENT_ROLE from permit_to where permit_id=#permit_id# group by AGENT_ROLE order by AGENT_ROLE
					</cfquery>
					<cfloop query="tpa">
						<li>Role: #AGENT_ROLE#</li>
					</cfloop>
				</ul>
			</li>
		</cfloop>
	</ul>
	<!----
	<ul>
		<cfloop query="permit_to">
			<li>
				Permit <a href="/Permit.cfm?action=search&ISSUED_TO_AGENT_ID=#agent_id#">#PERMIT_NUM#: #PERMIT_TYPE#</a> was issued to
			</li>
		</cfloop>
		<cfquery name="permit_by" datasource="uam_god">
			select
				PERMIT_NUM,
				PERMIT_TYPE
			from
				permit
			where ISSUED_by_AGENT_ID=#agent_id#
		</cfquery>
		<cfloop query="permit_by">
			<li>
				Issued Permit <a href="/Permit.cfm?action=search&ISSUED_by_AGENT_ID=#agent_id#">#PERMIT_NUM#: #PERMIT_TYPE#</a>
			</li>
		</cfloop>
		<cfquery name="permit_contact" datasource="uam_god">
			select
				PERMIT_NUM,
				PERMIT_TYPE
			from
				permit
			where CONTACT_AGENT_ID=#agent_id#
		</cfquery>
		<cfloop query="permit_by">
			<li>
				Contact for Permit <a href="/Permit.cfm?action=search&CONTACT_AGENT_ID=#agent_id#">#PERMIT_NUM#: #PERMIT_TYPE#</a>
			</li>
		</cfloop>
	</ul>
	---->
Transactions
	<ul>
		<cfquery name="shipment" datasource="uam_god">
			select
				LOAN_NUMBER,
				loan.transaction_id,
				guid_prefix
			from
				shipment,
				loan,
				trans,
				collection
			where
				shipment.transaction_id=loan.transaction_id and
				loan.transaction_id =trans.transaction_id and
				trans.collection_id=collection.collection_id and
				PACKED_BY_AGENT_ID=#agent_id#
		</cfquery>
		<cfloop query="shipment">
			<li>Packed Shipment for <a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#guid_prefix# #loan_number#</a></li>
		</cfloop>
		<a name="shipping"></a>
		<cfquery name="ship_to" datasource="uam_god">
			select
				LOAN_NUMBER,
				loan.transaction_id,
				guid_prefix
			from
				shipment,
				address,
				loan,
				trans,
				collection
			where
				shipment.transaction_id=loan.transaction_id and
				loan.transaction_id =trans.transaction_id and
				trans.collection_id=collection.collection_id and
				shipment.SHIPPED_TO_ADDR_ID=address.address_id and
				address.agent_id=#agent_id#
		</cfquery>
		<cfloop query="ship_to">
			<li><a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#guid_prefix# #loan_number#</a> shipped to addr</li>
		</cfloop>
		<cfquery name="ship_from" datasource="uam_god">
			select
				LOAN_NUMBER,
				loan.transaction_id,
				guid_prefix
			from
				shipment,
				address,
				loan,
				trans,
				collection
			where
				shipment.transaction_id=loan.transaction_id and
				loan.transaction_id =trans.transaction_id and
				trans.collection_id=collection.collection_id and
				shipment.SHIPPED_FROM_ADDR_ID=address.address_id and
				address.agent_id=#agent_id#
		</cfquery>
		<cfloop query="ship_from">
			<li><a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#guid_prefix# #loan_number#</a> shipped from</li>
		</cfloop>
		<cfquery name="trans_agent_l" datasource="uam_god">
			select
				loan.transaction_id,
				TRANS_AGENT_ROLE,
				loan_number,
				guid_prefix
			from
				trans_agent,
				loan,
				trans,
				collection
			where
				trans_agent.transaction_id=loan.transaction_id and
				loan.transaction_id=trans.transaction_id and
				trans.collection_id=collection.collection_id and
				AGENT_ID=#agent_id#
			group by
				loan.transaction_id,
				TRANS_AGENT_ROLE,
				loan_number,
				guid_prefix
			order by
				guid_prefix,
				loan_number,
				TRANS_AGENT_ROLE
		</cfquery>
		<cfloop query="trans_agent_l">
			<li>#TRANS_AGENT_ROLE# for Loan <a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#guid_prefix# #loan_number#</a></li>
		</cfloop>
		<cfquery name="trans_agent_a" datasource="uam_god">
			select
				accn.transaction_id,
				TRANS_AGENT_ROLE,
				accn_number,
				guid_prefix
			from
				trans_agent,
				accn,
				trans,
				collection
			where
				trans_agent.transaction_id=accn.transaction_id and
				accn.transaction_id=trans.transaction_id and
				trans.collection_id=collection.collection_id and
				AGENT_ID=#agent_id#
			group by
				accn.transaction_id,
				TRANS_AGENT_ROLE,
				accn_number,
				guid_prefix
			order by
				guid_prefix,
				accn_number,
				TRANS_AGENT_ROLE
		</cfquery>
		<cfloop query="trans_agent_a">
			<li>#TRANS_AGENT_ROLE# for Accession <a href="/editAccn.cfm?action=edit&transaction_id=#transaction_id#">#guid_prefix# #accn_number#</a></li>
		</cfloop>
		<cfquery name="loan_item" datasource="uam_god">
			select
				trans.transaction_id,
				loan_number,
				count(*) cnt,
				guid_prefix
			from
				trans,
				loan,
				collection,
				loan_item
			where
				trans.transaction_id=loan.transaction_id and
				loan.transaction_id=loan_item.transaction_id and
				trans.collection_id=collection.collection_id and
				RECONCILED_BY_PERSON_ID =#agent_id#
			group by
				trans.transaction_id,
				loan_number,
				guid_prefix
		</cfquery>
		<cfloop query="loan_item">
			<li>Reconciled #cnt# items for Loan
				<a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#guid_prefix# #loan_number#</a>
			</li>
		</cfloop>
	</ul>
</cfoutput>
<cfinclude template = "/includes/_footer.cfm">