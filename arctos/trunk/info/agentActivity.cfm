<cfinclude template = "/includes/_frameHeader.cfm">
<cfset title = "Agent Activity">
<cfoutput>
<cfquery name="agent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * FROM agent where agent_id=#agent_id#
</cfquery>
<cfquery name="person" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * FROM person where person_id=#agent_id#
</cfquery>
<cfquery name="name" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select agent_name_id, agent_name, agent_name_type FROM agent_name where agent_id=#agent_id#
</cfquery>
<cfquery name="collector" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
Back to <a href="/editAllAgent.cfm?agent_id=#agent_id#">Agent Details</a>
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
	<li>
		Collected or Prepared:
	</li>
	<ul>
		<CFLOOP query="collector">
			<li>
				<a href="/SpecimenResults.cfm?collector_agent_id=#agent_id#&collection_id=#collector.collection_id#">#collector.cnt# #collector.collection#</a> specimens
			</li>
	  </CFLOOP>
	</ul>
	<cfquery name="agent_relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from agent_relations where 	(agent_id=#agent_id# OR related_agent_id = #agent_id#)
	</cfquery>
	<li>Involved in #agent_relations.cnt# agent relationships</li>
	<cfquery name="addr" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from addr where agent_id=#agent_id#
	</cfquery>
		<li>Has #addr.cnt# address(es)</li>
	<cfquery name="attributes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			count(distinct(collection_object_id)) specs 
			,count(attribute_id) cnt 
			from attributes where determined_by_agent_id=#agent_id#
	</cfquery>
	<li>
		Determined #attributes.cnt# attributes for <a href="/SpecimenResults.cfm?attributed_determiner_agent_id=#agent_id#">#attributes.specs# specimens</a> 
	</li>
	<cfquery name="binary_object" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt,
			count(distinct(derived_from_cat_item)) specs 
			from binary_object,coll_object
			 where made_agent_id=#agent_id#
			 and binary_object.collection_object_id = coll_object.collection_object_id
	</cfquery>
	<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select media_id from media_relations where media_relationship like '% agent' and
		related_primary_key=#agent_id#
	</cfquery>
	<li>
		Subject of #media.recordcount# <a href="/MediaSearch.cfm?action=search&related_primary_key__1=#agent_id#"> Media entries.</a>
	</li>
	<cfquery name="media_assd_relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select media_id from media_relations where CREATED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<li>
		Assigned of #media_assd_relations.recordcount# Media Relationships.
	</li>
	<cfquery name="media_labels" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select media_id from media_labels where ASSIGNED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<li>
		Assigned of #media_labels.recordcount# Media Labels.
	</li>
	<cfquery name="electronic_address" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from electronic_address where agent_id=#agent_id#
	</cfquery>
	<li>Has #electronic_address.cnt# electronic address(es)</li>
	<cfquery name="encumbrance" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from encumbrance where encumbering_agent_id=#agent_id#
	</cfquery>
	<cfquery name="coll_object_encumbrance" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from encumbrance,coll_object_encumbrance
		 where encumbering_agent_id=#agent_id#
		 and encumbrance.encumbrance_id = coll_object_encumbrance.encumbrance_id
	</cfquery>
	<li>Created #encumbrance.cnt# encumbrances 
		covering <a href="/SpecimenResults.cfm?encumbering_agent_id=#agent_id#">#coll_object_encumbrance.cnt# specimens</a> 
	</li>
	<cfquery name="identification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
	<cfquery name="lat_long" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from lat_long where determined_by_agent_id=#agent_id#
	</cfquery>
	<li>Determined #lat_long.cnt# coordinates</li>
	<cfquery name="permit_to" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from permit where ISSUED_TO_AGENT_ID=#agent_id#
	</cfquery>
	<li>Has been issued #permit_to.cnt# permits</li>
	<cfquery name="permit_by" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from permit where ISSUED_by_AGENT_ID=#agent_id#
	</cfquery>
	<li>Issued #permit_by.cnt# permits</li>
	<cfquery name="project_agent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from project_agent where agent_name_id IN (#names#)
	</cfquery>
	<li>
		Involved in <a href="/ProjectList.cfm?project_agent_name_id=#names#&src=proj">#project_agent.cnt# projects</a>
	</li>
	<cfquery name="shipment" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from shipment where PACKED_BY_AGENT_ID=#agent_id#
	</cfquery>
	<li>Packed #shipment.cnt# shipments</li>
	<cfquery name="publication_author_name" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from publication_author_name where agent_name_id IN (#names#)
	</cfquery>
	<li>Authored <a href="/PublicationResults.cfm?publication_author_id=#names#&src=proj">#publication_author_name.cnt# publications</a> </li>
	<cfquery name="trans_agent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select TRANS_AGENT_ROLE, count(*) cnt from trans_agent where TRANS_AGENT_ID=#agent_id#
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
	<cfquery name="entered" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from coll_object,cataloged_item where ENTERED_PERSON_ID =#agent_id#
		and coll_object.collection_object_id = cataloged_item.collection_object_id
	</cfquery>
	<li>Entered <a href="/SpecimenResults.cfm?entered_by_id=#agent_id#">#entered.cnt# specimens</a></li>
	<cfquery name="last_edit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(coll_object.collection_object_id) cnt from coll_object,cataloged_item
		 where LAST_EDITED_PERSON_ID =#agent_id#
		 and coll_object.collection_object_id = cataloged_item.collection_object_id
	</cfquery>
	<li>Edited <a href="/SpecimenResults.cfm?edited_by_id=#agent_id#">#last_edit.cnt# specimens</a></li>
	<cfquery name="loan_item" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select count(*) cnt from loan_item where RECONCILED_BY_PERSON_ID =#agent_id#
	</cfquery>
	<li>Reconciled #loan_item.cnt# loan items</li>
</ul>	
</cfoutput>
<cfinclude template = "/includes/_footer.cfm">