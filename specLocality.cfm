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
			var idNum=id.replace('geology_attribute__','');
			var thisValue=$("#geology_attribute__" + idNum).val();;
			var dataValue=$("#geo_att_value__" + idNum).val();
			var theSelect="geo_att_value__";
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
</script>
<span class="helpLink" data-helplink="specimen-event">Page Help</span>
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
	<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    	select
			 COLLECTING_EVENT.COLLECTING_EVENT_ID,
			 specimen_event_id,
			 locality.LOCALITY_ID,
			 VERBATIM_DATE,
			 VERBATIM_LOCALITY,
			 COLL_EVENT_REMARKS,
			 BEGAN_DATE,
			 ENDED_DATE,
			 verbatim_coordinates,
			 collecting_event_name,
			 COLLECTING_EVENT.LAT_DEG,
			 DEC_LAT_MIN,
			 LAT_MIN,
			 LAT_SEC,
			 LAT_DIR,
			 LONG_DEG,
			 DEC_LONG_MIN,
			 LONG_MIN,
			 LONG_SEC,
			 LONG_DIR,
			 COLLECTING_EVENT.DEC_LAT,
			 COLLECTING_EVENT.DEC_LONG,
			 COLLECTING_EVENT.DATUM,
			 UTM_ZONE,
			 UTM_EW,
			 UTM_NS,
			 COLLECTING_EVENT.ORIG_LAT_LONG_UNITS,
			 geog_auth_rec.GEOG_AUTH_REC_ID,
			 SPEC_LOCALITY,
			 locality.DEC_LAT locdeclat,
			 locality.DEC_LONG locdeclong,
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
			 GEOLOGY_ATTRIBUTE_ID,
			GEOLOGY_ATTRIBUTE,
			GEO_ATT_VALUE,
			GEO_ATT_DETERMINER_ID,
			getPreferredAgentName(GEO_ATT_DETERMINER_ID) geo_att_determiner,
			GEO_ATT_DETERMINED_DATE,
			GEO_ATT_DETERMINED_METHOD,
			GEO_ATT_REMARK,
			geog_auth_rec.geog_auth_rec_id,
			higher_geog,
			specimen_event_remark
		from
			geog_auth_rec,
			locality,
			geology_attributes,
			collecting_event,
			specimen_event
		where
			geog_auth_rec.geog_auth_rec_id=locality.geog_auth_rec_id and
			locality.locality_id=collecting_event.locality_id and
			locality.locality_id=geology_attributes.locality_id (+) and
			collecting_event.collecting_event_id=specimen_event.collecting_event_id and
			specimen_event.collection_object_id = #collection_object_id#
	</cfquery>
	<cfquery name="l" dbtype="query">
		select
		 COLLECTING_EVENT_ID,
			 LOCALITY_ID,
			 VERBATIM_DATE,
			 VERBATIM_LOCALITY,
			 COLL_EVENT_REMARKS,
			 BEGAN_DATE,
			 ENDED_DATE,
			 verbatim_coordinates,
			 collecting_event_name,
			 LAT_DEG,
			 DEC_LAT_MIN,
			 LAT_MIN,
			 LAT_SEC,
			 LAT_DIR,
			 LONG_DEG,
			 DEC_LONG_MIN,
			 LONG_MIN,
			 LONG_SEC,
			 LONG_DIR,
			 DEC_LAT,
			 DEC_LONG,
			 UTM_ZONE,
			 UTM_EW,
			 UTM_NS,
			 ORIG_LAT_LONG_UNITS,
			 GEOG_AUTH_REC_ID,
			 SPEC_LOCALITY,
			 locdeclat,
			 locdeclong,
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
			 georeference_source,
			 georeference_protocol,
			 locality_name,
			 assigned_by_agent_id,
			 assigned_by_agent_name,
			 assigned_date,
			 specimen_event_type,
			 COLLECTING_METHOD,
			 COLLECTING_SOURCE,
			 VERIFICATIONSTATUS,
			 habitat,
			geog_auth_rec_id,
			higher_geog,
			specimen_event_id,
			specimen_event_remark
			from raw group by
			COLLECTING_EVENT_ID,
			 LOCALITY_ID,
			 VERBATIM_DATE,
			 VERBATIM_LOCALITY,
			 COLL_EVENT_REMARKS,
			 BEGAN_DATE,
			 ENDED_DATE,
			 verbatim_coordinates,
			 collecting_event_name,
			 LAT_DEG,
			 DEC_LAT_MIN,
			 LAT_MIN,
			 LAT_SEC,
			 LAT_DIR,
			 LONG_DEG,
			 DEC_LONG_MIN,
			 LONG_MIN,
			 LONG_SEC,
			 LONG_DIR,
			 DEC_LAT,
			 DEC_LONG,
			 DATUM,
			 UTM_ZONE,
			 UTM_EW,
			 UTM_NS,
			 ORIG_LAT_LONG_UNITS,
			 GEOG_AUTH_REC_ID,
			 SPEC_LOCALITY,
			 locdeclat,
			 locdeclong,
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
			 assigned_by_agent_name,
			 assigned_date,
			 specimen_event_type,
			 COLLECTING_METHOD,
			 COLLECTING_SOURCE,
			 VERIFICATIONSTATUS,
			 habitat,
			geog_auth_rec_id,
			higher_geog,
			specimen_event_id,
			specimen_event_remark
		order by
		specimen_event_type
	</cfquery>

	<cfquery name="g" dbtype="query">
		 select
		 	GEOLOGY_ATTRIBUTE_ID,
			GEOLOGY_ATTRIBUTE,
			GEO_ATT_VALUE,
			GEO_ATT_DETERMINER_ID,
			geo_att_determiner,
			GEO_ATT_DETERMINED_DATE,
			GEO_ATT_DETERMINED_METHOD,
			GEO_ATT_REMARK
		from
			raw
		where
			GEOLOGY_ATTRIBUTE_ID is not null
		group by
			 GEOLOGY_ATTRIBUTE_ID,
			GEOLOGY_ATTRIBUTE,
			GEO_ATT_VALUE,
			GEO_ATT_DETERMINER_ID,
			geo_att_determiner,
			GEO_ATT_DETERMINED_DATE,
			GEO_ATT_DETERMINED_METHOD,
			GEO_ATT_REMARK
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
	<cfquery name="ctGeorefMethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select georefMethod from ctgeorefmethod order by georefMethod
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
	<cfquery name="se" dbtype="query">
		select
			specimen_event_type,specimen_event_id
		from
			raw
		group by
			specimen_event_type,specimen_event_id
		order by
			specimen_event_type,specimen_event_id
	</cfquery>
		<a name="top"></a>
		Specimen/Event Shortcuts
		<ul>
			<li><a href="##specimen_event_new">Create New Specimen/Event</a></li>
			<cfloop query="se">
				<li><a href="##specimen_event_#specimen_event_id#">#specimen_event_type#</a></li>
			</cfloop>
		</ul>
	<cfset f=1>
	<cfloop query="l">
		<div style="border:2px solid black; margin:1em;">
		<table border="1" width="100%"><tr><td>
		<cfform name="loc#f#" method="post" action="specLocality.cfm">
			<input type="hidden" name="action" value="saveChange">
			<input type="hidden" name="nothing" id="nothing">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
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
				 onchange="getAgent('assigned_by_agent_id','assigned_by_agent_name','loc#f#',this.value); return false;"
				 onKeyPress="return noenter(event);">
			<input type="hidden" name="assigned_by_agent_id" id="assigned_by_agent_id" value="#l.assigned_by_agent_id#">

			<label for="assigned_date" class="helpLink" data-helplink="specimen-event_date">Determined Date</label>
			<input type="text" name="assigned_date" id="assigned_date" value="#dateformat(l.assigned_date,'yyyy-mm-dd')#" class="reqdClr">

			<label for="specimen_event_remark" class="infoLink">Specimen/Event Remark</label>
			<input type="text" name="specimen_event_remark" id="specimen_event_remark" value="#l.specimen_event_remark#" size="75">

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
			<h4>
				Collecting Event
				<a style="font-size:small;" href="/Locality.cfm?action=editCollEvnt&collecting_event_id=#collecting_event_id#" target="_top">[ Edit Event ]</a>
			</h4>
			<label for="">If you pick a new event, the Verbatim Locality will go here. Save to see the changes in the rest of the form.</label>
			<input type="text" size="50" name="cepick#f#">
			<input type="button" class="picBtn" value="pick new event" onclick="findCollEvent('collecting_event_id','loc#f#','cepick#f#');">
			<br>
			<cfinvoke component="component.functions" method="getEventContents" returnvariable="contents">
			    <cfinvokeargument name="collecting_event_id" value="#collecting_event_id#">
			</cfinvoke>
			#contents#
			<br>
			<ul>
				<li>Date: #VERBATIM_DATE# (<cfif BEGAN_DATE is ENDED_DATE>#ENDED_DATE#<cfelse>#BEGAN_DATE# to #ENDED_DATE#</cfif>)</li>
				<cfif len(VERBATIM_LOCALITY) gt 0>
					<li>Verbatim Locality: #VERBATIM_LOCALITY#</li>
				</cfif>
				<cfif len(verbatim_coordinates) gt 0>
					<li>Verbatim Coordinates: #verbatim_coordinates#</li>
				</cfif>
				<cfif len(collecting_event_name) gt 0>
					<li>Collecting Event Nickname: #collecting_event_name#</li>
				</cfif>
				<cfif len(COLL_EVENT_REMARKS) gt 0>
					<li>Collecting Event Remarks: #COLL_EVENT_REMARKS#</li>
				</cfif>
			</ul>
			<input type="button" value="Save Changes to this Specimen/Event" class="savBtn" onclick="loc#f#.action.value='saveChange';loc#f#.submit();">
			<input type="button" value="Delete this Specimen/Event" class="delBtn" onclick="loc#f#.action.value='delete';confirmDelete('loc#f#');">

	</cfform>
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
			<input type="text" size="50" name="cepick">
			<input type="button" class="picBtn" value="pick new event" onclick="findCollEvent('collecting_event_id','loc_new','cepick');">
			<br><input type="submit" value="Create this Specimen/Event" class="savBtn">
		</cfform>
	</div>
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
			habitat='#escapeQuotes(habitat)#'
		where
			SPECIMEN_EVENT_ID=#SPECIMEN_EVENT_ID#
	</cfquery>
	<cflocation url="specLocality.cfm?collection_object_id=#collection_object_id#" addtoken="false">
</cfif>