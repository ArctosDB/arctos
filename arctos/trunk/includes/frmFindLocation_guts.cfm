<style>
	.noShow {
		display:none;
		}
	.locGroup {
		border: 1px dashed green;
		padding:2px;
		margin:5px;
		}
</style>
<script language="javascript" type="text/javascript">
	function nada(){}
	function toggleGeogDetail(onOff) {
		if (onOff==0) {
			$("#geogDetail").hide();
			$("#geogDetailCtl").attr('onCLick','toggleGeogDetail(1)').html('Show More Options');	
		} else {
			$("#geogDetail").show();
			$("#geogDetailCtl").attr('onCLick','toggleGeogDetail(0)').html('Show Fewer Options');
		}
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "saveLocSrchPref",
				id : 'GeogDetail',
				onOff : onOff,
				returnformat : "json",
				queryformat : 'column'
			},
			nada
		);
	}
	function toggleLocDetail(onOff) {
		if (onOff==0) {
			$("#locDetail").hide();
			$("#locDetailCtl").attr('onCLick','toggleLocDetail(1)').html('Show More Options');
		} else {
			$("#locDetail").show();
			$("#locDetailCtl").attr('onCLick','toggleLocDetail(0)').html('Show Fewer Options');
		}
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "saveLocSrchPref",
				id : 'LocDetail',
				onOff : onOff,
				returnformat : "json",
				queryformat : 'column'
			},
			nada
		);
	}
	/*
	function toggleGeorefDetail(onOff) {
		if (onOff==0) {
			$("#georefDetail").hide();
			$("#georefDetailCtl").attr('onCLick','toggleGeorefDetail(1)').html('Show More Options');
		} else {
			$("#georefDetail").show();
			$("#georefDetailCtl").attr('onCLick','toggleGeorefDetail(0)').html('Show Fewer Options');
		}
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "saveLocSrchPref",
				id : 'GeorefDetail',
				onOff : onOff,
				returnformat : "json",
				queryformat : 'column'
			},
			nada
		);
	}
	*/
	function toggleEventDetail(onOff) {
		if (onOff==0) {
			$("#eventDetail").hide();
			$("#eventDetailCtl").attr('onCLick','toggleEventDetail(1)').html('Show More Options');
		} else {
			$("#eventDetail").show();
			$("#eventDetailCtl").attr('onCLick','toggleEventDetail(0)').html('Show Fewer Options');
		}
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "saveLocSrchPref",
				id : 'EventDetail',
				onOff : onOff,
				returnformat : "json",
				queryformat : 'column'
			},
			nada
		);
	}	
</script>
<cfoutput>
<cfif not isdefined("showLocality")>
	<cfset showLocality=0>
</cfif>
<cfif not isdefined("showEvent")>
	<cfset showEvent=0>
</cfif>
<cfquery name="ctElevUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select orig_elev_units from ctorig_elev_units order by orig_elev_units
</cfquery>
<cfquery name="ctFeature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select distinct(feature) from ctfeature order by feature
</cfquery>

<cfquery name="ctIslandGroup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select island_group from ctisland_group order by island_group
</cfquery>
<cfquery name="ctCollectingSource" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select collecting_source from ctcollecting_source order by collecting_source
</cfquery>
<cfquery name="ctVerificationStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select VerificationStatus from ctVerificationStatus order by VerificationStatus
</cfquery>
<cfquery name="ctGeorefMethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select georefMethod from ctgeorefmethod order by georefMethod
</cfquery>
<cfquery name="ctgeology_attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select geology_attribute from ctgeology_attribute order by geology_attribute
</cfquery>
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
	select collection,collection_id from collection order by collection
</cfquery>
<table  cellpadding="0" cellspacign="0"><tr><td>
	<div class="locGroup">
		<span id="geogDetailCtl" class="infoLink" onclick="toggleGeogDetail(1)";>Show More Options</span>
		<table cellpadding="0" cellspacign="0">
		<tr>
			<td>
				<label for="higher_geog">Higher Geog</label>
				<input type="text" name="higher_geog" id="higher_geog" size="50">
			</td>
		</tr>
	</table>	
		<div id="geogDetail" class="noShow">
		<table cellpadding="0" cellspacign="0">
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
			<tr>
				<td>
					<label for="geog_auth_rec_id">Geog Auth Rec ID</label>
					<input type="text" name="geog_auth_rec_id" id="geog_auth_rec_id">
				</td>
			</tr>
		</table>
		</div>
	
</div>

<cfif showLocality is 1>
	<div class="locGroup">
		<span id="locDetailCtl" class="infoLink" onclick="toggleLocDetail(1)";>Show More Options</span>
	<table cellpadding="0" cellspacign="0">
		<tr>
			<td colspan="2">
				<label for="locality_name">Locality Name</label>
				<input type="text" name="locality_name" id="locality_name" size="50">
			</td>
		</tr><tr>
			<td colspan="2">
				<label for="spec_locality">Specific Locality</label>
				<input type="text" name="spec_locality" id="spec_locality" size="50">
			</td>
		</tr>
		</table>
		<div id="locDetail" class="noShow">
		<table cellpadding="0" cellspacign="0">
			<tr>
				<td>
					<label for="collnOper">Collection</label>
					<select name="collnOper" id="collnOper" size="1">
		            	<option value=""></option>
		                <option value="usedOnlyBy">used only by</option>
		                <option value="usedBy">used by</option>
		                <option value="notUsedBy">not used by</option>
		             </select>
		             <select name="collection_id" id="collection_id" size="1">
		            	<option value=""></option>
		                <cfloop query="ctcollection">
		                	<option value="#ctcollection.collection_id#">#ctcollection.collection#</option>
		                </cfloop>
		           	</select>
				</td>
				
			
			</tr>
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
			<tr>
				<td>
					<label for="locality_id">Locality ID</label>
					<input type="text" name="locality_id" id="locality_id">
				</td>
			</tr>
			<tr>
				<td>
					<table cellpadding="0" cellspacing="0">
						<tr><td>
					<label for="geology_attribute">Geology Attribute</label>
					<select name="geology_attribute" id="geology_attribute">
						<option value="">Anything</option>
						<cfloop query="ctgeology_attribute">
							<option value = "#ctgeology_attribute.geology_attribute#">#ctgeology_attribute.geology_attribute#</option>
						</cfloop>
					</select>
						</td>
						
						<td>
							<label for="geo_att_value">Attribute Value</label>
							<input type="text" name="geo_att_value">
						</td>
						<td>
						<label for="geology_attribute_hier">Traverse Hierarchies?</label>
					<select name="geology_attribute_hier" id="geology_attribute_hier">
						<option selected="selected" value="0">No</option>
						<option value="1">Yes</option>
					</select>
						</td>
						</tr>
						
					</table>
				</td>
			</tr>
		</table>
	</div>
	</div>	
</cfif>	
	<!--------------------------------------- event ----------------------------------------------------------->
	<cfif showEvent is 1>	
	<div class="locGroup">
		<span id="eventDetailCtl" class="infoLink" onclick="toggleEventDetail(1)";>Show More Options</span>
	<table cellpadding="0" cellspacign="0">
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
	</table>
		<div id="eventDetail" class="noShow">
			<table cellpadding="0" cellspacign="0">	
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
					<label for="collecting_event_id">Collecting Event ID</label>
					<input type="text" name="collecting_event_id" id="collecting_event_id" >
				</td>
			</tr>
		</table>
		</div>
		</div>
		</cfif>
<table cellpadding="0" cellspacign="0">	
	<tr>
		<td align="center">
			<input type="submit" 
				value="Find Matches" 
				class="schBtn">
           <input type="reset"
				value="Clear Form"
				class="qutBtn">
		</td>
	</tr>
</table>
</td></tr></table>
<cfif isdefined("session.locSrchPrefs") and len(session.locSrchPrefs) gt 0>
	<cfloop list="#session.locSrchPrefs#" index="i">
		<cfset r='toggle' & i>	
		<script type="text/javascript" language="javascript">
			#r#(1);
		</script>
	</cfloop>
</cfif>

</cfoutput>