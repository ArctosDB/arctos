<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<style>

	.higher_geog {
		border:1px solid green;
		margin:1em;
		padding:.1em;
	}
	.eventloc {
		border:1px solid red;
		margin:1em;
		padding:.1em;
		margin: .1em .1em .1em 1em;
	}
	.locality {
		 display: table-row;
		width:100%;
	}
	.localityData{
		display: table-cell;
		vertical-align: top;
		padding:.1em;
		width:80%;
	}
	.mapgohere {
		vertical-align: top;
		display: table-cell;
		width:20%;
	}
	.event {
		border:1px solid blue;
		padding:.1em;
		margin: .1em .1em .1em 1em;
	}



</style>
<script>
		jQuery(document).ready(function() {
			$.each($("div[id^='mapgohere-']"), function() {
				var theElemID=this.id;
				var theIDType=this.id.split('-')[1];
				var theID=this.id.split('-')[2];
			  	var ptl='/component/functions.cfc?method=getMap&showCaption=false&returnformat=plain&size=100x100&' + theIDType + '=' + theID;
			    jQuery.get(ptl, function(data){
					jQuery("#" + theElemID).html(data);
				});
			});
		});
	</script>
<!---------------------------------------------------------------------------------------------------->
<cfoutput>
	<cfset title="Explore Localities">
	<cfset showLocality=1>
	<cfset showEvent=1>
	<strong>Find Localities</strong>
    <form name="getCol" method="get" action="showLocality2.cfm##results">
		<input type="hidden" name="action" value="srch">
		<cfinclude template="/includes/frmFindLocation_guts.cfm">
    </form>
<!---------------------------------------------------------------------------------------------------->

	<cfset title="Locality Information">
	<cf_findLocality type="event" rowlimit=200>


<a name="results"></a>

<cfif localityResults.recordcount is 0>
	nothing found; try another search
</cfif>
<!----
 	COLLECTING_EVENT_ID
COLLECTING_EVENT_NAME
CONTINENT_OCEAN 	COUNTRY 	COUNTY 	DATUM 	DEC_LAT 	DEC_LONG
	DEPTH_UNITS 	ENDED_DATE 	FEATURE 	GEOG_AUTH_REC_ID 	GEOG_REMARK
		GEOLATTS 	GEOREFERENCE_PROTOCOL 	GEOREFERENCE_SOURCE 	HIGHER_GEOG
			ISLAND 	ISLAND_GROUP 	LOCALITY_ID 	LOCALITY_NAME 	LOCALITY_REMARKS
			MAXIMUM_ELEVATION 	MAXIMUM_ELEVATION 	MAX_DEPTH 	MAX_ERROR_DISTANCE
			MAX_ERROR_UNITS 	MINIMUM_ELEVATION 	MINIMUM_ELEVATION 	MIN_DEPTH
			ORIG_ELEV_UNITS 	ORIG_ELEV_UNITS 	QUAD 	SEA 	SOURCE_AUTHORITY
			SPEC_LOCALITY 	STATE_PROV 	VERBATIM_COORDINATES 	VERBATIM_DATE 	VERBATIM_LOCALITY



---->

		<cfquery name="geog" dbtype="query">
			select distinct higher_geog, SOURCE_AUTHORITY,geog_auth_rec_id from localityResults order by higher_geog
		</cfquery>
		<cfloop query="geog">
			<div class="higher_geog">
				Higher Geography: #higher_geog#
				<a class="infoLink" href="/geography.cfm?geog_auth_rec_id=#geog_auth_rec_id#">[ details ]</a>
				<cfif SOURCE_AUTHORITY contains "http">
					<a class="infoLink external" target="_blank" href="#SOURCE_AUTHORITY#">[ #SOURCE_AUTHORITY# ]</a>
				</cfif>
				<cfquery name="searchterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select SEARCH_TERM from geog_search_term where geog_auth_rec_id=#val(geog_auth_rec_id)# order by SEARCH_TERM
				</cfquery>
				<cfloop query="searchterm">
					<div class="searchterm">
						#SEARCH_TERM#
					</div><!---- /searchterm ---->
				</cfloop>
				<cfquery name="locality" dbtype="query">
					select
						locality_id,
						spec_locality,
						dec_lat,
						dec_long,
						DEPTH_UNITS,
						ORIG_ELEV_UNITS,
						MINIMUM_ELEVATION,
						MAXIMUM_ELEVATION,
						MIN_DEPTH,
						MAX_DEPTH,
						MAX_ERROR_UNITS,
						MAX_ERROR_DISTANCE,
						GEOREFERENCE_PROTOCOL,
						GEOREFERENCE_SOURCE,
						LOCALITY_NAME,
						LOCALITY_REMARKS,
						GEOLATTS
					from
						localityResults
					where
						geog_auth_rec_id=#val(geog_auth_rec_id)#
					group by
						locality_id,
						spec_locality,
						dec_lat,
						dec_long,
						DEPTH_UNITS,
						ORIG_ELEV_UNITS,
						MINIMUM_ELEVATION,
						MAXIMUM_ELEVATION,
						MIN_DEPTH,
						MAX_DEPTH,
						MAX_ERROR_DISTANCE,
						MAX_ERROR_UNITS,
						GEOREFERENCE_PROTOCOL,
						GEOREFERENCE_SOURCE,
						LOCALITY_NAME,
						LOCALITY_REMARKS,
						GEOLATTS
					order by
						spec_locality,
						dec_lat,
						dec_long
				</cfquery>
				<cfloop query="locality">
					<div class="eventloc">
						<div class="locality">
							<div class="localityData">
								Specific Locality: #spec_locality#
								<cfif len(DEPTH_UNITS) gt 0>
									<br>Depth: #MIN_DEPTH#-#MAX_DEPTH# #DEPTH_UNITS#
								</cfif>
								<cfif len(ORIG_ELEV_UNITS) gt 0>
									<br>Elevation: #MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#
								</cfif>
								<cfif len(MAX_ERROR_UNITS) gt 0>
									<br>Coordinate Error: #MAX_ERROR_DISTANCE# #MAX_ERROR_UNITS#
								</cfif>
								<cfif len(GEOREFERENCE_PROTOCOL) gt 0>
									<br>Georeference Protocol: #GEOREFERENCE_PROTOCOL#
								</cfif>
								<cfif len(GEOREFERENCE_SOURCE) gt 0>
									<br>Georeference Source: #GEOREFERENCE_SOURCE#
								</cfif>
								<cfif len(LOCALITY_NAME) gt 0>
									<br>Locality Name: #LOCALITY_NAME#
								</cfif>
								<cfif len(LOCALITY_REMARKS) gt 0>
									<br>Locality Remarks: #LOCALITY_REMARKS#
								</cfif>
								<cfif len(GEOLATTS) gt 0>
									<br>Geology Attribues: #GEOLATTS#
								</cfif>
								<cfquery name="locmedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
									select count(*) c from media_relations where related_primary_key=#val(locality_id)# and
									media_relationship like '% locality'
								</cfquery>
								<cfif locMedia.c gt 0>
									<br>
									<a href="MediaSearch.cfm?action=search&locality_id=#locality_id#">
										#locmedia.c# Media Records
									</a>
								</cfif>
								<cfquery name="locSpec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
									select
										count(*) c
									from
										specimen_event,
										collecting_event
									where
										specimen_event.collecting_event_id=collecting_event.collecting_event_id and
										collecting_event.locality_id=#val(locality_id)#
								</cfquery>
								<cfif locSpec.c gt 0>
									<br>
									<a href="SpecimenResults.cfm?locality_id=#locality_id#">
										#locSpec.c# Specimen Records
									</a>
								</cfif>
							</div> <!---- localityData/ ---->
							<cfif len(dec_lat) gt 0>
								<div class="mapgohere" id="mapgohere-locality_id-#locality_id#">
									<img src="/images/indicator.gif"> [#dec_lat#/#dec_long#]
								</div><!---- /mapgohere ---->
							</cfif>
						</div><!--- locality ---->
						<cfquery name="event" dbtype="query">
							select
								COLLECTING_EVENT_ID,
								COLLECTING_EVENT_NAME,
								verbatim_locality,
								verbatim_date,
								began_date,
								ended_date
							from
								localityResults
							where
								locality_id=#val(locality_id)#
							group by
								COLLECTING_EVENT_ID,
								COLLECTING_EVENT_NAME,
								verbatim_locality,
								verbatim_date,
								began_date,
								ended_date
							order by
								verbatim_locality,
								verbatim_date,
								began_date,
								ended_date
						</cfquery>
						<cfloop query="event">
							<cfif (verbatim_date is began_date) AND (verbatim_date is ended_date)>
								<cfset thisDate = began_date>
							<cfelseif ((verbatim_date is not began_date) OR	(verbatim_date is not ended_date)) AND
									began_date is ended_date>
								<cfset thisDate = "#verbatim_date# (#began_date#)">
							<cfelse>
								<cfset thisDate = "#verbatim_date# (#began_date# - #ended_date#)">
							</cfif>
							<div class="event">
								Verbatim Locality: #verbatim_locality#
								<br>Date: #thisDate#
								<cfif len(COLLECTING_EVENT_NAME) gt 0>
									<br>Event Name: #COLLECTING_EVENT_NAME#
								</cfif>
								<cfquery name="eventmedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
									select count(*) c from media_relations where related_primary_key=#val(COLLECTING_EVENT_ID)# and
									media_relationship like '% collecting_event'
								</cfquery>
								<cfif eventmedia.c gt 0>
									<br>
									<a href="MediaSearch.cfm?action=search&collecting_event_id=#COLLECTING_EVENT_ID#">
										#eventmedia.c# Media Records
									</a>
								</cfif>
								<cfquery name="eventSpec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
									select
										count(*) c
									from
										specimen_event
									where
										specimen_event.collecting_event_id=#val(COLLECTING_EVENT_ID)#
								</cfquery>
								<cfif eventSpec.c gt 0>
									<br>
									<a href="SpecimenResults.cfm?COLLECTING_EVENT_ID=#COLLECTING_EVENT_ID#">
										#eventSpec.c# Specimen Records
									</a>
								</cfif>
							</div><!---- event ---->
						</cfloop>
					</div>
				</cfloop>
			</div><!---- /higher_geog ---->
		</cfloop>


	</cfoutput>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">