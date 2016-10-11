<style>
	.noShow { display:none; } .locGroup { border: 1px dashed green; padding:2px; margin:5px; } .vert { /* Safari */ -webkit-transform: rotate(-90deg); /* Firefox */ -moz-transform: rotate(-90deg); /* IE */ -ms-transform: rotate(-90deg); /* Opera */ -o-transform: rotate(-90deg); /* Internet Explorer */ filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3); }
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
	function clearGeogForm(){

		console.log('i am clearGeogForm');

		// this page is only guts; we don't have the code which establishes the form so...
		// we need to get the parent of the clear button
		var theForm=$('#geoResetBtn').closest('form');

		console.log(theForm);

		 $("theForm input[type=text]").each(function() {
            console.log(this.id);
        });
       // return false;


	//	$('#geoResetBtn').closest('form');


	}
</script>
<cfoutput>
	<cfif not isdefined("showLocality")>
		<cfset showLocality=0 />
	</cfif>
	<cfif not isdefined("showEvent")>
		<cfset showEvent=0 />
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
		select guid_prefix,collection_id from collection order by guid_prefix
	</cfquery>



	<cfparam name="higher_geog" default="">
	<cfparam name="continent_ocean" default="">
	<cfparam name="country" default="">
	<cfparam name="state_prov" default="">
	<cfparam name="county" default="">
	<cfparam name="quad" default="">
	<cfparam name="feature" default="">
	<cfparam name="island_group" default="">
	<cfparam name="island" default="">
	<cfparam name="sea" default="">
	<cfparam name="geog_auth_rec_id" default="">
	<cfparam name="hasGeoWKT" default="">
	<cfparam name="locality_name" default="">
	<cfparam name="spec_locality" default="">
	<cfparam name="collnOper" default="">
	<cfparam name="collection_id" default="">
	<cfparam name="MinElevOper" default="">
	<cfparam name="minimum_elevation" default="">
	<cfparam name="MaxElevOper" default="">
	<cfparam name="maximum_elevation" default="">
	<cfparam name="orig_elev_units" default="">
	<cfparam name="locality_remarks" default="">
	<cfparam name="locality_id" default="">
	<cfparam name="datum" default="">
	<cfparam name="max_err_m" default="">
	<cfparam name="coord_serv_diff" default="">
	<cfparam name="dec_lat" default="">
	<cfparam name="dec_long" default="">
	<cfparam name="search_precision" default="2">
	<cfparam name="geology_attribute" default="">
	<cfparam name="geo_att_value" default="">
	<cfparam name="geology_attribute_hier" default="0">
	<cfparam name="verbatim_locality" default="">
	<cfparam name="begDateOper" default="">
	<cfparam name="began_date" default="">
	<cfparam name="endDateOper" default="">
	<cfparam name="ended_date" default="">
	<cfparam name="verbatim_date" default="">
	<cfparam name="collecting_event_name" default="">
	<cfparam name="coll_event_remarks" default="">
	<cfparam name="collecting_event_id" default="">


	<table  cellpadding="0" cellspacign="0">
		<tr>
			<td>
				<div class="locGroup">
					<span id="geogDetailCtl" class="infoLink" onclick="toggleGeogDetail(1)";>Show More Options</span>
					<table cellpadding="0" cellspacign="0">
						<tr>
							<td>
								<label for="higher_geog">Higher Geog</label>
								<input type="text" name="higher_geog" id="higher_geog" size="50" value="#higher_geog#">
							</td>
						</tr>
						<tr>
							<td>
								<cfif not isdefined("any_geog")>
									<cfset any_geog="">
								</cfif>
								<label for="any_geog">Any Geog</label>
								<input type="text" name="any_geog" id="any_geog" size="50" value="#any_geog#">
							</td>
						</tr>
					</table>
					<div id="geogDetail" class="noShow">
						<table cellpadding="0" cellspacign="0">
							<tr>
								<td>
									<label for="continent_ocean">Continent or Ocean</label>
									<input type="text" name="continent_ocean" id="continent_ocean" size="50" value="#continent_ocean#">
								</td>
							</tr>
							<tr>
								<td>
									<label for="country">Country</label>
									<input type="text" name="country" id="country" size="50" value="#country#">
								</td>
							</tr>
							<tr>
								<td>
									<label for="state_prov">State or Province</label>
									<input type="text" name="state_prov" id="state_prov" size="50" value="#state_prov#">
								</td>
							</tr>
							<tr>
								<td>
									<label for="county">County</label>
									<input type="text" name="county" id="county" size="50" value="#county#">
								</td>
							</tr>
							<tr>
								<td>
									<label for="quad">Quad</label>
									<input type="text" name="quad" id="quad" size="50" value="#quad#">
								</td>
							</tr>
							<tr>
								<td>
									<cfset x=feature>
									<label for="feature">Feature</label>
									<select name="feature" id="feature">
										<option value=""></option>
										<cfloop query="ctFeature">
											<option <cfif x is ctFeature.feature> selected="selected" </cfif> value = "#ctFeature.feature#">#ctFeature.feature#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td>
									<cfset x=island_group>
									<label for="island_group">Island Group</label>
									<select name="island_group" id="island_group">
										<option value=""></option>
										<cfloop query="ctIslandGroup">
											<option <cfif x is ctIslandGroup.island_group> selected="selected" </cfif> value = "#ctIslandGroup.island_group#">#ctIslandGroup.island_group#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td>
									<label for="island">Island</label>
									<input type="text" name="island" id="island" size="50" value="#island#">
								</td>
							</tr>
							<tr>
								<td>
									<label for="sea">Sea</label>
									<input type="text" name="sea" id="sea" size="50" value="#sea#">
								</td>
							</tr>
							<tr>
								<td>
									<label for="geog_auth_rec_id">Geog Auth Rec ID</label>
									<input type="text" name="geog_auth_rec_id" id="geog_auth_rec_id" value="#geog_auth_rec_id#">
								</td>
							</tr>
							<tr>
								<td>
									<label for="hasGeoWKT">hasGeoWKT</label>
									<select name="hasGeoWKT" id="hasGeoWKT">
										<option  value=""></option>
										<option <cfif hasGeoWKT is "1">selected="selected"</cfif> value="1">yes</option>
										<option <cfif hasGeoWKT is "0">selected="selected"</cfif> value="0">no</option>
									</select>
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
									<label for="locality_name">Locality Nickname</label>
									<input type="text" name="locality_name" id="locality_name" size="50" value="#locality_name#">
								</td>
							</tr>
							<tr>
								<td colspan="2">
									<label for="spec_locality">Specific Locality</label>
									<input type="text" name="spec_locality" id="spec_locality" size="50" value="#spec_locality#">
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
											<option <cfif collnOper is "usedOnlyBy"> selected="selected" </cfif> value="usedOnlyBy">used only by</option>
											<option <cfif collnOper is "usedBy"> selected="selected" </cfif>value="usedBy">used by</option>
											<option <cfif collnOper is "notUsedBy"> selected="selected" </cfif> value="notUsedBy">not used by</option>
										</select>
										<cfset x=island_group>
										<select name="collection_id" id="collection_id" size="1">
											<option value=""></option>
											<cfloop query="ctcollection">
												<option <cfif x is ctcollection.collection_id> selected="selected" </cfif> value="#ctcollection.collection_id#">#ctcollection.guid_prefix#</option>
											</cfloop>
										</select>
									</td>
								</tr>
								<tr>
									<td>
										<label for="MinElevOper">Minimum Elevation</label>
										<select name="MinElevOper" id="MinElevOper" size="1">
											<option <cfif MinElevOper is "="> selected="selected" </cfif> value="=">is</option>
											<option <cfif MinElevOper is "<>"> selected="selected" </cfif> value="<>">is not</option>
											<option <cfif MinElevOper is "></cfif>"> selected="selected" </cfif> value=">">more than</option>
											<option <cfif MinElevOper is "<"> selected="selected" </cfif> value="<">less than</option>
										</select>
										<input type="text" name="minimum_elevation" id="minimum_elevation" value="#minimum_elevation#">
									</td>
								</tr>
								<tr>
									<td>
										<label for="MaxElevOper">Maximum Elevation</label>
										<select name="MaxElevOper" id="MaxElevOper" size="1">
											<option <cfif MaxElevOper is "="> selected="selected" </cfif> value="=">is</option>
											<option <cfif MaxElevOper is "<>"> selected="selected" </cfif> value="<>">is not</option>
											<option <cfif MaxElevOper is "></cfif>"> selected="selected" </cfif> value=">">more than</option>
											<option <cfif MaxElevOper is "<"> selected="selected" </cfif> value="<">less than</option>
										</select>
										<input type="text" name="maximum_elevation" id="maximum_elevation" value="#maximum_elevation#">
									</td>
								</tr>
								<tr>
									<td>
										<cfset x=orig_elev_units>
										<label for="orig_elev_units">Elevation Units</label>
										<select name="orig_elev_units" id="orig_elev_units" size="1">
											<option value=""></option>
											<cfloop query="ctElevUnit">
												<option <cfif x is ctElevUnit.orig_elev_units> selected="selected" </cfif> value="#ctElevUnit.orig_elev_units#">#ctElevUnit.orig_elev_units#</option>
											</cfloop>
										</select>
									</td>
								</tr>
								<tr>
									<td>
										<label for="locality_remarks">Locality Remarks</label>
										<input type="text" name="locality_remarks" id="locality_remarks" size="50" value="#locality_remarks#">
									</td>
								</tr>
								<tr>
									<td>
										<label for="locality_id">Locality ID</label>
										<input type="text" name="locality_id" id="locality_id" value="#locality_id#">
									</td>
								</tr>
								<tr>
									<td>
										<cfset x=datum>
										<label for="datum">Datum</label>
										<select name="datum" id="datum">
											<option value=""></option>
											<cfloop query="ctdatum">
												<option <cfif x is ctdatum.datum> selected="selected" </cfif> value = "#ctdatum.datum#">#ctdatum.datum#</option>
											</cfloop>
										</select>
									</td>
								</tr>
								<tr>
									<td>
										<label title="max_error_distance in meters"
											for="max_err_m">Error (m) [format: &lt;INT,&gt;INT,=INT]</label>
										<input type="text" name="max_err_m" id="max_err_m" value="#max_err_m#">
									</td>
								</tr>
								<tr>
									<td>
										<label title="distance in KM between asserted and suggested coordinates" for="coord_serv_diff">
											Coord/Service Error (km) [format: &lt;INT,&gt;INT,=INT]
										</label>
										<input type="text" name="coord_serv_diff" id="coord_serv_diff" value="#coord_serv_diff#">
									</td>
								</tr>
								<tr>
									<td>
										<div style="border:1px solid black;">
											<table>
												<tr>
													<td>
														<label for="dec_lat">DecLat (negative is south)</label>
														<input type="text" name="dec_lat" id="dec_lat" value="#dec_lat#">
													</td>
													<td>
														<label for="dec_long">DecLong (negative is west)</label>
														<input type="text" name="dec_long" id="dec_long" value="#dec_long#">
													</td>
													<td>
														<label for="search_precision">Search Precision</label>
														<select name="search_precision" id="search_precision">
															<option <cfif search_precision is "0"> selected="selected" </cfif> value="0">round to integer</option>
															<option <cfif search_precision is "2"> selected="selected" </cfif> value="2">2 (NN.nn)</option>
															<option <cfif search_precision is "4"> selected="selected" </cfif> value="4">4 (NN.nnnn)</option>
															<option <cfif search_precision is "exact"> selected="selected" </cfif> value="exact">exact match only</option>
														</select>
													</td>
												</tr>
											</table>
										</div>
										<label for="dmsdiv">Convert to decimal degrees</label>
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
														<button class="lnkBtn" onclick="convertToDD('dms');">
														convert to decimal</span>
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
													</td>
													<td rowspan="2" style="vertical-align: middle;">
														<button class="lnkBtn" onclick="convertToDD('dm');">
														convert to decimal</span>
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
											<tr>
												<td>
													<cfset x=geology_attribute>
													<label for="geology_attribute">Geology Attribute</label>
													<select name="geology_attribute" id="geology_attribute">
														<option value="">Anything</option>
														<cfloop query="ctgeology_attribute">
															<option <cfif x is ctgeology_attribute.geology_attribute> selected="selected" </cfif> value = "#ctgeology_attribute.geology_attribute#">#ctgeology_attribute.geology_attribute#</option>
														</cfloop>
													</select>
												</td>
												<td>
													<label for="geo_att_value">Attribute Value</label>
													<input type="text" name="geo_att_value"  value="#geo_att_value#">
												</td>
												<td>
													<label for="geology_attribute_hier">Traverse Hierarchies?</label>
													<select name="geology_attribute_hier" id="geology_attribute_hier">
														<option  <cfif geology_attribute_hier is "0"> selected="selected" </cfif> value="0">No</option>
														<option  <cfif geology_attribute_hier is "0"> selected="selected" </cfif> value="1">Yes</option>
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
									<input type="text" name="verbatim_locality" id="verbatim_locality" size="50" value="#verbatim_locality#">
								</td>
							</tr>
							<tr>
								<td>
									<label for="begDateOper">Began Date</label>
									<select name="begDateOper" id="begDateOper" size="1">
										<option <cfif begDateOper is "="> selected="selected" </cfif> value="=">is</option>
										<option <cfif begDateOper is "<"> selected="selected" </cfif> value="<">before</option>
										<option <cfif begDateOper is ">"> selected="selected" </cfif> value=">">after</option>
									</select>
									<input type="text" name="began_date" id="began_date" value="#began_date#">
								</td>
							</tr>
							<tr>
								<td>
									<label for="endDateOper">Ended Date</label>
									<select name="endDateOper" id="endDateOper" size="1">
										<option <cfif endDateOper is "="> selected="selected" </cfif> value="=">is</option>
										<option <cfif endDateOper is "<"> selected="selected" </cfif> value="<">before</option>
										<option <cfif endDateOper is ">"> selected="selected" </cfif> value=">">after</option>
									</select>
									<input type="text" name="ended_date" id="ended_date" value="#ended_date#">
								</td>
							</tr>
						</table>
						<div id="eventDetail" class="noShow">
							<table cellpadding="0" cellspacign="0">
								<tr>
									<td>
										<label for="verbatim_date">Verbatim Date</label>
										<input type="text" name="verbatim_date" id="verbatim_date" size="50" value="#verbatim_date#">
									</td>
								</tr>
								<tr>
									<td>
										<label for="collecting_event_name">CollectingEventNickname</label>
										<input type="text" name="collecting_event_name" id="collecting_event_name" size="50" value="#collecting_event_name#">
									</td>
								</tr>
								<tr>
									<td>
										<label for="coll_event_remarks">Collecting Event Remarks</label>
										<input type="text" name="coll_event_remarks" id="coll_event_remarks" size="50" value="#coll_event_remarks#">
									</td>
								</tr>
								<tr>
									<td>
										<label for="collecting_event_id">Collecting Event ID</label>
										<input type="text" name="collecting_event_id" id="collecting_event_id" value="#collecting_event_id#">
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
							<input type="button" id="geoResetBtn" onclick="clearGeogForm()"
								value="Clear Form"
								class="qutBtn">
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<cfif isdefined("session.locSrchPrefs") and len(session.locSrchPrefs) gt 0>
		<cfloop list="#session.locSrchPrefs#" index="i">
			<cfset r='toggle' & i />
			<script type="text/javascript" language="javascript">#r#(1);</script>
		</cfloop>
	</cfif>
</cfoutput>
