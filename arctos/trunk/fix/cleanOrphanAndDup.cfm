<!----
<!--- kill unused collecting events --->
<cfquery name="orphanCollEvent" datasource="#Application.uam_dbo#">
	delete from collecting_event where collecting_event_id not in (
		select collecting_event_id from cataloged_item)
</cfquery>

<!--- kill  coordinates of unused localities--->
<cfquery name="orphanCoord" datasource="#Application.uam_dbo#">
	delete from lat_long where locality_id NOT in (select locality_id FROM 
		collecting_event)
</cfquery>
<!--- kill unused localities --->
<cfquery name="orphanLoc" datasource="#Application.uam_dbo#">
	delete from locality where locality_id not in (
		select locality_id from collecting_event)
</cfquery>

<!--- kill unused geog --->
<cfquery name="orphanGeog" datasource="#Application.uam_dbo#">
	delete from geog_auth_rec where geog_auth_rec_id not in (
		select geog_auth_rec_id from locality)
</cfquery>

<!--- kill unused coordinates --->
<cfquery name="orphanCoord" datasource="#Application.uam_dbo#">
	delete from lat_long where lat_long_id not in (
		select lat_long_id from locality)
</cfquery>
---->
<cfoutput>
<!---
<!--- now combine geogs --->
<!--- first, get an idea of the duplicates --->
<cfquery name="dupGeog" datasource="#Application.uam_dbo#">
	select 
	HIGHER_GEOG,count(higher_geog) num
	from 
	geog_auth_rec
	having count(higher_geog) > 1
	group by HIGHER_GEOG
</cfquery>
<br>got counts<cfflush>
<cfloop query="dupGeog">
	<!--- get all records for this potentially duplicate higher geog --->
	<cfquery name="pDups" datasource="#Application.uam_dbo#">
		select * from geog_auth_rec where higher_geog='#HIGHER_GEOG#'
		order by geog_auth_rec_id
	</cfquery>
	<br>got one<cfflush>
	<!--- loop through duplicates and see if they're really the same --->
	<!--- just base this on the first record --->
	<cfquery name="theOne" dbtype="query" maxrows="1">
		select * from pDups
	</cfquery>
	<cfquery name="theRest" dbtype="query">
		select * from pDups where geog_auth_rec_id <> #theOne.geog_auth_rec_id#
	</cfquery>
	<hr>
	<cfloop query="theRest">
		<cfset theSame = "yes">
			<cfif #theOne.CONTINENT_OCEAN# is #CONTINENT_OCEAN#>
				<br>#theOne.CONTINENT_OCEAN# is #CONTINENT_OCEAN#
			<cfelse>
				<br>#theOne.CONTINENT_OCEAN# IS NOT #CONTINENT_OCEAN#
				<cfset theSame = "no">
			</cfif>
			
			<cfif #theOne.COUNTRY# is #COUNTRY#>
				<br>#theOne.COUNTRY# is #COUNTRY#
			<cfelse>
				<br>#theOne.COUNTRY# IS NOT #COUNTRY#
				<cfset theSame = "no">
			</cfif>
			
			<cfif #theOne.STATE_PROV# is #STATE_PROV#>
				<br>#theOne.STATE_PROV# is #STATE_PROV#
			<cfelse>
				<br>#theOne.STATE_PROV# IS NOT #STATE_PROV#
				<cfset theSame = "no">
			</cfif>
			
			<cfif #theOne.COUNTY# is #COUNTY#>
				<br>#theOne.COUNTY# is #COUNTY#
			<cfelse>
				<br>#theOne.COUNTY# IS NOT #COUNTY#
				<cfset theSame = "no">
			</cfif>
			
			<cfif #theOne.QUAD# is #QUAD#>
				<br>#theOne.QUAD# is #QUAD#
			<cfelse>
				<br>#theOne.QUAD# IS NOT #QUAD#
				<cfset theSame = "no">
			</cfif>
			
			<cfif #theOne.FEATURE# is #FEATURE#>
				<br>#theOne.FEATURE# is #FEATURE#
			<cfelse>
				<br>#theOne.FEATURE# IS NOT #FEATURE#
				<cfset theSame = "no">
			</cfif>
			
			<cfif #theOne.ISLAND# is #ISLAND#>
				<br>#theOne.ISLAND# is #ISLAND#
			<cfelse>
				<br>#theOne.ISLAND# IS NOT #ISLAND#
				<cfset theSame = "no">
			</cfif>
			
			<cfif #theOne.ISLAND_GROUP# is #ISLAND_GROUP#>
				<br>#theOne.ISLAND_GROUP# is #ISLAND_GROUP#
			<cfelse>
				<br>#theOne.ISLAND_GROUP# IS NOT #ISLAND_GROUP#
				<cfset theSame = "no">
			</cfif>
			
			<cfif #theOne.SEA# is #SEA#>
				<br>#theOne.SEA# is #SEA#
			<cfelse>
				<br>#theOne.SEA# IS NOT #SEA#
				<cfset theSame = "no">
			</cfif>
			
			<cfif #theOne.VALID_CATALOG_TERM_FG# is #VALID_CATALOG_TERM_FG#>
				<br>#theOne.VALID_CATALOG_TERM_FG# is #VALID_CATALOG_TERM_FG#
			<cfelse>
				<br>#theOne.VALID_CATALOG_TERM_FG# IS NOT #VALID_CATALOG_TERM_FG#
				<cfset theSame = "no">
			</cfif>
			
			<cfif #theOne.SOURCE_AUTHORITY# is #SOURCE_AUTHORITY#>
				<br>#theOne.SOURCE_AUTHORITY# is #SOURCE_AUTHORITY#
			<cfelse>
				<br>#theOne.SOURCE_AUTHORITY# IS NOT #SOURCE_AUTHORITY#
				<cfset theSame = "no">
			</cfif>
			<!--- already know higher_geog is the same --->
			<cfif #theSame# is "yes">
				<cftransaction>
				<cfquery name="fixIt" datasource="#Application.uam_dbo#">
					update locality set geog_auth_rec_id=#theOne.geog_auth_rec_id#
					where geog_auth_rec_id=#geog_auth_rec_id#
				</cfquery>
				<cfquery name="cleanup" datasource="#Application.uam_dbo#">
					delete from geog_auth_rec
					where geog_auth_rec_id=#geog_auth_rec_id#
				</cfquery>
				</cftransaction>
				<br>----------#theOne.geog_auth_rec_id# is the same as #geog_auth_rec_id#------------
				<br>====#theOne.higher_geog# = #higher_geog#=======
			<cfelseif #theSame# is "no">
				<br>----------#theOne.geog_auth_rec_id# IS NOT THE SAME AS #geog_auth_rec_id#------------
			<cfelse>
				<br>----------something goofy happened------------
				<br>====#theOne.higher_geog# -<>- #higher_geog#=======
			</cfif>
			<hr>
			<cfflush>
			
	</cfloop>
</cfloop>
--->

<!--------------- now get duplicate localities 
	start with non-georefd
	------------------->
	<!---
<cfquery name="pDups" datasource="#Application.uam_dbo#">
	select 
		GEOG_AUTH_REC_ID,
		MAXIMUM_ELEVATION,
		MINIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		TOWNSHIP ,
		TOWNSHIP_DIRECTION,
		RANGE,
		RANGE_DIRECTION,
		SECTION,
		SECTION_PART,
		SPEC_LOCALITY,
		LOCALITY_REMARKS,
		LEGACY_SPEC_LOCALITY_FG,
		DEPTH_UNITS,
		MIN_DEPTH,
		MAX_DEPTH,
		count(*) num
	from 
	locality
	where locality_id not in (
		select locality_id from lat_long)
	having count(*) > 1
	group by
	GEOG_AUTH_REC_ID,
		MAXIMUM_ELEVATION,
		MINIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		TOWNSHIP ,
		TOWNSHIP_DIRECTION,
		RANGE,
		RANGE_DIRECTION,
		SECTION,
		SECTION_PART,
		SPEC_LOCALITY,
		LOCALITY_REMARKS,
		LEGACY_SPEC_LOCALITY_FG,
		DEPTH_UNITS,
		MIN_DEPTH,
		MAX_DEPTH		
</cfquery>
<cfloop query="pDups">
	<cfset sql="select * from locality where
	GEOG_AUTH_REC_ID = #GEOG_AUTH_REC_ID#">
	 
	<cfif len(#MAXIMUM_ELEVATION#) gt 0>
		<cfset sql="#sql# and MAXIMUM_ELEVATION = #MAXIMUM_ELEVATION#">
	<cfelse>
		<cfset sql="#sql# and MAXIMUM_ELEVATION IS NULL">
	</cfif>
	<cfif len(#MINIMUM_ELEVATION#) gt 0>
		<cfset sql="#sql# and MINIMUM_ELEVATION = #MINIMUM_ELEVATION#">
	<cfelse>
		<cfset sql="#sql# and MINIMUM_ELEVATION IS NULL">
	</cfif>
	
	<cfif len(#ORIG_ELEV_UNITS#) gt 0>
		<cfset sql="#sql# and ORIG_ELEV_UNITS = '#ORIG_ELEV_UNITS#'">
	<cfelse>
		<cfset sql="#sql# and ORIG_ELEV_UNITS IS NULL">
	</cfif>
	
	<cfif len(#TOWNSHIP#) gt 0>
		<cfset sql="#sql# and TOWNSHIP = '#TOWNSHIP#'">
	<cfelse>
		<cfset sql="#sql# and TOWNSHIP IS NULL">
	</cfif>
	
	<cfif len(#TOWNSHIP_DIRECTION#) gt 0>
		<cfset sql="#sql# and TOWNSHIP_DIRECTION = '#TOWNSHIP_DIRECTION#'">
	<cfelse>
		<cfset sql="#sql# and TOWNSHIP_DIRECTION IS NULL">
	</cfif>
	
	<cfif len(#RANGE#) gt 0>
		<cfset sql="#sql# and RANGE = '#RANGE#'">
	<cfelse>
		<cfset sql="#sql# and RANGE IS NULL">
	</cfif>
	
	<cfif len(#RANGE_DIRECTION#) gt 0>
		<cfset sql="#sql# and RANGE_DIRECTION = '#RANGE_DIRECTION#'">
	<cfelse>
		<cfset sql="#sql# and RANGE_DIRECTION IS NULL">
	</cfif>
	
	<cfif len(#SECTION#) gt 0>
		<cfset sql="#sql# and SECTION = '#SECTION#'">
	<cfelse>
		<cfset sql="#sql# and SECTION IS NULL">
	</cfif>
	<cfif len(#SECTION_PART#) gt 0>
		<cfset sql="#sql# and SECTION_PART = '#SECTION_PART#'">
	<cfelse>
		<cfset sql="#sql# and SECTION_PART IS NULL">
	</cfif>
	
	<cfif len(#SPEC_LOCALITY#) gt 0>
		<cfset sql="#sql# and SPEC_LOCALITY = '#replace(SPEC_LOCALITY,"'","''","all")#'">
	<cfelse>
		<cfset sql="#sql# and SPEC_LOCALITY IS NULL">
	</cfif>
	
	<cfif len(#LOCALITY_REMARKS#) gt 0>
		<cfset sql="#sql# and LOCALITY_REMARKS = '#LOCALITY_REMARKS#'">
	<cfelse>
		<cfset sql="#sql# and LOCALITY_REMARKS IS NULL">
	</cfif>
	
	<cfif len(#LEGACY_SPEC_LOCALITY_FG#) gt 0>
		<cfset sql="#sql# and LEGACY_SPEC_LOCALITY_FG = #LEGACY_SPEC_LOCALITY_FG#">
	<cfelse>
		<cfset sql="#sql# and LEGACY_SPEC_LOCALITY_FG IS NULL">
	</cfif>
	
	<cfif len(#DEPTH_UNITS#) gt 0>
		<cfset sql="#sql# and DEPTH_UNITS = '#DEPTH_UNITS#'">
	<cfelse>
		<cfset sql="#sql# and DEPTH_UNITS IS NULL">
	</cfif>
	
	<cfif len(#MIN_DEPTH#) gt 0>
		<cfset sql="#sql# and MIN_DEPTH = '#MIN_DEPTH#'">
	<cfelse>
		<cfset sql="#sql# and MIN_DEPTH IS NULL">
	</cfif>
	<cfif len(#MAX_DEPTH#) gt 0>
		<cfset sql="#sql# and MAX_DEPTH = '#MAX_DEPTH#'">
	<cfelse>
		<cfset sql="#sql# and MAX_DEPTH IS NULL">
	</cfif>
	<cfset sql="#sql# and locality_id NOT IN (select locality_id from lat_long)">
		<cfquery name="tDups" datasource="#Application.uam_dbo#">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfquery name="theOne" dbtype="query" maxrows="1">
			select * from tDups
		</cfquery>
		<cfquery name="theRest" dbtype="query">
			select * from tDups where locality_id <> #theOne.locality_id#
		</cfquery>
		<hr>
			<br>theOne.locality_id: #theOne.locality_id#
			<cfloop query="theRest">
				<!--- kill this --->
				<cftransaction>
					<!--- first, update collecting events --->
					<cfquery name="fColl" datasource="#Application.uam_dbo#">
						UPDATE collecting_event set locality_id=#theOne.locality_id# where locality_id=#locality_id#
					</cfquery>
					<!--- there are no coordinates this time around --->
					<!--- clean up locality --->
					<cfquery name="fLoc" datasource="#Application.uam_dbo#">
						delete from locality where locality_id=#locality_id#
					</cfquery>
				</cftransaction>
				<br>the rest: #locality_id#
			</cfloop>
</cfloop>
--->
<!--------------- now get duplicate localities with coordinates
	------------------->
	
	<!--- require locality to 
		have coordinates
		have accepted coordinates
		not have any unaccepted coordinates
		
		this will get most of them and be safer than
		trying to sort out old determinations
		--->
		<!---
<cfquery name="pDups" datasource="#Application.uam_dbo#">
	select 
		GEOG_AUTH_REC_ID,
		MAXIMUM_ELEVATION,
		MINIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		TOWNSHIP ,
		TOWNSHIP_DIRECTION,
		RANGE,
		RANGE_DIRECTION,
		SECTION,
		SECTION_PART,
		SPEC_LOCALITY,
		LOCALITY_REMARKS,
		LEGACY_SPEC_LOCALITY_FG,
		DEPTH_UNITS,
		MIN_DEPTH,
		MAX_DEPTH,
		LAT_DEG ,
		DEC_LAT_MIN,
		LAT_MIN ,
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
		DETERMINED_BY_AGENT_ID,
		DETERMINED_DATE,
		LAT_LONG_REF_SOURCE,
		LAT_LONG_REMARKS,
		MAX_ERROR_DISTANCE,
		MAX_ERROR_UNITS,
		NEAREST_NAMED_PLACE,
		LAT_LONG_FOR_NNP_FG,
		FIELD_VERIFIED_FG,
		ACCEPTED_LAT_LONG_FG,
		EXTENT,
		GPSACCURACY,
		GEOREFMETHOD,
		VERIFICATIONSTATUS,
		count(*) num
	from 
		locality,lat_long
	where 
		locality.locality_id = lat_long.locality_id and
		locality.locality_id not in (select locality_id from lat_long where ACCEPTED_LAT_LONG_FG <> 1)
	having count(*) > 1
	group by
	GEOG_AUTH_REC_ID,
		MAXIMUM_ELEVATION,
		MINIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		TOWNSHIP ,
		TOWNSHIP_DIRECTION,
		RANGE,
		RANGE_DIRECTION,
		SECTION,
		SECTION_PART,
		SPEC_LOCALITY,
		LOCALITY_REMARKS,
		LEGACY_SPEC_LOCALITY_FG,
		DEPTH_UNITS,
		MIN_DEPTH,
		MAX_DEPTH,
		LAT_DEG ,
		DEC_LAT_MIN,
		LAT_MIN ,
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
		DETERMINED_BY_AGENT_ID,
		DETERMINED_DATE,
		LAT_LONG_REF_SOURCE,
		LAT_LONG_REMARKS,
		MAX_ERROR_DISTANCE,
		MAX_ERROR_UNITS,
		NEAREST_NAMED_PLACE,
		LAT_LONG_FOR_NNP_FG,
		FIELD_VERIFIED_FG,
		ACCEPTED_LAT_LONG_FG,
		EXTENT,
		GPSACCURACY,
		GEOREFMETHOD,
		VERIFICATIONSTATUS	
</cfquery>
<cfloop query="pDups">
	<cfset sql="select * from locality,lat_long where
	locality.locality_id = lat_long.locality_id and
		locality.locality_id not in (select locality_id from lat_long where ACCEPTED_LAT_LONG_FG <> 1) and
	GEOG_AUTH_REC_ID = #GEOG_AUTH_REC_ID#">
	 
	<cfif len(#MAXIMUM_ELEVATION#) gt 0>
		<cfset sql="#sql# and MAXIMUM_ELEVATION = #MAXIMUM_ELEVATION#">
	<cfelse>
		<cfset sql="#sql# and MAXIMUM_ELEVATION IS NULL">
	</cfif>
	<cfif len(#MINIMUM_ELEVATION#) gt 0>
		<cfset sql="#sql# and MINIMUM_ELEVATION = #MINIMUM_ELEVATION#">
	<cfelse>
		<cfset sql="#sql# and MINIMUM_ELEVATION IS NULL">
	</cfif>
	
	<cfif len(#ORIG_ELEV_UNITS#) gt 0>
		<cfset sql="#sql# and ORIG_ELEV_UNITS = '#ORIG_ELEV_UNITS#'">
	<cfelse>
		<cfset sql="#sql# and ORIG_ELEV_UNITS IS NULL">
	</cfif>
	
	<cfif len(#TOWNSHIP#) gt 0>
		<cfset sql="#sql# and TOWNSHIP = '#TOWNSHIP#'">
	<cfelse>
		<cfset sql="#sql# and TOWNSHIP IS NULL">
	</cfif>
	
	<cfif len(#TOWNSHIP_DIRECTION#) gt 0>
		<cfset sql="#sql# and TOWNSHIP_DIRECTION = '#TOWNSHIP_DIRECTION#'">
	<cfelse>
		<cfset sql="#sql# and TOWNSHIP_DIRECTION IS NULL">
	</cfif>
	
	<cfif len(#RANGE#) gt 0>
		<cfset sql="#sql# and RANGE = '#RANGE#'">
	<cfelse>
		<cfset sql="#sql# and RANGE IS NULL">
	</cfif>
	
	<cfif len(#RANGE_DIRECTION#) gt 0>
		<cfset sql="#sql# and RANGE_DIRECTION = '#RANGE_DIRECTION#'">
	<cfelse>
		<cfset sql="#sql# and RANGE_DIRECTION IS NULL">
	</cfif>
	
	<cfif len(#SECTION#) gt 0>
		<cfset sql="#sql# and SECTION = '#SECTION#'">
	<cfelse>
		<cfset sql="#sql# and SECTION IS NULL">
	</cfif>
	<cfif len(#SECTION_PART#) gt 0>
		<cfset sql="#sql# and SECTION_PART = '#SECTION_PART#'">
	<cfelse>
		<cfset sql="#sql# and SECTION_PART IS NULL">
	</cfif>
	
	<cfif len(#SPEC_LOCALITY#) gt 0>
		<cfset sql="#sql# and SPEC_LOCALITY = '#replace(SPEC_LOCALITY,"'","''","all")#'">
	<cfelse>
		<cfset sql="#sql# and SPEC_LOCALITY IS NULL">
	</cfif>
	
	<cfif len(#LOCALITY_REMARKS#) gt 0>
		<cfset sql="#sql# and LOCALITY_REMARKS = '#LOCALITY_REMARKS#'">
	<cfelse>
		<cfset sql="#sql# and LOCALITY_REMARKS IS NULL">
	</cfif>
	
	<cfif len(#LEGACY_SPEC_LOCALITY_FG#) gt 0>
		<cfset sql="#sql# and LEGACY_SPEC_LOCALITY_FG = #LEGACY_SPEC_LOCALITY_FG#">
	<cfelse>
		<cfset sql="#sql# and LEGACY_SPEC_LOCALITY_FG IS NULL">
	</cfif>
	
	<cfif len(#DEPTH_UNITS#) gt 0>
		<cfset sql="#sql# and DEPTH_UNITS = '#DEPTH_UNITS#'">
	<cfelse>
		<cfset sql="#sql# and DEPTH_UNITS IS NULL">
	</cfif>
	
	<cfif len(#MIN_DEPTH#) gt 0>
		<cfset sql="#sql# and MIN_DEPTH = '#MIN_DEPTH#'">
	<cfelse>
		<cfset sql="#sql# and MIN_DEPTH IS NULL">
	</cfif>
	<cfif len(#MAX_DEPTH#) gt 0>
		<cfset sql="#sql# and MAX_DEPTH = '#MAX_DEPTH#'">
	<cfelse>
		<cfset sql="#sql# and MAX_DEPTH IS NULL">
	</cfif>
	
	<cfif len(#LAT_DEG#) gt 0>
		<cfset sql="#sql# and LAT_DEG = #LAT_DEG#">
	<cfelse>
		<cfset sql="#sql# and LAT_DEG IS NULL">
	</cfif>
	<cfif len(#DEC_LAT_MIN#) gt 0>
		<cfset sql="#sql# and DEC_LAT_MIN = #DEC_LAT_MIN#">
	<cfelse>
		<cfset sql="#sql# and DEC_LAT_MIN IS NULL">
	</cfif>
	<cfif len(#LAT_MIN#) gt 0>
		<cfset sql="#sql# and LAT_MIN = #LAT_MIN#">
	<cfelse>
		<cfset sql="#sql# and LAT_MIN IS NULL">
	</cfif>
	<cfif len(#LAT_SEC#) gt 0>
		<cfset sql="#sql# and LAT_SEC = #LAT_SEC#">
	<cfelse>
		<cfset sql="#sql# and LAT_SEC IS NULL">
	</cfif>
	<cfif len(#LAT_DIR#) gt 0>
		<cfset sql="#sql# and LAT_DIR = '#LAT_DIR#'">
	<cfelse>
		<cfset sql="#sql# and LAT_DIR IS NULL">
	</cfif>
	<cfif len(#LONG_DEG#) gt 0>
		<cfset sql="#sql# and LONG_DEG = #LONG_DEG#">
	<cfelse>
		<cfset sql="#sql# and LONG_DEG IS NULL">
	</cfif>
	
	<cfif len(#DEC_LONG_MIN#) gt 0>
		<cfset sql="#sql# and DEC_LONG_MIN = #DEC_LONG_MIN#">
	<cfelse>
		<cfset sql="#sql# and DEC_LONG_MIN IS NULL">
	</cfif>
	<cfif len(#LONG_MIN#) gt 0>
		<cfset sql="#sql# and LONG_MIN = #LONG_MIN#">
	<cfelse>
		<cfset sql="#sql# and LONG_MIN IS NULL">
	</cfif>
	<cfif len(#LONG_SEC#) gt 0>
		<cfset sql="#sql# and LONG_SEC = #LONG_SEC#">
	<cfelse>
		<cfset sql="#sql# and LONG_SEC IS NULL">
	</cfif>
	<cfif len(#LONG_DIR#) gt 0>
		<cfset sql="#sql# and LONG_DIR = '#LONG_DIR#'">
	<cfelse>
		<cfset sql="#sql# and LONG_DIR IS NULL">
	</cfif>
	<cfif len(#DEC_LAT#) gt 0>
		<cfset sql="#sql# and DEC_LAT = #DEC_LAT#">
	<cfelse>
		<cfset sql="#sql# and DEC_LAT IS NULL">
	</cfif>
	<cfif len(#DEC_LONG#) gt 0>
		<cfset sql="#sql# and DEC_LONG = #DEC_LONG#">
	<cfelse>
		<cfset sql="#sql# and DEC_LONG IS NULL">
	</cfif>
	<cfif len(#DATUM#) gt 0>
		<cfset sql="#sql# and DATUM = '#DATUM#'">
	<cfelse>
		<cfset sql="#sql# and DATUM IS NULL">
	</cfif>
	<cfif len(#UTM_ZONE#) gt 0>
		<cfset sql="#sql# and UTM_ZONE = '#UTM_ZONE#'">
	<cfelse>
		<cfset sql="#sql# and UTM_ZONE IS NULL">
	</cfif>
	<cfif len(#UTM_EW#) gt 0>
		<cfset sql="#sql# and UTM_EW = '#UTM_EW#'">
	<cfelse>
		<cfset sql="#sql# and UTM_EW IS NULL">
	</cfif>
	<cfif len(#UTM_NS#) gt 0>
		<cfset sql="#sql# and UTM_NS = '#UTM_NS#'">
	<cfelse>
		<cfset sql="#sql# and UTM_NS IS NULL">
	</cfif>
	<cfif len(#ORIG_LAT_LONG_UNITS#) gt 0>
		<cfset sql="#sql# and ORIG_LAT_LONG_UNITS = '#ORIG_LAT_LONG_UNITS#'">
	<cfelse>
		<cfset sql="#sql# and ORIG_LAT_LONG_UNITS IS NULL">
	</cfif>
	<cfif len(#DETERMINED_BY_AGENT_ID#) gt 0>
		<cfset sql="#sql# and DETERMINED_BY_AGENT_ID = #DETERMINED_BY_AGENT_ID#">
	<cfelse>
		<cfset sql="#sql# and DETERMINED_BY_AGENT_ID IS NULL">
	</cfif>
	<cfif len(#DETERMINED_DATE#) gt 0>
		<cfset sql="#sql# and DETERMINED_DATE = '#dateformat(DETERMINED_DATE,"dd-mmm-yyyy")#'">
	<cfelse>
		<cfset sql="#sql# and DETERMINED_DATE IS NULL">
	</cfif>
	<cfif len(#LAT_LONG_REF_SOURCE#) gt 0>
		<cfset sql="#sql# and LAT_LONG_REF_SOURCE = '#replace(LAT_LONG_REF_SOURCE,"'","''","all")#'">
	<cfelse>
		<cfset sql="#sql# and LAT_LONG_REF_SOURCE IS NULL">
	</cfif>
	<cfif len(#LAT_LONG_REMARKS#) gt 0>
		<cfset sql="#sql# and LAT_LONG_REMARKS = '#LAT_LONG_REMARKS#'">
	<cfelse>
		<cfset sql="#sql# and LAT_LONG_REMARKS IS NULL">
	</cfif>
	<cfif len(#MAX_ERROR_DISTANCE#) gt 0>
		<cfset sql="#sql# and MAX_ERROR_DISTANCE = #MAX_ERROR_DISTANCE#">
	<cfelse>
		<cfset sql="#sql# and MAX_ERROR_DISTANCE IS NULL">
	</cfif>
	<cfif len(#MAX_ERROR_UNITS#) gt 0>
		<cfset sql="#sql# and MAX_ERROR_UNITS = '#MAX_ERROR_UNITS#'">
	<cfelse>
		<cfset sql="#sql# and MAX_ERROR_UNITS IS NULL">
	</cfif>
	<cfif len(#NEAREST_NAMED_PLACE#) gt 0>
		<cfset sql="#sql# and NEAREST_NAMED_PLACE = '#NEAREST_NAMED_PLACE#'">
	<cfelse>
		<cfset sql="#sql# and NEAREST_NAMED_PLACE IS NULL">
	</cfif>
	<cfif len(#LAT_LONG_FOR_NNP_FG#) gt 0>
		<cfset sql="#sql# and LAT_LONG_FOR_NNP_FG = #LAT_LONG_FOR_NNP_FG#">
	<cfelse>
		<cfset sql="#sql# and LAT_LONG_FOR_NNP_FG IS NULL">
	</cfif>
	<cfif len(#FIELD_VERIFIED_FG#) gt 0>
		<cfset sql="#sql# and FIELD_VERIFIED_FG = #FIELD_VERIFIED_FG#">
	<cfelse>
		<cfset sql="#sql# and FIELD_VERIFIED_FG IS NULL">
	</cfif>
	<cfif len(#ACCEPTED_LAT_LONG_FG#) gt 0>
		<cfset sql="#sql# and ACCEPTED_LAT_LONG_FG = #ACCEPTED_LAT_LONG_FG#">
	<cfelse>
		<cfset sql="#sql# and ACCEPTED_LAT_LONG_FG IS NULL">
	</cfif>
	<cfif len(#EXTENT#) gt 0>
		<cfset sql="#sql# and EXTENT = #EXTENT#">
	<cfelse>
		<cfset sql="#sql# and EXTENT IS NULL">
	</cfif>
	<cfif len(#GPSACCURACY#) gt 0>
		<cfset sql="#sql# and GPSACCURACY = #GPSACCURACY#">
	<cfelse>
		<cfset sql="#sql# and GPSACCURACY IS NULL">
	</cfif>
	<cfif len(#GEOREFMETHOD#) gt 0>
		<cfset sql="#sql# and GEOREFMETHOD = '#GEOREFMETHOD#'">
	<cfelse>
		<cfset sql="#sql# and GEOREFMETHOD IS NULL">
	</cfif>
	<cfif len(#VERIFICATIONSTATUS#) gt 0>
		<cfset sql="#sql# and VERIFICATIONSTATUS = '#VERIFICATIONSTATUS#'">
	<cfelse>
		<cfset sql="#sql# and VERIFICATIONSTATUS IS NULL">
	</cfif>
	
		<cfquery name="tDups" datasource="#Application.uam_dbo#">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfquery name="theOne" dbtype="query" maxrows="1">
			select * from tDups
		</cfquery>
		<cfquery name="theRest" dbtype="query">
			select * from tDups where locality_id <> #theOne.locality_id#
		</cfquery>
		<hr>
			<br>theOne.locality_id: #theOne.locality_id#
			<cfloop query="theRest">
				<!--- kill this --->
				
				<cftransaction>
					<!--- first, update collecting events --->
					<cfquery name="fColl" datasource="#Application.uam_dbo#">
						UPDATE collecting_event set locality_id=#theOne.locality_id# where locality_id=#locality_id#
					</cfquery>
					<!--- delete soon-to-be unused coordinates --->
					<cfquery name="fLL" datasource="#Application.uam_dbo#">
						delete from lat_long where locality_id=#locality_id#
					</cfquery>
					<!--- clean up locality --->
					<cfquery name="fLoc" datasource="#Application.uam_dbo#">
						delete from locality where locality_id=#locality_id#
					</cfquery>
				</cftransaction>
				<br>the rest: #locality_id#
			</cfloop>
</cfloop>
--->

<!--- now collecting events --->
<!---
<cfquery name="pDups" datasource="#Application.uam_dbo#">
select 
	LOCALITY_ID,
	BEGAN_DATE,
	ENDED_DATE,
	VERBATIM_DATE,
	VERBATIM_LOCALITY,
	COLL_EVENT_REMARKS,
	VALID_DISTRIBUTION_FG,
	COLLECTING_SOURCE,
	COLLECTING_METHOD,
	HABITAT_DESC,
	count(*) num
	from 
		collecting_event
	having count(*) > 1
	group by
      LOCALITY_ID,
		BEGAN_DATE,
		ENDED_DATE,
		VERBATIM_DATE,
		VERBATIM_LOCALITY,
		COLL_EVENT_REMARKS,
		VALID_DISTRIBUTION_FG,
		COLLECTING_SOURCE,
		COLLECTING_METHOD,
		HABITAT_DESC
</cfquery>
<cfloop query="pDups">
	
			<cfset sql="select * from collecting_event where
			LOCALITY_ID=#LOCALITY_ID# and
			BEGAN_DATE='#dateformat(BEGAN_DATE,"dd-mmm-yyyy")#' and
			ENDED_DATE='#dateformat(ENDED_DATE,"dd-mmm-yyyy")#' and
			VERBATIM_DATE='#VERBATIM_DATE#' and
			COLLECTING_SOURCE='#COLLECTING_SOURCE#'">
			<cfif len(#VERBATIM_LOCALITY#) gt 0>
				<cfset sql="#sql# and VERBATIM_LOCALITY = '#replace(VERBATIM_LOCALITY,"'","''","all")#'">
			<cfelse>
				<cfset sql="#sql# and VERBATIM_LOCALITY IS NULL">
			</cfif>
			<cfif len(#COLL_EVENT_REMARKS#) gt 0>
				<cfset sql="#sql# and COLL_EVENT_REMARKS = '#COLL_EVENT_REMARKS#'">
			<cfelse>
				<cfset sql="#sql# and COLL_EVENT_REMARKS IS NULL">
			</cfif>
			<cfif len(#VALID_DISTRIBUTION_FG#) gt 0>
				<cfset sql="#sql# and VALID_DISTRIBUTION_FG = #VALID_DISTRIBUTION_FG#">
			<cfelse>
				<cfset sql="#sql# and VALID_DISTRIBUTION_FG IS NULL">
			</cfif>
			<cfif len(#COLLECTING_METHOD#) gt 0>
				<cfset sql="#sql# and COLLECTING_METHOD = '#COLLECTING_METHOD#'">
			<cfelse>
				<cfset sql="#sql# and COLLECTING_METHOD IS NULL">
			</cfif>
			<cfif len(#HABITAT_DESC#) gt 0>
				<cfset sql="#sql# and HABITAT_DESC = '#HABITAT_DESC#'">
			<cfelse>
				<cfset sql="#sql# and HABITAT_DESC IS NULL">
			</cfif>
			<!---
			<hr>
			#preservesinglequotes(sql)#
			<hr>
			--->
		<cfquery name="tDups" datasource="#Application.uam_dbo#">
			#preservesinglequotes(sql)#
		</cfquery>
		<cfquery name="theOne" dbtype="query" maxrows="1">
			select * from tDups
		</cfquery>
		<cfquery name="theRest" dbtype="query">
			select * from tDups where collecting_event_id <> #theOne.collecting_event_id#
		</cfquery>
	<hr>
			<br>theOne.collecting_event_id: #theOne.collecting_event_id#
			<cfloop query="theRest">
				<!--- kill this --->
				
				<cftransaction>
					<!--- first, update collecting events --->
					<cfquery name="FcAT" datasource="#Application.uam_dbo#">
						UPDATE cataloged_item set collecting_event_id=#theOne.collecting_event_id# 
						where collecting_event_id=#collecting_event_id#
					</cfquery>
					<!--- delete soon-to-be unused coordinates --->
					<cfquery name="fColE" datasource="#Application.uam_dbo#">
						delete from collecting_event where collecting_event_id=#collecting_event_id#
					</cfquery>
				</cftransaction>
				<br>the rest: #collecting_event_id#
			</cfloop>

</cfloop>
--->
<!---
<!--- people ---->
<cfquery name="p" datasource="#Application.uam_dbo#" maxrows="1000">
	select 
		PREFIX,
		LAST_NAME,
		FIRST_NAME,
		MIDDLE_NAME,
		SUFFIX,
		count(*) 
	from person
	where
	person_id not in (select related_agent_id from agent_relations where agent_relationship='bad duplicate of')
	having count(*) > 1
	group by
	PREFIX,
		LAST_NAME,
		FIRST_NAME,
		MIDDLE_NAME,
		SUFFIX	
</cfquery>
<cfloop query="p">
	<!--- don't get agents that are already in a bad dup of relationship --->
	<cfquery name="pd" datasource="#Application.uam_dbo#">
		select 
			*
		from
		person where
		last_name='#last_name#'
		<cfif len(#PREFIX#) gt 0>
			and PREFIX = '#PREFIX#'
		<cfelse>
			and PREFIX IS NULL
		</cfif>
		<cfif len(#FIRST_NAME#) gt 0>
			and FIRST_NAME = '#FIRST_NAME#'
		<cfelse>
			and FIRST_NAME IS NULL
		</cfif>
		<cfif len(#MIDDLE_NAME#) gt 0>
			and MIDDLE_NAME = '#MIDDLE_NAME#'
		<cfelse>
			and MIDDLE_NAME IS NULL
		</cfif>
		<cfif len(#SUFFIX#) gt 0>
			and SUFFIX = '#SUFFIX#'
		<cfelse>
			and SUFFIX IS NULL
		</cfif>
	</cfquery>
	
	<cfquery name="theOne" dbtype="query" maxrows="1">
			select * from pd
		</cfquery>
		<cfquery name="theRest" dbtype="query">
			select * from pd where person_id <> #theOne.person_id#
		</cfquery>
	<hr>
			<br>theOne.person_id: #theOne.person_id#
			<cfloop query="theRest">
				<!--- kill this --->
				
				<cftransaction>
					<!--- add relationship --->
					<cfquery name="FcAT" datasource="#Application.uam_dbo#">
						insert into agent_relations (agent_id,related_agent_id,agent_relationship)
						values
						(#person_id#,#theOne.person_id#,'bad duplicate of')
					</cfquery>
					
				</cftransaction>
				<br>the rest: #person_id#
			</cfloop>
			
			
</cfloop>
---->

<!---- taxonomy ---->
<cfquery name="p" datasource="#Application.uam_dbo#" maxrows="500">
	select 
		SCIENTIFIC_NAME,
		count(*) 
	from taxonomy
	having count(*) > 1
	group by
	SCIENTIFIC_NAME
</cfquery>
<cfloop query="p">
	<!--- don't get agents that are already in a bad dup of relationship --->
	<cfquery name="pd" datasource="#Application.uam_dbo#">
		select 
			* from
		taxonomy
		 where
		 scientific_Name='#SCIENTIFIC_NAME#'
		 order by taxon_name_id
	</cfquery>
	
	<cfquery name="theOne" dbtype="query" maxrows="1">
			select * from pd
		</cfquery>
		<cfquery name="theRest" dbtype="query">
			select * from pd where taxon_name_id <> #theOne.taxon_name_id#
		</cfquery>
	<hr>
			<br>theOne.taxon_name_id: #theOne.taxon_name_id#
			<cfloop query="theRest">
				<cfset theSame = "yes">
				<cfif #theOne.PHYLCLASS# is not #PHYLCLASS#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.PHYLORDER# is not #PHYLORDER#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.SUBORDER# is not #SUBORDER#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.FAMILY# is not #FAMILY#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.SUBFAMILY# is not #SUBFAMILY#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.GENUS# is not #GENUS#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.SUBGENUS# is not #SUBGENUS#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.SPECIES# is not #SPECIES#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.SUBSPECIES# is not #SUBSPECIES#>
					<cfset theSame = "no">
				</cfif>
				
				<cfif #theOne.VALID_CATALOG_TERM_FG# is not #VALID_CATALOG_TERM_FG#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.SOURCE_AUTHORITY# is not #SOURCE_AUTHORITY#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.FULL_TAXON_NAME# is not #FULL_TAXON_NAME#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.SCIENTIFIC_NAME# is not #SCIENTIFIC_NAME#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.AUTHOR_TEXT# is not #AUTHOR_TEXT#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.TRIBE# is not #TRIBE#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.INFRASPECIFIC_RANK# is not #INFRASPECIFIC_RANK#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theOne.TAXON_REMARKS# is not #TAXON_REMARKS#>
					<cfset theSame = "no">
				</cfif>
				<cfif #theSame# is "yes">
					<cftransaction>
						<cfquery name="id" datasource="#Application.uam_dbo#">
							update identification_taxonomy set 
							taxon_name_id=#theOne.taxon_name_id# where taxon_name_id = #taxon_name_id#
						</cfquery>
						<cfquery name="cit" datasource="#Application.uam_dbo#">
							update citation set CITED_TAXON_NAME_ID
							=#theOne.taxon_name_id# where CITED_TAXON_NAME_ID = #taxon_name_id#
						</cfquery>
						<cftry>
							<cfquery name="cname" datasource="#Application.uam_dbo#">
								update COMMON_NAME set TAXON_NAME_ID
								=#theOne.taxon_name_id# where TAXON_NAME_ID = #taxon_name_id#
							</cfquery>
						<cfcatch>
							<!--- trying to make another common name, just kill the old one --->
							<cfquery name="cname" datasource="#Application.uam_dbo#">
								delete from  COMMON_NAME where TAXON_NAME_ID = #taxon_name_id#
							</cfquery>
						</cfcatch>
						</cftry>
						<cftry>
						<cfquery name="reln" datasource="#Application.uam_dbo#">
							update TAXON_RELATIONS set TAXON_NAME_ID
							=#theOne.taxon_name_id# where TAXON_NAME_ID = #taxon_name_id#
						</cfquery>
						<cfquery name="relnd" datasource="#Application.uam_dbo#">
							update TAXON_RELATIONS set RELATED_TAXON_NAME_ID
							=#theOne.taxon_name_id# where RELATED_TAXON_NAME_ID = #taxon_name_id#
						</cfquery>
						<cfcatch>
							<cfquery name="reln" datasource="#Application.uam_dbo#">
								delete from  TAXON_RELATIONS where TAXON_NAME_ID = #taxon_name_id#
							</cfquery>
							<cfquery name="reln" datasource="#Application.uam_dbo#">
								delete from  TAXON_RELATIONS where RELATED_TAXON_NAME_ID = #taxon_name_id#
							</cfquery>
						</cfcatch>
						</cftry>
						
						<cfquery name="tax" datasource="#Application.uam_dbo#">
							delete from taxonomy where taxon_name_id = #taxon_name_id#
						</cfquery>
						<br>#theOne.SCIENTIFIC_NAME# is #SCIENTIFIC_NAME#
						<cfflush>
					</cftransaction>
				</cfif>
			</cfloop>
</cfloop>
moving over.....
<!----
<script>
	document.location='cleanOrphanAndDup.cfm';
</script>
---->

</cfoutput>