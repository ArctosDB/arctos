CREATE OR REPLACE PACKAGE bulk_pkg as
	PROCEDURE check_and_load;
	PROCEDURE bulkloader_check;
END;
/
sho err

CREATE OR REPLACE PACKAGE BODY bulk_pkg as
error_msg varchar2(4000);
l_collection_object_id number;
l_collecting_event_id number;
l_entered_person_id number;
l_accn_id number;
l_taxa_formula varchar2(20);
l_id_made_by_agent_id number;
l_cat_num number;
l_collection_id number;
l_locality_id number;
l_taxon_name_id_1 number;
l_taxon_name_id_2 number;
 tempStr VARCHAR2(255);
tempStr2 VARCHAR2(255);
failed_validation exception;
num number;
---------------------------------------------------------------------------------------------------------------------------------------------
 PROCEDURE bulkload_error  (
 	errMsg IN varchar,
 	sqlMsg IN varchar,
 	procName IN varchar,
 	collobjid IN number
 	) 
is
begin
	if sqlMsg != 'User-Defined Exception' then
		-- unhandled exception
		error_msg := errMsg || '; called from ' || procName || ': ' || sqlMsg;
	end if;
	if length(error_msg) > 224 then
		error_msg := substr(error_msg,1,200) || ' {snip...}';
	end if;
	update bulkloader set loaded = error_msg where collection_object_id = collobjid;
EXCEPTION
	when others then
		error_msg := 'An error in the error handler - OH NOES!! ' || error_msg;
		if length(error_msg) > 224 then
			error_msg := substr(error_msg,1,200) || ' {snip...}';
		end if;
		update bulkloader set loaded = error_msg where collection_object_id = collobjid;		
end;

---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE bulkloader_check 
is
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
 taxa_one varchar2(255);
 taxa_two varchar2(255);
 num number;
 tempStr VARCHAR2(255);
tempStr2 VARCHAR2(255);

  BEGIN
	FOR rec IN (SELECT * FROM bulkloader where loaded is null) LOOP
		thisError := '';
		select count(distinct(agent_id)) into numRecs from agent_name where agent_name = rec.ENTEREDBY
		    AND agent_name_type != 'Kew abbr.';
		if (numRecs != 1) then
			thisError :=  thisError || '; ENTEREDBY matches ' || numRecs || ' agents';
		END IF;
		select count(*) into numRecs from collection where
					institution_acronym = rec.institution_acronym and
					collection_cde=rec.collection_cde;
		IF (numRecs = 0) THEN
			thisError :=  thisError || '; institution_acronym and/or collection_cde is invalid';
		END IF;
		IF (rec.cat_num is not null) THEN
			select count(*) into numRecs from collection,cataloged_item where
				collection.collection_id = cataloged_item.collection_id AND
				collection.institution_acronym = rec.institution_acronym and
				collection.collection_cde=rec.collection_cde AND
				cat_num=rec.cat_num;
			IF (numRecs > 0) THEN
				thisError :=  thisError || '; cat_num is invalid';
			END IF;
		END IF;
		IF (rec.cat_num = 0) THEN
			thisError :=  thisError || '; cat_num may not be 0';
		END IF;
		IF (isdate(rec.began_date)=0 OR rec.began_date is null) THEN
			thisError :=  thisError || '; began_date is invalid';
		END IF;
		IF (isdate(rec.ended_date)=0 OR rec.ended_date is null) THEN
			thisError :=  thisError || '; ended_date is invalid';
		END IF;
		IF (rec.verbatim_date is null) THEN
			thisError :=  thisError || '; verbatim_date is invalid';
		END IF;
		IF (rec.relationship is not null) THEN
			IF (rec.related_to_num_type is null OR rec.related_to_number is null) THEN
				thisError :=  thisError || '; ::related_to_number:: and ::related_to_num_type:: are required when relationship is given';
			END IF;
			select count(*) into numRecs from ctbiol_relations where
				biol_indiv_relationship =rec.relationship;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; relationship is invalid';
			END IF;
			select  count(*) into numRecs from ctcoll_other_id_type
				where collection_cde=rec.collection_cde and
				other_id_type=rec.related_to_num_type;
			IF (numRecs = 0) THEN
				thisError :=  thisError || '; related_to_num_type is invalid';
			END IF;
		END IF;

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		-- only care about locality and geog IF we've not prepicked a locality ID	
		IF rec.locality_id IS NULL THEN	
    		SELECT count(*) INTO numRecs FROM geog_auth_rec WHERE higher_geog = rec.higher_geog;
    		IF (numRecs != 1) THEN
    			thisError :=  thisError || '; geog_auth_rec matched ' || numRecs || ' records';
    		END IF;
    		IF (isnumeric(rec.maximum_elevation) = 0) THEN
    			thisError :=  thisError || '; maximum_elevation is invalid';
    		END IF;	
    		IF (
    			(rec.maximum_elevation is not null AND rec.minimum_elevation is null) OR
    			(rec.minimum_elevation is not null AND rec.maximum_elevation is null) OR
    			((rec.minimum_elevation is not null OR rec.maximum_elevation is not null) AND rec.orig_elev_units is null)
    			) THEN
    			thisError :=  thisError || '; maximum_elevation,minimum_elevation,orig_elev_units are all required if one is given';
    		END IF;	
    		IF (rec.orig_elev_units is not null) THEN
    			SELECT count(*) INTO numRecs from ctorig_elev_units where orig_elev_units = rec.orig_elev_units;
    			IF (numRecs = 0) THEN
    				thisError :=  thisError || '; orig_elev_units is invalid';
    			END IF;
    		END IF;
    		IF (rec.spec_locality is null) THEN
        			thisError :=  thisError || '; spec_locality is required';
        		END IF;
    		    IF (rec.min_depth is not null OR rec.max_depth is not null OR rec.depth_units is not null OR 
    			isnumeric(rec.min_depth) = 0 OR isnumeric(rec.max_depth) = 0) THEN
    			thisError :=  thisError || '; depth is invalid';
    		END IF;	
    		IF (rec.depth_units is not null) THEN
    			SELECT count(*) INTO numRecs FROM ctdepth_units where depth_units=rec.depth_units;
    			IF (numRecs = 0) THEN
    				thisError :=  thisError || '; depth_units is invalid';
    			END IF;
    			if rec.MIN_DEPTH is null or is_number(rec.MIN_DEPTH) = 0 OR rec.MAX_DEPTH is null or is_number(rec.MAX_DEPTH) = 0 then
    				thisError :=  thisError || '; MIN_DEPTH and/or MAX_DEPTH is invalid';
    			END IF;
    		END IF;
    		IF (rec.orig_lat_long_units is NOT null) THEN
    			SELECT count(*) INTO numRecs from ctlat_long_units where orig_lat_long_units=rec.orig_lat_long_units;
    			IF (numRecs = 0) THEN
    				thisError :=  thisError || '; orig_lat_long_units is invalid';
    			END IF;
    			
    			IF (rec.orig_lat_long_units = 'decimal degrees') THEN
    				IF (isnumeric(rec.dec_lat) = 0 OR isnumeric(rec.dec_long) = 0  OR 
    					rec.dec_long < -180 OR rec.dec_long > 180 OR rec.dec_lat < -90 OR rec.dec_lat > 90) THEN	
    					thisError :=  thisError || '; dec_lat or dec_long is invalid';
    				END IF;
    			ELSIF (rec.orig_lat_long_units = 'deg. min. sec.') THEN	
    				IF (isnumeric(rec.latdeg) = 0 OR rec.latdeg < 0 OR rec.latdeg > 90 OR
    					isnumeric(rec.latmin) = 0 OR rec.latmin < 0 OR rec.latmin > 60 OR
    					isnumeric(rec.latsec) = 0 OR rec.latsec < 0 OR rec.latsec > 60 OR
    					isnumeric(rec.longdeg) = 0 OR rec.longdeg < 0 OR rec.longdeg > 180 OR
    					isnumeric(rec.longmin) = 0 OR rec.longmin < 0 OR rec.longmin > 60 OR
    					isnumeric(rec.longsec) = 0 OR rec.longsec < 0 OR rec.longsec > 60) THEN
    					thisError :=  thisError || '; coordinates are invalid';
    				END IF;	 
    				IF (rec.latdir <> 'N' AND rec.latdir <> 'S') THEN
    					thisError :=  thisError || '; latdir is invalid';
    				END IF;
    				IF (rec.longdir <> 'E' AND rec.longdir <> 'W') THEN
    					thisError :=  thisError || '; longdir is invalid';
    				END IF;
    			ELSIF (rec.orig_lat_long_units = 'degrees dec. minutes') THEN	
    				IF (isnumeric(rec.latdeg) = 0 OR rec.latdeg < 0 OR rec.latdeg > 90 OR
    					isnumeric(rec.dec_lat_min) = 0 OR rec.dec_lat_min < 0 OR rec.dec_lat_min > 60 OR
    					isnumeric(rec.longdeg) = 0 OR rec.longdeg < 0 OR rec.longdeg > 180 OR
    					isnumeric(rec.dec_long_min) = 0 OR rec.dec_long_min < 0 OR rec.dec_long_min > 60) THEN
    					thisError :=  thisError || '; coordinates are invalid';
    				END IF;	 
    				
    				
    				
    				
    				IF (rec.latdir != 'N' AND rec.latdir != 'S') THEN
    					thisError := thisError || ' stuff broke at coordiantes';
    				END IF;
    				
    				IF (rec.longdir <> 'E' AND rec.longdir <> 'W') THEN
    					thisError :=  thisError || '; longdir is invalid';
    				END IF;
    				
    			ELSIF (rec.orig_lat_long_units = 'UTM') THEN
    				IF isnumeric(rec.UTM_EW) = 0 OR	isnumeric(rec.UTM_NS) = 0 THEN
    					thisError := thisError || '; coordinates are invalid';
    				END IF;	
    			END IF;
    			SELECT count(*) INTO numRecs from ctdatum where datum =rec.datum;
    			IF (numRecs = 0) THEN
    				thisError :=  thisError || '; datum is invalid';
    			END IF;
    			SELECT count(distinct(agent_id)) INTO numRecs from agent_name where agent_name = rec.determined_by_agent
    				and agent_name_type <> 'Kew abbr.';
    			IF (numRecs = 0) THEN
    				thisError :=  thisError || '; determined_by_agent matches ' || numRecs || ' agents';
    			END IF;
    			IF (isdate(rec.determined_date)=0 OR rec.determined_date is null) THEN
    				thisError :=  thisError || '; determined_date is invalid';
    			END IF;
    			IF (rec.lat_long_ref_source is null) THEN
    				thisError :=  thisError || '; lat_long_ref_source is required';
    			END IF;
    			IF (rec.max_error_units is not null) THEN
    				SELECT count(*) INTO numRecs from CTLAT_LONG_ERROR_UNITS where LAT_LONG_ERROR_UNITS = rec.max_error_units;
    				IF (numRecs = 0) THEN
    					thisError :=  thisError || '; max_error_units is invalid';
    				END IF;
    			END IF;
    			SELECT count(*) INTO numRecs from CTGEOREFMETHOD where GEOREFMETHOD = rec.GEOREFMETHOD;
    			IF (numRecs = 0) THEN
    				thisError :=  thisError || '; GEOREFMETHOD is invalid';
    			END IF;
    			SELECT count(*) INTO numRecs from CTVERIFICATIONSTATUS where VERIFICATIONSTATUS = rec.VERIFICATIONSTATUS;
    			IF (numRecs = 0) THEN
    				thisError :=  thisError || '; VERIFICATIONSTATUS is invalid';
    			END IF;	
    		END IF;  -- end lat/long check
    	END IF;  -- end locality_id check
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
    	
		IF (rec.verbatim_locality is null) THEN
			thisError :=  thisError || '; verbatim_locality is required';
		END IF;
		SELECT count(*) INTO numRecs from ctcoll_obj_disp where COLL_OBJ_DISPOSITION = rec.coll_obj_disposition;
		IF (numRecs = 0) THEN
			thisError :=  thisError || '; coll_obj_disposition is invalid';
		END IF;	
		IF (rec.condition is null) THEN
			thisError :=  thisError || '; condition is required';
		END IF;
		IF (rec.made_date is null OR isdate(rec.made_date)=0 ) THEN
			thisError :=  thisError || '; made_date is invalid';
		END IF;
		SELECT count(*) INTO numRecs from ctnature_of_id WHERE nature_of_id = rec.nature_of_id;
		IF (numRecs = 0) THEN
			thisError :=  thisError || '; nature_of_id is invalid';
		END IF;	
		IF (rec.taxon_name is null) THEN
			thisError :=  thisError || '; taxon_name is required';
		ELSE
			if instr(rec.taxon_name,' or ') > 1 then
				num := instr(rec.taxon_name, ' or ') -1;
				taxa_one := substr(rec.taxon_name,1,num);
				taxa_two := substr(rec.taxon_name,num+5);
			elsif instr(rec.taxon_name,' x ') > 1 then
				num := instr(rec.taxon_name, ' x ') -1;
				taxa_one := substr(rec.taxon_name,1,num);
				taxa_two := substr(rec.taxon_name,num+4);
			elsif  substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' sp.' then
				taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
			elsif  substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' cf.' then
				taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
			elsif  substr(rec.taxon_name,length(rec.taxon_name) - 1) = ' ?' then
				taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 1);
			else
				taxa_one := rec.taxon_name;
			end if;				
			if taxa_two is not null AND (
				  substr(taxa_one,length(taxa_one) - 3) = ' sp.' OR
					substr(taxa_two,length(taxa_two) - 3) = ' sp.' OR
					substr(taxa_one,length(taxa_one) - 1) = ' ?' OR
					substr(taxa_two,length(taxa_two) - 1) = ' ?' 
				) then
					thisError :=  thisError || '; "sp." and "?" are not allowed in multi-taxon IDs';
			end if;
			if taxa_one is not null then
				select count(distinct(taxon_name_id)) into numRecs from taxonomy where scientific_name = trim(taxa_one) and VALID_CATALOG_TERM_FG = 1;
				if numRecs = 0 then
					thisError :=  thisError || '; Taxonomy (' || taxa_one || ') not found';
				end if;
			end if;
			if taxa_two is not null then
				select count(distinct(taxon_name_id)) into numRecs from taxonomy where scientific_name = trim(taxa_two) and VALID_CATALOG_TERM_FG = 1;
				if numRecs = 0 then
					thisError :=  thisError || '; Taxonomy (' || taxa_two || ') not found';
				end if;
			end if;
		END IF;
		SELECT count(distinct(agent_id)) INTO numRecs from agent_name where agent_name = rec.ID_MADE_BY_AGENT
				and agent_name_type <> 'Kew abbr.';
		IF (numRecs = 0) THEN
			thisError :=  thisError || '; ID_MADE_BY_AGENT matches ' || numRecs || ' agents';
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
				 from bulkloader where  collection_object_id = ' || rec.collection_object_id into 
				 attributeType,
				 attributeValue,
				 attributeUnits,
				 attributeDate,
				 attributeDeterminer;
				IF attributeType is not null and attributeValue is not null THEN
					SELECT count(*) INTO numRecs FROM ctattribute_type WHERE ATTRIBUTE_TYPE = attributeType AND 
					collection_cde = rec.collection_cde;
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
									rec.collection_cde || '''' into numRecs;
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
									rec.collection_cde || '''' into numRecs;
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
				 from bulkloader where  collection_object_id = ' || rec.collection_object_id into 
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
					collection_cde = rec.collection_cde;
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
					--if partContainerLabel is null then
					--	thisError :=  thisError || '; PART_CONTAINER_LABEL_' || i || ' is invalid';
					--END IF;
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
				 from bulkloader where  collection_object_id = ' || rec.collection_object_id into 
				 otherIdType,
				 otherIdNum;
			if otherIdNum is not null then
				if otherIdType is not null then
					SELECT count(*) INTO numRecs FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE = otherIdType and collection_cde = rec.collection_cde;
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
				 from bulkloader where  collection_object_id = ' || rec.collection_object_id into 
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
		if rec.flags is not null then
			SELECT count(*) INTO numRecs FROM ctflags WHERE FLAGS = rec.FLAGS;
			if numRecs = 0 then
				thisError :=  thisError || '; FLAGS is invalid';
			END IF; 
		end if;
		IF rec.accn LIKE '[%' AND rec.accn LIKE '%]%' THEN
	     -- trans.institution in accn number
        	tempStr :=  substr(rec.accn, instr(rec.accn,'[',1,1) + 1,instr(rec.accn,']',1,1) -2);
        	
        	tempStr2 := REPLACE(rec.accn,'[' || tempStr || ']');
          ELSE
            -- use institution_acronym	
            tempStr := rec.institution_acronym;
            tempStr2 := rec.accn;
    	END IF;
	    dbms_output.put_line('tempStr: ' || tempStr);
	      dbms_output.put_line('tempStr2: ' || tempStr2);
	            	
	            	
		SELECT count(*) INTO numRecs FROM accn WHERE ACCN_NUMBER = tempStr2;
		if numRecs = 0 then
			thisError :=  thisError || '; ACCN is invalid';
		END IF; 
		SELECT count(*) INTO numRecs FROM ctCOLLECTING_SOURCE WHERE COLLECTING_SOURCE = rec.COLLECTING_SOURCE;
		if numRecs = 0 then
			thisError :=  thisError || '; COLLECTING_SOURCE is invalid';
		END IF; 
		
		if thisError is not null then
			if length(thisError) > 224 then
				thisError := substr(thisError,1,200) || ' {snip...}';
			end if;
			rollback;
			update bulkloader set loaded = thisError where collection_object_id = rec.collection_object_id;
		end if;
		commit;
		--dbms_output.put_line (rec.collection_object_id ||': ' || thisError);
	END LOOP;
END;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_rollback_bulkloader  (l_collection_object_id IN number,collobjid IN number) 
is
	determiner_id number;
	b_locality_id bulkloader.locality_id%TYPE;
	error_msg varchar2(4000);  
	b_container_id container.container_id%TYPE;
BEGIN
	delete from cf_temp_relations where collection_object_id = l_collection_object_id;
	delete from coll_obj_other_id_num where collection_object_id = l_collection_object_id;
		
		delete from container where container_id IN (
			select container_id from coll_obj_cont_hist where collection_object_id IN (
				select collection_object_id FROM specimen_part WHERE derived_from_cat_item = l_collection_object_id
			)
		);
		delete from coll_obj_cont_hist where collection_object_id IN (
			select collection_object_id FROM specimen_part WHERE derived_from_cat_item = l_collection_object_id
		);
		delete from coll_object_remark where collection_object_id IN (
			select collection_object_id FROM specimen_part WHERE derived_from_cat_item = l_collection_object_id
		);
		delete from specimen_part where derived_from_cat_item = l_collection_object_id;
		delete from attributes where collection_object_id = l_collection_object_id;
		delete from identification_agent where IDENTIFICATION_ID IN (
			select IDENTIFICATION_ID from IDENTIFICATION where collection_object_id = l_collection_object_id
		);
		delete from identification_taxonomy where IDENTIFICATION_ID IN (
			select IDENTIFICATION_ID from IDENTIFICATION where collection_object_id = l_collection_object_id
		);
		delete from identification_agent where IDENTIFICATION_ID IN (
			select IDENTIFICATION_ID from IDENTIFICATION where collection_object_id = l_collection_object_id
		);
		delete from IDENTIFICATION where collection_object_id = l_collection_object_id;
		delete from coll_object_remark where collection_object_id = l_collection_object_id;
	 	delete from collector where collection_object_id = l_collection_object_id;
		delete from cataloged_item where collection_object_id = l_collection_object_id;
		delete from coll_object where collection_object_id = l_collection_object_id;
		-- see if locality, collecting event is used by any other records
		/*
		select count(*) into num from 
			cataloged_item,collecting_event,locality
		where
			cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
			collecting_event.locality_id = locality.locality_id AND
			collecting_event.collecting_event_id = l_collecting_event_id;
		if (num = 0) then
			--delete from collecting_event where collecting_event_id = l_collecting_event_id;
			commit;
			--delete from lat_long where locality_id = l_locality_id;
			commit;
			--delete from locality where locality_id = l_locality_id;
			commit;
			--delete from vessel where COLLECTING_EVENT_ID =  l_collecting_event_id;
			--dbms_output.put_line ('delete loc and coll event');
		else
			-- see if just the collecting event can be deleted
			select count(*) into num from cataloged_item,collecting_event
				where
				cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
				collecting_event.collecting_event_id = l_collecting_event_id;
			if num = 0 then
				-- ok to delete the collecting event
				--delete from collecting_event where collecting_event_id = l_collecting_event_id;
				--delete from vessel where COLLECTING_EVENT_ID =  l_collecting_event_id;
				--dbms_output.put_line ('delete coll event');
			end if;
		end if;	
		*/	
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulk_this',collobjid);
END;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_bulkload_attribute  (collobjid IN number) 
is
catitemcollid cataloged_item.collection_object_id%TYPE;
DETERMINED_BY_AGENT_ID attributes.DETERMINED_BY_AGENT_ID%TYPE;
ATTRIBUTE attributes.attribute_type%TYPE;
ATTRIBUTE_VALUE attributes.ATTRIBUTE_VALUE%TYPE;
ATTRIBUTE_UNITS attributes.ATTRIBUTE_UNITS%TYPE;
ATTRIBUTE_REMARKS attributes.ATTRIBUTE_REMARK%TYPE;
ATTRIBUTE_DATE attributes.DETERMINED_DATE%TYPE;
ATTRIBUTE_DET_METH attributes.DETERMINATION_METHOD%TYPE;
ATTRIBUTE_DETERMINER_ID agent.agent_id%TYPE;
ATTRIBUTE_DETERMINER varchar2(255);
ATTRIBUTE_ID attributes.ATTRIBUTE_ID%TYPE;
BEGIN
	--dbms_output.put_line ('catitemcollid' || catitemcollid);
	for i IN 1 .. 10 LOOP -- number of attributes
		execute immediate 'select count(*) from bulkloader where ATTRIBUTE_' || i || ' is not null and 
			ATTRIBUTE_VALUE_' || i || ' is not null and collection_object_id = ' || collobjid into num;
			--dbms_output.put_line ('num: ' || num);
		if num = 1 then -- there's an attribute - insert it
			select max(attribute_id) + 1 into ATTRIBUTE_ID from attributes;
			--dbms_output.put_line ('ATTRIBUTE_ID: ' || ATTRIBUTE_ID);
			execute immediate 'select ATTRIBUTE_DETERMINER_' || i || ' from bulkloader where collection_object_id = ' || 
				collobjid into ATTRIBUTE_DETERMINER;
				--dbms_output.put_line ('ATTRIBUTE_DETERMINER: ' || ATTRIBUTE_DETERMINER);
			if ATTRIBUTE_DETERMINER is null then
				error_msg := 'Bad ATTRIBUTE_DETERMINER_' || i;
				raise failed_validation;
			end if;
			select count(distinct(agent_id)) into num from agent_name where agent_name = ATTRIBUTE_DETERMINER;
			--dbms_output.put_line ('num: ' || num);
			if num = 0 then
				error_msg := 'Bad ATTRIBUTE_DETERMINER_' || i;
				raise failed_validation;
			end if;
			select distinct(agent_id) into ATTRIBUTE_DETERMINER_ID from agent_name where agent_name = ATTRIBUTE_DETERMINER;
			execute immediate 'select ATTRIBUTE_' || i || 
				',ATTRIBUTE_VALUE_' || i || 
				',ATTRIBUTE_UNITS_' || i || 
				',ATTRIBUTE_REMARKS_' || i ||
				',ATTRIBUTE_DATE_' || i ||
				',ATTRIBUTE_DET_METH_' || i || 
				' from bulkloader where collection_object_id = ' || collobjid into
				ATTRIBUTE,
				ATTRIBUTE_VALUE,
				ATTRIBUTE_UNITS,
				ATTRIBUTE_REMARKS,
				ATTRIBUTE_DATE,
				ATTRIBUTE_DET_METH
			;
			--dbms_output.put_line ('ATTRIBUTE: ' || ATTRIBUTE);
			--dbms_output.put_line ('ATTRIBUTE_VALUE: ' || ATTRIBUTE_VALUE);
			insert into attributes (
				ATTRIBUTE_ID,
				COLLECTION_OBJECT_ID,
				DETERMINED_BY_AGENT_ID,
				ATTRIBUTE_TYPE,
				ATTRIBUTE_VALUE,
				ATTRIBUTE_UNITS,
				ATTRIBUTE_REMARK,
				DETERMINED_DATE,
				DETERMINATION_METHOD 
			) values (
				ATTRIBUTE_ID,
				l_collection_object_id,
				ATTRIBUTE_DETERMINER_ID,
				ATTRIBUTE,
				ATTRIBUTE_VALUE,
				ATTRIBUTE_UNITS,
				ATTRIBUTE_REMARKS,
				ATTRIBUTE_DATE,
				ATTRIBUTE_DET_METH
			);
				 --dbms_output.put_line ('inserted attribute);
		end if;
	end loop;
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulkload_attribute',collobjid);
END;       
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_bulkload_parts  (collobjid IN number) 
is
r_partname  specimen_part.PART_NAME%TYPE;
r_partmod  specimen_part.PART_MODIFIER%TYPE;
r_presmeth  specimen_part.PRESERVE_METHOD%TYPE;
r_condn  coll_object.CONDITION%TYPE;
r_barcode  container.BARCODE%TYPE;
r_label  container.LABEL%TYPE;
r_lotcount  coll_object.LOT_COUNT%TYPE;
r_disposition  coll_object.COLL_OBJ_DISPOSITION%TYPE;
r_partremark  coll_object_remark.COLL_OBJECT_REMARKS%TYPE;
catitemcollid CATALOGED_ITEM.COLLECTION_OBJECT_ID%TYPE;
r_container_id container.container_id%TYPE;
part_id specimen_part.COLLECTION_OBJECT_ID%TYPE;
entered_person_id agent.agent_id%TYPE;
part_label varchar2(255);
institution_acronym container.institution_acronym%TYPE;
--error_msg varchar2(4000);
r_parent_container_id container.parent_container_id%TYPE;
BEGIN
	--dbms_output.put_line ('parts...');
	--dbms_output.put_line ('got catcollid...');
	select institution_acronym into institution_acronym from bulkloader where collection_object_id = collobjid;
	--dbms_output.put_line ('got institution_acronym...');
	for i IN 1 .. 12 LOOP -- number of parts
	    --dbms_output.put_line('on part loop ' || i);
	    
		execute immediate 'select count(*) from bulkloader where PART_NAME_' || i || ' is not null 
			and collection_object_id = ' || collobjid into num;
		if num = 1 then -- there's a part - insert it
				--dbms_output.put_line ('inserting a part...');
			execute immediate 'select 
				PART_NAME_' || i || ', 
				PART_MODIFIER_' || i || ', 
				PRESERV_METHOD_' || i || ', 
				PART_CONDITION_' || i || ', 
				PART_BARCODE_' || i || ', 
				PART_CONTAINER_LABEL_' || i || ', 
				PART_LOT_COUNT_' || i || ', 
				PART_DISPOSITION_' || i || ', 
				PART_REMARK_' || i || ' 
			from bulkloader 
			where collection_object_id = ' || collobjid 
			into 
				r_partname,
				r_partmod,
				r_presmeth,
				r_condn,
				r_barcode,
				r_label,
				r_lotcount,
				r_disposition,
				r_partremark
			;
			-- next container ID
			--dbms_output.put_line ('loadin a part - PART_DISPOSITION: ' || r_disposition || 'number: ' || i);
			--- DLM 9 May 2007 - strip out create container for parts bit
			--select max(container_id) + 1 into r_container_id from container;
			--dbms_output.put_line ('got container_id...');
			-- part ID
			select max(COLLECTION_OBJECT_ID) + 1 into part_id from coll_object;
			--dbms_output.put_line ('got coll obj id');
			execute immediate 'select institution_acronym || '' '' || collection_cde || '' ' || l_cat_num || ' ''  || 
				part_name_' || i ||  ' from bulkloader where collection_object_id = ' || 
				collobjid into part_label;
			--dbms_output.put_line ('got label');
			INSERT INTO coll_object (
				COLLECTION_OBJECT_ID,
				COLL_OBJECT_TYPE,
				ENTERED_PERSON_ID,
				COLL_OBJECT_ENTERED_DATE,
				COLL_OBJ_DISPOSITION,
				LOT_COUNT,
				CONDITION 
			) VALUES (
				part_id,
				'SP',
				l_entered_person_id,
				sysdate,
				r_disposition,
				r_lotcount,
				r_condn   
			);
			INSERT INTO specimen_part (	
				COLLECTION_OBJECT_ID,
				PART_NAME,
				PART_MODIFIER,
				PRESERVE_METHOD,
				DERIVED_FROM_CAT_ITEM
			) VALUES (
				part_id,
				r_partname,
				r_partmod,
				r_presmeth,
				l_collection_object_id
			);
			if r_partremark is not null then
				INSERT INTO coll_object_remark (
						collection_object_id, 
						coll_object_remarks
				) VALUES (
					part_id, r_partremark);
			end if;
	dbms_output.put_line ('inserting container ID: ' || r_container_id);
			/*
           INSERT INTO container (
				CONTAINER_ID,
				PARENT_CONTAINER_ID,
				CONTAINER_TYPE,
				LABEL,
				PARENT_INSTALL_DATE,
				locked_position,
				institution_acronym)
			VALUES (
				r_container_id,
				0,
				'collection object',
				part_label,
				sysdate,
				0,
				institution_acronym
			);
			dbms_output.put_line ('made container: inserting coll_obj_cont_hist');
			INSERT INTO coll_obj_cont_hist (
				  COLLECTION_OBJECT_ID,
				  CONTAINER_ID,
				  INSTALLED_DATE,
				  CURRENT_CONTAINER_FG)
			VALUES (
				part_id,
				r_container_id,
				sysdate,
				1
			);
			*/
			dbms_output.put_line ('made coll_obj_cont_hist');
			if r_barcode is not null then
			    -- find the container_id of the part we just made
			    SELECT container_id INTO r_container_id FROM coll_obj_cont_hist WHERE collection_object_id = part_id;
			    dbms_output.put_line ('CURRENT part IS : ' || r_container_id);
				SELECT container_id into r_parent_container_id FROM container WHERE barcode = r_barcode;
				dbms_output.put_line ('got parent contianer id: ' || r_parent_container_id);
				UPDATE container SET 
					parent_container_id = r_parent_container_id,
					parent_install_date = sysdate
				WHERE 
					container_id = r_container_id;
				if r_label is not null then
					UPDATE container SET label = r_label
						where container_id = r_container_id;
				end if;
			end if;			
			/*			
			dbms_output.put_line ('part: ' || i);
			dbms_output.put_line ('part_label: ' || part_label);
			dbms_output.put_line ('partname: ' || partname);
			dbms_output.put_line ('partmod: ' || partmod);
			dbms_output.put_line ('presmeth: ' || presmeth);
			dbms_output.put_line ('condn: ' || condn);
			dbms_output.put_line ('barcode: ' || barcode);
			dbms_output.put_line ('label: ' || label);
			dbms_output.put_line ('lotcount: ' || lotcount);
			dbms_output.put_line ('disposition: ' || disposition);
			dbms_output.put_line ('partremark: ' || partremark);
			dbms_output.put_line ('-------------------------------------------');
			*/
		end if;
		--dbms_output.put_line ('parts loop de looooppppeeeee.....');
	end loop;
--dbms_output.put_line ('made it thru parts');	
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulkload_parts',collobjid);
END;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_bulkload_otherid  (collobjid IN number) 
is
oidn  coll_obj_other_id_num.OTHER_ID_NUM%TYPE;
oidt  coll_obj_other_id_num.OTHER_ID_TYPE%TYPE;
catcollid cataloged_item.collection_object_id%TYPE;
BEGIN
	for i IN 1 .. 5 LOOP -- number of other IDs		
		execute immediate 'select count(*) from bulkloader where OTHER_ID_NUM_' || i || ' is not null 
			and collection_object_id = ' || collobjid into num;
		if num = 1 then -- there's an other ID number - insert it
			execute immediate 'select OTHER_ID_NUM_' || i || ', OTHER_ID_NUM_TYPE_' || i || ' from bulkloader where 
				collection_object_id = ' || collobjid
				into oidn,oidt;			
			/*
			insert into coll_obj_other_id_num (
				COLLECTION_OBJECT_ID,
				OTHER_ID_NUM,
				OTHER_ID_TYPE
			) values (
				l_collection_object_id,
				oidn,
				oidt
			);
			*/			
			-- call the function to attempt parsing other IDs out into components
			parse_other_id(l_collection_object_id, oidn, oidt);
		end if;
	end loop;		
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulkload_otherid',collobjid);
END;        
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_bulkload (collobjid IN NUMBER)
is
catcollid number;
someRandomString varchar2(4000);
someRandomStringTwo varchar2(4000);
someRandomNumber number;
someRandomNumberTwo number;
someRandomNumberThree number;
someRandomNumberFour number;
someRandomNumberFive number;
rec bulkloader%ROWTYPE;
geog_auth_rec_id geog_auth_rec.geog_auth_rec_id%TYPE;
newLocId  locality.locality_id%TYPE;
DETERMINED_BY_AGENT_ID  agent.agent_id%TYPE;
bulk_table_coll_obj_id number;
BEGIN
		SELECT * into rec FROM bulkloader where collection_object_id = collobjid;		
		--select catcollid into catcollid from bulkloader_keys where k_collection_object_id = collobjid;
			
		-- coll object and cataloged_item
		--dbms_output.put_line ('loadin a coll_object... ');
		--select entered_person_id into someRandomNumber from bulkloader_keys where k_collection_object_id = rec.collection_object_id;
		INSERT INTO coll_object (
			COLLECTION_OBJECT_ID,
			COLL_OBJECT_TYPE,
			ENTERED_PERSON_ID,
			COLL_OBJECT_ENTERED_DATE,
			COLL_OBJ_DISPOSITION,
			LOT_COUNT,
			CONDITION,
			FLAGS
		) VALUES (
			l_collection_object_id,
			'CI',
			l_entered_person_id,
			sysdate,
			rec.coll_obj_disposition,
			1,
			rec.condition,
			rec.FLAGS
		)
		;
		dbms_output.put_line ('loadied a coll_object... ');
		
		--select accn_id into someRandomNumber from bulkloader_keys where k_collection_object_id = rec.collection_object_id;
		--select K_CAT_NUM into someRandomNumberThree from bulkloader_keys where k_collection_object_id = rec.collection_object_id;
		--select collecting_event_id into someRandomNumberFour from bulkloader_keys where k_collection_object_id = rec.collection_object_id;
		--dbms_output.put_line ('keys colleventid: ' || someRandomNumberFour);
		--select collection_id into someRandomNumberFive from bulkloader_keys where k_collection_object_id = rec.collection_object_id;
		
		
		INSERT INTO cataloged_item (
			COLLECTION_OBJECT_ID,
			CAT_NUM,
			ACCN_ID,
			COLLECTING_EVENT_ID,
			COLLECTION_CDE,
			CATALOGED_ITEM_TYPE,
			COLLECTION_ID
			)
		VALUES (
			l_collection_object_id,
			l_cat_num,
			l_accn_id,
			l_collecting_event_id,
			rec.collection_cde,
			'BI',
			l_collection_id
		);
		commit; -- necessary so triggers work
		 -- relationship
		 IF (rec.relationship is not null) THEN
		 	IF (rec.RELATED_TO_NUMBER is null OR rec.RELATED_TO_NUM_TYPE is null) THEN
		 		error_msg := 'Incomplete relationship';
				raise failed_validation;
			END IF;
			insert into cf_temp_relations (
				collection_object_id,
				relationship,
				related_to_number,
				related_to_num_type)
			VALUES (
				l_collection_object_id,
				rec.relationship,
				rec.RELATED_TO_NUMBER,
				rec.RELATED_TO_NUM_TYPE)
			;
		END IF;
		
		-- vessel
		IF (rec.vessel is not null) THEN
			--select COLLECTING_EVENT_ID into someRandomNumber from bulkloader_keys where	k_collection_object_id = rec.collection_object_id;
			INSERT INTO vessel (
				COLLECTING_EVENT_ID,
				VESSEL,
				STATION_NAME,
				STATION_NUMBER)
			values (
				l_collecting_event_id,
				rec.VESSEL,
				rec.STATION_NAME,
				rec.STATION_NUMBER)
			; 
		END IF;
		
		-- other IDs
		
		-- parts
		
		-- attributes
		
		
		-- identification
		select max(identification_id) + 1 into someRandomNumber from identification;
		
	
		insert into identification (
			IDENTIFICATION_ID,
			COLLECTION_OBJECT_ID,
			ID_MADE_BY_AGENT_ID, -- can go away when identification_agent fully deployed
			MADE_DATE,
			NATURE_OF_ID,
			ACCEPTED_ID_FG,
			IDENTIFICATION_REMARKS,
			TAXA_FORMULA,
			SCIENTIFIC_NAME
		) values (
			someRandomNumber,
			l_collection_object_id,
			l_id_made_by_agent_id,
			rec.MADE_DATE,
			rec.NATURE_OF_ID,
			1,
			rec.IDENTIFICATION_REMARKS,
			l_taxa_formula,
			rec.TAXON_NAME
		);
		-- only deals with variable=a so far.... 
		
		insert into identification_taxonomy (
			IDENTIFICATION_ID,
			TAXON_NAME_ID,
			VARIABLE
		) values (
			someRandomNumber,
			l_taxon_name_id_1,
			'A'
		);
		if l_taxon_name_id_2 is not null then
			insert into identification_taxonomy (
				IDENTIFICATION_ID,
				TAXON_NAME_ID,
				VARIABLE
			) values (
				someRandomNumber,
				l_taxon_name_id_2,
				'B'
			);
		end if;
		
		insert into identification_agent (
			IDENTIFICATION_ID,
			AGENT_ID,
			IDENTIFIER_ORDER
		) values (
			someRandomNumber,
			l_id_made_by_agent_id,
			1
		);
	
		
			if rec.COLL_OBJECT_HABITAT is not null OR
			rec.ASSOCIATED_SPECIES is not null OR 
			rec.COLL_OBJECT_REMARKS is not null OR
			rec.DISPOSITION_REMARKS is not null then
			insert into coll_object_remark (
				COLLECTION_OBJECT_ID,
				DISPOSITION_REMARKS,
				COLL_OBJECT_REMARKS,
				HABITAT,
				ASSOCIATED_SPECIES
			) values (
				l_collection_object_id,
				rec.DISPOSITION_REMARKS,
				rec.COLL_OBJECT_REMARKS,
				rec.COLL_OBJECT_HABITAT,
				rec.ASSOCIATED_SPECIES
			);
		end if;
		-- collectors
		for i IN 1 .. 8 LOOP -- number of collectors
			execute immediate 'select count(*)
				FROM bulkloader
				where 
				COLLECTOR_AGENT_' || i || ' is not null and 
				collection_object_id = ' || rec.collection_object_id 
				INTO num;
			if num > 0 then
				execute immediate 'select 
					COLLECTOR_AGENT_' || i || ', 
					COLLECTOR_ROLE_' || i || '
					FROM bulkloader
					where collection_object_id = ' || rec.collection_object_id  
					INTO someRandomString,
					someRandomStringTwo;
				select count(distinct(agent_id))  into num from agent_name where agent_name = someRandomString;
				if num != 1 then
					error_msg := 'Bad COLLECTOR_AGENT_' || i || '(' || someRandomString || ')';
					raise failed_validation;
				else
					select distinct(agent_id) into someRandomNumber from agent_name where agent_name = someRandomString;
					insert into collector (
						COLLECTION_OBJECT_ID,
						AGENT_ID,
						COLLECTOR_ROLE,
						COLL_ORDER
					) values (
						l_collection_object_id,
						someRandomNumber,
						someRandomStringTwo,
						i
					);
				end if;
			end if;
		END LOOP;
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulkload',collobjid);

END;



---------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE b_bulkload_coll_event  (collobjid IN number) 
is
rec bulkloader%ROWTYPE;
determiner_id number;
geog_auth_rec_id geog_auth_rec.geog_auth_rec_id%TYPE;
gcollecting_event_id collecting_event.collecting_event_id%TYPE;
--error_msg varchar2(4000);  
k_locality_id locality.locality_id%TYPE;
BEGIN
	select * into rec from bulkloader where collection_object_id=collobjid;
	select count(*) into num from
	collecting_event where
	locality_id = l_locality_id and
	verbatim_date = rec.verbatim_date and
	began_date = rec.began_date and
	ended_date = rec.ended_date and
	DATE_DETERMINED_BY_AGENT_ID=0 and
	nvl(VERBATIM_LOCALITY,'nuthin') = nvl(rec.VERBATIM_LOCALITY,'nuthin') AND
	nvl(coll_event_remarks,'nuthin') = nvl(rec.coll_event_remarks,'nuthin') AND
	nvl(collecting_method,'nuthin') = nvl(rec.collecting_method,'nuthin') AND
	collecting_source = rec.collecting_source;
	if (num = 1) then
		dbms_output.put_line ('there is an existing coll event');
		select collecting_event.collecting_event_id into gcollecting_event_id from
		collecting_event where
		locality_id = l_locality_id and
		verbatim_date = rec.verbatim_date and
		began_date = rec.began_date and
		ended_date = rec.ended_date and
		DATE_DETERMINED_BY_AGENT_ID=0 and
		nvl(VERBATIM_LOCALITY,'nuthin') = nvl(rec.VERBATIM_LOCALITY,'nuthin') AND
		nvl(coll_event_remarks,'nuthin') = nvl(rec.coll_event_remarks,'nuthin') AND
		nvl(collecting_method,'nuthin') = nvl(rec.collecting_method,'nuthin') AND
		collecting_source = rec.collecting_source;
		l_collecting_event_id := gcollecting_event_id;
	else
		dbms_output.put_line ('there is NOT an existing coll event');
		select max(collecting_event_id) + 1 into gcollecting_event_id from collecting_event;
		--dbms_output.put_line ('gcollecting_event_id: ' || gcollecting_event_id);
		insert into collecting_event (
			collecting_event_id,
			locality_id,
			verbatim_date,
			VERBATIM_LOCALITY,
			began_date,
			ended_date,
			DATE_DETERMINED_BY_AGENT_ID,
			coll_event_remarks,
			collecting_method,
			collecting_source)
		values (
			gcollecting_event_id,
			l_locality_id,
			rec.verbatim_date,
			rec.VERBATIM_LOCALITY,
			rec.began_date,			
			rec.ended_date,
			0,
			rec.coll_event_remarks,
			rec.collecting_method,
			rec.collecting_source
			);
		dbms_output.put_line ('made new coll event');
		l_collecting_event_id := gcollecting_event_id;
		commit;
	end if;
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulkload_coll_event',collobjid);
END;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_make_bulkloader_locality  (collobjid IN number) 
is
aRec bulkloader%ROWTYPE;
determiner_id number;
geog_auth_rec_id geog_auth_rec.geog_auth_rec_id%TYPE;
gLocalityId locality.locality_id%TYPE;
gLatLongId lat_long.lat_long_id%TYPE;
BEGIN
	select * into aRec from bulkloader where collection_object_id=collobjid;
	IF aRec.locality_id is null then -- it should always be
		select geog_auth_rec_id into geog_auth_rec_id from geog_auth_rec where higher_geog = aRec.higher_geog;
		dbms_output.put_line('got a geog ID');
		select MAX(locality_id) + 1 into gLocalityId from locality;
		dbms_output.put_line('got a gLocalityId');
		select MAX(lat_long_id) + 1 into gLatLongId from lat_long;
		dbms_output.put_line('got gLatLongId');
		
		-- just insert the locality
		INSERT INTO locality (
			 LOCALITY_ID,
			 GEOG_AUTH_REC_ID,
			 MAXIMUM_ELEVATION,
			 MINIMUM_ELEVATION,
			 ORIG_ELEV_UNITS,
			 SPEC_LOCALITY,
			 LOCALITY_REMARKS,
			 DEPTH_UNITS,
			 MIN_DEPTH,
			 MAX_DEPTH
		) values (
			gLocalityId,
			geog_auth_rec_id,
			aRec.MAXIMUM_ELEVATION,
			aRec.MINIMUM_ELEVATION,
			 aRec.ORIG_ELEV_UNITS,
			 aRec.SPEC_LOCALITY,
			 aRec.LOCALITY_REMARKS,
			 aRec.DEPTH_UNITS,
			 aRec.MIN_DEPTH,
			 aRec.MAX_DEPTH);
			 dbms_output.put_line('made a locality');
		
		IF aRec.ORIG_LAT_LONG_UNITS is not null THEN
				 dbms_output.put_line('making a lat/long');
				select distinct(agent_id) into determiner_id from agent_name where agent_name = aRec.DETERMINED_BY_AGENT;
                    dbms_output.put_line('got determiner');
                    dbms_output.put_line(' aRec.ORIG_LAT_LONG_UNITS: ' ||  aRec.ORIG_LAT_LONG_UNITS);
			IF aRec.ORIG_LAT_LONG_UNITS = 'deg. min. sec.' THEN
					INSERT INTO lat_long (
						 LAT_LONG_ID,
						 LOCALITY_ID,
						 ORIG_LAT_LONG_UNITS,
						 DETERMINED_BY_AGENT_ID,
						 DETERMINED_DATE,
						 LAT_LONG_REF_SOURCE,
						 LAT_LONG_REMARKS,
						 MAX_ERROR_DISTANCE,
						 MAX_ERROR_UNITS,
						 ACCEPTED_LAT_LONG_FG,
						 GEOREFMETHOD,
						 VERIFICATIONSTATUS,
						 datum,
						 lat_deg,
						 long_deg,
						 lat_min,
						 lat_sec,
						 long_min,
						 long_sec,
						 lat_dir,
						 long_dir,
						 extent,
						 gpsaccuracy)
					values (
						gLatLongId,
						gLocalityId,
						aRec.ORIG_LAT_LONG_UNITS,
						determiner_id,
						 aRec.DETERMINED_DATE,
						 aRec.LAT_LONG_REF_SOURCE,
						 aRec.LAT_LONG_REMARKS,
						 aRec.MAX_ERROR_DISTANCE,
						 aRec.MAX_ERROR_UNITS,
						 1,
						 aRec.GEOREFMETHOD,
						 aRec.VERIFICATIONSTATUS,
						 aRec.datum,
						 aRec.latdeg,
						 aRec.longdeg,
						 aRec.latmin,
						 aRec.latsec,
						 aRec.longmin,
						 aRec.longsec,
						 aRec.latdir,
						 aRec.longdir,
						 aRec.extent,
						 aRec.gpsaccuracy);
				ELSIF aRec.ORIG_LAT_LONG_UNITS = 'decimal degrees' THEN
				    dbms_output.put_line('inserting decimal degrees....');
				    dbms_output.put_line('gLatLongId: ' || gLatLongId);
				    dbms_output.put_line('gLocalityId: ' || gLocalityId);
				    dbms_output.put_line('aRec.ORIG_LAT_LONG_UNITS: ' || aRec.ORIG_LAT_LONG_UNITS);
				    dbms_output.put_line('determiner_id: ' || determiner_id);
				    dbms_output.put_line('aRec.DETERMINED_DATE,: ' || aRec.DETERMINED_DATE);
				    dbms_output.put_line('aRec.LAT_LONG_REF_SOURCE: ' || aRec.LAT_LONG_REF_SOURCE);
				    dbms_output.put_line('aRec.LAT_LONG_REMARKS: ' || aRec.LAT_LONG_REMARKS);
				    dbms_output.put_line('aRec.MAX_ERROR_DISTANCE: ' || aRec.MAX_ERROR_DISTANCE);
				    dbms_output.put_line('aRec.MAX_ERROR_UNITS: ' || aRec.MAX_ERROR_UNITS);
				    dbms_output.put_line('aRec.GEOREFMETHOD: ' || aRec.GEOREFMETHOD);
				    dbms_output.put_line('aRec.VERIFICATIONSTATUS: ' || aRec.VERIFICATIONSTATUS);
				    dbms_output.put_line('aRec.datum: ' || aRec.datum);
				    dbms_output.put_line('aRec.dec_lat: ' || aRec.dec_lat);
				    dbms_output.put_line('aRec.dec_long: ' || aRec.dec_long);
				    dbms_output.put_line('aRec.extent: ' || aRec.EXTENT);
				    dbms_output.put_line('aRec.gpsaccuracy: ' || aRec.gpsaccuracy);
				     dbms_output.put_line('thats all folks ');
					INSERT INTO lat_long (
						 LAT_LONG_ID,
						 LOCALITY_ID,
						 ORIG_LAT_LONG_UNITS,
						 DETERMINED_BY_AGENT_ID,
						 DETERMINED_DATE,
						 LAT_LONG_REF_SOURCE,
						 LAT_LONG_REMARKS,
						 MAX_ERROR_DISTANCE,
						 MAX_ERROR_UNITS,
						 ACCEPTED_LAT_LONG_FG,
						 GEOREFMETHOD,
						 VERIFICATIONSTATUS,
						 datum,
						 dec_lat,
						 dec_long,
						 extent,
						 gpsaccuracy)
					values (
						gLatLongId,
						gLocalityId,
						aRec.ORIG_LAT_LONG_UNITS,
						determiner_id,
						 aRec.DETERMINED_DATE,
						 aRec.LAT_LONG_REF_SOURCE,
						 aRec.LAT_LONG_REMARKS,
						 aRec.MAX_ERROR_DISTANCE,
						 aRec.MAX_ERROR_UNITS,
						 1,
						 aRec.GEOREFMETHOD,
						 aRec.VERIFICATIONSTATUS,
						  aRec.datum,
						 aRec.dec_lat,
						 aRec.dec_long,
						 aRec.extent,
						 aRec.gpsaccuracy);
						 dbms_output.put_line('inserted DD');
				ELSIF aRec.ORIG_LAT_LONG_UNITS = 'UTM' THEN
					INSERT INTO lat_long (
						 LAT_LONG_ID,
						 LOCALITY_ID,
						 ORIG_LAT_LONG_UNITS,
						 DETERMINED_BY_AGENT_ID,
						 DETERMINED_DATE,
						 LAT_LONG_REF_SOURCE,
						 LAT_LONG_REMARKS,
						 MAX_ERROR_DISTANCE,
						 MAX_ERROR_UNITS,
						 ACCEPTED_LAT_LONG_FG,
						 GEOREFMETHOD,
						 VERIFICATIONSTATUS,
						 datum,
						 utm_ew,
						 utm_ns,
						 utm_zone,
						 extent,
						 gpsaccuracy)
					values (
						gLatLongId,
						gLocalityId,
						aRec.ORIG_LAT_LONG_UNITS,
						determiner_id,
						 aRec.DETERMINED_DATE,
						 aRec.LAT_LONG_REF_SOURCE,
						 aRec.LAT_LONG_REMARKS,
						 aRec.MAX_ERROR_DISTANCE,
						 aRec.MAX_ERROR_UNITS,
						 1,
						 aRec.GEOREFMETHOD,
						 aRec.VERIFICATIONSTATUS,
						  aRec.datum,						 
						 aRec.utm_ew,
						 aRec.utm_ns,
						 aRec.utm_zone,
						 aRec.extent,
						 aRec.gpsaccuracy);
				ELSIF aRec.ORIG_LAT_LONG_UNITS = 'degrees dec. minutes' THEN
					INSERT INTO lat_long (
						 LAT_LONG_ID,
						 LOCALITY_ID,
						 ORIG_LAT_LONG_UNITS,
						 DETERMINED_BY_AGENT_ID,
						 DETERMINED_DATE,
						 LAT_LONG_REF_SOURCE,
						 LAT_LONG_REMARKS,
						 MAX_ERROR_DISTANCE,
						 MAX_ERROR_UNITS,
						 ACCEPTED_LAT_LONG_FG,
						 GEOREFMETHOD,
						 VERIFICATIONSTATUS,
						 datum,
						 lat_deg,
						 DEC_LAT_MIN,
						 long_deg,
						 DEC_LONG_MIN,
						 lat_dir,
						 LONG_DIR,
						 extent,
						 gpsaccuracy)
					values (
						gLatLongId,
						gLocalityId,
						aRec.ORIG_LAT_LONG_UNITS,
						determiner_id,
						 aRec.DETERMINED_DATE,
						 aRec.LAT_LONG_REF_SOURCE,
						 aRec.LAT_LONG_REMARKS,
						 aRec.MAX_ERROR_DISTANCE,
						 aRec.MAX_ERROR_UNITS,
						 1,
						 aRec.GEOREFMETHOD,
						 aRec.VERIFICATIONSTATUS,
						 arec.datum,
						aRec.latdeg,
						 aRec.DEC_LAT_MIN,
						 aRec.longdeg,
						 aRec.DEC_LONG_MIN,
						 aRec.latdir,
						 aRec.longdir,
						 aRec.extent,
						 aRec.gpsaccuracy);
				ELSIF aRec.ORIG_LAT_LONG_UNITS = 'degrees dec. minutes' THEN
					INSERT INTO lat_long (
						 LAT_LONG_ID,
						 LOCALITY_ID,
						 ORIG_LAT_LONG_UNITS,
						 DETERMINED_BY_AGENT_ID,
						 DETERMINED_DATE,
						 LAT_LONG_REF_SOURCE,
						 LAT_LONG_REMARKS,
						 MAX_ERROR_DISTANCE,
						 MAX_ERROR_UNITS,
						 ACCEPTED_LAT_LONG_FG,
						 GEOREFMETHOD,
						 VERIFICATIONSTATUS,
						 datum,
						 utm_ns,
						 utm_ew,
						 utm_zone,
						 extent,
						 gpsaccuracy)
					values (
						gLatLongId,
						gLocalityId,
						aRec.ORIG_LAT_LONG_UNITS,
						determiner_id,
						 aRec.DETERMINED_DATE,
						 aRec.LAT_LONG_REF_SOURCE,
						 aRec.LAT_LONG_REMARKS,
						 aRec.MAX_ERROR_DISTANCE,
						 aRec.MAX_ERROR_UNITS,
						 1,
						 aRec.GEOREFMETHOD,
						 aRec.VERIFICATIONSTATUS,
						 arec.datum,
						 arec.utm_ns,
						 arec.utm_ew,
						 arec.utm_zone,
						 aRec.extent,
						 aRec.gpsaccuracy);
						 
				ELSE
					error_msg := 'got something hinky for units - choke and die...';
					raise failed_validation;
				END IF;
				    dbms_output.put_line('inserted lat/long');
			END IF;
			l_locality_id := gLocalityId;
	ELSE
		error_msg := 'Bad record passed to make_bulkload_locality';
		raise failed_validation;
	END IF; -- locid is null chech
	commit;
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_make_bulkloader_locality',collobjid);
END;



---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_bulkload_locality  (collobjid IN number) 
is
aRec bulkloader%ROWTYPE;
determiner_id number;
geog_auth_rec_id geog_auth_rec.geog_auth_rec_id%TYPE;
gLocalityId locality.locality_id%TYPE;
BEGIN
	--dbms_output.put_line ('locality thingy running...');
	select * into aRec from bulkloader where collection_object_id=collobjid;
	--dbms_output.put_line ('Good higher_geog');
	if aRec.locality_id is null then -- otherwise, we already have what we need
	    	select count(geog_auth_rec_id) into num from geog_auth_rec where higher_geog = aRec.higher_geog;
	    	if num != 1 then
        		error_msg := 'Bad higher_geog';
        		raise failed_validation;
        		--dbms_output.put_line ('');
	    	END IF;
		--dbms_output.put_line ('need to find or make a locality');
		select geog_auth_rec_id into geog_auth_rec_id from geog_auth_rec where higher_geog = aRec.higher_geog;
		select count(*) into num from locality where
			GEOG_AUTH_REC_ID = geog_auth_rec_id AND
			nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
			nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
			nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
			nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
			nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
			nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
			nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
			nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1)
			;
		dbms_output.put_line ('there is/are ' || num || ' matching locality, see if there is still one when we throw coordinates in');
		IF num > 0 THEN -- matching locality, see if there's still one when we throw coordinates in
			--dbms_output.put_line ('found > 0 localities - checking for coordinate matches');
			IF aRec.ORIG_LAT_LONG_UNITS is not null THEN
			     dbms_output.put_line ('Looking for locality with coordinates');
				select count(distinct(agent_id)) into num from agent_name where agent_name = aRec.DETERMINED_BY_AGENT;
				if num != 1 then
					error_msg := 'Bad DETERMINED_BY_AGENT';
					raise failed_validation;
					--dbms_output.put_line ('Bad DETERMINED_BY_AGENT');
				end if;
				select distinct(agent_id) into determiner_id from agent_name where agent_name = aRec.DETERMINED_BY_AGENT;
		
				--dbms_output.put_line ('there are coordinates for the new locality');
				IF aRec.ORIG_LAT_LONG_UNITS = 'deg. min. sec.' THEN
					--dbms_output.put_line ('ORIG_LAT_LONG_UNITS = deg. min. sec.');
					select count(*) into num from lat_long WHERE
						nvl(lat_deg,-1) = nvl(aRec.latdeg,-1) AND
						nvl(long_deg,-1) = nvl(aRec.longdeg,-1) AND
						nvl(lat_min,-1) = nvl(aRec.latmin,-1) AND
						nvl(lat_sec,-1) = nvl(aRec.latsec,-1) AND
						nvl(long_min,-1) = nvl(aRec.longmin,-1) AND
						nvl(long_sec,-1) = nvl(aRec.longsec,-1) AND
						nvl(lat_dir,'nuthin') = nvl(aRec.latdir,'nuthin') AND
						nvl(long_dir,'nuthin') = nvl(aRec.longdir,'nuthin') AND
						nvl(lat_dir,'DATUM') = nvl(aRec.latdir,'DATUM') AND
						--DETERMINED_BY_AGENT_ID = determiner_id AND
						DETERMINED_DATE = aRec.DETERMINED_DATE AND
						LAT_LONG_REF_SOURCE = aRec.LAT_LONG_REF_SOURCE AND
						nvl(LAT_LONG_REMARKS,'nuthin') = nvl(aRec.LAT_LONG_REMARKS,'nuthin') AND
						nvl(MAX_ERROR_UNITS,'nuthin') = nvl(aRec.MAX_ERROR_UNITS,'nuthin') AND
						nvl(MAX_ERROR_DISTANCE,-1) = nvl(aRec.MAX_ERROR_DISTANCE,-1) AND
						nvl(EXTENT,-1) = nvl(aRec.EXTENT,-1) AND
						nvl(GPSACCURACY,-1) = nvl(aRec.GPSACCURACY,-1) AND
						GEOREFMETHOD = aRec.GEOREFMETHOD AND
						VERIFICATIONSTATUS = aRec.VERIFICATIONSTATUS AND
						locality_id IN (
							select locality_id from locality where
								GEOG_AUTH_REC_ID = geog_auth_rec_id AND
								nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
								nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
								nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
								nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
								nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
								nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
								nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
								nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1)
						);
				ELSIF aRec.ORIG_LAT_LONG_UNITS = 'decimal degrees' THEN
					--dbms_output.put_line ('ORIG_LAT_LONG_UNITS = decimal degrees');
					select count(*) into num from lat_long WHERE
						nvl(dec_lat,-1) = nvl(aRec.dec_lat,-1) AND
						nvl(dec_long,-1) = nvl(aRec.dec_long,-1) AND
						nvl(DATUM,'nuthin') = nvl(aRec.DATUM,'nuthin') AND
						--DETERMINED_BY_AGENT_ID = determiner_id AND
						DETERMINED_DATE = aRec.DETERMINED_DATE AND
						LAT_LONG_REF_SOURCE = aRec.LAT_LONG_REF_SOURCE AND
						nvl(LAT_LONG_REMARKS,'nuthin') = nvl(aRec.LAT_LONG_REMARKS,'nuthin') AND
						nvl(MAX_ERROR_UNITS,'nuthin') = nvl(aRec.MAX_ERROR_UNITS,'nuthin') AND
						nvl(MAX_ERROR_DISTANCE,-1) = nvl(aRec.MAX_ERROR_DISTANCE,-1) AND
						nvl(EXTENT,-1) = nvl(aRec.EXTENT,-1) AND
						nvl(GPSACCURACY,-1) = nvl(aRec.GPSACCURACY,-1) AND
						GEOREFMETHOD = aRec.GEOREFMETHOD AND
						VERIFICATIONSTATUS = aRec.VERIFICATIONSTATUS AND
						locality_id IN (
							select locality_id from locality where
								GEOG_AUTH_REC_ID = geog_auth_rec_id AND
								nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
								nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
								nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
								nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
								nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
								nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
								nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
								nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1)
						);
				ELSIF aRec.ORIG_LAT_LONG_UNITS = 'degrees dec. minutes' THEN
					--dbms_output.put_line ('ORIG_LAT_LONG_UNITS = degrees dec. minutes');
					select count(*) into num from lat_long WHERE
						nvl(lat_deg,-1) = nvl(aRec.latdeg,-1) AND
						nvl(long_deg,-1) = nvl(aRec.longdeg,-1) AND
						nvl(dec_lat_min,-1) = nvl(aRec.dec_lat_min,-1) AND
						nvl(dec_long_min,-1) = nvl(aRec.dec_long_min,-1) AND
						nvl(lat_dir,'nuthin') = nvl(aRec.latdir,'nuthin') AND
						nvl(long_dir,'nuthin') = nvl(aRec.longdir,'nuthin') AND
						nvl(DATUM,'nuthin') = nvl(aRec.DATUM,'nuthin') AND
						--DETERMINED_BY_AGENT_ID = determiner_id AND
						DETERMINED_DATE = aRec.DETERMINED_DATE AND
						LAT_LONG_REF_SOURCE = aRec.LAT_LONG_REF_SOURCE AND
						nvl(LAT_LONG_REMARKS,'nuthin') = nvl(aRec.LAT_LONG_REMARKS,'nuthin') AND
						nvl(MAX_ERROR_UNITS,'nuthin') = nvl(aRec.MAX_ERROR_UNITS,'nuthin') AND
						nvl(MAX_ERROR_DISTANCE,-1) = nvl(aRec.MAX_ERROR_DISTANCE,-1) AND
						nvl(EXTENT,-1) = nvl(aRec.EXTENT,-1) AND
						nvl(GPSACCURACY,-1) = nvl(aRec.GPSACCURACY,-1) AND
						GEOREFMETHOD = aRec.GEOREFMETHOD AND
						VERIFICATIONSTATUS = aRec.VERIFICATIONSTATUS AND
						locality_id IN (
							select locality_id from locality where
								GEOG_AUTH_REC_ID = geog_auth_rec_id AND
								nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
								nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
								nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
								nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
								nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
								nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
								nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
								nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1)
						);	
				ELSIF aRec.ORIG_LAT_LONG_UNITS = 'UTM' THEN
					--dbms_output.put_line ('ORIG_LAT_LONG_UNITS = degrees dec. minutes');
					select count(*) into num from lat_long WHERE
						nvl(utm_ew,-1) = nvl(aRec.utm_ew,-1) AND
						nvl(utm_ns,-1) = nvl(aRec.utm_ns,-1) AND
						nvl(utm_zone,'nuthin') = nvl(aRec.utm_zone,'nuthin') AND
						nvl(DATUM,'nuthin') = nvl(aRec.DATUM,'nuthin') AND
						--DETERMINED_BY_AGENT_ID = determiner_id AND
						DETERMINED_DATE = aRec.DETERMINED_DATE AND
						LAT_LONG_REF_SOURCE = aRec.LAT_LONG_REF_SOURCE AND
						nvl(LAT_LONG_REMARKS,'nuthin') = nvl(aRec.LAT_LONG_REMARKS,'nuthin') AND
						nvl(MAX_ERROR_UNITS,'nuthin') = nvl(aRec.MAX_ERROR_UNITS,'nuthin') AND
						nvl(MAX_ERROR_DISTANCE,-1) = nvl(aRec.MAX_ERROR_DISTANCE,-1) AND
						nvl(EXTENT,-1) = nvl(aRec.EXTENT,-1) AND
						nvl(GPSACCURACY,-1) = nvl(aRec.GPSACCURACY,-1) AND
						GEOREFMETHOD = aRec.GEOREFMETHOD AND
						VERIFICATIONSTATUS = aRec.VERIFICATIONSTATUS AND
						locality_id IN (
							select locality_id from locality where
								GEOG_AUTH_REC_ID = geog_auth_rec_id AND
								nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
								nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
								nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
								nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
								nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
								nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
								nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
								nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1)
						);	
				ELSE -- coordiantes don't match any known format
					--dbms_output.put_line ('Lat Long Units not recognized - aborting');
					error_msg := 'Lat Long Units not recognized';
					raise failed_validation;
				END IF; -- end coordinate check
					--dbms_output.put_line ('matching latlong: ' || num);		
					IF num = 1 THEN
						-- repeat all this crap above to get the locality_id
						IF aRec.ORIG_LAT_LONG_UNITS = 'deg. min. sec.' THEN
							select lat_long.locality_id INTO gLocalityId from lat_long WHERE
								nvl(lat_deg,-1) = nvl(aRec.latdeg,-1) AND
								nvl(long_deg,-1) = nvl(aRec.longdeg,-1) AND
								nvl(lat_min,-1) = nvl(aRec.latmin,-1) AND
								nvl(lat_sec,-1) = nvl(aRec.latsec,-1) AND
								nvl(long_min,-1) = nvl(aRec.longmin,-1) AND
								nvl(long_sec,-1) = nvl(aRec.longsec,-1) AND
								nvl(lat_dir,'nuthin') = nvl(aRec.latdir,'nuthin') AND
								nvl(long_dir,'nuthin') = nvl(aRec.longdir,'nuthin') AND
								nvl(lat_dir,'DATUM') = nvl(aRec.latdir,'DATUM') AND
								--DETERMINED_BY_AGENT_ID = determiner_id AND
								DETERMINED_DATE = aRec.DETERMINED_DATE AND
								LAT_LONG_REF_SOURCE = aRec.LAT_LONG_REF_SOURCE AND
								nvl(LAT_LONG_REMARKS,'nuthin') = nvl(aRec.LAT_LONG_REMARKS,'nuthin') AND
								nvl(MAX_ERROR_UNITS,'nuthin') = nvl(aRec.MAX_ERROR_UNITS,'nuthin') AND
								nvl(MAX_ERROR_DISTANCE,-1) = nvl(aRec.MAX_ERROR_DISTANCE,-1) AND
								nvl(EXTENT,-1) = nvl(aRec.EXTENT,-1) AND
								nvl(GPSACCURACY,-1) = nvl(aRec.GPSACCURACY,-1) AND
								GEOREFMETHOD = aRec.GEOREFMETHOD AND
								VERIFICATIONSTATUS = aRec.VERIFICATIONSTATUS AND
								locality_id IN (
									select locality_id from locality where
										GEOG_AUTH_REC_ID = geog_auth_rec_id AND
										nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
										nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
										nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
										nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
										nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
										nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
										nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
										nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1)
								);
						ELSIF aRec.ORIG_LAT_LONG_UNITS = 'UTM' THEN
							select lat_long.locality_id INTO gLocalityId from lat_long WHERE
								nvl(utm_ns,-1) = nvl(aRec.utm_ns,-1) AND
								nvl(utm_ew,-1) = nvl(aRec.utm_ew,-1) AND
								nvl(utm_zone,'nuthin') = nvl(aRec.utm_zone,'nuthin') AND
								nvl(long_dir,'nuthin') = nvl(aRec.longdir,'nuthin') AND
								--DETERMINED_BY_AGENT_ID = determiner_id AND
								DETERMINED_DATE = aRec.DETERMINED_DATE AND
								LAT_LONG_REF_SOURCE = aRec.LAT_LONG_REF_SOURCE AND
								nvl(LAT_LONG_REMARKS,'nuthin') = nvl(aRec.LAT_LONG_REMARKS,'nuthin') AND
								nvl(MAX_ERROR_UNITS,'nuthin') = nvl(aRec.MAX_ERROR_UNITS,'nuthin') AND
								nvl(MAX_ERROR_DISTANCE,-1) = nvl(aRec.MAX_ERROR_DISTANCE,-1) AND
								nvl(EXTENT,-1) = nvl(aRec.EXTENT,-1) AND
								nvl(GPSACCURACY,-1) = nvl(aRec.GPSACCURACY,-1) AND
								GEOREFMETHOD = aRec.GEOREFMETHOD AND
								VERIFICATIONSTATUS = aRec.VERIFICATIONSTATUS AND
								locality_id IN (
									select locality_id from locality where
										GEOG_AUTH_REC_ID = geog_auth_rec_id AND
										nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
										nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
										nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
										nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
										nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
										nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
										nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
										nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1)
								);
						ELSIF aRec.ORIG_LAT_LONG_UNITS = 'decimal degrees' THEN
							--dbms_output.put_line ('decimal degrees');		
							
							select lat_long.locality_id INTO gLocalityId  from lat_long WHERE
								nvl(dec_lat,-1) = nvl(aRec.dec_lat,-1) AND
								nvl(dec_long,-1) = nvl(aRec.dec_long,-1) AND
								nvl(DATUM,'nuthin') = nvl(aRec.DATUM,'nuthin') AND
								--DETERMINED_BY_AGENT_ID = determiner_id AND
								DETERMINED_DATE = aRec.DETERMINED_DATE AND
								LAT_LONG_REF_SOURCE = aRec.LAT_LONG_REF_SOURCE AND
								nvl(LAT_LONG_REMARKS,'nuthin') = nvl(aRec.LAT_LONG_REMARKS,'nuthin') AND
								nvl(MAX_ERROR_UNITS,'nuthin') = nvl(aRec.MAX_ERROR_UNITS,'nuthin') AND
								nvl(MAX_ERROR_DISTANCE,-1) = nvl(aRec.MAX_ERROR_DISTANCE,-1) AND
								nvl(EXTENT,-1) = nvl(aRec.EXTENT,-1) AND
								nvl(GPSACCURACY,-1) = nvl(aRec.GPSACCURACY,-1) AND
								GEOREFMETHOD = aRec.GEOREFMETHOD AND
								VERIFICATIONSTATUS = aRec.VERIFICATIONSTATUS AND
								locality_id IN (
									select locality_id from locality where
										GEOG_AUTH_REC_ID = geog_auth_rec_id AND
										nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
										nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
										nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
										nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
										nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
										nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
										nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
										nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1)
								);
						ELSIF aRec.ORIG_LAT_LONG_UNITS = 'degrees dec. minutes' THEN
							select lat_long.locality_id INTO gLocalityId from lat_long WHERE
								nvl(lat_deg,-1) = nvl(aRec.latdeg,-1) AND
								nvl(long_deg,-1) = nvl(aRec.longdeg,-1) AND
								nvl(dec_lat_min,-1) = nvl(aRec.dec_lat_min,-1) AND
								nvl(dec_long_min,-1) = nvl(aRec.dec_long_min,-1) AND
								nvl(lat_dir,'nuthin') = nvl(aRec.latdir,'nuthin') AND
								nvl(long_dir,'nuthin') = nvl(aRec.longdir,'nuthin') AND
								nvl(DATUM,'nuthin') = nvl(aRec.DATUM,'nuthin') AND
								--DETERMINED_BY_AGENT_ID = determiner_id AND
								DETERMINED_DATE = aRec.DETERMINED_DATE AND
								LAT_LONG_REF_SOURCE = aRec.LAT_LONG_REF_SOURCE AND
								nvl(LAT_LONG_REMARKS,'nuthin') = nvl(aRec.LAT_LONG_REMARKS,'nuthin') AND
								nvl(MAX_ERROR_UNITS,'nuthin') = nvl(aRec.MAX_ERROR_UNITS,'nuthin') AND
								nvl(MAX_ERROR_DISTANCE,-1) = nvl(aRec.MAX_ERROR_DISTANCE,-1) AND
								nvl(EXTENT,-1) = nvl(aRec.EXTENT,-1) AND
								nvl(GPSACCURACY,-1) = nvl(aRec.GPSACCURACY,-1) AND
								GEOREFMETHOD = aRec.GEOREFMETHOD AND
								VERIFICATIONSTATUS = aRec.VERIFICATIONSTATUS AND
								locality_id IN (
									select locality_id from locality where
										GEOG_AUTH_REC_ID = geog_auth_rec_id AND
										nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
										nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
										nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
										nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
										nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
										nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
										nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
										nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1)
								);	
						ELSE
							-- got something hinky for units - choke and die...
							error_msg := 'Bad coordinate units';
							raise failed_validation;
						END IF;
						--dbms_output.put_line ('got matching locality');
						l_locality_id := gLocalityId;
						--dbms_output.put_line ('got matching locality');
						-- dbms_output.put_line ('yea yea, spiffy - get gLocalityId: ' || gLocalityId );		
					ELSIF num = 0 THEN
					    dbms_output.put_line ('going off to make a new locality');
						-- nothing matched, make a locality
						--dbms_output.put_line ('mak new locality with no coords');
						--dbms_output.put_line ('mak new locality with no coords');
						b_make_bulkloader_locality(collobjid);
					ELSE
						-- >1, choke and die
						--dbms_output.put_line ('too many mathces - dups found - die die die');
						error_msg := 'More than one matching locality exists; this application cannot handle that';
						raise failed_validation;
						--dbms_output.put_line ('too many mathces - dups found - die die die');
					END IF;
					
			ELSE
				--dbms_output.put_line ('need locality without any coordinates');
				-- need locality without any coordinates
				/*
				select count(*)  INTO num from locality WHERE
					GEOG_AUTH_REC_ID = geog_auth_rec_id AND
					nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
					nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
					nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
					nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
					nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
					nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
					nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
					nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1) AND
					locality_id NOT IN (select locality_id from accepted_lat_long);
					
					--dbms_output.put_line ('select count(*)  from locality WHERE
					GEOG_AUTH_REC_ID = ' || geog_auth_rec_id || ' AND
					nvl(SPEC_LOCALITY,''nuthin'') = nvl( ''' || aRec.SPEC_LOCALITY || ''',''nuthin'') AND
					nvl(LOCALITY_REMARKS,''nuthin'') = nvl(''' || aRec.LOCALITY_REMARKS ||  ''',''nuthin'') AND
					locality_id NOT IN (select locality_id from accepted_lat_long);');
					
				*/
				select count(*)  INTO num from locality WHERE
					GEOG_AUTH_REC_ID = geog_auth_rec_id AND
					nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
					nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
					nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
					nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
					nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
					nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
					nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
					nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1) AND
					locality_id NOT IN (select locality_id from accepted_lat_long);
										
				dbms_output.put_line ('there are ' || num || 'coordinate-less localities');
				IF num > 0 then
					select MIN(locality_id)  INTO gLocalityId from locality WHERE
					GEOG_AUTH_REC_ID = geog_auth_rec_id AND
					nvl(MAXIMUM_ELEVATION,-1) = nvl(aRec.MAXIMUM_ELEVATION,-1) AND
					nvl(MINIMUM_ELEVATION,-1) = nvl(aRec.MINIMUM_ELEVATION,-1) AND
					nvl(ORIG_ELEV_UNITS,'nuthin') = nvl(aRec.ORIG_ELEV_UNITS,'nuthin') AND
					nvl(SPEC_LOCALITY,'nuthin') = nvl(aRec.SPEC_LOCALITY,'nuthin') AND
					nvl(LOCALITY_REMARKS,'nuthin') = nvl(aRec.LOCALITY_REMARKS,'nuthin') AND
					nvl(DEPTH_UNITS,'nuthin') = nvl(aRec.DEPTH_UNITS,'nuthin') AND
					nvl(MIN_DEPTH,-1) = nvl(aRec.MIN_DEPTH,-1) AND
					nvl(MAX_DEPTH,-1) = nvl(aRec.MAX_DEPTH,-1) AND
					locality_id NOT IN (select locality_id from accepted_lat_long);
					l_locality_id := gLocalityId;
					--dbms_output.put_line ('found locality with no coords');
					--dbms_output.put_line ('yea yea, spiffy - get gLocalityId: ' || gLocalityId );	
				ELSE
					--dbms_output.put_line ('going off to make a locality');
					-- nothing, make a locality
					b_make_bulkloader_locality(collobjid);
					dbms_output.put_line ('makem new - no coords');
				END IF;
				
				--dbms_output.put_line ('going off to make a locality');
				-- null orig units = no coordinates
			END IF;
			
		
		ELSE
			-- create a locality
			-- dbms_output.put_line ('makem new ');
			--dbms_output.put_line ('going off to make a locality');
			b_make_bulkloader_locality(collobjid);
		END IF;
	else
		-- there's a pre-specificed locality_id
		select locality_id into gLocalityId from bulkloader where collection_object_id = collobjid;
		select count(*)  into num from locality where locality_id=gLocalityId;
		if num = 1 then
			l_locality_id := gLocalityId;
		else
			error_msg := 'Bulkloader.locality_id does not resolve to a valid locality';
			raise failed_validation;
		end if;
	END IF; -- locid is null check
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulkload_locality',collobjid);
END;
        

---------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE b_build_keys_table (collobjid IN number) 
is
rec bulkloader%ROWTYPE;
taxa_one varchar2(255);
taxa_two varchar2(255);
BEGIN
l_collection_object_id  := NULL;
l_collecting_event_id := NULL;
l_entered_person_id := NULL;
l_accn_id := NULL;
l_taxa_formula := NULL;
l_id_made_by_agent_id := NULL;
l_cat_num := NULL;
l_collection_id := NULL;
l_locality_id := NULL;
l_taxon_name_id_1 := NULL;
l_taxon_name_id_2 := NULL;

	
	select * into rec from bulkloader where collection_object_id=collobjid;
	select max(collection_object_id) + 1 into l_collection_object_id from coll_object;
	
	if rec.cat_num is null then
		select max(cat_num) + 1 into l_cat_num from cataloged_item,collection
		where cataloged_item.collection_id = collection.collection_id and
		collection.collection_cde=rec.collection_cde and 
		collection.institution_acronym = rec.institution_acronym;
	else
		select count(cat_num) into num from cataloged_item,collection
		where cataloged_item.collection_id = collection.collection_id and
		collection.collection_cde=rec.collection_cde and 
		collection.institution_acronym = rec.institution_acronym and
		cat_num=rec.cat_num;
		if num = 1 then
			error_msg := 'Bad CAT_NUM';
			raise failed_validation;
		else
			l_cat_num := rec.cat_num;
		end if;
	end if;

	select count(distinct(collection_id)) into num from collection where collection_cde=rec.collection_cde and
		institution_acronym = rec.institution_acronym;
	if num != 1 then
		error_msg := 'Bad Bad collection_cde and institution_acronym';
		raise failed_validation;
	else
		select distinct(collection_id) into l_collection_id from collection where collection_cde=rec.collection_cde and
			institution_acronym = rec.institution_acronym;
	end if;
	
	select count(distinct(agent_id)) into num from agent_name where agent_name = rec.ENTEREDBY
		AND agent_name_type != 'Kew abbr.';
	
	if num != 1 then
		error_msg := 'Bad ENTEREDBY';
		raise failed_validation;
	else
		select distinct(agent_id) into l_entered_person_id from agent_name where agent_name = rec.ENTEREDBY
    		AND agent_name_type != 'Kew abbr.';
	end if;
	IF rec.accn LIKE '[%' AND rec.accn LIKE '%]%' THEN
	     -- trans.institution in accn number
    	tempStr :=  substr(rec.accn, instr(rec.accn,'[',1,1) + 1,instr(rec.accn,']',1,1) -2);
    	tempStr2 := REPLACE(rec.accn,'['||tempStr||']');
      ELSE
        -- use institution_acronym	
        tempStr := rec.institution_acronym;
        tempStr2 := rec.accn;
	END IF;
	    
    select count(distinct(accn.transaction_id)) into num from accn,trans where 
    	accn.transaction_id = trans.transaction_id and
    	institution_acronym = tempStr and
    	accn_number = tempStr2;
    	if num != 1 then
    		error_msg := 'Bad accn: ' || rec.accn;
    		raise failed_validation;
    	else
    		select accn.transaction_id into l_accn_id from accn,trans where 
    		accn.transaction_id = trans.transaction_id and
    		institution_acronym = tempStr and
    		accn_number = tempStr2;
    	end if;
  
	if instr(rec.taxon_name,' or ') > 1 then
		num := instr(rec.taxon_name, ' or ') -1;
		taxa_one := substr(rec.taxon_name,1,num);
		taxa_two := substr(rec.taxon_name,num+5);
		l_taxa_formula := 'A or B';
	elsif instr(rec.taxon_name,' x ') > 1 then
		num := instr(rec.taxon_name, ' x ') -1;
		taxa_one := substr(rec.taxon_name,1,num);
		taxa_two := substr(rec.taxon_name,num+4);
		l_taxa_formula := 'A x B';			
	elsif  substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' sp.' then
		l_taxa_formula := 'A sp.';
		taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
	elsif substr(rec.taxon_name,length(rec.taxon_name) - 1) = ' ?' then
		l_taxa_formula := 'A ?';
		taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 1);
	elsif substr(rec.taxon_name,length(rec.taxon_name) - 3) = ' cf.' then
		l_taxa_formula := 'A cf.';
		taxa_one := substr(rec.taxon_name,1,length(rec.taxon_name) - 3);
	else
		l_taxa_formula := 'A';
		taxa_one := rec.taxon_name;
	end if;
	if taxa_two is not null AND (
		  substr(taxa_one,length(taxa_one) - 3) = ' sp.' OR
			substr(taxa_two,length(taxa_two) - 3) = ' sp.' OR
			substr(taxa_one,length(taxa_one) - 1) = ' ?' OR
			substr(taxa_two,length(taxa_two) - 1) = ' ?' 
		) then
			error_msg := '"sp." and "?" are not allowed in multi-taxon IDs';
			raise failed_validation;	
	end if;
	if taxa_one is not null then
		select count(distinct(taxon_name_id)) into num from taxonomy where scientific_name = trim(taxa_one) and VALID_CATALOG_TERM_FG = 1;
		if num = 1 then
			select distinct(taxon_name_id) into l_taxon_name_id_1 from taxonomy where scientific_name = trim(taxa_one) and VALID_CATALOG_TERM_FG = 1;
		else
			error_msg := 'Taxonomy (' || taxa_one || ') < not found';
			raise failed_validation;
		end if;
	end if;
	if taxa_two is not null then
		select count(distinct(taxon_name_id)) into num from taxonomy where scientific_name = trim(taxa_two) and VALID_CATALOG_TERM_FG = 1;
		if num = 1 then
			select distinct(taxon_name_id) into l_taxon_name_id_2 from taxonomy where scientific_name = trim(taxa_two) and VALID_CATALOG_TERM_FG = 1;
		else
			error_msg := 'Taxonomy (' || taxa_two || ') not found';
			raise failed_validation;	
		end if;
	end if;
	
	select count(distinct(agent_id)) into num from agent_name where agent_name = rec.ID_MADE_BY_AGENT;
	if num != 1 then
		error_msg := 'ID_MADE_BY_AGENT (' || rec.ID_MADE_BY_AGENT || ') not found';
		raise failed_validation;
	else
		select distinct(agent_id) into l_id_made_by_agent_id from agent_name where agent_name = rec.ID_MADE_BY_AGENT;
	end if;
	
	if l_collection_object_id IS NULL OR
		l_entered_person_id  IS NULL OR
		l_accn_id  IS NULL OR
		l_taxon_name_id_1  IS NULL OR
		l_taxa_formula  IS NULL OR
		l_id_made_by_agent_id  IS NULL OR
		l_cat_num  IS NULL OR
		l_collection_id  IS NULL THEN
		error_msg := 'Failed to set key values at b_build_keys_table';
		raise failed_validation;
	end if;
	

	insert into bulkloader_attempts (
		b_collection_object_id,
 		collection_object_id,
 		tstamp 
 	) values (
 		rec.collection_object_id,
 		l_collection_object_id,
 		sysdate
 	);
 	
 	commit;
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_build_keys_table',collobjid);
END;

---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE b_bulk_this is
	CURSOR rec_cursor IS
		SELECT collection_object_id from bulkloader where loaded is null and collection_object_id > 10;
	n_collection_object_id cataloged_item.collection_object_id%TYPE;
	n_clocality_id locality.locality_id%TYPE;
	--error_msg varchar2(4000);  
	collobjid cataloged_item.collection_object_id%TYPE;
	l_loaded bulkloader.loaded%TYPE;
begin
	--b_bulk_disable;	
	FOR rec IN rec_cursor LOOP
		error_msg := NULL;
		collobjid := rec.collection_object_id;
		b_build_keys_table(collobjid);
		if error_msg is null then
			b_bulkload_locality(collobjid);
		end if;
		if error_msg is null then
			b_bulkload_coll_event(collobjid);
		end if;
		if error_msg is null then
			b_bulkload(collobjid);
		end if;
		if error_msg is null then
			b_bulkload_otherid(collobjid);
		end if;
		if error_msg is null then
			b_bulkload_parts(collobjid);
		end if;
		if error_msg is null then
			b_bulkload_attribute(collobjid);
		end if;		
		
		if error_msg is null then
			delete from bulkloader where collection_object_id = collobjid;
			--update bulkloader set loaded = 'spiffification complete' where collection_object_id = collobjid;
		else
			b_rollback_bulkloader (l_collection_object_id,collobjid);
		end if;	
		
		--b_bulk_makeflat(rec.collection_object_id);
		commit;
		/*
		select loaded into l_loaded from bulkloader where collection_object_id = collobjid;
			if l_loaded is null then
				
			end if;
		
		--b_bulk_makeflat(rec.collection_object_id);
		commit;
		*/
	end loop;
	
	--b_bulk_enable;
EXCEPTION
	when others then
		bulkload_error (error_msg,SQLERRM,'b_bulk_this',collobjid);


end;
---------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE check_and_load is
	num number;
begin
	-- relies on table proc_bl_status:
	-- create table proc_bl_status (status number(1));
	select count(*) into num from proc_bl_status;
	if num != 1 then
		delete from proc_bl_status;
		insert into proc_bl_status (status) values (0);
		commit;
	end if;
	select status into num from proc_bl_status;
	if num = 0 then
		-- lock this process
		update proc_bl_status set status=1;
		commit;
		bulkloader_check;
		b_bulk_this;
		-- update status table to indicate loading attempt complete
		update proc_bl_status set status=0;
		commit;
	end if;
end;
---------------------------------------------------------------------------------------------------------------------------------------------


END;
/
sho err

