<cfcomponent>
<cffunction name="get_picked_locality" access="remote">
	<cfargument name="locality_id" type="numeric" required="yes">
	<cftry>
		<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				locality.locality_id,
				geog_auth_rec.HIGHER_GEOG,
				locality.MAXIMUM_ELEVATION,
				locality.MINIMUM_ELEVATION,
				locality.ORIG_ELEV_UNITS,
				locality.SPEC_LOCALITY,
				locality.LOCALITY_REMARKS,
				accepted_lat_long.LAT_DEG,			
				accepted_lat_long.DEC_LAT_MIN,
				accepted_lat_long.LAT_MIN,
				accepted_lat_long.LAT_SEC,
				accepted_lat_long.LAT_DIR,			
				accepted_lat_long.LONG_DEG,
				accepted_lat_long.DEC_LONG_MIN,
				accepted_lat_long.LONG_MIN,
				accepted_lat_long.LONG_SEC,			
				accepted_lat_long.LONG_DIR,
				accepted_lat_long.DEC_LAT,
				accepted_lat_long.DEC_LONG,
				accepted_lat_long.DATUM,
				accepted_lat_long.ORIG_LAT_LONG_UNITS,
				llAgnt.agent_name DETERMINED_BY,
				to_char(accepted_lat_long.DETERMINED_DATE,'dd-Mon-yyyy') DETERMINED_DATE,
				accepted_lat_long.LAT_LONG_REF_SOURCE,
				accepted_lat_long.LAT_LONG_REMARKS,
				accepted_lat_long.MAX_ERROR_DISTANCE,
				accepted_lat_long.MAX_ERROR_UNITS,
				accepted_lat_long.EXTENT,
				accepted_lat_long.GPSACCURACY,
				accepted_lat_long.GEOREFMETHOD,
				accepted_lat_long.VERIFICATIONSTATUS,
				GEOLOGY_ATTRIBUTE,
				GEO_ATT_VALUE,
				geoAgnt.agent_name GEO_ATT_DETERMINER,
				to_char(GEO_ATT_DETERMINED_DATE,'dd-Mon-yyyy') GEO_ATT_DETERMINED_DATE,
				GEO_ATT_DETERMINED_METHOD,
				GEO_ATT_REMARK 
			FROM
				geog_auth_rec,
				locality,
				accepted_lat_long,
				preferred_agent_name llAgnt,
				geology_attributes,
				preferred_agent_name geoAgnt
			WHERE
				locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
				locality.LOCALITY_ID = accepted_lat_long.LOCALITY_ID (+) AND
				locality.LOCALITY_ID = geology_attributes.LOCALITY_ID (+) AND
				geology_attributes.GEO_ATT_DETERMINER_ID = geoAgnt.agent_id (+) AND
				accepted_lat_long.DETERMINED_BY_AGENT_ID = llAgnt.agent_id (+) AND
				locality.locality_id = #locality_id#
		</cfquery>
	<cfcatch>
		<cfset result = QueryNew("locality_id,msg")>
		<cfset temp = QueryAddRow(result, 1)>
		<cfset temp = QuerySetCell(result, "locality_id", "-1",1)>
		<cfset temp = QuerySetCell(result, "msg", "#cfcatch.detail#",1)>
	</cfcatch>
	</cftry>	
	<cfreturn result>
</cffunction>
</cfcomponent>