<cfinclude template="/includes/_header.cfm">
	<cfquery name="d" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			count(cataloged_item.collection_object_id) c,
			catcollobj.condition,
			catcollobj.coll_object_disposition
		from
			cataloged_item,
			coll_object catcollobj
		where
			cataloged_item.collection_object_id=catcollobj.collection_object_id and
			(
				catcollobj.condition like '%loan%' or
				catcollobj.coll_object_disposition like '%loan%'
			)
		group by
			catcollobj.condition,
			catcollobj.coll_object_disposition
	</cfquery>
	<cfdump var=#d#>

<cfinclude template="/includes/_footer.cfm">