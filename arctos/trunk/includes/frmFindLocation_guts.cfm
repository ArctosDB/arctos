<style>
	.noShow {
		display:none;
		}
	.locGroup {
		border: 1px dashed green;
		padding:2px;
		margin:5px;
		}
	.vert {

/* Safari */
-webkit-transform: rotate(-90deg);

/* Firefox */
-moz-transform: rotate(-90deg);

/* IE */
-ms-transform: rotate(-90deg);

/* Opera */
-o-transform: rotate(-90deg);

/* Internet Explorer */
filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);

}
</style>
<script language="javascript" type="text/javascript">
	function convertToDD(format){
		if (format=='dms'){
			var lat_deg=$("#lat_deg").val();
			if(lat_deg==''){
				lat_deg=0;
			}
			var lat_min=$("#lat_min").val();
			if(lat_min==''){
				lat_min=0;
			}
			var lat_sec=$("#lat_sec").val();
			if(lat_sec==''){
				lat_sec=0;
			}
			var dms_latdir=$("#dms_latdir").val();
			var long_deg=$("#long_deg").val();
			if(long_deg==''){
				long_deg=0;
			}
			var long_min=$("#long_min").val();
			if(long_min==''){
				long_min=0;
			}
			var long_sec=$("#long_sec").val();
			if(long_sec==''){
				long_sec=0;
			}
			var dms_longdir=$("#dms_longdir").val();

			var dec_lat = parseFloat(lat_deg) + (parseFloat(lat_min) / 60) + (parseFloat(lat_sec) / 3600);
            if (dms_latdir == 'S'){
                dec_lat = dec_lat * -1;
            }
			var dec_long = parseFloat(long_deg) + (parseFloat(long_min) / 60) + (parseFloat(long_sec) / 3600);
             if (dms_longdir == 'W'){
                dec_long = dec_long * -1;
            }
        }
        if (format=='dm'){
			var dec_lat_deg=$("#dec_lat_deg").val();
			if(dec_lat_deg==''){
				dec_lat_deg=0;
			}
			var dec_lat_min=$("#dec_lat_min").val();
			if(dec_lat_min==''){
				dec_lat_min=0;
			}

			var dm_latdir=$("#dm_latdir").val();
			var dec_long_deg=$("#dec_long_deg").val();
			if(dec_long_deg==''){
				dec_long_deg=0;
			}
			var dec_long_min=$("#dec_long_min").val();
			if(dec_long_min==''){
				dec_long_min=0;
			}

			var dm_longdir=$("#dm_longdir").val();

			var dec_lat = parseFloat(dec_lat_deg) + (parseFloat(dec_lat_min) / 60);
            if (dm_latdir == 'S'){
                dec_lat = dec_lat * -1;
            }
			var dec_long = parseFloat(dec_long_deg) + (parseFloat(dec_long_min) / 60);
             if (dm_longdir == 'W'){
                dec_long = dec_long * -1;
            }

		}

            $("#dec_lat").val(dec_lat);
            $("#dec_long").val(dec_long);

	}




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
	<cfquery name="ctDatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
		select datum from ctDatum order by datum
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
		        					<label for="datum">Datum</label>
		                	<select name="datum" id="datum">
		                			                							<option value=""></option>
		                			                							<cfloop query="ctdatum">
		                			                								<option value = "#ctdatum.datum#">#ctdatum.datum#</option>
		                			                							</cfloop>
		                			                						</select>
		        				</td>
		        			</tr>



			<tr>
				<td>
					<div style="border:1px solid black;">
					<table>
						<tr>
							<td>
		                		<label for="dec_lat">DecLat</label>
		                		<input type="text" name="dec_lat" id="dec_lat">
							</td>
							<td>
		                		<label for="dec_long">DecLong</label>
		                		<input type="text" name="dec_long" id="dec_long">
							</td>
							<td>
		                		<label for="search_precision">Search Precision</label>
   		                		<select name="search_precision" id="search_precision">
   									<option value="0">round to integer</option>
   									<option value="2">2 (NN.nn)</option>
		                			<option value="4">4 (NN.nnnn)</option>
		                			<option value="exact">exact match only</option>
   								</select>
							</td>
						</tr>
					</table>
		            </div>
		            <label for="dmsdiv">Convert to decimal degrees (not included in search)</label>
		            <div id="dmsdiv" style="border:1px solid black;padding-left:1.5em;background-color:LightGray;">
					<table>
						<tr>
							<td>
		                		<label for="lat_deg">LatDeg</label>
		                		<input type="text" name="lat_deg" id="lat_deg" size="2">
							</td>
							<td>
		                		<label for="lat_min">LatMin</label>
		                		<input type="text" name="lat_min" id="lat_min" size="2">
							</td>
							<td>
		                		<label for="lat_sec">LatDec</label>
		                		<input type="text" name="lat_sec" id="lat_sec" size="2">
							</td>
							<td>
		                		<label for="lat_dir">LatDir</label>
		                		<select name="dms_latdir" id="dms_latdir">
									<option value="N">N</option>
									<option value="S">S</option>
								</select>
							</td>
							<td rowspan="2" style="vertical-align: middle;">
								<button class="lnkBtn" onclick="convertToDD('dms');">convert to decimal</span>
							</td>
						</tr>
               			<tr>
							<td>
		                		<label for="long_deg">LongDeg</label>
		                		<input type="text" name="long_deg" id="long_deg" size="2">
							</td>
							<td>
		                		<label for="long_min">LongMin</label>
		                		<input type="text" name="long_min" id="long_min" size="2">
							</td>
							<td>
		                		<label for="long_sec">LongSec</label>
		                		<input type="text" name="long_sec" id="long_sec" size="2">
							</td>
							<td>
		                		<label for="dms_longdir">LongDir</label>
		                		<select name="dms_longdir" id="dms_longdir">
									<option value="E">E</option>
									<option value="W">W</option>
								</select>
							</td>

						</tr>
					</table>
				            </div>
				            <div style="border:1px solid black;padding-left:1.5em;background-color:LightGray;">
                	<table>
						<tr>
							<td>
		                		<label for="dec_lat_deg">LatDeg</label>
		                		<input type="text" name="dec_lat_deg" id="dec_lat_deg" size="2">
							</td>
							<td>
		                		<label for="dec_lat_min">DecLatMin</label>
		                		<input type="text" name="dec_lat_min" id="dec_lat_min" size="4">
							</td>
							<td>
		                		<label for="dm_latdir">LatDir</label>
		                		<select name="dm_latdir" id="dm_latdir">
									<option value="N">N</option>
									<option value="S">S</option>
								</select>
							</td><td rowspan="2" style="vertical-align: middle;">
		                			        <button class="lnkBtn" onclick="convertToDD('dm');">convert to decimal</span>
	                			                								</td>
						</tr>
               			<tr>
							<td>
		                		<label for="dec_long_deg">LongDeg</label>
		                		<input type="text" name="dec_long_deg" id="dec_long_deg" size="2">
							</td>
							<td>
		                		<label for="dec_long_min">DecLongMin</label>
		                		<input type="text" name="dec_long_min" id="dec_long_min" size="2">
							</td>
							<td>
		                		<label for="dm_longdir">LongDir</label>
		                		<select name="dm_longdir" id="dm_longdir">
									<option value="E">E</option>
									<option value="W">W</option>
								</select>
							</td>
						</tr>
					</table>
		                	 </div>
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
					<label for="collecting_event_name">CollectingEventName</label>
					<input type="text" name="collecting_event_name" id="collecting_event_name" size="50">
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