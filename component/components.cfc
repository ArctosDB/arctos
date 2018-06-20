<cfcomponent>
	<cffunction name="validateSpecimenEvent" access="public">
		<cfargument name="q" required="yes" type="query">
		<cfset problems="">
		<cfset checkEvent=true>
		<cfset checkLocality=true>
		<cfquery name="x" datasource="uam_god">
			select count(*) c from CTSPECIMEN_EVENT_TYPE where SPECIMEN_EVENT_TYPE='#q.SPECIMEN_EVENT_TYPE#'
		</cfquery>
		<cfif x.c is not 1>
			<cfset problems=listappend(problems,'invalid SPECIMEN_EVENT_TYPE')>
		</cfif>
		<cfquery name="x" datasource="uam_god">
			select count(*) c from CTCOLLECTING_SOURCE where COLLECTING_SOURCE='#q.COLLECTING_SOURCE#'
		</cfquery>
		<cfif x.c is not 1>
			<cfset problems=listappend(problems,'invalid COLLECTING_SOURCE')>
		</cfif>
		<cfif len(q.LOCALITY_ID) is 0 and len(q.COLLECTING_EVENT_ID) is 0 and len(q.GEOG_AUTH_REC_ID) is 0>
			<cfquery name="x" datasource="uam_god">
				select count(*) c from GEOG_AUTH_REC where HIGHER_GEOG='#q.HIGHER_GEOG#'
			</cfquery>
			<cfif x.c is not 1>
				<cfset problems=listappend(problems,'invalid HIGHER_GEOG')>
			</cfif>
		</cfif>
		<cfif  q.orig_lat_long_units is not null AND
		   (
		       q.datum is null or
		       q.GEOREFERENCE_SOURCE is null or
		       q.GEOREFERENCE_PROTOCOL is null
		   )>
			<cfset problems=listappend(problems,'invalid datum,GEOREFERENCE_SOURCE,GEOREFERENCE_PROTOCOL')>
		</cfif>
		<cfquery name="x" datasource="uam_god">
			select collection_object_id from flat where guid='#q.guid#'
		</cfquery>
		<cfif len(x.collection_object_id) is 0>
			<cfset problems=listappend(problems,'guid not found')>
		<cfelse>
			<cfset r.collection_object_id=getCatItem.collection_object_id>
		</cfif>


		<cfquery name="x" datasource="uam_god">
			select agent_id from agent_name where agent_name='#q.ASSIGNED_BY_AGENT#' group by agent_id
		</cfquery>
		<cfif x.recordcount is 1 and len(x.agent_id) gt 0>
			<cfset r.agent_id=x.agent_id>
		<cfelse>
			<cfset problems=listappend(problems,'ASSIGNED_BY_AGENT not found')>
		</cfif>
		<cfquery name="x" datasource="uam_god">
			select is_iso8601('#q.ASSIGNED_DATE#') isdate from dual
		</cfquery>
		<cfif x.isdate is not "valid">
			<cfset problems=listappend(problems,'ASSIGNED_DATE not a valid date')>
		</cfif>
		<cfif len(q.collecting_event_id) gt 0>
			<cfset checkEvent=false>
			<cfset checkLocality=false>
			<cfquery name="x" datasource="uam_god">
				select collecting_event_id from collecting_event where collecting_event_id=#q.collecting_event_id#
			</cfquery>
			<cfif x.recordcount is not 1>
				<cfset problems=listappend(problems,'not a valid collecting_event_id')>
			<cfelse>
				<cfset r.collecting_event_id=x.collecting_event_id>
			</cfif>
		</cfif>
		<cfif len(q.collecting_event_name) gt 0>
			<cfset checkEvent=false>
			<cfset checkLocality=false>
			<cfquery name="x" datasource="uam_god">
				select min(collecting_event_id) collecting_event_id from collecting_event where collecting_event_name='#q.collecting_event_name#'
			</cfquery>
			<cfif x.recordcount is 1 and len(x.collecting_event_id) gt 0>
				<cfset r.collecting_event_id=collecting_event.collecting_event_id>
			<cfelse>x
				<cfset problems=listappend(problems,'not a valid collecting_event_name')>
			</cfif>
		</cfif>
		<cfif len(q.LOCALITY_ID) gt 0>
			<cfset checkLocality=false>
			<cfquery name="x" datasource="uam_god">
				select min(LOCALITY_ID) LOCALITY_ID from LOCALITY where LOCALITY_ID=#q.LOCALITY_ID#
			</cfquery>
			<cfif x.recordcount is 1 and len(x.LOCALITY_ID) gt 0>
				<cfset r.LOCALITY_ID=x.LOCALITY_ID>
			<cfelse>
				<cfset problems=listappend(problems,'not a valid LOCALITY_ID')>
			</cfif>
		</cfif>
		<cfif len(q.LOCALITY_NAME) gt 0>
			<cfset checkLocality=false>
			<cfquery name="x" datasource="uam_god">
				select min(LOCALITY_ID) LOCALITY_ID from LOCALITY where LOCALITY_NAME='#q.LOCALITY_NAME#'
			</cfquery>
			<cfif x.recordcount is 1 and len(x.LOCALITY_ID) gt 0>
				<cfset r.LOCALITY_ID=x.LOCALITY_ID>
			<cfelse>
				<cfset problems=listappend(problems,'not a valid LOCALITY_NAME')>
			</cfif>
		</cfif>


		<cfif checkEvent is true>
			<cfif len(q.VERBATIM_DATE) is 0>
				<cfset problems=listappend(problems,'VERBATIM_DATE is required',',')>
			</cfif>
			<cfif len(q.VERBATIM_LOCALITY) is 0>
				<cfset problems=listappend(problems,'VERBATIM_LOCALITY is required',',')>
			</cfif>
			<cfquery name="x" datasource="uam_god">
				select is_iso8601('#q.BEGAN_DATE#') isdate from dual
			</cfquery>
			<cfif x.isdate is not "valid">
				<cfset problems=listappend(problems,'BEGAN_DATE is not a valid date')>
			</cfif>
			<cfquery name="x" datasource="uam_god">
				select is_iso8601('#q.ENDED_DATE#') isdate from dual
			</cfquery>
			<cfif x.isdate is not "valid">
				<cfset problems=listappend(problems,'ENDED_DATE is not a valid date')>
			</cfif>
			<cfif len(q.ORIG_LAT_LONG_UNITS) gt 0>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from CTLAT_LONG_UNITS where ORIG_LAT_LONG_UNITS='#q.ORIG_LAT_LONG_UNITS#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'ORIG_LAT_LONG_UNITS is not valid')>
				</cfif>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from ctDATUM where DATUM='#q.DATUM#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'DATUM is not valid')>
				</cfif>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from ctGEOREFERENCE_PROTOCOL where GEOREFERENCE_PROTOCOL='#q.GEOREFERENCE_PROTOCOL#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'GEOREFERENCE_PROTOCOL is not valid')>
				</cfif>
				<cfif q.ORIG_LAT_LONG_UNITS is "decimal degrees">
					<cfif q.DEC_LAT gt 90 or q.DEC_LAT lt -90 or q.DEC_LONG gt 180 or q.DEC_LONG lt -180>
						<cfset problems=listappend(problems,'coordinates not valid')>
					</cfif>
				<cfelseif q.orig_lat_long_units is 'deg. min. sec.'>
					<cfif q.LAT_DEG gt 90 or q.LAT_DEG lt 0 or
						q.LAT_MIN lt 0 or q.LAT_MIN gt 60 or
						q.LAT_SEC  lt 0 or q.LAT_SEC gt 60 or
						q.LONG_DEG gt 180 or q.LONG_DEG lt 0 or
						q.LONG_MIN lt 0 or q.LONG_MIN gt 60 or
						q.LONG_SEC  lt 0 or q.LONG_SEC gt 60 or
						(q.LAT_DIR is not "N" and q.LAT_DIR is not "S") or
						(q.LONG_DIR is not "W" and q.LONG_DIR is not "E")>
						<cfset problems=listappend(problems,'coordinates not valid')>
					</cfif>
				<cfelseif q.orig_lat_long_units is 'degrees dec. minutes'>
					<cfif q.LAT_DEG gt 90 or q.LAT_DEG lt 0 or
						q.DEC_LAT_MIN lt 0 or q.DEC_LAT_MIN gt 60 or
						q.LONG_DEG gt 180 or q.LONG_DEG lt 0 or
						q.DEC_LONG_MIN lt 0 or q.DEC_LONG_MIN gt 60 or
						(q.LAT_DIR is not "N" and q.LAT_DIR is not "S") or
						(q.LONG_DIR is not "W" and q.LONG_DIR is not "E")>
						<cfset problems=listappend(problems,'coordinates not valid')>
					</cfif>
				<cfelseif q.orig_lat_long_units is 'UTM'>
					<cfif not (isnumeric(q.UTM_EW) and isnumeric(q.UTM_NS))>
						<cfset problems=listappend(problems,'coordinates not valid')>
					</cfif>
				</cfif>
			</cfif><!---- END len(ORIG_LAT_LONG_UNITS) gt 0 --->
		</cfif><!--- END  checkEvent is true --->

		<cfif checkLocality is true>
			<cfif len(q.SPEC_LOCALITY) is 0>
				<cfset problems=listappend(problems,'SPEC_LOCALITY is required')>
			</cfif>
			<cfif len(q.ORIG_ELEV_UNITS) gt 0>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from ctORIG_ELEV_UNITS where ORIG_ELEV_UNITS='#q.ORIG_ELEV_UNITS#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'ORIG_ELEV_UNITS is not valid')>
				</cfif>
				<cfif len(q.MINIMUM_ELEVATION) is 0 or len(q.MAXIMUM_ELEVATION) is 0 or (not isnumeric(q.MINIMUM_ELEVATION))
					 or (not isnumeric(q.MAXIMUM_ELEVATION)) or (q.MINIMUM_ELEVATION gt q.MAXIMUM_ELEVATION)>
					<cfset problems=listappend(problems,'elevation is wonky')>
				</cfif>
			</cfif>
			<cfif len(q.DEPTH_UNITS) gt 0>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from ctDEPTH_UNITS where DEPTH_UNITS='#q.DEPTH_UNITS#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'DEPTH_UNITS is not valid')>
				</cfif>
				<cfif len(q.MIN_DEPTH) is 0 or len(q.MAX_DEPTH) is 0 or (not isnumeric(q.MIN_DEPTH))
					 or (not isnumeric(q.MAX_DEPTH)) or (q.MIN_DEPTH gt q.MAX_DEPTH)>
					<cfset problems=listappend(problems,'depth is wonky')>
				</cfif>
			</cfif>
			<cfif len(q.MAX_ERROR_UNITS) gt 0>
				<cfquery name="x" datasource="uam_god">
					select count(*) c from CTLAT_LONG_ERROR_UNITS  where LAT_LONG_ERROR_UNITS='#q.MAX_ERROR_UNITS#'
				</cfquery>
				<cfif x.c is not 1>
					<cfset problems=listappend(problems,'MAX_ERROR_UNITS is not valid')>
				</cfif>
				<cfif len(q.MAX_ERROR_DISTANCE) is 0>
					<cfset problems=listappend(problems,'MAX_ERROR_DISTANCE is required when MAX_ERROR_UNITS is given')>
				</cfif>
			</cfif>
			<cfif len(q.GEOG_AUTH_REC_ID) gt 0>
				<cfquery name="x" datasource="uam_god">
					select nvl(GEOG_AUTH_REC_ID,0) GEOG_AUTH_REC_ID from GEOG_AUTH_REC where GEOG_AUTH_REC_ID=#q.GEOG_AUTH_REC_ID#
				</cfquery>
				<cfset r.GEOG_AUTH_REC_ID=x.GEOG_AUTH_REC_ID>
				<cfif x.GEOG_AUTH_REC_ID is 0>
					<cfset problems=listappend(problems,'GEOG_AUTH_REC_ID is not valid')>
				</cfif>
			<cfelseif len(q.HIGHER_GEOG) gt 0>
				<cfquery name="x" datasource="uam_god">
					select nvl(GEOG_AUTH_REC_ID,0) GEOG_AUTH_REC_ID  from GEOG_AUTH_REC where HIGHER_GEOG='#q.HIGHER_GEOG#'
				</cfquery>
				<cfset r.GEOG_AUTH_REC_ID=x.GEOG_AUTH_REC_ID>
				<cfif x.GEOG_AUTH_REC_ID is 0>
					<cfset problems=listappend(problems,'HIGHER_GEOG is not valid')>
				</cfif>
			<cfelse>
				<cfset problems=listappend(problems,'Either HIGHER_GEOG or GEOG_AUTH_REC_ID is required.')>
			</cfif>
		</cfif><!---- END checkLocality is true --->
		<cfset r.problems=problems>
		<cfreturn r>



















	</cffunction>

</cfcomponent>
