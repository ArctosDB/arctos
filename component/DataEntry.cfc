<cfcomponent>
<!------------------------------------------------------------------------------->
<cffunction name="isValidISODate"  access="remote">
	<cfargument name="datestring" type="string" required="yes">
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select is_iso8601('#datestring#') r from dual
	</cfquery>
	<cfif result.r is "valid">
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>
<!---------------------------------------------------------------->


<cffunction name="getAttCodeTbl"  access="remote">
	<cfargument name="attribute" type="string" required="yes">
	<cfargument name="collection_cde" type="string" required="yes">
	<cfargument name="element" type="string" required="yes">
	<cfquery name="isCtControlled" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select VALUE_CODE_TABLE,UNITS_CODE_TABLE from ctattribute_code_tables where attribute_type='#attribute#'
	</cfquery>
	<cfif isCtControlled.recordcount is 1>
		<cfif len(isCtControlled.VALUE_CODE_TABLE) gt 0>
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isCtControlled.value_code_table)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from #isCtControlled.value_code_table#
			</cfquery>
			<cfset collCode = "">
			<cfset columnName = "">
			<cfloop query="getCols">
				<cfif getCols.column_name is "COLLECTION_CDE">
					<cfset collCode = "yes">
				  <cfelse>
					<cfset columnName = "#getCols.column_name#">
				</cfif>
			</cfloop>
			<cfif len(collCode) gt 0>
				<cfquery name="valCodes" dbtype="query">
					SELECT #columnName# as valCodes from valCT
					WHERE collection_cde='#collection_cde#'
				</cfquery>
			  <cfelse>
				<cfquery name="valCodes" dbtype="query">
					SELECT  #columnName# as valCodes from valCT
				</cfquery>
			</cfif>
			<cfset result = QueryNew("V")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "value",1)>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
			<cfset i=3>
			<cfloop query="valCodes">
				<cfset newRow = QueryAddRow(result, 1)>
				<cfif valcodes is "yes">
					<cfset rval="_yes_">
				<cfelseif valcodes is "no">
					<cfset rval="_no_">
				<cfelse>
					<cfset rval=valcodes>
				</cfif>
				<cfset temp = QuerySetCell(result, "v", rval,i)>
				<cfset i=i+1>
			</cfloop>

		<cfelseif #isCtControlled.UNITS_CODE_TABLE# gt 0>
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isCtControlled.UNITS_CODE_TABLE)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from #isCtControlled.UNITS_CODE_TABLE#
			</cfquery>
			<cfset collCode = "">
			<cfset columnName = "">
			<cfloop query="getCols">
				<cfif getCols.column_name is "COLLECTION_CDE">
					<cfset collCode = "yes">
				  <cfelse>
					<cfset columnName = "#getCols.column_name#">
				</cfif>
			</cfloop>
			<cfif len(#collCode#) gt 0>
				<cfquery name="valCodes" dbtype="query">
					SELECT #columnName# as valCodes from valCT
					WHERE collection_cde='#collection_cde#'
				</cfquery>
			  <cfelse>
				<cfquery name="valCodes" dbtype="query">
					SELECT #columnName# as valCodes from valCT
				</cfquery>
			</cfif>
			<cfset result = "unit - #isCtControlled.UNITS_CODE_TABLE#">
			<cfset result = QueryNew("V")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "units")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
			<cfset i=3>
			<cfloop query="valCodes">
				<cfset newRow = QueryAddRow(result, 1)>
				<cfset temp = QuerySetCell(result, "v", "#valCodes#",#i#)>
				<cfset i=#i#+1>
			</cfloop>
		<cfelse>
			<cfset result = QueryNew("V")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "ERROR")>
			<cfset newRow = QueryAddRow(result, 1)>
			<cfset temp = QuerySetCell(result, "v", "#element#",2)>
		</cfif>
	<cfelse>
		<cfset result = QueryNew("V")>
		<cfset newRow = QueryAddRow(result, 1)>
		<cfset temp = QuerySetCell(result, "v", "NONE")>
		<cfset newRow = QueryAddRow(result, 1)>
		<cfset temp = QuerySetCell(result, "v", "#element#",2)>
	</cfif>

	<cfreturn result>

</cffunction>
<!---------------------------------------------------------------->
<cffunction name="getcatNumSeq" access="remote">
	<cfargument name="coll" type="string" required="yes">
	<cfset theSpace = find(" " ,coll)>
	<cfset inst = trim(left(coll,theSpace))>
	<cfset collcde = trim(mid(coll,theSpace,len(coll)))>
	<cfquery name="collID" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection_id from collection where
		institution_acronym='#inst#' and
		collection_cde='#collcde#'
	</cfquery>
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select max(cat_num + 1) as nextnum
		from cataloged_item
		where
		collection_id=#collID.collection_id#
	</cfquery>
	<cfquery name="b" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
	<cfargument name="collection_cde" type="string" required="yes">
	<cfargument name="institution_acronym" type="string" required="yes">
	<cftry>
	<cfif accn contains "[" and accn contains "]">
		<cfset p = find(']',accn)>
		<cfset ic = mid(accn,2,p-2)>
		<cfset ia=listgetat(ic,1,":")>
		<cfset cc=listgetat(ic,2,":")>
		<cfset ac = mid(accn,p+1,len(accn))>
	<cfelse>
		<cfset ac=accn>
		<cfset ia=institution_acronym>
		<cfset cc=collection_cde>
	</cfif>
	<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
			collection.institution_acronym = '#ia#' and
			collection.collection_cde = '#cc#'
	</cfquery>
		<cfset result = "#q.cnt#">
	<cfcatch>
		<cfset result = "#cfcatch.detail#">
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>

<!---------------------------------------------------------------------------------------->
<cffunction name="incrementCustomID" access="remote">
	<cfargument name="yesno" type="numeric" required="yes">
	<cfset session.rememberLastOtherId=yesno>
	<cfreturn yesno>
</cffunction>
					otherID

	<cfif isdefined("session.rememberLastOtherId") and session.rememberLastOtherId is 1 and action is "enter">
		<cftry>
			<cfset cVal="">
			<cfif isnumeric(other_id_num_5)>
				<cfset cVal = other_id_num_5 + 1>
			<cfelseif isnumeric(right(other_id_num_5,len(other_id_num_5)-1))>
				<cfset temp = (right(other_id_num_5,len(other_id_num_5)-1)) + 1>
				<cfset cVal = left(other_id_num_5,1) & temp>
			</cfif>
			<script language="javascript" type="text/javascript">
				var cid = document.getElementById('other_id_num_5').value='#cVal#';
			</script>
		<cfcatch>
			<cfmail to="arctos.database@gmail.com" subject="data entry catch" from="wtf@#Application.fromEmail#" type="html">
				other_id_num_5: #other_id_num_5#
				<cfdump var=#cfcatch#>
			</cfmail>
		</cfcatch>
		</cftry>
	</cfif>
	
	
	
	
<!---------------------------------------------------------------------------------------->
<cffunction name="rememberLastOtherId" access="remote">
	<cfargument name="yesno" type="numeric" required="yes">
	<cfset session.rememberLastOtherId=yesno>
	<cfreturn yesno>
</cffunction>
<!---------------------------------------------------------------------------------------->
<cffunction name="get_picked_event" access="remote">
	<cfargument name="collecting_event_id" type="numeric" required="yes">
		<cftry>

	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			collecting_event.COLLECTING_EVENT_ID,
			collecting_event.COLLECTING_EVENT_name,
			collecting_event.BEGAN_DATE,
			collecting_event.ENDED_DATE,
			collecting_event.VERBATIM_DATE,
			collecting_event.VERBATIM_LOCALITY,
			collecting_event.COLL_EVENT_REMARKS,
			<!----

			COLLECTING_SOURCE,
			COLLECTING_METHOD,
			HABITAT_DESC,


			---->
			locality.locality_id,
			geog_auth_rec.HIGHER_GEOG,
			locality.MAXIMUM_ELEVATION,
			locality.MINIMUM_ELEVATION,
			locality.ORIG_ELEV_UNITS,
			locality.SPEC_LOCALITY,
			locality.LOCALITY_REMARKS,
			locality.DEC_LAT,
			locality.DEC_LONG,
			decode (locality.DEC_LAT,
				NULL,'',
				'decimal degrees') ORIG_LAT_LONG_UNITS,
			locality.MAX_ERROR_DISTANCE,
			locality.MAX_ERROR_UNITS,
			locality.DATUM,
			locality.georeference_protocol,
			locality.georeference_source,
			locality.locality_name,
			<!----
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
			accepted_lat_long.ORIG_LAT_LONG_UNITS,
			llAgnt.agent_name DETERMINED_BY,
			accepted_lat_long.DETERMINED_DATE DETERMINED_DATE,
			accepted_lat_long.LAT_LONG_REF_SOURCE,
			accepted_lat_long.LAT_LONG_REMARKS,
			accepted_lat_long.EXTENT,
			accepted_lat_long.GPSACCURACY,
			accepted_lat_long.GEOREFMETHOD,
			accepted_lat_long.VERIFICATIONSTATUS,
			accepted_lat_long.UTM_ZONE,
			accepted_lat_long.UTM_EW,
			accepted_lat_long.UTM_NS,
			---->
			GEOLOGY_ATTRIBUTE,
			GEO_ATT_VALUE,
			getPreferredAgentName(GEO_ATT_DETERMINER_ID) GEO_ATT_DETERMINER,
			to_char(GEO_ATT_DETERMINED_DATE,'yyyy-mm-dd') GEO_ATT_DETERMINED_DATE,
			GEO_ATT_DETERMINED_METHOD,
			GEO_ATT_REMARK
		FROM
			geog_auth_rec,
			locality,
			geology_attributes,
			collecting_event
		WHERE
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
			locality.LOCALITY_ID = geology_attributes.LOCALITY_ID (+) AND
			locality.locality_id=collecting_event.LOCALITY_ID and
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
		<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				locality.locality_id,
				geog_auth_rec.HIGHER_GEOG,
				locality.MAXIMUM_ELEVATION,
				locality.MINIMUM_ELEVATION,
				locality.ORIG_ELEV_UNITS,
				locality.SPEC_LOCALITY,
				locality.LOCALITY_REMARKS,
				locality.DEC_LAT,
				locality.DEC_LONG,
				'decimal degrees' ORIG_LAT_LONG_UNITS,
				locality.MAX_ERROR_DISTANCE,
				locality.MAX_ERROR_UNITS,
				locality.DATUM,
				locality.georeference_protocol,
				locality.georeference_source,
				locality.locality_name,
				<!----
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
				accepted_lat_long.ORIG_LAT_LONG_UNITS,
				llAgnt.agent_name DETERMINED_BY,
				accepted_lat_long.DETERMINED_DATE DETERMINED_DATE,
				accepted_lat_long.LAT_LONG_REF_SOURCE,
				accepted_lat_long.LAT_LONG_REMARKS,
				accepted_lat_long.EXTENT,
				accepted_lat_long.GPSACCURACY,
				accepted_lat_long.GEOREFMETHOD,
				accepted_lat_long.VERIFICATIONSTATUS,
				accepted_lat_long.UTM_ZONE,
				accepted_lat_long.UTM_EW,
				accepted_lat_long.UTM_NS,
				---->
				GEOLOGY_ATTRIBUTE,
				GEO_ATT_VALUE,
				geoAgnt.agent_name GEO_ATT_DETERMINER,
				to_char(GEO_ATT_DETERMINED_DATE,'yyyy-mm-dd') GEO_ATT_DETERMINED_DATE,
				GEO_ATT_DETERMINED_METHOD,
				GEO_ATT_REMARK
			FROM
				geog_auth_rec,
				locality,
				geology_attributes,
				preferred_agent_name geoAgnt
			WHERE
				locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
				locality.LOCALITY_ID = geology_attributes.LOCALITY_ID (+) AND
				geology_attributes.GEO_ATT_DETERMINER_ID = geoAgnt.agent_id (+) AND
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