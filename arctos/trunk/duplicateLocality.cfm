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
	</table>

</cfoutput>
<cfinclude template="includes/_footer.cfm">