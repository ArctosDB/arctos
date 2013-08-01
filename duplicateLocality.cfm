<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfoutput>
	<cfquery name="orig" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			LOCALITY_ID,
			GEOG_AUTH_REC_ID,
			SPEC_LOCALITY,
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
			LOCALITY_NAME
		from 
			locality 
		where locality_id=#locality_id#
	</cfquery>
	<table border id="t" class="sortable">
		<tr>
			<th>LOCALITY_ID</th>
			<th>GEOG_AUTH_REC_ID</th>
			<th>SPEC_LOCALITY</th>
			<th>DEC_LAT</th>
			<th>DEC_LONG</th>
			<th>MINIMUM_ELEVATION</th>
			<th>MAXIMUM_ELEVATION</th>
			<th>ORIG_ELEV_UNITS</th>
			<th>MIN_DEPTH</th>
			<th>MAX_DEPTH</th>
			<th>DEPTH_UNITS</th>
			<th>MAX_ERROR_DISTANCE</th>
			<th>MAX_ERROR_UNITS</th>
			<th>DATUM</th>
			<th>LOCALITY_REMARKS</th>
			<th>GEOREFERENCE_SOURCE</th>
			<th>GEOREFERENCE_PROTOCOL</th>
			<th>LOCALITY_NAME</th>
		</tr>
		<tr>
			<td>#orig.LOCALITY_ID#</td>
			<td>#orig.GEOG_AUTH_REC_ID#</td>
			<td>#orig.SPEC_LOCALITY#</td>
			<td>#orig.DEC_LAT#</td>
			<td>#orig.DEC_LONG#</td>
			<td>#orig.MINIMUM_ELEVATION#</td>
			<td>#orig.MAXIMUM_ELEVATION#</td>
			<td>#orig.ORIG_ELEV_UNITS#</td>
			<td>#orig.MIN_DEPTH#</td>
			<td>#orig.MAX_DEPTH#</td>
			<td>#orig.DEPTH_UNITS#</td>
			<td>#orig.MAX_ERROR_DISTANCE#</td>
			<td>#orig.MAX_ERROR_UNITS#</td>
			<td>#orig.DATUM#</td>
			<td>#orig.LOCALITY_REMARKS#</td>
			<td>#orig.GEOREFERENCE_SOURCE#</td>
			<td>#orig.GEOREFERENCE_PROTOCOL#</td>
			<td>#orig.LOCALITY_NAME#</td>
		</tr>
		<tr>
			<td>Filter for Duplicates.....</td>
			<td>#orig.GEOG_AUTH_REC_ID#</td>
			<td>#orig.SPEC_LOCALITY#</td>
			<td>#orig.DEC_LAT#</td>
			<td>#orig.DEC_LONG#</td>
			<td>#orig.MINIMUM_ELEVATION#</td>
			<td>#orig.MAXIMUM_ELEVATION#</td>
			<td>#orig.ORIG_ELEV_UNITS#</td>
			<td>#orig.MIN_DEPTH#</td>
			<td>#orig.MAX_DEPTH#</td>
			<td>#orig.DEPTH_UNITS#</td>
			<td>#orig.MAX_ERROR_DISTANCE#</td>
			<td>#orig.MAX_ERROR_UNITS#</td>
			<td>#orig.DATUM#</td>
			<td>#orig.LOCALITY_REMARKS#</td>
			<td>#orig.GEOREFERENCE_SOURCE#</td>
			<td>#orig.GEOREFERENCE_PROTOCOL#</td>
			<td>#orig.LOCALITY_NAME#</td>
		</tr>
	</table>
	<cfset sql="select
			LOCALITY_ID,
			GEOG_AUTH_REC_ID,
			SPEC_LOCALITY,
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
			LOCALITY_NAME
		from 
			locality 
		where 
			locality_id != #locality_id# and
			GEOG_AUTH_REC_ID=#orig.GEOG_AUTH_REC_ID# and
			SPEC_LOCALITY='#orig.SPEC_LOCALITY#' and ">
	<cfif len(orig.dec_lat) gt 0>
		<cfset sql=sql & " DEC_LAT=#orig.DEC_LAT# and ">
	<cfelse>
		<cfset sql=sql & " DEC_LAT is null and ">
	</cfif>
	<cfif len(orig.DEC_LONG) gt 0>
		<cfset sql=sql & " DEC_LONG=#orig.DEC_LONG# and ">
	<cfelse>
		<cfset sql=sql & " DEC_LONG is null and ">
	</cfif>
	<cfif len(orig.MINIMUM_ELEVATION) gt 0>
		<cfset sql=sql & " MINIMUM_ELEVATION=#orig.MINIMUM_ELEVATION# and ">
	<cfelse>
		<cfset sql=sql & " MINIMUM_ELEVATION is null and ">
	</cfif>
	<cfif len(orig.MAXIMUM_ELEVATION) gt 0>
		<cfset sql=sql & " MAXIMUM_ELEVATION=#orig.MAXIMUM_ELEVATION# and ">
	<cfelse>
		<cfset sql=sql & " MAXIMUM_ELEVATION is null and ">
	</cfif>
	<cfset sql=sql & " ORIG_ELEV_UNITS = '#orig.ORIG_ELEV_UNITS#' and ">
	
	<cfif len(orig.MIN_DEPTH) gt 0>
		<cfset sql=sql & " MIN_DEPTH=#orig.MIN_DEPTH# and ">
	<cfelse>
		<cfset sql=sql & " MIN_DEPTH is null and ">
	</cfif>
	<cfif len(orig.MAX_DEPTH) gt 0>
		<cfset sql=sql & " MAX_DEPTH=#orig.MAX_DEPTH# and ">
	<cfelse>
		<cfset sql=sql & " MAX_DEPTH is null and ">
	</cfif>
	<cfset sql=sql & " DEPTH_UNITS = '#orig.DEPTH_UNITS#' and ">
	<cfif len(orig.MAX_ERROR_DISTANCE) gt 0>
		<cfset sql=sql & " MAX_ERROR_DISTANCE=#orig.MAX_ERROR_DISTANCE# and ">
	<cfelse>
		<cfset sql=sql & " MAX_ERROR_DISTANCE is null and ">
	</cfif>
	<cfset sql=sql & " MAX_ERROR_UNITS = '#orig.MAX_ERROR_UNITS#' and ">
	<cfset sql=sql & " DATUM = '#orig.DATUM#' and ">
	<cfset sql=sql & " LOCALITY_REMARKS = '#orig.LOCALITY_REMARKS#' and ">
	<cfset sql=sql & " GEOREFERENCE_SOURCE = '#orig.GEOREFERENCE_SOURCE#' and ">
	<cfset sql=sql & " GEOREFERENCE_PROTOCOL = '#orig.GEOREFERENCE_PROTOCOL#' and ">
	<cfset sql=sql & " LOCALITY_NAME = '#orig.LOCALITY_NAME#' and ">
		
	
	<cfquery name="dups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>
	
	<cfdump var=#dups#>

</cfoutput>
<cfinclude template="includes/_footer.cfm">