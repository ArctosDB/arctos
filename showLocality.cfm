<cfinclude template="includes/_header.cfm">
<style>

	.higher_geog {
		border:1px dashed #6E8A84;
		background: #EBEFEE;
		margin:1em;
		padding:.1em;
	}
	.eventloc {
		border:1px dashed #339933;
		background: #DCE3E1;
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
		width:100%;
	}
	.mapgohere {
		vertical-align: top;
		display: table-cell;
		width:20%;
	}
	.event {
		border:1px dashed #669999;

		background: #CCD6D4;
		padding:.1em;
		margin: .1em .1em .1em 1em;
	}
	.sevent {
		border:1px dashed #669999;
		background: #BCCAC7;
		padding:.1em;
		margin: .1em .1em .1em 1em;
	}
	.searchterm{
		font-size:x-small;
		margin-left: 1em;
		font-weight:100;
	}
	.dTtl {font-size:small;}
	.dVal {font-weight:600;font-size:smaller;}
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
	<cfparam name="showDetail" default="locality">
	<strong>Find Localities</strong>
    <form name="getCol" method="get" action="showLocality.cfm##results">
		<input type="hidden" name="action" value="srch">
		<label for="showDetail">Show Detail To</label>
		<select name="showDetail">
			<option <cfif showDetail is "geography"> selected="selected" </cfif>value="geography">geography</option>
			<option <cfif showDetail is "locality"> selected="selected" </cfif>value="locality">locality</option>
			<option <cfif showDetail is "event"> selected="selected" </cfif>value="event">event</option>
			<option <cfif showDetail is "specimenevent"> selected="selected" </cfif>value="specimenevent">specimen-event</option>
		</select>
		<cfinclude template="/includes/frmFindLocation_guts.cfm">

    </form>
	<cf_findLocality type="event" rowlimit=100>
	<a name="results"></a>
	<cfif localityResults.recordcount is 0>
		nothing found; try another search
	</cfif>
	<cfquery name="geog" dbtype="query">
		select distinct higher_geog, SOURCE_AUTHORITY,geog_auth_rec_id from localityResults order by higher_geog
	</cfquery>
	<cfloop query="geog">
		<div class="higher_geog">
			<span class="dTtl">Higher Geography:</span> <span class="dVal">#higher_geog#</span>
			<a class="infoLink" href="/geography.cfm?geog_auth_rec_id=#geog_auth_rec_id#">[ details ]</a>
			<cfif SOURCE_AUTHORITY contains "http">
				<a class="infoLink external" target="_blank" href="#SOURCE_AUTHORITY#">[ #SOURCE_AUTHORITY# ]</a>
			</cfif>
			<a class="infoLink" href="/showLocality.cfm?geog_auth_rec_id=#geog_auth_rec_id#">[ show only ]</a>
			<cfif session.roles contains "manage_geography">
				<a class="infoLink" href="/Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">[ edit ]</a>
			</cfif>
			<a class="infoLink" href="/showLocality.cfm?geog_auth_rec_id=#geog_auth_rec_id#">[ show only ]</a>
			<cfquery name="searchterm" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select SEARCH_TERM from geog_search_term where geog_auth_rec_id=#val(geog_auth_rec_id)# order by SEARCH_TERM
			</cfquery>
			<cfloop query="searchterm">
				<div class="searchterm">
					#SEARCH_TERM#
				</div><!---- /searchterm ---->
			</cfloop>
			<cfquery name="geogSpec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
				select
					count(*) c
				from
					specimen_event,
					collecting_event,
					locality
				where
					specimen_event.collecting_event_id=collecting_event.collecting_event_id and
					collecting_event.locality_id=locality.locality_id and
					locality.geog_auth_rec_id=#val(geog_auth_rec_id)#
			</cfquery>
			<cfif geogSpec.c gt 0>
				<br>
				<a href="SpecimenResults.cfm?geog_auth_rec_id=#geog_auth_rec_id#">
					#geogSpec.c# Specimen Records
				</a>
			</cfif>

			<cfif showDetail is "locality" or showDetail is "event" or showDetail is "specimenevent">
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
								<span class="dTtl">Specific Locality:</span> <span class="dVal">#spec_locality#</span>
								<cfif len(DEPTH_UNITS) gt 0>
									<br><span class="dTtl">Depth:</span> <span class="dVal">#MIN_DEPTH#-#MAX_DEPTH# #DEPTH_UNITS#</span>
								</cfif>
								<cfif len(ORIG_ELEV_UNITS) gt 0>
									<br><span class="dTtl">Elevation:</span> <span class="dVal">#MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#</span>
								</cfif>
								<cfif len(MAX_ERROR_UNITS) gt 0>
									<br><span class="dTtl">Coordinate Error:</span> <span class="dVal">#MAX_ERROR_DISTANCE# #MAX_ERROR_UNITS#</span>
								</cfif>
								<cfif len(GEOREFERENCE_PROTOCOL) gt 0>
									<br><span class="dTtl">Georeference Protocol:</span> <span class="dVal">#GEOREFERENCE_PROTOCOL#</span>
								</cfif>
								<cfif len(GEOREFERENCE_SOURCE) gt 0>
									<br><span class="dTtl">Georeference Source:</span> <span class="dVal">#GEOREFERENCE_SOURCE#</span>
								</cfif>
								<cfif len(LOCALITY_NAME) gt 0>
									<br><span class="dTtl">Locality Name:</span> <span class="dVal">#LOCALITY_NAME#</span>
								</cfif>
								<cfif len(LOCALITY_REMARKS) gt 0>
									<br><span class="dTtl">Locality Remarks:</span> <span class="dVal">#LOCALITY_REMARKS#</span>
								</cfif>
								<cfif len(GEOLATTS) gt 0>
									<br><span class="dTtl">Geology Attribues:</span> <span class="dVal">#GEOLATTS#</span>
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
								<cfif session.roles contains "manage_locality">
									<a href="editLocality.cfm?locality_id=#locality_id#">
										Edit
									</a>
								</cfif>
							</div> <!---- localityData/ ---->
							<cfif len(dec_lat) gt 0>
								<div class="mapgohere" id="mapgohere-locality_id-#locality_id#">
									<img src="/images/indicator.gif"> [#dec_lat#/#dec_long#]
								</div><!---- /mapgohere ---->
							</cfif>
						</div><!--- locality ---->
						<cfif showDetail is "event" or showDetail is "specimenevent">
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
									<span class="dTtl">Verbatim Locality:</span> <span class="dVal">#verbatim_locality#</span>
									<br><span class="dTtl">Date:</span> <span class="dVal">#thisDate#</span>
									<cfif len(COLLECTING_EVENT_NAME) gt 0>
										<br><span class="dTtl">Event Name:</span> <span class="dVal">#COLLECTING_EVENT_NAME#</span>
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
									<cfif session.roles contains "manage_locality">
										<a href="/Locality.cfm?Action=editCollEvnt&collecting_event_id=#collecting_event_id#">
											Edit
										</a>
									</cfif>
									<cfif showDetail is "specimenevent">
										<cfquery name="sevent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
											select
												SPECIMEN_EVENT_ID,
												getPreferredAgentName(ASSIGNED_BY_AGENT_ID) AssignedBY,
												to_char(ASSIGNED_DATE,'YYYY-MM-DD') ASSIGNED_DATE,
												SPECIMEN_EVENT_REMARK,
												habitat,
												SPECIMEN_EVENT_TYPE,
												COLLECTING_METHOD,
												COLLECTING_SOURCE,
												VERIFICATIONSTATUS
											from
												specimen_event
											where
												collecting_event_id=#val(collecting_event_id)#
										</cfquery>
										<cfloop query="sevent">
											<div class="sevent">
												<span class="dTtl">Specimen-Event Type:</span> <span class="dVal">#specimen_event_type#</span>
												<a href="SpecimenResults.cfm?SPECIMEN_EVENT_ID=#SPECIMEN_EVENT_ID#">
													Specimen Record
												</a>
												<br><span class="dTtl">Assigned By (on date):</span> <span class="dVal">#AssignedBY# (#ASSIGNED_DATE#)</span>
												<br><span class="dTtl">Collecting Method:</span> <span class="dVal">#COLLECTING_METHOD#</span>
												<br><span class="dTtl">Collecting Source:</span> <span class="dVal">#COLLECTING_SOURCE#</span>
												<br><span class="dTtl">Verification Status:</span> <span class="dVal">#VERIFICATIONSTATUS#</span>
												<br><span class="dTtl">Habitat:</span> <span class="dVal">#HABITAT#</span>
												<br><span class="dTtl">Specimen-Event Remark:</span> <span class="dVal">#SPECIMEN_EVENT_REMARK#</span>
											</div>
										</cfloop>
									</cfif><!---- end specimenevent---->
								</div><!---- event ---->
							</cfloop>
						</cfif><!--- end event ---->
					</div>
				</cfloop>
			</cfif><!--- end locality ---->
		</div><!---- /higher_geog ---->
	</cfloop>
</cfoutput>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">