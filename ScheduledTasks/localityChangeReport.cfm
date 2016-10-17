<cfquery name="d" datasource="uam_god">
	select
		distinct 
		locality_archive.locality_id,
		collection.guid_prefix,
		collection.collection_id		
		-- media something
	from
		locality_archive,
		collecting_event,
		specimen_event,
		cataloged_item,
		collection
	where
		locality_archive.locality_id=collecting_event.locality_id and
		collecting_event.collecting_event_id=specimen_event.collecting_event_id and
		specimen_event.collection_object_id=cataloged_item.collection_object_id and
		cataloged_item.collection_id=collection.collection_id and
		-- this runs daily, so just grab the last 24h
		sysdate-changedate<1
</cfquery>

 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 COLLECTION_CONTACT_ID						   NOT NULL NUMBER
 COLLECTION_ID							   NOT NULL NUMBER
 CONTACT_ROLE							   NOT NULL VARCHAR2(60)
 CONTACT_AGENT_ID						   NOT NULL NUMBER

 data quality 

<br />get_address(collection_contacts.contact_agent_id,'email')


		;
		
		
		
		 and
		-
		