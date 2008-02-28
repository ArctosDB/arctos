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
		nogeorefbecause
	from 
		geog_auth_rec,
		locality,
		accepted_lat_long,
		collecting_event
	where
		geog_auth_rec.geog_auth_rec_id = locality.geog_auth_rec_id and
		locality.locality_id = accepted_lat_long.locality_id (+) and
		locality.locality_id=collecting_event.locality_id">

<cfif isdefined("locality_id") and len(#locality_id#) gt 0>
	<cfset sql = "#sql# AND collecting_event.locality_id = #locality_id#">
</cfif><!--- normal search --->
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
<cfif len(#ENDED_DATE#) gt 0>
	<cfset sql = "#sql# AND ENDED_DATE #endDateOper# to_date('#ENDED_DATE#')">
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
	<cfset sql = "#sql# AND upper(spec_locality) like '%#escapeQuotes(spec_locality)#%'">
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
<cfif isdefined("valid_catalog_term_fg") and len(#valid_catalog_term_fg#) gt 0>
	<cfset sql = "#sql# AND valid_catalog_term_fg = #valid_catalog_term_fg#">
</cfif>
<cfset sql = "#sql# ORDER BY
	higher_geog,
	spec_locality,
	verbatim_locality,
	verbatimLatitude">
<cfquery name="getCollEvent" datasource="#Application.web_user#">
	#preservesinglequotes(sql)#
</cfquery>
	
<table border>
	<tr>
		<td><b>Geog</b></td>
		<td><b>Locality</b></td>
		<td><b>Verbatim&nbsp;Locality</b></td>
		<td><b>Began&nbsp;Date</b></td>
		<td><b>End&nbsp;Date</b></td>
		<td><b>Verb.&nbsp;Date</b></td>
		<td><b>Source</b></td>
		<td><b>Method</b></td>
	</tr>
	<cfloop query="getCollEvent">
		<input type="hidden" name="collecting_event_id" value="#collecting_event_id#" />
		<tr>
			<td> <div class="smaller">#higher_geog#
				(<a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#" 
					target="#client.target#">#geog_auth_rec_id#</a>)
				</div>
			</td>
			<td>
				 <div class="smaller">
				 #spec_locality#
					<cfif len(#VerbatimLatitude#) gt 0>
						<br>#VerbatimLatitude#/#VerbatimLongitude#
					<cfelse>
						<br>#nogeorefbecause#
					</cfif> 
					(<a href="editLocality.cfm?locality_id=#locality_id#" 
						target="#client.target#">#locality_id#</a>)
				</div>
			<!---&nbsp;<a href="/fix/DupLocs.cfm?action=killDups&locid=#locality_id#" target="_blank"><font size="-2"><i>kill dups</i></font></a>---></td>
			<td>
				<div class="smaller">
				 	#verbatim_locality#
					(<a href="Locality.cfm?Action=editCollEvnt&collecting_event_id=#collecting_event_id#">#collecting_event_id#</a>)
				</div>
			</td>
			<td>#dateformat(began_date,"dd mmm yyyy")#</td>
			<td>#dateformat(ended_date,"dd mmm yyyy")#</td>
			<td>#verbatim_date#</td>
			<td>#collecting_source#</td>
			<td>#collecting_method#</td>
		</tr>
	</cfloop>
</table>
</cfoutput>