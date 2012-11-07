this doesn't actually do anything - it was written for a specific purpose and needs expanded. Contact us.


<cfabort>
<cfoutput>
		<cfquery name="d" datasource="uam_god">
		select 
	LATITUDE,
	LONGITUDE 
from uw where 
	LATITUDE_DECIMAL_DEGREES_GEO is null and
	LONGITUDE_DECIMAL_DEGREES_GE is null and (	
		is_number(LATITUDE) = 0 or is_number(LONGITUDE) = 0
	) and
	ORIG_LAT_LONG_UNITS is null
	group by LATITUDE,LONGITUDE
	order by LATITUDE,LONGITUDE
		</cfquery>
		
		
		<cfloop query="d">
			
			<cfset lat=replace(LATITUDE,'N','','all')>
			<cfset lat=replace(lat,"'",' ','all')>
			<cfset lat=replace(lat,'"','','all')>
			
			
			<cfset lon=replace(LONGITUDE,'W','','all')>
			<cfset lon=replace(lon,"'",' ','all')>
			<cfset lon=replace(lon,'"','','all')>
		
		<br>
		update uw set
	
	LATDEG='#listgetat(lat,1," ")#',
	<cfif listgetat(lat,2," ") contains ".">
		DEC_LAT_MIN='#listgetat(lat,2," ")#',
		ORIG_LAT_LONG_UNITS='degrees dec. minutes',
	<cfelse>
		ORIG_LAT_LONG_UNITS='deg. min. sec. ',
		LATMIN='#listgetat(lat,2," ")#',
		LATSEC='#listgetat(lat,3," ")#',
	</cfif>
	LONGDEG='#listgetat(lon,1," ")#',
	<cfif listgetat(lon,2," ") contains ".">
		DEC_LONG_MIN='#listgetat(lon,2," ")#',
	<cfelse>
		LONGMIN='#listgetat(lon,2," ")#',
		LONGSEC='#listgetat(lon,3," ")#',
	</cfif>
	LATDIR='N',
	LONGDIR='W'
where
	LATITUDE='#replace(LATITUDE,"'","''","all")#' and
	LONGITUDE='#replace(LONGITUDE,"'","''","all")#'
;





		</cfloop>
<cfdump var=#d#>

</cfoutput>