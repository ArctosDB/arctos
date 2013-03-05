<cfinclude template="includes/_header.cfm">
<cfoutput>
	<script>
		function useGL(glat,glon,gerr){
			$("##MAX_ERROR_DISTANCE").val(gerr);
			$("##MAX_ERROR_UNITS").val('m');
			$("##DATUM").val('World Geodetic System 1984');
			$("##georeference_source").val('GeoLocate');
			$("##georeference_protocol").val('GeoLocate');
			$("##dec_lat").val(glat);
			$("##dec_long").val(glon);
			closeGeoLocate();
		}
	</script>
</cfoutput>

<cfif action is "nothing">
<cfset title="Edit Locality">
<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$("select[id^='geology_attribute_']").each(function(e){
			populateGeology(this.id);
		});
	    $.each($("input[id^='geo_att_determined_date_']"), function() {
			$("#" + this.id).datepicker();
	    });
	    if (window.addEventListener) {
			window.addEventListener("message", getGeolocate, false);
		} else {
			window.attachEvent("onmessage", getGeolocate);
		}
	});
	function geolocate(method) {
		alert('This opens a map. There is a help link at the top. Use it. The save button will create a new determination.');
		var guri='http://www.museum.tulane.edu/geolocate/web/webgeoreflight.aspx?georef=run';
		if (method=='adjust'){
			guri+="&tab=result&points=" + $("#dec_lat").val() + "|" + $("#dec_long").val() + "|||" + $("#error_in_meters").val();
		} else {
			guri+="&state=" + $("#state_prov").val();
			guri+="&country="+$("#country").val();
			guri+="&county="+$("#county").val().replace(" County", "");
			guri+="&locality="+$("#spec_locality").val();
		}
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeGeoLocate("clicked closed")');
		document.body.appendChild(bgDiv);
		var popDiv=document.createElement('div');
		popDiv.id = 'popDiv';
		popDiv.className = 'editAppBox';
		document.body.appendChild(popDiv);
		var cDiv=document.createElement('div');
		cDiv.className = 'fancybox-close';
		cDiv.id='cDiv';
		cDiv.setAttribute('onclick','closeGeoLocate("clicked closed")');
		$("#popDiv").append(cDiv);
		var hDiv=document.createElement('div');
		hDiv.className = 'fancybox-help';
		hDiv.id='hDiv';
		hDiv.innerHTML='<a href="https://arctosdb.wordpress.com/how-to/create/data-entry/geolocate/" target="blank">[ help ]</a>';
		$("#popDiv").append(hDiv);
		$("#popDiv").append('<img src="/images/loadingAnimation.gif" class="centeredImage">');
		var theFrame = document.createElement('iFrame');
		theFrame.id='theFrame';
		theFrame.className = 'editFrame';
		theFrame.src=guri;
		$("#popDiv").append(theFrame);
	}
	function getGeolocate(evt) {
		var message;
		if (evt.origin !== "http://www.museum.tulane.edu") {
	    	alert( "iframe url does not have permision to interact with me" );
	        closeGeoLocate('intruder alert');
	    }
	    else {
	    	var breakdown = evt.data.split("|");
			if (breakdown.length == 4) {
			    var glat=breakdown[0];
			    var glon=breakdown[1];
			    var gerr=breakdown[2];
			    useGL(glat,glon,gerr)
			} else {
				alert( "Whoa - that's not supposed to happen. " +  breakdown.length);
				closeGeoLocate('ERROR - breakdown length');
	 		}
	    }
	}
	function closeGeoLocate(msg) {
		$('#bgDiv').remove();
		$('#bgDiv', window.parent.document).remove();
		$('#popDiv').remove();
		$('#popDiv', window.parent.document).remove();
		$('#cDiv').remove();
		$('#cDiv', window.parent.document).remove();
		$('#theFrame').remove();
		$('#theFrame', window.parent.document).remove();
	}
	function populateGeology(id) {
		if (id=='geology_attribute') {
			var idNum='';
			var thisValue=$("#geology_attribute").val();
			var dataValue=$("#geo_att_value").val();
			var theSelect="geo_att_value";
		} else {
			var idNum=id.replace('geology_attribute_','');
			var thisValue=$("#geology_attribute_" + idNum).val();;
			var dataValue=$("#geo_att_value_" + idNum).val();
			var theSelect="geo_att_value_";
		}
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getGeologyValues",
				attribute : thisValue,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				var s='';
				for (i=0; i<r.ROWCOUNT; ++i) {
					s+='<option value="' + r.DATA.ATTRIBUTE_VALUE[i] + '"';
					if (r.DATA.ATTRIBUTE_VALUE[i]==dataValue) {
						s+=' selected="selected"';
					}
					s+='>' + r.DATA.ATTRIBUTE_VALUE[i] + '</option>';
				}
				$("select#" + theSelect + idNum).html(s);
			}
		);
	}

	function cloneLocality(locality_id) {
		if(confirm('Are you sure you want to create a copy of this locality which you may then edit?')) {
			var rurl='editLocality.cfm?action=clone&locality_id=' + locality_id;
			document.location=rurl;
		}
	}


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

</script>
<cfoutput>
	<cfquery name="locDet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    	select
			locality.locality_id,
			geog_auth_rec.GEOG_AUTH_REC_ID,
			higher_geog,
			state_prov,
			county,
			country,
			spec_locality,
			MIN_DEPTH,
			MAX_DEPTH,
			DEPTH_UNITS,
			LOCALITY_REMARKS,
			MINIMUM_ELEVATION,
			MAXIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			SPEC_LOCALITY,
			DEC_LAT,
			DEC_LONG,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
			to_meters(MAX_ERROR_DISTANCE,MAX_ERROR_UNITS) error_in_meters,
			DATUm,
			georeference_source,
			georeference_protocol,
			locality_name,
			s$elevation,
			s$geography,
			s$dec_lat,
			s$dec_long
		from
			locality,
			geog_auth_rec
		where
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
			locality.locality_id=#locality_id#
	</cfquery>
	<cfif locDet.recordcount is not 1>
		<div class="error">locality not found</div><cfabort>
	</cfif>
	<cfquery name="geolDet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    	select
			*
		from
			geology_attributes,
			preferred_agent_name
		where
			geology_attributes.geo_att_determiner_id = preferred_agent_name.agent_id (+) and
			geology_attributes.locality_id=#locality_id#
	</cfquery>
     <cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select datum from ctdatum order by datum
     </cfquery>
	<cfquery name="ctElevUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select orig_elev_units from ctorig_elev_units order by orig_elev_units
	</cfquery>
	<cfquery name="ctDepthUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select depth_units from ctdepth_units order by depth_units
	</cfquery>
    <cfquery name="cterror" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS order by LAT_LONG_ERROR_UNITS
     </cfquery>
     <cfquery name="ctgeoreference_protocol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select georeference_protocol from ctgeoreference_protocol order by georeference_protocol
	</cfquery>
	<cfquery name="ctgeology_attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select geology_attribute from ctgeology_attribute order by geology_attribute
     </cfquery>
	<cfquery name="ctVerificationStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select VerificationStatus from ctVerificationStatus order by VerificationStatus
	</cfquery>




	<cfinvoke component="component.functions" method="getLocalityContents" returnvariable="contents">
	    <cfinvokeargument name="locality_id" value="#locality_id#">
	</cfinvoke>
	#contents#
	<br>



   	<div style="border:5px solid red; background-color:red;">
   			<br>Red is scary. This form is dangerous. Make sure you know what it's doing before you get all clicky.
   			<cfquery name="vstat" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
   				select
   					verificationstatus,
   					collection,
   					count(*) c
   				from
   					specimen_event,
   					cataloged_item,
   					collection,
					collecting_event
   				where
   					specimen_event.collection_object_id=cataloged_item.collection_object_id and
   					cataloged_item.collection_id=collection.collection_id and
   					specimen_event.collecting_event_id=collecting_event.collecting_event_id and
					collecting_event.locality_id=#locDet.locality_id#
   				group by
   					verificationstatus,
   					collection
   			</cfquery>
   			<label for="dfs">"Your" specimens in this locality:</label>
   			<table id="dfs" border>
   				<tr>
   					<th>Collection</th>
   					<th>VerificationStatus</th>
   					<th>NumberSpecimenEvents</th>
   				</tr>
   				<cfloop query="vstat">
   					<tr>
   						<td>#collection#</td>
   						<td>#verificationstatus#</td>
   						<td>#c#</td>
   					</tr>
   				</cfloop>
   			</table>
   			<form name="x" method="post" action="editLocality.cfm">
   			    <input type="hidden" name="locality_id" value="#locDet.locality_id#">
   		    	<input type="hidden" name="action" value="updateAllVerificationStatus">
   				<label for="VerificationStatus" class="likeLink" onClick="getDocs('lat_long','verification_status')">Update Verification Status for ALL specimen_events in this collecting event to....</label>
   				<select name="VerificationStatus" id="verificationstatus" size="1" class="reqdClr">
   					<option value=""></option>
   					<cfloop query="ctVerificationStatus">
   						<option value="#VerificationStatus#">#VerificationStatus#</option>
   					</cfloop>
   				</select>
   				<br>
   				<input type="submit" class="lnkBtn" value="Update Verification Status for all of your specimen_events in this collecting event to value in pick above">
   			</form>
   		</div>



	<span style="margin:1em;display:inline-block;padding:1em;border:3px solid black;">
	<table width="100%"><tr><td valign="top">
	<p><strong>Locality</strong></p>
	<form name="locality" method="post" action="editLocality.cfm">
        <input type="hidden" id="state_prov" name="state_prov" value="#locDet.state_prov#">
        <input type="hidden" id="country" name="country" value="#locDet.country#">
        <input type="hidden" id="county" name="county" value="#locDet.county#">
		<input type="hidden" name="action" value="saveLocalityEdit">
        <input type="hidden" name="locality_id" value="#locDet.locality_id#">
        <input type="hidden" name="geog_auth_rec_id" value="#locDet.geog_auth_rec_id#">
       	<label for="higher_geog">Higer Geography</label>
		<input type="text" name="higher_geog" id="higher_geog" value="#locDet.higher_geog#" size="120" class="readClr" readonly="yes">
        <input type="button" value="Change" class="picBtn" id="changeGeogButton"
			onclick="GeogPick('geog_auth_rec_id','higher_geog','locality'); return false;">
		<input type="button" value="Edit" class="lnkBtn"
			onClick="document.location='Locality.cfm?action=editGeog&geog_auth_rec_id=#locDet.geog_auth_rec_id#'">
		<label for="spec_locality" class="likeLink" onClick="getDocs('locality','specific_locality')">
			Specific Locality
		</label>
		<input type="text"id="spec_locality" name="spec_locality" value="#stripQuotes(locDet.spec_locality)#" size="120">
		<label for="locality_name" class="likeLink" onClick="getDocs('locality','locality_name')">
			Locality Name
		</label>
		<input type="text" id="locality_name" name="locality_name" value="#stripQuotes(locDet.locality_name)#" size="120">

		<cfif len(locDet.locality_name) is 0>
			<span class="infoLink" onclick="$('##locality_name').val('#CreateUUID()#');">create GUID</span>
		</cfif>
		<table>
			<tr>
				<td>
					<label for="minimum_elevation" onClick="getDocs('locality','elevation')" class="likeLink">
						Min. Elev.
					</label>
					<input type="text" name="minimum_elevation" id="minimum_elevation" value="#locDet.minimum_elevation#" size="3">
				</td>
				<td>TO</td>
				<td>
					<label for="maximum_elevation" onClick="getDocs('locality','elevation')" class="likeLink">
						Max. Elev.
					</label>
					<input type="text" name="maximum_elevation" id="maximum_elevation" value="#locDet.maximum_elevation#" size="3">
				</td>
				<td>
					<label for="orig_elev_units" onClick="getDocs('locality','elevation')" class="likeLink">
						Elev. Unit
					</label>
					<select name="orig_elev_units" size="1" id="orig_elev_units">
						<option value=""></option>
	                    <cfloop query="ctElevUnit">
	                    	<option <cfif ctelevunit.orig_elev_units is locdet.orig_elev_units> selected="selected" </cfif>value="#ctElevUnit.orig_elev_units#">#ctElevUnit.orig_elev_units#</option>
	                    </cfloop>
	                </select>
				</td>
			</tr>
		</table>
		<table>
			<tr>
				<td>
					<label for="min_depth" onClick="getDocs('locality','depth')" class="likeLink">
						Min. Depth.
					</label>
					<input type="text" name="min_depth" id="min_depth" value="#locDet.min_depth#" size="3">
				</td>
				<td>TO</td>
				<td>
					<label for="max_depth" class="likeLink" onClick="getDocs('locality','depth')">
						Max. Depth.
					</label>
					<input type="text" name="max_depth"  id="max_depth" value="#locDet.max_depth#" size="3">
				</td>
				<td>
					<label for="depth_units" class="likeLink" onClick="getDocs('locality','depth')">
						Depth Unit
					</label>
					<select name="depth_units" size="1" id="depth_units">
						<option value=""></option>
	                    <cfloop query="ctDepthUnit">
	                    	<option <cfif ctDepthUnit.depth_units is locdet.depth_units> selected="selected" </cfif>value="#ctDepthUnit.depth_units#">#ctDepthUnit.depth_units#</option>
	                    </cfloop>
	                </select>
				</td>
			</tr>
		</table>
		<label for="locality_remarks">Locality Remarks</label>
		<input type="text" name="locality_remarks" id="locality_remarks" value="#stripQuotes(locDet.locality_remarks)#"  size="120">
		<table>
			<tr>
				<td>
					<label for="dec_lat">Decimal Latitude</label>
					<input type="text" name="DEC_LAT" id="dec_lat" value="#locDet.DEC_LAT#" class="">
				</td>
				<td>
					<label for="dec_long">Decimal Longitude</label>
					<input type="text" name="DEC_LONG" value="#locDet.DEC_LONG#" id="dec_long" class="">
				</td>
				<td rowspan="3">
	            	<cfquery name="events" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select
							count(*) c,
							VERBATIM_DATE,
							VERBATIM_LOCALITY,
							VERBATIM_COORDINATES,
							COLLECTING_EVENT_NAME
							from
								collecting_event
							where
								locality_id=#locDet.locality_id#
							group by
								VERBATIM_DATE,
								VERBATIM_LOCALITY,
								VERBATIM_COORDINATES,
								COLLECTING_EVENT_NAME
					</cfquery>
					<label for="et">Events using this Locality</label>
					<table id="et" border>
						<tr>
							<th>Count</th>
							<th>Nickname</th>
							<th>Date</th>
							<th>Coordinates</th>
						</tr>
						<cfloop query="events">
							<tr>
								<td>#c#</td>
								<td>#COLLECTING_EVENT_NAME#</td>
								<td>#VERBATIM_DATE#</td>
								<td>#verbatim_coordinates#</td>
							</tr>
						</cfloop>
					</table>
					<input type="button" value="Update all events to use locality coordinates" class="lnkBtn"
						onclick="document.location='/Locality.cfm?action=massEditCollEvent&locality_id=#locDet.locality_id#'">

				</td>
			</tr>
			<tr>
				<td colspan="2">
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
		</table>
		<table>
			<tr>
				<td>
					<input type="hidden" id="error_in_meters" value="#locDet.error_in_meters#">
					<label for="MAX_ERROR_DISTANCE" class="likeLink" onClick="getDocs('lat_long','maximum_error')">Max Error</label>
					<input type="text" name="MAX_ERROR_DISTANCE" id="MAX_ERROR_DISTANCE" value="#locDet.MAX_ERROR_DISTANCE#" size="6">
				</td>
				<td>
					<label for="MAX_ERROR_UNITS" class="likeLink" onClick="getDocs('lat_long','maximum_error')">Max Error Units</label>
					<select name="MAX_ERROR_UNITS" size="1" id="MAX_ERROR_UNITS">
						<option value=""></option>
						<cfloop query="cterror">
							<option <cfif cterror.LAT_LONG_ERROR_UNITS is locDet.MAX_ERROR_UNITS> selected="selected" </cfif>
								value="#cterror.LAT_LONG_ERROR_UNITS#">#cterror.LAT_LONG_ERROR_UNITS#</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
		<label for="DATUM" class="likeLink" onClick="getDocs('lat_long','datum')">Datum</label>
		<select name="DATUM" id="DATUM" size="1" class="reqdClr">
			<option value=''></option>
			<cfloop query="ctdatum">
				<option <cfif ctdatum.DATUM is locDet.DATUM> selected="selected" </cfif> value="#ctdatum.DATUM#">#ctdatum.DATUM#</option>
			</cfloop>
		</select>
		<label for="georeference_source" class="likeLink" onClick="getDocs('lat_long','georeference_source')">georeference_source</label>
		<input type="text" name="georeference_source" id="georeference_source" size="120" class="reqdClr" value='#preservesinglequotes(locDet.georeference_source)#' />
		<label for="georeference_protocol" class="likeLink" onClick="getDocs('lat_long','georeference_protocol')">Georeference Protocol</label>
		<select name="georeference_protocol" id="georeference_protocol" size="1" class="reqdClr">
			<option value=''></option>
			<cfloop query="ctgeoreference_protocol">
				<option
					<cfif locDet.georeference_protocol is ctgeoreference_protocol.georeference_protocol> selected="selected" </cfif>
					value="#ctgeoreference_protocol.georeference_protocol#">#ctgeoreference_protocol.georeference_protocol#</option>
			</cfloop>
		</select>
		<br>
		<cfset slat=locDet.s$dec_lat>
		<cfset slon=locDet.s$dec_long>
		<cfset sgeo=locDet.s$geography>
		<cfset sele=locDet.s$elevation>

		<!----
			get calculated coordinates and political stuff from the descriptive data
		---->
		<cfset geoList="">
		<cfif len(locDet.s$dec_lat) is 0>
			<cfhttp method="get" url="http://maps.googleapis.com/maps/api/geocode/json?address=#locDet.spec_locality#, #locDet.higher_geog#&sensor=false" timeout="1"></cfhttp>
			<cfif cfhttp.responseHeader.Status_Code is 200>
				<cfset llresult=DeserializeJSON(cfhttp.fileContent)>
				<cfif llresult.status is "OK">
					<cfloop from="1" to ="#arraylen(llresult.results)#" index="llr">
						<cfloop from="1" to="#arraylen(llresult.results[llr].address_components)#" index="ac">
							<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].long_name)>
								<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].long_name)>
							</cfif>
							<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].short_name)>
								<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].short_name)>
							</cfif>
						</cfloop>
					</cfloop>
					<cfset slat=llresult.results[1].geometry.location.lat>
					<cfset slon=llresult.results[1].geometry.location.lng>
				</cfif>
			</cfif>
		</cfif>
		<!--- see if we can get better political data from the coordinates ---->
		<cfif len(locDet.s$geography) is 0>
			<cfif len(locDet.dec_lat) gt 0>
				<cfhttp method="get" url="http://maps.googleapis.com/maps/api/geocode/json?latlng=#locDet.dec_lat#,#locDet.dec_long#&sensor=false" timeout="1"></cfhttp>
				<cfif cfhttp.responseHeader.Status_Code is 200>
					<cfset llresult=DeserializeJSON(cfhttp.fileContent)>
					<cfloop from="1" to ="#arraylen(llresult.results)#" index="llr">
						<cfloop from="1" to="#arraylen(llresult.results[llr].address_components)#" index="ac">
							<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].long_name)>
								<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].long_name)>
							</cfif>
							<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].short_name)>
								<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].short_name)>
							</cfif>
						</cfloop>
					</cfloop>
				</cfif>
			</cfif>
			<cfif len(locDet.s$dec_lat) gt 0>
				<cfhttp method="get" url="http://maps.googleapis.com/maps/api/geocode/json?latlng=#locDet.s$dec_lat#,#locDet.s$dec_long#&sensor=false" timeout="1"></cfhttp>
				<cfif cfhttp.responseHeader.Status_Code is 200>
					<cfset llresult=DeserializeJSON(cfhttp.fileContent)>
					<cfloop from="1" to ="#arraylen(llresult.results)#" index="llr">
						<cfloop from="1" to="#arraylen(llresult.results[llr].address_components)#" index="ac">
							<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].long_name)>
								<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].long_name)>
							</cfif>
							<cfif not listcontainsnocase(geolist,llresult.results[llr].address_components[ac].short_name)>
								<cfset geolist=listappend(geolist,llresult.results[llr].address_components[ac].short_name)>
							</cfif>
						</cfloop>
					</cfloop>
				</cfif>
			</cfif>
		</cfif>
		<cfif len(locDet.s$elevation) is 0>
			<cfif len(locDet.dec_lat) gt 0>
				<cfhttp method="get" url="http://maps.googleapis.com/maps/api/elevation/json?locations=#locDet.DEC_LAT#,#locDet.DEC_LONG#&sensor=false" timeout="1"></cfhttp>
				<cfif cfhttp.responseHeader.Status_Code is 200>
					<cfset elevResult=DeserializeJSON(cfhttp.fileContent)>
					<cfif isdefined("elevResult.status") and elevResult.status is "OK">
						<cfset sele=round(elevResult.results[1].elevation)>
					</cfif>
				</cfif>
			<cfelseif len(locDet.s$dec_lat) gt 0>
				<cfhttp method="get" url="http://maps.googleapis.com/maps/api/elevation/json?locations=#locDet.s$dec_lat#,#locDet.s$dec_long#&sensor=false" timeout="1"></cfhttp>
				<cfif cfhttp.responseHeader.Status_Code is 200>
					<cfset elevResult=DeserializeJSON(cfhttp.fileContent)>
					<cfif isdefined("elevResult.status") and elevResult.status is "OK">
						<cfset sele=round(elevResult.results[1].elevation)>
					</cfif>
				</cfif>
			<cfelseif len(slat) gt 0>
				<cfhttp method="get" url="http://maps.googleapis.com/maps/api/elevation/json?locations=#slat#,#slon#&sensor=false" timeout="1"></cfhttp>
				<cfif cfhttp.responseHeader.Status_Code is 200>
					<cfset elevResult=DeserializeJSON(cfhttp.fileContent)>
					<cfif isdefined("elevResult.status") and elevResult.status is "OK">
						<cfset sele=round(elevResult.results[1].elevation)>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		<cfif len(geoList) gt 0>
			<cfset sgeo=geoList>
		</cfif>
		<input type="button" value="Save" class="savBtn" onclick="locality.action.value='saveLocalityEdit';locality.submit();">
		<input type="button" value="Delete" class="delBtn" onClick="locality.action.value='deleteLocality';confirmDelete('locality');">
		<input type="button" value="Clone Locality" class="insBtn" onClick="cloneLocality(#locality_id#)">
		<input type="button" value="Add Collecting Event" class="insBtn"
			onclick="document.location='Locality.cfm?action=newCollEvent&locality_id=#locDet.locality_id#'">
		<input type="button" value="Georeference with GeoLocate" class="insBtn" onClick="geolocate();">
		<cfif len(locDet.DEC_LONG) gt 0>
			<input type="button" value="Modify Coordinates/Error with GeoLocate" class="insBtn" onClick="geolocate('adjust');">
		</cfif>
		<br>
		<a href="Locality.cfm?action=findCollEvent&locality_id=#locDet.locality_id#">[ Find all Collecting Events ]</a>
		<a href="http://manisnet.org/gci2.html" target="_blank" class="external">[ Georef Calculator ]</a>
		<span class="likeLink" onClick="getDocs('lat_long')">[ lat_long help ]</span>
	</td>
	<td valign="top">
		<cfif len(locDet.dec_lat) gt 0>
			<cfinvoke component="component.functions" method="getMap" returnvariable="contents">
				<cfinvokeargument name="locality_id" value="#locality_id#">
			</cfinvoke>
			<table>
				<tr>
					<td>#contents#</td>
					<td>
						<div style="font-size:smaller;font-weight:bold;">
							Click the map to open BerkeleyMapper. This won't work if you do not have database permission for at least one specimen
							 in the locality -
							try <a href="https://maps.google.com/?q=#locDet.dec_lat#,#locDet.dec_long#">Google Maps</a> (caution: no uncertainty!) or one of the
							GeoLocate options to the left.
						</div>
					</td>
				</tr>
			</table>
		</cfif>


		<div style="border:1px dashed red; padding:1em;background-color:lightgray;">
		<strong>Webservice Lookup Data</strong>
		<div style="font-size:small">
			Data in this box come from various webservices. They are NOT specimen data and come with no guarantees.
		</div>
		<cfif len(slat) gt 0>
			<figure>
				<img src="http://maps.google.com/maps/api/staticmap?center=#slat#,#slon#&markers=color:red|size:tiny|#slat#,#slon#&sensor=false&size=80x80&zoom=2&maptype=roadmap" alt="[ Google Map of #slat#,#slon# ]">
				<figcaption>#numberformat(slat,"__.___")#,#numberformat(slon,"___.___")#</figcaption>
			</figure>
		<cfelse>
			<br>--Coordinates not found--<br>
		</cfif>
		<cfset sgeo=replace(sgeo,",",", ","all")>
		<strong>Elevation:</strong> #sele# m
		<br><strong>Descriptive:</strong> #sgeo#
		</div>

		<input type="hidden" name="s$dec_lat" value="#slat#">
		<input type="hidden" name="s$dec_long" value="#slon#" id="s$dec_long">
		<input type="hidden" name="s$elevation" value="#sele#" id="s$elevation">
		<input type="hidden" name="s$geography" value="#sgeo#" id="s$geography">
	</form>

	</td></tr></table>
	</span>
	<hr>
	<strong>Geology Attributes</strong>
	<cfif geolDet.recordcount gt 0>
		<form name="editGeolAtt" method="post" action="editLocality.cfm">
			<input type="hidden" name="action" value="editGeol">
           	<input type="hidden" name="locality_id" value="#locDet.locality_id#">
			<input type="hidden" name="number_of_determinations" value="#geolDet.recordcount#">
			<cfset i=1>
			<table border>
				<cfloop query="geolDet">
					<input type="hidden" name="geology_attribute_id_#i#" value="#geology_attribute_id#">
					<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<td>
							<label for="geology_attribute_#i#">Geology Attribute</label>
							<select name="geology_attribute_#i#" id="geology_attribute_#i#" class="reqdClr" onchange="populateGeology(this.id)">
								<option value="delete" class="red">Delete This</option>
								<cfloop query="ctgeology_attribute">
									<option <cfif #geology_attribute# is geolDet.geology_attribute> selected="selected" </cfif>value="#geology_attribute#">#geology_attribute#</option>
								</cfloop>
							</select>
							<span class="infoLink" onclick="document.getElementById('geology_attribute_#i#').value='delete'">Delete This</span>
							<label for="geo_att_value">Value</label>
							<select name="geo_att_value_#i#" id="geo_att_value_#i#" class="reqdClr">
								<option value="#geo_att_value#">#geo_att_value#</option>
							</select>
							<label for="geo_att_determiner_#i#">Determiner</label>
							<input type="text" name="geo_att_determiner_#i#"  size="40"
								onchange="getAgent('geo_att_determiner_id_#i#','geo_att_determiner_#i#','editGeolAtt',this.value); return false;"
			 					onKeyPress="return noenter(event);"
			 					value="#agent_name#">
							<input type="hidden" name="geo_att_determiner_id_#i#" id="geo_att_determiner_id" value="#geo_att_determiner_id#">
							<label for="geo_att_determined_date_#i#">Date</label>
							<input type="text" name="geo_att_determined_date_#i#" id="geo_att_determined_date_#i#" value="#dateformat(geo_att_determined_date,'yyyy-mm-dd')#">
							<label for="geo_att_determined_method_#i#">Method</label>
							<input type="text" name="geo_att_determined_method_#i#" size="60"  value="#geo_att_determined_method#">
							<label for="geo_att_remark_#i#">Remark</label>
							<input type="text" name="geo_att_remark_#i#" size="60" value="#geo_att_remark#">
						</td>
					</tr>
					<cfset i=i+1>
				</cfloop>
				<tr>
					<td colspan="2">
						<input type="submit" value="Save Changes"  class="savBtn">
					</td>
				</tr>
			</table>
		</form>
	</cfif>
	<table class="newRec">
		<tr>
			<td>
				<strong>Create Geology Determination</strong>
				<form name="newGeolDet" method="post" action="editLocality.cfm">
		            <input type="hidden" name="action" value="AddGeol">
		            <input type="hidden" name="locality_id" value="#locDet.locality_id#">
					<label for="geology_attribute">Geology Attribute</label>
					<select name="geology_attribute" id="geology_attribute" class="reqdClr" onchange="populateGeology(this.id)">
						<option value=""></option>
						<cfloop query="ctgeology_attribute">
							<option value="#geology_attribute#">#geology_attribute#</option>
						</cfloop>
					</select>
					<label for="geo_att_value">Value</label>
					<select name="geo_att_value" id="geo_att_value" class="reqdClr"></select>
					<label for="geo_att_determiner">Determiner</label>
					<input type="text" name="geo_att_determiner" id="geo_att_determiner" size="40"
						onchange="getAgent('geo_att_determiner_id','geo_att_determiner','newGeolDet',this.value); return false;"
				 		onKeyPress="return noenter(event);">
					<input type="hidden" name="geo_att_determiner_id" id="geo_att_determiner_id">
					<label for="geo_att_determined_date">Determined Date</label>
					<input type="text" name="geo_att_determined_date" id="geo_att_determined_date">
					<label for="geo_att_determined_method">Determination Method</label>
					<input type="text" name="geo_att_determined_method" id="geo_att_determined_method" size="60">
					<label for="geo_att_remark">Remark</label>
					<input type="text" name="geo_att_remark" id="geo_att_remark" size="60">
					<br>
					<input type="submit" value="Create Determination" class="insBtn">
				</form>
			</td>
		</tr>
	</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
</cfif>
<!------------------------------------------------------------------------------------------------------>
<cfif action is "updateAllVerificationStatus">
	<cfoutput>
	    <cfquery name="upall" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update
				specimen_event
			set
				VerificationStatus='#VerificationStatus#'
			where
				COLLECTING_EVENT_ID in (select COLLECTING_EVENT_ID from COLLECTING_EVENT where locality_id = #locality_id#) and
				COLLECTION_OBJECT_ID in (select COLLECTION_OBJECT_ID from cataloged_item) -- keep things on the right side of the VPD
		</cfquery>
		<cflocation addtoken="false" url="editLocality.cfm?locality_id=#locality_id#">
	</cfoutput>
</cfif>
<cfif action is "editGeol">
<cfoutput>
	<cfloop from="1" to="#number_of_determinations#" index="n">
		<cfset deleteThis="">
		<cfset thisID = #evaluate("geology_attribute_id_" & n)#>
		<cfset thisAttribute = #evaluate("geology_attribute_" & n)#>
		<cfset thisValue = #evaluate("geo_att_value_" & n)#>
		<cfset thisDate = #evaluate("geo_att_determined_date_" & n)#>
		<cfset thisMethod = #evaluate("geo_att_determined_method_" & n)#>
		<cfset thisDeterminer = #evaluate("geo_att_determiner_id_" & n)#>
		<cfset thisRemark = #evaluate("geo_att_remark_" & n)#>

		<cfif #thisAttribute# is "delete">
			<cfquery name="deleteGeol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				delete from geology_attributes where geology_attribute_id=#thisID#
			</cfquery>
		<cfelse>
			<cfquery name="upGeol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				update
					geology_attributes
				set
					geology_attribute='#thisAttribute#',
					geo_att_value='#stripQuotes(thisValue)#'
					<cfif len(#thisDeterminer#) gt 0>
						,geo_att_determiner_id=#thisDeterminer#
					<cfelse>
						,geo_att_determiner_id=NULL
					</cfif>
					<cfif len(#thisDate#) gt 0>
						,geo_att_determined_date='#dateformat(thisDate,"yyyy-mm-dd")#'
					<cfelse>
						,geo_att_determined_date=NULL
					</cfif>
					<cfif len(#thisMethod#) gt 0>
						,geo_att_determined_method='#stripQuotes(thisMethod)#'
					<cfelse>
						,geo_att_determined_method=NULL
					</cfif>
					<cfif len(#thisRemark#) gt 0>
						,geo_att_remark='#stripQuotes(thisRemark)#'
					<cfelse>
						,geo_att_remark=NULL
					</cfif>
				where
					geology_attribute_id=#thisID#
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------>
<cfif action is "AddGeol">
<cfoutput>
		<cfquery name="changeGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into geology_attributes (
    			locality_id,
			    geology_attribute,
			    geo_att_value
			    <cfif len(#geo_att_determiner_id#) gt 0>
					,geo_att_determiner_id
				</cfif>
				<cfif len(#geo_att_determined_date#) gt 0>
					,geo_att_determined_date
				</cfif>
			   	<cfif len(#geo_att_determined_method#) gt 0>
					,geo_att_determined_method
				</cfif>
			   	<cfif len(#geo_att_remark#) gt 0>
					,geo_att_remark
				</cfif>
			   ) values (
			   #locality_id#,
			   '#geology_attribute#',
			   '#stripQuotes(geo_att_value)#'
			   <cfif len(#geo_att_determiner_id#) gt 0>
					,#geo_att_determiner_id#
				</cfif>
				<cfif len(#geo_att_determined_date#) gt 0>
					,'#dateformat(geo_att_determined_date,"yyyy-mm-dd")#'
				</cfif>
				<cfif len(#geo_att_determined_method#) gt 0>
					,'#stripQuotes(geo_att_determined_method)#'
				</cfif>
				<cfif len(#geo_att_remark#) gt 0>
					,'#stripQuotes(geo_att_remark)#'
				</cfif>
			 )
		</cfquery>
		<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveLocalityEdit">
	<cfoutput>

	<cfset sql = "UPDATE locality SET GEOG_AUTH_REC_ID = #GEOG_AUTH_REC_ID#">
	<cfset sql = "#sql#,MAX_ERROR_UNITS = '#MAX_ERROR_UNITS#'">
	<cfset sql = "#sql#,DATUM = '#DATUM#'">
	<cfset sql = "#sql#,georeference_source = '#georeference_source#'">
	<cfset sql = "#sql#,georeference_protocol = '#georeference_protocol#'">
	<cfset sql = "#sql#,locality_name = '#locality_name#'">

	<cfif len(MAX_ERROR_DISTANCE) gt 0>
		<cfset sql = "#sql#,MAX_ERROR_DISTANCE = #MAX_ERROR_DISTANCE#">
	<cfelse>
		<cfset sql = "#sql#,MAX_ERROR_DISTANCE = null">
	</cfif>

	<cfif len(DEC_LAT) gt 0>
		<cfset sql = "#sql#,DEC_LAT = #DEC_LAT#">
	<cfelse>
		<cfset sql = "#sql#,DEC_LAT = null">
	</cfif>
	<cfif len(DEC_LONG) gt 0>
		<cfset sql = "#sql#,DEC_LONG = #DEC_LONG#">
	<cfelse>
		<cfset sql = "#sql#,DEC_LONG = null">
	</cfif>

	<cfif len(spec_locality) gt 0>
		<cfset sql = "#sql#,spec_locality = '#escapeQuotes(spec_locality)#'">
	  <cfelse>
		<cfset sql = ",spec_locality=null">
	</cfif>
	<cfif len(#MINIMUM_ELEVATION#) gt 0>
		<cfset sql = "#sql#,MINIMUM_ELEVATION = #MINIMUM_ELEVATION#">
	<cfelse>
		<cfset sql = "#sql#,MINIMUM_ELEVATION = null">
	</cfif>
	<cfif len(#MAXIMUM_ELEVATION#) gt 0>
		<cfset sql = "#sql#,MAXIMUM_ELEVATION = #MAXIMUM_ELEVATION#">
	<cfelse>
		<cfset sql = "#sql#,MAXIMUM_ELEVATION = null">
	</cfif>
	<cfif len(#ORIG_ELEV_UNITS#) gt 0>
		<cfset sql = "#sql#,ORIG_ELEV_UNITS = '#ORIG_ELEV_UNITS#'">
	<cfelse>
		<cfset sql = "#sql#,ORIG_ELEV_UNITS = null">
	</cfif>
	<cfif len(#min_depth#) gt 0>
		<cfset sql = "#sql#,min_depth = #min_depth#">
	<cfelse>
		<cfset sql = "#sql#,min_depth = null">
	</cfif>
	<cfif len(#max_depth#) gt 0>
		<cfset sql = "#sql#,max_depth = #max_depth#">
	<cfelse>
		<cfset sql = "#sql#,max_depth = null">
	</cfif>
	<cfif len(#depth_units#) gt 0>
		<cfset sql = "#sql#,depth_units = '#depth_units#'">
	<cfelse>
		<cfset sql = "#sql#,depth_units = null">
	</cfif>
	<cfif len(#LOCALITY_REMARKS#) gt 0>
		<cfset sql = "#sql#,LOCALITY_REMARKS = '#escapeQuotes(LOCALITY_REMARKS)#'">
	<cfelse>
		<cfset sql = "#sql#,LOCALITY_REMARKS = null">
	</cfif>
	<cfif len(s$geography) gt 0>
		<cfset sql = "#sql#,s$geography = '#escapeQuotes(s$geography)#'">
	<cfelse>
		<cfset sql = "#sql#,s$geography = null">
	</cfif>

	<cfif len(s$elevation) gt 0>
		<cfset sql = "#sql#,s$elevation = #s$elevation#">
	<cfelse>
		<cfset sql = "#sql#,s$elevation = null">
	</cfif>
	<cfif len(s$dec_lat) gt 0>
		<cfset sql = "#sql#,s$dec_lat = #s$dec_lat#">
	<cfelse>
		<cfset sql = "#sql#,s$dec_lat = null">
	</cfif>
	<cfif len(s$dec_long) gt 0>
		<cfset sql = "#sql#,s$dec_long = #s$dec_long#">
	<cfelse>
		<cfset sql = "#sql#,s$dec_long = null">
	</cfif>

	<cfset sql = "#sql# where locality_id = #locality_id#">
	<cfquery name="edLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cflocation addtoken="no" url="editLocality.cfm?locality_id=#locality_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "deleteLocality">
<cfoutput>
	<cfdump var=#form#>
	<cfquery name="isColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collecting_event_id from collecting_event where locality_id=#locality_id#
	</cfquery>
	<cfif len(isColl.collecting_event_id) gt 0>
		There are active collecting events for this locality. It cannot be deleted.
		<br><a href="editLocality.cfm?locality_id=#locality_id#">Return</a> to editing.
		<cfabort>
	</cfif>
	<cftransaction>
		<cfquery name="deleLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from locality where locality_id=#locality_id#
		</cfquery>
	</cftransaction>
	You deleted it.
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "clone">
	<cfoutput>
		<cftransaction>
			<cfquery name="nLocId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_locality_id.nextval nv from dual
			</cfquery>
			<cfset lid=nLocId.nv>
			<cfquery name="newLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				INSERT INTO locality (
					LOCALITY_ID,
					GEOG_AUTH_REC_ID,
					MAXIMUM_ELEVATION,
					MINIMUM_ELEVATION,
					ORIG_ELEV_UNITS,
					SPEC_LOCALITY,
					LOCALITY_REMARKS,
					DEPTH_UNITS,
					MIN_DEPTH,
					MAX_DEPTH,
					DEC_LAT,
					DEC_LONG,
					MAX_ERROR_DISTANCE,
					MAX_ERROR_UNITS,
					DATUM,
					georeference_source,
					georeference_protocol,
					locality_name
				)  (
					select
						#lid#,
						GEOG_AUTH_REC_ID,
						MAXIMUM_ELEVATION,
						MINIMUM_ELEVATION,
						ORIG_ELEV_UNITS,
						SPEC_LOCALITY,
						LOCALITY_REMARKS,
						DEPTH_UNITS,
						MIN_DEPTH,
						MAX_DEPTH,
						DEC_LAT,
						DEC_LONG,
						MAX_ERROR_DISTANCE,
						MAX_ERROR_UNITS,
						DATUM,
						georeference_source,
						georeference_protocol,
						DECODE(locality_name,NULL,NULL,'clone of ' || locality_name)
					from
						locality
					where
						locality_id=#locality_id#
				)
			</cfquery>
		</cftransaction>
		<cflocation url="editLocality.cfm?locality_id=#lid#" addtoken="false">
	</cfoutput>
</cfif>