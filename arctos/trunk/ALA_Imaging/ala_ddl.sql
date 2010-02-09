
CREATE OR REPLACE PACKAGE ala as
	procedure show_sql;
	procedure show_stats;
	procedure reset_ala_status;
	PROCEDURE set_ala_status;
	procedure set_folder_type;
	procedure set_sheet_type;
	procedure ala_to_bulk;
	procedure set_exist_location;
	procedure set_loaded_location;
	PROCEDURE run_all;
END;
/
sho err
CREATE OR REPLACE PACKAGE BODY ala as
	cid NUMBER;
	pcid NUMBER;
	part_id NUMBER;
	part_container_id NUMBER;
	still_waiting number;
	num number;
	got_issues VARCHAR2(255);
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE run_all 
	is
	begin
		reset_ala_status;
		set_ala_status;
		set_folder_type;
		set_sheet_type;
		ala_to_bulk;
		set_exist_location;
		set_loaded_location;
END;
----------------------------------------------------------------
PROCEDURE show_sql 
	is
	begin
		dbms_output.put_line('exec ala.show_stats;');
		dbms_output.put_line('exec ala.run_all;');
		dbms_output.put_line('exec ala.reset_ala_status;');
		dbms_output.put_line('exec ala.set_ala_status;');
		dbms_output.put_line('exec ala.set_folder_type;');
		dbms_output.put_line('exec ala.set_sheet_type;');
		dbms_output.put_line('exec ala.ala_to_bulk;');
		dbms_output.put_line('exec ala.set_exist_location;');
		dbms_output.put_line('exec ala.set_loaded_location;');

END;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE show_stats 
	is
	begin
	    for r in (select status,count(*) c from ala_plant_imaging group by status) loop
			dbms_output.put_line(r.status || chr(9) || r.c);
		end loop;    
END;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE reset_ala_status 
	is
	begin
	    update ala_plant_imaging set status = NULL
         where status NOT IN (
             'loaded',
             'pre_existing',
             'pre_existing_containerized',
             'loaded_containerized'
        );
END;
-----------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE set_ala_status 
	is
	begin	 
	UPDATE ala_plant_imaging 
	SET status = 'processing'
	where status is null;

	UPDATE ala_plant_imaging 
		SET status = 'bad_folder_id'
		WHERE NOT EXISTS (
			SELECT scientific_name 
				FROM taxonomy 
			WHERE 
				scientific_name = ala_plant_imaging.folder_identification) AND 
		status = 'processing';
	
	UPDATE ala_plant_imaging 
	SET status = 'bad_entered_by'
	WHERE NOT EXISTS (
		SELECT agent_name 
		FROM agent_name 
		WHERE 
			agent_name_type = 'login' AND 
			agent_name = whodunit) AND 
			status = 'processing';
	
	UPDATE ala_plant_imaging 
	SET status = 'bad_barcode'
	WHERE
		NOT EXISTS (
			SELECT barcode 
			FROM container 
			WHERE barcode = ala_plant_imaging.barcode) AND
		status = 'processing';
	
	UPDATE ala_plant_imaging 
	SET status = 'bad_folder_barcode'
	WHERE 
		NOT EXISTS (
			SELECT barcode 
			FROM container 
			WHERE barcode = ala_plant_imaging.folder_barcode) AND
		status = 'processing';
	UPDATE ala_plant_imaging 
	SET status = 'dup_ala_num'
	WHERE
		idnum IN (
			SELECT idnum 
			FROM ala_plant_imaging 
			HAVING count(idnum) > 1 
			GROUP BY idnum) AND 
		status = 'processing';
	
	UPDATE ala_plant_imaging 
		SET status = 'dup_ala_num_in_arctos'
	WHERE
		idnum IN (
			SELECT display_value 
			FROM coll_obj_other_id_num
			where other_id_type='ALAAC' 
			HAVING count(display_value) > 1 
			GROUP BY display_value) AND 
		status = 'processing';
		
	UPDATE ala_plant_imaging 
		SET status = 'dup_ala_num_in_bulkloader'
	WHERE
		idtype = 'ALAAC' AND
        idnum IN (
			SELECT other_id_num_1 
			FROM bulkloader
			where other_id_num_type_1='ALAAC' 
		)
	    AND 
		status = 'processing';

   	-- want to flag the following:
   	-- not an integer
   	-- not "V" + an integer
   	-- Integer greater than 99065
   	-- "V" + integer, but integer not between 68725 and 200000
   	
UPDATE ala_plant_imaging 
 SET status = 'bad_alaac_number'
WHERE 
 idtype = 'ALAAC' AND
 (
  is_number(REPLACE(idnum,'V')) = 0 OR
  (
   (
    idnum NOT LIKE 'V%' AND
    is_number(idnum) = 0 AND
    to_number(REPLACE(idnum,'V')) > 99065
   )
   OR
   (
    idnum LIKE 'V%' AND
    is_number(REPLACE(idnum,'V')) = 0 AND 
    (
     to_number(REPLACE(idnum,'V')) < 68725 OR
     to_number(REPLACE(idnum,'V')) > 200000
    )
   )
  )
 )
AND status = 'processing';
dbms_output.put_line('l154');

    UPDATE ala_plant_imaging 
	    SET status = status || ':bad_barcode'
	    WHERE 
		NOT EXISTS (
			SELECT barcode 
			FROM container 
			WHERE barcode = ala_plant_imaging.barcode);
	UPDATE ala_plant_imaging 
	    SET status = status || ':bad_folder_barcode'
	    WHERE 
		NOT EXISTS (
			SELECT barcode 
			FROM container 
			WHERE barcode = ala_plant_imaging.folder_barcode);
			
	
END;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE set_folder_type 
	is
	begin	
	FOR s IN (SELECT FOLDER_BARCODE,folder_identification
          FROM ala_plant_imaging
          WHERE status IN ('loaded', 'pre_existing') and
          FOLDER_BARCODE is not null and
          folder_identification is not null
          GROUP BY FOLDER_BARCODE,folder_identification) LOOP
              UPDATE container SET
			    container_type = 'herbarium folder',
			    label = s.folder_identification
		WHERE barcode = s.folder_barcode; 
  END LOOP;
end;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE set_sheet_type 
	is
	begin
	FOR s IN (SELECT BARCODE
          FROM ala_plant_imaging
          WHERE status IN ('loaded', 'pre_existing')
          GROUP BY BARCODE) LOOP
              UPDATE container SET
			    container_type = 'herbarium sheet'
		WHERE barcode = s.barcode; 
  END LOOP;
end;
--------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE ala_to_bulk 
	is
	existing_num number;
	cnt NUMBER;	
BEGIN
	FOR r IN (SELECT * FROM ala_plant_imaging WHERE status = 'processing') LOOP
		existing_num := NULL;
	
		SELECT COUNT(*) INTO cnt 
		FROM coll_obj_other_id_num 
		WHERE 
			other_id_type = r.idtype AND 
			display_value = r.idnum;
	
		IF cnt > 0 THEN
			UPDATE ala_plant_imaging 
			SET status = 'pre_existing' 
			WHERE image_id = r.image_id;
		ELSE
			INSERT INTO bulkloader (
			 	COLLECTION_OBJECT_ID,
			 	ENTEREDBY,
			 	OTHER_ID_NUM_1,
			 	OTHER_ID_NUM_TYPE_1,
			 	ACCN,
			 	TAXON_NAME,
			 	NATURE_OF_ID,
			 	ID_MADE_BY_AGENT,
			 	MADE_DATE,
			 	IDENTIFICATION_REMARKS,
			 	VERBATIM_DATE,
			 	BEGAN_DATE,
			 	ENDED_DATE,
			 	LOCALITY_ID,
			 	VERBATIM_LOCALITY,
			 	COLLECTOR_AGENT_1,
			 	collector_role_1,
			 	COLLECTION_CDE,
			 	INSTITUTION_ACRONYM,
			 	COLL_OBJ_DISPOSITION,
			 	CONDITION,
			 	COLL_OBJECT_REMARKS,
			 	PART_NAME_1,
			 	PART_CONDITION_1,
			 	PART_LOT_COUNT_1,
			 	PART_DISPOSITION_1,
			 	PART_BARCODE_1,
			 	collecting_source
			 ) VALUES (
			 	bulkloader_pkey.nextval,
			 	r.WHODUNIT,
			 	r.IDNUM,
			 	r.IDTYPE,
			 	'2007.001.Herb',
			 	r.FOLDER_IDENTIFICATION,
			 	'legacy',
			 	'unknown',
			 	to_char(r.WHENDUNIT,'dd-Mon-yyyy'),
			 	'Identification taken from herbarium sheet folder.',
			 	'not recorded',
			 	'1-Jan-1800',
			 	to_char(sysdate,'dd-Mon-yyyy'),
			 	77457,
			 	'No verbatim locality recorded',
			 	'unknown',
			 	'c',
			 	'Herb',
			 	'UAM',
			 	'in collection',
			 	'unchecked',
			 	'Entered by ALA Imaging Project - more data will be available after images are scanned.',
			 	'whole organism',
			 	'unchecked',
			 	1,
			 	'in collection',
			 	r.barcode,
			 	'wild caught');	

			UPDATE ala_plant_imaging 
			SET status = 'loaded' 
			WHERE image_id = r.image_id;
		END IF;
	END LOOP;
END;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE set_exist_location 
	is
	begin
	execute immediate 'alter trigger MOVE_CONTAINER disable';
	FOR r IN (SELECT * FROM ala_plant_imaging WHERE status = 'pre_existing') LOOP
		--dbms_output.put_line('--------------------------------------------------------------------------------------------');

		SELECT container_id INTO cid 
		FROM container 
		WHERE barcode = r.barcode;
		--dbms_output.put_line('cid: ' || cid);
		-- cid is the container for the SHEET
		
		SELECT container_id INTO pcid 
		FROM container 
		WHERE barcode = r.folder_barcode;
		--dbms_output.put_line('pcid: ' || pcid);
		-- pcid is the container for the FOLDER
		
		UPDATE container 
		SET parent_container_id = pcid 
		WHERE container_id = cid;
		--put THE sheet into THE folder

		SELECT MIN(specimen_part.collection_object_id) INTO part_id 
		FROM
			specimen_part,
			coll_obj_other_id_num
		WHERE
			specimen_part.derived_from_cat_item = coll_obj_other_id_num.collection_object_id AND
			coll_obj_other_id_num.other_id_type = r.idtype AND
			coll_obj_other_id_num.display_value = r.idnum;
		--dbms_output.put_line('part_id: ' || part_id); 
		SELECT container_id INTO part_container_id 
		FROM coll_obj_cont_hist 
		WHERE collection_object_id = part_id;
		--dbms_output.put_line('part_container_id: ' || part_container_id); 

		UPDATE container 
		SET parent_container_id = cid 
		WHERE container_id = part_container_id;
		-- put the PART into the SHEET
		
		UPDATE ala_plant_imaging 
		SET status = 'pre_existing_containerized' 
		WHERE image_id = r.image_id;
	END LOOP;
	execute immediate 'alter trigger MOVE_CONTAINER enable';
	exception
		when others then
			execute immediate 'alter trigger MOVE_CONTAINER enable';
			dbms_output.put_line('exception: ' || sqlerrm);
end;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE set_loaded_location 
	is
	begin
		--dbms_output.put_line('hi there');
		execute immediate 'alter trigger MOVE_CONTAINER disable';
		FOR r IN (SELECT * FROM ala_plant_imaging WHERE status = 'loaded') LOOP
		
		select count(*) into still_waiting
		from coll_obj_other_id_num where
		other_id_type=trim(r.idtype) and
		display_value=trim(r.idnum);
		/*
		
        			select count(*) 
		from coll_obj_other_id_num where
		other_id_type=trim('ALAAC') and
		display_value=trim('148464');
		*/
		
		/*
		IF still_waiting = 0 THEN
		    dbms_output.put_line('r.idnum:' || r.idnum || '; ' || r.idtype || ';');
		END IF;
		*/
		if still_waiting = 1 then
			got_issues := NULL;
			SELECT COUNT(*) INTO num
    			FROM container 
    			WHERE barcode = r.barcode;
			IF num != 1 THEN
			    got_issues := 'barcode not in container';
			END IF;
			 SELECT COUNT(*) INTO num
        			FROM container 
        			WHERE barcode = r.folder_barcode;
        	IF num != 1 THEN
			    got_issues := 'folder_barcode not in container';
			END IF; 
		    SELECT count(*) INTO num 
    			FROM
    				specimen_part,
    				coll_obj_other_id_num
    			WHERE
    				specimen_part.derived_from_cat_item = coll_obj_other_id_num.collection_object_id AND
    				coll_obj_other_id_num.other_id_type = r.idtype AND
    				coll_obj_other_id_num.display_value = r.idnum;
    	    IF num != 1 THEN
			    got_issues := 'specimen_part container not found';
			END IF;
			IF got_issues IS NULL THEN
   	            SELECT container_id INTO cid
           			FROM container 
           			WHERE barcode = r.barcode;
    			--dbms_output.put_line('r.idnum: ' || r.idnum);
	    		dbms_output.put_line('cid: ' || cid);
		    	SELECT container_id INTO pcid 
    		    	FROM container 
    			    WHERE barcode = r.folder_barcode;
			    dbms_output.put_line('pcid: ' || pcid);
			    UPDATE container 
			        SET parent_container_id = pcid 
			        WHERE container_id = cid;
	    		SELECT MIN(specimen_part.collection_object_id) INTO part_id 
		        	FROM
				        specimen_part,
				        coll_obj_other_id_num
			        WHERE
				        specimen_part.derived_from_cat_item = coll_obj_other_id_num.collection_object_id AND
				        coll_obj_other_id_num.other_id_type = r.idtype AND
				        coll_obj_other_id_num.display_value = r.idnum;
			    --dbms_output.put_line('part_id: ' || part_id);
			    --dbms_output.put_line('r.idtype: ' || r.idtype);
			    --dbms_output.put_line('r.idnum: ' || r.idnum);
			    SELECT container_id INTO part_container_id 
			        FROM coll_obj_cont_hist
			        WHERE collection_object_id = part_id;
	    		UPDATE container 
		        	SET parent_container_id = cid 
			        WHERE container_id = part_container_id;
				UPDATE ala_plant_imaging 
			        SET status = 'loaded_containerized' 
			        WHERE image_id = r.image_id;
			ELSE
			    UPDATE ala_plant_imaging 
			        SET status = 'loaded:' || got_issues 
			        WHERE image_id = r.image_id;
			END IF;
		elsif still_waiting > 1 then
			UPDATE ala_plant_imaging 
			SET status = 'dup_ala_num_in_arctos' 
			WHERE image_id = r.image_id;
		ELSE
		    UPDATE ala_plant_imaging 
			SET status = 'loaded_not_found: ' || still_waiting
			WHERE image_id = r.image_id;
		end if;
		
	END LOOP;
	execute immediate 'alter trigger MOVE_CONTAINER enable';
	exception
		when others then
			execute immediate 'alter trigger MOVE_CONTAINER enable';
			dbms_output.put_line('exception: ' || sqlerrm);
end;
---------------------------------------------------------------------------------------------------------------------------------------------
end;
/	

--    exec ala.show_sql;



/*

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'sch_ala_procedures',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'ala.run_all',
		start_date		=> to_timestamp_tz('16-FEB-2008 19:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'FREQ=DAILY',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'Fix ALA Imaging stuff');
END;
/

*/