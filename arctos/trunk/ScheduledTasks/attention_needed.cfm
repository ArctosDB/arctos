<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<!--- pending relationships that have been in the table for >30d ---->
		<cfquery name="contacts" datasource="#Application.web_user#">
			select 
				count(*) c,
				collection,
				insert_date,
				LASTTRYDATE,
				(sysdate - insert_date) gap,
				ADDRESS
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
				sysdate - insert_date  >30 and
				related_collection_object_id is null and
				ADDRESS_TYPE='e-mail'
			group by insert_date,
				collection,
				insert_date,
				LASTTRYDATE,
				(sysdate - insert_date),
				ADDRESS
		</cfquery>
		<cfloop query="contacts">
			#ADDRESS#: You are receiving this message because you are listed as a contact for Arctos collection #collection#.
			<br>
			There are #c# #collection# items in the Pending Relationships table that have been processing for more than
			30 days. These probably require your attention.
			<br>
			See http://arctos-test.arctos.database.museum/tools/pendingRelations.cfm?action=showStatus for more detail.
		</cfloop>
		
	</cfoutput>
	
	
<cfinclude template="/includes/_footer.cfm">