<cfinclude template = "/includes/_frameHeader.cfm">
<cfset title = "Agent Activity">
<cfoutput>
Back to <a href="/editAllAgent.cfm?agent_id=#agent_id#">Agent Details</a>

<div class="red">Please note: your login may prevent you from seeing some data</div>
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
Entered:
	<cfquery name="entered" datasource="uam_god">
		select 
			count(*) cnt,
			collection,
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
			collection,
			collection.collection_id
	</cfquery>
	<ul>
		<cfloop query="entered">
			<li>
				<a href="/SpecimenResults.cfm?entered_by_id=#agent_id#&collection_id=#collection_id#">#cnt# #collection#</a> specimens
			</li>
		</cfloop>
	</ul>
Edited:	
	<cfquery name="last_edit" datasource="uam_god">
		select 
			count(*) cnt,
			collection,
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
			collection,
			collection.collection_id
	</cfquery>
	<ul>
		<cfloop query="last_edit">
			<li>
				<a href="/SpecimenResults.cfm?edited_by_id=#agent_id#&collection_id=#collection_id#">#cnt# #collection#</a> specimens
			</li>
		</cfloop>
	</ul>
Attribute Determiner:
	<cfquery name="attributes" datasource="uam_god">
		select 
			count(attributes.collection_object_id) c,
			count(distinct(cataloged_item.collection_object_id)) s,
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
				#c# attributes for #s#
				<a href="/SpecimenResults.cfm?attributed_determiner_agent_id=#agent_id#&collection_id=#attributes.collection_id#">
					#attributes.collection#</a> specimens
			</li>
		</cfloop>
	</ul>
Media:
	<cfquery name="media" datasource="uam_god">
		select media_id from media_relations where media_relationship like '% agent' and
		related_primary_key=#agent_id#
	</cfquery>
	<cfquery name="media_assd_relations" datasource="uam_god">
		select media_id from media_relations where CREATED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<cfquery name="media_labels" datasource="uam_god">
		select media_id from media_labels where ASSIGNED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<ul>
		<li>
			Subject of #media.recordcount# <a href="/MediaSearch.cfm?action=search&related_primary_key__1=#agent_id#"> Media entries.</a>
		</li>
		<li>
			Assigned #media_assd_relations.recordcount# Media Relationships.
		</li>
		<li>
			Assigned #media_labels.recordcount# Media Labels.
		</li>
	</ul>
Encumbrances:
	<ul>
		<cfquery name="encumbrance" datasource="uam_god">
			select count(*) cnt from encumbrance where encumbering_agent_id=#agent_id#
		</cfquery>
		<cfquery name="coll_object_encumbrance" datasource="uam_god">
			select 
				count(distinct(coll_object_encumbrance.collection_object_id)) specs,
				collection,
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
			 	collection,
				collection.collection_id
		</cfquery>
		<li>Owns #encumbrance.cnt# encumbrances</li>
		<cfloop query="coll_object_encumbrance">
			<li>Encumbered <a href="/SpecimenResults.cfm?encumbering_agent_id=#agent_id#&collection_id=#collection_id#">
				#specs# #collection#</a> records</li>
		</cfloop>
	</ul>
Identification:
	<cfquery name="identification" datasource="uam_god">
		select 
			count(*) cnt, 
			count(distinct(identification.collection_object_id)) specs,
			collection.collection_id,
			collection.collection
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
			collection.collection
	</cfquery>
	<ul>
		<cfloop query="identification">
			<li>
				#cnt# identifications for <a href="/SpecimenResults.cfm?identified_agent_id=#agent_id#&collection_id=#collection_id#">
					#specs# #collection#</a> specimens
			</li>
		</cfloop>
	</ul>
Coordinates:
	<cfquery name="lat_long" datasource="uam_god">
		select 
			count(*) cnt,
			count(distinct(locality_id)) locs from lat_long where determined_by_agent_id=#agent_id#
	</cfquery>
	<ul>
		<li>Determined #lat_long.cnt# coordinates for #lat_long.locs# localities</li>
	</ul>
Permits:	
	<cfquery name="permit_to" datasource="uam_god">
		select count(*) cnt from permit where ISSUED_TO_AGENT_ID=#agent_id#
	</cfquery>
	<cfquery name="permit_by" datasource="uam_god">
		select count(*) cnt from permit where ISSUED_by_AGENT_ID=#agent_id#
	</cfquery>
	<ul>
		<li>#permit_to.cnt# permits issued to</li>
		<li>#permit_by.cnt# permits issued by</li>
	</ul>
Projects:	
	<cfquery name="project_agent" datasource="uam_god">
		select 
			project_name,
			project.project_id
		from 
			project_agent,
			project,
			agent_name
		where
			 project.project_id=project_agent.project_id and
			 project_agent.agent_name_id=agent_name.agent_name_id and
			 agent_name.agent_id=#agent_id#
		group by
			project_name,
			project.project_id
	</cfquery>
	<ul>
		<cfloop query="project_agent">
			<li>
				<a href="/ProjectDetail.cfm?project_id=#project_id#">#project_name#</a>
			</li>
		</cfloop>
	</ul>
Transactions
	<ul>
		<cfquery name="shipment" datasource="uam_god">
			select 
				LOAN_NUMBER,
				loan.transaction_id,
				collection
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
			<li>Packed Shipment for <a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#collection# #loan_number#</a></li>
		</cfloop>
		<cfquery name="trans_agent_l" datasource="uam_god">
			select 
				loan.transaction_id,
				TRANS_AGENT_ROLE,
				loan_number,
				collection
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
				collection
			order by
				collection,
				loan_number,
				TRANS_AGENT_ROLE
		</cfquery>
		<cfloop query="trans_agent_l">
			<li>#TRANS_AGENT_ROLE# for Loan <a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#collection# #loan_number#</a></li>
		</cfloop>
		<cfquery name="trans_agent_a" datasource="uam_god">
			select 
				accn.transaction_id,
				TRANS_AGENT_ROLE,
				accn_number,
				collection
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
				collection
			order by
				collection,
				accn_number,
				TRANS_AGENT_ROLE
		</cfquery>
		<cfloop query="trans_agent_a">
			<li>#TRANS_AGENT_ROLE# for Accession <a href="/editAccn.cfm?action=edit&transaction_id=#transaction_id#">#collection# #accn_number#</a></li>
		</cfloop>
		<cfquery name="loan_item" datasource="uam_god">
			select 
				trans.transaction_id,
				loan_number,
				count(*) cnt,
				collection
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
				collection				
		</cfquery>
		<cfloop query="trans_agent_a">
			<li>Reconciled #cnt# items for Loan 
				<a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#collection# #loan_number#</a>
			</li>		
		</cfloop>
Publications
	<cfquery name="publication_author_name" datasource="uam_god">
		select 
			publication.PUBLICATION_ID,
			PUBLICATION_TITLE
		from
			publication,
			publication_author_name,
			agent_name
		where
			publication.publication_id=publication_author_name.publication_id and
			publication_author_name.agent_name_id=agent_name.agent_name_id and
			agent_name.agent_id=#agent_id#
		group by
			publication.PUBLICATION_ID,
			PUBLICATION_TITLE
	</cfquery>
	<ul>
		<cfloop query="publication_author_name">
			<li>
				<a href="/PublicationResults.cfm?PUBLICATION_ID=#PUBLICATION_ID#">#PUBLICATION_TITLE#</a>
			</li>
		</cfloop>
	</ul>
</cfoutput>
<cfinclude template = "/includes/_footer.cfm">