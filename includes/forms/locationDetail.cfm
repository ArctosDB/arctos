<cfinclude template="/includes/_frameHeader.cfm">
<style>
	.lblCell{
		text-align:right;
	}
	.dataCell {
		font-weight:bold;
	}
</style>
<cfoutput>
	<cfquery name="r" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			CONTINENT_OCEAN,
			COUNTRY,
			STATE_PROV,
			COUNTY,
			QUAD,
			FEATURE,
			ISLAND,
			ISLAND_GROUP,
			SEA,
			SOURCE_AUTHORITY,
			HIGHER_GEOG,
			MAXIMUM_ELEVATION,
			MINIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			SPEC_LOCALITY,
			LOCALITY_REMARKS,
			DEPTH_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			NOGEOREFBECAUSE,
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
			DATUM,
			UTM_ZONE,
			UTM_EW,
			UTM_NS,
			ORIG_LAT_LONG_UNITS,
			LAT_LONG_REF_SOURCE,
			LAT_LONG_REMARKS,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
			ACCEPTED_LAT_LONG_FG,
			EXTENT,
			GPSACCURACY,
			GEOREFMETHOD,
			VERIFICATIONSTATUS,
			cdet.agent_name coordinateDeterminer,
			DETERMINED_DATE,
			GEOLOGY_ATTRIBUTE,
			GEO_ATT_VALUE,
			gdet.agent_name geologyDeterminer,
			GEO_ATT_DETERMINED_DATE,
			GEO_ATT_DETERMINED_METHOD,
			GEO_ATT_REMARK,
			COLLECTING_EVENT_ID,
			BEGAN_DATE,
			ENDED_DATE,
			VERBATIM_DATE,
			VERBATIM_LOCALITY,
			COLL_EVENT_REMARKS,
			COLLECTING_SOURCE,
			COLLECTING_METHOD,
			HABITAT_DESC	
		from
			geog_auth_rec,
			locality,
			lat_long,
			geology_attributes,
			preferred_agent_name cdet,
			preferred_agent_name gdet,
			collecting_event
		where
			locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
			locality.locality_id=lat_long.locality_id(+) and
			lat_long.determined_by_agent_id=cdet.agent_id(+) and
			locality.locality_id=geology_attributes.locality_id(+) and
			geology_attributes.GEO_ATT_DETERMINER_ID=gdet.agent_id(+) and
			locality.locality_id=collecting_event.locality_id(+) and
			<cfif isdefined("geog_auth_rec_id") and len(geog_auth_rec_id) gt 0>
				geog_auth_rec.geog_auth_rec_id=#geog_auth_rec_id#
			<cfelseif isdefined("locality_id") and len(locality_id) gt 0>
				locality.locality_id=#locality_ID#
			<cfelseif isdefined("collecting_event_id") and len(collecting_event_id) gt 0>
				collecting_event.collecting_event_id=#collecting_event_id#
			</cfif>
		</cfquery>
		<cfquery name="geog" dbtype="query">
			select
				CONTINENT_OCEAN,
				COUNTRY,
				STATE_PROV,
				COUNTY,
				QUAD,
				FEATURE,
				ISLAND,
				ISLAND_GROUP,
				SEA,
				SOURCE_AUTHORITY,
				HIGHER_GEOG
			from r
			group by
				CONTINENT_OCEAN,
				COUNTRY,
				STATE_PROV,
				COUNTY,
				QUAD,
				FEATURE,
				ISLAND,
				ISLAND_GROUP,
				SEA,
				SOURCE_AUTHORITY,
				HIGHER_GEOG
		</cfquery>
		<table>
			<cfloop query="geog">
				<cfif len(CONTINENT_OCEAN) gt 0>
					<tr>
						<td class="lblCell">Continent/Ocean</td>
						<td class="dataCell">#CONTINENT_OCEAN#</td>
					</tr>
				</cfif>
				<cfif len(COUNTRY) gt 0>
					<tr>
						<td class="lblCell">Country</td>
						<td class="dataCell">#COUNTRY#</td>
					</tr>
				</cfif>
				<!----
				<div class="lrPair">
					<div class="leftS"></div>
					<div class="rightS"></div>
				</div>
				<div class="lrPair">
					<div class="leftS"></div>
					<div class="rightS">#COUNTRY#</div>
				</div>
				<div class="lrPair">
					<div class="leftS">State/Province</div>
					<div class="rightS">#STATE_PROV#</div>
				</div>
				<div class="lrPair">
					<div class="leftS">County</div>
					<div class="rightS">#COUNTY#</div>
				</div>
				<div class="lrPair">
					<div class="leftS">Country</div>
					<div class="rightS">#COUNTRY#</div>
				</div>
				<div class="lrPair">
					<div class="leftS">Country</div>
					<div class="rightS">#COUNTRY#</div>
				</div>
				<div class="lrPair">
					<div class="leftS">Country</div>
					<div class="rightS">#COUNTRY#</div>
				</div>
				<div class="lrPair">
					<div class="leftS">Country</div>
					<div class="rightS">#COUNTRY#</div>
				</div>
				<div class="lrPair">
					<div class="leftS">Country</div>
					<div class="rightS">#COUNTRY#</div>
				</div>
				<div class="lrPair">
					<div class="leftS">Country</div>
					<div class="rightS">#COUNTRY#</div>
				</div>
				,
				,
				,
				,
				QUAD,
				FEATURE,
				ISLAND,
				ISLAND_GROUP,
				SEA,
				SOURCE_AUTHORITY,
				HIGHER_GEOG
				---->
			</cfloop>
		</table>
	</cfoutput>	