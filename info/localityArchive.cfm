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
		 	DEC_LAT,
		 	DEC_LONG,
			MINIMUM_ELEVATION,
			MAXIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
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
		 	DEC_LAT,
		 	DEC_LONG,
			MINIMUM_ELEVATION,
			MAXIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
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
			<td>currentData</td>
			<td>-n/a-</td>
			<td>#orig.LOCALITY_ID#</td>
			<cfset lastGeoID=orig.GEOG_AUTH_REC_ID>
			<td>#orig.GEOG_AUTH_REC_ID#</td>

			<cfset lastSpecLoc=orig.SPEC_LOCALITY>
			<td>#orig.SPEC_LOCALITY#</td>


			<cfset lastLocName=orig.LOCALITY_NAME>
			<td>#orig.LOCALITY_NAME#</td>

			<cfset lastDepth=orig.depth>
			<td>#lastDepth#</td>

			<cfset lastElev="#orig.MINIMUM_ELEVATION#-#orig.MAXIMUM_ELEVATION# #orig.ORIG_ELEV_UNITS#">
			<td>#lastElev#</td>

			<cfset lastDatum=orig.DATUM>
			<td>#orig.DATUM#</td>


			<cfset lastCoords="#orig.DEC_LAT#,#orig.DEC_LONG#">
			<td>#lastCoords#</td>

			<cfset lastCoordErr=orig.coordinateError>
			<td>#lastCoordErr#</td>


			<cfset lastProt=orig.GEOREFERENCE_PROTOCOL>
			<td>#orig.GEOREFERENCE_PROTOCOL#</td>

			<cfset lastSrc=orig.GEOREFERENCE_SOURCE>
			<td>#orig.GEOREFERENCE_SOURCE#</td>


			<cfset lastWKT=orig.polyhash>
			<td>#lastWKT#</td>

			<cfset lastRem=orig.LOCALITY_REMARKS>
			<td>#orig.LOCALITY_REMARKS#</td>


		</tr>

		<cfquery name="thisChanges" dbtype="query">
			select * from d where locality_id=#lid# order by changedate desc
		</cfquery>
		<cfloop query="thisChanges">
			<tr>

				<td>#changedate#</td>
				<td>#whodunit#</td>
				<td>#LOCALITY_ID#</td>
				<cfset thisgeoID=GEOG_AUTH_REC_ID>
				<cfif thisGeoID is lastGeoID>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastGeoID=thisGeoID>
				<td class="#thisStyle#">
					#thisGeoID#
				</td>

				<cfset thisSpecLoc=SPEC_LOCALITY>
				<cfif thisSpecLoc is lastSpecLoc>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastSpecLoc=thisSpecLoc>
				<td class="#thisStyle#">
					#thisSpecLoc#
				</td>


				<cfset thisLocName=LOCALITY_NAME>
				<cfif thisLocName is lastLocName>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastLocName=thisLocName>
				<td class="#thisStyle#">
					#thisLocName#
				</td>

				<cfset thisDepth=depth>
				<cfif thisDepth is lastDepth>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastDepth=thisDepth>
				<td class="#thisStyle#">
					#thisDepth#
				</td>


				<cfset thisElev="#MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
				<cfif thisElev is lastElev>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastElev=thisElev>
				<td class="#thisStyle#">
					#thisElev#
				</td>


				<cfset thisDatum=DATUM>
				<cfif thisDatum is lastDatum>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastDatum=thisDatum>
				<td class="#thisStyle#">
					#thisDatum#
				</td>

				<cfset thisCoords="#DEC_LAT#,#DEC_LONG#">
				<cfif thisCoords is lastCoords>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastCoords=thisCoords>
				<td class="#thisStyle#">
					#thisCoords#
				</td>


				<cfset thisCoordErr=coordinateError>
				<cfif thisCoordErr is lastCoordErr>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastCoordErr=thisCoordErr>
				<td class="#thisStyle#">
					#thisCoordErr#
				</td>



				<cfset thisProt=GEOREFERENCE_PROTOCOL>
				<cfif thisProt is lastProt>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastProt=thisProt>
				<td class="#thisStyle#">
					#thisProt#
				</td>



				<cfset thisSrc=GEOREFERENCE_SOURCE>
				<cfif thisSrc is lastSrc>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastSrc=thisSrc>
				<td class="#thisStyle#">
					#thisSrc#
				</td>



				<cfset thisWKT=polyhash>
				<cfif thisWKT is lastWKT>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastWKT=thisWKT>
				<td class="#thisStyle#">
					#thisWKT#
				</td>



				<cfset thisrem=LOCALITY_REMARKS>
				<cfif thisrem is lastRem>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastRem=thisrem>
				<td class="#thisStyle#">
					#thisrem#
				</td>




			</tr>




		</cfloop>
	</cfloop>


	</table>


</cfoutput>
<cfinclude template="/includes/_footer.cfm">