<cfcomponent>
<!------------------------------------------------------------------------------->
<cffunction name="getcatNumSeq" access="remote">
	<cfargument name="coll" type="string" required="yes">
	<cfset theSpace = find(" " ,coll)>
	<cfset inst = trim(left(coll,theSpace))>
	<cfset collcde = trim(mid(coll,theSpace,len(coll)))>	
	<cfquery name="collID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_id from collection where
		institution_acronym='#inst#' and
		collection_cde='#collcde#'
	</cfquery>
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(cat_num + 1) as nextnum
		from cataloged_item 
		where 
		collection_id=#collID.collection_id# 
	</cfquery>
	<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select max(to_number(cat_num) + 1) as nextnum from bulkloader
		where
		institution_acronym='#inst#' and
		collection_cde='#collcde#'
	</cfquery>
	<cfif #q.nextnum# gt #b.nextnum#>
		<cfset result = "#q.nextnum#">
	<cfelse>
		<cfset result = "#b.nextnum#">
	</cfif>
	<cfreturn result>
</cffunction>
<!---------------------------------------------------------------------------------------->
<cffunction name="is_good_accn" access="remote">
	<cfargument name="accn" type="string" required="yes">
	<cfargument name="institution_acronym" type="string" required="yes">
	<cftry>
	<cfif #accn# contains "[" and #accn# contains "]">
		<cfset p = find(']',accn)>
		<cfset ia = mid(accn,2,p-2)>
		<cfset ac = mid(accn,p+1,len(accn))>
	<cfelse>
		<cfset ac=#accn#>
		<cfset ia=#institution_acronym#>
	</cfif>
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			count(*) cnt
		FROM
			accn,
			trans,
			collection
		WHERE
			accn.transaction_id = trans.transaction_id AND
			trans.collection_id=collection.collection_id and
			accn.accn_number = '#ac#' and
			collection.institution_acronym = '#ia#'
	</cfquery>
		<cfset result = "#q.cnt#">
	<cfcatch>
		<cfset result = "#cfcatch.detail#">
	</cfcatch>
	</cftry>	
	<cfreturn result>
</cffunction>
<!---------------------------------------------------------------------------------------->
<cffunction name="rememberLastOtherId" access="remote">
	<cfargument name="yesno" type="numeric" required="yes">
	<cfset session.rememberLastOtherId=#yesno#>
	<cfreturn yesno>
</cffunction>
<!---------------------------------------------------------------------------------------->
<cffunction name="get_picked_event" access="remote">
	<cfargument name="collecting_event_id" type="numeric" required="yes">
	<cftry>
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			collecting_event.COLLECTING_EVENT_ID,
			BEGAN_DATE,
			ENDED_DATE,
			VERBATIM_DATE,
			VERBATIM_LOCALITY,
			COLL_EVENT_REMARKS,
			COLLECTING_SOURCE,
			COLLECTING_METHOD,
			HABITAT_DESC,
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
			preferred_agent_name geoAgnt,
			collecting_event
		WHERE
			collecting_event.LOCALITY_ID=locality.locality_id and
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
			locality.LOCALITY_ID = accepted_lat_long.LOCALITY_ID (+) AND
			locality.LOCALITY_ID = geology_attributes.LOCALITY_ID (+) AND
			geology_attributes.GEO_ATT_DETERMINER_ID = geoAgnt.agent_id (+) AND
			accepted_lat_long.DETERMINED_BY_AGENT_ID = llAgnt.agent_id (+) AND
			collecting_event.collecting_event_id = #collecting_event_id#
	</cfquery>
	<cfcatch>
	<cfset result = QueryNew("COLLECTING_EVENT_ID,MSG")>
	<cfset temp = QueryAddRow(result, 1)>
	<cfset temp = QuerySetCell(result, "collecting_event_id", "-1",1)>
	<cfset temp = QuerySetCell(result, "msg", "#cfcatch.detail#",1)>
	</cfcatch>
	</cftry>	
	<cfreturn result>
</cffunction>
<!---------------------------------------------------------------------------------------->
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
		<cfset result = QueryNew("LOCALITY_ID,MSG")>
		<cfset temp = QueryAddRow(result, 1)>
		<cfset temp = QuerySetCell(result, "locality_id", "-1",1)>
		<cfset temp = QuerySetCell(result, "msg", "#cfcatch.detail#",1)>
	</cfcatch>
	</cftry>	
	<cfreturn result>
</cffunction>
</cfcomponent>