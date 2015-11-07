<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<style>

	.higher_geog {
		border:1px solid black;
	}
	.searchterm {
		border:1px solid black;
		font-size:small;
	}

	.locality {
		padding-left:1em;
		width:100%;
		 display: table;
		border-left:1em solid lightgray;
	}
	.mapgohere {
		vertical-align: top;
		display: table-cell;
	}
	.localityData{
		display: table-cell;
		vertical-align: top;

	}


	.event {
		border:1px solid black;
		padding-left:2em;
		border-left:2em solid lightblue;
	}

</style>
<div class="higher_geog">
	Higher Geography:
	<div class="searchterm">
		SEARCH_TERM
	</div><!---- /searchterm ---->
	<div class="locality">
		<div class="localityData">
			locality data
		</div>
		<div class="mapgohere">
			ima map
		</div>
		<div class="event">
			events
		</div>
	</div>
</div>
<cfabort>




				<a class="infoLink" href="/geography.cfm?geog_auth_rec_id=#geog_auth_rec_id#">[ details ]</a>
				<cfif SOURCE_AUTHORITY contains "http">
					<a class="infoLink external" target="_blank" href="#SOURCE_AUTHORITY#">[ #SOURCE_AUTHORITY# ]</a>
				</cfif>
				<cfquery name="searchterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
					select SEARCH_TERM from geog_search_term where geog_auth_rec_id=#val(geog_auth_rec_id)# order by SEARCH_TERM
				</cfquery>
				<cfloop query="searchterm">

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
									<a href="MediaSearch.cfm?action=search&specimen_collecting_event_id=#COLLECTING_EVENT_ID#">
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
					</div><!---- /locality ---->
			</cfloop>
		</div><!---- /higher_geog ---->


		</cfloop>


afterloop
		<!------------





		<cfquery name="localityResults" dbtype="query">
			select
				collecting_event_id,
				higher_geog,
				geog_auth_rec_id,
				spec_locality,
				geolAtts,
				Verbatim_coordinates,
				locality_id,
				verbatim_locality,
				dec_lat,
				dec_long,
				began_date,
				ended_date,
				verbatim_date
			from
				localityResults
			group by
				collecting_event_id,
				higher_geog,
				geog_auth_rec_id,
				spec_locality,
				geolAtts,
				Verbatim_coordinates,
				dec_lat,
				dec_long,
				locality_id,
				verbatim_locality,
				began_date,
				ended_date,
				verbatim_date
		</cfquery>
		<a href="showLocality2.cfm">Search Again</a>
		<table border id="t" class="sortable">
			<tr>
				<th>Geography</th>
				<th>Locality</th>
				<th>Event</th>
			</tr>
			<cfset x=0>
			<cfloop query="localityResults">
				<cfset x=x+1>
		        <cfif (verbatim_date is began_date) AND (verbatim_date is ended_date)>
					<cfset thisDate = began_date>
				<cfelseif (
							(verbatim_date is not began_date) OR
				 			(verbatim_date is not ended_date)
						)
						AND
						began_date is ended_date>
						<cfset thisDate = "#verbatim_date# (#began_date#)">
				<cfelse>
						<cfset thisDate = "#verbatim_date# (#began_date# - #ended_date#)">
				</cfif>
		        <tr>
					<td>
						<span class="infoLink" onclick="expand('geog_auth_rec_id', #geog_auth_rec_id#)">[&nbsp;details&nbsp;]</span>
						<a href="showLocality2.cfm?action=srch&geog_auth_rec_id=#geog_auth_rec_id#">#higher_geog#</a>
					</td>
					<td>
						<cfif len(locality_id) gt 0>
							<span class="infoLink" onclick="expand('locality_id', #locality_id#)">[&nbsp;details&nbsp;]</span>
							<cfif len(spec_locality) gt 0>
								<a href="showLocality2.cfm?action=srch&locality_id=#locality_id#">#spec_locality#</a>
							<cfelse>
								[null]
							</cfif>
							<cfif len(geolAtts) gt 0>[#geolAtts#]</cfif>
							<cfif len(dec_lat) gt 0>
								<div id="mapgohere-locality_id-#locality_id#">
									<img src="/images/indicator.gif"> [#dec_lat#/#dec_long#]
								</div
								<!----
								<br>#dec_lat#/#dec_long#
								<cfif x lte 25>
									<cfinvoke component="component.functions" method="getMap" returnvariable="contents">
									    <cfinvokeargument name="locality_id" value="#locality_id#">
									</cfinvoke>
									#contents#
								</cfif>
								---->
							</cfif>
						<cfelse>
							[no localities]
						</cfif>
					<td>
						<cfif len(collecting_event_id) gt 0>
							<span class="infoLink" onclick="expand('collecting_event_id', #collecting_event_id#)">[&nbsp;details&nbsp;]</span>
							<a href="showLocality2.cfm?action=srch&collecting_event_id=#collecting_event_id#">
							<cfif len(verbatim_locality) gt 0>
								#verbatim_locality#
							<cfelse>
								[null]
							</cfif>
							</a>
							<br>#thisDate#
						<cfelse>
							[no events]
						</cfif>
					</td>
				</tr>
			</cfloop>
		</table>
		--------->
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">