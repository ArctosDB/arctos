<cfinclude template="/includes/alwaysInclude.cfm">
<cfif not listfindnocase(session.roles,'manage_specimens')>
	<div class="error">
		not authorized
	</div>
	<cfabort>
</cfif>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$("#began_date").datepicker();
		$("#ended_date").datepicker();
		$(":input[id^='geo_att_determined_date']").each(function(e){
			$("#" + this.id).datepicker();
		});
		$("select[id^='geology_attribute_']").each(function(e){
			populateGeology(this.id);
		});
		if (window.addEventListener) {
			window.addEventListener("message", getGeolocate, false);
		} else {
			window.attachEvent("onmessage", getGeolocate);
		}
	});
	function populateGeology(id) {
		if (id.indexOf('__') > -1) {
			var idNum=id.replace('geology_attribute_','');
			var thisValue=$("#geology_attribute_" + idNum).val();;
			var dataValue=$("#geo_att_value_" + idNum).val();
			var theSelect="geo_att_value_";
			if (thisValue == ''){
				return false;
			}
		} else {
			// new geol attribute
			var idNum='';
			var thisValue=$("#geology_attribute").val();
			var dataValue=$("#geo_att_value").val();
			var theSelect="geo_att_value";
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

	function verifByMe(i,u){
		$("#verified_by_agent_name").val(u);
		$("#verified_by_agent_id").val(i);
		$("#verified_date").val(getFormattedDate());
	}

</script>
<span class="helpLink" data-helplink="specimen_event">Page Help</span>
<script>
	function showLLFormat(orig_units) {
		//alert(orig_units);
		var llMeta = document.getElementById('llMeta');
		var decdeg = document.getElementById('decdeg');
		var utm = document.getElementById('utm');
		var ddm = document.getElementById('ddm');
		var dms = document.getElementById('dms');
		llMeta.style.display='none';
		decdeg.style.display='none';
		utm.style.display='none';
		ddm.style.display='none';
		dms.style.display='none';
		//alert('everything off');
		if (orig_units.length > 0) {
			//alert('got soemthing');
			$("#orig_lat_long_units").val(orig_units);
			llMeta.style.display='';
			if (orig_units == 'decimal degrees') {
				decdeg.style.display='';
			}
			else if (orig_units == 'UTM') {
				//alert(utm.style.display);
				utm.style.display='';
				//alert(utm.style.display);
			}
			else if (orig_units == 'degrees dec. minutes') {
				ddm.style.display='';
			}
			else if (orig_units == 'deg. min. sec.') {
				dms.style.display='';
			}
			else {
				alert('I have no idea what to do with ' + orig_units);
			}
		}
	}
	function geoLocate(){
		alert('This form is kind of funky. Use Edit Locality if you have access.');
		$.getJSON("/component/Bulkloader.cfc",
			{
				method : "splitGeog",
				geog: $("#higher_geog").val(),
				specloc: $("#spec_locality").val(),
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				var gbgDiv = document.createElement('div');
				gbgDiv.id = 'gbgDiv';
				gbgDiv.className = 'bgDiv';
				gbgDiv.setAttribute('onclick','closeGeoLocate("clicked closed")');
				document.body.appendChild(gbgDiv);
				var gpopDiv=document.createElement('div');
				gpopDiv.id = 'gpopDiv';
				gpopDiv.className = 'editAppBox';
				document.body.appendChild(gpopDiv);
				var gcDiv=document.createElement('div');
				gcDiv.className = 'fancybox-close';
				gcDiv.id='gcDiv';
				gcDiv.setAttribute('onclick','closeGeoLocate("clicked closed")');
				$("#gpopDiv").append(gcDiv);
				var ghDiv=document.createElement('div');
				ghDiv.className = 'fancybox-help';
				ghDiv.id='ghDiv';
				ghDiv.innerHTML='<a href="https://arctosdb.wordpress.com/how-to/create/data-entry/geolocate/" target="blank">[ help ]</a>';
				$("#gpopDiv").append(ghDiv);
				$("#gpopDiv").append('<img src="/images/loadingAnimation.gif" class="centeredImage">');
				var gtheFrame = document.createElement('iFrame');
				gtheFrame.id='gtheFrame';
				gtheFrame.className = 'editFrame';
				gtheFrame.src=r;
				$("#gpopDiv").append(gtheFrame);
			}
		);
	}
	function closeGeoLocate(msg) {
		$('#gbgDiv').remove();
		$('#gbgDiv', window.parent.document).remove();
		$('#gpopDiv').remove();
		$('#gpopDiv', window.parent.document).remove();
		$('#gcDiv').remove();
		$('#gcDiv', window.parent.document).remove();
		$('#gtheFrame').remove();
		$('#gtheFrame', window.parent.document).remove();
		$("#geoLocateResults").html(msg);
	}
	function getGeolocate(evt) {
		var message;
		if (evt.origin !== "http://www.geo-locate.org") {
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
	$(document).ready(function() {
		$("input[type='date'], input[type='datetime']" ).datepicker();
	});
</script>
<cfif action is "nothing">
<cfoutput>
<script>
function useGL(glat,glon,gerr){
			showLLFormat('decimal degrees','');
			$("##accepted_lat_long_fg").val('1');
			$("##coordinate_determiner").val('#session.username#');
			$("##determined_by_agent_id").val('#session.myAgentId#');
			$("##determined_date").val('#dateformat(now(),"yyyy-mm-dd")#');
			$("##max_error_distance").val(gerr);
			$("##max_error_units").val('m');
			$("##datum").val('World Geodetic System 1984');
			$("##georefmethod").val('GeoLocate');
			$("##extent").val('');
			$("##gpsaccuracy").val('');
			$("##verificationstatus").val('unverified');
			$("##lat_long_ref_source").val('GeoLocate');
			$("##dec_lat").val(glat);
			$("##dec_long").val(glon);
			$("##lat_long_remarks").val('');
			closeGeoLocate();
		}
</script>
	<cfquery name="l" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    		select
	specimen_event.collection_object_id,
			 COLLECTING_EVENT.COLLECTING_EVENT_ID,
			 specimen_event_id,
			 locality.LOCALITY_ID,
			 VERBATIM_DATE,
			 VERBATIM_LOCALITY,
			 COLL_EVENT_REMARKS,
			 BEGAN_DATE,
			 ENDED_DATE,
			 geog_auth_rec.GEOG_AUTH_REC_ID,
			 SPEC_LOCALITY,
			 locality.DEC_LAT ,
			 locality.DEC_LONG ,
			 locality.datum,
			 MINIMUM_ELEVATION,
			 MAXIMUM_ELEVATION,
			 ORIG_ELEV_UNITS,
			 MIN_DEPTH,
			 MAX_DEPTH,
			 DEPTH_UNITS,
			 MAX_ERROR_DISTANCE,
			 MAX_ERROR_UNITS,
			 LOCALITY_REMARKS,
			 georeference_source,
			 georeference_protocol,
			 locality_name,
			 assigned_by_agent_id,
			 getPreferredAgentName(assigned_by_agent_id) assigned_by_agent_name,
			 assigned_date,
			 specimen_event_type,
			 COLLECTING_METHOD,
			 COLLECTING_SOURCE,
			 VERIFICATIONSTATUS,
			 habitat,
			geog_auth_rec.geog_auth_rec_id,
			higher_geog,
			specimen_event_remark,
			specimen_event.VERIFIED_BY_AGENT_ID,
			getPreferredAgentName(specimen_event.VERIFIED_BY_AGENT_ID) verified_by_agent_name,
			specimen_event.VERIFIED_DATE
		from
			geog_auth_rec,
			locality,
			collecting_event,
			specimen_event
		where
			geog_auth_rec.geog_auth_rec_id=locality.geog_auth_rec_id and
			locality.locality_id=collecting_event.locality_id and
			collecting_event.collecting_event_id=specimen_event.collecting_event_id and
			specimen_event.specimen_event_id = #specimen_event_id#
	</cfquery>


	<cfquery name="geology" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		 select
		 	GEOLOGY_ATTRIBUTE_ID,
			GEOLOGY_ATTRIBUTE,
			GEO_ATT_VALUE,
			GEO_ATT_DETERMINER_ID,
			getPreferredAgentName(GEO_ATT_DETERMINER_ID) geo_att_determiner,
			GEO_ATT_DETERMINED_DATE,
			GEO_ATT_DETERMINED_METHOD,
			GEO_ATT_REMARK
		from
			geology_attributes
		where
			locality_id=#l.locality_id#
		order by
			GEOLOGY_ATTRIBUTE
	</cfquery>
	<cfquery name="ctElevUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select orig_elev_units from ctorig_elev_units order by orig_elev_units
	</cfquery>
	<cfquery name="ctdepthUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select depth_units from ctdepth_units order by depth_units
	</cfquery>
     <cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select datum from ctdatum order by datum
     </cfquery>
	<cfquery name="ctVerificationStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select VerificationStatus from ctVerificationStatus order by VerificationStatus
	</cfquery>
     <cfquery name="cterror" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS order by LAT_LONG_ERROR_UNITS
     </cfquery>
     <cfquery name="ctew" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select e_or_w from ctew order by e_or_w
     </cfquery>
     <cfquery name="ctns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select n_or_s from ctns order by n_or_s
     </cfquery>
     <cfquery name="ctunits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select orig_lat_long_units from ctLAT_LONG_UNITS order by orig_lat_long_units
     </cfquery>
	<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select COLLECTING_SOURCE from ctcollecting_source order by COLLECTING_SOURCE
     </cfquery>
	<cfquery name="ctgeology_attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select geology_attribute from ctgeology_attribute order by geology_attribute
	</cfquery>
	<cfquery name="ctspecimen_event_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select specimen_event_type from ctspecimen_event_type order by specimen_event_type
	</cfquery>



		<div style="border:2px solid black; margin:1em;">
		<table border="1" width="100%"><tr><td>
		<form name="editForkSpecEvent" method="post" action="specLocality_forkLocStk.cfm">
			<input type="hidden" name="action" value="saveChange">
			<input type="hidden" name="nothing" id="nothing">
			<input type="hidden" name="collection_object_id" value="#l.collection_object_id#">
			<input type="hidden" name="collecting_event_id" value="#l.collecting_event_id#">
			<input type="hidden" name="specimen_event_id" value="#l.specimen_event_id#">

			<!-------------------------- specimen_event -------------------------->
			<h4>
				Specimen/Event
				<a name="specimen_event_#specimen_event_id#" href="##top">[ scroll to top ]</a>
			</h4>
			<label for="specimen_event_type">Specimen/Event Type</label>
			<select name="specimen_event_type" id="specimen_event_type" size="1" class="reqdClr">
				<cfloop query="ctspecimen_event_type">
					<option <cfif ctspecimen_event_type.specimen_event_type is "#l.specimen_event_type#"> selected="selected" </cfif>
						value="#ctspecimen_event_type.specimen_event_type#">#ctspecimen_event_type.specimen_event_type#</option>
			    </cfloop>
			</select>
			<span class="infoLink" onclick="getCtDoc('ctspecimen_event_type');">Define</span>
			<label for="specimen_event_type">Event Determiner</label>
			<input type="text" name="assigned_by_agent_name" id="assigned_by_agent_name" class="reqdClr" value="#l.assigned_by_agent_name#" size="40"
				 onchange="getAgent('assigned_by_agent_id','assigned_by_agent_name','editForkSpecEvent',this.value); return false;"
				 onKeyPress="return noenter(event);">
			<input type="hidden" name="assigned_by_agent_id" id="assigned_by_agent_id" value="#l.assigned_by_agent_id#">

			<label for="assigned_date" class="helpLink" data-helplink="specimen_event_date">Determined Date</label>
			<input type="datetime" name="assigned_date" id="assigned_date" value="#dateformat(l.assigned_date,'yyyy-mm-dd')#" class="reqdClr">

			<label for="specimen_event_remark" class="infoLink">Specimen/Event Remark</label>
			<input type="text" name="specimen_event_remark" id="specimen_event_remark" value="#stripQuotes(l.specimen_event_remark)#" size="75">

			<label for="habitat">Habitat</label>
			<input type="text" name="habitat" id="habitat" value="#l.habitat#" size="75">
			<label for="collecting_source" class="helpLink" data-helplink="collecting_source">Collecting Source</label>
			<select name="collecting_source" id="collecting_source" size="1">
				<option value=""></option>
				<cfloop query="ctcollecting_source">
					<option <cfif ctcollecting_source.COLLECTING_SOURCE is l.COLLECTING_SOURCE> selected="selected" </cfif>
						value="#ctcollecting_source.COLLECTING_SOURCE#">#ctcollecting_source.COLLECTING_SOURCE#</option>
				</cfloop>
			</select>
			<span class="infoLink" onclick="getCtDoc('ctcollecting_source');">Define</span>

			<label for="collecting_method" class="helpLink" data-helplink="collecting_method">Collecting Method</label>
			<input type="text" name="collecting_method" id="collecting_method" value="#stripQuotes(l.COLLECTING_METHOD)#" size="75">

			<label for="VerificationStatus" class="helpLink" data-helplink="verification_status">Verification Status</label>
			<select name="VerificationStatus" id="verificationstatus" size="1" class="reqdClr">
				<cfloop query="ctVerificationStatus">
					<option <cfif l.VerificationStatus is ctVerificationStatus.VerificationStatus> selected="selected" </cfif>
						value="#VerificationStatus#">#VerificationStatus#</option>
				</cfloop>
			</select>
			<span class="infoLink" onclick="getCtDoc('ctverificationstatus');">Define</span>
			<label for="verified_by_agent_name">Verified By</label>

			<input type="text" name="verified_by_agent_name" id="verified_by_agent_name" value="#l.verified_by_agent_name#" size="40"
				 onchange="pickAgentModal('verified_by_agent_id',this.id,this.value); return false;"
				 onKeyPress="return noenter(event);">
			<span class="infoLink" onclick="verifByMe('#session.MyAgentID#','#session.dbuser#')">Me, Today</span>

			<input type="hidden" name="verified_by_agent_id" id="verified_by_agent_id" value="#l.verified_by_agent_id#">

			<label for="verified_date" class="helpLink" data-helplink="verified_date">Verified Date</label>
			<input type="datetime" name="verified_date" id="verified_date" value="#dateformat(l.verified_date,'yyyy-mm-dd')#">

			<h4>
				Collecting Event
			</h4>



			<label for="verbatim_date" class="helpLink" data-helplink="verbatim_date">Verbatim Date</label>
			<input type="text" name="verbatim_date" id="verbatim_date" value="#stripQuotes(l.verbatim_date)#" size="75">
			<table>
				<tr>
					<td>
						<label for="began_date" class="helpLink" data-helplink="began_date">Began Date</label>
						<input type="text" name="began_date" id="began_date" value="#l.began_date#">
					</td>
					<td>
						<label for="ended_date" class="helpLink" data-helplink="ended_date">Ended Date</label>
						<input type="text" name="ended_date" id="ended_date" value="#l.ended_date#">
					</td>
				</tr>
			</table>

			<label for="verbatim_locality" class="helpLink" data-helplink="verbatim_locality">Verbatim Locality</label>
			<input type="text" name="verbatim_locality" id="verbatim_locality" value="#stripQuotes(l.verbatim_locality)#" size="75">

			<label for="coll_event_remarks" class="helpLink" data-helplink="coll_event_remarks">Collecting Event Remarks</label>
			<input type="text" name="coll_event_remarks" id="coll_event_remarks" value="#stripQuotes(l.coll_event_remarks)#" size="75">

			<h4>
				Locality
			</h4>


			<label for="spec_locality" class="helpLink" data-helplink="spec_locality">Specific Locality</label>
			<input type="text" name="spec_locality" id="spec_locality" value="#l.spec_locality#">


			<label for="locality_remarks" class="helpLink" data-helplink="locality_remarks">Locality Remarks</label>
			<input type="text" name="locality_remarks" id="locality_remarks" value="#l.locality_remarks#">


			<table>
				<tr>
					<td>
						<label for="dec_lat" class="helpLink" data-helplink="dec_lat">Decimal Latitude</label>
						<input type="number" name="dec_lat" id="dec_lat" value="#l.dec_lat#">
					</td>
					<td>
						<label for="dec_long" class="helpLink" data-helplink="dec_long">Decimal Longitude</label>
						<input type="number" name="dec_long" id="dec_long" value="#l.dec_long#">
					</td>
				</tr>
			</table>
			<table>
				<tr>
					<td>
						<label for="max_error_distance" class="helpLink" data-helplink="max_error_distance">Max Error Distance</label>
						<input type="number" name="max_error_distance" id="max_error_distance" value="#l.max_error_distance#">
					</td>
					<td>
						<label for="max_error_units" class="helpLink" data-helplink="max_error_units">Error Units</label>
						<select name="max_error_units" id="max_error_units" size="1">
							<cfloop query="cterror">
								<option <cfif l.max_error_units is cterror.LAT_LONG_ERROR_UNITS> selected="selected" </cfif>
									value="#LAT_LONG_ERROR_UNITS#">#LAT_LONG_ERROR_UNITS#</option>
							</cfloop>
						</select>
					</td>
				</tr>
			</table>


			<label for="datum" class="helpLink" data-helplink="datum">Datum</label>
			<select name="datum" id="datum" size="1" class="reqdClr">
				<cfloop query="ctdatum">
					<option <cfif l.datum is ctdatum.datum> selected="selected" </cfif>
						value="#datum#">#datum#</option>
				</cfloop>
			</select>


			<label for="georeference_protocol" class="helpLink" data-helplink="georeference_protocol">Georeference Protocol</label>
			<input type="text" name="georeference_protocol" id="georeference_protocol" value="#l.georeference_protocol#">

			<label for="georeference_source" class="helpLink" data-helplink="georeference_source">Georeference Source</label>
			<input type="text" name="georeference_source" id="georeference_source" value="#l.georeference_source#">

			<table>
				<tr>
					<td>
						<label for="minimum_elevation" class="helpLink" data-helplink="minimum_elevation">Min Elevation</label>
						<input type="number" name="minimum_elevation" id="minimum_elevation" value="#l.minimum_elevation#">
					</td>
					<td>
						<label for="maximum_elevation" class="helpLink" data-helplink="maximum_elevation">Max Elevation</label>
						<input type="number" name="maximum_elevation" id="maximum_elevation" value="#l.maximum_elevation#">
					</td>
					<td>
						<label for="orig_elev_units" class="helpLink" data-helplink="orig_elev_units">Elevation Units</label>
						<select name="orig_elev_units" id="orig_elev_units" size="1">
							<cfloop query="ctElevUnit">
								<option <cfif l.orig_elev_units is ctElevUnit.orig_elev_units> selected="selected" </cfif>
									value="#orig_elev_units#">#orig_elev_units#</option>
							</cfloop>
						</select>
					</td>
				</tr>
			</table>

			<table>
				<tr>
					<td>
						<label for="min_depth" class="helpLink" data-helplink="min_depth">Min Depth</label>
						<input type="number" name="min_depth" id="min_depth" value="#l.min_depth#">
					</td>
					<td>
						<label for="max_depth" class="helpLink" data-helplink="max_depth">Max Depth</label>
						<input type="number" name="max_depth" id="max_depth" value="#l.max_depth#">
					</td>
					<td>
						<label for="depth_units" class="helpLink" data-helplink="depth_units">Depth Units</label>
						<select name="depth_units" id="depth_units" size="1">
							<cfloop query="ctdepthUnit">
								<option <cfif l.depth_units is ctdepthUnit.depth_units> selected="selected" </cfif>
									value="#depth_units#">#depth_units#</option>
							</cfloop>
						</select>
					</td>
				</tr>
			</table>
			<h4>
				Geology
			</h4>

			<table border>
				<tr>
					<th>Attribute</th>
					<th>Value</th>
					<th>Determiner</th>
					<th>Date</th>
					<th>Method</th>
					<th>Remark</th>
				</tr>
				<cfset i=1>
				<cfloop query="geology">
					<tr>
						<td>
							<select name="geology_attribute_#i#" id="geology_attribute_#i#" class="reqdClr" onchange="populateGeology(this.id)">
								<option value="" class="red">Delete This</option>
								<cfloop query="ctgeology_attribute">
									<option <cfif ctgeology_attribute.geology_attribute is geology.geology_attribute> selected="selected" </cfif>value="#geology_attribute#">#geology_attribute#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<select name="geo_att_value_#i#" id="geo_att_value_#i#" class="reqdClr">
								<option value="#geo_att_value#">#geo_att_value#</option>
							</select>
						</td>
						<td>
							<input type="hidden" name="geo_att_determiner_id_#i#" id="geo_att_determiner_id" value="#geo_att_determiner_id#">
							<input type="text" name="geo_att_determiner_#i#"  size="40"
								onchange="pickAgentModal('geo_att_determiner_id_#i#','geo_att_determiner_#i#',this.value); return false;"
			 					onKeyPress="return noenter(event);"
			 					value="#agent_name#">
						</td>
						<td>
							<input type="text" name="geo_att_determined_date_#i#" id="geo_att_determined_date_#i#" value="#dateformat(geo_att_determined_date,'yyyy-mm-dd')#">
						</td>
						<td>
							<input type="text" name="geo_att_determined_method_#i#" size="60"  value="#geo_att_determined_method#">
						</td>
						<td>
							<input type="text" name="geo_att_remark_#i#" size="60" value="#geo_att_remark#">
						</td>
					</tr>
					<cfset i=i+1>
				</cfloop>
				<cfset lpt=i+3>
				<cfloop from ="#i#" to="#lpt#" index="i">
					<tr>
						<td>
							<select name="geology_attribute_#i#" id="geology_attribute_#i#" class="reqdClr" onchange="populateGeology(this.id)">
								<option value=""></option>
								<cfloop query="ctgeology_attribute">
									<option value="#geology_attribute#">#geology_attribute#</option>
								</cfloop>
							</select>
						</td>
						<td>
							<select name="geo_att_value_#i#" id="geo_att_value_#i#" class="reqdClr">
								<option value=""></option>
							</select>
						</td>
						<td>
							<input type="hidden" name="geo_att_determiner_id_#i#" id="geo_att_determiner_id" >
							<input type="text" name="geo_att_determiner_#i#"  size="40"
								onchange="pickAgentModal('geo_att_determiner_id_#i#','geo_att_determiner_#i#',this.value); return false;"
			 					onKeyPress="return noenter(event);">
						</td>
						<td>
							<input type="text" name="geo_att_determined_date_#i#" id="geo_att_determined_date_#i#">
						</td>
						<td>
							<input type="text" name="geo_att_determined_method_#i#" size="60" >
						</td>
						<td>
							<input type="text" name="geo_att_remark_#i#" size="60">
						</td>
					</tr>
				</cfloop>
			</table>



			<h4>
				Geography
			</h4>
			<input type="hidden" name="geog_auth_rec_id" value="#l.geog_auth_rec_id#">
			<label for="higher_geog">Higher Geography</label>
			<input type="text" name="higher_geog" id="higher_geog" value="#l.higher_geog#" size="120" class="readClr" readonly="yes">
			<input type="button" value="Pick" class="picBtn" id="changeGeogButton"
				onclick="GeogPick('geog_auth_rec_id','higher_geog','locality'); return false;">
<!----

			<input type="button" value="Save Changes to this Specimen/Event" class="savBtn" onclick="loc#f#.action.value='saveChange';loc#f#.submit();">
			<input type="button" value="Delete this Specimen/Event" class="delBtn" onclick="loc#f#.action.value='delete';confirmDelete('loc#f#');">
---->
	</form>


	<!--------
	<cfset obj = CreateObject("component","component.functions")>
	</td><td valign="top">
		<h4>Geography</h4>
			<ul>
				<li>#higher_geog#</li>
			</ul>
			<h4>
				Locality
				<a style="font-size:small;" href="/editLocality.cfm?locality_id=#locality_id#" target="_top">[ Edit Locality ]</a>
			</h4>
			<cfset localityContents = obj.getLocalityContents(locality_id="#locality_id#")>

			#localityContents#
			<ul>
				<cfif len(locality_name) gt 0>
					<li>Locality Nickname: #locality_name#</li>
				</cfif>
				<cfif len(DEC_LAT) gt 0>
					<li>
						<cfset getMap = obj.getMap(locality_id="#locality_id#")>
						<!-------
						<cfinvoke component="component.functions" method="getMap" returnvariable="contents">
							<cfinvokeargument name="lat" value="#DEC_LAT#">
							<cfinvokeargument name="" value="#DEC_LONG#">
							<cfinvokeargument name="locality_id" value="#locality_id#">
						</cfinvoke>
						--->
						#getMap#
						<span style="font-size:small;">
							<br>#DEC_LAT# / #DEC_LONG#
							<br>Datum: #DATUM#
							<br>Error: #MAX_ERROR_DISTANCE# #MAX_ERROR_UNITS#
							<br>Georeference Source: #georeference_source#
							<br>Georeference Protocol: #georeference_protocol#
						</span>
					</li>
				</cfif>
				<cfif len(SPEC_LOCALITY) gt 0>
					<li>Specific Locality: #SPEC_LOCALITY#</li>
				</cfif>
				<cfif len(ORIG_ELEV_UNITS) gt 0>
					<li>Elevation: #MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#</li>
				</cfif>
				<cfif len(DEPTH_UNITS) gt 0>
					<li>Depth: #MIN_DEPTH#-#MAX_DEPTH# #DEPTH_UNITS#</li>
				</cfif>
				<cfif len(LOCALITY_REMARKS) gt 0>
					<li>Remark: #LOCALITY_REMARKS#</li>
				</cfif>
			</ul>
			<cfif g.recordcount gt 0>
				<h4>Geology</h6>
				<ul>
					<cfloop query="g">
						<li>GEOLOGY_ATTRIBUTE_ID: #GEOLOGY_ATTRIBUTE_ID#</li>
						<li>GEOLOGY_ATTRIBUTE: #GEOLOGY_ATTRIBUTE#</li>
						<li>GEO_ATT_VALUE: #GEO_ATT_VALUE#</li>
						<li>geo_att_determiner: #geo_att_determiner#</li>
						<li>GEO_ATT_DETERMINED_DATE: #GEO_ATT_DETERMINED_DATE#</li>
						<li>GEO_ATT_DETERMINED_METHOD: #GEO_ATT_DETERMINED_METHOD#</li>
						<li>GEO_ATT_REMARK: #GEO_ATT_REMARK#</li>
					</cfloop>
				</ul>
			</cfif>


	</td>
	</tr></table>
	</div>
		<cfset f=f+1>
	</cfloop>
	<div style="border:2px solid black; margin:1em;">
		<cfform name="loc_new" method="post" action="specLocality.cfm">
			<input type="hidden" name="action" value="createSpecEvent">
			<input type="hidden" name="nothing" id="nothing">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			<input type="hidden" name="collecting_event_id" value="">
			<!-------------------------- specimen_event -------------------------->
			<h4>
				Add Specimen/Event
				<a name="specimen_event_new" href="##top">[ scroll to top ]</a>
			</h4>
			<label for="specimen_event_type">Specimen/Event Type</label>
			<select name="specimen_event_type" id="specimen_event_type" size="1" class="reqdClr">
				<cfloop query="ctspecimen_event_type">
					<option value="#ctspecimen_event_type.specimen_event_type#">#ctspecimen_event_type.specimen_event_type#</option>
			    </cfloop>
			</select>
			<span class="infoLink" onclick="getCtDoc('ctspecimen_event_type');">Define</span>

			<label for="specimen_event_type">Event Assigned by Agent</label>
			<input type="text" name="assigned_by_agent_name" id="assigned_by_agent_name" class="reqdClr" size="40" value="#session.dbuser#"
				 onchange="getAgent('assigned_by_agent_id','assigned_by_agent_name','loc_new',this.value); return false;"
				 onKeyPress="return noenter(event);">
			<input type="hidden" name="assigned_by_agent_id" id="assigned_by_agent_id" value="#session.myAgentId#">

			<label for="assigned_date" class="helpLink" data-helplink="specimen_event_date">Specimen/Event Assigned Date</label>
			<input type="text" name="assigned_date" id="assigned_date" value="#dateformat(now(),'yyyy-mm-dd')#" class="reqdClr">

			<label for="specimen_event_remark" class="infoLink">Specimen/Event Remark</label>
			<input type="text" name="specimen_event_remark" id="specimen_event_remark" value="" size="75">

			<label for="habitat">Habitat</label>
			<input type="text" name="habitat" id="habitat" value="#l.habitat#" size="75">

			<label for="collecting_source" class="helpLink" data-helplink="collecting_source">Collecting Source</label>
			<select name="collecting_source" id="collecting_source" size="1">
				<option value=""></option>
				<cfloop query="ctcollecting_source">
					<option value="#ctcollecting_source.COLLECTING_SOURCE#">#ctcollecting_source.COLLECTING_SOURCE#</option>
				</cfloop>
			</select>
			<span class="infoLink" onclick="getCtDoc('ctcollecting_source');">Define</span>

			<label for="collecting_method" class="helpLink" data-helplink="collecting_method">Collecting Method</label>
			<input type="text" name="collecting_method" id="collecting_method" value="" size="75">

			<label for="VerificationStatus" class="helpLink" data-helplink="verification_status">Verification Status</label>
			<select name="VerificationStatus" id="verificationstatus" size="1" class="reqdClr">
				<cfloop query="ctVerificationStatus">
					<option <cfif VerificationStatus is "unverified"> selected="selected"</cfif>value="#VerificationStatus#">#VerificationStatus#</option>
				</cfloop>
			</select>
			<span class="infoLink" onclick="getCtDoc('ctverificationstatus');">Define</span>
			<h4>
				Collecting Event
			</h4>
			<label for="">Click the button to pick an event. The Verbatim Locality of the event you pick will go here.</label>
			<input type="text" size="50" class="reqdClr" name="cepick">
			<input type="button" class="picBtn" value="pick new event" onclick="findCollEvent('collecting_event_id','loc_new','cepick');">
			<br><input type="submit" value="Create this Specimen/Event" class="savBtn">
		</cfform>
	</div>
	----------->
	</cfoutput>
</cfif>

<cfif action is "delete">
	<cfquery name="upSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		delete from specimen_event where specimen_event_id=#specimen_event_id#
	</cfquery>
	<cflocation url="specLocality.cfm?collection_object_id=#collection_object_id#" addtoken="false">
</cfif>

<cfif action is "createSpecEvent">
	<cfquery name="upSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into specimen_event (
			collection_object_id,
			collecting_event_id,
			assigned_by_agent_id,
			assigned_date,
			specimen_event_remark,
			specimen_event_type,
			COLLECTING_METHOD,
			COLLECTING_SOURCE,
			VERIFICATIONSTATUS,
			habitat
		) values (
			#collection_object_id#,
			#collecting_event_id#,
			#assigned_by_agent_id#,
			'#dateformat(assigned_date,"yyyy=mm-dd")#',
			'#escapeQuotes(specimen_event_remark)#',
			'#specimen_event_type#',
			'#escapeQuotes(COLLECTING_METHOD)#',
			'#COLLECTING_SOURCE#',
			'#VERIFICATIONSTATUS#',
			'#escapeQuotes(habitat)#'
		)
	</cfquery>
	<cflocation url="specLocality.cfm?collection_object_id=#collection_object_id#" addtoken="false">
</cfif>


<cfif action is "saveChange">
	<cfquery name="upSE" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		update specimen_event set
			collecting_event_id=#collecting_event_id#,
			assigned_by_agent_id=#assigned_by_agent_id#,
			assigned_date='#dateformat(assigned_date,"yyyy=mm-dd")#',
			specimen_event_remark='#escapeQuotes(specimen_event_remark)#',
			specimen_event_type='#specimen_event_type#',
			COLLECTING_METHOD='#escapeQuotes(COLLECTING_METHOD)#',
			COLLECTING_SOURCE='#COLLECTING_SOURCE#',
			VERIFICATIONSTATUS='#VERIFICATIONSTATUS#',
			habitat='#escapeQuotes(habitat)#',
			<cfif len(verified_by_agent_id) gt 0>
				verified_by_agent_id=#verified_by_agent_id#,
			<cfelse>
				verified_by_agent_id=null,
			</cfif>
			verified_date='#verified_date#'
		where
			SPECIMEN_EVENT_ID=#SPECIMEN_EVENT_ID#
	</cfquery>
	<cflocation url="specLocality.cfm?collection_object_id=#collection_object_id#" addtoken="false">
</cfif>