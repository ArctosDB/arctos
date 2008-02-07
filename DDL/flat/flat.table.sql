create table wtf as
 select 
 	-- cataloged item
 	cataloged_item.collection_object_id 		collection_object_id,
 	cat_num as 									cat_num,
 	accn_id,
 	identification.identification_id,
 	collection.institution_acronym as 						institution_acronym,
 	collection.collection_cde as				collection_cde,
 	collection.collection_id,
 	 collecting_event.collecting_event_id,
 	geog_auth_rec.geog_auth_rec_id,
 	last_edit_date,
 	lot_count INDIVIDUALCOUNT,
 	COLL_OBJ_DISPOSITION,
 	concatColls('collection_object_id', cataloged_item.collection_object_id, 'agent_name','coll_names') COLLECTORS,
 	ConcatSingleOtherId(cataloged_item.collection_object_id,'Field Num') field_num,
 	concatotherid(cataloged_item.collection_object_id) OTHERCATALOGNUMBERS,
 	concatgenbank(cataloged_item.collection_object_id) GENBANKNUM,
 	concatrelations(cataloged_item.collection_object_id) RELATEDCATALOGEDITEMS,
 	concattypestatus(cataloged_item.collection_object_id) TYPESTATUS,
 	ConcatAttributeValue(cataloged_item.collection_object_id,'sex') sex,
 	concatparts(cataloged_item.collection_object_id) parts,
 	trans.INSTITUTION_ACRONYM || ' ' || accn_number as accession,
 	concatEncumbrances(cataloged_item.collection_object_id) ENCUMBRANCES,
 	began_date,
 	ended_date,
 	verbatim_date ,
 	higher_geog ,
 	continent_ocean ,
 	country ,
 	state_prov ,
 	county ,
 	feature ,
 	island ,
 	island_group ,
 	quad,
 	sea,
 	spec_locality ,
 	decode(orig_elev_units,
		'm',minimum_elevation,
		'ft',minimum_elevation * .3048) min_elev_in_m,
	decode(orig_elev_units,
		'm',maximum_elevation,
		'ft',maximum_elevation * .3048) max_elev_in_m ,
	locality.locality_id,
 	dec_lat ,
 	dec_long  ,
 	datum ,
 	orig_lat_long_units ,
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
	lat_long_ref_source ,
	decode(max_error_units,
		'm',max_error_distance,
		'ft',max_error_distance * .3048,
		'km',max_error_distance * 1000,
		'mi',max_error_distance * 1609.344,
		'yd',max_error_distance * .9144) COORDINATEUNCERTAINTYINMETERS,
	georefmethod,
 	lat_long_remarks ,
 	lldetr.agent_name AS lat_long_determiner,
	identification.scientific_name ,
	idby.agent_name IDENTIFIEDBY,
 	identification.made_date,
 	coll_object_remarks REMARKS,
 	habitat,
 	associated_species
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
 		preferred_agent_name idby,
 		coll_object_remark,
 		accn,
 		trans,
 		preferred_agent_name lldetr
 	where 
 		cataloged_item.collection_object_id = coll_object.collection_object_id and
 		cataloged_item.accn_id = accn.transaction_id and 
 		accn.transaction_id = trans.transaction_id AND
 		cataloged_item.collection_id = collection.collection_id and
 		cataloged_item.collection_object_id = collectornumber.collection_object_id (+) and
 		cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
 		collecting_event.locality_id = locality.locality_id and
 		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
 		locality.locality_id = accepted_lat_long.locality_id (+) and
 		accepted_lat_long.DETERMINED_BY_AGENT_ID = lldetr.agent_id (+) AND
 		cataloged_item.collection_object_id = identification.collection_object_id and
 		accepted_id_fg=1 AND
 		identification.id_made_by_agent_id = idby.agent_id (+) and
 		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+)
 		;
 		
 		
 		drop table flat;
 		rename wtf to flat;
 		
 	
 		
 		alter table flat modify COLLECTION_CDE VARCHAR2(5) NULL;
 		alter table flat modify INDIVIDUALCOUNT NUMBER NULL;
 		alter table flat modify COLL_OBJ_DISPOSITION VARCHAR2(20) NULL;
 		alter table flat modify BEGAN_DATE DATE NULL;
 		alter table flat modify ENDED_DATE DATE NULL;
 		alter table flat modify VERBATIM_DATE VARCHAR2(60) NULL;
 		alter table flat modify COLLECTING_EVENT_ID NUMBER NULL;
		alter table flat modify GEOG_AUTH_REC_ID NUMBER NULL;
		alter table flat modify LOCALITY_ID NUMBER NULL;
		alter table flat modify SCIENTIFIC_NAME VARCHAR2(255) NULL;
		


 		
 		create or replace public synonym flat for flat;
 		grant select on flat to uam_query,uam_update ;
 
 drop index flat_collobjid;
 create unique index pkey_flat on flat (collection_object_id);
 create index flat_cat_num on flat (cat_num);
  create index flat_collection_id on flat (collection_id);
  create index flat_COLLECTORS on flat (COLLECTORS);
  create index flat_began_date on flat (began_date);
  create index flat_ended_date on flat (ended_date);
  create index u_flat_higher_geog on flat (upper(higher_geog));
  create index u_flat_continent_ocean on flat (upper(continent_ocean));
  create index u_flat_country on flat (upper(country));
  create index u_flat_state_prov on flat (upper(state_prov));
  create index u_flat_county on flat (upper(county));
  create index u_flat_feature on flat (upper(feature));
  create index u_flat_island on flat (upper(island));
  create index u_flat_island_group on flat (upper(island_group));
  create index u_flat_quad on flat (upper(quad));
  create index u_flat_sea on flat (upper(sea));
  create index u_flat_spec_locality on flat (upper(spec_locality));
  create index u_flat_scientific_name on flat (upper(scientific_name));

 
 analyze table flat compute statistics;
 
 /*
 	Random stuff to update bits and pieces when things are added, get out of sync, etc:
 	
 	update flat set (accession) =
 	(select institution_acronym || ' ' || accn_number
 	from accn,trans where
 	accn.transaction_id = trans.transaction_id
 	and trans.transaction_id = flat.ACCN_ID)
 	;	
*/ 	