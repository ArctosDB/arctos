create or replace view loc_acc_lat_long as select 
			locality.LOCALITY_ID,
			locality.geog_auth_rec_id,
			MAXIMUM_ELEVATION,
			MINIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			SPEC_LOCALITY,
			LOCALITY_REMARKS,
			DEPTH_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			NOGEOREFBECAUSE,
			LAT_LONG_ID,
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
			UTM_ZONE,
			UTM_EW,
			UTM_NS,				
			DATUM,
			ORIG_LAT_LONG_UNITS,
			DETERMINED_BY_AGENT_ID,
			DETERMINED_DATE,
			LAT_LONG_REMARKS,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
			ACCEPTED_LAT_LONG_FG,
			EXTENT,
			GPSACCURACY,
			GEOREFMETHOD,
			VERIFICATIONSTATUS,
			LAT_LONG_REF_SOURCE
		from 
			locality, 
			accepted_lat_long,
			preferred_agent_name
		where 
			locality.locality_id=accepted_lat_long.locality_id (+) AND
			determined_by_agent_id = agent_id (+)		
;			


create public synonym loc_acc_lat_long for loc_acc_lat_long;
grant select on loc_acc_lat_long to public;