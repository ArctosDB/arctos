<cfinclude template = "/includes/_frameHeader.cfm">
<cfset title = "Agent Activity">
<cfoutput>
Back to <a href="/editAllAgent.cfm?agent_id=#agent_id#">Agent Details</a>
<cfquery name="agent" datasource="uam_god">
	select * FROM agent where agent_id=#agent_id#
</cfquery>
<cfquery name="person" datasource="uam_god">
	select * FROM person where person_id=#agent_id#
</cfquery>
<cfquery name="name" datasource="uam_god">
	select agent_name_id, agent_name, agent_name_type FROM agent_name where agent_id=#agent_id#
</cfquery>
Agent:
<table border>
	<tr>
		<td align="right"><strong>Agent Type:</strong></td>
		<td>#agent.agent_type#</td>
	</tr>
	<cfif #person.recordcount# gt 0>
		<tr>
			<td align="right"><strong>Prefix:</strong></td>
			<td>#person.prefix#</td>
		</tr>
		<tr>
			<td align="right"><strong>First Name:</strong></td>
			<td>#person.FIRST_NAME#</td>
		</tr>
		<tr>
			<td align="right"><strong>Middle Name:</strong></td>
			<td>#person.MIDDLE_NAME#</td>
		</tr>
		<tr>
			<td align="right"><strong>Last Name:</strong></td>
			<td>#person.LAST_NAME#</td>
		</tr>			
		<tr>
			<td align="right"><strong>Suffix:</strong></td>
			<td>#person.SUFFIX#</td>
		</tr>
		<tr>
			<td align="right"><strong>Birth Date:</strong></td>
			<td>#dateformat(person.BIRTH_DATE,"dd mmm yyyy")#</td>
		</tr>
		<tr>
			<td align="right"><strong>Death Date:</strong></td>
			<td>#dateformat(person.DEATH_DATE,"dd mmm yyyy")#</td>
		</tr>
	</cfif>
</table>
Agent Names:
	<ul>
		<cfloop query="name">
			<li>#name.agent_name# (#agent_name_type#)</li>
		</cfloop>
	</ul>
Collected or Prepared:
	<cfquery name="collector" datasource="uam_god">
		select 
			count(distinct(collector.collection_object_id)) cnt,
			collection.collection,
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
			collection.collection,
	        collection.collection_id
	</cfquery>
	<ul>
		<CFLOOP query="collector">
			<li>
				<a href="/SpecimenResults.cfm?collector_agent_id=#agent_id#&collection_id=#collector.collection_id#">#collector.cnt# #collector.collection#</a> specimens
			</li>
	  	</CFLOOP>
	</ul>
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
Electronic Address:
	<cfquery name="electronic_address" datasource="uam_god">
		select * from electronic_address where agent_id=#agent_id#
	</cfquery>
	<ul>
		<cfloop query="electronic_address">
			<li>#ADDRESS_TYPE#: #ADDRESS#</li>
		</cfloop>
	</ul>
Address:	
	<cfquery name="addr" datasource="uam_god">
		select replace(formatted_addr,chr(10),'<br>') formatted_addr from addr where agent_id=#agent_id#
	</cfquery>
	<ul>
		<cfloop query="addr">
			<li>#formatted_addr#</li>
		</cfloop>
	</ul>
Attribute Determiner:
	<cfquery name="attributes" datasource="uam_god">
		select 
			count(attributes.collection_object_id) c,
			collection.collection_id,
			collection 
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
			collection 
	</cfquery>
	<ul>
		<cfloop query="attributes">
			<li>
				#c# 
				<a href="/SpecimenResults.cfm?attributed_determiner_agent_id=#agent_id#&collection_id=#attributes.collection_id#">
					#attributes.collection#</a>
			</li>
		</cfloop>
	</ul>
	<cfquery name="binary_object" datasource="uam_god">
		select count(*) cnt,
			count(distinct(derived_from_cat_item)) specs 
			from binary_object,coll_object
			 where made_agent_id=#agent_id#
			 and binary_object.collection_object_id = coll_object.collection_object_id
	</cfquery>
	<cfquery name="media" datasource="uam_god">
		select media_id from media_relations where media_relationship like '% agent' and
		related_primary_key=#agent_id#
	</cfquery>
	<li>
		Subject of #media.recordcount# <a href="/MediaSearch.cfm?action=search&related_primary_key__1=#agent_id#"> Media entries.</a>
	</li>
	<cfquery name="media_assd_relations" datasource="uam_god">
		select media_id from media_relations where CREATED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<li>
		Assigned #media_assd_relations.recordcount# Media Relationships.
	</li>
	<cfquery name="media_labels" datasource="uam_god">
		select media_id from media_labels where ASSIGNED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<li>
		Assigned #media_labels.recordcount# Media Labels.
	</li>
	
	<cfquery name="encumbrance" datasource="uam_god">
		select count(*) cnt from encumbrance where encumbering_agent_id=#agent_id#
	</cfquery>
	<cfquery name="coll_object_encumbrance" datasource="uam_god">
		select count(*) cnt from encumbrance,coll_object_encumbrance
		 where encumbering_agent_id=#agent_id#
		 and encumbrance.encumbrance_id = coll_object_encumbrance.encumbrance_id
	</cfquery>
	<li>Created #encumbrance.cnt# encumbrances 
		covering <a href="/SpecimenResults.cfm?encumbering_agent_id=#agent_id#">#coll_object_encumbrance.cnt# specimens</a> 
	</li>
	<cfquery name="identification" datasource="uam_god">
		select count(*) cnt, count(distinct(collection_object_id)) specs from 
        identification,
        identification_agent
        where 
        identification.identification_id=identification_agent.identification_id and
        agent_id=#agent_id#
	</cfquery>
	<li>Made #identification.cnt# identifications for <a href="/SpecimenResults.cfm?identified_agent_id=#agent_id#">
		#identification.specs# specimens</a>
	</li>	
	<cfquery name="lat_long" datasource="uam_god">
		select count(*) cnt from lat_long where determined_by_agent_id=#agent_id#
	</cfquery>
	<li>Determined #lat_long.cnt# coordinates</li>
	<cfquery name="permit_to" datasource="uam_god">
		select count(*) cnt from permit where ISSUED_TO_AGENT_ID=#agent_id#
	</cfquery>
	<li>Has been issued #permit_to.cnt# permits</li>
	<cfquery name="permit_by" datasource="uam_god">
		select count(*) cnt from permit where ISSUED_by_AGENT_ID=#agent_id#
	</cfquery>
	<li>Issued #permit_by.cnt# permits</li>
	<cfquery name="project_agent" datasource="uam_god">
		select count(*) cnt from project_agent where agent_name_id IN (#names#)
	</cfquery>
	<li>
		Involved in <a href="/ProjectList.cfm?project_agent_name_id=#names#&src=proj">#project_agent.cnt# projects</a>
	</li>
	<cfquery name="shipment" datasource="uam_god">
		select count(*) cnt from shipment where PACKED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<li>Packed #shipment.cnt# shipments</li>
	<cfquery name="publication_author_name" datasource="uam_god">
		select count(*) cnt from publication_author_name where agent_name_id IN (#names#)
	</cfquery>
	<li>Authored <a href="/PublicationResults.cfm?publication_author_id=#names#&src=proj">#publication_author_name.cnt# publications</a> </li>
	<cfquery name="trans_agent" datasource="uam_god">
		select TRANS_AGENT_ROLE, count(*) cnt from trans_agent where AGENT_ID=#agent_id#
		group by TRANS_AGENT_ROLE
	</cfquery>
	<li>
		Transactions:
		<ul>
			<cfloop query="trans_agent">
				#TRANS_AGENT_ROLE#: #cnt#
			</cfloop>
		</ul>
	</li>
	<cfquery name="entered" datasource="uam_god">
		select count(*) cnt from coll_object,cataloged_item where ENTERED_PERSON_ID =#agent_id#
		and coll_object.collection_object_id = cataloged_item.collection_object_id
	</cfquery>
	<li>Entered <a href="/SpecimenResults.cfm?entered_by_id=#agent_id#">#entered.cnt# specimens</a></li>
	<cfquery name="last_edit" datasource="uam_god">
		select count(coll_object.collection_object_id) cnt from coll_object,cataloged_item
		 where LAST_EDITED_PERSON_ID =#agent_id#
		 and coll_object.collection_object_id = cataloged_item.collection_object_id
	</cfquery>
	<li>Edited <a href="/SpecimenResults.cfm?edited_by_id=#agent_id#">#last_edit.cnt# specimens</a></li>
	<cfquery name="loan_item" datasource="uam_god">
		select count(*) cnt from loan_item where RECONCILED_BY_PERSON_ID =#agent_id#
	</cfquery>
	<li>Reconciled #loan_item.cnt# loan items</li>
</ul>	
</cfoutput>
<cfinclude template = "/includes/_footer.cfm">