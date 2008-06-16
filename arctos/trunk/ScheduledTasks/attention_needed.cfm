<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<!--- pending relationships that have been in the table for >30d ---->
		<cfquery name="contacts" datasource="#Application.web_user#">
			select 
				distinct(ADDRESS)
			from
				cf_temp_relations,
				cataloged_item,
				collection,
				collection_contacts,
				electronic_address
			where
				cf_temp_relations.COLLECTION_OBJECT_ID = cataloged_item.COLLECTION_OBJECT_ID and
				cataloged_item.collection_id = collection.collection_id and
				collection.collection_id=collection_contacts.collection_id and
				collection_contacts.CONTACT_AGENT_ID=electronic_address.AGENT_ID and
				CONTACT_ROLE='data quality' and
				related_collection_object_id is null and
				ADDRESS_TYPE='e-mail'
		</cfquery>
		<cfdump var="#contacts#">
		
	</cfoutput>
	
	
<cfinclude template="/includes/_footer.cfm">