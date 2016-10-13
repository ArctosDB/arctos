<cfinclude template="/includes/_header.cfm">
<cfset title="Locality Archive">
<style>
	.nochange{border:3px solid green;}
	.haschange{
		border:3px solid red;}


</style>
<cfoutput>
	<cfif not isdefined("locality_id")>
		bad call<cfabort>
	</cfif>
	<cfquery name="d" datasource="uam_god">
		select
			locality_archive_id,
		 	locality_id,
		 	geog_auth_rec_id,
		 	spec_locality,
		 	decode(DEC_LAT,
				null,'[NULL]',
				DEC_LAT || ',' || DEC_LONG) coordinates,
		 	decode(ORIG_ELEV_UNITS,
				null,'[NULL]',
				MINIMUM_ELEVATION || '-' || MAXIMUM_ELEVATION || ' ' || ORIG_ELEV_UNITS) elevation,
			decode(DEPTH_UNITS,
				null,'[NULL]',
				MIN_DEPTH || '-' || MAX_DEPTH || ' ' || DEPTH_UNITS) depth,
			MIN_DEPTH,
			MAX_DEPTH,
			DEPTH_UNITS,
			decode(
				MAX_ERROR_DISTANCE,
				null,'[NULL]',
				MAX_ERROR_DISTANCE || ' ' || MAX_ERROR_UNITS) coordinateError,
			DATUM,
			LOCALITY_REMARKS,
			GEOREFERENCE_SOURCE,
			GEOREFERENCE_PROTOCOL,
			LOCALITY_NAME,
		 	md5hash(WKT_POLYGON) polyhash,
		 	whodunit,
		 	changedate
		 from locality_archive where locality_id in (  <cfqueryparam value = "#locality_id#" CFSQLType = "CF_SQL_INTEGER"
        list = "yes"
        separator = ","> )
	</cfquery>
	<cfif d.recordcount is 0>
		No archived information found.<cfabort>
	</cfif>
	<table border>
		<tr>
			<th>ChangeDate</th>
			<th>UserID</th>
			<th>LOCALITY_ID</th>
			<th>GEOG_AUTH_REC_ID</th>
			<th>SPEC_LOCALITY</th>
			<th>LOCALITY_NAME</th>
			<th>Depth</th>
			<th>Elevation</th>
			<th>DATUM</th>
			<th>Coordinates</th>
			<th>CoordError</th>
			<th>GEOREFERENCE_PROTOCOL</th>
			<th>GEOREFERENCE_SOURCE</th>
			<th>WKT(hash)</th>
			<th>LOCALITY_REMARKS</th>
		</tr>
	<cfloop list="#locality_id#" index="lid">
		<cfquery name="orig" datasource="uam_god">
			select locality_id,
		 	geog_auth_rec_id,
		 	spec_locality,
		 	decode(DEC_LAT,
				null,'[NULL]',
				DEC_LAT || ',' || DEC_LONG) coordinates,
		 	decode(ORIG_ELEV_UNITS,
				null,'[NULL]',
				MINIMUM_ELEVATION || '-' || MAXIMUM_ELEVATION || ' ' || ORIG_ELEV_UNITS) elevation,
			decode(DEPTH_UNITS,
				null,'[NULL]',
				MIN_DEPTH || '-' || MAX_DEPTH || ' ' || DEPTH_UNITS) depth,
			decode(
				MAX_ERROR_DISTANCE,
				null,'[NULL]',
				MAX_ERROR_DISTANCE || ' ' || MAX_ERROR_UNITS) coordinateError,
			DATUM,
			LOCALITY_REMARKS,
			GEOREFERENCE_SOURCE,
			GEOREFERENCE_PROTOCOL,
			LOCALITY_NAME,
		 	md5hash(WKT_POLYGON) polyhash from locality where locality_id=#lid#
		</cfquery>
		<tr>
			<td class="original">currentData</td>
			<td class="original">-n/a-</td>
			<td class="original">#orig.LOCALITY_ID#</td>
			<cfset lastGeoID=orig.GEOG_AUTH_REC_ID>
			<td class="original">#orig.GEOG_AUTH_REC_ID#</td>

			<cfset lastSpecLoc=orig.SPEC_LOCALITY>
			<td class="original">#orig.SPEC_LOCALITY#</td>


			<cfset lastLocName=orig.LOCALITY_NAME>
			<td class="original">#orig.LOCALITY_NAME#</td>

			<cfset lastDepth=orig.depth>
			<td class="original">#lastDepth#</td>

			<cfset lastElev=orig.elevation>
			<td class="original">#lastElev#</td>

			<cfset lastDatum=orig.DATUM>
			<td class="original">#orig.DATUM#</td>


			<cfset lastCoords=orig.coordinates>
			<td class="original">#lastCoords#</td>

			<cfset lastCoordErr=orig.coordinateError>
			<td class="original">#lastCoordErr#</td>


			<cfset lastProt=orig.GEOREFERENCE_PROTOCOL>
			<td class="original">#orig.GEOREFERENCE_PROTOCOL#</td>

			<cfset lastSrc=orig.GEOREFERENCE_SOURCE>
			<td class="original">#orig.GEOREFERENCE_SOURCE#</td>


			<cfset lastWKT=orig.polyhash>
			<td class="original">#lastWKT#</td>

			<cfset lastRem=orig.LOCALITY_REMARKS>
			<td class="original">#orig.LOCALITY_REMARKS#</td>


		</tr>

		<cfquery name="thisChanges" dbtype="query">
			select * from d where locality_id=#lid# order by changedate desc
		</cfquery>
		<cfloop query="thisChanges">
			<tr>

				<td>#changedate#</td>
				<td>#whodunit#</td>
				<td>#LOCALITY_ID#</td>
				<cfif GEOG_AUTH_REC_ID is lastGeoID>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastGeoID=GEOG_AUTH_REC_ID>
				<td class="#thisStyle#">
					#GEOG_AUTH_REC_ID#
				</td>

				<cfif SPEC_LOCALITY is lastSpecLoc>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastSpecLoc=SPEC_LOCALITY>
				<td class="#thisStyle#">
					#SPEC_LOCALITY#
				</td>


				<cfif LOCALITY_NAME is lastLocName>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastLocName=LOCALITY_NAME>
				<td class="#thisStyle#">
					#LOCALITY_NAME#
				</td>

				<cfif depth is lastDepth>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastDepth=depth>
				<td class="#thisStyle#">
					#depth#
				</td>


				<cfif elevation is lastElev>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastElev=elevation>
				<td class="#thisStyle#">
					#elevation#
				</td>


				<cfif DATUM is lastDatum>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastDatum=DATUM>
				<td class="#thisStyle#">
					#DATUM#
				</td>

				<cfif coordinates is lastCoords>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastCoords=coordinates>
				<td class="#thisStyle#">
					#coordinates#
				</td>


				<cfif coordinateError is lastCoordErr>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastCoordErr=coordinateError>
				<td class="#thisStyle#">
					#coordinateError#
				</td>



				<cfif GEOREFERENCE_PROTOCOL is lastProt>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastProt=GEOREFERENCE_PROTOCOL>
				<td class="#thisStyle#">
					#GEOREFERENCE_PROTOCOL#
				</td>



				<cfif GEOREFERENCE_SOURCE is lastSrc>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastSrc=GEOREFERENCE_SOURCE>
				<td class="#thisStyle#">
					#GEOREFERENCE_SOURCE#
				</td>



				<cfif polyhash is lastWKT>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastWKT=polyhash>
				<td class="#thisStyle#">
					#polyhash#
				</td>



				<cfif LOCALITY_REMARKS is lastRem>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastRem=LOCALITY_REMARKS>
				<td class="#thisStyle#">
					#LOCALITY_REMARKS#
				</td>


			</tr>




		</cfloop>
	</cfloop>


	</table>


</cfoutput>
<cfinclude template="/includes/_footer.cfm">