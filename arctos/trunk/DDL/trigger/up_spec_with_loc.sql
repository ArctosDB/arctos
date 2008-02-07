-- 6 Aug 2007
-- DLM
-- Bugfix: new <> old higher geog was never firing - removed IF

CREATE OR REPLACE TRIGGER up_spec_with_loc
INSTEAD OF UPDATE
ON spec_with_loc
FOR EACH ROW
DECLARE
	num_specs_coll_event number;
	num_coll_event_loc number;
	ngeog_auth_rec_id number;
	nlocality_id number;
	ncollecting_event_id number;
	nlat_long_id number;
	num number;
	sqlstr varchar2(4000);
	sqlSel varchar2(255);
	execThis varchar2(4000);
BEGIN
    sqlstr:='alter session set nls_date_format = ''DD-Mon-YYYY''';
    EXECUTE IMMEDIATE sqlstr;

    -- if :new.geog_auth_rec_id <> :old.geog_auth_rec_id THEN
    dbms_output.put_line('new <> old geog');
	-- make sure we can get a good geog_auth_rec_id
	
	SELECT count(*) INTO num  FROM geog_auth_rec WHERE higher_geog = :new.higher_geog;
	IF num = 0 THEN
		RAISE_APPLICATION_ERROR(-20000, 'New higher geography not found.');
	END IF;
	    
	-- get getog_auth_rec_id into a local variable
	SELECT min(geog_auth_rec_id) INTO ngeog_auth_rec_id FROM geog_auth_rec WHERE higher_geog = :new.higher_geog;
    -- ELSE
	-- dbms_output.put_line('new = (but not really) old geog');
	-- ngeog_auth_rec_id := :old.geog_auth_rec_id;
    -- END IF;
    dbms_output.put_line('ngeog_auth_rec_id: ' || ngeog_auth_rec_id);
    	
    sqlSel := 'select count(*)';
    
    sqlstr := ' FROM spec_with_loc WHERE
		geog_auth_rec_id = ' || ngeog_auth_rec_id || ' AND
		NVL(maximum_elevation,-1) = ' || NVL(:new.maximum_elevation,-1) || ' AND
		NVL(minimum_elevation,-1) = ' || NVL(:new.minimum_elevation,-1) || ' AND
		NVL(orig_elev_units,''NULL'') = ''' || NVL(:new.orig_elev_units,'NULL') || ''' AND
		NVL(min_depth,-1) = ' || nvl(:new.min_depth,-1) || ' AND
		NVL(max_depth,-1) = ' || nvl(:new.max_depth,-1) || ' AND
		NVL(spec_locality,''NULL'') = ''' || NVL(:new.spec_locality,'NULL') || ''' AND
		NVL(locality_remarks,''NULL'') = ''' || NVL(:new.locality_remarks,'NULL') || ''' AND
		NVL(depth_units,''NULL'') = ''' || NVL(:new.depth_units,'NULL') || ''' AND 
		NVL(nogeorefbecause,''NULL'') = ''' ||  NVL(:new.nogeorefbecause,'NULL') || '''';
			
    IF :new.orig_lat_long_units IS NOT null THEN
    	sqlstr := sqlstr || ' AND 
			orig_lat_long_units = ''' || :new.orig_lat_long_units || ''' AND
			datum = ''' || :new.datum || ''' AND
			determined_by_agent_id = ' || :new.determined_by_agent_id || ' AND
			NVL(determined_date,''1-JAN-1600'') = ''' || NVL(:new.determined_date,'1-JAN-1600') || ''' AND 
			NVL(lat_long_ref_source,''NULL'') = ''' || NVL(:new.lat_long_ref_source,'NULL') || ''' AND 
			NVL(lat_long_remarks,''NULL'') = ''' || NVL(:new.lat_long_remarks,'NULL') || ''' AND 
			NVL(max_error_distance,-1) = ' || nvl(:new.max_error_distance,-1) || ' AND
			NVL(max_error_units,''NULL'') = ''' || NVL(:new.max_error_units,'NULL') || ''' AND 
			NVL(extent,-1) = ' || nvl(:new.extent,-1) || ' AND
			NVL(gpsaccuracy,-1) = ' || nvl(:new.gpsaccuracy,-1) || ' AND
			NVL(georefmethod,''NULL'') = ''' || NVL(:new.georefmethod,'NULL') || ''' AND 
			NVL(verificationstatus,''NULL'') = ''' || NVL(:new.verificationstatus,'NULL') || ''' AND 
			NVL(verificationstatus,''NULL'') = ''' || NVL(:new.verificationstatus,'NULL') || '''';  
    	IF :new.orig_lat_long_units = 'decimal degrees' THEN
			sqlstr := sqlstr || ' AND
				NVL(dec_lat,-1) = ' || nvl(:NEW.dec_lat,-1) || ' AND
				NVL(dec_long,-1) = ' || nvl(:NEW.dec_long,-1) || '';
		ELSIF :new.orig_lat_long_units = 'UTM' THEN
			sqlstr := sqlstr || ' AND
				NVL(utm_ew,-1) = ' || nvl(:new.utm_ew,-1) || ' AND
				NVL(utm_ns,-1) = ' || nvl(:new.utm_ns,-1) || ' AND
				NVL(utm_zone,''NULL'') = ''' || NVL(:new.utm_zone,'NULL') || '''';
		ELSIF :new.orig_lat_long_units = 'degrees dec. minutes' THEN
			sqlstr := sqlstr || ' AND
				NVL(lat_deg,-1) = ' || nvl(:new.lat_deg,-1) || ' AND
				NVL(dec_lat_min,-1) = ' || nvl(:new.dec_lat_min,-1) || ' AND
				NVL(lat_dir,''NULL'') = ''' || NVL(:new.lat_dir,'NULL') || ''' AND
				NVL(long_deg,-1) = ' || nvl(:new.long_deG,-1) || ' AND
				NVL(dec_long_min,-1) = ' || nvl(:new.dec_long_min,-1) || ' AND
				NVL(long_dir,''NULL'') = ''' || NVL(:new.long_diR,'NULL') || '''';
		ELSIF :new.orig_lat_long_units = 'deg. min. sec.' THEN
			sqlstr := sqlstr || ' AND
				NVL(lat_deg,-1) = ' || nvl(:new.lat_deg,-1) || ' AND
				NVL(lat_min,-1) = ' || nvl(:new.lat_min,-1) || ' AND
				NVL(lat_sec,-1) = ' || nvl(:new.lat_sec,-1) || ' AND
				NVL(lat_dir,''NULL'') = ''' || NVL(:new.lat_dir,'NULL') || ''' AND
				NVL(long_deg,-1) = ' || nvl(:new.long_deg,-1) || ' AND
				NVL(long_min,-1) = ' || nvl(:new.long_min,-1) || ' AND
				NVL(long_sec,-1) = ' || nvl(:new.long_sec,-1) || ' AND
				NVL(long_dir,''NULL'') = ''' || NVL(:new.long_dir,'NULL') || '''';
		ELSE
			RAISE_APPLICATION_ERROR(-20000, 'Invalid orig_lat_long_units');	
		END IF;
	END IF;	
	    
	execThis := sqlSel || sqlstr;
	--dbms_output.put_line('sqlstr: ' || sqlstr);
	execute immediate execThis into num ;
	dbms_output.put_line('num of matching latlong localities: ' || num);
			
    IF num > 0 THEN
    	-- there is an existing lat_long/locality record available
    	sqlSel := 'select min(locality_id) ';
    	execThis := sqlSel || sqlstr;
		--dbms_output.put_line('execThis: ' || execThis);
    	execute immediate execThis into nlocality_id ;
		dbms_output.put_line('using existing locality nlocality_id: ' || nlocality_id);
    ELSE
    	-- must create lat_long/locality
    	dbms_output.put_line('makem new nlocality_id');
	    SELECT max(locality_id) + 1 INTO nlocality_id FROM locality;
	
    	INSERT INTO locality (
			locality_id,
			geog_auth_rec_id,
			maximum_elevation,
			minimum_elevation,
			orig_elev_units,
			spec_locality,
			locality_remarks,
			depth_units,
			min_depth,
			max_depth,
			nogeorefbecause)
		VALUES (
	    	nlocality_id,
			ngeog_auth_rec_id,
			:new.maximum_elevation,
			:new.minimum_elevation,
			:new.orig_elev_units,
			:new.spec_locality,
			:new.locality_remarks,
			:new.depth_units,
			:new.min_depth,
			:new.max_depth,
			:new.nogeorefbecause);
	
        IF :new.orig_lat_long_units IS NOT null THEN
        	SELECT max(lat_long_id) + 1 INTO nlat_long_id FROM lat_long;
        	sqlstr := 'INSERT INTO lat_long (
				lat_long_id,
				locality_id,
				orig_lat_long_units,
				determined_by_agent_id,
				determined_date,
				lat_long_ref_source,
				lat_long_remarks,
				max_error_distance,
				max_error_units,
				accepted_lat_long_fg,
				extent,
				gpsaccuracy,
				georefmethod,
				verificationstatus,
				datum';
    		execThis := nlat_long_id || ',' ||
   	     		nlocality_id || ',''' ||
				:new.orig_lat_long_units || ''',' ||
				:new.determined_by_agent_id || ',''' ||
				:new.determined_date || ''',''' ||
        		:new.lat_long_ref_source || ''',''' ||
				:new.lat_long_remarks || ''','  ||
				NVL(:new.max_error_distance,-1) || ',''' ||
				:new.max_error_units || ''',' ||
				1 || ',' ||
				NVL(:new.extent,-1) || ',' ||
				NVL(:new.gpsaccuracy,-1) || ',''' ||
				:new.georefmethod || ''',''' ||
				:new.verificationstatus || ''',''' ||
				:new.datum || '''';
    		IF :new.orig_lat_long_units = 'decimal degrees' THEN
    			sqlstr := sqlstr || ' ,dec_lat,dec_long';
				execThis := execThis || ',' || :new.dec_lat || ',' || :new.dec_long;
			ELSIF :new.orig_lat_long_units = 'UTM' THEN
				sqlstr := sqlstr || ', utm_ew, utm_ns , utm_zone';
				execThis := execThis || ',' || :new.utm_ew || ',' || :new.utm_ns || ',''' || :new.utm_zone || '''';
			ELSIF :new.orig_lat_long_units = 'degrees dec. minutes' THEN
				sqlstr := sqlstr || ' , lat_deg, dec_lat_min, lat_dir, long_deg, dec_long_min, long_dir';
				execThis := execThis || ',' || :new.lat_deg || ',' || :new.dec_lat_min || ',''' || :new.lat_dir || ''',' ||
                    :new.long_deg || ',' || :new.dec_long_min || ',''' || :new.long_dir || '''';
    		ELSIF :new.orig_lat_long_units = 'deg. min. sec.' THEN
    			sqlstr := sqlstr || ', lat_deg, lat_min , lat_sec, lat_dir, long_deg, long_min,long_sec, long_dir ';
    			execThis := execThis || ',' || :new.lat_deg || ',' || :new.lat_min  || ',' || :new.lat_sec || ',''' || :new.LAT_DIR || ''',' ||
			        :new.long_deg || ',' || :new.long_min || ',' || :new.long_sec || ',''' || :new.long_dir || '''';
    		ELSE
			    RAISE_APPLICATION_ERROR(-20000, 'Invalid orig_lat_long_units');	
    		END IF;
		
    		--dbms_output.put_line('sqlstr: ' || sqlstr);
			--dbms_output.put_line('execThis: ' || execThis);
			sqlstr := sqlstr || ' ) values ( ' || execThis || ' )';
			--dbms_output.put_line('sqlstr: ' || sqlstr);
			execute immediate sqlstr;
        END IF;
	
	    dbms_output.put_line('made new locality: ' || nlocality_id);
    END IF;
    --nlocality_id := 123445567;

    sqlstr := ' FROM spec_with_loc WHERE
		NVL(verbatim_date,''NULL'') = ''' || NVL(:new.verbatim_date,'NULL') || ''' AND
		NVL(began_date,''1-JAN-1600'') = ''' || NVL(:new.began_date,'1-JAN-1600') || ''' AND 
		NVL(ended_date,''1-JAN-1600'') = ''' || NVL(:new.ended_date,'1-JAN-1600') || ''' AND 
		NVL(verbatim_locality,''NULL'') = ''' || NVL(:new.verbatim_locality,'NULL') || ''' AND
		NVL(coll_event_remarks,''NULL'') = ''' || NVL(:new.coll_event_remarks,'NULL') || ''' AND
		NVL(collecting_source,''NULL'') = ''' || NVL(:new.collecting_source,'NULL') || ''' AND
		NVL(collecting_method,''NULL'') = ''' || NVL(:new.collecting_method,'NULL') || ''' AND
		NVL(habitat_desc,''NULL'') = ''' || NVL(:new.habitat_desc,'NULL') || ''' AND
	    locality_id = ' || nlocality_id ;
    
    sqlSel := 'select count(*)  ';
	execThis := sqlSel || sqlstr;
	dbms_output.put_line('execThis: ' || execThis);
	execute immediate execThis into num ;
	
    IF num > 0 THEN
    	-- there is an existing collecting event available
    	sqlSel := 'select min(collecting_event_id) ';
    	execThis := sqlSel || sqlstr;
		dbms_output.put_line('execThis: ' || execThis);
		execute immediate execThis into ncollecting_event_id ;
		--dbms_output.put_line('ncollecting_event_id: ' || ncollecting_event_id);
    ELSE
	-- if collecting event is only used by this specimen, update. Otherwise, create a new collecting event
    	SELECT count(*) INTO num 
		FROM spec_with_loc 
		WHERE
		    collecting_event_id = :new.collecting_event_id AND 
		    collection_object_id <> :new.collection_object_id;
	
    	IF num = 0 THEN
    		--no other specimens use this collecting event, we can update
    		UPDATE collecting_event 
    		SET
				locality_id = nlocality_id,
				began_date = :new.began_date,
				ended_date = :new.ended_date,
				verbatim_date = :new.verbatim_date,
				verbatim_locality = :new.verbatim_locality,
				coll_event_remarks = :new.coll_event_remarks,
				collecting_source = :new.collecting_source,
				collecting_method = :new.collecting_method,
				habitat_desc = :new.habitat_desc
			WHERE collecting_event_id = :old.collecting_event_id;		
		    ncollecting_event_id := :old.collecting_event_id;
        ELSE
    		-- must create collecting event
			--dbms_output.put_line('makem new ncollecting_event_id');
			SELECT max(collecting_event_id) + 1 INTO ncollecting_event_id FROM collecting_event;
			INSERT INTO collecting_event (
    			collecting_event_id,
				locality_id,
				began_date,
				ended_date,
				verbatim_date,
				verbatim_locality,
				coll_event_remarks,
				collecting_source,
				collecting_method,
				habitat_desc)
			values (
		    	ncollecting_event_id,
				nlocality_id,
				:new.began_date,
				:new.ended_date,
				:new.verbatim_date,
				:new.verbatim_locality,
				:new.coll_event_remarks,
				:new.collecting_source,
				:new.collecting_method,
				:new.habitat_desc);
    	END IF;
    END IF;
        
    update cataloged_item SET collecting_event_id = ncollecting_event_id WHERE collection_object_id = :new.collection_object_id;
    update lat_long SET max_error_distance = NULL WHERE max_error_distance = -1;
	update lat_long SET EXTENT = NULL WHERE EXTENT = -1;
	update lat_long SET gpsaccuracy = NULL WHERE gpsaccuracy = -1;
END;
/
sho err;
