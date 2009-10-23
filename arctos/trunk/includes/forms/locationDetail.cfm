<cfinclude template="/includes/_frameHeader.cfm">
<style>
.outer {
width:95%;
background-color:white;
}

.group {

}

.pair {
clear:both;

}

.value {
float:right;
width:69%;
font-weight:600;
text-align:left;
}

.data {
float:left;
width:30%;
text-align:right;
}

.title{
font-weight:bold;
clear:both;
padding-top:3em;
padding-left:4em;
}

.data:after{
content: ": ";
}
</style>
</div><!--- close the header div --->
<div class="infoLink" style="text-align:right;" onclick="removeDetail()">close</div>
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
			geog_auth_rec.geog_auth_rec_id=locality.geog_auth_rec_id(+) and
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
	<div class="outer">
		<div class="group">
			<cfloop query="geog">
				<div class="title">
					Geography
				</div>
				<cfif len(CONTINENT_OCEAN) gt 0>
					<div class="pair">
						<div class="data">Continent/Ocean</div>
						<div class="value">#CONTINENT_OCEAN#</div>
					</div>
				</cfif>
				<cfif len(COUNTRY) gt 0>
					<div class="pair">
						<div class="data">Country</div>
						<div class="value">#COUNTRY#</div>
					</div>
				</cfif>
				<cfif len(STATE_PROV) gt 0>
					<div class="pair">
						<div class="data">State/Province</div>
						<div class="value">#STATE_PROV#</div>
					</div>
				</cfif>
				<cfif len(COUNTY) gt 0>
					<div class="pair">
						<div class="data">County</div>
						<div class="value">#COUNTY#</div>
					</div>
				</cfif>
				<cfif len(QUAD) gt 0>
					<div class="pair">
						<div class="data">USGS Quad</div>
						<div class="value">#QUAD#</div>
					</div>
				</cfif>
				<cfif len(FEATURE) gt 0>
					<div class="pair">
						<div class="data">Feature</div>
						<div class="value">#FEATURE#</div>
					</div>
				</cfif>
				<cfif len(ISLAND) gt 0>
					<div class="pair">
						<div class="data">Island</div>
						<div class="value">#ISLAND#</div>
					</div>
				</cfif>
				<cfif len(ISLAND_GROUP) gt 0>
					<div class="pair">
						<div class="data">Island Group</div>
						<div class="value">#ISLAND_GROUP#</div>
					</div>
				</cfif>
				<cfif len(SEA) gt 0>
					<div class="pair">
						<div class="data">Sea</div>
						<div class="value">#SEA#</div>
					</div>
				</cfif>
				<cfif len(SOURCE_AUTHORITY) gt 0>
					<div class="pair">
						<div class="data">Source</div>
						<div class="value">#SOURCE_AUTHORITY#</div>
					</div>
				</cfif>
			</cfloop>
		</div>
		<cfif isdefined("locality_id") or isdefined("collecting_event_id")>
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
			<div class="group">
				<cfloop query="locality">
					<div class="title">
						Locality
					</div>
					<cfif len(SPEC_LOCALITY) gt 0>
						<div class="pair">
							<div class="data">Specific Locality</div>
							<div class="value">#SPEC_LOCALITY#</div>
						</div>
					</cfif>
					<cfif len(ORIG_ELEV_UNITS) gt 0>
						<cfif MINIMUM_ELEVATION is MAXIMUM_ELEVATION>
							<cfset e="#MINIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
						<cfelse>
							<cfset e="Between #MINIMUM_ELEVATION# and #MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
						</cfif>
						<div class="pair">
							<div class="data">Elevation</div>
							<div class="value">#e#</div>
						</div>
					</cfif>
					<cfif len(DEPTH_UNITS) gt 0>
						<cfif MIN_DEPTH is MAX_DEPTH>
							<cfset e="#MAX_DEPTH# #DEPTH_UNITS#">
						<cfelse>
							<cfset e="Between #MIN_DEPTH# and #MAX_DEPTH# #DEPTH_UNITS#">
						</cfif>
						<div class="pair">
							<div class="data">Depth</div>
							<div class="value">#e#</div>
						</div>
					</cfif>
					<cfif len(LOCALITY_REMARKS) gt 0>
						<div class="pair">
							<div class="data">Locality Remarks</div>
							<div class="value">#LOCALITY_REMARKS#</div>
						</div>
					</cfif>
					<cfif len(NOGEOREFBECAUSE) gt 0>
						<div class="pair">
							<div class="data">Not georeferenced because</div>
							<div class="value">#NOGEOREFBECAUSE#</div>
						</div>
					</cfif>
				</cfloop>
			</div>
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
				from r 
				where
					ACCEPTED_LAT_LONG_FG is not null
				group by
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
			<div class="group">
				<cfloop query="coords">
					<div class="title">
						<cfif ACCEPTED_LAT_LONG_FG is 1>
							Accepted Coordinates
						<cfelse>
							Unaccepted Coordinates
						</cfif>
					</div>
					<cfif ORIG_LAT_LONG_UNITS is "decimal degrees">
						<div class="pair">
							<div class="data">Decimal Latitude</div>
							<div class="value">#DEC_LAT#</div>
						</div>
						<div class="pair">
							<div class="data">Decimal Longitude</div>
							<div class="value">#DEC_LONG#</div>
						</div>
					<cfelseif ORIG_LAT_LONG_UNITS is "degrees dec. minutes">
						<div class="pair">
							<div class="data">Degrees Latitude</div>
							<div class="value">#LAT_DEG#</div>
						</div>
						<div class="pair">
							<div class="data">Minutes Latitude</div>
							<div class="value">#DEC_LAT_MIN#</div>
						</div>
						<div class="pair">
							<div class="data">Latitude Direction</div>
							<div class="value">#LAT_DIR#</div>
						</div>
						<div class="pair">
							<div class="data">Degrees Longitude</div>
							<div class="value">#LONG_DEG#</div>
						</div>
						<div class="pair">
							<div class="data">Minutes Longitude</div>
							<div class="value">#DEC_LONG_MIN#</div>
						</div>
						<div class="pair">
							<div class="data">Longitude Direction</div>
							<div class="value">#LONG_DIR#</div>
						</div>
					<cfelseif ORIG_LAT_LONG_UNITS is "deg. min. sec.">
						<div class="pair">
							<div class="data">Degrees Latitude</div>
							<div class="value">#LAT_DEG#</div>
						</div>
						<div class="pair">
							<div class="data">Minutes Latitude</div>
							<div class="value">#LAT_MIN#</div>
						</div>
						<div class="pair">
							<div class="data">Seconds Latitude</div>
							<div class="value">#LAT_SEC#</div>
						</div>
						<div class="pair">
							<div class="data">Latitude Direction</div>
							<div class="value">#LAT_DIR#</div>
						</div>
						<div class="pair">
							<div class="data">Degrees Longitude</div>
							<div class="value">#LONG_DEG#</div>
						</div>
						<div class="pair">
							<div class="data">Minutes Longitude</div>
							<div class="value">#LONG_MIN#</div>
						</div>
						<div class="pair">
							<div class="data">Seconds Longitude</div>
							<div class="value">#LONG_SEC#</div>
						</div>
						<div class="pair">
							<div class="data">Longitude Direction</div>
							<div class="value">#LONG_DIR#</div>
						</div>
					<cfelseif ORIG_LAT_LONG_UNITS is "UTM">
						<div class="pair">
							<div class="data">UTM Zone</div>
							<div class="value">#UTM_ZONE#</div>
						</div>
						<div class="pair">
							<div class="data">UTM E/W</div>
							<div class="value">#UTM_EW#</div>
						</div>
						<div class="pair">
							<div class="data">UTM N/S</div>
							<div class="value">#UTM_NS#</div>
						</div>
					</cfif>
					<div class="pair">
						<div class="data">Datum</div>
						<div class="value">#DATUM#</div>
					</div>
					<div class="pair">
						<div class="data">Reference</div>
						<div class="value">#LAT_LONG_REF_SOURCE#</div>
					</div>
					<div class="pair">
						<div class="data">Reference</div>
						<div class="value">#LAT_LONG_REF_SOURCE#</div>
					</div>
					<cfif len(MAX_ERROR_DISTANCE) gt 0>
						<div class="pair">
							<div class="data">Error</div>
							<div class="value">#MAX_ERROR_DISTANCE# #MAX_ERROR_UNITS#</div>
						</div>
					</cfif>
					<div class="pair">
						<div class="data">Determiner</div>
						<div class="value">#coordinateDeterminer#</div>
					</div>
					<div class="pair">
						<div class="data">Determined Date</div>
						<div class="value">#dateformat(DETERMINED_DATE,"dd mmm yyyy")#</div>
					</div>
					<div class="pair">
						<div class="data">Method</div>
						<div class="value">#GEOREFMETHOD#</div>
					</div>
					<div class="pair">
						<div class="data">Verification Status</div>
						<div class="value">#VERIFICATIONSTATUS#</div>
					</div>
					<cfif len(EXTENT) gt 0>
						<div class="pair">
							<div class="data">Extent</div>
							<div class="value">#EXTENT# #MAX_ERROR_UNITS#</div>
						</div>
					</cfif>
					<cfif len(GPSACCURACY) gt 0>
						<div class="pair">
							<div class="data">GPS Accuracy</div>
							<div class="value">#GPSACCURACY# #MAX_ERROR_UNITS#</div>
						</div>
					</cfif>
					<cfif len(GEOREFMETHOD) gt 0>
						<div class="pair">
							<div class="data">Method</div>
							<div class="value">#GEOREFMETHOD#</div>
						</div>
					</cfif>
					<cfif len(LAT_LONG_REMARKS) gt 0>
						<div class="pair">
							<div class="data">Remark</div>
							<div class="value">#LAT_LONG_REMARKS#</div>
						</div>
					</cfif>
				</cfloop>
			</div>
			<cfquery name="geology" dbtype="query">
				select
					GEOLOGY_ATTRIBUTE,
					GEO_ATT_VALUE,
					geologyDeterminer,
					GEO_ATT_DETERMINED_DATE,
					GEO_ATT_DETERMINED_METHOD,
					GEO_ATT_REMARK
				from r group by
					GEOLOGY_ATTRIBUTE,
					GEO_ATT_VALUE,
					geologyDeterminer,
					GEO_ATT_DETERMINED_DATE,
					GEO_ATT_DETERMINED_METHOD,
					GEO_ATT_REMARK
			</cfquery>
			<div class="group">
				<cfloop query="geology">
					<div class="pair">
						<div class="data">#GEOLOGY_ATTRIBUTE#</div>
						<div class="value"></div>
					</div>
					<div class="pair">
						<div class="data">Attribute Value</div>
						<div class="value">#GEO_ATT_VALUE#</div>
					</div>
					<cfif len(geologyDeterminer) gt 0>
						<div class="pair">
							<div class="data">Determiner</div>
							<div class="value">#geologyDeterminer#</div>
						</div>
					</cfif>
					<cfif len(GEO_ATT_DETERMINED_METHOD) gt 0>
						<div class="pair">
							<div class="data">Method</div>
							<div class="value">#GEO_ATT_DETERMINED_METHOD#</div>
						</div>
					</cfif>
					<cfif len(GEO_ATT_DETERMINED_DATE) gt 0>
						<div class="pair">
							<div class="data">Determined Date</div>
							<div class="value">#GEO_ATT_DETERMINED_DATE#</div>
						</div>
					</cfif>
					<cfif len(GEO_ATT_REMARK) gt 0>
						<div class="pair">
							<div class="data">Remark</div>
							<div class="value">#GEO_ATT_REMARK#</div>
						</div>
					</cfif>
				</cfloop>
			</div>
		</cfif>
		<cfif isdefined("collecting_event_id")>
			<cfquery name="event" dbtype="query">
				select
					BEGAN_DATE,
					ENDED_DATE,
					VERBATIM_DATE,
					VERBATIM_LOCALITY,
					COLL_EVENT_REMARKS,
					COLLECTING_SOURCE,
					COLLECTING_METHOD,
					HABITAT_DESC
				from r group by
					BEGAN_DATE,
					ENDED_DATE,
					VERBATIM_DATE,
					VERBATIM_LOCALITY,
					COLL_EVENT_REMARKS,
					COLLECTING_SOURCE,
					COLLECTING_METHOD,
					HABITAT_DESC	
			</cfquery>
			<div class="group">
				<cfloop query="event">
					<cfif (verbatim_date is began_date) AND (verbatim_date is ended_date)>
					    <cfset thisDate = dateformat(began_date,"dd mmm yyyy")>
			        <cfelseif ((verbatim_date is not began_date) OR (verbatim_date is not ended_date)) AND began_date is ended_date>
					    <cfset thisDate = "#verbatim_date# (#dateformat(began_date,'dd mmm yyyy')#)">
			        <cfelse>
					    <cfset thisDate = "#verbatim_date# (#dateformat(began_date,'dd mmm yyyy')# - #dateformat(ended_date,'dd mmm yyyy')#)">
			        </cfif>
					<div class="title">
						Collecting Event
					</div>
			        <div class="pair">
						<div class="data">Date</div>
						<div class="value">#thisDate#</div>
					</div>
					<cfif len(VERBATIM_LOCALITY) gt 0>
						<div class="pair">
							<div class="data">Verbatim Locality</div>
							<div class="value">#VERBATIM_LOCALITY#</div>
						</div>
					</cfif>
					<cfif len(COLLECTING_SOURCE) gt 0>
						<div class="pair">
							<div class="data">Collecting Source</div>
							<div class="value">#COLLECTING_SOURCE#</div>
						</div>
					</cfif>
					<cfif len(COLLECTING_METHOD) gt 0>
						<div class="pair">
							<div class="data">Collecting Method</div>
							<div class="value">#COLLECTING_METHOD#</div>
						</div>
					</cfif>
					<cfif len(HABITAT_DESC) gt 0>
						<div class="pair">
							<div class="data">Habitat</div>
							<div class="value">#HABITAT_DESC#</div>
						</div>
					</cfif>
					<cfif len(COLL_EVENT_REMARKS) gt 0>
						<div class="pair">
							<div class="data">Event Remarks</div>
							<div class="value">#COLL_EVENT_REMARKS#</div>
						</div>
					</cfif>							
				</cfloop>
			</div>
		</cfif>
	</div>
</cfoutput>	