exec reset_ala_status;
exec set_ala_status;

select status,count(*) from ala_plant_imaging group by status;

exec ala_to_bulk;

/*
 update bulkloader set loaded = null where collection_cde = 'Herb';
*/

create or replace procedure ala_fix_containers IS
	cid NUMBER;
	pcid NUMBER;
	part_id NUMBER;
	part_container_id NUMBER;
begin
	FOR r IN (SELECT barcode, folder_identification 
				FROM ala_plant_imaging
				WHERE status IN ('loaded', 'pre_existing')
				GROUP BY barcode, folder_identification) LOOP
		UPDATE container
		SET
			container_type = 'herbarium folder',
			label = r.folder_identification
		WHERE barcode = r.barcode; 
	END LOOP;													

	FOR r IN (SELECT * FROM ala_plant_imaging WHERE status = 'loaded') LOOP
		SELECT container_id INTO cid
		FROM container 
		WHERE barcode = r.barcode;
		
		SELECT container_id INTO pcid 
		FROM container 
		WHERE barcode = r.folder_barcode;
		
		UPDATE container 
		SET container_type = 'herbarium sheet'
		WHERE container_id = cid;
		
		COMMIT;
		
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
	END LOOP;

	FOR r IN (SELECT * FROM ala_plant_imaging WHERE status = 'pre_existing') LOOP
		SELECT container_id INTO cid 
		FROM container 
		WHERE barcode = r.barcode;
		
		SELECT container_id INTO pcid 
		FROM container 
		WHERE barcode = r.folder_barcode;
		
		UPDATE container 
		SET container_type = 'herbarium sheet' 
		WHERE container_id = cid;
		
		COMMIT;
		
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
			 
		SELECT container_id INTO part_container_id 
		FROM coll_obj_cont_hist 
		WHERE collection_object_id = part_id;
		
		UPDATE container 
		SET parent_container_id = cid 
		WHERE container_id = part_container_id;
		
		UPDATE ala_plant_imaging 
		SET status = 'pre_existing_containerized' 
		WHERE image_id = r.image_id;
	END LOOP;
END;
/
sho err

exec ala_to_bulk;

CREATE OR REPLACE PROCEDURE ala_to_bulk IS
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
/
sho err

CREATE OR REPLACE PROCEDURE reset_ala_status IS
BEGIN

END;
/

CREATE OR REPLACE PROCEDURE t IS
BEGIN
	NULL;
END;
/

CREATE OR REPLACE PROCEDURE set_ala_status IS
BEGIN
    	UPDATE ala_plant_imaging 
	SET status = NULL
	WHERE status = 'bad_alaac_number';
	
	UPDATE ala_plant_imaging 
	SET status = NULL
	WHERE status = 'dup_ala_num';
	
	UPDATE ala_plant_imaging 
	SET status = NULL
	WHERE status = 'bad_folder_barcode';
	
	UPDATE ala_plant_imaging 
	SET status = NULL
	WHERE status = 'bad_folder_id';
	
	UPDATE ala_plant_imaging 
	SET status = NULL
	WHERE status = 'bad_barcode';
	
	UPDATE ala_plant_imaging 
	SET status = NULL
	WHERE status = 'bad_entered_by';
	
	UPDATE ala_plant_imaging 
	SET status = 'processing'
	WHERE status IS null;
	 
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
	SET status = 'bad_alaac_number'
	WHERE 
		idtype = 'ALAAC' AND
		is_number(REPLACE(idnum,'V')) = 0 OR
		(
			(
				idnum NOT LIKE 'V%' AND
				to_number(REPLACE(idnum,'V')) > 99065
			) OR
			(
				idnum LIKE 'V%' AND
				to_number(REPLACE(idnum,'V')) < 68725 OR
				to_number(REPLACE(idnum,'V')) > 200000
			 )
		 )
		 AND status = 'processing';
END;
/
sho err

exec dbms_scheduler.drop_job('ALA_STATUS', TRUE);
 
BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'ala_status',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'set_ala_status',
		start_date		=> to_timestamp_tz('30-MAY-2007 19:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval => 'FREQ=DAILY',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'Flag ALA records for further processing');
END;
/

exec dbms_scheduler.drop_job('SCHED_ALA_TO_BULK', TRUE);

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'sched_ala_to_bulk',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'ala_to_bulk',
		start_date		=> to_timestamp_tz('30-MAY-2007 20:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'FREQ=DAILY',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'Move screened ALA records to the bulkloader');
END;
/

exec dbms_scheduler.drop_job('SCH_ALA_FIX_CONTAINERS', TRUE);

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'sch_ala_fix_containers',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'ala_fix_containers',
		start_date		=> to_timestamp_tz('30-MAY-2007 05:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'FREQ=DAILY',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'Fix containers and folders');
END;
/