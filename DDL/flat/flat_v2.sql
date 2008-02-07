create table testflat as
 select 
 	cataloged_item.collection_object_id	collection_object_id,
 	collection.institution_acronym || ':' || collection.collection_cde || ':' || cataloged_item.cat_num GlobalUniqueIdentifier,
 	-- use entered date is last modified date is NULL
 	decode(coll_object.last_edit_date,
 		NULL,COLL_OBJECT_ENTERED_DATE,
 		LAST_EDIT_DATE) DateLastModified,
 	-- need code table/definition for coll_object_type, and need to implement making it useful (as part of observations rework)
	decode(coll_object.COLL_OBJECT_TYPE,
		'CI','PreservedSpecimen',
		'HO','HumanObservation',
		'OtherSpecimen') BasisOfRecord,
	collection.institution_acronym InstitutionCode,
	collection.collection_cde CollectionCode,
	cat_num CatalogNumber,
	-- examples: "mask preparator; mask original field number; mask collector" - "reserved for genetic analysis"
	-- wild guess: the curators that make encumbrances will whine and 
	-- snivel if we tell people that they're hiding data, even though we SHOULD
	-- be telling people when we're hiding data
	concatEncumbrances(cataloged_item.collection_object_id) InformationWithheld,
	coll_object_remarks Remarks,
	identification.scientific_name ScientificName,
	-- get_taxonomy is a function that returns one term (e.g., full_taxon_name) when
	-- all elements used in the ID share that term, and "undefinable" when they
	-- do not. So, "Rattus a or Rattus b" returns genus=Rattus, but "Rattus a or Sprex b" returns genus=undefinable 
	get_taxonomy(cataloged_item.collection_object_id,'full_taxon_name') HigherTaxon,
	-- not recorded in Arctos
	-- Kingdom,
	-- Phylum,
	get_taxonomy(cataloged_item.collection_object_id,'phylclass') Class,
	get_taxonomy(cataloged_item.collection_object_id,'phylorder') pOrder,
	get_taxonomy(cataloged_item.collection_object_id,'family') Family,
	get_taxonomy(cataloged_item.collection_object_id,'genus') Genus,
	get_taxonomy(cataloged_item.collection_object_id,'species') SpecificEpithet,
	get_taxonomy(cataloged_item.collection_object_id,'infraspecific_rank') InfraspecificRank,
	get_taxonomy(cataloged_item.collection_object_id,'subspecies') InfraSpecificEpithet,
	-- will probably break more often than not - see above.
	get_taxonomy(cataloged_item.collection_object_id,'author_text') AuthorYearOfScientificName,
	-- NomenclaturalCode,
	nature_of_id IdentificationQualifer,
	higher_geog HigherGeography,
	continent_ocean Continent,
	-- not sure how to separate this out from continent_ocean, and the data are goofy enough to complicate the issue
	-- WaterBody,
	island_group IslandGroup,
	island Island,
	country Country,
	state_prov StateProvince,
	county County,
	spec_locality Locality,
	to_meters(minimum_elevation,orig_elev_units) MinimumElevationInMeters,
	to_meters(maximum_elevation,orig_elev_units) MaximumElevationInMeters,
	to_meters(MIN_DEPTH,DEPTH_UNITS) MinimumDepthInMeters,
	to_meters(MAX_DEPTH,DEPTH_UNITS) MaximumDepthInMeters,
  	collecting_method CollectingMethod,
  	-- I don't _think_ we're willing to try, once again, to translate collecting_source to some arbitrary yes/no decision
  	-- ValidDistributionFlag,
  	began_date EarliestDateCollected,
  	ended_date LatestDateCollected,
  	--Returns NULL if began_date and ended_date aren't the same 
  	DECODE (began_date,
  		ended_date,TO_NUMBER(TO_CHAR(BEGAN_DATE,'DDD')),
  		NULL) DayOfYear,
  	--comma-separated list of collectors
  	concatColl(cataloged_item.collection_object_id) Collector,
  	-- list of determinations of attribute "sex." Possibilities include: male; male, male, male; male, female, ....
  	concatattributevalue(cataloged_item.collection_object_id,'sex') Sex,
  	-- this works fine for mammals, but will probably need modified for other collections
  	concatattributevalue(cataloged_item.collection_object_id,'age class') LifeStage,
  	-- example: sex: male; eyes: blue; .....
	concatattribute(cataloged_item.collection_object_id) Attributes,
	--space-separated list of URLs of binary objects
	ConcatImageUrl(cataloged_item.collection_object_id) ImageURL,
	-- link to SpecimenDetail
	'<a href="http://arctos.database.museum/SpecimenDetail.cfm?collection_object_id=' || cataloged_item.collection_object_id || '">' || collection.institution_acronym || ' ' || collection.collection_cde || ' ' || cataloged_item.cat_num || '</a>' RelatedInformation,
	-- will soon be problematic as many collections do not have numeric catalog numbers
	cat_num CatalogNumberNumeric,
	CONCATACCEPTEDIDENTIFYINGAGENT(cataloged_item.collection_object_id) IdentifiedBy,
	identification.made_date DateIdentified,
	concatsingleotherid(cataloged_item.collection_object_id,'collector number') CollectorNumber,
	concatsingleotherid(cataloged_item.collection_object_id,'original field number') FieldNumber,
	-- FieldNotes,
	verbatim_date VerbatimCollectingDate,
	decode (ORIG_ELEV_UNITS,
		NULL,NULL,
		MINIMUM_ELEVATION || '-' || MAXIMUM_ELEVATION || ' ' || ORIG_ELEV_UNITS) VerbatimElevation,
	decode (DEPTH_UNITS,
		NULL,NULL,
		MIN_DEPTH || '-' || MAX_DEPTH || ' ' || DEPTH_UNITS) VerbatimDepth,
 	concatparts(cataloged_item.collection_object_id) Preparations,
	concattypestatus(cataloged_item.collection_object_id) TypeStatus,
	-- list of HREF-wrapped URLs to GenBank
	concatgenbank(cataloged_item.collection_object_id) GenBankNumber,
 	concatotherid(cataloged_item.collection_object_id) OtherCatalogNumbers,
 	-- space-separated list of format {relationship} of {GUID}
	concatDarwinRelations(cataloged_item.collection_object_id) RelatedCatalogedItems,
	coll_object.COLL_OBJ_DISPOSITION Disposition,
	-- DarwinCore docs: don't use for observations. Arctos: is (perhaps??) used for observations
	coll_object.lot_count IndividualCount,
	dec_lat DecimalLatitude,
	dec_long DecimalLongitude,
	datum GeodeticDatum,
	to_meters(max_error_distance,max_error_units) CoordinateUncertaintyInMeters,
	-- PointRadiusSpatialFit,
	-- unsure of utility as it related to Arctos
	-- VerbatimCoordinates,
	decode(orig_lat_long_units,
		'decimal degrees',to_char(dec_lat) || 'd',
		'deg. min. sec.', to_char(lat_deg) || 'd ' || to_char(lat_min) || 'm ' || to_char(lat_sec) || 's ' || lat_dir,
		'degrees dec. minutes', to_char(lat_deg) || 'd ' || to_char(dec_lat_min) || 'm ' || lat_dir
		)  VerbatimLatitude,
	decode(orig_lat_long_units,
		'decimal degrees',to_char(dec_long) || 'd',
		'deg. min. sec.', to_char(long_deg) || 'd ' || to_char(long_min) || 'm ' || to_char(long_sec) || 's ' || long_dir,
		'degrees dec. minutes', to_char(long_deg) || 'd ' || to_char(dec_long_min) || 'm ' || long_dir
		)  VerbatimLongitude,
	orig_lat_long_units VerbatimCoordinateSystem,
	GEOREFMETHOD GeoreferenceProtocol,
	LAT_LONG_REF_SOURCE GeoreferenceSources,
	VERIFICATIONSTATUS GeoreferenceVerificationStatus,
	LAT_LONG_REMARKS GeoreferenceRemarks,
	-- FootprintWKT,
	-- FootprintSpatialFit,
	-- end of DarwinCore data
	trans.INSTITUTION_ACRONYM || ' ' || accn_number as accession,
	collecting_event.collecting_event_id,
 	accn_id,
 	collection.collection_id,
 	geog_auth_rec.geog_auth_rec_id,
	locality.locality_id,
 	lldetr.agent_name AS lat_long_determiner,
	habitat,
	associated_species	
 from 
 	cataloged_item, 
 	coll_object,
 	collection,
 	collecting_event,
 	locality,
 	geog_auth_rec,
 	accepted_lat_long,
 	identification,
 	coll_object_remark,
	accn,
	trans,
	preferred_agent_name lldetr
where 
	cataloged_item.collection_object_id = coll_object.collection_object_id and
	cataloged_item.accn_id = accn.transaction_id and 
	accn.transaction_id = trans.transaction_id AND
	cataloged_item.collection_id = collection.collection_id and
	cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
	collecting_event.locality_id = locality.locality_id and
	locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
	locality.locality_id = accepted_lat_long.locality_id (+) and
	accepted_lat_long.DETERMINED_BY_AGENT_ID = lldetr.agent_id (+) AND
	cataloged_item.collection_object_id = identification.collection_object_id and
	accepted_id_fg=1 AND
	cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+)
	and cat_num < 20
;
 	

 		alter table testflat modify COLLECTION_CDE VARCHAR2(5) NULL;
 		alter table testflat modify INDIVIDUALCOUNT NUMBER NULL;
 		alter table testflat modify COLL_OBJ_DISPOSITION VARCHAR2(20) NULL;
 		alter table testflat modify BEGAN_DATE DATE NULL;
 		alter table testflat modify ENDED_DATE DATE NULL;
 		alter table testflat modify VERBATIM_DATE VARCHAR2(60) NULL;
 		alter table testflat modify COLLECTING_EVENT_ID NUMBER NULL;
		alter table testflat modify GEOG_AUTH_REC_ID NUMBER NULL;
		alter table testflat modify LOCALITY_ID NUMBER NULL;
		alter table testflat modify SCIENTIFIC_NAME VARCHAR2(255) NULL;


 