<!----

Builds DiGIR tables
	Needs replaced with links to FILTERED_FLAT
	
 /* Views used by this 
 
 create view collectornumber as 
 	select collection_object_id, 
 	other_id_num from coll_obj_other_id_num 
 	where other_id_type='original field number';
create public synonym collectornumber for collectornumber;
grant select on collectornumber to uam_query,uam_update;

*/
---->

<cfoutput>
<!---- First, create a new table to minimize down-time ---->
<cfquery name="killOld" datasource="uam_god">
	drop table mdc2_temp
</cfquery>
<!---- make a temp table ---->
<cfquery name="makeNew" datasource="uam_god">
 create table mdc2_temp as
 select 
 	cataloged_item.collection_object_id PKEYID,
 	to_char(last_edit_date,'dd Mon yyyy') DATELASTMODIFIED,
 	'voucher' BASISOFRECORD,
 	institution_acronym INSTITUTIONCODE,
 	collection.collection_cde COLLECTIONCODE,
 	'<a href="#Application.ServerRootUrl#/SpecimenDetail.cfm?collection_object_id=' || cataloged_item.collection_object_id || '">' || cat_num || '</a>' CATALOGNUMBERTEXT,
 	cat_num CATALOGNUMBERNUMERIC,
 	concatColls('collection_object_id', cataloged_item.collection_object_id, 'agent_name','coll_names') COLLECTOR,
 	other_id_num COLLECTORNUMBER,
 	' ' FIELDNUM,
 	to_number(to_char(began_date,'yyyy')) YEARCOLLECTED,
 	to_number(to_char(began_date,'mm')) MONTHCOLLECTED,
 	to_number(to_char(began_date,'dd')) DAYCOLLECTED,
 	verbatim_date VERBATIMCOLLECTINGDATE,
 	' ' FIELDNOTES,
 	higher_geog HIGHERGEOGRAPHY,
 	continent_ocean CONTINENTOCEAN,
 	country COUNTRY,
 	state_prov STATE,
 	county COUNTY,
 	feature FEATURE,
 	island ISLAND,
 	island_group ISLANDGROUP,
 	spec_locality LOCALITY,
 	dec_lat DECIMALLATITUDE,
 	dec_long  DECIMALLONGITUDE,
 	datum HORIZONTALDATUM,
 	orig_lat_long_units ORIGINALCOORDINATESYSTEM,
 	decode(orig_lat_long_units,
				'decimal degrees',to_char(dec_lat) || 'd',
				'deg. min. sec.', to_char(lat_deg) || 'd ' || to_char(lat_min) || 'm ' || to_char(lat_sec) || 's ' || lat_dir,
				'degrees dec. minutes', to_char(lat_deg) || 'd ' || to_char(dec_lat_min) || 'm ' || lat_dir
			)  VERBATIMLATITUDE,
			decode(orig_lat_long_units,
				'decimal degrees',to_char(dec_long) || 'd',
				'deg. min. sec.', to_char(long_deg) || 'd ' || to_char(long_min) || 'm ' || to_char(long_sec) || 's ' || long_dir,
				'degrees dec. minutes', to_char(long_deg) || 'd ' || to_char(dec_long_min) || 'm ' || long_dir
			)  VERBATIMLONGITUDE,
	lat_long_ref_source GEOREFMETHOD,
	decode(max_error_units,
		'm',max_error_distance,
		'ft',max_error_distance * 3.28,
		'km',max_error_distance * 1000,
		'mi',max_error_distance * 1609.3,
		'yd',max_error_distance * .9144) COORDINATEUNCERTAINTYINMETERS,
 		lat_long_remarks LATLONGCOMMENTS,
		decode(orig_elev_units,
		'm',minimum_elevation,
		'ft',minimum_elevation * 3.28) MINIMUMELEVATIONINMETERS,
		decode(orig_elev_units,
		'm',maximum_elevation,
		'ft',maximum_elevation * 3.28) MAXIMUMELEVATIONINMETERS,
		identification.scientific_name SCIENTIFICNAME,
		' ' KINGDOM,
		' ' PHYLUM,
		phylclass CLASS,
		phylorder PHYLORDER,
		family FAMILY,
		genus GENUS,
		species SPECIES,
		subspecies SUBSPECIES,
		' ' IDENTIFICATIONMODIFIER,
		idby.agent_name IDENTIFIEDBY,
 		to_number(to_char(identification.made_date,'yyyy')) YEARIDENTIFIED,
 		to_number(to_char(identification.made_date,'mm')) MONTHIDENTIFIED,
 		to_number(to_char(identification.made_date,'dd')) DAYIDENTIFIED,
 		concattypestatus(cataloged_item.collection_object_id) TYPESTATUS,
 		ConcatAttributeValue(cataloged_item.collection_object_id,'sex') SEXINTERPRETED,
 		concatparts(cataloged_item.collection_object_id) PREPARATIONS,
 		' ' TISSUES,
 		concatotherid(cataloged_item.collection_object_id) OTHERCATALOGNUMBERS,
 		concatrelations(cataloged_item.collection_object_id) RELATEDCATALOGEDITEMS,
 		lot_count INDIVIDUALCOUNT,
 		coll_object_remarks REMARKS,
 		full_taxon_name HIGHERTAXON,
 		concatgenbank(cataloged_item.collection_object_id) GENBANKNUM
 	from 
 		cataloged_item, 
 		coll_object,
 		collection,
 		collectornumber,
 		collecting_event,
 		locality,
 		geog_auth_rec,
 		accepted_lat_long,
 		identification,
 		taxonomy,
 		identification_taxonomy,
 		preferred_agent_name idby,
 		coll_object_remark
 	where 
 		cataloged_item.collection_object_id = coll_object.collection_object_id and
 		cataloged_item.collection_id = collection.collection_id and
 		cataloged_item.collection_object_id = collectornumber.collection_object_id (+) and
 		cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
 		collecting_event.locality_id = locality.locality_id and
 		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
 		locality.locality_id = accepted_lat_long.locality_id (+) and
 		cataloged_item.collection_object_id = identification.collection_object_id and
 		identification.identification_id = identification_taxonomy.identification_id and
 		identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id and
 		identification.id_made_by_agent_id = idby.agent_id (+) and
 		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+)
	</cfquery>=
	
 <!---- OK, we have everything in the new table - now kill encumbered things ---->
 <cfquery name="hideColls" datasource="uam_god">
 	 UPDATE mdc2_temp SET COLLECTOR = 'Anonymous' WHERE
 	pkeyid IN (
 		select 
 			coll_object_encumbrance.collection_object_id 
 		FROM 
 			coll_object_encumbrance,
 			encumbrance
 		WHERE
 			coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id AND
 			encumbrance_action='mask collector'
 			)
 </cfquery>
 <cfquery name="hideCollNums" datasource="uam_god">
 	UPDATE mdc2_temp SET COLLECTORNUMBER = 'Anonymous' WHERE
 	COLLECTORNUMBER is not null AND
 	pkeyid IN (
 		select 
 			coll_object_encumbrance.collection_object_id 
 		FROM 
 			coll_object_encumbrance,
 			encumbrance
 		WHERE
 			coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id AND
 			encumbrance_action='mask original field number'
 			)
 </cfquery>
 <cfquery name="hideCoordinates" datasource="uam_god">
  UPDATE mdc2_temp SET VERBATIMLATITUDE = 'Anonymous',
 					  VERBATIMLongitude = 'Anonymous',
 					  decimallatitude = NULL,
 					  decimallongitude = NULL
 		WHERE
 	pkeyid IN (
 		select 
 			coll_object_encumbrance.collection_object_id 
 		FROM 
 			coll_object_encumbrance,
 			encumbrance
 		WHERE
 			coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id AND
 			encumbrance_action='mask coordinates'
 			)
 </cfquery>
 <cfquery name="hideHidden" datasource="uam_god">
 DELETE FROM mdc2_temp WHERE 
 	pkeyid IN (
 		select 
 			coll_object_encumbrance.collection_object_id 
 		FROM 
 			coll_object_encumbrance,
 			encumbrance
 		WHERE
 			coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id AND
 			encumbrance_action='mask record'
 			) 
 </cfquery>
 <!---- Remove UAM Birds at the request of Kevin Winker ---->
  <cfquery name="hideBirds" datasource="uam_god">
  DELETE FROM mdc2_temp WHERE pkeyid IN (
 	SELECT 
 		cataloged_item.collection_object_id 
 	FROM
 		cataloged_item,collection
 	WHERE 
 		cataloged_item.collection_id = collection.collection_id AND
 		institution_acronym='UAM' AND 
 		cataloged_item.collection_cde='Bird'
 	)
  </cfquery>
<!----
	We're left with clean public data - now remove the old table
 	and re-build it. DELETE FROM is too slow, so just drop. Synonyms 
 	sometimes get corrupted when the table drops, so just drop and rebuild the synonym
 	as well.
 ---->		
   <cfquery name="killOldMain" datasource="uam_god">
   		drop table mdc2
   </cfquery>
   <cfquery name="makeNewMain" datasource="uam_god">
   		rename mdc2_temp to mdc2
   </cfquery>
   <cfquery name="killSynonym" datasource="uam_god">
   		drop public synonym mdc2
   </cfquery>
    <cfquery name="makeSynonym" datasource="uam_god">
   		create public synonym mdc2 for mdc2
   </cfquery>
   <cfquery name="giveRights" datasource="uam_god">
   		grant select on mdc2 to uam_query
   </cfquery>
 </cfoutput>