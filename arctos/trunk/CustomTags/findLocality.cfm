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
		Verbatim_coordinates,
		max_error_distance,
		max_error_units,
		minimum_elevation,
		maximum_elevation,
		orig_elev_units,
		concatGeologyAttributeDetail(locality.locality_id) geolAtts,
		specimen_event_type,
		locality.dec_lat,
		locality.dec_long,
		georeference_source,
		georeference_protocol
	from 
		geog_auth_rec,
		locality,
		collecting_event,
		specimen_event,
		geology_attributes,
		cataloged_item
	where
		geog_auth_rec.geog_auth_rec_id = locality.geog_auth_rec_id (+) and
		locality.locality_id=collecting_event.locality_id (+) and
		collecting_event.collecting_event_id = specimen_event.collecting_event_id (+) and
		specimen_event.collection_object_id=cataloged_item.collection_object_id (+) and
		locality.locality_id = geology_attributes.locality_id (+) ">

<cfif isdefined("collection_id") and len(collection_id) gt 0>
	<cfif not isdefined("collnOper") or len(collnOper) is 0>
		<cfset collnOper="usedOnlyBy">
	</cfif>
	<cfif collnOper is "usedOnlyBy">
		<cfset sql = "#sql# AND cataloged_item.collection_id in ( #collection_id# ) and
			cataloged_item.collection_id not in ( select collection_id from collection minus select #collection_id# from dual)">
	<cfelseif collnOper is "usedBy">
		<cfset sql = "#sql# AND cataloged_item.collection_id in ( #collection_id# )">
	<cfelseif collnOper is "notUsedBy">
		<cfset sql = "#sql# AND cataloged_item.collection_id not in ( #collection_id# )">
	</cfif>
</cfif>
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
	<cfset sql = "#sql# AND began_date #begDateOper# '#began_date#'">
</cfif>		
<cfif isdefined("ended_date") and len(#ended_date#) gt 0>
	<cfset sql = "#sql# AND ended_date #endDateOper# '#ended_date#'">
</cfif>

<cfif isdefined("verbatim_date") and len(#verbatim_date#) gt 0>
	<cfset sql = "#sql# AND upper(verbatim_date) like '%#escapeQuotes(ucase(verbatim_date))#%'">
</cfif>

<cfif isdefined("verbatim_locality") and len(#verbatim_locality#) gt 0>
	<cfset sql = "#sql# AND upper(verbatim_locality) like '%#escapeQuotes(ucase(verbatim_locality))#%'">
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

<cfif isdefined("habitat") and len(#habitat#) gt 0>
	<cfset sql = "#sql# AND upper(habitat) like '%#ucase(habitat)#%'">
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
<cfif isdefined("georeference_protocol") AND len(#georeference_protocol#) gt 0>
	<cfset sql = "#sql# AND georeference_protocol='#georeference_protocol#'">
</cfif>
<cfif right(sql,4) is " (+)">
	<span class="error">You must enter search criteria.</span>
	<cfabort>
</cfif>
<cfset sql = "#sql# ORDER BY
	higher_geog,
	spec_locality,
	verbatim_locality,
	verbatim_coordinates">
<cfquery name="caller.localityResults" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	#preservesinglequotes(sql)#
</cfquery>
<cfif caller.localityResults.recordcount is 0>
	<span class="error">Your search found no matches.</span>
	<cfabort>
</cfif>	
</cfoutput>