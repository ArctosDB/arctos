<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Duplicate Locality Merger Widget">
<cfoutput>
	<cfif action is "nothing">
		<cfif not isdefined("q_spec_locality")>
			<cfset q_spec_locality='exact'>
		</cfif>
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
					<td>Filter for Duplicates</td>
					<td>Set criteria this row</td>
					<td>
						<select name="q_spec_locality">
							<option <cfif q_spec_locality is 'exact'> selected="selected"</cfif>value="exact">exact</option>
						</select>
					</td>
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
					GEOG_AUTH_REC_ID=#orig.GEOG_AUTH_REC_ID# and ">
			<cfif q_spec_locality is "exact">
				<cfif len(orig.SPEC_LOCALITY) gt 0>
					<cfset sql=sql & " SPEC_LOCALITY='#escapeQuotes(orig.SPEC_LOCALITY)#' and ">
				<cfelse>
					<cfset sql=sql & " SPEC_LOCALITY is null and ">
				</cfif>
			</cfif>		
			
			
			
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
			
			<cfif len(orig.ORIG_ELEV_UNITS) gt 0>
				<cfset sql=sql & " ORIG_ELEV_UNITS='#orig.ORIG_ELEV_UNITS#' and ">
			<cfelse>
				<cfset sql=sql & " ORIG_ELEV_UNITS is null and ">
			</cfif>
			
				
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
			<cfif len(orig.DEPTH_UNITS) gt 0>
				<cfset sql=sql & " DEPTH_UNITS='#orig.DEPTH_UNITS#' and ">
			<cfelse>
				<cfset sql=sql & " DEPTH_UNITS is null and ">
			</cfif>
		
			<cfif len(orig.MAX_ERROR_DISTANCE) gt 0>
				<cfset sql=sql & " MAX_ERROR_DISTANCE=#orig.MAX_ERROR_DISTANCE# and ">
			<cfelse>
				<cfset sql=sql & " MAX_ERROR_DISTANCE is null and ">
			</cfif>
			
			<cfif len(orig.MAX_ERROR_UNITS) gt 0>
				<cfset sql=sql & " MAX_ERROR_UNITS='#orig.MAX_ERROR_UNITS#' and ">
			<cfelse>
				<cfset sql=sql & " MAX_ERROR_UNITS is null and ">
			</cfif>
			<cfif len(orig.DATUM) gt 0>
				<cfset sql=sql & " DATUM='#orig.DATUM#' and ">
			<cfelse>
				<cfset sql=sql & " DATUM is null and ">
			</cfif>
			<cfif len(orig.LOCALITY_REMARKS) gt 0>
				<cfset sql=sql & " LOCALITY_REMARKS='#orig.LOCALITY_REMARKS#' and ">
			<cfelse>
				<cfset sql=sql & " LOCALITY_REMARKS is null and ">
			</cfif>
			<cfif len(orig.GEOREFERENCE_SOURCE) gt 0>
				<cfset sql=sql & " GEOREFERENCE_SOURCE='#orig.GEOREFERENCE_SOURCE#' and ">
			<cfelse>
				<cfset sql=sql & " GEOREFERENCE_SOURCE is null and ">
			</cfif>
			<cfif len(orig.GEOREFERENCE_PROTOCOL) gt 0>
				<cfset sql=sql & " GEOREFERENCE_PROTOCOL='#orig.GEOREFERENCE_PROTOCOL#' and ">
			<cfelse>
				<cfset sql=sql & " GEOREFERENCE_PROTOCOL is null and ">
			</cfif>
			<cfif len(orig.LOCALITY_NAME) gt 0>
				<cfset sql=sql & " LOCALITY_NAME='#orig.LOCALITY_NAME#' ">
			<cfelse>
				<cfset sql=sql & " LOCALITY_NAME is null ">
			</cfif>
			<cfquery name="dups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				#preservesinglequotes(sql)# and rownum < 1001
			</cfquery>
			<cfif dups.recordcount is 100>
				This form only returns 1000 records. You may have to delete a few sets.
			</cfif>
			Potential Duplicates
			<script>
				function checkAll() {
					$('input:checkbox[name="deleteLocalityID"]').prop('checked', true);
				}
				function uncheckAll() {
					$('input:checkbox[name="deleteLocalityID"]').prop('checked', false);
				}
			</script>
			<span class="likeLink" onclick="checkAll();">Check All</span>
			<span class="likeLink" onclick="uncheckAll();">UNcheck All</span>
			<form name="d" method="post" action="duplicateLocality.cfm">
				<input type="hidden" name="locality_id" value="#locality_id#">
				<input type="hidden" name="action" value="delete">
				<input type="submit" value="merge checked localities with this locality">
				<table border id="t" class="sortable">
					<tr>
						<th>merge</th>
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
					<cfloop query="dups">
						<tr>
							<td>
								<input type="checkbox" name="deleteLocalityID" value="#LOCALITY_ID#">
							</td>
							<td>#LOCALITY_ID#</td>
							<td>#GEOG_AUTH_REC_ID#</td>
							<td>#SPEC_LOCALITY#</td>
							<td>#DEC_LAT#</td>
							<td>#DEC_LONG#</td>
							<td>#MINIMUM_ELEVATION#</td>
							<td>#MAXIMUM_ELEVATION#</td>
							<td>#ORIG_ELEV_UNITS#</td>
							<td>#MIN_DEPTH#</td>
							<td>#MAX_DEPTH#</td>
							<td>#DEPTH_UNITS#</td>
							<td>#MAX_ERROR_DISTANCE#</td>
							<td>#MAX_ERROR_UNITS#</td>
							<td>#DATUM#</td>
							<td>#LOCALITY_REMARKS#</td>
							<td>#GEOREFERENCE_SOURCE#</td>
							<td>#GEOREFERENCE_PROTOCOL#</td>
							<td>#LOCALITY_NAME#</td>
						</tr>
					</cfloop>
				</table>
			</form>
	</cfif>
	<cfif action is "delete">
		<cftransaction>
			<cfquery name="cleardups" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update collecting_event set locality_id=#locality_id# where locality_id in (#deleteLocalityID#)
			</cfquery>
			<cfquery name="cleardupsMedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update media_relations set related_primary_key=#locality_id# where 
				media_relationship like '% locality' and 
				related_primary_key in (#deleteLocalityID#)
			</cfquery>
			<cfquery name="cleardupsBL" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update bulkloader set locality_id=#locality_id# where locality_id in (#deleteLocalityID#)
			</cfquery>
			<cfquery name="delete" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from locality where locality_id in (#deleteLocalityID#)
			</cfquery>
		</cftransaction>
		<cflocation url="duplicateLocality.cfm?locality_id=#locality_id#" addtoken="false">
		
	</cfif>
</cfoutput>
<cfinclude template="includes/_footer.cfm">