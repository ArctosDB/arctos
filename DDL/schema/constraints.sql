
ALTER TABLE cataloged_item ADD PRIMARY KEY (collection_object_id);

alter table project add primary key (project_id);
alter table agent_name add primary key (agent_name_id);

ALTER TABLE binary_object
add CONSTRAINT pk_binary_object
  PRIMARY  KEY (collection_object_id);
  
 ALTER TABLE binary_object
add CONSTRAINT fk_binary_object
  FOREIGN KEY (DERIVED_FROM_COLL_OBJ)
  REFERENCES binary_object(collection_object_id);
  

  
  
ALTER TABLE cataloged_item
add CONSTRAINT fk_collecting_event
  FOREIGN KEY (collecting_event_id)
  REFERENCES collecting_event(collecting_event_id);

ALTER TABLE cataloged_item
add CONSTRAINT fk_coll_object
  FOREIGN KEY (collection_object_id)
  REFERENCES coll_object(collection_object_id);
  

ALTER TABLE cataloged_item
add CONSTRAINT fk_collection
  FOREIGN KEY (COLLECTION_ID)
  REFERENCES collection(COLLECTION_ID);

ALTER TABLE cataloged_item
add CONSTRAINT pos_cat_num CHECK (cat_num > 0);

ALTER TABLE collection ADD PRIMARY KEY (COLLECTION_ID); 

ALTER TABLE collecting_event ADD PRIMARY KEY (collecting_event_id); 

ALTER TABLE coll_object ADD PRIMARY KEY (collection_object_id); 

ALTER TABLE publication ADD PRIMARY KEY (publication_id); 

ALTER TABLE citation ADD PRIMARY KEY (collection_object_id,publication_id); 

ALTER TABLE citation
add CONSTRAINT fk_cit_cat_item
  FOREIGN KEY (collection_object_id)
  REFERENCES cataloged_item(collection_object_id);

ALTER TABLE collecting_event
add CONSTRAINT fk_LOCALITY_ID
  FOREIGN KEY (LOCALITY_ID)
  REFERENCES LOCALITY(LOCALITY_ID);  
  
 ALTER TABLE citation
add CONSTRAINT fk_cit_publication
  FOREIGN KEY (publication_id)
  REFERENCES publication(publication_id);

   ALTER TABLE collector
add CONSTRAINT fk_coll_cat_item
  FOREIGN KEY (COLLECTION_OBJECT_ID)
  REFERENCES cataloged_item(COLLECTION_OBJECT_ID);

     ALTER TABLE collector
add CONSTRAINT fk_coll_agent
  FOREIGN KEY (AGENT_ID)
  REFERENCES AGENT(AGENT_ID);

       ALTER TABLE Specimen_Part
add CONSTRAINT fk_coll_obj_part
  FOREIGN KEY (COLLECTION_OBJECT_ID)
  REFERENCES coll_object(COLLECTION_OBJECT_ID);

 ALTER TABLE Specimen_Part
add CONSTRAINT fk_part_cat_item
  FOREIGN KEY (derived_from_cat_item)
  REFERENCES cataloged_item(COLLECTION_OBJECT_ID);

   

  
ALTER TABLE trans ADD PRIMARY KEY (transaction_id); 
ALTER TABLE accn
add CONSTRAINT fk_accn_trans
  FOREIGN KEY (transaction_id)
  REFERENCES trans(transaction_id);
ALTER TABLE trans
add CONSTRAINT fk_TRANS_ENTERED_AGENT_ID
  FOREIGN KEY (TRANS_ENTERED_AGENT_ID)
  REFERENCES agent(agent_id);

  ALTER TABLE trans
add CONSTRAINT fk_RECEIVED_AGENT_ID
  FOREIGN KEY (RECEIVED_AGENT_ID)
  REFERENCES agent(agent_id);

  ALTER TABLE trans
add CONSTRAINT fk_TRANS_AGENCY_ID
  FOREIGN KEY (TRANS_AGENCY_ID)
  REFERENCES agent(agent_id);

 ALTER TABLE trans
add CONSTRAINT fk_AUTH_AGENT_ID
  FOREIGN KEY (AUTH_AGENT_ID)
  REFERENCES agent(agent_id);
    
ALTER TABLE trans
add CONSTRAINT trans_TRANSACTION_TYPE CHECK (TRANSACTION_TYPE IN ('accn','loan','borrow'));
 
ALTER TABLE publication
add CONSTRAINT pub_pub_type_cons CHECK (publication_type IN ('Journal Article','Book Section','Book'));

ALTER TABLE trans
add CONSTRAINT trans_CORRESP_FG CHECK (CORRESP_FG IN (0,1));

 ALTER TABLE locality
add CONSTRAINT min_more_max_elev CHECK (MINIMUM_ELEVATION <= MAXIMUM_ELEVATION);

/*

ALTER TABLE locality
add CONSTRAINT all_or_none_elev CHECK (
	(MINIMUM_ELEVATION IS NULL AND MAXIMUM_ELEVATION IS NULL AND ORIG_ELEV_UNITS IS NULL)
	OR
	(MINIMUM_ELEVATION IS NOT NULL AND MAXIMUM_ELEVATION IS NOT NULL AND ORIG_ELEV_UNITS IS NOT NULL));
ORA-02293: cannot validate (UAM.ALL_OR_NONE_ELEV) - check constraint violated	
select count(*) from locality where mINIMUM_ELEVATION IS NULL or MAXIMUM_ELEVATION IS NULL AND ORIG_ELEV_UNITS IS not NULL;
*/

ALTER TABLE locality
add CONSTRAINT min_more_max_depth CHECK (MIN_DEPTH <= MAX_DEPTH);

CREATE OR REPLACE TRIGGER relationship_ct_check
before UPDATE or INSERT ON biol_indiv_relations
for each row
declare
numrows number;
BEGIN
SELECT COUNT(*) INTO numrows FROM ctbiol_relations WHERE BIOL_INDIV_RELATIONSHIP = :NEW.BIOL_INDIV_RELATIONSHIP;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid BIOL_INDIV_RELATIONSHIP'
	      );
	END IF;
END;
/
alter table biol_indiv_relations drop constraint fk_related_item;
ALTER TABLE biol_indiv_relations
add CONSTRAINT fk_related_item
  FOREIGN KEY (collection_object_id)
  REFERENCES cataloged_item(collection_object_id);
  
  alter table biol_indiv_relations drop constraint fk_related_to_item;
ALTER TABLE biol_indiv_relations
add CONSTRAINT fk_related_to_item
  FOREIGN KEY (RELATED_COLL_OBJECT_ID)
  REFERENCES cataloged_item(collection_object_id);

create unique index u_higher_geog on geog_auth_rec (higher_geog);
ALTER TABLE geog_auth_rec ADD PRIMARY KEY (geog_auth_rec_id);
ALTER TABLE locality ADD PRIMARY KEY (locality_id);

ALTER TABLE locality
add CONSTRAINT fk_geog
  FOREIGN KEY (geog_auth_rec_id)
  REFERENCES geog_auth_rec(geog_auth_rec_id);

CREATE OR REPLACE TRIGGER locality_ct_check
before UPDATE or INSERT ON locality
for each row
declare
numrows number;
BEGIN
	IF (:new.orig_elev_units is not null) THEN
		SELECT COUNT(*) INTO numrows FROM ctorig_elev_units WHERE orig_elev_units = :NEW.orig_elev_units;
		IF (numrows = 0) THEN
			 raise_application_error(
		        -20001,
		        'Invalid orig_elev_units'
		      );
		END IF;
	END IF;
	IF (:new.DEPTH_UNITS is not null) THEN
		SELECT COUNT(*) INTO numrows FROM ctdepth_units WHERE DEPTH_UNITS = :NEW.DEPTH_UNITS;
		IF (numrows = 0) THEN
			 raise_application_error(
		        -20001,
		        'Invalid DEPTH_UNITS'
		      );
		END IF;
	END IF;
END;
/
sho err

ALTER TABLE lat_long ADD PRIMARY KEY (lat_long_id); 





CREATE OR REPLACE TRIGGER lat_long_ct_check
before UPDATE or INSERT ON lat_long
for each row
declare
numrows number;
BEGIN
	SELECT COUNT(*) INTO numrows FROM ctVERIFICATIONSTATUS WHERE VERIFICATIONSTATUS = :NEW.VERIFICATIONSTATUS;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid VERIFICATIONSTATUS'
	      );
	END IF;
	SELECT COUNT(*) INTO numrows FROM ctGEOREFMETHOD WHERE GEOREFMETHOD = :NEW.GEOREFMETHOD;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid GEOREFMETHOD'
	      );
	END IF;
	SELECT COUNT(*) INTO numrows FROM ctdatum WHERE datum = :NEW.datum;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid datum'
	      );
	END IF;
	SELECT COUNT(*) INTO numrows FROM ctlat_long_units WHERE orig_lat_long_units = :NEW.orig_lat_long_units;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid orig_lat_long_units'
	      );
	END IF;
	IF (:NEW.MAX_ERROR_UNITS is not null) THEN
		SELECT COUNT(*) INTO numrows FROM ctlat_long_error_units WHERE LAT_LONG_ERROR_UNITS = :NEW.MAX_ERROR_UNITS;
		IF (numrows = 0) THEN
			 raise_application_error(
		        -20001,
		        'Invalid MAX_ERROR_UNITS'
		      );
		END IF;
	END IF;
	IF (:NEW.MAX_ERROR_UNITS is not null) THEN
		SELECT COUNT(*) INTO numrows FROM ctlat_long_error_units WHERE LAT_LONG_ERROR_UNITS = :NEW.gps_distance_units;
		IF (numrows = 0) THEN
			 raise_application_error(
		        -20001,
		        'Invalid gps_distance_units.'
		      );
		END IF;
	END IF;	
	IF (:NEW.orig_lat_long_units = 'decimal degrees') THEN
		IF (:NEW.dec_lat is null OR :NEW.dec_long is null) THEN
			raise_application_error(
		        -20001,
		        'dec_lat and dec_long are required when orig_lat_long_units is decimal degrees'
	      	);
	    END IF;	   
	ELSIF (:NEW.orig_lat_long_units = 'deg. min. sec.') THEN
		IF (:NEW.LAT_DEG is null OR :NEW.LAT_DIR is null OR :NEW.LONG_DEG is null OR :NEW.LONG_DIR is null) THEN
			raise_application_error(
		        -20001,
		        'Insufficient information to create new coordinates with degrees minutes seconds'
	      	);
		END IF;
	ELSIF (:NEW.orig_lat_long_units = 'degrees dec. minutes') THEN
		IF (:NEW.LAT_DEG is null OR :NEW.LAT_DIR is null OR :NEW.LONG_DEG is null OR :NEW.LONG_DIR is null) THEN
			raise_application_error(
		        -20001,
		        'Insufficient information to create new coordinates with degrees dec. minutes'
	      	);
		END IF;
	ELSIF (:NEW.orig_lat_long_units = 'UTM') THEN
		IF (:NEW.utm_ew is null OR :NEW.utm_ns is null OR :NEW.utm_zone is null) THEN
			raise_application_error(
		        -20001,
		        'Insufficient information to create new coordinates with UTM'
	      	);
		END IF;	
	ELSE
		raise_application_error(
		        -20001,
		        :NEW.orig_lat_long_units || ' is not handled. Please contact your database administrator.'
	      	);
	END IF;    	
END;
/
sho err
drop trigger attribute_ct_check;
CREATE OR REPLACE TRIGGER attribute_ct_check
before UPDATE or INSERT ON attributes
for each row
declare
numrows number := 0;
collectionCode varchar2(4);
sqlString varchar2(4000);
vct varchar2(255);
uct varchar2(255);
ctctColname varchar2(255);
ctctCollCde number :=0;
no_problem_go_away exception;
BEGIN
	select collection.collection_cde into collectionCode from collection,cataloged_item where 
		collection.collection_id = cataloged_item.collection_id and cataloged_item.collection_object_id = :NEW.collection_object_id;
	--dbms_output.put_line ('collectionCode: ' || collectionCode);
	SELECT COUNT(*) INTO numrows FROM ctattribute_type WHERE attribute_type = :NEW.attribute_type AND collection_cde =collectionCode; 
	--dbms_output.put_line ('numrows FROM ctattribute_type: ' || numrows);
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid attribute_type'
	      );
	END IF;
	select count(*) into numrows FROM ctattribute_code_tables WHERE attribute_type = :NEW.attribute_type;
	IF (numrows = 0) THEN
		-- this is NOT controlled - they can put anything they want in value, but units must be null
		if :new.attribute_units is not null then
			 raise_application_error(
		        -20001,
		        'This attribute cannot have units'
		      );
		else
			RAISE no_problem_go_away;
		end if;
	END IF;
	-- one or the other if we made it to here
	SELECT upper(VALUE_CODE_TABLE),upper(UNITS_CODE_TABLE) INTO vct,uct FROM ctattribute_code_tables WHERE attribute_type = :NEW.attribute_type;
	IF (vct is not null) THEN
		 --dbms_output.put_line ('there is a value code table');
		-- get the code table column name
		select column_name into ctctColname from user_tab_columns where upper(table_name) = vct  and upper(column_name) <>'COLLECTION_CDE' and upper(column_name) <>'DESCRIPTION';
		--dbms_output.put_line (ctctColname);
		-- see if there's a collection_cde column; 1=yes, 0=default=no
		select count(*) into ctctCollCde from user_tab_columns where upper(table_name) = vct and column_name='COLLECTION_CDE';
		--dbms_output.put_line (ctctCollCde);
		IF (ctctCollCde = 1) THEN
			--dbms_output.put_line ('there is a collection code for this attribute');
			sqlString := 'select count(*)  from ' || vct || ' WHERE ' || ctctColname || ' = ''' || :NEW.ATTRIBUTE_VALUE || ''' and collection_cde= ''' || collectionCode  || '''';
			execute immediate sqlstring into numrows;
			IF (numrows = 0) THEN
				 raise_application_error(
			        -20001,
			        'Invalid ATTRIBUTE_VALUE for ATTRIBUTE_TYPE in this collection'
			      );
			END IF;
		ELSE
			-- no collection code
			sqlString := 'select count(*)  from ' || vct || ' WHERE ' || ctctColname || ' = ''' || :NEW.ATTRIBUTE_VALUE || '''';
			execute immediate sqlstring into numrows;
			IF (numrows = 0) THEN
				 raise_application_error(
			        -20001,
			        'Invalid ATTRIBUTE_VALUE for ATTRIBUTE_TYPE in this collection'
			      );
			END IF;
		END IF;
	ELSIF (uct is not null) THEN
		--dbms_output.put_line('controlled units');
		select column_name into ctctColname from user_tab_columns where upper(table_name) = uct and upper(column_name) <>'COLLECTION_CDE' and upper(column_name) <>'DESCRIPTION';
		--dbms_output.put_line (ctctColname);
		-- these will never be collection-specific, according to me
		sqlString := 'select count(*)  from ' || uct || ' WHERE ' || ctctColname || ' = ''' || :NEW.ATTRIBUTE_UNITS || '''';
		execute immediate sqlstring into numrows;
		IF (numrows = 0) THEN
			 raise_application_error(
		        -20001,
		        'Invalid ATTRIBUTE_UNITS'
		      );
		END IF;
	END IF;
EXCEPTION
	WHEN no_problem_go_away THEN
	-- do something or it'll complain
	NULL;
	-- dbms_output.put_line('bla');
END;
/
sho err
 
 
ALTER TABLE lat_long
add CONSTRAINT fk_locality
  FOREIGN KEY (locality_id)
  REFERENCES locality(locality_id);

ALTER TABLE agent ADD constraint bob PRIMARY KEY (agent_id); 
  
ALTER TABLE lat_long
add CONSTRAINT fk_determinre
  FOREIGN KEY (DETERMINED_BY_AGENT_ID)
  REFERENCES agent(agent_id);


ALTER TABLE lat_long
add CONSTRAINT dec_lat_range CHECK (dec_lat BETWEEN -90 AND 90);
-- select locality_id  from lat_long where dec_lat > 90;
ALTER TABLE lat_long
add CONSTRAINT dec_long_range CHECK (dec_long BETWEEN -180 AND 180);
--select locality_id from lat_long where dec_long >180;
ALTER TABLE lat_long
add CONSTRAINT lat_deg_range CHECK (lat_deg BETWEEN 0 AND 90);
ALTER TABLE lat_long
add CONSTRAINT DEC_LAT_MIN_range CHECK (DEC_LAT_MIN >= 0 AND DEC_LAT_MIN < 60);
--select count(*) from lat_long where DEC_LAT_MIN < 0;
--select count(*) from lat_long where DEC_LAT_MIN >=60;
ALTER TABLE lat_long
add CONSTRAINT LAT_MIN_range CHECK (LAT_MIN >= 0 AND LAT_MIN < 60);
ALTER TABLE lat_long
add CONSTRAINT LAT_SEC_range CHECK (LAT_SEC >= 0 AND LAT_SEC < 60);
ALTER TABLE lat_long
add CONSTRAINT LAT_DIR_range CHECK (LAT_DIR IN ('N','S'));
ALTER TABLE lat_long
add CONSTRAINT LONG_DEG_range CHECK (LONG_DEG BETWEEN 0 AND 180);
select count(*) from lat_long where LONG_DEG <=0;
ALTER TABLE lat_long
add CONSTRAINT DEC_LONG_MIN_range CHECK (DEC_LONG_MIN >= 0 AND DEC_LONG_MIN < 60);
select count(*) from lat_long where DEC_LONG_MIN >=60;
ALTER TABLE lat_long
add CONSTRAINT LONG_MIN_range CHECK (LONG_MIN >= 0 AND LONG_MIN < 60);
select count(*) from lat_long where LONG_MIN >=60;
ALTER TABLE lat_long
add CONSTRAINT LONG_SEC_range CHECK (LONG_SEC >= 0 AND LONG_SEC < 60);
ALTER TABLE lat_long
add CONSTRAINT ACCEPTED_LAT_LONG_FG_range CHECK (ACCEPTED_LAT_LONG_FG IN (0,1));

CREATE OR REPLACE TRIGGER coll_object_ct_check
before UPDATE or INSERT ON coll_object
for each row
declare
numrows number;
BEGIN
	SELECT COUNT(*) INTO numrows FROM ctcoll_obj_disp WHERE coll_obj_disposition = :NEW.coll_obj_disposition;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid coll_obj_disposition: ' || :NEW.coll_obj_disposition
	      );
	END IF;
	 	
END;
/
sho err

		
CREATE OR REPLACE TRIGGER identification_ct_check
before UPDATE or INSERT ON identification
for each row
declare
numrows number;
BEGIN
	SELECT COUNT(*) INTO numrows FROM ctnature_of_id WHERE nature_of_id = :NEW.nature_of_id;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid nature_of_id'
	      );
	END IF;
	 	
END;
/
sho err

ALTER TABLE identification_agent add CONSTRAINT fk_id_identi_id
 FOREIGN KEY (identification_id)
 REFERENCES identification (identification_id);
ALTER TABLE identification_agent add CONSTRAINT fk_id_agnt_id
 FOREIGN KEY (agent_id)
 REFERENCES agent (agent_id);


ALTER TABLE taxonomy ADD PRIMARY KEY (taxon_name_id); 
ALTER TABLE identification ADD PRIMARY KEY (identification_id); 


ALTER TABLE identification_taxonomy
add CONSTRAINT fk_taxonomy
  FOREIGN KEY (taxon_name_id)
  REFERENCES taxonomy(taxon_name_id);

ALTER TABLE identification_taxonomy
add CONSTRAINT fk_identification
  FOREIGN KEY (identification_id)
  REFERENCES identification(identification_id);

 alter table attributes drop constraint fk_cataloged_item;
   ALTER TABLE attributes
add CONSTRAINT fk_cataloged_item
  FOREIGN KEY (collection_object_id)
  REFERENCES cataloged_item(collection_object_id);
	
  ALTER TABLE attributes
add CONSTRAINT fk_DETERMINED_BY_AGENT_ID
  FOREIGN KEY (DETERMINED_BY_AGENT_ID)
  REFERENCES agent(agent_id);
  
ALTER TABLE attributes ADD PRIMARY KEY (attribute_id); 
  
drop trigger other_id_ct_check;

 alter table cataloged_item modify COLLECTION_CDE varchar2(4);

CREATE OR REPLACE TRIGGER other_id_ct_check
	before UPDATE or INSERT ON coll_obj_other_id_num
	for each row
	declare
	numrows number;
	collectionCode varchar2(20);
BEGIN
	select collection.collection_cde into collectionCode from collection,cataloged_item where 
		collection.collection_id = cataloged_item.collection_id and cataloged_item.collection_object_id = :NEW.collection_object_id;
	execute immediate 'SELECT COUNT(*) FROM ctcoll_other_id_type 
		WHERE other_id_type = ''' || :NEW.other_id_type || '''
		AND collection_cde = ''' || collectionCode || '''' INTO numrows ; 
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid other ID type (' || :NEW.other_id_type || ') for collection_cde ' || collectionCode || '.'
	      );
	END IF;
END;
/
sho err


		--dbms_output.put_line('select collection.collection_cde from collection,cataloged_item where collection.collection_id = cataloged_item.collection_id and cataloged_item.collection_object_id = ' || :NEW.collection_object_id);
		--dbms_output.put_line('SELECT COUNT(*) FROM ctcoll_other_id_type WHERE other_id_type = ' || :NEW.other_id_type || '
		--AND collection_cde = ' || collectionCode);
		--dbms_output.put_line(':'||collectionCode||':');
		--dbms_output.put_line(':'||:NEW.other_id_type||':');
		--dbms_output.put_line('numrows: '||numrows);









ALTER TABLE identification
add CONSTRAINT fk_id_determiner
  FOREIGN KEY (ID_MADE_BY_AGENT_ID)
  REFERENCES agent(agent_id);

ALTER TABLE collector
add CONSTRAINT coll_role_check CHECK (COLLECTOR_ROLE IN ('c','p'));

CREATE OR REPLACE TRIGGER specimen_part_ct_check
	before UPDATE or INSERT ON specimen_part
	for each row
	declare
	numrows number;
	collectionCode varchar2(4);
BEGIN
	select collection.collection_cde into collectionCode from collection,cataloged_item where 
		collection.collection_id = cataloged_item.collection_id and cataloged_item.collection_object_id = :NEW.derived_from_cat_item;
	SELECT COUNT(*) INTO numrows FROM ctspecimen_part_name WHERE part_name = :NEW.part_name AND collection_cde =collectionCode; 
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid part name'
	      );
	END IF;
	IF (:new.PART_MODIFIER is not null) THEN
		SELECT COUNT(*) INTO numrows FROM ctspecimen_part_modifier WHERE PART_MODIFIER = :NEW.PART_MODIFIER; 
		IF (numrows = 0) THEN
			 raise_application_error(
		        -20001,
		        'Invalid PART_MODIFIER'
		      );
		END IF;
	END IF;
END;
/

CREATE OR REPLACE TRIGGER collecting_event_ct_check
before UPDATE or INSERT ON collecting_event
for each row
declare
numrows number;
BEGIN
SELECT COUNT(*) INTO numrows FROM ctcollecting_source WHERE collecting_source = :NEW.collecting_source;
	IF (numrows = 0) THEN
		 raise_application_error(
	        -20001,
	        'Invalid collecting_source'
	      );
	END IF;
END;
/	