<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
<cfoutput>
	<cfquery name="gp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select guid_prefix from collection order by guid_prefix
	</cfquery>
	<cfparam name="collection" default="">
	<form action="loaded_specimen_extras.cfm" method="post">
		<label for="collection">Collection</label>
		<select name="collection">
			<option value=""></option>
			<cfloop query="gp">
				<option <cfif collection is guid_prefix>selected="selected"</cfif> value="#guid_prefix#">#guid_prefix#</option>
			</cfloop>
		</select>
		<input type="submit" value="filter">
	</form>
	<cfquery name="cf_temp_specevent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			cf_temp_specevent.KEY,
			cf_temp_specevent.STATUS,
			cf_temp_specevent.ASSIGNED_BY_AGENT,
			cf_temp_specevent.ASSIGNED_DATE,
			cf_temp_specevent.SPECIMEN_EVENT_REMARK,
			cf_temp_specevent.SPECIMEN_EVENT_TYPE,
			cf_temp_specevent.COLLECTING_METHOD,
			cf_temp_specevent.COLLECTING_SOURCE,
			cf_temp_specevent.VERIFICATIONSTATUS,
			cf_temp_specevent.HABITAT,
			cf_temp_specevent.COLLECTING_EVENT_ID,
			cf_temp_specevent.VERBATIM_DATE,
			cf_temp_specevent.VERBATIM_LOCALITY,
			cf_temp_specevent.COLL_EVENT_REMARKS,
			cf_temp_specevent.BEGAN_DATE,
			cf_temp_specevent.ENDED_DATE,
			cf_temp_specevent.COLLECTING_EVENT_NAME,
			cf_temp_specevent.LAT_DEG || ' ' ||
				cf_temp_specevent.DEC_LAT_MIN || ' ' ||
				cf_temp_specevent.LAT_MIN || ' ' ||
				cf_temp_specevent.LAT_SEC || ' ' ||
				cf_temp_specevent.LAT_DIR || ' ' ||
				cf_temp_specevent.LONG_DEG || ' ' ||
				cf_temp_specevent.DEC_LONG_MIN || ' ' ||
				cf_temp_specevent.LONG_MIN || ' ' ||
				cf_temp_specevent.LONG_SEC || ' ' ||
				cf_temp_specevent.LONG_DIR
				dms_data,
			cf_temp_specevent.DEC_LAT || ' ' || cf_temp_specevent.DEC_LONG dddata,
			cf_temp_specevent.UTM_EW || ' ' || cf_temp_specevent.UTM_NS || ' ' || cf_temp_specevent.UTM_ZONE utmdata,
			cf_temp_specevent.DATUM,
			cf_temp_specevent.ORIG_LAT_LONG_UNITS,
			cf_temp_specevent.LOCALITY_ID,
			cf_temp_specevent.SPEC_LOCALITY,
			cf_temp_specevent.MINIMUM_ELEVATION,
			cf_temp_specevent.MAXIMUM_ELEVATION,
			cf_temp_specevent.ORIG_ELEV_UNITS,
			cf_temp_specevent.MIN_DEPTH,
			cf_temp_specevent.MAX_DEPTH,
			cf_temp_specevent.DEPTH_UNITS,
			cf_temp_specevent.MAX_ERROR_DISTANCE,
			cf_temp_specevent.MAX_ERROR_UNITS,
			cf_temp_specevent.LOCALITY_REMARKS,
			cf_temp_specevent.GEOREFERENCE_SOURCE,
			cf_temp_specevent.GEOREFERENCE_PROTOCOL,
			cf_temp_specevent.LOCALITY_NAME,
			cf_temp_specevent.GEOG_AUTH_REC_ID,
			cf_temp_specevent.HIGHER_GEOG,
			cf_temp_specevent.INSERT_DATE,
			cf_temp_specevent.USERNAME,
			flat.guid
		from
			cf_temp_specevent,
			coll_obj_other_id_num,
			flat
		where
			coll_obj_other_id_num.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID and
			coll_obj_other_id_num.DISPLAY_VALUE=cf_temp_specevent.UUID
			<cfif len(collection) gt 0>
				and flat.guid_prefix like '#collection#:%'
			</cfif>
	</cfquery>
	<table border>
		<tr>
			<th>KEY</th>
			<th>guid</th>
			<th>STATUS</th>
			<th>USERNAME</th>
			<th>INSERT_DATE</th>
			<th>ASSIGNED_BY_AGENT</th>
			<th>ASSIGNED_DATE</th>
			<th>SPECIMEN_EVENT_REMARK</th>
			<th>SPECIMEN_EVENT_TYPE</th>
			<th>COLLECTING_METHOD</th>
			<th>COLLECTING_SOURCE</th>
			<th>VERIFICATIONSTATUS</th>
			<th>HABITAT</th>
			<th>COLLECTING_EVENT_ID</th>
			<th>VERBATIM_DATE</th>
			<th>VERBATIM_LOCALITY</th>
			<th>COLL_EVENT_REMARKS</th>
			<th>BEGAN_DATE</th>
			<th>ENDED_DATE</th>
			<th>COLLECTING_EVENT_NAME</th>
			<th>dms_data</th>
			<th>dddata</th>
			<th>utmdata</th>
			<th>DATUM</th>
			<th>ORIG_LAT_LONG_UNITS</th>
			<th>LOCALITY_ID</th>
			<th>SPEC_LOCALITY</th>
			<th>MINIMUM_ELEVATION</th>
			<th>MAXIMUM_ELEVATION</th>
			<th>ORIG_ELEV_UNITS</th>
			<th>MIN_DEPTH</th>
			<th>MAX_DEPTH</th>
			<th>DEPTH_UNITS</th>
			<th>MAX_ERROR_DISTANCE</th>
			<th>MAX_ERROR_UNITS</th>
			<th>LOCALITY_REMARKS</th>
			<th>GEOREFERENCE_SOURCE</th>
			<th>GEOREFERENCE_PROTOCOL</th>
			<th>LOCALITY_NAME</th>
			<th>GEOG_AUTH_REC_ID</th>
			<th>HIGHER_GEOG</th>
		</tr>
		<cfloop query="cf_temp_specevent">
			<tr>
				<td>#KEY#</td>
				<td>#GUID#</td>
				<td>#STATUS#</td>
				<td>#USERNAME#</td>
				<td>#INSERT_DATE#</td>
				<td>#ASSIGNED_BY_AGENT#</td>
				<td>#ASSIGNED_DATE#</td>
				<td>#SPECIMEN_EVENT_REMARK#</td>
				<td>#SPECIMEN_EVENT_TYPE#</td>
				<td>#COLLECTING_METHOD#</td>
				<td>#COLLECTING_SOURCE#</td>
				<td>#VERIFICATIONSTATUS#</td>
				<td>#HABITAT#</td>
				<td>#COLLECTING_EVENT_ID#</td>
				<td>#VERBATIM_DATE#</td>
				<td>#VERBATIM_LOCALITY#</td>
				<td>#COLL_EVENT_REMARKS#</td>
				<td>#BEGAN_DATE#</td>
				<td>#ENDED_DATE#</td>
				<td>#COLLECTING_EVENT_NAME#</td>
				<td>#dms_data#</td>
				<td>#dddata#</td>
				<td>#utmdata#</td>
				<td>#DATUM#</td>
				<td>#ORIG_LAT_LONG_UNITS#</td>
				<td>#LOCALITY_ID#</td>
				<td>#SPEC_LOCALITY#</td>
				<td>#MINIMUM_ELEVATION#</td>
				<td>#MAXIMUM_ELEVATION#</td>
				<td>#ORIG_ELEV_UNITS#</td>
				<td>#MIN_DEPTH#</td>
				<td>#MAX_DEPTH#</td>
				<td>#DEPTH_UNITS#</td>
				<td>#MAX_ERROR_DISTANCE#</td>
				<td>#MAX_ERROR_UNITS#</td>
				<td>#LOCALITY_REMARKS#</td>
				<td>#GEOREFERENCE_SOURCE#</td>
				<td>#GEOREFERENCE_PROTOCOL#</td>
				<td>#LOCALITY_NAME#</td>
				<td>#GEOG_AUTH_REC_ID#</td>
				<td>#HIGHER_GEOG#</td>
			</tr>
		</cfloop>
	</table>

	<cfquery name="cf_temp_parts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			cf_temp_parts.KEY,
			cf_temp_parts.PART_NAME,
			cf_temp_parts.DISPOSITION,
			cf_temp_parts.CONDITION,
			cf_temp_parts.LOT_COUNT,
			cf_temp_parts.REMARKS,
			cf_temp_parts.USE_EXISTING,
			cf_temp_parts.CONTAINER_BARCODE,
			cf_temp_parts.CHANGE_CONTAINER_TYPE,
			cf_temp_parts.CHANGE_CONTAINER_LABEL,
			cf_temp_parts.PART_ATTRIBUTE_TYPE_1,
			cf_temp_parts.PART_ATTRIBUTE_VALUE_1,
			cf_temp_parts.PART_ATTRIBUTE_UNITS_1,
			cf_temp_parts.PART_ATTRIBUTE_DATE_1,
			cf_temp_parts.PART_ATTRIBUTE_DETERMINER_1,
			cf_temp_parts.PART_ATTRIBUTE_REMARK_1,
			cf_temp_parts.PART_ATTRIBUTE_TYPE_2,
			cf_temp_parts.PART_ATTRIBUTE_VALUE_2,
			cf_temp_parts.PART_ATTRIBUTE_UNITS_2,
			cf_temp_parts.PART_ATTRIBUTE_DATE_2,
			cf_temp_parts.PART_ATTRIBUTE_DETERMINER_2,
			cf_temp_parts.PART_ATTRIBUTE_REMARK_2,
			cf_temp_parts.PART_ATTRIBUTE_TYPE_3,
			cf_temp_parts.PART_ATTRIBUTE_VALUE_3,
			cf_temp_parts.PART_ATTRIBUTE_UNITS_3,
			cf_temp_parts.PART_ATTRIBUTE_DATE_3,
			cf_temp_parts.PART_ATTRIBUTE_DETERMINER_3,
			cf_temp_parts.PART_ATTRIBUTE_REMARK_3,
			cf_temp_parts.PART_ATTRIBUTE_TYPE_4,
			cf_temp_parts.PART_ATTRIBUTE_VALUE_4,
			cf_temp_parts.PART_ATTRIBUTE_UNITS_4,
			cf_temp_parts.PART_ATTRIBUTE_DATE_4,
			cf_temp_parts.PART_ATTRIBUTE_DETERMINER_4,
			cf_temp_parts.PART_ATTRIBUTE_REMARK_4,
			cf_temp_parts.PART_ATTRIBUTE_TYPE_5,
			cf_temp_parts.PART_ATTRIBUTE_VALUE_5,
			cf_temp_parts.PART_ATTRIBUTE_UNITS_5,
			cf_temp_parts.PART_ATTRIBUTE_DATE_5,
			cf_temp_parts.PART_ATTRIBUTE_DETERMINER_5,
			cf_temp_parts.PART_ATTRIBUTE_REMARK_5,
			cf_temp_parts.PART_ATTRIBUTE_TYPE_6,
			cf_temp_parts.PART_ATTRIBUTE_VALUE_6,
			cf_temp_parts.PART_ATTRIBUTE_UNITS_6,
			cf_temp_parts.PART_ATTRIBUTE_DATE_6,
			cf_temp_parts.PART_ATTRIBUTE_DETERMINER_6,
			cf_temp_parts.PART_ATTRIBUTE_REMARK_6,
			cf_temp_parts.STATUS,
			cf_temp_parts.USERNAME,
			flat.guid
		from
			cf_temp_parts,
			coll_obj_other_id_num,
			flat
		where
			coll_obj_other_id_num.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID and
			coll_obj_other_id_num.DISPLAY_VALUE=cf_temp_parts.other_id_number
			<cfif len(collection) gt 0>
				and flat.guid_prefix like '#collection#:%'
			</cfif>
	</cfquery>
	<table border>
		<tr>
			<th>KEY</th>
			<th>GUID</th>
			<th>STATUS</th>
			<th>USERNAME</th>
			<th>guid</th>
			<th>PART_NAME</th>
			<th>DISPOSITION</th>
			<th>CONDITION</th>
			<th>LOT_COUNT</th>
			<th>REMARKS</th>
			<th>USE_EXISTING</th>
			<th>CONTAINER_BARCODE</th>
			<th>CHANGE_CONTAINER_TYPE</th>
			<th>CHANGE_CONTAINER_LABEL</th>
			<th>PART_ATTRIBUTE_TYPE_1</th>
			<th>PART_ATTRIBUTE_VALUE_1</th>
			<th>PART_ATTRIBUTE_UNITS_1</th>
			<th>PART_ATTRIBUTE_DATE_1</th>
			<th>PART_ATTRIBUTE_DETERMINER_1</th>
			<th>PART_ATTRIBUTE_REMARK_1</th>
			<th>PART_ATTRIBUTE_TYPE_2</th>
			<th>PART_ATTRIBUTE_VALUE_2</th>
			<th>PART_ATTRIBUTE_UNITS_2</th>
			<th>PART_ATTRIBUTE_DATE_2</th>
			<th>PART_ATTRIBUTE_DETERMINER_2</th>
			<th>PART_ATTRIBUTE_REMARK_2</th>
			<th>PART_ATTRIBUTE_TYPE_3</th>
			<th>PART_ATTRIBUTE_VALUE_3</th>
			<th>PART_ATTRIBUTE_UNITS_3</th>
			<th>PART_ATTRIBUTE_DATE_3</th>
			<th>PART_ATTRIBUTE_DETERMINER_3</th>
			<th>PART_ATTRIBUTE_REMARK_3</th>
			<th>PART_ATTRIBUTE_TYPE_4</th>
			<th>PART_ATTRIBUTE_VALUE_4</th>
			<th>PART_ATTRIBUTE_UNITS_4</th>
			<th>PART_ATTRIBUTE_DATE_4</th>
			<th>PART_ATTRIBUTE_DETERMINER_4</th>
			<th>PART_ATTRIBUTE_REMARK_4</th>
			<th>PART_ATTRIBUTE_TYPE_5</th>
			<th>PART_ATTRIBUTE_VALUE_5</th>
			<th>PART_ATTRIBUTE_UNITS_5</th>
			<th>PART_ATTRIBUTE_DATE_5</th>
			<th>PART_ATTRIBUTE_DETERMINER_5</th>
			<th>PART_ATTRIBUTE_REMARK_5</th>
			<th>PART_ATTRIBUTE_TYPE_6</th>
			<th>PART_ATTRIBUTE_VALUE_6</th>
			<th>PART_ATTRIBUTE_UNITS_6</th>
			<th>PART_ATTRIBUTE_DATE_6</th>
			<th>PART_ATTRIBUTE_DETERMINER_6</th>
			<th>PART_ATTRIBUTE_REMARK_6</th>
		</tr>
		<cfloop query="cf_temp_parts">
			<tr>
				<td>#KEY#</td>
				<th>#GUID#</th>
				<td>#STATUS#</td>
				<td>#USERNAME#</td>
				<td>#guid#</td>
				<td>#PART_NAME#</td>
				<td>#DISPOSITION#</td>
				<td>#CONDITION#</td>
				<td>#LOT_COUNT#</td>
				<td>#REMARKS#</td>
				<td>#USE_EXISTING#</td>
				<td>#CONTAINER_BARCODE#</td>
				<td>#CHANGE_CONTAINER_TYPE#</td>
				<td>#CHANGE_CONTAINER_LABEL#</td>
				<td>#PART_ATTRIBUTE_TYPE_1#</td>
				<td>#PART_ATTRIBUTE_VALUE_1#</td>
				<td>#PART_ATTRIBUTE_UNITS_1#</td>
				<td>#PART_ATTRIBUTE_DATE_1#</td>
				<td>#PART_ATTRIBUTE_DETERMINER_1#</td>
				<td>#PART_ATTRIBUTE_REMARK_1#</td>
				<td>#PART_ATTRIBUTE_TYPE_2#</td>
				<td>#PART_ATTRIBUTE_VALUE_2#</td>
				<td>#PART_ATTRIBUTE_UNITS_2#</td>
				<td>#PART_ATTRIBUTE_DATE_2#</td>
				<td>#PART_ATTRIBUTE_DETERMINER_2#</td>
				<td>#PART_ATTRIBUTE_REMARK_2#</td>
				<td>#PART_ATTRIBUTE_TYPE_3#</td>
				<td>#PART_ATTRIBUTE_VALUE_3#</td>
				<td>#PART_ATTRIBUTE_UNITS_3#</td>
				<td>#PART_ATTRIBUTE_DATE_3#</td>
				<td>#PART_ATTRIBUTE_DETERMINER_3#</td>
				<td>#PART_ATTRIBUTE_REMARK_3#</td>
				<td>#PART_ATTRIBUTE_TYPE_4#</td>
				<td>#PART_ATTRIBUTE_VALUE_4#</td>
				<td>#PART_ATTRIBUTE_UNITS_4#</td>
				<td>#PART_ATTRIBUTE_DATE_4#</td>
				<td>#PART_ATTRIBUTE_DETERMINER_4#</td>
				<td>#PART_ATTRIBUTE_REMARK_4#</td>
				<td>#PART_ATTRIBUTE_TYPE_5#</td>
				<td>#PART_ATTRIBUTE_VALUE_5#</td>
				<td>#PART_ATTRIBUTE_UNITS_5#</td>
				<td>#PART_ATTRIBUTE_DATE_5#</td>
				<td>#PART_ATTRIBUTE_DETERMINER_5#</td>
				<td>#PART_ATTRIBUTE_REMARK_5#</td>
				<td>#PART_ATTRIBUTE_TYPE_6#</td>
				<td>#PART_ATTRIBUTE_VALUE_6#</td>
				<td>#PART_ATTRIBUTE_UNITS_6#</td>
				<td>#PART_ATTRIBUTE_DATE_6#</td>
				<td>#PART_ATTRIBUTE_DETERMINER_6#</td>
				<td>#PART_ATTRIBUTE_REMARK_6#</td>
			</tr>
		</cfloop>
	</table>

	<cfquery name="cf_temp_attributes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			cf_temp_attributes.KEY,
			cf_temp_attributes.USERNAME,
			cf_temp_attributes.STATUS,
			cf_temp_attributes.ATTRIBUTE,
			cf_temp_attributes.ATTRIBUTE_VALUE,
			cf_temp_attributes.ATTRIBUTE_UNITS,
			cf_temp_attributes.ATTRIBUTE_DATE,
			cf_temp_attributes.ATTRIBUTE_METH,
			cf_temp_attributes.DETERMINER,
			cf_temp_attributes.REMARKS,
			flat.guid
		from
			cf_temp_attributes,
			coll_obj_other_id_num,
			flat
		where
			coll_obj_other_id_num.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID and
			coll_obj_other_id_num.DISPLAY_VALUE=cf_temp_attributes.other_id_number
			<cfif len(collection) gt 0>
				and flat.guid_prefix like '#collection#:%'
			</cfif>
	</cfquery>

	<table border>
		<tr>
			<th>KEY</th>
			<th>GUID</th>
			<th>USERNAME</th>
			<th>STATUS</th>
			<th>ATTRIBUTE</th>
			<th>ATTRIBUTE_VALUE</th>
			<th>ATTRIBUTE_UNITS</th>
			<th>ATTRIBUTE_DATE</th>
			<th>ATTRIBUTE_METH</th>
			<th>DETERMINER</th>
			<th>REMARKS</th>
		</tr>
		<cfloop query="cf_temp_attributes">
			<tr>
				<td>#KEY#</td>
				<td>#GUID#</td>
				<td>#USERNAME#</td>
				<td>#STATUS#</td>
				<td>#ATTRIBUTE#</td>
				<td>#ATTRIBUTE_VALUE#</td>
				<td>#ATTRIBUTE_UNITS#</td>
				<td>#ATTRIBUTE_DATE#</td>
				<td>#ATTRIBUTE_METH#</td>
				<td>#DETERMINER#</td>
				<td>#REMARKS#</td>
			</tr>
		</cfloop>
	</table>
	<cfquery name="cf_temp_oids" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			cf_temp_oids.KEY,
			cf_temp_oids.USERNAME,
			cf_temp_oids.STATUS,
			cf_temp_oids.NEW_OTHER_ID_TYPE,
			cf_temp_oids.NEW_OTHER_ID_NUMBER,
			cf_temp_oids.NEW_OTHER_ID_REFERENCES,
			flat.guid
		from
			cf_temp_oids,
			coll_obj_other_id_num,
			flat
		where
			coll_obj_other_id_num.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID and
			coll_obj_other_id_num.DISPLAY_VALUE=cf_temp_oids.EXISTING_OTHER_ID_NUMBER
			<cfif len(collection) gt 0>
				and flat.guid_prefix like '#collection#:%'
			</cfif>
	</cfquery>
	<table border>
		<tr>
			<th>KEY</th>
			<th>GUID</th>
			<th>USERNAME</th>
			<th>STATUS</th>
			<th>NEW_OTHER_ID_TYPE</th>
			<th>NEW_OTHER_ID_NUMBER</th>
			<th>NEW_OTHER_ID_REFERENCES</th>
		</tr>
		<cfloop query="cf_temp_oids">
			<tr>
				<td>#KEY#</td>
				<td>#GUID#</td>
				<td>#USERNAME#</td>
				<td>#STATUS#</td>
				<td>#NEW_OTHER_ID_TYPE#</td>
				<td>#NEW_OTHER_ID_NUMBER#</td>
				<td>#NEW_OTHER_ID_REFERENCES#</td>
			</tr>
		</cfloop>
	</table>

	<cfquery name="cf_temp_collector" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			cf_temp_collector.KEY,
			cf_temp_collector.USERNAME,
			cf_temp_collector.STATUS,
			cf_temp_collector.AGENT_NAME,
			cf_temp_collector.COLLECTOR_ROLE,
			cf_temp_collector.COLL_ORDER,
			flat.guid
		from
			cf_temp_collector,
			coll_obj_other_id_num,
			flat
		where
			coll_obj_other_id_num.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID and
			coll_obj_other_id_num.DISPLAY_VALUE=cf_temp_collector.other_id_number
			<cfif len(collection) gt 0>
				and flat.guid_prefix like '#collection#:%'
			</cfif>
	</cfquery>
	<table border>
		<tr>
			<th>KEY</th>
			<th>GUID</th>
			<th>USERNAME</th>
			<th>STATUS</th>
			<th>AGENT_NAME</th>
			<th>COLLECTOR_ROLE</th>
			<th>COLL_ORDER</th>
		</tr>
		<cfloop query="cf_temp_collector">
			<tr>
				<td>#KEY#</td>
				<td>#GUID#</td>
				<td>#USERNAME#</td>
				<td>#STATUS#</td>
				<td>#AGENT_NAME#</td>
				<td>#COLLECTOR_ROLE#</td>
				<td>#COLL_ORDER#</td>
			</tr>
		</cfloop>
	</table>



</cfoutput>
</cfif>



<cfinclude template="/includes/_footer.cfm">
