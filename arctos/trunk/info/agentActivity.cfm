<cfinclude template = "/includes/_frameHeader.cfm">
<cfif #client.target# is "_self">
	<cfset thisTarget = "_top">
<cfelse>
	<cfset thisTarget = #client.target#>
</cfif>
<cfset title = "Agent Activity">
<cfoutput>
Back to <a href="/agents.cfm?agent_id=#agent_id#&action=editAgent">Agent Details</a><table border>
	<cfquery name="agent" datasource="#Application.web_user#">
		select * FROM agent where agent_id=#agent_id#
	</cfquery>
		<tr>
			<td align="right"><strong>Agent Type:</strong></td>
			<td>#agent.agent_type#</td>
		</tr>
	<cfquery name="person" datasource="#Application.web_user#">
		select * FROM person where person_id=#agent_id#
	</cfquery>
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
	<cfquery name="name" datasource="#Application.web_user#">
		select agent_name_id, agent_name, agent_name_type FROM agent_name where agent_id=#agent_id#
	</cfquery>
	<cfset names="">
	<cfloop query="name">
		<cfif len(#names#) is 0>
			<cfset names=#agent_name_id#>
		<cfelse>
			<cfset names="#names#,#agent_name_id#">
		</cfif>
	</cfloop>
			<ul>
			<li>Is known as:</li>
				<ul>
					<cfloop query="name">
						<li>#name.agent_name# (#agent_name_type#)</li>
					</cfloop>
				</ul>
			
			
	<cfquery name="collector" datasource="#Application.web_user#">
		select 
			count(distinct(collector.collection_object_id)) cnt,
			collection.collection_cde ,
			institution_acronym
		from 
			collector,
			cataloged_item,
			collection
		where 
			collector.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = collection.collection_id AND
			agent_id=#agent_id#
		group by
			collection.collection_cde,
			institution_acronym
	</cfquery>
	
			<li>
				Collected or Prepared:
			</li>
			<ul>
				<CFLOOP query="collector">
					<li>
						<a href="/SpecimenResults.cfm?collector_agent_id=#agent_id#&collection_cde=#collector.collection_cde#" target="#thisTarget#">#collector.cnt# #collector.institution_acronym# #collector.collection_cde#</a> specimens
					</li>
			  </CFLOOP>
			</ul>
					
		
	<cfquery name="agent_relations" datasource="#Application.web_user#">
		select count(*) cnt from agent_relations where 
			(agent_id=#agent_id# OR related_agent_id = #agent_id#)
	</cfquery>
			<li>Involved in #agent_relations.cnt# agent relationships</li>
	<cfquery name="addr" datasource="#Application.web_user#">
		select count(*) cnt from addr where agent_id=#agent_id#
	</cfquery>
			<li>Has #addr.cnt# address(es)</li>
	<cfquery name="attributes" datasource="#Application.web_user#">
		select 
			count(distinct(collection_object_id)) specs 
			,count(attribute_id) cnt 
			from attributes where determined_by_agent_id=#agent_id#
	</cfquery>
				<li>
					Determined #attributes.cnt# attributes for <a href="/SpecimenResults.cfm?attributed_determiner_agent_id=#agent_id#" 
						target="#thisTarget#">#attributes.specs# specimens</a> 
			  </li>
			
	
	<cfquery name="binary_object" datasource="#Application.web_user#">
		select count(*) cnt,
			count(distinct(derived_from_cat_item)) specs 
			from binary_object,coll_object
			 where made_agent_id=#agent_id#
			 and binary_object.collection_object_id = coll_object.collection_object_id
	</cfquery>
			<li>
				Made #binary_object.cnt# binary objects for <a href="/SpecimenResults.cfm?binary_object_made_by_id=#agent_id#" 
						target="#thisTarget#">#binary_object.specs# specimens</a> 
			</li>
	
	<cfquery name="electronic_address" datasource="#Application.web_user#">
		select count(*) cnt from electronic_address where agent_id=#agent_id#
	</cfquery>
			<li>Has #electronic_address.cnt# electronic address(es)</li>
	<cfquery name="encumbrance" datasource="#Application.web_user#">
		select count(*) cnt from encumbrance where encumbering_agent_id=#agent_id#
	</cfquery>
	<cfquery name="coll_object_encumbrance" datasource="#Application.web_user#">
		select count(*) cnt from encumbrance,coll_object_encumbrance
		 where encumbering_agent_id=#agent_id#
		 and encumbrance.encumbrance_id = coll_object_encumbrance.encumbrance_id
	</cfquery>
		<li>Created #encumbrance.cnt# encumbrances 
				covering <a href="/SpecimenResults.cfm?encumbering_agent_id=#agent_id#" 
						target="#thisTarget#">#coll_object_encumbrance.cnt# specimens</a> 
			  </li>
	
	<cfquery name="identification" datasource="#Application.web_user#">
		select count(*) cnt, count(distinct(collection_object_id)) specs from identification where id_made_by_agent_id=#agent_id#
	</cfquery>
	 
						</li>
						
		<li>Made #identification.cnt# identifications for <a href="/SpecimenResults.cfm?identified_agent_id=#agent_id#" 
						target="#thisTarget#">#identification.specs# specimens</a></li>
		
	<cfquery name="lat_long" datasource="#Application.web_user#">
		select count(*) cnt from lat_long where determined_by_agent_id=#agent_id#
	</cfquery>
		<li>Determined #lat_long.cnt# coordinates</li>
	<cfquery name="permit_to" datasource="#Application.web_user#">
		select count(*) cnt from permit where ISSUED_TO_AGENT_ID=#agent_id#
	</cfquery>
		<li>Has been issued #permit_to.cnt# permits</li>
	
	<cfquery name="permit_by" datasource="#Application.web_user#">
		select count(*) cnt from permit where ISSUED_by_AGENT_ID=#agent_id#
	</cfquery>
		<li>Issued #permit_by.cnt# permits</li>
	
	<cfquery name="project_agent" datasource="#Application.web_user#">
		select count(*) cnt from project_agent where agent_name_id IN (#names#)
	</cfquery>
		
		<li>Involved in 
	<a href="/ProjectList.cfm?project_agent_name_id=#names#&src=proj" 
						target="#thisTarget#">#project_agent.cnt# projects</a>
			  </li>
	<cfquery name="shipment" datasource="#Application.web_user#">
		select count(*) cnt from shipment where PACKED_BY_AGENT_ID=#agent_id#
	</cfquery>
		<li>Packed #shipment.cnt# shipments</li>
	
	<cfquery name="publication_author_name" datasource="#Application.web_user#">
		select count(*) cnt from publication_author_name where agent_name_id IN (#names#)
	</cfquery>
		
		
		<li>Authored <a href="/PublicationResults.cfm?publication_author_id=#names#&src=proj" 
						target="#thisTarget#">#publication_author_name.cnt# publications</a> </li>
						
	<cfquery name="trans_auth" datasource="#Application.web_user#">
		select count(*) cnt from trans where AUTH_AGENT_ID =#agent_id#
	</cfquery>
		<li>Authorized #trans_auth.cnt# transactions</li>
	<cfquery name="trans_ent" datasource="#Application.web_user#">
		select count(*) cnt from trans where TRANS_ENTERED_AGENT_ID =#agent_id#
	</cfquery>
		<li>Entered #trans_ent.cnt# transactions</li>
	<cfquery name="trans_rec" datasource="#Application.web_user#">
		select count(*) cnt from trans where RECEIVED_AGENT_ID =#agent_id#
	</cfquery>
		<li>Received #trans_rec.cnt# transactions</li>
	<cfquery name="entered" datasource="#Application.web_user#">
		select count(*) cnt from coll_object,cataloged_item where ENTERED_PERSON_ID =#agent_id#
		and coll_object.collection_object_id = cataloged_item.collection_object_id
	</cfquery>
		<li>Entered <a href="/SpecimenResults.cfm?entered_by_id=#agent_id#" 
						target="#thisTarget#">#entered.cnt# specimens</a></li>
	<cfquery name="last_edit" datasource="#Application.web_user#">
		select count(coll_object.collection_object_id) cnt from coll_object,cataloged_item
		 where LAST_EDITED_PERSON_ID =#agent_id#
		 and coll_object.collection_object_id = cataloged_item.collection_object_id
	</cfquery>
		<li>Edited <a href="/SpecimenResults.cfm?edited_by_id=#agent_id#" 
						target="#thisTarget#">#last_edit.cnt# specimens</a></li>
	<cfquery name="loan_item" datasource="#Application.web_user#">
		select count(*) cnt from loan_item where RECONCILED_BY_PERSON_ID =#agent_id#
	</cfquery>
		<li>Reconciled #loan_item.cnt# loan items</li>
	
	</ul>
	
</cfoutput>
<cfinclude template = "/includes/_footer.cfm">