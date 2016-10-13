<cfinclude template="/includes/_header.cfm">
<cfset title="Locality Archive">
<style>
	.nochange{border:1px solid green;}
	.haschange{border:1px solid red;}

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
			MIN_DEPTH,
			MAX_DEPTH,
			DEPTH_UNITS,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
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
			MIN_DEPTH,
			MAX_DEPTH,
			DEPTH_UNITS,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
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

			<cfset lastDepth="#orig.MIN_DEPTH#-#orig.MAX_DEPTH# #orig.DEPTH_UNITS#">
			<td>#lastDepth#</td>

			<cfset lastElev="#orig.MINIMUM_ELEVATION#-#orig.MAXIMUM_ELEVATION# #orig.ORIG_ELEV_UNITS#">
			<td>#lastElev#</td>

			<cfset lastDatum=orig.DATUM>
			<td>#orig.DATUM#</td>


			<cfset lastCoords="#orig.DEC_LAT#,#orig.DEC_LONG#">
			<td>#lastCoords#</td>

			<cfset lastCoordErr="#orig.MAX_ERROR_DISTANCE# #orig.MAX_ERROR_UNITS#">
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
			select * from d where locality_id=#lid# order by changedate
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
				<td>
					<span class="#thisStyle#">
						#thisGeoID#
					</span>
				</td>

				<cfset thisSpecLoc=SPEC_LOCALITY>
				<cfif thisSpecLoc is lastSpecLoc>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastSpecLoc=thisSpecLoc>
				<td>
					<span class="#thisStyle#">
						#thisSpecLoc#
					</span>
				</td>


				<cfset thisLocName=LOCALITY_NAME>
				<cfif thisLocName is lastLocName>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastLocName=thisLocName>
				<td>
					<span class="#thisStyle#">
						#thisLocName#
					</span>
				</td>

				<cfset thisDepth="#MIN_DEPTH#-#MAX_DEPTH# #DEPTH_UNITS#">
				<cfif thisDepth is lastDepth>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastDepth=thisDepth>
				<td>
					<span class="#thisStyle#">
						#thisDepth#
					</span>
				</td>


				<cfset thisElev="#MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
				<cfif thisElev is lastElev>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastElev=thisElev>
				<td>
					<span class="#thisStyle#">
						#thisElev#
					</span>
				</td>


				<cfset thisDatum=DATUM>
				<cfif thisDatum is lastDatum>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastDatum=thisDatum>
				<td>
					<span class="#thisStyle#">
						#thisDatum#
					</span>
				</td>

				<cfset thisCoords="#DEC_LAT#,#DEC_LONG#">
				<cfif thisCoords is lastCoords>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastCoords=thisCoords>
				<td>
					<span class="#thisStyle#">
						#thisCoords#
					</span>
				</td>


				<cfset thisCoordErr="#MAX_ERROR_DISTANCE# #MAX_ERROR_UNITS#">
				<cfif thisCoordErr is lastCoordErr>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastCoordErr=thisCoordErr>
				<td>
					<span class="#thisStyle#">
						#thisCoordErr#
					</span>
				</td>



				<cfset thisProt=GEOREFERENCE_PROTOCOL>
				<cfif thisProt is lastProt>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastProt=thisProt>
				<td>
					<span class="#thisStyle#">
						#thisProt#
					</span>
				</td>



				<cfset thisSrc=GEOREFERENCE_SOURCE>
				<cfif thisSrc is lastSrc>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastSrc=thisSrc>
				<td>
					<span class="#thisStyle#">
						#thisSrc#
					</span>
				</td>



				<cfset thisWKT=polyhash>
				<cfif thisWKT is lastWKT>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastWKT=thisWKT>
				<td>
					<span class="#thisStyle#">
						#thisWKT#
					</span>
				</td>



				<cfset thisrem=LOCALITY_REMARKS>
				<cfif thisrem is lastRem>
					<cfset thisStyle="nochange">
				<cfelse>
					<cfset thisStyle="haschange">
				</cfif>
				<cfset lastRem=thisrem>
				<td>
					<span class="#thisStyle#">
						#thisrem#
					</span>
				</td>




			</tr>




		</cfloop>
		changes:
		<cfdump var=#thisChanges#>
	</cfloop>


	</table>


</cfoutput>
<cfinclude template="/includes/_footer.cfm">