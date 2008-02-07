CREATE OR REPLACE TRIGGER bulk_stage_check
before UPDATE or INSERT ON bulkloader_stage
for each row
declare
thisError varchar2(4000);
 numRecs NUMBER;
 justAString varchar2(255);
 attributeType varchar2(255);
 attributeValue varchar2(255);
  attributeUnits varchar2(255);
 attributeDate varchar2(255);
 attributeDeterminer varchar2(255);
 attributeValueTable varchar2(255);
 attributeUnitsTable varchar2(255);
  attributeCodeTableColName varchar2(255);
 partName  varchar2(255);
 partModifier  varchar2(255);
 preservMethod  varchar2(255);
 partCondition  varchar2(255);
 partBarcode  varchar2(255);
 partContainerLabel  varchar2(255);
 partLotCount  varchar2(255);
 partDisposition  varchar2(255);
 otherIdType varchar2(255);
 otherIdNum varchar2(255);
 collectorName varchar2(255);
 collectorRole  varchar2(255);
BEGIN
	thisError := '';
		select count(distinct(agent_id)) into numRecs from agent_name where agent_name = :NEW.ENTEREDBY;
		if (numRecs != 1) then
			thisError :=  thisError || '; ENTEREDBY matches ' || numRecs || ' agents';
		END IF;
		select count(*) into numRecs from collection where
					institution_acronym = :NEW.institution_acronym and
					collection_cde=:NEW.collection_cde;
		IF (numRecs = 0) THEN
			thisError :=  thisError || '; institution_acronym and/or collection_cde is invalid';
		END IF;
		IF (:NEW.cat_num is not null) THEN
			select count(*) into numRecs from collection,cataloged_item where
				collection.collection_id = cataloged_item.collection_id AND
				collection.institution_acronym = :NEW.institution_acronym and
				collection.collection_cde=:NEW.collection_cde AND
				cat_num=:NEW.cat_num;
			IF (numRecs > 0) THEN
				thisError :=  thisError || '; cat_num is invalid';
			END IF;
		END IF;
		IF (:NEW.cat_num = 0) THEN
			thisError :=  thisError || '; cat_num may not be 0';
		END IF;
		IF (isdate(:NEW.began_date)=0 OR :NEW.began_date is null) THEN
			thisError :=  thisError || '; began_date is invalid';
		END IF;
		IF (isdate(:NEW.ended_date)=0 OR :NEW.ended_date is null) THEN
			thisError :=  thisError || '; ended_date is invalid';
		END IF;
		IF (:NEW.verbatim_date is null) THEN
			thisError :=  thisError || '; verbatim_date is invalid';
		END IF;
		IF (:NEW.relationship is not null) THEN
			IF (:NEW.related_to_num_type is null OR :NEW.related_to_number is null) THEN
				thisError :=  thisError || '; ::related_to_number:: and ::related_to_num_type:: are required when relationship is given';
			END IF;
			select count(*) into numRecs from ctbiol_relations where
				biol_indiv_relationship =:NEW.relationship;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; relationship is invalid';
			END IF;
			select  count(*) into numRecs from ctcoll_other_id_type
				where collection_cde=:NEW.collection_cde and
				other_id_type=:NEW.related_to_num_type;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; related_to_num_type is invalid';
			END IF;
		END IF;
		SELECT count(*) INTO numRecs FROM geog_auth_rec WHERE higher_geog = :NEW.higher_geog;
		IF (numRecs != 1) THEN
			thisError :=  thisError || '; geog_auth_rec matched ' || numRecs || ' records';
		END IF;
		IF (isnumeric(:NEW.maximum_elevation) = 0) THEN
			thisError :=  thisError || '; maximum_elevation is invalid';
		END IF;	
		IF (
			(:NEW.maximum_elevation is not null AND :NEW.minimum_elevation is null) OR
			(:NEW.minimum_elevation is not null AND :NEW.maximum_elevation is null) OR
			((:NEW.minimum_elevation is not null OR :NEW.maximum_elevation is not null) AND :NEW.orig_elev_units is null)
			) THEN
			thisError :=  thisError || '; maximum_elevation,minimum_elevation,orig_elev_units are all required if one is given';
		END IF;	
		IF (:NEW.orig_elev_units is not null) THEN
			SELECT count(*) INTO numRecs from ctorig_elev_units where orig_elev_units = :NEW.orig_elev_units;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; orig_elev_units is invalid';
			END IF;
		END IF;
		IF (:NEW.spec_locality is null) THEN
			thisError :=  thisError || '; spec_locality is required';
		END IF;
		
		IF (:NEW.orig_lat_long_units is NOT null) THEN
			SELECT count(*) INTO numRecs from ctlat_long_units where orig_lat_long_units=:NEW.orig_lat_long_units;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; orig_lat_long_units is invalid';
			END IF;
			
			IF (:NEW.orig_lat_long_units = 'decimal degrees') THEN
				IF (isnumeric(:NEW.dec_lat) = 0 OR isnumeric(:NEW.dec_long) = 0  OR 
					:NEW.dec_long < -180 OR :NEW.dec_long > 180 OR :NEW.dec_lat < -90 OR :NEW.dec_lat > 90) THEN	
					thisError :=  thisError || '; dec_lat or dec_long is invalid';
				END IF;
			ELSIF (:NEW.orig_lat_long_units = 'deg. min. sec.') THEN	
				IF (isnumeric(:NEW.latdeg) = 0 OR :NEW.latdeg < 0 OR :NEW.latdeg > 90 OR
					isnumeric(:NEW.latmin) = 0 OR :NEW.latmin < 0 OR :NEW.latmin > 60 OR
					isnumeric(:NEW.latsec) = 0 OR :NEW.latsec < 0 OR :NEW.latsec > 60 OR
					isnumeric(:NEW.longdeg) = 0 OR :NEW.longdeg < 0 OR :NEW.longdeg > 180 OR
					isnumeric(:NEW.longmin) = 0 OR :NEW.longmin < 0 OR :NEW.longmin > 60 OR
					isnumeric(:NEW.longsec) = 0 OR :NEW.longsec < 0 OR :NEW.longsec > 60) THEN
					thisError :=  thisError || '; coordinates are invalid';
				END IF;	 
				IF (:NEW.latdir <> 'N' AND :NEW.latdir <> 'S') THEN
					thisError :=  thisError || '; latdir is invalid';
				END IF;
				IF (:NEW.longdir <> 'E' AND :NEW.longdir <> 'W') THEN
					thisError :=  thisError || '; longdir is invalid';
				END IF;
			ELSIF (:NEW.orig_lat_long_units = 'degrees dec. minutes') THEN	
				IF (isnumeric(:NEW.latdeg) = 0 OR :NEW.latdeg < 0 OR :NEW.latdeg > 90 OR
					isnumeric(:NEW.dec_lat_min) = 0 OR :NEW.dec_lat_min < 0 OR :NEW.dec_lat_min > 60 OR
					isnumeric(:NEW.longdeg) = 0 OR :NEW.longdeg < 0 OR :NEW.longdeg > 180 OR
					isnumeric(:NEW.dec_long_min) = 0 OR :NEW.dec_long_min < 0 OR :NEW.dec_long_min > 60) THEN
					thisError :=  thisError || '; coordinates are invalid';
				END IF;	 
				IF (:NEW.latdir <> 'N' AND :NEW.latdir <> 'S') THEN
					thisError :=  thisError || '; latdir is invalid';
				END IF;
				IF (:NEW.longdir <> 'E' AND :NEW.longdir <> 'W') THEN
					thisError :=  thisError || '; longdir is invalid';
				END IF;
			END IF;
			SELECT count(*) INTO numRecs from ctdatum where datum =:NEW.datum;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; datum is invalid';
			END IF;
			SELECT count(distinct(agent_id)) INTO numRecs from agent_name where agent_name = :NEW.determined_by_agent
				and agent_name_type <> 'Kew abbr.';
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; determined_by_agent matches ' || numRecs || ' agents';
			END IF;
			IF (isdate(:NEW.determined_date)=0 OR :NEW.determined_date is null) THEN
				thisError :=  thisError || '; determined_date is invalid';
			END IF;
			IF (:NEW.lat_long_ref_source is null) THEN
				thisError :=  thisError || '; lat_long_ref_source is required';
			END IF;
			IF (:NEW.max_error_distance is null OR isnumeric(:NEW.max_error_distance) = 0) THEN
				thisError :=  thisError || '; max_error_distance is required and must be numeric';
			END IF;
			SELECT count(*) INTO numRecs from CTLAT_LONG_ERROR_UNITS where LAT_LONG_ERROR_UNITS = :NEW.max_error_units;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; max_error_units is invalid';
			END IF;	
			SELECT count(*) INTO numRecs from CTGEOREFMETHOD where GEOREFMETHOD = :NEW.GEOREFMETHOD;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; GEOREFMETHOD is invalid';
			END IF;
			SELECT count(*) INTO numRecs from CTVERIFICATIONSTATUS where VERIFICATIONSTATUS = :NEW.VERIFICATIONSTATUS;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; VERIFICATIONSTATUS is invalid';
			END IF;	
		END IF;
		IF (:NEW.verbatim_locality is null) THEN
			thisError :=  thisError || '; verbatim_locality is required';
		END IF;
		SELECT count(*) INTO numRecs from ctcoll_obj_disp where COLL_OBJ_DISPOSITION = :NEW.coll_obj_disposition;
		IF (numRecs = 0) THEN
			thisError :=  thisError || '; coll_obj_disposition is invalid';
		END IF;	
		IF (:NEW.condition is null) THEN
			thisError :=  thisError || '; condition is required';
		END IF;
		IF (:NEW.made_date is null OR isdate(:NEW.made_date)=0 ) THEN
			thisError :=  thisError || '; made_date is invalid';
		END IF;
		SELECT count(*) INTO numRecs from ctnature_of_id WHERE nature_of_id = :NEW.nature_of_id;
		IF (numRecs = 0) THEN
			thisError :=  thisError || '; nature_of_id is invalid';
		END IF;	
		IF (:NEW.taxon_name is null) THEN
			thisError :=  thisError || '; taxon_name is required';
		ELSE
			IF (:NEW.taxon_name LIKE '% sp.') THEN
				justAString := substr(:NEW.taxon_name,1,length(:NEW.taxon_name)-4);
			ELSIF (:NEW.taxon_name LIKE '% cf.') THEN
				justAString := substr(:NEW.taxon_name,1,length(:NEW.taxon_name)-4);
			ELSIF (:NEW.taxon_name LIKE '% _') THEN
				justAString := substr(:NEW.taxon_name,1,length(:NEW.taxon_name)-2);
			ELSE
				justAString := :NEW.taxon_name;
			END IF;
			SELECT count(*) INTO numRecs FROM taxonomy WHERE scientific_name = justAString AND valid_catalog_term_fg=1;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; taxon_name is invalid';
			END IF;	
		END IF;
		SELECT count(distinct(agent_id)) INTO numRecs from agent_name where agent_name = :NEW.ID_MADE_BY_AGENT
				and agent_name_type <> 'Kew abbr.';
		IF (numRecs = 0) THEN
			thisError :=  thisError || '; ID_MADE_BY_AGENT matches ' || numRecs || ' agents';
		END IF;
		IF (:NEW.min_depth is not null OR :NEW.max_depth is not null OR :NEW.depth_units is not null OR 
			isnumeric(:NEW.min_depth) = 0 OR isnumeric(:NEW.max_depth) = 0) THEN
			thisError :=  thisError || '; depth is invalid';
		END IF;	
		IF (:NEW.depth_units is not null) THEN
			SELECT count(*) INTO numRecs FROM ctdepth_units where depth_units=:NEW.depth_units;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; depth_units is invalid';
			END IF;
			if :NEW.MIN_DEPTH is null or is_number(:NEW.MIN_DEPTH) = 0 OR :NEW.MAX_DEPTH is null or is_number(:NEW.MAX_DEPTH) = 0 then
				thisError :=  thisError || '; MIN_DEPTH and/or MAX_DEPTH is invalid';
			END IF;
		END IF;
		for i IN 1 .. 10 LOOP -- number of attributes
			attributeValueTable := NULL;
			attributeUnitsTable := NULL;
			execute immediate 'select 
					ATTRIBUTE_' || i || ',
					 ATTRIBUTE_VALUE_' || i || ',
					ATTRIBUTE_UNITS_' || i || ',
					 ATTRIBUTE_DATE_' || i || ',
					 ATTRIBUTE_DETERMINER_' || i || '
				 from bulkloader where  collection_object_id = ' || :NEW.collection_object_id into 
				 attributeType,
				 attributeValue,
				 attributeUnits,
				 attributeDate,
				 attributeDeterminer;
				IF attributeType is not null and attributeValue is not null THEN
					SELECT count(*) INTO numRecs FROM ctattribute_type WHERE ATTRIBUTE_TYPE = attributeType AND 
					collection_cde = :NEW.collection_cde;
					IF (numRecs = 0) THEN
						thisError :=  thisError || '; ATTRIBUTE_' || i || ' is invalid';
					END IF;
					execute immediate 'SELECT count(*) FROM ctattribute_code_tables WHERE ATTRIBUTE_TYPE = ''' || attributeType || '''' INTO numRecs;
					IF (numRecs > 0) THEN
						select VALUE_CODE_TABLE,UNITS_CODE_TABLE into attributeValueTable,attributeUnitsTable
							FROM ctattribute_code_tables WHERE ATTRIBUTE_TYPE = attributeType;
						IF attributeValueTable is not null then
							execute immediate 'select count(*) from user_tab_cols where table_name = ''' ||attributeValueTable || '''
								and column_name=''COLLECTION_CDE''' into numRecs;
							execute immediate 'select column_name from user_tab_cols where table_name = ''' ||upper(attributeValueTable) || '''
								and column_name <> ''DESCRIPTION'' and column_name <> ''COLLECTION_CDE''' into attributeCodeTableColName;
							
							if numRecs = 1 then
								execute immediate 'select count(*) from ' || attributeValueTable || ' where ' || 
									attributeCodeTableColName || ' = ''' || attributeValue || ''' and collection_cde = ''' || 
									:NEW.collection_cde || '''' into numRecs;
								if numRecs = 0 then
									thisError :=  thisError || '; ATTRIBUTE_' || i || ' value is not in the code table';
								end if;
							else
								execute immediate 'select count(*) from ' || attributeValueTable || ' where ' || 
									attributeCodeTableColName || ' = ''' || attributeValue || '''' into numRecs;
								if numRecs = 0 then
									thisError :=  thisError || '; ATTRIBUTE_' || i || ' value is not in the code table';
								end if;
							end if;
						elsif attributeUnitsTable  is not null then
							execute immediate 'select count(*) from user_tab_cols where table_name = ''' || attributeUnitsTable || '''
								and column_name=''COLLECTION_CDE''' into numRecs;
							execute immediate 'select column_name from user_tab_cols where table_name = ''' ||upper(attributeUnitsTable) || '''
								and column_name <> ''DESCRIPTION'' and column_name <> ''COLLECTION_CDE''' into attributeCodeTableColName;
							if numRecs = 1 then
								execute immediate 'select count(*) from ' || attributeUnitsTable || ' where ' || 
									attributeCodeTableColName || ' = ''' || attributeUnits || ''' and collection_cde = ''' || 
									:NEW.collection_cde || '''' into numRecs;
								if numRecs = 0 then
									thisError :=  thisError || '; ATTRIBUTE_' || i || ' units is not in the code table';
								end if;
							else
								execute immediate 'select count(*) from ' || attributeUnitsTable || ' where ' || 
									attributeCodeTableColName || ' = ''' || attributeUnits || '''' into numRecs;
								if numRecs = 0 then
									thisError :=  thisError || '; ATTRIBUTE_' || i || ' units is not in the code table';
								end if;
							end if;
						END IF;	
					END IF;
					if attributeDate is null or isdate(attributeDate) =0 then
						thisError :=  thisError || '; ATTRIBUTE_DATE_' || i || ' is invalid';
					end if;
					execute immediate 'select count(distinct(agent_id)) from agent_name where agent_name = ''' || attributeDeterminer ||'''' into numRecs;
					if numRecs = 0 then
						thisError :=  thisError || '; ATTRIBUTE_DETERMINER_' || i || ' is invalid';
					end if;
				END IF;
		end loop; -- end attributes loop
		for i IN 1 .. 12 LOOP -- number of parts
			partName := NULL;
			partModifier := NULL;
			preservMethod := NULL;
			partCondition := NULL;
			partBarcode := NULL;
			partContainerLabel := NULL;
			partLotCount := NULL;
			partDisposition := NULL;
			 
				 execute immediate 'select 
					PART_NAME_' || i || ',
					PART_MODIFIER_' || i || ',
					PRESERV_METHOD_' || i || ',
					PART_CONDITION_' || i || ',
					PART_BARCODE_' || i || ',
					PART_CONTAINER_LABEL_' || i || ',
					PART_LOT_COUNT_' || i || ',
					PART_DISPOSITION_' || i || '
				 from bulkloader where  collection_object_id = ' || :NEW.collection_object_id into 
				 partName,
				 partModifier,
				 preservMethod,
				 partCondition,
				 partBarcode,
				 partContainerLabel,
				 partLotCount,
				 partDisposition;
			if partName is not null then
				SELECT count(*) INTO numRecs FROM ctspecimen_part_name WHERE PART_NAME = partName AND 
					collection_cde = :NEW.collection_cde;
					IF (numRecs = 0) THEN
						thisError :=  thisError || '; PART_NAME_' || i || ' is invalid';
					END IF;
				if partModifier is not null then
					SELECT count(*) INTO numRecs FROM ctspecimen_part_modifier WHERE PART_MODIFIER = partModifier;
						IF (numRecs = 0) THEN
							thisError :=  thisError || '; PART_MODIFIER_' || i || ' is invalid';
						END IF;
				END IF;
				if preservMethod is not null then
					SELECT count(*) INTO numRecs FROM ctspecimen_preserv_method WHERE PRESERVE_METHOD = preservMethod;
						IF (numRecs = 0) THEN
							thisError :=  thisError || '; PRESERVE_METHOD_' || i || ' is invalid';
						END IF;
				END IF; 
				if partCondition is null then
					thisError :=  thisError || '; PART_CONDITION_' || i || ' is invalid';
				END IF; 
				if partBarcode is not null then
					SELECT count(*) INTO numRecs FROM container WHERE barcode = partBarcode;
					if numRecs = 0 then
						thisError :=  thisError || '; barcode_' || i || ' is invalid';
					END IF;
					if partContainerLabel is null then
						thisError :=  thisError || '; PART_CONTAINER_LABEL_' || i || ' is invalid';
					END IF;
				else
					if partContainerLabel is not null then
						thisError :=  thisError || '; PART_CONTAINER_LABEL_' || i || ' is invalid';
					END IF;
				END IF;
				if partLotCount is null or is_number(partLotCount) = 0 then
					thisError :=  thisError || '; PART_LOT_COUNT_' || i || ' is invalid';
				END IF;
				SELECT count(*) INTO numRecs FROM ctcoll_obj_disp WHERE partDisposition = partDisposition;
					if numRecs = 0 then
						thisError :=  thisError || '; PART_DISPOSITION_' || i || ' is invalid';
					END IF;
			END IF;
		end loop; -- end parts loop
		for i IN 1 .. 5 LOOP -- number of other IDs
			 execute immediate 'select 
					OTHER_ID_NUM_TYPE_' || i || ',
					OTHER_ID_NUM_' || i || '
				 from bulkloader where  collection_object_id = ' || :NEW.collection_object_id into 
				 otherIdType,
				 otherIdNum;
			if otherIdNum is not null then
				if otherIdType is not null then
					SELECT count(*) INTO numRecs FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE = otherIdType and collection_cde = :NEW.collection_cde;
						if numRecs = 0 then
							thisError :=  thisError || '; OTHER_ID_TYPE_' || i || ' is invalid';
						END IF;
				else
					thisError :=  thisError || '; OTHER_ID_TYPE_' || i || ' is invalid';
				end if;
			end if;
 		end loop; -- end other ID loop
 		for i IN 1 .. 8 LOOP -- number of collectors
 			 execute immediate 'select 
					COLLECTOR_AGENT_' || i || ',
					COLLECTOR_ROLE_' || i || '
				 from bulkloader where  collection_object_id = ' || :NEW.collection_object_id into 
				 collectorName,
				 collectorRole;
			if i = 1 and (collectorName is null or collectorRole != 'c') then
				thisError :=  thisError || '; First collector is required';
			end if;
			if  collectorName is not null then
				SELECT count(distinct(agent_id)) INTO numRecs FROM agent_name WHERE agent_name = collectorName;
					if numRecs = 0 then
						thisError :=  thisError || '; COLLECTOR_AGENT_' || i || ' is invalid';
					END IF;
				if collectorRole not in ('c','p') then
					thisError :=  thisError || '; COLLECTOR_ROLE_' || i || ' is invalid';
				end if;
			end if;
		end loop; -- end collector loop
		if :NEW.flags is not null then
			SELECT count(*) INTO numRecs FROM ctflags WHERE FLAGS = :NEW.FLAGS;
			if numRecs = 0 then
				thisError :=  thisError || '; FLAGS is invalid';
			END IF; 
		end if;
		SELECT count(*) INTO numRecs FROM accn WHERE ACCN_NUMBER = :NEW.ACCN;
		if numRecs = 0 then
			thisError :=  thisError || '; ACCN is invalid';
		END IF; 
		SELECT count(*) INTO numRecs FROM ctCOLLECTING_SOURCE WHERE COLLECTING_SOURCE = :NEW.COLLECTING_SOURCE;
		if numRecs = 0 then
			thisError :=  thisError || '; COLLECTING_SOURCE is invalid';
		END IF; 
		
		if thisError is not null then
			if length(thisError) > 224 then
				thisError := substr(thisError,1,200) || ' {snip...}';
			end if;
			:NEW.loaded = thisError;
		end if;
		commit;
		--dbms_output.put_line (:NEW.collection_object_id ||': ' || thisError);
END;



	
END;
/
sho err