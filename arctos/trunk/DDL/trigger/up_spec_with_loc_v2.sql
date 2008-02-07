create or replace trigger up_spec_with_loc
INSTEAD OF UPDATE
ON spec_with_loc
FOR EACH ROW
declare
	num_specs_coll_event number;
	num_coll_event_loc number;
	ngeog_auth_rec_id NUMBER;
	nlocality_id NUMBER;
	ncollecting_event_id NUMBER;
	nlat_long_id NUMBER;
	num number;
	sqlstr varchar2(4000);
	sqlSel varchar2(255);
	execThis varchar2(4000);
BEGIN
-- possibilities covered in this trigger:
-- 1) One or more appropriate coll event/locality/coordinates exist
-- 		Solution: update cataloged item with the new collecting_event_id
-- 2) One or more appropriate locality/ies exist/s
-- 		Solution: create an appropriate collecting event for the good locality, update cataloged_item
-- 3) No collecting events or localities exist
-- 		Solution: create everything, update cataloged_item
sqlstr:='alter session set nls_date_format = ''DD-Mon-YYYY''';
execute immediate sqlstr;

if :NEW.geog_auth_rec_id <> :OLD.geog_auth_rec_id THEN
	-- make sure we can get a good geog_auth_rec_id
	select count(*) into num from geog_auth_rec where higher_geog = :NEW.higher_geog;
	if num = 0 then
		RAISE_APPLICATION_ERROR(-20000, 'New higher geography not found.');
	end if;
	-- get getog_auth_rec_id into a local variable
	select min(geog_auth_rec_id) into ngeog_auth_rec_id from geog_auth_rec where higher_geog = :NEW.higher_geog;
	dbms_output.put_line('ngeog_auth_rec_id: ' || ngeog_auth_rec_id)
ELSE
	ngeog_auth_rec_id := :OLD.geog_auth_rec_id;
END IF;
-- first, we want to see if we can just use an existing locality-coordinate-collecting_event
-- if so, all we have to to is update cataloged item
select 
	 nvl(min(collecting_event_id),-1),
	 nvl(min(locality_id),-1)			 
INTO
	ncollecting_event_id,
	nlocality_id
FROM 
	spec_with_loc 
WHERE
	geog_auth_rec_id = ngeog_auth_rec_id AND
	NVL(MAXIMUM_ELEVATION,-1) = NVL(:NEW.maximum_elevation,-1) AND
	NVL(MAXIMUM_ELEVATION,-1) = NVL(:NEW.maximum_elevation,-1) AND
	NVL(MINIMUM_ELEVATION,-1) = NVL(:NEW.minimum_elevation,-1) AND
	NVL(ORIG_ELEV_UNITS,'NULL') = NVL(:NEW.orig_elev_units,'NULL') AND
	NVL(MIN_DEPTH,-1) = nvl(:NEW.min_depth,-1) AND
	NVL(MAX_DEPTH,-1) = nvl(:NEW.max_depth,-1) AND
	NVL(SPEC_LOCALITY,'NULL') = NVL(:NEW.spec_locality,'NULL') AND
	NVL(LOCALITY_REMARKS,'NULL') = NVL(:NEW.locality_remarks,'NULL') AND
	NVL(DEPTH_UNITS,'NULL') = NVL(:NEW.depth_units,'NULL') AND 
	NVL(NOGEOREFBECAUSE,'NULL') = NVL(:NEW.nogeorefbecause,'NULL')  AND
	NVL(orig_lat_long_units,'NULL') = NVL(:NEW.orig_lat_long_units,'NULL') AND
	datum = :NEW.datum AND
	NVL(determined_by_agent_id,-1) = nvl(:NEW.determined_by_agent_id,-1) AND
	NVL(determined_date,'1-JAN-1600') = NVL(to_date(:NEW.determined_date),'1-JAN-1600') AND 
	NVL(lat_long_ref_source,'NULL') = NVL(:NEW.lat_long_ref_source,'NULL') AND 
	NVL(lat_long_remarks,'NULL') = NVL(:NEW.lat_long_remarks,'NULL')  AND 
	NVL(max_error_distance,-1) = nvl(:NEW.max_error_distance,-1) AND
	NVL(gps_distance_units,-1) = nvl(:NEW.gps_distance_units,-1) AND
	NVL(max_error_units,'NULL') = NVL(:NEW.max_error_units,'NULL') AND 
	NVL(extent,-1) = nvl(:NEW.extent,-1) AND
	NVL(gpsaccuracy,-1) = nvl(:NEW.gpsaccuracy,-1) AND
	NVL(georefmethod,'NULL') = NVL(:NEW.georefmethod,'NULL')  AND 
	NVL(verificationstatus,'NULL') = NVL(:NEW.verificationstatus,'NULL') AND 
	NVL(DEC_LAT,-1) = nvl(:NEW.DEC_LAT,-1) AND
	NVL(DEC_LONG,-1) = nvl(:NEW.DEC_LONG,-1) AND
	NVL(UTM_EW,-1) = nvl(:NEW.UTM_EW,-1) AND
	NVL(UTM_NS,-1) = nvl(:NEW.UTM_NS,-1) AND
	NVL(UTM_ZONE,'NULL') = NVL(:NEW.UTM_ZONE,'NULL') AND
	NVL(LAT_DEG,-1) = nvl(:NEW.LAT_DEG,-1) AND
	NVL(DEC_LAT_MIN,-1) = nvl(:NEW.DEC_LAT_MIN,-1) AND
	NVL(LAT_DIR,'NULL') = NVL(:NEW.LAT_DIR,'NULL') AND
	NVL(LONG_DEG,-1) = nvl(:NEW.LONG_DEG,-1) AND
	NVL(DEC_LONG_MIN,-1) = nvl(:NEW.DEC_LONG_MIN,-1) AND
	NVL(LONG_DIR,'NULL') = NVL(:NEW.LONG_DIR,'NULL') AND
	NVL(LAT_MIN,-1) = nvl(:NEW.LAT_MIN,-1) AND
	NVL(LAT_SEC,-1) = nvl(:NEW.LAT_SEC,-1) AND
	NVL(LONG_MIN,-1) = nvl(:NEW.LONG_MIN,-1) AND
	NVL(LONG_SEC,-1) = nvl(:NEW.LONG_SEC,-1) AND
	NVL(VERBATIM_DATE,'NULL') = NVL(:NEW.VERBATIM_DATE,'NULL') AND
	NVL(BEGAN_DATE,'1-JAN-1600') = NVL(to_date(:NEW.BEGAN_DATE),'1-JAN-1600') AND 
	NVL(ENDED_DATE,'1-JAN-1600') = NVL(to_date(:NEW.ENDED_DATE),'1-JAN-1600') AND 
	NVL(VERBATIM_LOCALITY,'NULL') = NVL(:NEW.VERBATIM_LOCALITY,'NULL') AND
	NVL(COLL_EVENT_REMARKS,'NULL') = NVL(:NEW.COLL_EVENT_REMARKS,'NULL') AND
	NVL(COLLECTING_SOURCE,'NULL') = NVL(:NEW.COLLECTING_SOURCE,'NULL') AND
	NVL(COLLECTING_METHOD,'NULL') = NVL(:NEW.COLLECTING_METHOD,'NULL') AND
	NVL(HABITAT_DESC,'NULL') = NVL(:NEW.HABITAT_DESC,'NULL')
;
IF 	ncollecting_event_id < 0 OR nlocality_id < 0 THEN
-- there are no existing locality-coordinate-collecting events available, see about a locality
	select 
		nvl(min(locality_id),-1)
	INTO
		nlocality_id
	FROM 
		spec_with_loc 
	WHERE
		geog_auth_rec_id = ngeog_auth_rec_id AND
		NVL(MAXIMUM_ELEVATION,-1) = NVL(:NEW.maximum_elevation,-1) AND
		NVL(MINIMUM_ELEVATION,-1) = NVL(:NEW.minimum_elevation,-1) AND
		NVL(ORIG_ELEV_UNITS,'NULL') = NVL(:NEW.orig_elev_units,'NULL') AND
		NVL(MIN_DEPTH,-1) = nvl(:NEW.min_depth,-1) AND
		NVL(MAX_DEPTH,-1) = nvl(:NEW.max_depth,-1) AND
		NVL(SPEC_LOCALITY,'NULL') = NVL(:NEW.spec_locality,'NULL') AND
		NVL(LOCALITY_REMARKS,'NULL') = NVL(:NEW.locality_remarks,'NULL') AND
		NVL(DEPTH_UNITS,'NULL') = NVL(:NEW.depth_units,'NULL') AND 
		NVL(NOGEOREFBECAUSE,'NULL') = NVL(:NEW.nogeorefbecause,'NULL') AND
		NVL(orig_lat_long_units,'NULL') = NVL(:NEW.orig_lat_long_units,'NULL') AND
		NVL(datum,'NULL') = NVL(:NEW.datum,'NULL') AND		
		NVL(gps_distance_units,-1) = nvl(:NEW.gps_distance_units,-1) AND	
		NVL(determined_by_agent_id,-1) = nvl(:NEW.determined_by_agent_id,-1) AND
		NVL(determined_date,'1-JAN-1600') = NVL(to_date(:NEW.determined_date),'1-JAN-1600') AND 
		NVL(lat_long_ref_source,'NULL') = NVL(:NEW.lat_long_ref_source,'NULL') AND 
		NVL(lat_long_remarks,'NULL') = NVL(:NEW.lat_long_remarks,'NULL') AND 
		NVL(max_error_distance,-1) = nvl(:NEW.max_error_distance,-1) AND
		NVL(max_error_units,'NULL') = NVL(:NEW.max_error_units,'NULL') AND 
		NVL(extent,-1) = nvl(:NEW.extent,-1) AND
		NVL(gpsaccuracy,-1) = nvl(:NEW.gpsaccuracy,-1) AND
		NVL(georefmethod,'NULL') = NVL(:NEW.georefmethod,'NULL') AND 
		NVL(verificationstatus,'NULL') = NVL(:NEW.verificationstatus,'NULL') AND 
		NVL(DEC_LAT,-1) = nvl(:NEW.DEC_LAT,-1) AND
		NVL(DEC_LONG,-1) = nvl(:NEW.DEC_LONG,-1) AND
		NVL(UTM_EW,-1) = nvl(:NEW.UTM_EW,-1)AND
		NVL(UTM_NS,-1) = nvl(:NEW.UTM_NS,-1) AND
		NVL(UTM_ZONE,'NULL') = NVL(:NEW.UTM_ZONE,'NULL') AND
		NVL(LAT_DEG,-1) = nvl(:NEW.LAT_DEG,-1) AND
		NVL(DEC_LAT_MIN,-1) = nvl(:NEW.DEC_LAT_MIN,-1) AND
		NVL(LAT_DIR,'NULL') = NVL(:NEW.LAT_DIR,'NULL') AND
		NVL(LONG_DEG,-1) = nvl(:NEW.LONG_DEG,-1) AND
		NVL(DEC_LONG_MIN,-1) = nvl(:NEW.DEC_LONG_MIN,-1) AND
		NVL(LONG_DIR,'NULL') = NVL(:NEW.LONG_DIR,'NULL') AND
		NVL(LAT_MIN,-1) = nvl(:NEW.LAT_MIN,-1) AND
		NVL(LAT_SEC,-1) = nvl(:NEW.LAT_SEC,-1) AND
		NVL(LONG_MIN,-1) = nvl(:NEW.LONG_MIN,-1) AND
		NVL(LONG_SEC,-1) = nvl(:NEW.LONG_SEC,-1)
	;
	IF nlocality_id < 0 THEN
		-- there are no existing localities, create locality and collecting event
		select max(locality_id) + 1 into nlocality_id from locality;
		insert into locality (
			LOCALITY_ID,
			GEOG_AUTH_REC_ID,
			MAXIMUM_ELEVATION,
			MINIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			SPEC_LOCALITY,
			LOCALITY_REMARKS,
			DEPTH_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			NOGEOREFBECAUSE
		) values (
			nlocality_id,
			ngeog_auth_rec_id,
			:NEW.MAXIMUM_ELEVATION,
			:NEW.MINIMUM_ELEVATION,
			:NEW.ORIG_ELEV_UNITS,
			:NEW.SPEC_LOCALITY,
			:NEW.LOCALITY_REMARKS,
			:NEW.DEPTH_UNITS,
			:NEW.MIN_DEPTH,
			:NEW.MAX_DEPTH,
			:NEW.NOGEOREFBECAUSE
		);
		select max(COLLECTING_EVENT_ID) + 1 into ncollecting_event_id from collecting_event;
		INSERT INTO collecting_event (
			COLLECTING_EVENT_ID,
			LOCALITY_ID,
			BEGAN_DATE,
			ENDED_DATE,
			VERBATIM_DATE,
			VERBATIM_LOCALITY,
			COLL_EVENT_REMARKS,
			COLLECTING_SOURCE,
			COLLECTING_METHOD,
			HABITAT_DESC
		) values (
			ncollecting_event_id,
			nlocality_id,
			:NEW.began_date,
			:NEW.ended_date,
			:NEW.verbatim_date,
			:NEW.verbatim_locality,
			:NEW.coll_event_remarks,
			:NEW.collecting_source,
			:NEW.collecting_method,
			:NEW.habitat_desc
		); 	
		if :NEW.orig_lat_long_units is not null THEN
			select max(lat_long_id) + 1 into nlat_long_id from lat_long;
			INSERT INTO lat_long (
				LAT_LONG_ID,
				LOCALITY_ID,
				LAT_DEG,
				DEC_LAT_MIN,
				LAT_MIN,
				LAT_SEC,
				LAT_DIR,
				LONG_DEG,
				DEC_LONG_MIN,
				LONG_MIN,
				LONG_SEC,
				LONG_DIR,
				DEC_LAT,
				DEC_LONG,
				DATUM,
				UTM_ZONE,
				UTM_EW,
				UTM_NS,
				ORIG_LAT_LONG_UNITS,
				DETERMINED_BY_AGENT_ID,
				DETERMINED_DATE,
				LAT_LONG_REF_SOURCE,
				LAT_LONG_REMARKS,
				MAX_ERROR_DISTANCE,
				MAX_ERROR_UNITS,
				ACCEPTED_LAT_LONG_FG,
				EXTENT,
				GPSACCURACY,
				GEOREFMETHOD,
				VERIFICATIONSTATUS,
                gps_distance_units
			) values (
				nlat_long_id,
				nlocality_id,
				:new.LAT_DEG,
				:new.DEC_LAT_MIN,
				:new.LAT_MIN,
				:new.LAT_SEC,
				:new.LAT_DIR,
				:new.LONG_DEG,
				:new.DEC_LONG_MIN,
				:new.LONG_MIN,
				:new.LONG_SEC,
				:new.LONG_DIR,
				:new.DEC_LAT,
				:new.DEC_LONG,
				:new.DATUM,
				:new.UTM_ZONE,
				:new.UTM_EW,
				:new.UTM_NS,
				:new.ORIG_LAT_LONG_UNITS,
				:new.DETERMINED_BY_AGENT_ID,
				:new.DETERMINED_DATE,
				:new.LAT_LONG_REF_SOURCE,
				:new.LAT_LONG_REMARKS,
				:new.MAX_ERROR_DISTANCE,
				:new.MAX_ERROR_UNITS,
				1,
				:new.EXTENT,
				:new.GPSACCURACY,
				:new.GEOREFMETHOD,
				:new.VERIFICATIONSTATUS,
				:NEW.gps_distance_units)
			;
		END IF; -- end need new coordinates check	
	ELSE
		-- there is an appropriate locality, just create the collecting event
			select max(COLLECTING_EVENT_ID) + 1 into ncollecting_event_id from collecting_event;
		INSERT INTO collecting_event (
			COLLECTING_EVENT_ID,
			LOCALITY_ID,
			BEGAN_DATE,
			ENDED_DATE,
			VERBATIM_DATE,
			VERBATIM_LOCALITY,
			COLL_EVENT_REMARKS,
			COLLECTING_SOURCE,
			COLLECTING_METHOD,
			HABITAT_DESC
		) values (
			ncollecting_event_id,
			nlocality_id,
			:NEW.began_date,
			:NEW.ended_date,
			:NEW.verbatim_date,
			:NEW.verbatim_locality,
			:NEW.coll_event_remarks,
			:NEW.collecting_source,
			:NEW.collecting_method,
			:NEW.habitat_desc
		); 	

	END IF; -- end check for existing locality
END IF; -- end did NOT find pre-existing combination
-- update cataloged item no matter what happened above
update cataloged_item set collecting_event_id = ncollecting_event_id where collection_object_id = :NEW.collection_object_id;
end;
/
sho err;
