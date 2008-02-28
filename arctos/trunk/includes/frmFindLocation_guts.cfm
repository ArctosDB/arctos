<!---
	Search form for all location "stuff"
	
	Need from caller, all in 1 or 0:
	geogDetail
	showLocality
	localityDetail
	showEvent
--->
<cfif not isdefined("geogDetail")>
	<cfset geogDetail=0>
</cfif>
<cfif not isdefined("showLocality")>
	<cfset showLocality=0>
</cfif>
<cfif not isdefined("localityDetail")>
	<cfset localityDetail=0>
</cfif>
<cfif not isdefined("showEvent")>
	<cfset showEvent=0>
</cfif>
<cfif not isdefined("georefDetail")>
	<cfset georefDetail=0>
</cfif>
<cfif not isdefined("eventDetail")>
	<cfset eventDetail=0>
</cfif>
<cfquery name="ctElevUnit" datasource="#Application.web_user#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select orig_elev_units from ctorig_elev_units order by orig_elev_units
</cfquery>
<cfquery name="ctFeature" datasource="#Application.web_user#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select distinct(feature) from ctfeature order by feature
</cfquery>

<cfquery name="ctIslandGroup" datasource="#Application.web_user#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select island_group from ctisland_group order by island_group
</cfquery>
<cfquery name="ctCollectingSource" datasource="#Application.web_user#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select collecting_source from ctcollecting_source order by collecting_source
</cfquery>
<cfquery name="ctVerificationStatus" datasource="#Application.web_user#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select VerificationStatus from ctVerificationStatus order by VerificationStatus
</cfquery>
<cfquery name="ctGeorefMethod" datasource="#Application.web_user#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select georefMethod from ctgeorefmethod order by georefMethod
</cfquery>
<table cellpadding="0" cellspacign="0">
	<cfif #geogDetail# is 1>
		<tr>
			<td>
				<label for="continent_ocean">Continent or Ocean</label>
				<input type="text" name="continent_ocean" id="continent_ocean" size="50">
			</td>
		</tr>
		<tr>
			<td>
				<label for="country">Country</label>
				<input type="text" name="country" id="country" size="50">
			</td>
		</tr>
		<tr>
			<td>
				<label for="state_prov">State or Province</label>
				<input type="text" name="state_prov" id="state_prov" size="50">
			</td>
		</tr>
		<tr>
			<td>
				<label for="county">County</label>
				<input type="text" name="county" id="county" size="50">
			</td>
		</tr>
		<tr>
			<td>
				<label for="quad">Quad</label>
				<input type="text" name="quad" id="quad" size="50">
			</td>
		</tr>
		<tr>
			<td>
				<label for="feature">Feature</label>
				<select name="feature" id="feature">
					<option value=""></option>
					<cfloop query="ctFeature">
						<option value = "#ctFeature.feature#">#ctFeature.feature#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<label for="island_group">Island Group</label>
				<select name="island_group" id="island_group">
					<option value=""></option>
					<cfloop query="ctIslandGroup">
						<option value = "#ctIslandGroup.island_group#">#ctIslandGroup.island_group#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<label for="island">Island</label>
				<input type="text" name="island" id="island" size="50">
			</td>
		</tr>
		<tr>
			<td>
				<label for="sea">Sea</label>
				<input type="text" name="sea" id="sea" size="50">
			</td>
		</tr>
	<cfelse>
		<tr>
			<td>
				<label for="higher_geog">Higher Geog</label>
				<input type="text" name="sea" id="higher_geog" size="50">
			</td>
		</tr>	
	</cfif>
	
	<!----------------------------------------------- locality -------------------------------->
	<cfif #showLocality# is 1>
		<tr>
			<td colspan="2">
				<label for="spec_locality">Specific Locality</label>
				<input type="text" name="spec_locality" id="spec_locality" size="50">
			</td>
		</tr>
		<cfif #localityDetail# is 1>
			<tr>
				<td>
					<label for="MinElevOper">Minimum Elevation</label>
					<select name="MinElevOper" id="MinElevOper" size="1">
		            	<option value="=">is</option>
		                <option value="<>">is not</option>
		                <option value=">">more than</option>
		                <option value="<">less than</option>
		             </select> 
					<input type="text" name="minimum_elevation" id="minimum_elevation">
				</td>
			</tr>
			<tr>
				<td>
					<label for="MaxElevOper">Maximum Elevation</label>
					<select name="MaxElevOper" id="MaxElevOper" size="1">
		            	<option value="=">is</option>
		                <option value="<>">is not</option>
		                <option value=">">more than</option>
		                <option value="<">less than</option>
		            </select>
					<input type="text" name="maximum_elevation" id="maximum_elevation">
				</td>
			</tr>
			<tr>
				<td>
					<label for="orig_elev_units">Elevation Units</label>
					<select name="orig_elev_units" id="orig_elev_units" size="1">
		            	<option value=""></option>
		                <cfloop query="ctElevUnit">
		                	<option value="#ctElevUnit.orig_elev_units#">#ctElevUnit.orig_elev_units#</option>
		                </cfloop>
		           	</select>
				</td>
			</tr>
			<tr>
				<td>
					<label for="locality_remarks">Locality Remarks</label>
					<input type="text" name="locality_remarks" id="locality_remarks" size="50">
				</td>
			</tr>
		</cfif>
		<cfif #georefDetail# is 1>
			<tr>
				<td>
					<label for="findNoGeoRef">No Georeferences</label>
					<input type="checkbox" name="findNoGeoRef" id="findNoGeoRef">
				</td>
			</tr>
			<tr>
				<td>
					<label for="findNoAccGeoRef">No Accepted Georeferences</label>
					<input type="checkbox" name="findNoAccGeoRef" id="findNoAccGeoRef">
				</td>
			</tr>
			<tr>
				<td>
					<label for="isIncomplete">isIncomplete</label>
					<input type="checkbox" name="isIncomplete" id="isIncomplete">
				</td>
			</tr>
			<tr>
				<td>
					<label for="NoGeorefBecause">NoGeorefBecause</label>
					<input type="text" name="NoGeorefBecause" size="50" id="NoGeorefBecause">
				</td>
			</tr>
			<tr>
				<td>
					<label for="nullNoGeorefBecause">NULL NoGeorefBecause</label>
					<input type="checkbox" name="nullNoGeorefBecause" id="nullNoGeorefBecause">
				</td>
			</tr>
			<tr>
				<td>
					<label for="VerificationStatus">VerificationStatus</label>
					<select name="VerificationStatus" id="VerificationStatus" size="1">
						<option value=""></option>
						<cfloop query="ctVerificationStatus">
							<option value="#VerificationStatus#">#VerificationStatus#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td>
					<label for="GeorefMethod">GeorefMethod</label>
					<select name="GeorefMethod" id="GeorefMethod" size="1">
						<option value=""></option>
						<cfloop query="ctGeorefMethod">
							<option value="#GeorefMethod#">#GeorefMethod#</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</cfif>
		
	</cfif>
	<!--------------------------------------- event ----------------------------------------------------------->
	<cfif #showEvent# is 1>	
		<tr>
			<td>
				<label for="verbatim_locality">Verbatim Locality</label>
				<input type="text" name="verbatim_locality" id="verbatim_locality" size="50">
			</td>
		</tr>
		<tr>
			<td>
				<label for="begDateOper">Began Date</label>
				<select name="begDateOper" id="begDateOper" size="1">
	            	<option value="=">is</option>
	                <option value="<">before</option>
	                <option value=">">after</option>
	            </select> 
				<input type="text" name="began_date" id="began_date">
			</td>
		</tr>
		<tr>
			<td>
				<label for="endDateOper">Ended Date</label>
				<select name="endDateOper" id="endDateOper" size="1">
	            	<option value="=">is</option>
	                <option value="<">before</option>
	                <option value=">">after</option>
	            </select> 
				<input type="text" name="ended_date" id="ended_date">
			</td>
		</tr>
		<cfif #eventDetail# is 1>
			<tr>
				<td>
					<label for="verbatim_date">Verbatim Date</label>
					<input type="text" name="verbatim_date" id="verbatim_date" size="50">
				</td>
			</tr>
			<tr>
				<td>
					<label for="coll_event_remarks">Collecting Event Remarks</label>
					<input type="text" name="coll_event_remarks" id="coll_event_remarks" size="50">
				</td>
			</tr>
			<tr>
				<td>
					<label for="collecting_source">Collecting Source</label>
					<select name="collecting_source" id="collecting_source" size="1">
		            	<option value=""></option>
		                <cfloop query="ctCollectingSource">
		                	<option value="#ctCollectingSource.collecting_source#">#ctCollectingSource.collecting_source#</option>
		                </cfloop>
		           	</select>
				</td>
			</tr>
			<tr>
				<td>
					<label for="collecting_method">Collecting Method</label>
					<input type="text" name="collecting_method" id="collecting_method" size="50">
				</td>
			</tr>
			<tr>
				<td>
					<label for="habitat_desc">Habitat</label>
					<input type="text" name="habitat_desc" id="habitat_desc" size="50">
				</td>
			</tr>
		</cfif>
	</cfif>
	<tr>
		<td align="center">
			<input type="submit" 
				value="Find Matches" 
				class="schBtn"
				onmouseover="this.className='schBtn btnhov'" 
				onmouseout="this.className='schBtn'">
           <input type="reset"
				value="Clear Form"
				class="qutBtn"
				onmouseover="this.className='qutBtn btnhov'"
				onmouseout="this.className='qutBtn'">
		</td>
	</tr>
</table>