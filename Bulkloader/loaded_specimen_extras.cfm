<cfinclude template="/includes/_header.cfm">
<cfif action is "findRecords">
<cfoutput>
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
	</cfquery>
	<table border>
		<tr>
			<th>KEY</th>
			<th>STATUS</th>
			<th>USERNAME</th>
			<th>INSERT_DATE</th>
			<th>guid</th>
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
				<td>#STATUS#</td>
				<td>#USERNAME#</td>
				<td>#INSERT_DATE#</td>
				<td>#guid#</td>
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
	</cfquery>
	<cfdump var=#cf_temp_parts#>


	<cfquery name="cf_temp_attributes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			cf_temp_attributes.USERNAME,
			flat.guid
		from
			cf_temp_attributes,
			coll_obj_other_id_num,
			flat
		where
			coll_obj_other_id_num.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID and
			coll_obj_other_id_num.DISPLAY_VALUE=cf_temp_attributes.other_id_number
	</cfquery>
	<cfdump var=#cf_temp_parts#>

	<cfquery name="cf_temp_oids" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			cf_temp_oids.USERNAME,
			flat.guid
		from
			cf_temp_oids,
			coll_obj_other_id_num,
			flat
		where
			coll_obj_other_id_num.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID and
			coll_obj_other_id_num.DISPLAY_VALUE=cf_temp_oids.EXISTING_OTHER_ID_NUMBER
	</cfquery>
	<cfdump var=#cf_temp_parts#>


	<cfquery name="cf_temp_collector" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			cf_temp_collector.USERNAME,
			flat.guid
		from
			cf_temp_collector,
			coll_obj_other_id_num,
			flat
		where
			coll_obj_other_id_num.OTHER_ID_TYPE='UUID' and
			coll_obj_other_id_num.COLLECTION_OBJECT_ID=flat.COLLECTION_OBJECT_ID and
			coll_obj_other_id_num.DISPLAY_VALUE=cf_temp_collector.other_id_number
	</cfquery>
	<cfdump var=#cf_temp_parts#>




</cfoutput>
</cfif>



<cfinclude template="/includes/_footer.cfm">
