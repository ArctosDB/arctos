CREATE OR REPLACE VIEW filtered_flat AS
	SELECT
		collection_object_id,
		cat_num,
		accn_id,
		collection_id,
		institution_acronym,
		collection_cde,
		collection,
		collecting_event_id,
		-- mask year collected
		CASE
			WHEN encumbrances LIKE '%mask year collected%'
			THEN to_date(to_char(began_date,'dd-Mon')||'-8888')
			ELSE began_date
		END began_date,
		CASE
			WHEN encumbrances LIKE '%mask year collected%'
			THEN to_date(to_char(ended_date,'dd-Mon')||'-8888')
			ELSE ended_date
		END ended_date,
		CASE
			WHEN encumbrances LIKE '%mask year collected%'
			THEN 'Masked'
			ELSE verbatim_date
		END verbatim_date,
		last_edit_date,
		individualcount,
		coll_obj_disposition,
		-- mask collector
		CASE
			WHEN encumbrances LIKE '%mask collector%'
			THEN 'Anonymous'
			ELSE collectors
		END collectors,
		-- mask original field number
		CASE
			WHEN encumbrances LIKE '%mask original field number%'
			THEN 'Anonymous'
			ELSE field_num
		END field_num,
		othercatalognumbers,
		genbanknum,
		relatedcatalogeditemS,
		typestatus,
		sex,
		parts,
		encumbrances,
		accession,
		geog_auth_rec_id,
		higher_geog,
		continent_ocean,
		country,
		state_prov,
		county,
		feature,
		island,
		island_group,
		quad,
		sea,
		locality_id,
		spec_locality,
		minimum_elevation,
		maximum_elevation,
		orig_elev_units,
		min_elev_in_m,
		max_elev_in_m,
		-- mask coordinates
		CASE
			WHEN encumbrances LIKE '%mask coordinates%'
			THEN 0
			ELSE dec_lat
		END dec_lat,
		CASE
			WHEN encumbrances LIKE '%mask coordinates%'
			THEN 0
			ELSE dec_long
		END dec_long,
		datum,
		orig_lat_long_units,
		CASE
			WHEN encumbrances LIKE '%mask coordinates%'
			THEN 'Masked'
			ELSE verbatimlatitude
		END verbatimlatitude,
		CASE
			WHEN encumbrances LIKE '%mask coordinates%'
			THEN 'Masked'
			ELSE verbatimlongitude
		END verbatimlongitude,
		lat_long_ref_source,
		coordinateuncertaintyinmeters,
		georefmethod,
		lat_long_remarks,
		lat_long_determiner,
		identification_id,
		scientific_name,
		identifiedby,
		made_date,
		remarks,
		habitat,
		associated_species
	FROM
		flat
	WHERE
	-- exclude masked records
		(encumbrances IS null OR encumbrances NOT LIKE '%mask record%');

CREATE OR REPLACE PUBLIC SYNONYM filtered_flat FOR filtered_flat;
GRANT SELECT ON filtered_flat TO public;
