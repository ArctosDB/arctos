<cfif action is "seeWhatsThere">
	<cfquery name="ese" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from  cf_temp_specevent  where UUID='#UUID#'
	</cfquery>
	<cfif ese.recordcount is 0>
		<p>There are no external specimen-events for this UUID/entry</p>
	<cfelse>
		<p>There are #ese.recordcount# external specimen-events for this UUID/entry</p>
		<cfdump var=#ese#>
	</cfif>
</cfif>
<cfif action is "help">
	<p>
		This form extends the specimen bulkloader to include non-specimen bulkloaders. This is a limited-scope form and certain limitations exist.
		For Specimen-events, limitations may be bypassed by pre-creating collecting events. 
		
	</p>
	<p>
		To use this form, other_id_num_type4 MUST be a UUID, and other_id_val_4 MUST be a unique identifier. It 
		is recommended to allow the application to generate these values; simply leave other_id_4 NULL to do so.
	</p>
	<p>
		The UUID is the link to related records created here; do not alter or remove it until all data have been
		loaded and associated with the proper specimen. After all data are loaded, it's OK to delete the UUID.
	</p>
</cfif>


<cfif action is "addSE">

	<style>
		.grpDiv {border:1px solid green;}
	</style>
	<script>
	
		/// everything here is copy/pasted from DE and then injected into the same page, so it shared ID - bla - cheat with find

		jQuery(document).ready(function() {
			$("#assigned_date").datepicker();
	

		});

	function typeEvent(oo){
		if (oo=='on'){
			// clicked from "pick event" to "type event"
			// pick event off
			$("#opnPickEventDiv").hide();
			// type event on
			$("#opnEnterEventDiv").show();
			// pick locality on
			$("#opnPickLocalityDiv").show();
			// type locality off
			$("#opnEnterkLocalityDiv").hide();
			
			$("#letype").val('type_event');
		} else {
			// clicked from "type event" to "pick event"
			// pick event on
			$("#opnPickEventDiv").show();
			// type event off
			$("#opnEnterEventDiv").hide();
			// all locality off
			$("#opnPickLocalityDiv").hide();
			$("#opnEnterkLocalityDiv").hide();
			$("#letype").val('pick_event');
		}
	}
	function typeLocality(oo){
		if (oo=='on'){
			// clicked from "pick locality" to "type locality"
			$("#opnPickLocalityDiv").hide();
			$("#opnEnterkLocalityDiv").show();
			$("#letype").val('type_locality');
		} else {
			$("#opnPickLocalityDiv").show();
			$("#opnEnterkLocalityDiv").hide();
			$("#letype").val('pick_locality');
		}
	}



		function pickLL(OrigUnits){
	
			var dms=$("#mptab").find("[id='dms']");
			var ddm=$("#mptab").find("[id='ddm']");
			var dd=$("#mptab").find("[id='dd']");
			var utm=$("#mptab").find("[id='utm']");
			var lat_long_meta=$("#mptab").find("[id='lat_long_meta']");


			dms.hide();
			ddm.hide();
			dd.hide();
			utm.hide();
			lat_long_meta.hide();
			if (OrigUnits == 'deg. min. sec.') {
				lat_long_meta.show();
				dms.show();
			} else if (OrigUnits == 'decimal degrees') {
				lat_long_meta.show();
				dd.show();
			} else if (OrigUnits == 'degrees dec. minutes') {
				lat_long_meta.show();
				ddm.show();
			} else if (OrigUnits == 'UTM') {
				lat_long_meta.show();
				utm.show();
			}
		}

		function saveSpecimenEvent(){
			// serialize everything and send it to the server for processing
			$.ajax({
				url: "/component/Bulkloader.cfc?queryformat=column",
				type: "GET",
				dataType: "json",
				data: {
					method:  "saveNewSpecimenEvent",
					q: $('#theForm').serialize()
			},
			success: function(r) {
				console.log('saved');
				console.log(r);
		},
		error: function (xhr, textStatus, errorThrown){
		    // show error
		    alert(errorThrown);
		  }
		});


		}

	</script>
	
	
	<cfoutput>
	

		
		<cfquery name="ctgeoreference_protocol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select georeference_protocol from ctgeoreference_protocol order by georeference_protocol
		</cfquery>
		<cfquery name="cterror" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	    	select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS order by lat_long_error_units
	    </cfquery>
		<cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
			select datum from ctdatum order by datum
	    </cfquery>
		<cfquery name="ctgeorefmethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select georefmethod from ctgeorefmethod order by georefmethod
	    </cfquery>
		<cfquery name="ctverificationstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select verificationstatus from ctverificationstatus order by verificationstatus
	    </cfquery>

	<cfquery name="ctspecimen_event_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select specimen_event_type from ctspecimen_event_type order by specimen_event_type
	</cfquery>
	<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select COLLECTING_SOURCE from ctcollecting_source order by COLLECTING_SOURCE
     </cfquery>
	
	<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select COLLECTING_SOURCE from ctcollecting_source order by COLLECTING_SOURCE
     </cfquery>
	<cfquery name="ctunits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
       select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS order by orig_lat_long_units
    </cfquery>
	
		<cfquery name="ctOrigElevUnits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	       	select orig_elev_units from ctorig_elev_units
	    </cfquery>
		

		
		<form name="theForm" id="theForm">
		<input type="hidden" id="#uuid#">
		<input type="hidden" name="nothing" id="nothing">
		<input type="hidden" name="letype" id="letype" value="pick_event">
		<br>Add a specimen-event:
		<table id="mptab">
			<tr>
				<td>
					<label for="specimen_event_type">Specimen/Event Type</label>
					<select name="specimen_event_type" id="specimen_event_type" size="1" class="reqdClr">
						<cfloop query="ctspecimen_event_type">
							<option value="#ctspecimen_event_type.specimen_event_type#">#ctspecimen_event_type.specimen_event_type#</option>
					    </cfloop>
					</select>
				</td>
				<td>
					<label for="assigned_by_agent_name">Event Assigned by Agent</label>
					<input type="text" name="assigned_by_agent_name" id="assigned_by_agent_name" class="reqdClr" size="40" value="#session.dbuser#"
						 onchange="getAgent('assigned_by_agent_id','assigned_by_agent_name','theForm',this.value); return false;"
						 onKeyPress="return noenter(event);">
					<input type="hidden" name="assigned_by_agent_id" id="assigned_by_agent_id" value="#session.myAgentId#">
				</td>
				<td>
					<label for="assigned_date">Specimen/Event Assigned Date</label>
					<input type="text" name="assigned_date" id="assigned_date" value="#dateformat(now(),'yyyy-mm-dd')#" class="reqdClr">
				</td>
				<td>
					<label for="VerificationStatus">Verification Status</label>
					<select name="VerificationStatus" id="verificationstatus" size="1" class="reqdClr">
						<option value="unverified">unverified</option>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<label for="specimen_event_remark" class="infoLink">Specimen/Event Remark</label>
					<input type="text" name="specimen_event_remark" id="specimen_event_remark" value="" size="75">
				</td>
				<td colspan="2">
					<label for="habitat">Habitat</label>
					<input type="text" name="habitat" id="habitat" size="75">
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<label for="collecting_source">Collecting Source</label>
					<select name="collecting_source" id="collecting_source" size="1" class="reqdClr">
						<option value=""></option>
						<cfloop query="ctcollecting_source">
							<option value="#ctcollecting_source.COLLECTING_SOURCE#">#ctcollecting_source.COLLECTING_SOURCE#</option>
						</cfloop>
					</select>
				</td>
				<td colspan="2">
					<label for="collecting_method" class="infoLink">Collecting Method</label>
					<input type="text" name="collecting_method" id="collecting_method" value="" size="75">
				</td>
			</tr>
			<tr>
				<td colspan="4">
					<div class="grpDiv" id="opnPickEventDiv" >
					<label for="opnPickEventDiv">Pick a collecting event</label>
						<table width="100%">
							<tr>
								<td  >
									<label for="">Find Collecting Event by Nickname</label>
									<input type="text" name="collecting_event_name" class="" id="collecting_event_name" size="60"
										onchange="findCollEvent('collecting_event_id','theForm','cepick',this.value);">
								</td>
								<td>
									<input type="button" class="picBtn" value="more pick options" onclick="findCollEvent('collecting_event_id','theForm','cepick');">
								</td>
								<td>
									<input type="hidden" id="collecting_event_id" name="collecting_event_id" value="">
									<label for="">(Verbatim Locality of picked Events will go here)</label>
									<input type="text" size="50" name="cepick" class="readClr" readonly="readonly">
								</td>
								<td><input type="button" class="lnkBtn" value="Type Event Instead" onclick="typeEvent('on');"></td>
							</tr>
							
						</table>
					</div>
				</td>
			</tr>
			<tr>
				<td colspan="4">
					<div class="grpDiv" id="opnEnterEventDiv" style="display:none;">
					<label for="opnEnterEventDiv">Create a collecting event</label>
						<table>
							<tr>
								<td colspan="3">
									<label for="verbatim_locality">Verbatim Locality</label>
									<input type="text" name="verbatim_locality" class="reqdClr" size="80" id="verbatim_locality">
								</td>
								<td>
									<input type="button" class="lnkBtn" value="Back to Pick Event" onclick="typeEvent('off');">
								</td>
							</tr>
							<tr>
								<td colspan="2">
									<label for="verbatim_date">VerbatimDate</label>
									<input type="text" name="verbatim_date" class="reqdClr" id="verbatim_date" size="40">
								</td>
								<td>
									<label for="began_date">BeginDate</label>
									<input type="text" name="began_date" class="reqdClr" id="began_date" size="20">
								</td>
								<td>
									<label for="ended_date">EndDate</label>
									<input type="text" name="ended_date" class="reqdClr" id="ended_date" size="20">
								</td>
							</tr>
							<tr>
								<td colspan="3">
									<label for="coll_event_remarks">Collecting Event Remarks</label>
									<input type="text" name="coll_event_remarks" size="80" id="coll_event_remarks">
								</td>
							</tr>
							<tr>
								<td colspan="4">									
									<div class="grpDiv" id="opnPickLocalityDiv">
									<label for="opnPickLocalityDiv">Pick a Locality</label>
										<table>
											<tr>
												<td>
													<label for="locality_name">Pick Locality By Nickname</label>
													<input type="text" name="locality_name" class="" id="locality_name" size="60"
														onchange="LocalityPick('locality_id','pickedSpecloc','theForm',this.value);">
													<input type="button" class="picBtn" value="more pick options" 
														onclick="LocalityPick('locality_id','pickedSpecloc','theForm',''); return false;">
														<input type="hidden" name="locality_id" id="locality_id" class="readClr" size="8">							
												</td>
												<td>
													<label for="pickedSpecloc">Picked SpecificLocality</label>
													<input type="text" name="pickedSpecloc" id="pickedSpecloc" class="readClr" size="60">
													<input type="button" class="lnkBtn" value="Type Locality Instead" onclick="typeLocality('on');">
												</td>
											</tr>
										</table>
										
									</div>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			<tr>
				<td colspan="4" >
					
					<div class="grpDiv" id="opnEnterkLocalityDiv" style="display:none;">
						<label for="opnPickLocalityDiv">Create a Locality</label>
						<table>
							<tr>
								<td>
									<label for="higher_geog">Pick Higher Geography</label>
									<input type="text" name="higher_geog" class="reqdClr" id="higher_geog" size="80"
										onchange="getGeog('nothing',this.id,'dataEntry',this.value)">
										
									<input type="button" class="lnkBtn" value="Pick Locality Instead" onclick="typeLocality('off');">

								</td>
							</tr>
							<tr>
								<td>
									<label for="spec_locality">Specific Locality</label>
									<input type="text" name="spec_locality" class="reqdClr" id="spec_locality" size="80">
								</td>
							</tr>
							<tr>
								<td>
									<label for="locality_remarks">Locality Remarks</label>
									<input type="text" name="locality_remarks" class="" id="locality_remarks" size="80">
								</td>
							</tr>
							<tr>
								<td>
									<table>
										<tr>
											<td>
												<label for+"orig_elev_units">Elevation Units</label>
												<select name="orig_elev_units" size="1" id="orig_elev_units">
													<option value=""></option>
													<cfloop query="ctOrigElevUnits">
														<option value="#orig_elev_units#">#orig_elev_units#</option>
													</cfloop>
												</select>
											</td>
											<td>
												<label for+"minimum_elevation">MinElevation</label>
												<input type="text" name="minimum_elevation" size="4" id="minimum_elevation">
											</td>
											<td>
												<label for+"maximum_elevation">MaxElevation</label>
												<input type="text" name="maximum_elevation" size="4" id="maximum_elevation">
											</td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td>
									<label for="orig_lat_long_units">Coordinate Units</label>
									<select name="orig_lat_long_units" id="orig_lat_long_units"	onChange="pickLL(this.value);">
										<option value=""></option>
										<cfloop query="ctunits">
										  <option value="#ctunits.ORIG_LAT_LONG_UNITS#">#ctunits.ORIG_LAT_LONG_UNITS#</option>
										</cfloop>
									</select>
									<!----
									<span style="font-size:small" class="likeLink" onclick="geolocate()">[ geolocate ]</span>
									<div id="geoLocateResults" style="font-size:small"></div>
									---->
								</td>
							</tr>
							<tr>
								<td>
									<div id="lat_long_meta" style="display:none;">
										<table cellpadding="0" cellspacing="0">
											<tr>
												<td align="right"><span class="f11a">Max Error</span></td>
												<td>
													<input type="text" name="max_error_distance" id="max_error_distance" size="10">
													<select name="max_error_units" size="1" id="max_error_units">
														<option value=""></option>
														<cfloop query="cterror">
														  <option value="#cterror.LAT_LONG_ERROR_UNITS#">#cterror.LAT_LONG_ERROR_UNITS#</option>
														</cfloop>
													</select>
												</td>
											</tr>
											<tr>
												<td align="right"><span class="f11a">Datum</span></td>
												<td>
													<select name="datum" size="1" class="reqdClr" id="datum">
														<option value=""></option>
														<cfloop query="ctdatum">
															<option value="#datum#">#datum#</option>
														</cfloop>
													</select>
												</td>
											</tr>


											<tr>
												<td align="right"><span class="f11a">Georeference Source</span></td>
												<td colspan="3" nowrap="nowrap">
													<input type="text" name="georeference_source" id="georeference_source"  class="reqdClr" size="60">
												</td>
											</tr>
											<tr>
												<td align="right"><span class="f11a">Georeference Protocol</span></td>
												<td>
													<select name="georeference_protocol" size="1" class="reqdClr" style="width:130px" id="georeference_protocol">
														<option value=""></option>
														<cfloop query="ctgeoreference_protocol">
															<option value="#ctgeoreference_protocol.georeference_protocol#">#ctgeoreference_protocol.georeference_protocol#</option>
														</cfloop>
													</select>
												</td>
											</tr>
										</table>
									</div>
									<div id="dms" style="display:none;">
										<table cellpadding="0" cellspacing="0">
											<tr>
												<td align="right"><span class="f11a">Lat Deg</span></td>
												<td>
													<input type="text" name="latdeg" size="4" id="latdeg" class="reqdClr">
												</td>
												<td align="right"><span class="f11a">Min</span></td>
												<td>
													<input type="text"
														 name="LATMIN"
														size="4"
														id="latmin"
														class="reqdClr">
												</td>
												<td align="right"><span class="f11a">Sec</span></td>
												<td>
													<input type="text"
														 name="latsec"
														size="6"
														id="latsec"
														class="reqdClr">
													</td>
												<td align="right"><span class="f11a">Dir</span></td>
												<td>
													<select name="latdir" size="1" id="latdir" class="reqdClr">
														<option value=""></option>
														<option value="N">N</option>
														<option value="S">S</option>
													  </select>
												</td>
											</tr>
											<tr>
												<td align="right"><span class="f11a">Long Deg</span></td>
												<td>
													<input type="text"
														name="longdeg"
														size="4"
														id="longdeg"
														class="reqdClr">
												</td>
												<td align="right"><span class="f11a">Min</span></td>
												<td>
													<input type="text"
														name="longmin"
														size="4"
														id="longmin"
														class="reqdClr">
												</td>
												<td align="right"><span class="f11a">Sec</span></td>
												<td>
													<input type="text"
														 name="longsec"
														size="6"
														id="longsec"
														class="reqdClr">
												</td>
												<td align="right"><span class="f11a">Dir</span></td>
												<td>
													<select name="longdir" size="1" id="longdir" class="reqdClr">
														<option value=""></option>
														<option value="E">E</option>
														<option value="W">W</option>
													  </select>
												</td>
											</tr>
										</table>
									</div>
									<div id="ddm"  style="display:none;">
										<table cellpadding="0" cellspacing="0">
											<tr>
												<td align="right"><span class="f11a">Lat Deg</span></td>
												<td>
													<input type="text"
														 name="decLAT_DEG"
														size="4"
														id="decLAT_DEG"
														class="reqdClr"
														onchange="dataEntry.latdeg.value=this.value;">
												</td>
												<td align="right"><span class="f11a">Dec Min</span></td>
												<td>
													<input type="text"
														name="dec_lat_min"
														 size="8"
														id="dec_lat_min"
														class="reqdClr">
												</td>
												<td align="right"><span class="f11a">Dir</span></td>
												<td>
													<select name="decLAT_DIR"
														size="1"
														id="decLAT_DIR"
														class="reqdClr"
														onchange="dataEntry.latdir.value=this.value;">
														<option value=""></option>
														<option value="N">N</option>
														<option value="S">S</option>
													</select>
												</td>
											</tr>
											<tr>
												<td align="right"><span class="f11a">Long Deg</span></td>
												<td>
													<input type="text"
														name="decLONGDEG"
														size="4"
														id="decLONGDEG"
														class="reqdClr"
														onchange="dataEntry.longdeg.value=this.value;">
												</td>
												<td align="right"><span class="f11a">Dec Min</span></td>
												<td>
													<input type="text"
														name="DEC_LONG_MIN"
														size="8"
														id="dec_long_min"
														class="reqdClr">
												</td>
												<td align="right"><span class="f11a">Dir</span></td>
												<td>
													<select name="decLONGDIR"
														 size="1"
														id="decLONGDIR"
														class="reqdClr"
														onchange="dataEntry.longdir.value=this.value;">
														<option value=""></option>
														<option value="E">E</option>
														<option value="W">W</option>
													</select>
												</td>
											</tr>
										</table>
									</div>
									<div id="dd"  style="display:none;">
										<span class="f11a">Dec Lat</span>
										<input type="text"
											 name="dec_lat"
											size="8"
											id="dec_lat"
											class="reqdClr">
										<span class="f11a">Dec Long</span>
											<input type="text"
												 name="dec_long"
												size="8"
												id="dec_long"
												class="reqdClr">
									</div>
									<div id="utm" style="display:none;">
										<span class="f11a">UTM Zone</span>
										<input type="text"
											 name="utm_zone"
											size="8"
											id="utm_zone"
											class="reqdClr">
										<span class="f11a">UTM E/W</span>
										<input type="text"
											 name="utm_ew"
											size="8"
											id="utm_ew"
											class="reqdClr">
										<span class="f11a">UTM N/S</span>
										<input type="text"
											 name="utm_ns"
											size="8"
											id="utm_ns"
											class="reqdClr">
									</div>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>		
		</table>
		<input type="button" onclick="saveSpecimenEvent()" value="Save Event">
	</form>
			
			
looking for #uuid#


other_id_num_type_4



<!-----

<script>
	function toggleTo(e,v){
		console.log(e);
		console.log(v);
		
		//$("#cat :input").val(v);
		
		
		$("#" + e + " :input").val(v);
		//$("#" + e + " :input").css('style:border 1px solid red;');
		//(v);			
	}
	function toggleAll(v){
		$("select").val(v);
	}
</script>


			
			
<style>
	.fs{
		border:1px solid green;
		margin:1em;
		padding:1em;
	}
	.child{
		padding-left:1em;
	}
</style>

	<cfif action is "nothing">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_dataentry_settings where username='#session.username#'
		</cfquery>
		<cfset noHide="OTHER_ID_NUM_TYPE_1,OTHER_ID_NUM_TYPE_2,OTHER_ID_NUM_TYPE_3,OTHER_ID_NUM_TYPE_4,OTHER_ID_NUM_TYPE_5,PART_CONDITION_1,PART_BARCODE_1,PART_CONTAINER_LABEL_1,PART_LOT_COUNT_1,PART_DISPOSITION_1,PART_REMARK_1,PART_CONDITION_2,PART_BARCODE_2,PART_CONTAINER_LABEL_2,PART_LOT_COUNT_2,PART_DISPOSITION_2,PART_REMARK_2,PART_CONDITION_3,PART_BARCODE_3,PART_CONTAINER_LABEL_3,PART_LOT_COUNT_3,PART_DISPOSITION_3,PART_REMARK_3,PART_CONDITION_4,PART_BARCODE_4,PART_CONTAINER_LABEL_4,PART_LOT_COUNT_4,PART_DISPOSITION_4,PART_REMARK_4,PART_CONDITION_5,PART_BARCODE_5,PART_CONTAINER_LABEL_5,PART_LOT_COUNT_5,PART_DISPOSITION_5,PART_REMARK_5,PART_CONDITION_6,PART_BARCODE_6,PART_CONTAINER_LABEL_6,PART_LOT_COUNT_6,PART_DISPOSITION_6,PART_REMARK_6,PART_CONDITION_7,PART_BARCODE_7,PART_CONTAINER_LABEL_7,PART_LOT_COUNT_7,PART_DISPOSITION_7,PART_REMARK_7,PART_CONDITION_8,PART_BARCODE_8,PART_CONTAINER_LABEL_8,PART_LOT_COUNT_8,PART_DISPOSITION_8,PART_REMARK_8,PART_CONDITION_9,PART_BARCODE_9,PART_CONTAINER_LABEL_9,PART_LOT_COUNT_9,PART_DISPOSITION_9,PART_REMARK_9,PART_CONDITION_10,PART_BARCODE_10,PART_CONTAINER_LABEL_10,PART_LOT_COUNT_10,PART_DISPOSITION_10,PART_REMARK_10,PART_CONDITION_11,PART_BARCODE_11,PART_CONTAINER_LABEL_11,PART_LOT_COUNT_11,PART_DISPOSITION_11,PART_REMARK_11,PART_CONDITION_12,PART_BARCODE_12,PART_CONTAINER_LABEL_12,PART_LOT_COUNT_12,PART_DISPOSITION_12,PART_REMARK_12,RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,ATTRIBUTE_VALUE_1,ATTRIBUTE_UNITS_1,ATTRIBUTE_REMARKS_1,ATTRIBUTE_DATE_1,ATTRIBUTE_DET_METH_1,ATTRIBUTE_DETERMINER_1,ATTRIBUTE_VALUE_2,ATTRIBUTE_UNITS_2,ATTRIBUTE_REMARKS_2,ATTRIBUTE_DATE_2,ATTRIBUTE_DET_METH_2,ATTRIBUTE_DETERMINER_2,ATTRIBUTE_VALUE_3,ATTRIBUTE_UNITS_3,ATTRIBUTE_REMARKS_3,ATTRIBUTE_DATE_3,ATTRIBUTE_DET_METH_3,ATTRIBUTE_DETERMINER_3,ATTRIBUTE_VALUE_4,ATTRIBUTE_UNITS_4,ATTRIBUTE_REMARKS_4,ATTRIBUTE_DATE_4,ATTRIBUTE_DET_METH_4,ATTRIBUTE_DETERMINER_4,ATTRIBUTE_VALUE_5,ATTRIBUTE_UNITS_5,ATTRIBUTE_REMARKS_5,ATTRIBUTE_DATE_5,ATTRIBUTE_DET_METH_5,ATTRIBUTE_DETERMINER_5,ATTRIBUTE_VALUE_6,ATTRIBUTE_UNITS_6,ATTRIBUTE_REMARKS_6,ATTRIBUTE_DATE_6,ATTRIBUTE_DET_METH_6,ATTRIBUTE_DETERMINER_6,ATTRIBUTE_VALUE_7,ATTRIBUTE_UNITS_7,ATTRIBUTE_REMARKS_7,ATTRIBUTE_DATE_7,ATTRIBUTE_DET_METH_7,ATTRIBUTE_DETERMINER_7,ATTRIBUTE_VALUE_8,ATTRIBUTE_UNITS_8,ATTRIBUTE_REMARKS_8,ATTRIBUTE_DATE_8,ATTRIBUTE_DET_METH_8,ATTRIBUTE_DETERMINER_8,ATTRIBUTE_VALUE_9,ATTRIBUTE_UNITS_9,ATTRIBUTE_REMARKS_9,ATTRIBUTE_DATE_9,ATTRIBUTE_DET_METH_9,ATTRIBUTE_DETERMINER_9,ATTRIBUTE_VALUE_10,ATTRIBUTE_UNITS_10,ATTRIBUTE_REMARKS_10,ATTRIBUTE_DATE_10,ATTRIBUTE_DET_METH_10,ATTRIBUTE_DETERMINER_10,GEO_ATT_VALUE_1,GEO_ATT_DETERMINER_1,GEO_ATT_DETERMINED_DATE_1,GEO_ATT_DETERMINED_METHOD_1,GEO_ATT_REMARK_1,GEO_ATT_VALUE_2,GEO_ATT_DETERMINER_2,GEO_ATT_DETERMINED_DATE_2,GEO_ATT_DETERMINED_METHOD_2,GEO_ATT_REMARK_2,GEO_ATT_VALUE_3,GEO_ATT_DETERMINER_3,GEO_ATT_DETERMINED_DATE_3,GEO_ATT_DETERMINED_METHOD_3,GEO_ATT_REMARK_3,GEO_ATT_VALUE_4,GEO_ATT_DETERMINER_4,GEO_ATT_DETERMINED_DATE_4,GEO_ATT_DETERMINED_METHOD_4,GEO_ATT_REMARK_4,GEO_ATT_VALUE_5,GEO_ATT_DETERMINER_5,GEO_ATT_DETERMINED_DATE_5,GEO_ATT_DETERMINED_METHOD_5,GEO_ATT_REMARK_5,GEO_ATT_VALUE_6,GEO_ATT_DETERMINER_6,GEO_ATT_DETERMINED_DATE_6,GEO_ATT_DETERMINED_METHOD_6,GEO_ATT_REMARK_6,DEC_LAT,DEC_LONG,LATDEG,DEC_LAT_MIN,LATMIN,LATSEC,LATDIR,LONGDEG,DEC_LONG_MIN,LONGMIN,LONGSEC,LONGDIR,DATUM,GEOREFERENCE_SOURCE,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,GEOREFERENCE_PROTOCOL,EVENT_ASSIGNED_BY_AGENT,EVENT_ASSIGNED_DATE,VERIFICATIONSTATUS,UTM_ZONE,UTM_EW,UTM_NS,maximum_elevation,minimum_elevation,collector_agent_1,collector_role_1,ACCN,TAXON_NAME,NATURE_OF_ID,ID_MADE_BY_AGENT,VERBATIM_DATE,BEGAN_DATE,ENDED_DATE,HIGHER_GEOG,SPEC_LOCALITY,VERBATIM_LOCALITY,COLL_OBJ_DISPOSITION,CONDITION,COLLECTING_METHOD,COLLECTING_SOURCE,EVENT_ASSIGNED_BY_AGENT,EVENT_ASSIGNED_DATE,SPECIMEN_EVENT_TYPE">
		<cfset cat="CAT_NUM,OTHER_ID_NUM_5,OTHER_ID_NUM_TYPE_5,ACCN">
		<cfset colls="COLLECTOR_AGENT_1,COLLECTOR_ROLE_1,COLLECTOR_AGENT_2,COLLECTOR_ROLE_2,COLLECTOR_AGENT_3,COLLECTOR_ROLE_3,COLLECTOR_AGENT_4,COLLECTOR_ROLE_4,COLLECTOR_AGENT_5,COLLECTOR_ROLE_5">
		<cfset ids="OTHER_ID_NUM_1,OTHER_ID_NUM_TYPE_1,OTHER_ID_NUM_2,OTHER_ID_NUM_TYPE_2,OTHER_ID_NUM_3,OTHER_ID_NUM_TYPE_3,OTHER_ID_NUM_4,OTHER_ID_NUM_TYPE_4">
		<cfset taxa="TAXON_NAME,NATURE_OF_ID,ID_MADE_BY_AGENT,MADE_DATE,IDENTIFICATION_REMARKS">
		<cfset locality="VERBATIM_DATE,BEGAN_DATE,ENDED_DATE,HIGHER_GEOG,SPEC_LOCALITY,VERBATIM_LOCALITY,ORIG_ELEV_UNITS,MAXIMUM_ELEVATION,MINIMUM_ELEVATION,LOCALITY_REMARKS,HABITAT,COLL_EVENT_REMARKS,DEPTH_UNITS,MIN_DEPTH,MAX_DEPTH,COLLECTING_METHOD,COLLECTING_SOURCE,ASSOCIATED_SPECIES,LOCALITY_ID,COLLECTING_EVENT_ID,EVENT_ASSIGNED_BY_AGENT,EVENT_ASSIGNED_DATE,SPECIMEN_EVENT_TYPE">
		<cfset coordinates="ORIG_LAT_LONG_UNITS,DEC_LAT,DEC_LONG,LATDEG,DEC_LAT_MIN,LATMIN,LATSEC,LATDIR,LONGDEG,DEC_LONG_MIN,LONGMIN,LONGSEC,LONGDIR,DATUM,LAT_LONG_REF_SOURCE,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,GEOREFMETHOD,VERIFICATIONSTATUS,UTM_ZONE,UTM_EW,UTM_NS">
		<cfset attributes="ATTRIBUTE_1,ATTRIBUTE_VALUE_1,ATTRIBUTE_UNITS_1,ATTRIBUTE_REMARKS_1,ATTRIBUTE_DATE_1,ATTRIBUTE_DET_METH_1,ATTRIBUTE_DETERMINER_1,ATTRIBUTE_2,ATTRIBUTE_VALUE_2,ATTRIBUTE_UNITS_2,ATTRIBUTE_REMARKS_2,ATTRIBUTE_DATE_2,ATTRIBUTE_DET_METH_2,ATTRIBUTE_DETERMINER_2,ATTRIBUTE_3,ATTRIBUTE_VALUE_3,ATTRIBUTE_UNITS_3,ATTRIBUTE_REMARKS_3,ATTRIBUTE_DATE_3,ATTRIBUTE_DET_METH_3,ATTRIBUTE_DETERMINER_3,ATTRIBUTE_4,ATTRIBUTE_VALUE_4,ATTRIBUTE_UNITS_4,ATTRIBUTE_REMARKS_4,ATTRIBUTE_DATE_4,ATTRIBUTE_DET_METH_4,ATTRIBUTE_DETERMINER_4,ATTRIBUTE_5,ATTRIBUTE_VALUE_5,ATTRIBUTE_UNITS_5,ATTRIBUTE_REMARKS_5,ATTRIBUTE_DATE_5,ATTRIBUTE_DET_METH_5,ATTRIBUTE_DETERMINER_5,ATTRIBUTE_6,ATTRIBUTE_VALUE_6,ATTRIBUTE_UNITS_6,ATTRIBUTE_REMARKS_6,ATTRIBUTE_DATE_6,ATTRIBUTE_DET_METH_6,ATTRIBUTE_DETERMINER_6,ATTRIBUTE_7,ATTRIBUTE_VALUE_7,ATTRIBUTE_UNITS_7,ATTRIBUTE_REMARKS_7,ATTRIBUTE_DATE_7,ATTRIBUTE_DET_METH_7,ATTRIBUTE_DETERMINER_7,ATTRIBUTE_8,ATTRIBUTE_VALUE_8,ATTRIBUTE_UNITS_8,ATTRIBUTE_REMARKS_8,ATTRIBUTE_DATE_8,ATTRIBUTE_DET_METH_8,ATTRIBUTE_DETERMINER_8,ATTRIBUTE_9,ATTRIBUTE_VALUE_9,ATTRIBUTE_UNITS_9,ATTRIBUTE_REMARKS_9,ATTRIBUTE_DATE_9,ATTRIBUTE_DET_METH_9,ATTRIBUTE_DETERMINER_9,ATTRIBUTE_10,ATTRIBUTE_VALUE_10,ATTRIBUTE_UNITS_10,ATTRIBUTE_REMARKS_10,ATTRIBUTE_DATE_10,ATTRIBUTE_DET_METH_10,ATTRIBUTE_DETERMINER_10">
		<cfset specimen="FLAGS,COLL_OBJ_DISPOSITION,CONDITION,COLL_OBJECT_REMARKS,DISPOSITION_REMARKS,RELATIONSHIP,RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE">
		<cfset parts="PART_NAME_1,PART_CONDITION_1,PART_BARCODE_1,PART_CONTAINER_LABEL_1,PART_LOT_COUNT_1,PART_DISPOSITION_1,PART_REMARK_1,PART_NAME_2,PART_CONDITION_2,PART_BARCODE_2,PART_CONTAINER_LABEL_2,PART_LOT_COUNT_2,PART_DISPOSITION_2,PART_REMARK_2,PART_NAME_3,PART_CONDITION_3,PART_BARCODE_3,PART_CONTAINER_LABEL_3,PART_LOT_COUNT_3,PART_DISPOSITION_3,PART_REMARK_3,PART_NAME_4,PART_CONDITION_4,PART_BARCODE_4,PART_CONTAINER_LABEL_4,PART_LOT_COUNT_4,PART_DISPOSITION_4,PART_REMARK_4,PART_NAME_5,PART_CONDITION_5,PART_BARCODE_5,PART_CONTAINER_LABEL_5,PART_LOT_COUNT_5,PART_DISPOSITION_5,PART_REMARK_5,PART_NAME_6,PART_CONDITION_6,PART_BARCODE_6,PART_CONTAINER_LABEL_6,PART_LOT_COUNT_6,PART_DISPOSITION_6,PART_REMARK_6,PART_NAME_7,PART_CONDITION_7,PART_BARCODE_7,PART_CONTAINER_LABEL_7,PART_LOT_COUNT_7,PART_DISPOSITION_7,PART_REMARK_7,PART_NAME_8,PART_CONDITION_8,PART_BARCODE_8,PART_CONTAINER_LABEL_8,PART_LOT_COUNT_8,PART_DISPOSITION_8,PART_REMARK_8,PART_NAME_9,PART_CONDITION_9,PART_BARCODE_9,PART_CONTAINER_LABEL_9,PART_LOT_COUNT_9,PART_DISPOSITION_9,PART_REMARK_9,PART_NAME_10,PART_CONDITION_10,PART_BARCODE_10,PART_CONTAINER_LABEL_10,PART_LOT_COUNT_10,PART_DISPOSITION_10,PART_REMARK_10,PART_NAME_11,PART_CONDITION_11,PART_BARCODE_11,PART_CONTAINER_LABEL_11,PART_LOT_COUNT_11,PART_DISPOSITION_11,PART_REMARK_11,PART_NAME_12,PART_CONDITION_12,PART_BARCODE_12,PART_CONTAINER_LABEL_12,PART_LOT_COUNT_12,PART_DISPOSITION_12,PART_REMARK_12">
		<cfset geol="GEOLOGY_ATTRIBUTE_1,GEO_ATT_VALUE_1,GEO_ATT_DETERMINER_1,GEO_ATT_DETERMINED_DATE_1,GEO_ATT_DETERMINED_METHOD_1,GEO_ATT_REMARK_1,GEOLOGY_ATTRIBUTE_2,GEO_ATT_VALUE_2,GEO_ATT_DETERMINER_2,GEO_ATT_DETERMINED_DATE_2,GEO_ATT_DETERMINED_METHOD_2,GEO_ATT_REMARK_2,GEOLOGY_ATTRIBUTE_3,GEO_ATT_VALUE_3,GEO_ATT_DETERMINER_3,GEO_ATT_DETERMINED_DATE_3,GEO_ATT_DETERMINED_METHOD_3,GEO_ATT_REMARK_3,GEOLOGY_ATTRIBUTE_4,GEO_ATT_VALUE_4,GEO_ATT_DETERMINER_4,GEO_ATT_DETERMINED_DATE_4,GEO_ATT_DETERMINED_METHOD_4,GEO_ATT_REMARK_4,GEOLOGY_ATTRIBUTE_5,GEO_ATT_VALUE_5,GEO_ATT_DETERMINER_5,GEO_ATT_DETERMINED_DATE_5,GEO_ATT_DETERMINED_METHOD_5,GEO_ATT_REMARK_5,GEOLOGY_ATTRIBUTE_6,GEO_ATT_VALUE_6,GEO_ATT_DETERMINER_6,GEO_ATT_DETERMINED_DATE_6,GEO_ATT_DETERMINED_METHOD_6,GEO_ATT_REMARK_6">
		<cfset child="ATTRIBUTE_VALUE_1,ATTRIBUTE_UNITS_1,ATTRIBUTE_REMARKS_1,ATTRIBUTE_DATE_1,ATTRIBUTE_DET_METH_1,ATTRIBUTE_DETERMINER_1,ATTRIBUTE_VALUE_2,ATTRIBUTE_UNITS_2,ATTRIBUTE_REMARKS_2,ATTRIBUTE_DATE_2,ATTRIBUTE_DET_METH_2,ATTRIBUTE_DETERMINER_2,ATTRIBUTE_VALUE_3,ATTRIBUTE_UNITS_3,ATTRIBUTE_REMARKS_3,ATTRIBUTE_DATE_3,ATTRIBUTE_DET_METH_3,ATTRIBUTE_DETERMINER_3,ATTRIBUTE_VALUE_4,ATTRIBUTE_UNITS_4,ATTRIBUTE_REMARKS_4,ATTRIBUTE_DATE_4,ATTRIBUTE_DET_METH_4,ATTRIBUTE_DETERMINER_4,ATTRIBUTE_VALUE_5,ATTRIBUTE_UNITS_5,ATTRIBUTE_REMARKS_5,ATTRIBUTE_DATE_5,ATTRIBUTE_DET_METH_5,ATTRIBUTE_DETERMINER_5,ATTRIBUTE_VALUE_6,ATTRIBUTE_UNITS_6,ATTRIBUTE_REMARKS_6,ATTRIBUTE_DATE_6,ATTRIBUTE_DET_METH_6,ATTRIBUTE_DETERMINER_6,ATTRIBUTE_VALUE_7,ATTRIBUTE_UNITS_7,ATTRIBUTE_REMARKS_7,ATTRIBUTE_DATE_7,ATTRIBUTE_DET_METH_7,ATTRIBUTE_DETERMINER_7,ATTRIBUTE_VALUE_8,ATTRIBUTE_UNITS_8,ATTRIBUTE_REMARKS_8,ATTRIBUTE_DATE_8,ATTRIBUTE_DET_METH_8,ATTRIBUTE_DETERMINER_8,ATTRIBUTE_VALUE_9,ATTRIBUTE_UNITS_9,ATTRIBUTE_REMARKS_9,ATTRIBUTE_DATE_9,ATTRIBUTE_DET_METH_9,ATTRIBUTE_DETERMINER_9,ATTRIBUTE_VALUE_10,ATTRIBUTE_UNITS_10,ATTRIBUTE_REMARKS_10,ATTRIBUTE_DATE_10,ATTRIBUTE_DET_METH_10,ATTRIBUTE_DETERMINER_10,MAXIMUM_ELEVATION,MINIMUM_ELEVATION,RELATED_TO_NUMBER,RELATED_TO_NUM_TYPE,MIN_DEPTH,MAX_DEPTH,OTHER_ID_NUM_TYPE_1,OTHER_ID_NUM_TYPE_2,OTHER_ID_NUM_TYPE_3,OTHER_ID_NUM_TYPE_4,PART_CONDITION_1,PART_BARCODE_1,PART_CONTAINER_LABEL_1,PART_LOT_COUNT_1,PART_DISPOSITION_1,PART_REMARK_1,PART_CONDITION_2,PART_BARCODE_2,PART_CONTAINER_LABEL_2,PART_LOT_COUNT_2,PART_DISPOSITION_2,PART_REMARK_2,PART_CONDITION_3,PART_BARCODE_3,PART_CONTAINER_LABEL_3,PART_LOT_COUNT_3,PART_DISPOSITION_3,PART_REMARK_3,PART_CONDITION_4,PART_BARCODE_4,PART_CONTAINER_LABEL_4,PART_LOT_COUNT_4,PART_DISPOSITION_4,PART_REMARK_4,PART_CONDITION_5,PART_BARCODE_5,PART_CONTAINER_LABEL_5,PART_LOT_COUNT_5,PART_DISPOSITION_5,PART_REMARK_5,PART_CONDITION_6,PART_BARCODE_6,PART_CONTAINER_LABEL_6,PART_LOT_COUNT_6,PART_DISPOSITION_6,PART_REMARK_6,PART_CONDITION_7,PART_BARCODE_7,PART_CONTAINER_LABEL_7,PART_LOT_COUNT_7,PART_DISPOSITION_7,PART_REMARK_7,PART_CONDITION_8,PART_BARCODE_8,PART_CONTAINER_LABEL_8,PART_LOT_COUNT_8,PART_DISPOSITION_8,PART_REMARK_8,PART_CONDITION_9,PART_BARCODE_9,PART_CONTAINER_LABEL_9,PART_LOT_COUNT_9,PART_DISPOSITION_9,PART_REMARK_9,PART_CONDITION_10,PART_BARCODE_10,PART_CONTAINER_LABEL_10,PART_LOT_COUNT_10,PART_DISPOSITION_10,PART_REMARK_10,PART_CONDITION_11,PART_BARCODE_11,PART_CONTAINER_LABEL_11,PART_LOT_COUNT_11,PART_DISPOSITION_11,PART_REMARK_11,PART_CONDITION_12,PART_BARCODE_12,PART_CONTAINER_LABEL_12,PART_LOT_COUNT_12,PART_DISPOSITION_12,PART_REMARK_12,DEC_LAT,DEC_LONG,LATDEG,DEC_LAT_MIN,LATMIN,LATSEC,LATDIR,LONGDEG,DEC_LONG_MIN,LONGMIN,LONGSEC,LONGDIR,DATUM,LAT_LONG_REF_SOURCE,MAX_ERROR_DISTANCE,MAX_ERROR_UNITS,GEOREFMETHOD,VERIFICATIONSTATUS,UTM_ZONE,UTM_EW,UTM_NS,GEO_ATT_VALUE_1,GEO_ATT_DETERMINER_1,GEO_ATT_DETERMINED_DATE_1,GEO_ATT_DETERMINED_METHOD_1,GEO_ATT_REMARK_1,GEO_ATT_VALUE_2,GEO_ATT_DETERMINER_2,GEO_ATT_DETERMINED_DATE_2,GEO_ATT_DETERMINED_METHOD_2,GEO_ATT_REMARK_2,GEO_ATT_VALUE_3,GEO_ATT_DETERMINER_3,GEO_ATT_DETERMINED_DATE_3,GEO_ATT_DETERMINED_METHOD_3,GEO_ATT_REMARK_3,GEO_ATT_VALUE_4,GEO_ATT_DETERMINER_4,GEO_ATT_DETERMINED_DATE_4,GEO_ATT_DETERMINED_METHOD_4,GEO_ATT_REMARK_4,GEO_ATT_VALUE_5,GEO_ATT_DETERMINER_5,GEO_ATT_DETERMINED_DATE_5,GEO_ATT_DETERMINED_METHOD_5,GEO_ATT_REMARK_5,GEO_ATT_VALUE_6,GEO_ATT_DETERMINER_6,GEO_ATT_DETERMINED_DATE_6,GEO_ATT_DETERMINED_METHOD_6,GEO_ATT_REMARK_6,COLLECTOR_ROLE_1,COLLECTOR_ROLE_2,COLLECTOR_ROLE_3,COLLECTOR_ROLE_4,COLLECTOR_ROLE_5,OTHER_ID_NUM_TYPE_5">

		Use this form to customize what you see on data entry and how data carries over when you save a new record. There are (generally)
		three choices in the dropdown for each field:
		<ul>
			<li>hide - remove the field from the data entry screen. 
				It may be possible to have data in hidden fields - use this option with great caution.</li>
			<li>show - show the field, reset to blank each time a record is saved</li>
			<li>carry - show the field, carry last value over after save</li>
		</ul>
		Note that it may be possible to turn off values such that you cannot save a new record, and it may be possible to 
		save a record with (potentially problematic) values in hidden fields.
		
		<p>
			"Linked" fields require only turning off the "parent" element to hide. Turn off elevation units to get
			rid of all elevation fields, or orig_lat_long_units to get rid of all coordinate data, for example. The "child" elements
			will individually remain as "show" but will not appear on the entry form. Child elements are indented under their parent.
		</p>
		<p>
			Attributes 1-6 do different things depending on collection type, and turning them off may do nothing for your account.
			Customize with caution.
		</p>
		<a name="top"></a>
		<div class="fs">
			Set everything on this page with one click: 
			<span class="likeLink" onclick="toggleAll('0')">[ hide everything ]</span>
			<span class="likeLink" onclick="toggleAll('1')">[ show everything ]</span>
			<span class="likeLink" onclick="toggleAll('2')">[ carry everything ]</span>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
		</div>
		<div class="fs">
			Jump To
			<ul>
				<li><a href="##cat">Cataloged Item Identifiers</a></li>
				<li><a href="##taxa">Identification</a></li>
				<li><a href="##coordinates">Coordinates</a></li>
				<li><a href="##colls">Collectors</a></li>
				<li><a href="##geol">Geology</a></li>
				<li><a href="##ids">Identifiers</a></li>
				<li><a href="##attributes">Attributes</a></li>
				<li><a href="##locality">Locality</a></li>				
				<li><a href="##specimen">Cataloged Item</a></li>
				<li><a href="##parts">Parts</a></li>
			</ul>
		</div>
		<form name="customize" method="post" action="customizeDataEntry.cfm">
			<input type="hidden" name="action" value="saveChanges">
			<input type="hidden" name="oldaction" value="#action#">
			<!--- along with required stuff, use this to deal with linked stuff,like elevation --->
			<a name="cat" href="##top">[ top ]</a>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
			<div class="fs" id="cat">
				<!--- cat --->
				<strong>Cataloged Item Identifiers</strong>
				<br><span style="font-size:small;">ID 5 is your Custom ID</span>
				<br>
				<span class="likeLink" onclick="toggleTo('cat','0')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('cat','1')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('cat','2')">[ carry all ]</span>				
				<table border id="_cat">
					<cfloop list="#cat#" index="i">
						<tr>
							<td>
								<div <cfif listfindnocase(child,i)>class="child"</cfif>>#i#</div>
							</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<a name="taxa" href="##top">[ top ]</a>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
			<div class="fs" id="taxa">
				<strong>Identification</strong>
				<br>
				<span class="likeLink" onclick="toggleTo('taxa','0')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('taxa','1')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('taxa','2')">[ carry all ]</span>				
				<table border id="taxa">
					<cfloop list="#taxa#" index="i">
						<tr>
							<td>
								<div <cfif listfindnocase(child,i)>class="child"</cfif>>#i#</div>
							</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<a name="coordinates" href="##top">[ top ]</a>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
			<div class="fs" id="coordinates">
				<!--- coordinates --->
				<strong>Coordinates</strong>
				<br>
				<span class="likeLink" onclick="toggleTo('coordinates','0')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('coordinates','1')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('coordinates','2')">[ carry all ]</span>
				<table border>
					<cfloop list="#coordinates#" index="i">
						<tr>
							<td>
								<div <cfif listfindnocase(child,i)>class="child"</cfif>>#i#</div>
							</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<a name="colls" href="##top">[ top ]</a>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
			<div class="fs" id="colls">
				<!--- colls ---->
				<strong>Collectors</strong>
				<br>
				<span class="likeLink" onclick="toggleTo('colls','0')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('colls','1')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('colls','2')">[ carry all ]</span>
				<table border>
					<cfloop list="#colls#" index="i">
						<tr>
							<td>
								<div <cfif listfindnocase(child,i)>class="child"</cfif>>#i#</div>
							</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<a name="geol" href="##top">[ top ]</a>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
			<div class="fs" id="geol">
				<!--- geol ---->
				<strong>Geology</strong>
				<br>
				<span class="likeLink" onclick="toggleTo('geol','0')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('geol','1')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('geol','2')">[ carry all ]</span>
				<table border>
					<cfloop list="#geol#" index="i">
						<tr>
							<td>
								<div <cfif listfindnocase(child,i)>class="child"</cfif>>#i#</div>
							</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<a name="ids" href="##top">[ top ]</a>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
			<div class="fs" id="ids">
				<!--- ids ---->
				<strong>Other IDs</strong>
				<br>
				<span class="likeLink" onclick="toggleTo('ids','0')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('ids','1')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('ids','2')">[ carry all ]</span>
				<table border>
					<cfloop list="#ids#" index="i">
						<tr>
							<td>
								<div <cfif listfindnocase(child,i)>class="child"</cfif>>#i#</div>
							</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<a name="attributes" href="##top">[ top ]</a>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
			<div class="fs" id="attributes">
				<!--- attributes ---->
				<strong>Attributes</strong>
				<br>
				<span class="likeLink" onclick="toggleTo('attributes','0')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('attributes','1')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('attributes','2')">[ carry all ]</span>
				<table border>
					<cfloop list="#attributes#" index="i">
						<tr>
							<td>
								<div <cfif listfindnocase(child,i)>class="child"</cfif>>#i#</div>
							</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<a name="locality" href="##top">[ top ]</a>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
			<div class="fs" id="locality">
				<!--- locality ---->
				<strong>Locality</strong>
				<br>
				<span class="likeLink" onclick="toggleTo('locality','0')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('locality','1')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('locality','2')">[ carry all ]</span>
				<table border>
					<cfloop list="#locality#" index="i">
						<tr>
							<td>
								<div <cfif listfindnocase(child,i)>class="child"</cfif>>#i#</div>
							</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<a name="specimen" href="##top">[ top ]</a>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
			<div class="fs" id="specimen">
				<!--- specimen ---->
				<strong>Cataloged Item</strong>
				<br>
				<span class="likeLink" onclick="toggleTo('specimen','0')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('specimen','1')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('specimen','2')">[ carry all ]</span>
				<table border>
					<cfloop list="#specimen#" index="i">
						<tr>
							<td>
								<div <cfif listfindnocase(child,i)>class="child"</cfif>>#i#</div>
							</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<a name="parts" href="##top">[ top ]</a>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
			<div class="fs" id="parts">
				<!--- parts ---->
				<strong>Parts</strong>
				<br>
				<span class="likeLink" onclick="toggleTo('parts','0')">[ hide all ]</span>
				<span class="likeLink" onclick="toggleTo('parts','1')">[ show all ]</span>
				<span class="likeLink" onclick="toggleTo('parts','2')">[ carry all ]</span>
				<table border>
					<cfloop list="#parts#" index="i">
						<tr>
							<td>
								<div <cfif listfindnocase(child,i)>class="child"</cfif>>#i#</div>
							</td>
							<td>
								<cfset uservalue=evaluate("d." & i)>
								<select name="#i#" id="#i#">
									<cfif not listfindnocase(noHide,i)>
										<option value="0" <cfif uservalue is 0> selected="selected" </cfif>>hide</option>
									</cfif>
									<option value="1" <cfif uservalue is 1> selected="selected" </cfif>>show</option>
									<option value="2" <cfif uservalue is 2> selected="selected" </cfif>>carry</option>
								</select>
							</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<span class="likeLink" onclick="customize.submit();">[ save and close ]</span>
		</form>
	</cfif>
	<cfif action is "saveChanges">
		<cfquery name="getCols" datasource="uam_god">
			select column_name from sys.user_tab_cols
			where lower(table_name)='cf_dataentry_settings'
			and column_name != 'USERNAME'
			order by internal_column_id
		</cfquery>
		
		<cfset sql = "UPDATE cf_dataentry_settings SET ">
		<cfloop query="getCols">
			<cfif isDefined("form.#column_name#")>
				<cfset thisData = evaluate("form." & column_name)>
				<cfset thisData = replace(thisData,"'","''","all")>
				<cfset sql = "#SQL#,#COLUMN_NAME# = '#thisData#'">
			</cfif>
		</cfloop>
		<cfset sql = "#SQL# where username = '#session.username#'">
		<cfset sql = replace(sql,"UPDATE cf_dataentry_settings SET ,","UPDATE cf_dataentry_settings SET ")>			
		<cfquery name="new" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preservesinglequotes(sql)#
		</cfquery>
		<script>
			parent.closeCust();
		</script>
		<!---<cfquery name="u" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update cf_dataentry_settings set
				numberAgents=#numberAgents#
			where username='#session.username#'
		</cfquery>
		cflocation url="customizeDataEntry.cfm" addtoken="false">
		--->
	</cfif>
	
	
	---->
	
</cfoutput>


</cfif>