<!--- returns query object localityResults --->
<cfinclude template="/includes/functionLib.cfm">
<cfoutput>
<cfset sql = "
	select
		geog_auth_rec.geog_auth_rec_id,
		locality.locality_id,
		collecting_event.collecting_event_id,
		higher_geog,
		spec_locality,
		began_date,
		ended_date,
		verbatim_date,
		verbatim_locality,
		collecting_source,
		collecting_method,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_lat || 'd'
			WHEN 'deg. min. sec.' THEN lat_deg || 'd ' || lat_min || 'm ' || lat_sec || 's ' || lat_dir
			WHEN 'degrees dec. minutes' THEN lat_deg || 'd ' || dec_lat_min || 'm ' || lat_dir
		END VerbatimLatitude,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_long || 'd'
			WHEN'degrees dec. minutes' THEN long_deg || 'd ' || dec_long_min || 'm ' || long_dir
			WHEN 'deg. min. sec.' THEN long_deg || 'd ' || long_min || 'm ' || long_sec || 's ' || long_dir
		END VerbatimLongitude,
		nogeorefbecause,
		max_error_distance,
		max_error_units,
		lat_long_ref_source,
        determined_date,
		minimum_elevation,
		maximum_elevation,
		orig_elev_units,
        coordDet.agent_name coordinateDeterminer,
		concatGeologyAttributeDetail(locality.locality_id) geolAtts
	from 
		geog_auth_rec,
		locality,
		accepted_lat_long,
        preferred_agent_name coordDet,
		collecting_event,
		geology_attributes
	where
		geog_auth_rec.geog_auth_rec_id = locality.geog_auth_rec_id (+) and
		locality.locality_id = accepted_lat_long.locality_id (+) and
        accepted_lat_long.determined_by_agent_id = coordDet.agent_id (+) and
		locality.locality_id=collecting_event.locality_id (+) and
		locality.locality_id = geology_attributes.locality_id (+) ">

<cfif isdefined("locality_id") and len(#locality_id#) gt 0>
	<cfset sql = "#sql# AND locality.locality_id = #locality_id#">
</cfif>
<cfif isdefined("geology_attribute") and len(#geology_attribute#) gt 0>
	<cfset sql = "#sql# AND geology_attributes.geology_attribute = '#geology_attribute#'">	
</cfif>
<cfif isdefined("geo_att_value") and len(#geo_att_value#) gt 0>
	<cfif isdefined("geology_attribute_hier") and #geology_attribute_hier# is 1>
		<!--- not quite sure what to do with this yet - turning it off at the 
		search form for now - DLM --->
		<cfset sql = "#sql# AND geology_attributes.geo_att_value IN (
				SELECT  
	 				attribute_value	
	 			FROM
					geology_attribute_hierarchy
				start with 
					upper(attribute_value) like '%#ucase(geo_att_value)#%'
				CONNECT BY PRIOR 
					geology_attribute_hierarchy_id = parent_id
				)">
	<cfelse>
		<cfset sql = "#sql# AND upper(geology_attributes.geo_att_value) like '%#ucase(geo_att_value)#%'">
	</cfif>	
</cfif>

<cfif isdefined("geog_auth_rec_id") and len(#geog_auth_rec_id#) gt 0>
	<cfset sql = "#sql# AND geog_auth_rec.geog_auth_rec_id = #geog_auth_rec_id#">
</cfif>
<cfif isdefined("collecting_event_id") and len(#collecting_event_id#) gt 0>
	<cfset sql = "#sql# AND collecting_event.collecting_event_id = #collecting_event_id#">
</cfif>


<cfif not isdefined("begDateOper")>
	<cfset begDateOper="=">
</cfif>
<cfif not isdefined("maxElevOper")>
	<cfset maxElevOper="=">
</cfif>
<cfif not isdefined("minElevOper")>
	<cfset minElevOper="=">
</cfif>
<cfif isdefined("began_date") and len(#began_date#) gt 0>
	<cfset sql = "#sql# AND began_date #begDateOper# to_date('#began_date#')">
</cfif>		
<cfif isdefined("ended_date") and len(#ended_date#) gt 0>
	<cfset sql = "#sql# AND ended_date #endDateOper# to_date('#ended_date#')">
</cfif>

<cfif isdefined("verbatim_date") and len(#verbatim_date#) gt 0>
	<cfset sql = "#sql# AND upper(verbatim_date) like '%#ucase(verbatim_date)#%'">
</cfif>

<cfif isdefined("verbatim_locality") and len(#verbatim_locality#) gt 0>
	<cfset sql = "#sql# AND upper(verbatim_locality) like '%#ucase(verbatim_locality)#%'">
</cfif>
<cfif isdefined("coll_event_remarks") and len(#coll_event_remarks#) gt 0>
	<cfset sql = "#sql# AND upper(coll_event_remarks) like '%#ucase(coll_event_remarks)#%'">
</cfif>

<cfif isdefined("collecting_source") and len(#collecting_source#) gt 0>
	<cfset sql = "#sql# AND upper(collecting_source) like '%#ucase(collecting_source)#%'">
</cfif>

<cfif isdefined("collecting_method") and len(#collecting_method#) gt 0>
	<cfset sql = "#sql# AND upper(collecting_method) like '%#ucase(collecting_method)#%'">
</cfif>

<cfif isdefined("habitat_desc") and len(#habitat_desc#) gt 0>
	<cfset sql = "#sql# AND upper(habitat_desc) like '%#ucase(habitat_desc)#%'">
</cfif>		
<cfif isdefined("spec_locality") and len(#spec_locality#) gt 0>
	<cfset sloc = #ucase(replace(spec_locality,"'","''","all"))#>
	<cfset sql = "#sql# AND upper(spec_locality) like '%#escapeQuotes(ucase(spec_locality))#%'">
</cfif>
<cfif isdefined("maximum_elevation") and len(#maximum_elevation#) gt 0>
	<cfset sql = "#sql# AND maximum_elevation #maxElevOper# #maximum_elevation#">
</cfif>
<cfif isdefined("minimum_elevation") and len(#minimum_elevation#) gt 0>
	<cfset sql = "#sql# AND minimum_elevation #minElevOper# #minimum_elevation#">
</cfif>
<cfif isdefined("orig_elev_units") and len(#orig_elev_units#) gt 0>
	<cfset sql = "#sql# AND orig_elev_units = '#orig_elev_units#'">
</cfif>
<cfif isdefined("locality_remarks") and len(#locality_remarks#) gt 0>
	<cfset sql = "#sql# AND upper(locality_remarks) like '%#ucase(locality_remarks)#%'">
</cfif>
<cfif isdefined("continent_ocean") and len(#continent_ocean#) gt 0>
	<cfset sql = "#sql# AND upper(continent_ocean) LIKE '%#ucase(continent_ocean)#%'">
</cfif>
<cfif isdefined("country") and len(#country#) gt 0>
	<cfset sql = "#sql# AND upper(country) LIKE '%#ucase(country)#%'">
</cfif>
<cfif isdefined("state_prov") and len(#state_prov#) gt 0>
	<cfset sql = "#sql# AND upper(state_prov) LIKE '%#ucase(state_prov)#%'">
</cfif>
<cfif isdefined("county") and len(#county#) gt 0>
	<cfset sql = "#sql# AND upper(county) LIKE '%#ucase(county)#%'">
</cfif>
<cfif isdefined("quad") and len(#quad#) gt 0>
	<cfset sql = "#sql# AND upper(quad) LIKE '%#ucase(quad)#%'">
</cfif>
<cfif isdefined("feature") and len(#feature#) gt 0>
	<cfset sql = "#sql# AND feature = '#feature#'">
</cfif>
<cfif isdefined("island_group") and len(#island_group#) gt 0>
	<cfset sql = "#sql# AND island_group = '#island_group#'">
</cfif>
<cfif isdefined("island") and len(#island#) gt 0>
	<cfset sql = "#sql# AND upper(island) LIKE '%#ucase(island)#%'">
</cfif>
<cfif isdefined("sea") and len(#sea#) gt 0>
	<cfset sql = "#sql# AND upper(sea) LIKE '%#ucase(sea)#%'">
</cfif>
<cfif isdefined("higher_geog") and len(#higher_geog#) gt 0>
	<cfset sql = "#sql# AND upper(higher_geog) like '%#ucase(higher_geog)#%'">
</cfif>
<cfif isdefined("NoGeorefBecause") AND len(#NoGeorefBecause#) gt 0>
	<cfset sql = "#sql# AND upper(NoGeorefBecause) like '%#ucase(NoGeorefBecause)#%'">
</cfif>
<cfif isdefined("VerificationStatus") AND len(#VerificationStatus#) gt 0>
	<cfset sql = "#sql# AND VerificationStatus='#VerificationStatus#'">
</cfif>
<cfif isdefined("GeorefMethod") AND len(#GeorefMethod#) gt 0>
	<cfset sql = "#sql# AND GeorefMethod='#GeorefMethod#'">
</cfif>
<cfif isdefined("nullNoGeorefBecause") and len(#nullNoGeorefBecause#) gt 0>
	<cfset sql = "#sql# AND NoGeorefBecause IS NULL">
</cfif>
<cfif isdefined("isIncomplete") AND len(#isIncomplete#) gt 0>
	<cfset sql = "#sql# AND 
		( GPSACCURACY IS NULL OR EXTENT IS NULL OR MAX_ERROR_DISTANCE = 0 or MAX_ERROR_DISTANCE IS NULL)">
</cfif>
<cfif isdefined("findNoAccGeoRef") and len(#findNoAccGeoRef#) gt 0>
	<cfset sql = "#sql# AND locality.locality_id 
		IN (select locality_id from lat_long) AND
		locality.locality_id  NOT IN (select locality_id from lat_long where accepted_lat_long_fg=1)">
</cfif>
<cfif isdefined("findNoGeoRef") and len(#findNoGeoRef#) gt 0>
	<cfset sql = "#sql# AND locality.locality_id NOT IN (select locality_id from lat_long)">
</cfif>
<cfif isdefined("coordinateDeterminer") and len(#coordinateDeterminer#) gt 0>
	<cfset sql = "#sql# AND upper(agent_name) like '%#ucase(coordinateDeterminer)#%'">
</cfif>

<cfif right(sql,4) is " (+)">
	<span class="error">You must enter search criteria.</span>
	<cfabort>
</cfif>
<cfset sql = "#sql# ORDER BY
	higher_geog,
	spec_locality,
	verbatim_locality,
	verbatimLatitude">
<cfquery name="caller.localityResults" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
<cfif caller.localityResults.recordcount is 0>
	<span class="error">Your search found no matches.</span>
	<cfabort>
</cfif>	
</cfoutput>