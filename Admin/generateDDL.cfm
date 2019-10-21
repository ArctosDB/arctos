<cfinclude template="/includes/_header.cfm">
<p>
	Random generated code that's useful in various places.
</p>
<cfoutput>
	<cfset s="">
	<cfloop from ="1" to="16" index="i">
		<cfset s=s & chr(10) & "if r.GEOLOGY_ATTRIBUTE_#i# is not null then">
		<cfset s=s & chr(10) & chr(9) & 'insert into geology_attributes ('>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "GEOLOGY_ATTRIBUTE_ID,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "LOCALITY_ID,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "GEOLOGY_ATTRIBUTE,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "GEO_ATT_VALUE,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "GEO_ATT_DETERMINER_ID,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "GEO_ATT_DETERMINED_DATE,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "GEO_ATT_DETERMINED_METHOD,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "GEO_ATT_REMARK">
		<cfset s=s & chr(10) & chr(9) & ') values ('>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "sq_GEOLOGY_ATTRIBUTE_ID.nextval,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "sq_locality_id.currval,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "r.GEOLOGY_ATTRIBUTE_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "r.GEO_ATT_VALUE_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "getAgentID(r.GEO_ATT_DETERMINER_ID_#i#),">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "r.GEO_ATT_DETERMINED_DATE_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "r.GEO_ATT_DETERMINED_METHOD_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "r.GEO_ATT_REMARK_#i#">
		<cfset s=s & chr(10) & chr(9) & ');'>
		<cfset s=s & chr(10) & "end if;">
	</cfloop>
	<textarea rows="100" cols="150">
		#s#
	</textarea>
	<cfset s="">
	<cfloop from ="1" to="10" index="i">
		<cfset s=s & chr(10) & "if rec.attribute_value_#i# is not null and rec.attribute_#i# is not null then">
		<cfset s=s & chr(10) & chr(9) & 'insert into attributes ('>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "attribute_id,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "collection_object_id,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "determined_by_agent_id,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "attribute_type,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "attribute_value,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "attribute_units,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "attribute_remark,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "determination_method,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "determined_date">
		<cfset s=s & chr(10) & chr(9) & ") values (">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "nextval('sq_attribute_id'),">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "l_collection_object_id,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "getAgentId(rec.attribute_determiner_#i#),">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "rec.attribute_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "rec.attribute_value_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "rec.attribute_units_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "rec.attribute_remarks_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "rec.attribute_det_meth_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "rec.attribute_date_#i#">
		<cfset s=s & chr(10) & chr(9) & ");">
		<cfset s=s & chr(10) & "end if;">
	</cfloop>
	<textarea rows="100" cols="150">
		#s#
	</textarea>
	<cfset s="">
	<cfloop from ="1" to="12" index="i">
		<cfset s=s & chr(10) & "if rec.PART_NAME_#i# is not null then">
		<cfset s=s & chr(10) & chr(9) & 'INSERT INTO coll_object ('>
		<cfset s=s & chr(10) & chr(9) &  chr(9) & 'COLLECTION_OBJECT_ID,'>
		<cfset s=s & chr(10) & chr(9) &  chr(9) & 'COLL_OBJECT_TYPE,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'ENTERED_PERSON_ID,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'COLL_OBJECT_ENTERED_DATE,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'COLL_OBJ_DISPOSITION,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'LOT_COUNT,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'CONDITION'>
		<cfset s=s & chr(10) & chr(9) & ') values ('>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "nextval('sq_collection_object_id'),">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "'SP',">
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'l_entered_person_id,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'CURRENT_TIMESTAMP,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'rec.PART_DISPOSITION_#i#,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'rec.PART_LOT_COUNT_#i#::int,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'rec.PART_CONDITION_#i#'>
		<cfset s=s & chr(10) & chr(9) & ');'>
		<cfset s=s & chr(10) & chr(9) & 'INSERT INTO specimen_part ('>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'COLLECTION_OBJECT_ID,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'PART_NAME,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'DERIVED_FROM_CAT_ITEM'>
		<cfset s=s & chr(10) & chr(9) & ') values ('>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "currval('sq_collection_object_id'),">
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'rec.PART_NAME_#i#,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'l_collection_object_id'>
		<cfset s=s & chr(10) & chr(9) & ');'>
		<cfset s=s & chr(10) & chr(9) & 'if rec.part_remark_#i# is not null then'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'INSERT INTO coll_object_remark ('>
		<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & 'collection_object_id,'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & 'coll_object_remarks'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & ') values ('>
		<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & "currval('sq_collection_object_id'),">
		<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & "rec.part_remark_#i#">
		<cfset s=s & chr(10) & chr(9) & chr(9) & ');'>
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & 'if rec.part_barcode_#i# is not null then'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "SELECT container_id INTO r_container_id FROM coll_obj_cont_hist WHERE collection_object_id = currval('sq_collection_object_id');">
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'UPDATE container SET '>
		<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & 'parent_container_id = (select container_id from container where barcode=rec.part_barcode_#i#)'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & 'WHERE'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & "container_id = r_container_id;">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & "end if;">
	</cfloop>
	<textarea rows="100" cols="150">
		#s#
	</textarea>
	<cfset s="">
	<cfloop from ="1" to="5" index="i">
		<cfset s=s & chr(10) & "if rec.OTHER_ID_NUM_#i# is not null then">
		<cfset s=s & chr(10) & chr(9) & 'call parse_other_id (l_collection_object_id,rec.OTHER_ID_NUM_#i#,rec.other_id_num_type_#i#,rec.other_id_references_#i#);'>
		<cfset s=s & chr(10) & "end if;">
	</cfloop>
	<textarea rows="100" cols="150">
		#s#
	</textarea>
	<cfset s="">
	<cfloop from ="1" to="6" index="i">
		<cfset s=s & chr(10) & "if rec.collector_agent_#i# is not null then">
		<cfset s=s & chr(10) & chr(9) & 'insert into collector ('>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "collector_id,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "COLLECTION_OBJECT_ID,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "AGENT_ID,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "COLLECTOR_ROLE,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "COLL_ORDER">
		<cfset s=s & chr(10) & chr(9) & ") values (">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "nextval('sq_collector_id'),">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "l_collection_object_id,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "getAgentId(rec.collector_agent_#i#),">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "rec.collector_role_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "#i#">
		<cfset s=s & chr(10) & chr(9) & ");">
		<cfset s=s & chr(10) & "end if;">
	</cfloop>
	<textarea rows="100" cols="150">
		#s#
	</textarea>
	<cfset s="">
	<cfloop from ="1" to="6" index="i">
		<cfset s=s & chr(10) & "if rec.geology_attribute_#i# is not null then">
		<cfset s=s & chr(10) & chr(9) & 'insert into geology_attributes ('>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "geology_attribute_id,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "locality_id,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "geology_attribute,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "geo_att_value,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "geo_att_determiner_id,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "geo_att_determined_date,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "geo_att_determined_method,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "geo_att_remark">
		<cfset s=s & chr(10) & chr(9) & ") values (">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "nextval('sq_geology_attribute_id'),">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "l_locality_id,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "rec.geology_attribute_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "rec.geo_att_value_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "getAgentId(rec.geo_att_determiner_#i#),">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "to_date(rec.geo_att_determined_date_#i#,'YYYY-MM-DD'),">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "rec.geo_att_determined_method_#i#,">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "rec.geo_att_remark_#i#">
		<cfset s=s & chr(10) & chr(9) & ");">
		<cfset s=s & chr(10) & "end if;">
	</cfloop>
	<textarea rows="100" cols="150">
		#s#
	</textarea>
	<cfset s="">
	<cfloop from ="1" to="10" index="i">
		<cfset s=s & chr(10) & "IF rec.ATTRIBUTE_#i# is not null and rec.ATTRIBUTE_VALUE_#i# is not null THEN">
		<cfset s=s & chr(10) & chr(9) & 'select isValidAttribute(rec.ATTRIBUTE_#i#,rec.ATTRIBUTE_VALUE_#i#,rec.ATTRIBUTE_UNITS_#i#,r_collection_cde) INTO STRICT numRecs;'>
		<cfset s=s & chr(10) & chr(9) & 'if numRecs = 0 then'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'ATTRIBUTE_#i# is not valid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & "if rec.ATTRIBUTE_DATE_#i# is null or is_iso8601(rec.ATTRIBUTE_DATE_#i#,1) != 'valid' then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'ATTRIBUTE_DATE_#i# is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & "numRecs := isValidAgent(rec.ATTRIBUTE_DETERMINER_#i#);">
		<cfset s=s & chr(10) & chr(9) & "if numRecs !=1 then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'ATTRIBUTE_DETERMINER_#i# [ ' || coalesce(rec.ATTRIBUTE_DETERMINER_#i#,'NULL') || ' ] matches ' || numRecs || ' agents';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10)  & 'end if;'>
	</cfloop>
	<textarea rows="100" cols="150">
		#s#
	</textarea>
	<cfset s="">
	<cfloop from ="1" to="12" index="i">
		<cfset s=s & chr(10) & "if rec.PART_NAME_#i# is not null THEN">
		<cfset s=s & chr(10) & chr(9) & "SELECT count(*) INTO STRICT numRecs FROM ctspecimen_part_name WHERE PART_NAME = rec.PART_NAME_#i# AND collection_cde = r_collection_cde;">
		<cfset s=s & chr(10) & chr(9) & "IF numRecs = 0 THEN">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'PART_NAME_#i# [ ' || coalesce(rec.PART_NAME_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & "if rec.PART_CONDITION_#i# is null then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'PART_CONDITION_#i# [ ' || coalesce(rec.PART_CONDITION_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & "if rec.PART_BARCODE_#i# is not null then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "SELECT count(*) INTO STRICT numRecs FROM container WHERE barcode = rec.PART_BARCODE_#i#;">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "if numRecs = 0 then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & "thisError :=  'PART_BARCODE_#i# [ ' || coalesce(rec.PART_BARCODE_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "END IF;">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "SELECT count(*) INTO STRICT numRecs FROM container WHERE container_type !='cryovial label' AND container_type LIKE '%label%' AND barcode = rec.PART_BARCODE_#i#;">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "if numRecs != 0 then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & "thisError :=  'PART_BARCODE_#i# [ ' || coalesce(rec.PART_BARCODE_#i#,'NULL') || ' ] is a label';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "END IF;">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & 'if rec.PART_LOT_COUNT_#i# is null or is_number(rec.PART_LOT_COUNT_#i#) = 0 then'>
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'PART_LOT_COUNT_#i# [ ' || coalesce(rec.PART_LOT_COUNT_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & 'SELECT count(*) INTO STRICT numRecs FROM ctcoll_obj_disp WHERE COLL_OBJ_DISPOSITION = rec.PART_DISPOSITION_#i#;'>
		<cfset s=s & chr(10) & chr(9) & 'if numRecs = 0 then'>
		<cfset s=s & chr(10) & chr(9) & chr(9)  & "thisError := 'PART_DISPOSITION_#i# [ ' || coalesce(rec.PART_DISPOSITION_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9)  & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) &  "END IF;">
		<cfset s=s & chr(10) & 'end if;'>
	</cfloop>
	<textarea rows="100" cols="150">
		#s#
	</textarea>
	<cfset s="">
	<cfloop from ="1" to="5" index="i">
		<cfset s=s & chr(10) & "if rec.OTHER_ID_NUM_#i# is not null THEN">
		<cfset s=s & chr(10) & chr(9) & "SELECT count(*) INTO STRICT numRecs FROM ctcoll_other_id_type WHERE OTHER_ID_TYPE = rec.OTHER_ID_NUM_TYPE_#i#;">
		<cfset s=s & chr(10) & chr(9) & "if numRecs = 0 then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'OTHER_ID_NUM_TYPE_#i# [ ' || coalesce(rec.OTHER_ID_NUM_TYPE_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & 'end if;'>
	</cfloop>
	<textarea rows="100" cols="150">
		#s#
	</textarea>
	<cfset s="">
	<cfloop from ="1" to="8" index="i">
		<cfset s=s & chr(10) & "if rec.COLLECTOR_AGENT_#i# is not null THEN">
		<cfset s=s & chr(10) & chr(9) & "SELECT count(*) INTO STRICT numRecs FROM ctcollector_role WHERE collector_role = rec.COLLECTOR_ROLE_#i#;">
		<cfset s=s & chr(10) & chr(9) & "if numRecs != 1 then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'COLLECTOR_ROLE_#i# [ ' || coalesce(rec.COLLECTOR_ROLE_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & chr(9) & 'numRecs := isValidAgent(rec.COLLECTOR_AGENT_#i#);'>
		<cfset s=s & chr(10) & chr(9) & "if numRecs != 1 then">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "thisError :=  'COLLECTOR_AGENT_#i# [ ' || coalesce(rec.COLLECTOR_AGENT_#i#,'NULL') || ' ] is invalid';">
		<cfset s=s & chr(10) & chr(9) & chr(9) & "allError:=concat_ws('; ',allError,thisError);">
		<cfset s=s & chr(10) & chr(9) & 'end if;'>
		<cfset s=s & chr(10) & 'end if;'>
	</cfloop>
	<textarea rows="100" cols="150">
		#s#
	</textarea>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
