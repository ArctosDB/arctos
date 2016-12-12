<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Locality Statistics">
<cfoutput>
	<cfif isdefined("session.roles") and session.roles contains "manage_locality">
		<p>
			See <a href="/Reports/georef.cfm">/Reports/FunkyData/GeoreferenceStatistics</a>
			for a summary of georeferencing activity and efficacy by collection.
		</p>
	</cfif>
	<table border class="sortable" id="t">
		<tr>
			<th>Thing</th>
			<th>Count</th>
		</tr>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from locality
		</cfquery>
		<tr>
			<td>Total Number Localities</td>
			<td>#d.c#</td>
		</tr>

		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from locality where locality_id in
				(
					select locality_id from collecting_event
					union
					select related_primary_key from media_relations where media_relationship like '% locality'
				)
		</cfquery>
		<tr>
			<td>Number Used Localities</td>
			<td>#d.c#</td>
		</tr>

		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from (
			  select distinct
			    DEC_LAT,
			    DEC_LONG,
			    to_meters(MINIMUM_ELEVATION,ORIG_ELEV_UNITS),
			    to_meters(MAXIMUM_ELEVATION,ORIG_ELEV_UNITS),
			    to_meters(MIN_DEPTH,DEPTH_UNITS),
			    to_meters(MAX_DEPTH,DEPTH_UNITS),
			    to_meters(MAX_ERROR_DISTANCE,MAX_ERROR_UNITS)
			  from locality
			)
 		</cfquery>

		<tr>
			<td>Number Spatially Distinct (coordinates/error/elevation/depth) Localities</td>
			<td>#d.c#</td>
		</tr>


		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from (
			  select distinct
			    GEOG_AUTH_REC_ID,
			    SPEC_LOCALITY,
			    DEC_LAT,
			    DEC_LONG,
			    to_meters(MINIMUM_ELEVATION,ORIG_ELEV_UNITS),
			    to_meters(MAXIMUM_ELEVATION,ORIG_ELEV_UNITS),
			    to_meters(MIN_DEPTH,DEPTH_UNITS),
			    to_meters(MAX_DEPTH,DEPTH_UNITS),
			    to_meters(MAX_ERROR_DISTANCE,MAX_ERROR_UNITS)
			  from locality
			 )
 		</cfquery>
		<tr>
			<td>Number (Spatial+SpecificLocality) Distinct Localities</td>
			<td>#d.c#</td>
		</tr>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from locality where dec_lat is not null
		</cfquery>
		<tr>
			<td>Number Localities with Coordinates</td>
			<td>#d.c#</td>
		</tr>

		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from locality where dec_lat is not null and MAX_ERROR_DISTANCE is not null
		</cfquery>
		<tr>
			<td>Number Localities with Coordinates+Error</td>
			<td>#d.c#</td>
		</tr>

		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from locality where dec_lat is not null and MAX_ERROR_DISTANCE is not null and MINIMUM_ELEVATION is not null
		</cfquery>
		<tr>
			<td>Number Localities with Coordinates+Error+Elevation</td>
			<td>#d.c#</td>
		</tr>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from locality where  S$DEC_LAT is not null
		</cfquery>
		<tr>
			<td>Number Localities with automated georeferences</td>
			<td>#d.c#</td>
		</tr>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(*) c from locality where S$GEOGRAPHY is not null
		</cfquery>
		<tr>
			<td>Number Localities with automated reverse georeferences</td>
			<td>#d.c#</td>
		</tr>
	</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">