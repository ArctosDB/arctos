<cfinclude template="/includes/_header.cfm">
	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>

	<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/themes/base/jquery-ui.css" type="text/css" />


<!----
 <script src="http://code.jquery.com/jquery-1.8.3.js"></script>

this is default and it works

  #sortable { list-style-type: none; margin: 0; padding: 0; width: 450px; }
    #sortable li { margin: 3px 3px 3px 0; padding: 1px; float: left; width: 200px; height: 90px; font-size: 4em; text-align: center; }
	#sortable li.dubbl { margin: 3px 3px 3px 0; padding: 1px; float: left; width: 400px; height: 90px; font-size: 4em; text-align: center; }
---->
    <style>
    #sortable { list-style-type: none; margin: 0; padding: 0; width: 100%; }
    #sortable li { margin: 3px 3px 3px 0; padding: 1px; float: left; width: 45%;}
	#sortable li.dubbl { margin: 3px 3px 3px 0; padding: 1px; float: left; width: 90%;}
    </style>
    <script>
    $(function() {
        $( "#sortable" ).sortable();
        $( "#sortable" ).disableSelection();
    });
    </script>
<cfoutput>

<ul id="sortable">
    <li class="ui-state-default">

	<table cellpadding="0" cellspacing="0" class="fs">
								<tr>
									<td>
										<img src="/images/info.gif" border="0" onClick="getDocs('geology_attributes')" class="likeLink" alt="[ help ]">
										<table cellpadding="0" cellspacing="0">
											<tr>
												<th nowrap="nowrap"><span class="f11a">Geol Att.</span></th>
												<th><span class="f11a">Geol Att. Value</span></th>
												<th><span class="f11a">Determiner</span></th>
												<th><span class="f11a">Date</span></th>
												<th><span class="f11a">Method</span></th>
												<th><span class="f11a">Remark</span></th>
											</tr>
											<cfloop from="1" to="6" index="i">
												<div id="#i#">
												<tr id="d_geology_attribute_#i#">
													<td>
														<select name="geology_attribute_#i#" id="geology_attribute_#i#" size="1" onchange="populateGeology(this.id);">
															<option value=""></option>

														</select>
													</td>
													<td>
														<select name="geo_att_value_#i#" id="geo_att_value_#i#">
														</select>
													</td>
													<td>
														<input type="text"
															name="geo_att_determiner_#i#"
															id="geo_att_determiner_#i#"
															onchange="getAgent('nothing',this.id,'dataEntry',this.value);"
															onkeypress="return noenter(event);">
													</td>
													<td>
														<input type="text"
															name="geo_att_determined_date_#i#"
															id="geo_att_determined_date_#i#"
															size="10">
													</td>
													<td>
														<input type="text"
															name="geo_att_determined_method_#i#"
															id="geo_att_determined_method_#i#"
															size="15">
													</td>
													<td>
														<input type="text"
															name="geo_att_remark_#i#"
															id="geo_att_remark_#i#"
															size="15">
													</td>
												</tr>
												</div>
											</cfloop>
										</table>
									</td>
								</tr>
							</table>
	</li>
    <li class="ui-state-default">


												<table cellpadding="0" cellspacing="0" class="fs" id="d_orig_lat_long_units"><!------- coordinates ------->
																	<tr>
																		<td rowspan="99" valign="top">
																			<img src="/images/info.gif" border="0" onClick="getDocs('lat_long')" class="likeLink" alt="[ help ]">
																		</td>
																		<td>
																			<table>
																				<tr>
																					<td align="right"  valign="top"><span class="f11a">Original&nbsp;lat/long&nbsp;Units</span></td>
																					<td colspan="99" width="100%">
																						<table>
																							<tr>
																								<td valign="top">
																									<select name="orig_lat_long_units" id="orig_lat_long_units"
																										onChange="switchActive(this.value);dataEntry.max_error_distance.focus();">
																										<option value=""></option>
																										<cfloop query="ctunits">
																										  <option value="#ctunits.ORIG_LAT_LONG_UNITS#">#ctunits.ORIG_LAT_LONG_UNITS#</option>
																										</cfloop>
																									</select>
																								</td>
																								<td valign="top">
																									<span style="font-size:small" class="likeLink" onclick="geolocate()">[ geolocate ]</span>
																								</td>
																								<td valign="top">
																									<div id="geoLocateResults" style="font-size:small">geolocate messages go here</div>
																								</td>
																							</tr>
																						</table>
																					</td>
																				</tr>
																			</table>
																		</td>
																	</tr>
																	<tr>
																		<td>
																			<div id="lat_long_meta" class="noShow">
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
																								<cfloop query="ctgeoreference_protocol">
																									<option value="#ctgeoreference_protocol.georeference_protocol#">#ctgeoreference_protocol.georeference_protocol#</option>
																								</cfloop>
																							</select>
																						</td>
																					</tr>
																				</table>
																			</div>
																			<div id="dms" class="noShow">
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
																			<div id="ddm" class="noShow">
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
																			<div id="dd" class="noShow">
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
																			<div id="utm" class="noShow">
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
																</table><!---- /coordinates ---->



	</li>
    <li class="ui-state-default">3</li>
    <li class="ui-state-default">4</li>
    <li class="ui-state-default">5</li>
    <li class="ui-state-default">6</li>
    <li class="ui-state-default">7</li>
    <li class="ui-state-default">8</li>
    <li class="ui-state-default">9</li>
    <li class="ui-state-default">10</li>
    <li class="ui-state-default">11</li>
    <li class="ui-state-default dubbl">

	<table border>
						<tr>
							<td rowspan="99" valign="top">
								<img src="/images/info.gif" border="0" onClick="getDocs('parts')" class="likeLink" alt="[ help ]">
							</td>
							<th><span class="f11a">Part Name</span></th>
							<th><span class="f11a">Condition</span></th>
							<th><span class="f11a">Disposition</span></th>
							<th><span class="f11a">##</span></th>
							<th><span class="f11a">Barcode</span></th>
							<th><span class="f11a">Label</span></th>
							<th><span class="f11a">Remark</span></th>
						</tr>
						<cfloop from="1" to="12" index="i">
							<tr id="d_part_name_#i#">
								<td>
									<input type="text" name="part_name_#i#" id="part_name_#i#"
										 size="25"
										onchange="DEpartLookup(this.id);requirePartAtts('#i#',this.value);"
										onkeypress="return noenter(event);">
								</td>
								<td>
									<input type="text" name="part_condition_#i#" id="part_condition_#i#">
								</td>
								<td>
									<select id="part_disposition_#i#" name="part_disposition_#i#">
										<option value=""></option>

									</select>
								</td>
								<td>
									<input type="text" name="part_lot_count_#i#" id="part_lot_count_#i#" size="1">
								</td>
								<td>
									<input type="text" name="part_barcode_#i#" id="part_barcode_#i#"
										 size="15" onchange="setPartLabel(this.id);">
								</td>
								<td>
									<input type="text" name="part_container_label_#i#" id="part_container_label_#i#" size="10">
								</td>
								<td>
									<input type="text" name="part_remark_#i#" id="part_remark_#i#" size="40">
								</td>
							</tr>
						</cfloop>
					</table>

	</li>
</ul>

	</cfoutput>