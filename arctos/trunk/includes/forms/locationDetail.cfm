<cfinclude template="/includes/_frameHeader.cfm">
<style>
	.lblCell{
		text-align:right;
	}
	.dataCell {
		font-weight:bold;
	}
	.lblCell:after {
		content: ": ";
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
				<cfif len(STATE_PROV) gt 0>
					<tr>
						<td class="lblCell">State/Province</td>
						<td class="dataCell">#STATE_PROV#</td>
					</tr>
				</cfif>
				<cfif len(COUNTY) gt 0>
					<tr>
						<td class="lblCell">County</td>
						<td class="dataCell">#COUNTY#</td>
					</tr>
				</cfif>
				<cfif len(QUAD) gt 0>
					<tr>
						<td class="lblCell">USGS Quad</td>
						<td class="dataCell">#QUAD#</td>
					</tr>
				</cfif>
				<cfif len(FEATURE) gt 0>
					<tr>
						<td class="lblCell">Feature</td>
						<td class="dataCell">#FEATURE#</td>
					</tr>
				</cfif>
				<cfif len(ISLAND) gt 0>
					<tr>
						<td class="lblCell">Island</td>
						<td class="dataCell">#ISLAND#</td>
					</tr>
				</cfif>
				<cfif len(ISLAND_GROUP) gt 0>
					<tr>
						<td class="lblCell">Island Group</td>
						<td class="dataCell">#ISLAND_GROUP#</td>
					</tr>
				</cfif>
				<cfif len(SEA) gt 0>
					<tr>
						<td class="lblCell">Sea</td>
						<td class="dataCell">#SEA#</td>
					</tr>
				</cfif>
				<cfif len(SOURCE_AUTHORITY) gt 0>
					<tr>
						<td class="lblCell">Source</td>
						<td class="dataCell">#SOURCE_AUTHORITY#</td>
					</tr>
				</cfif>
			</cfloop>
			<cfquery name="locality" dbtype="query">
				select
					MAXIMUM_ELEVATION,
					MINIMUM_ELEVATION,
					ORIG_ELEV_UNITS,
					SPEC_LOCALITY,
					LOCALITY_REMARKS,
					DEPTH_UNITS,
					MIN_DEPTH,
					MAX_DEPTH,
					NOGEOREFBECAUSE
				from r group by
					MAXIMUM_ELEVATION,
					MINIMUM_ELEVATION,
					ORIG_ELEV_UNITS,
					SPEC_LOCALITY,
					LOCALITY_REMARKS,
					DEPTH_UNITS,
					MIN_DEPTH,
					MAX_DEPTH,
					NOGEOREFBECAUSE
			</cfquery>
			<cfloop query="locality">
				<cfif len(SPEC_LOCALITY) gt 0>
					<tr>
						<td class="lblCell">Specific Locality</td>
						<td class="dataCell">#SPEC_LOCALITY#</td>
					</tr>
				</cfif>
				<cfif len(ORIG_ELEV_UNITS) gt 0>
					<cfif MINIMUM_ELEVATION is MAXIMUM_ELEVATION>
						<cfset e="#MINIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
					<cfelse>
						<cfset e="Between #MINIMUM_ELEVATION# and #MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
					</cfif>
					<tr>
						<td class="lblCell">Elevation</td>
						<td class="dataCell">#e#</td>
					</tr>
				</cfif>
				<cfif len(DEPTH_UNITS) gt 0>
					<cfif MIN_DEPTH is MAX_DEPTH>
						<cfset e="#MAX_DEPTH# #DEPTH_UNITS#">
					<cfelse>
						<cfset e="Between #MIN_DEPTH# and #MAX_DEPTH# #DEPTH_UNITS#">
					</cfif>
					<tr>
						<td class="lblCell">Depth</td>
						<td class="dataCell">#e#</td>
					</tr>
				</cfif>
				<cfif len(LOCALITY_REMARKS) gt 0>
					<tr>
						<td class="lblCell">Locality Remarks</td>
						<td class="dataCell">#LOCALITY_REMARKS#</td>
					</tr>
				</cfif>
				<cfif len(NOGEOREFBECAUSE) gt 0>
					<tr>
						<td class="lblCell">Not georeferenced because</td>
						<td class="dataCell">#NOGEOREFBECAUSE#</td>
					</tr>
				</cfif>
			</cfloop>
			<cfquery name="coords" dbtype="query">
				select
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
					coordinateDeterminer,
					DETERMINED_DATE
				from r group by
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
					coordinateDeterminer,
					DETERMINED_DATE
				order by
					ACCEPTED_LAT_LONG_FG desc
			</cfquery>
			<cfloop query="coords">
				--#ACCEPTED_LAT_LONG_FG#--
			</cfloop>
		</table>
	</cfoutput>	