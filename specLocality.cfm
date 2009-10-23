<cfinclude template="/includes/alwaysInclude.cfm">

<script language="JavaScript" src="/includes/jquery/jquery.ui.core.min.js" type="text/javascript"></script>
<script language="JavaScript" src="/includes/jquery/jquery.ui.datepicker.min.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		jQuery(function() {
			jQuery("#began_date").datepicker();
			jQuery("#ended_date").datepicker();	
			jQuery("#determined_date").datepicker();
			$(":input[id^='geology_attribute_']").each(function(e){
				console.log(e);	
			}
		});
	});
	
</script>
	
<cf_showMenuOnly>
	
<span class="pageHelp likeLink" onClick="getDocs('pageHelp/specLocality');">
	Page Help
</span>
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
		parent.dyniframesize();
	}
</script>
<cfif #Action# is "nothing">
<cfoutput> 
	<cfquery name="l" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
    	select 
			collection_object_id,
			collecting_event_id,
			LOCALITY_ID,
			geog_auth_rec_id,
			MAXIMUM_ELEVATION,
			MINIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			SPEC_LOCALITY,
			LOCALITY_REMARKS,
			DEPTH_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			NOGEOREFBECAUSE,
			LAT_LONG_ID,
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
			DATUM,
			ORIG_LAT_LONG_UNITS,
			DETERMINED_BY_AGENT_ID,
			coordinate_determiner,
			DETERMINED_DATE,
			LAT_LONG_REMARKS,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
			ACCEPTED_LAT_LONG_FG,
			EXTENT,
			GPSACCURACY,
			GEOREFMETHOD,
			VERIFICATIONSTATUS,
			LAT_LONG_REF_SOURCE,
			HIGHER_GEOG,
			BEGAN_DATE,
			ENDED_DATE,
			VERBATIM_DATE,
			VERBATIM_LOCALITY,
			COLL_EVENT_REMARKS,
			COLLECTING_SOURCE,
			COLLECTING_METHOD,
			HABITAT_DESC
		from 
			spec_with_loc
		where 
			collection_object_id = #collection_object_id#
		group by
			collection_object_id,
			collecting_event_id,
			LOCALITY_ID,
			geog_auth_rec_id,
			MAXIMUM_ELEVATION,
			MINIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			SPEC_LOCALITY,
			LOCALITY_REMARKS,
			DEPTH_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			NOGEOREFBECAUSE,
			LAT_LONG_ID,
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
			DATUM,
			ORIG_LAT_LONG_UNITS,
			DETERMINED_BY_AGENT_ID,
			coordinate_determiner,
			DETERMINED_DATE,
			LAT_LONG_REMARKS,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
			ACCEPTED_LAT_LONG_FG,
			EXTENT,
			GPSACCURACY,
			GEOREFMETHOD,
			VERIFICATIONSTATUS,
			LAT_LONG_REF_SOURCE,
			HIGHER_GEOG,
			BEGAN_DATE,
			ENDED_DATE,
			VERBATIM_DATE,
			VERBATIM_LOCALITY,
			COLL_EVENT_REMARKS,
			COLLECTING_SOURCE,
			COLLECTING_METHOD,
			HABITAT_DESC
	</cfquery>
	<cfquery name="g" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			spec_with_loc
		where 
			collection_object_id = #collection_object_id# and
			GEOLOGY_ATTRIBUTE is not null
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
	<cfquery name="ctElevUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select orig_elev_units from ctorig_elev_units
	</cfquery>
	<cfquery name="ctdepthUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select depth_units from ctdepth_units
	</cfquery>
     <cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
        select datum from ctdatum 
     </cfquery>
	<cfquery name="ctGeorefMethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select georefMethod from ctgeorefmethod
	</cfquery>
	<cfquery name="ctVerificationStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select VerificationStatus from ctVerificationStatus
	</cfquery>
     <cfquery name="cterror" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
        select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS 
     </cfquery>
     <cfquery name="ctew" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
        select e_or_w from ctew 
     </cfquery>
     <cfquery name="ctns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
        select n_or_s from ctns 
     </cfquery>
     <cfquery name="ctunits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
        select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS 
     </cfquery>
	<cfquery name="ctcollecting_source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
        select COLLECTING_SOURCE from ctcollecting_source 
     </cfquery>
	<cfquery name="ctgeology_attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select geology_attribute from ctgeology_attribute order by geology_attribute
	</cfquery>
		
	<cfform name="loc" method="post" action="specLocality.cfm">
		<input type="hidden" name="action" value="saveChange">
		<input type="hidden" name="nothing" id="nothing">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
<table>
	<tr>
		<td valign="top"><!--- left half of page ---> 	
<table>
		<tr>
			<td>
				<label for="higher_geog">
					<a href="javascript:void(0);" onClick="getDocs('higher_geography')">
						Higher Geography</a>
						&nbsp;&nbsp;
					<a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#l.geog_auth_rec_id#" target="_blank">
						Edit Higher Geography</a>
				</label>
				<input type="text" id="higher_geog" name="higher_geog" size="75" value="#l.higher_geog#" class="reqdClr"
					onchange="getGeog('nothing','higher_geog','loc',this.value); return false;">
			</td>
		</tr>
		<tr>
			<td>
				<label for="spec_locality">
					<a href="javascript:void(0);" onClick="getDocs('locality','specific_locality')">
						Specific Locality</a>
						&nbsp;&nbsp;
					<a href="editLocality.cfm?locality_id=#l.locality_id#" target="_blank">
						Edit Locality</a>
				</label>
				<cfinput type="text" 
					name="spec_locality" 
					id="spec_locality"
					value="#stripQuotes(l.spec_locality)#"  
					size="75" 
					required="true" 
					message="Specific Locality is required.">
			</td>
		</tr>
		<tr>
			<td>
				<label for="verbatim_locality">
					<a href="javascript:void(0);" onClick="getDocs('locality','verbatim_locality')">
						Verbatim Locality</a>
						&nbsp;&nbsp;
					<a href="Locality.cfm?Action=editCollEvnt&collecting_event_id=#l.collecting_event_id#" target="_blank">
						Edit Collecting Event</a>
				</label>
				<cfinput type="text" 
					name="verbatim_locality" 
					id="verbatim_locality"
					value="#stripQuotes(l.verbatim_locality)#"  
					size="75"
					required="true" 
					message="Verbatim Locality is required.">
			</td>
		</tr>
		<tr>
			<td>
				<label for="verbatim_date">
						<a href="javascript:void(0);" onClick="getDocs('locality','verbatim_date')">
							Verbatim Date</a>
				</label>
				<cfinput type="text" 
					name="verbatim_date"
					id="verbatim_date" 
					value="#stripQuotes(l.verbatim_date)#"  
					size="75"
					required="true" 
					message="Verbatim Date is a required text field.">
			</td>
		</tr>
		<tr>
			<td>
				<table>
					<td>
							<label for="began_date"><a href="javascript:void(0);" onClick="getDocs('locality','began_date')">
								Began Date</a></label>
							<cfinput type="text"  
								name="began_date"
								id="began_date"
								value="#dateformat(l.began_date,'dd mmm yyyy')#"
								class="reqdClr"
								required="true" 
								message="Began Date is a required Date field.">										
						</td>
						<td>
							<label for="ended_date">
								<a href="javascript:void(0);" onClick="getDocs('locality','ended_date')">
									Ended Date</a>
							</label>
							<cfinput type="text" 
								name="ended_date"
								id="ended_date" 
								value="#dateformat(l.ended_date,'dd mmm yyyy')#"
								class="reqdClr"
								required="true" 
								message="Ended Date is a required Date field.">
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<label for="coll_event_remarks">
					Collecting Event Remarks
				</label>
				<input type="text" 
					name="coll_event_remarks"
						id="coll_event_remarks" 
					value="#stripQuotes(l.COLL_EVENT_REMARKS)#"  
					size="75">
			</td>
		</tr>
		<tr>
			<td>
				<label for="collecting_source">
					<a href="javascript:void(0);" 
						onClick="getDocs('collecting_source','collecting_method')">Collecting Source</a>
				</label>
				<select name="collecting_source" id="collecting_source" size="1" class="reqdClr">
					<option value=""></option>
                    <cfloop query="ctcollecting_source">
                      <option <cfif #ctcollecting_source.COLLECTING_SOURCE# is "#l.COLLECTING_SOURCE#"> selected </cfif>
						value="#ctcollecting_source.COLLECTING_SOURCE#">#ctcollecting_source.COLLECTING_SOURCE#</option>
                    </cfloop>
                  </select>
			</td>
		</tr>
			<td>
				<label for="collecting_method">
					<a href="javascript:void(0);" 
						onClick="getDocs('collecting_event','collecting_method')">Collecting Method</a>
				</label>
				<input type="text" 
					name="collecting_method" 
					id="collecting_method"
					value="#stripQuotes(l.COLLECTING_METHOD)#"  
					size="75">
			</td>
		</tr>
		<tr>
			<td>
				<label for="habitat_desc">
					<a href="javascript:void(0);" 
						onClick="getDocs('collecting_event','habitat')">Habitat</a>
				</label>
				<input type="text" 
					name="habitat_desc" 
					id="habitat_desc"
					value="#stripQuotes(l.habitat_desc)#"  
					size="75">
			</td>
		</tr>
		<tr> 
            <td>
				<table>
					<tr>
						<td>
							<label for="minimum_elevation">
								<a href="javascript:void(0);" class="novisit" onClick="getDocs('locality','elevation')">
									Minimum Elevation</a>
							</label>
							<cfinput 
								type="text"
								name="minimum_elevation"
								id="minimum_elevation"
								value="#l.MINIMUM_ELEVATION#"
								size="5" 
								validate="numeric"
								message="Minimum Elevation is a number.">
						</td>
						<td>
							<label for="maximum_elevation">
								<a href="javascript:void(0);" class="novisit" onClick="getDocs('locality','elevation')">
									Maximum Elevation</a>
							</label>
							<cfinput type="text" 
								id="maximum_elevation"
								name="maximum_elevation" 
								value="#l.MAXIMUM_ELEVATION#" 
								size="5" 
								validate="numeric"
								message="Maximum Elevation is a number.">
						</td>
						<td>
							<label for="orig_elev_units">
								<a href="javascript:void(0);" class="novisit" onClick="getDocs('locality','elevation')">
									Elevation Units</a>
							</label>
							<select name="orig_elev_units" id="orig_elev_units" size="1">
								<option value=""></option>
			                    <cfloop query="ctElevUnit">
			                      <option <cfif #ctelevunit.orig_elev_units# is "#l.orig_elev_units#"> selected </cfif>
									value="#ctElevUnit.orig_elev_units#">#ctElevUnit.orig_elev_units#</option>
			                    </cfloop>
			                </select>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr> 
            <td>
				<table>
					<tr>
						<td>
							<label for="min_depth" onClick="getDocs('locality','depth')" class="likeLink">
									Minimum Depth
							</label>
							<cfinput type="text" name="min_depth" id="min_depth" value="#l.min_depth#" size="3"									
								validate="numeric"
								message="Minimum Depth is a number.">
						</td>
						<td>
							<label for="max_depth"  onClick="getDocs('locality','depth')" class="likeLink">
									Maximum Depth
							</label>
							<cfinput type="text" id="max_depth" name="max_depth" 
								value="#l.max_depth#" size="3"								
								validate="numeric"
								message="Maximum Depth is a number.">
						</td>
						<td>
							<label for="depth_units" onClick="getDocs('locality','depth')" class="likeLink">
									Depth Units
							</label>
							<select name="depth_units" id="depth_units" size="1">
								<option value=""></option>
			                    <cfloop query="ctdepthUnit">
			                      <option <cfif #ctdepthUnit.depth_units# is "#l.depth_units#"> selected </cfif>
									value="#ctdepthUnit.depth_units#">#ctdepthUnit.depth_units#</option>
			                    </cfloop>
			                </select>
						</td>
					</tr>
				</table>
			</td>
		</tr>	
		<tr> 
        	<td>
				<label for="locality_remarks">Locality Remarks</label>
				<input type="text" name="locality_remarks" id="locality_remarks" value="#l.LOCALITY_REMARKS#"  size="75">
			</td>
        </tr>
		<tr> 
            <td>
				<label for="NoGeorefBecause" class="likeLink" onClick="getDocs('locality','nogeorefbecause')">
					Not Georefererenced Because
				</label>
				<input type="text" name="NoGeorefBecause" value="#l.NoGeorefBecause#"  size="75">
				<cfif #len(l.orig_lat_long_units)# gt 0 AND len(#l.NoGeorefBecause#) gt 0>
					<div style="background-color:red">
						NoGeorefBecause should be NULL for localities with georeferences.
						Please review this locality and update accordingly.
					</div>
				<cfelseif #len(l.orig_lat_long_units)# is 0 AND len(#l.NoGeorefBecause#) is 0>
					<div style="background-color:red">
						Please georeference this locality or enter a value for NoGeorefBecause.
					</div>
				</cfif>
			</td>
		</tr>
		</table>
	</td>
	<td valign="top">
		<table>
		<tr>
			<td>
				<label for="ORIG_LAT_LONG_UNITS" class="likeLink" onClick="getDocs('lat_long','original_units')">
					Original Coordinate Units
				</label>
				<cfset thisUnits = #l.ORIG_LAT_LONG_UNITS#>
				<select name="ORIG_LAT_LONG_UNITS" id="ORIG_LAT_LONG_UNITS" size="1" class="reqdClr" onchange="showLLFormat(this.value)">
	            	<option value="">Not Georeferenced</option>
	            	<cfloop query="ctunits">
	                	<option 
						  	<cfif #thisUnits# is "#ctunits.ORIG_LAT_LONG_UNITS#"> selected </cfif>value="#ctunits.ORIG_LAT_LONG_UNITS#">#ctunits.ORIG_LAT_LONG_UNITS#</option>
	                </cfloop>
	            </select>				
			</td>
		</tr>
	<table>
	<table id="llMeta" style="display:none;">
		<tr>
			<td>
				<label for="coordinate_determiner" class="likeLink" onClick="getDocs('lat_long','determiner')">
					Coordinate Determiner
				</label>
				<input type="text" 
					name="coordinate_determiner" 
					id="coordinate_determiner"
					class="reqdClr" value="#l.coordinate_determiner#" size="40"
					 onchange="getAgent('DETERMINED_BY_AGENT_ID','coordinate_determiner','loc',this.value); return false;"
					 onKeyPress="return noenter(event);">
					<input type="hidden" name="DETERMINED_BY_AGENT_ID" value="#l.DETERMINED_BY_AGENT_ID#">
			</td>
			<td>
				<label for="DETERMINED_DATE" class="likeLink" onClick="getDocs('lat_long','date')">
					Determined Date
				</label>
				<input type="text" name="determined_date" id="determined_date"
					value="#dateformat(l.determined_date,'dd mmm yyyy')#" class="reqdClr">
			</td>
		</tr>
		<tr>
			<td>
				<label for="MAX_ERROR_DISTANCE" class="likeLink" onClick="getDocs('lat_long','maximum_error')">
					Maximum Error
				</label>
				<input type="text" name="MAX_ERROR_DISTANCE" id="MAX_ERROR_DISTANCE" value="#l.MAX_ERROR_DISTANCE#" size="6">
				<select name="MAX_ERROR_UNITS" size="1">
					<option value=""></option>
				    	<cfloop query="cterror">
				        	<option <cfif #cterror.LAT_LONG_ERROR_UNITS# is "#l.MAX_ERROR_UNITS#"> selected </cfif>
								value="#cterror.LAT_LONG_ERROR_UNITS#">#cterror.LAT_LONG_ERROR_UNITS#</option>
				        </cfloop>
				</select> 
			</td>
			<td>
				<label for="DATUM" class="likeLink" onClick="getDocs('lat_long','datum')">
					Datum
				</label>
				<cfset thisDatum = #l.DATUM#>
				<select name="DATUM" id="DATUM" size="1" class="reqdClr">
					<option value=""></option>
				    <cfloop query="ctdatum">
						<option <cfif #ctdatum.DATUM# is "#thisDatum#"> selected </cfif> 
							value="#ctdatum.DATUM#">#ctdatum.DATUM#</option>
				    </cfloop>
				</select> 
			</td>
		</tr>
		<tr>
			<td>
				<label for="georefMethod" class="likeLink" onClick="getDocs('lat_long','georefMethod')">
					Georeference Method
				</label>
				<cfset thisGeoMeth = #l.georefMethod#>
				<select name="georefMethod" id="georefMethod" size="1" class="reqdClr">
					<cfloop query="ctGeorefMethod">
						<option 
						<cfif #thisGeoMeth# is #ctGeorefMethod.georefMethod#> selected </cfif>
							value="#georefMethod#">#georefMethod#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<label for="extent" class="likeLink" onClick="getDocs('lat_long','extent')">
					Extent
				</label>
				<input type="text" name="extent" id="extent" value="#l.extent#" size="7">
			</td>
		</tr>
		<tr>
			<td>
				<label for="GpsAccuracy" class="likeLink" onClick="getDocs('lat_long','gps_accuracy')">
					GPS Accuracy
				</label>
				<input type="text" name="GpsAccuracy" id="GpsAccuracy" value="#l.GpsAccuracy#" size="7">
			</td>
			<td>
				<label for="VerificationStatus" class="likeLink" onClick="getDocs('lat_long','verification_status')">
					Verification Status
				</label>
				<cfset thisVerificationStatus = #l.VerificationStatus#>
				<select name="VerificationStatus" id="VerificationStatus" size="1" class="reqdClr">
					<cfloop query="ctVerificationStatus">
						<option 
							<cfif #thisVerificationStatus# is #ctVerificationStatus.VerificationStatus#> selected </cfif>
								value="#VerificationStatus#">#VerificationStatus#</option>
					</cfloop>
			  	</select>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<label for="LAT_LONG_REF_SOURCE" class="likeLink" onClick="getDocs('lat_long','source')">
					Reference
				</label>
				<input type="text" name="LAT_LONG_REF_SOURCE" id="LAT_LONG_REF_SOURCE" size="90" class="reqdClr"
					value='#preservesinglequotes(l.LAT_LONG_REF_SOURCE)#' />
			</td>
		</tr>
        <tr> 
			<td colspan="3">
				<label for="LAT_LONG_REMARKS" class="likeLink" onClick="getDocs('lat_long','remarks')">
					Remarks
				</label>
				<input type="text" 
					name="LAT_LONG_REMARKS" 
					id="LAT_LONG_REMARKS"
					value='#preservesinglequotes(l.LAT_LONG_REMARKS)#' 
					size="90">
			</td>
		</tr>
	</table>
	<table id="decdeg" style="display:none;">
		<tr> 
			<td>
				<label for="dec_lat">Decimal Latitude</label>
				<cfinput 
					type="text"
					name="dec_lat"
					id="dec_lat"
					value="#l.dec_lat#"
					class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="dec_long">Decimal Longitude</label>
				<cfinput
					type="text" 
					name="DEC_LONG"
					value="#l.DEC_LONG#"
					id="dec_long"
					class="reqdClr"
					validate="numeric">
			</td>
		</tr>
	</table>
	<table id="dms" style="display:none;">
		<tr> 
			<td>
				<label for="lat_deg">Lat. Deg.</label>
				<cfinput type="text" name="LAT_DEG" value="#l.LAT_DEG#" size="4" id="lat_deg" class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="lat_min">Lat. Min.</label>
				<cfinput type="text" name="LAT_MIN" value="#l.LAT_MIN#" size="4" id="lat_min" class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="lat_sec">Lat. Sec.</label>
				<cfinput type="text" name="LAT_SEC" value="#l.LAT_SEC#" id="lat_sec" class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="lat_dir">Lat. Dir.</label>
				<select name="LAT_DIR" size="1" id="lat_dir"  class="reqdClr">
					<option value=""></option>
			        <option <cfif #l.LAT_DIR# is "N"> selected </cfif>value="N">N</option>
			        <option <cfif #l.LAT_DIR# is "S"> selected </cfif>value="S">S</option>
			    </select>
			</td>
		</tr>
		<tr>
			<td>
				<label for="long_deg">Long. Deg.</label>
				<cfinput type="text" name="LONG_DEG" value="#l.LONG_DEG#" size="4" id="long_deg" class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="long_min">Long. Min.</label>
				<cfinput type="text" name="LONG_MIN" value="#l.LONG_MIN#" size="4" id="long_min" class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="long_sec">Long. Sec.</label>
				<cfinput type="text" name="LONG_SEC" value="#l.LONG_SEC#" id="long_sec"  class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="long_dir">Long. Dir.</label>
				<select name="LONG_DIR" size="1" id="long_dir" class="reqdClr">
			    	<option value=""></option>
			        <option <cfif #l.LONG_DIR# is "E"> selected </cfif>value="E">E</option>
			        <option <cfif #l.LONG_DIR# is "W"> selected </cfif>value="W">W</option>
			    </select>
			</td>
		</tr>
	</table>
	<table id="ddm" style="display:none;">
		<tr> 
			<td>
				<label for="dmlat_deg">Lat. Deg.<label>
				<input type="text" name="dmLAT_DEG" value="#l.LAT_DEG#" size="4" id="dmlat_deg" class="reqdClr">
			</td>
			<td>
				<label for="dec_lat_min">Lat. Dec. Min.<label>
				<cfinput type="text" name="DEC_LAT_MIN" value="#l.DEC_LAT_MIN#" id="dec_lat_min" class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="dmlat_dir">Lat. Dir.<label>
				<select name="dmLAT_DIR" size="1" id="dmlat_dir" class="reqdClr">
                	<option value=""></option>
                   	<option <cfif #l.LAT_DIR# is "N"> selected </cfif>value="N">N</option>
                   	<option <cfif #l.LAT_DIR# is "S"> selected </cfif>value="S">S</option>
                 </select>
			</td>
		</tr>
		<tr>
			<td>
				<label for="dmlong_deg">Long. Deg.<label>
				<cfinput type="text" name="dmLONG_DEG" value="#l.LONG_DEG#" size="4" id="dmlong_deg" class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="dec_long_min">Long. Dec. Min.<label>
				<cfinput type="text" name="DEC_LONG_MIN" value="#l.DEC_LONG_MIN#" id="dec_long_min" class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="dmlong_dir">Long. Dir.<label>
				<select name="dmLONG_DIR" size="1" id="dmlong_dir" class="reqdClr">
					<option value=""></option>
				    <option <cfif #l.LONG_DIR# is "E"> selected </cfif>value="E">E</option>
				    <option <cfif #l.LONG_DIR# is "W"> selected </cfif>value="W">W</option>
				</select>
			</td>
		</tr>
	</table>
	<table id="utm" style="display:none;">
		<tr> 
			<td>
				<label for="utm_zone">UTM Zone<label>
				<cfinput type="text" name="UTM_ZONE" value="#l.UTM_ZONE#" id="utm_zone" class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="utm_ew">UTM East/West<label>
				<cfinput type="text" name="UTM_EW" value="#l.UTM_EW#" id="utm_ew" class="reqdClr"
					validate="numeric">
			</td>
			<td>
				<label for="utm_ns">UTM North/South<label>
				<cfinput type="text" name="UTM_NS" value="#l.UTM_NS#" id="utm_ns" class="reqdClr"
					validate="numeric">
			</td>
		</tr>
	</td>
</table>
<label for="gTab">Geology<label>
<table id="gTab" border="1" cellpadding="0" cellspacing="0">
	<tr>
		<td>Attribute</td>
		<td>Value</td>
		<td>Determiner</td>
		<td>Date</td>	
		<td>Method</td>
		<td>Remark</td>
		<td></td>
	</tr>
	<cfloop query="g">
	<tr>
		<td>
			<cfset thisAttribute=g.geology_attribute>
			<select name="geology_attribute__#geology_attribute_id#" 
				id="geology_attribute__#geology_attribute_id#" size="1" class="reqdClr">
				<option value="">DELETE THIS ROW</option>
				<cfloop query="ctgeology_attribute">
					<option 
					<cfif thisAttribute is geology_attribute> selected="selected" </cfif>
						value="#geology_attribute#">#geology_attribute#</option>
				</cfloop>
			</select>			
		</td>
		<td>
			<input type="text" id="geo_att_value__#geology_attribute_id#" class="reqdClr"
				name="geo_att_value__#geology_attribute_id#" value="#geo_att_value#">
		</td>
		<td>
			<input type="text" id="geo_att_determiner__#geology_attribute_id#"
				name="geo_att_determiner__#geology_attribute_id#" value="#geo_att_determiner#"
				size="15"
				onchange="getAgent('geo_att_determiner_id__#geology_attribute_id#','geo_att_determiner__#geology_attribute_id#','loc',this.value); return false;">
			<input type="hidden" name="geo_att_determiner_id__#geology_attribute_id#"
				id="geo_att_determiner_id__#geology_attribute_id#" value="#geo_att_determiner_id#">
		</td>
		<td>
			<input type="text" id="geo_att_determined_date__#geology_attribute_id#"
				name="geo_att_determined_date__#geology_attribute_id#" 
				value="#dateformat(geo_att_determined_date,'dd mmm yyyy')#"
				size="10">
		</td>	
		<td>
			<input type="text" id="geo_att_determined_method__#geology_attribute_id#"
				name="geo_att_determined_method__#geology_attribute_id#" value="#geo_att_determined_method#"
				size="10">
				
		</td>
		<td>
			
			<input type="text" id="geo_att_remark__#geology_attribute_id#"
				name="geo_att_remark__#geology_attribute_id#" value="#geo_att_remark#"
				size="10">		
		</td>
		<td>
			<img src="/images/del.gif" class="likeLink" onclick="document.getElementById('geology_attribute__#geology_attribute_id#').value='';">
		</td>
	</tr>
		</cfloop>
	<tr class="newRec">
		<td colspan="6">New Geology Attribute</td>
	</tr>
	<tr  class="newRec">
		<td>
			<select name="geology_attribute" 
				id="geology_attribute" size="1" class="reqdClr">
				<option value=""></option>
				<cfloop query="ctgeology_attribute">
					<option value="#geology_attribute#">#geology_attribute#</option>
				</cfloop>
			</select>			
		</td>
		<td>
			<input type="text" id="geo_att_value" class="reqdClr"
				name="geo_att_value">
		</td>
		<td>
			<input type="text" id="geo_att_determiner"
				name="geo_att_determiner"
				size="15"
				onchange="getAgent('geo_att_determiner_id','geo_att_determiner','loc',this.value); return false;">
			<input type="hidden" name="geo_att_determiner_id"
				id="geo_att_determiner_id">
		</td>
		<td>
			<input type="text" id="geo_att_determined_date"
				name="geo_att_determined_date" 
				size="10">
		</td>	
		<td>
			<input type="text" id="geo_att_determined_method"
				name="geo_att_determined_method"
				size="10">	
		</td>
		<td>
			<input type="text" id="geo_att_remark"
				name="geo_att_remark"
				size="10">		
		</td>
		
	</tr>


</table>
</td>
	</tr>
	<tr>
		<td colspan="2" align="center">
			<input type="submit" value="Save Changes" class="savBtn"
   				onmouseover="this.className='savBtn btnhov';this.focus();" onmouseout="this.className='savBtn'">	
		</td>
	</tr>
</table> 
  	
	
	</cfform>
	<script>
		showLLFormat('#l.ORIG_LAT_LONG_UNITS#');	
	</script>
	</cfoutput>
</cfif> 		
      <!---------------------------------------------------------------------------------------------------->
<cfif #action# is "saveChange">
<cfoutput>
	
<cfset btime=now()>
	
	<cfset maxNumGeolAtts=10><!--- wild overestimation of the maximum number of geologic attributes; guess high or this form dies --->
	<cftransaction>
		<cfquery name="old"  datasource="uam_god">
			SELECT 
				locality_id, 
				collecting_event_id 
			FROM
	    		spec_with_loc 
	    	WHERE collection_object_id=#collection_object_id#
		</cfquery>
		<cfquery name="geog"  datasource="uam_god">
			select min(geog_auth_rec_id) geog_auth_rec_id from geog_auth_rec where higher_geog = '#escapeQuotes(higher_geog)#'
		</cfquery>
		<cfif len(geog.geog_auth_rec_id) is 0>
			<div class="error">Geography not found.</div>
			<cfabort>
		<cfelse>
			<cfset nGeogId=geog.geog_auth_rec_id>
		</cfif>
		<cfset fLocS="select min(locality_id) locality_id 
				FROM 
					loc_acc_lat_long
				WHERE
    				geog_auth_rec_id = #nGeogId# AND
    				NVL(MAXIMUM_ELEVATION,-1) = NVL('#maximum_elevation#',-1) AND
					NVL(MINIMUM_ELEVATION,-1) = NVL('#minimum_elevation#',-1) AND
					NVL(ORIG_ELEV_UNITS,'NULL') = NVL('#orig_elev_units#','NULL') AND
					NVL(MIN_DEPTH,-1) = nvl('#min_depth#',-1) AND
					NVL(MAX_DEPTH,-1) = nvl('#max_depth#',-1) AND
					NVL(SPEC_LOCALITY,'NULL') = NVL('#escapeQuotes(spec_locality)#','NULL') AND
					NVL(LOCALITY_REMARKS,'NULL') = NVL('#escapeQuotes(locality_remarks)#','NULL') AND
					NVL(DEPTH_UNITS,'NULL') = NVL('#depth_units#','NULL') AND 
					NVL(NOGEOREFBECAUSE,'NULL') = NVL('#escapeQuotes(nogeorefbecause)#','NULL')  AND
					NVL(orig_lat_long_units,'NULL') = NVL('#orig_lat_long_units#','NULL') AND
					NVL(datum,'NULL') = NVL('#datum#','NULL') AND
					NVL(determined_by_agent_id,-1) = nvl('#determined_by_agent_id#',-1) AND
					NVL(determined_date,'1-JAN-1600') = NVL(to_date('#determined_date#'),'1-JAN-1600') AND 
					NVL(lat_long_ref_source,'NULL') = NVL('#escapeQuotes(lat_long_ref_source)#','NULL') AND 
					NVL(lat_long_remarks,'NULL') = NVL('#escapeQuotes(lat_long_remarks)#','NULL')  AND 
					NVL(max_error_distance,-1) = nvl('#max_error_distance#',-1) AND
					NVL(max_error_units,'NULL') = NVL('#max_error_units#','NULL') AND 
					NVL(extent,-1) = nvl('#extent#',-1) AND
					NVL(gpsaccuracy,-1) = nvl('#gpsaccuracy#',-1) AND
					NVL(georefmethod,'NULL') = NVL('#georefmethod#','NULL')  AND 
					NVL(verificationstatus,'NULL') = NVL('#escapeQuotes(verificationstatus)#','NULL') AND 
					NVL(DEC_LAT,-1) = nvl('#DEC_LAT#',-1) AND
					NVL(DEC_LONG,-1) = nvl('#DEC_LONG#',-1) AND
					NVL(UTM_EW,-1) = nvl('#UTM_EW#',-1) AND
					NVL(UTM_NS,-1) = nvl('#UTM_NS#',-1) AND
					NVL(UTM_ZONE,'NULL') = NVL('#UTM_ZONE#','NULL') AND
					NVL(LAT_DEG,-1) = nvl('#LAT_DEG#',-1) AND
					NVL(DEC_LAT_MIN,-1) = nvl('#DEC_LAT_MIN#',-1) AND
					NVL(LAT_DIR,'NULL') = NVL('#LAT_DIR#','NULL') AND
					NVL(LONG_DEG,-1) = nvl('#LONG_DEG#',-1) AND
					NVL(DEC_LONG_MIN,-1) = nvl('#DEC_LONG_MIN#',-1) AND
					NVL(LONG_DIR,'NULL') = NVL('#LONG_DIR#','NULL') AND
					NVL(LAT_MIN,-1) = nvl('#LAT_MIN#',-1) AND
					NVL(LAT_SEC,-1) = nvl('#LAT_SEC#',-1) AND
					NVL(LONG_MIN,-1) = nvl('#LONG_MIN#',-1) AND
					NVL(LONG_SEC,-1) = nvl('#LONG_SEC#',-1)
		">
		<!--- see if there are any geology attributes to deal with --->
		<!---
		<cfdump var="#form#">
		<cfdump var="#variables#">
		--->
		<cfset ffldn=form.fieldnames>
		<cfdump var="#ffldn#">
		<cfset hasGeol=0>
		<cfset gattlst="">
		<cfloop from="1" to="#maxNumGeolAtts#" index="i">
			<cfset isGeo=ListContainsNoCase(ffldn,"GEOLOGY_ATTRIBUTE__")>
			<cfif isGeo gt 0>
				<cfset hasGeol=1>
				<cfset geo=listgetat(ffldn,isGeo)>
				<cfset thisGeoAttId=replace(geo,"GEOLOGY_ATTRIBUTE__","")>
				<cfset thisGeoAtt=evaluate("GEOLOGY_ATTRIBUTE__" & thisGeoAttId)>
				<cfset thisGeoAttValue=evaluate("GEO_ATT_VALUE__" & thisGeoAttId)>
				<cfset thisGeoDeterminerId=evaluate("GEO_ATT_DETERMINER_id__" & thisGeoAttId)>
				<cfset thisGeoAttDate=evaluate("GEO_ATT_DETERMINED_DATE__" & thisGeoAttId)>
				<cfset thisGeoAttMeth=evaluate("GEO_ATT_DETERMINED_METHOD__" & thisGeoAttId)>
				<cfset thisGeoAttRemark=evaluate("GEO_ATT_REMARK__" & thisGeoAttId)>
				<cfquery name="gatt"  datasource="uam_god">
					select min(GEOLOGY_ATTRIBUTE_ID) GEOLOGY_ATTRIBUTE_ID from geology_attributes where
						GEOLOGY_ATTRIBUTE='#thisGeoAtt#' and
						GEO_ATT_VALUE='#escapeQuotes(thisGeoAttValue)#' and
						nvl(GEO_ATT_DETERMINER_ID,-1)=nvl('#thisGeoDeterminerId#',-1) and
						NVL(GEO_ATT_DETERMINED_DATE,'1-JAN-1600') = NVL(to_date('#thisGeoAttDate#'),'1-JAN-1600') AND 
						NVL(GEO_ATT_DETERMINED_METHOD,'NULL') = NVL('#escapeQuotes(thisGeoAttMeth)#','NULL') AND
						NVL(GEO_ATT_REMARK,'NULL') = NVL('#escapeQuotes(thisGeoAttRemark)#','NULL')
				</cfquery>
				<cfif len(gatt.GEOLOGY_ATTRIBUTE_ID) is 0>
					<!--- no such attribute already esists, make sure we return nothing --->
					<cfset gattlst=listappend(gattlst,-1)>
				<cfelse>
					<cfset gattlst=listappend(gattlst,gatt.GEOLOGY_ATTRIBUTE_ID)>
					<cfset fLocS=fLocS & " and loc_acc_lat_long.locality_id IN (select locality_id from 
						geology_attributes where GEOLOGY_ATTRIBUTE_ID=#gatt.GEOLOGY_ATTRIBUTE_ID#)">
				</cfif>
				<cfloop from="1" to="#isGeo#" index="l">
					<cfset ffldn=listdeleteat(ffldn,1)>
				</cfloop>
			</cfif>
		</cfloop>
		<cfif len(geology_attribute) gt 0><!--- new attribute --->
			were making a new geology_attribute
			<cfset hasGeol=1>
			<cfquery name="gatt"  datasource="uam_god">
				select min(GEOLOGY_ATTRIBUTE_ID) GEOLOGY_ATTRIBUTE_ID from geology_attributes where
					GEOLOGY_ATTRIBUTE='#escapeQuotes(geology_attribute)#' and
					GEO_ATT_VALUE='#escapeQuotes(geo_att_value)#' and
					nvl(GEO_ATT_DETERMINER_ID,-1)=nvl('#geo_att_determiner_id#',-1) and
					NVL(GEO_ATT_DETERMINED_DATE,'1-JAN-1600') = NVL(to_date('#geo_att_determined_date#'),'1-JAN-1600') AND 
					NVL(GEO_ATT_DETERMINED_METHOD,'NULL') = NVL('#escapeQuotes(geo_att_determined_method)#','NULL') AND
					NVL(GEO_ATT_REMARK,'NULL') = NVL('#escapeQuotes(geo_att_remark)#','NULL')
			</cfquery>
			<cfif len(gatt.GEOLOGY_ATTRIBUTE_ID) is 0>
				<!--- no such attribute already esists, make sure we return nothing --->
				.....no such attribute already esists.....
				<cfset gattlst=listappend(gattlst,-1)>
			<cfelse>
				<cfset gattlst=listappend(gattlst,gatt.GEOLOGY_ATTRIBUTE_ID)>
				<cfset fLocS=fLocS & " and loc_acc_lat_long.locality_id IN (select locality_id from 
					geology_attributes where GEOLOGY_ATTRIBUTE_ID=#gatt.GEOLOGY_ATTRIBUTE_ID#)">
			</cfif>
		</cfif>
			
		<cfif hasGeol is 0>
			hasGeol is 0.....
			<cfset fLocS=fLocS & " and loc_acc_lat_long.locality_id NOT IN (select locality_id from geology_attributes)">
		<cfelse>
			hasGeol is NOT 0....
			<cfset fLocS=fLocS & " and loc_acc_lat_long.locality_id NOT IN (select locality_id from 
				geology_attributes where GEOLOGY_ATTRIBUTE_ID not in (#gattlst#))">
		</cfif>
		<cfquery name="isLoc"  datasource="uam_god">
			#preservesinglequotes(fLocS)#
		</cfquery>
		<hr>
		#preservesinglequotes(fLocS)#
		<hr>
		ran the query....
		<cfset nLocalityId=isLoc.locality_id>
		<cfif len(nLocalityId) is 0 or len(gatt.GEOLOGY_ATTRIBUTE_ID) is 0>
makin a locality....
<cfset etime=now()>
<cfset tt=DateDiff("s", btime, etime)>
<br>Runtime: #tt#


			<!--- need to make a locality --->
			<cfquery name="nlid" datasource="uam_god">
				select sq_locality_id.nextval nlid from dual
			</cfquery>
			
got locid
<cfset etime=now()>
<cfset tt=DateDiff("s", btime, etime)>
<br>Runtime: #tt#

			
			<cfset nLocalityId=nlid.nlid>
			<cfquery name="nLoc" datasource="uam_god">
				insert into locality (
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
					NOGEOREFBECAUSE
				) values (
					#nlid.nlid#,
					#nGeogId#,
					<cfif len(MAXIMUM_ELEVATION) gt 0>
						#MAXIMUM_ELEVATION#,
					<cfelse>
						NULL,
					</cfif>
					<cfif len(MINIMUM_ELEVATION) gt 0>
						#MINIMUM_ELEVATION#,
					<cfelse>
						NULL,
					</cfif>
					'#ORIG_ELEV_UNITS#',
					'#escapeQuotes(SPEC_LOCALITY)#',
					'#escapeQuotes(LOCALITY_REMARKS)#',
					'#DEPTH_UNITS#',
					<cfif len(MIN_DEPTH) gt 0>
						#MIN_DEPTH#,
					<cfelse>
						NULL,
					</cfif>
					<cfif len(MAX_DEPTH) gt 0>
						#MAX_DEPTH#,
					<cfelse>
						NULL,
					</cfif>
					'#escapeQuotes(NOGEOREFBECAUSE)#'
				)
			</cfquery>
made loc....
<cfset etime=now()>
<cfset tt=DateDiff("s", btime, etime)>
<br>Runtime: #tt#


			<!--- and new geology.... --->
			<cfset ffldn=form.fieldnames>
			<cfloop from="1" to="#maxNumGeolAtts#" index="i">
			<cfset isGeo=ListContainsNoCase(ffldn,"GEOLOGY_ATTRIBUTE__")>
			<cfif isGeo gt 0>
geology loop....			
				<cfset geo=listgetat(ffldn,isGeo)>
				<cfset thisGeoAttId=replace(geo,"GEOLOGY_ATTRIBUTE__","")>
				<cfset thisGeoAtt=evaluate("GEOLOGY_ATTRIBUTE__" & thisGeoAttId)>
				<cfset thisGeoAttValue=evaluate("GEO_ATT_VALUE__" & thisGeoAttId)>
				<cfset thisGeoDeterminerId=evaluate("GEO_ATT_DETERMINER_id__" & thisGeoAttId)>
				<cfset thisGeoAttDate=evaluate("GEO_ATT_DETERMINED_DATE__" & thisGeoAttId)>
				<cfset thisGeoAttMeth=evaluate("GEO_ATT_DETERMINED_METHOD__" & thisGeoAttId)>
				<cfset thisGeoAttRemark=evaluate("GEO_ATT_REMARK__" & thisGeoAttId)>
				<cfif len(thisGeoAtt) gt 0><!--- NULL=delete attribute --->
					<cfquery name="newGeo"  datasource="uam_god">
						insert into geology_attributes (
							locality_id,
							GEOLOGY_ATTRIBUTE,
							GEO_ATT_VALUE,
							GEO_ATT_DETERMINER_ID,
							GEO_ATT_DETERMINED_DATE,
							GEO_ATT_DETERMINED_METHOD,
							GEO_ATT_REMARK
						) values (
							#nlid.nlid#,
							'#thisGeoAtt#',
							'#escapeQuotes(thisGeoAttValue)#',
							<cfif len(thisGeoDeterminerId) gt 0>
								#thisGeoDeterminerId#,
							<cfelse>
								NULL,
							</cfif>
							to_date('#dateformat(thisGeoAttDate,"dd-mmm-yyyy")#'),
							'#escapeQuotes(thisGeoAttMeth)#',
							'#escapeQuotes(thisGeoAttRemark)#'
						)
					</cfquery>

				</cfif>				
				<cfloop from="1" to="#isGeo#" index="l">
					<cfset ffldn=listdeleteat(ffldn,1)>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfif len(geology_attribute) gt 0><!--- new attribute --->
				<cfquery name="newGeo"  datasource="uam_god">
					insert into geology_attributes (
						locality_id,
						GEOLOGY_ATTRIBUTE,
						GEO_ATT_VALUE,
						GEO_ATT_DETERMINER_ID,
						GEO_ATT_DETERMINED_DATE,
						GEO_ATT_DETERMINED_METHOD,
						GEO_ATT_REMARK
					) values (
						#nlid.nlid#,
						'#geology_attribute#',
						'#escapeQuotes(geo_att_value)#',
						<cfif len(geo_att_determiner_id) gt 0>
							#geo_att_determiner_id#,
						<cfelse>
							NULL,
						</cfif>
						to_date('#dateformat(geo_att_determined_date,"dd-mmm-yyyy")#'),
						'#escapeQuotes(geo_att_determined_method)#',
						'#escapeQuotes(geo_att_remark)#'
					)
				</cfquery>	

			</cfif>
			
			
			
			<cfif len(orig_lat_long_units) gt 0>
coordinates.....
<cfset etime=now()>
<cfset tt=DateDiff("s", btime, etime)>
<br>Runtime: #tt#
				
got llid....
<cfset etime=now()>
<cfset tt=DateDiff("s", btime, etime)>
<br>Runtime: #tt#
<br>
gonna try this:

				<cfquery name="newCoor" datasource="uam_god">
					INSERT INTO lat_long (
						LAT_LONG_ID,
						LOCALITY_ID,
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
						DETERMINED_BY_AGENT_ID,
						DETERMINED_DATE,
						LAT_LONG_REF_SOURCE,
						LAT_LONG_REMARKS,
						MAX_ERROR_DISTANCE,
						MAX_ERROR_UNITS,
						ACCEPTED_LAT_LONG_FG,
						EXTENT,
						GPSACCURACY,
						GEOREFMETHOD,
						VERIFICATIONSTATUS
					) values (
						sq_lat_long_id.nextval,
						#nlid.nlid#,
						<cfif len(LAT_DEG) gt 0>
							#LAT_DEG#,
						<cfelse>
							NULL,
						</cfif>
						<cfif len(DEC_LAT_MIN) gt 0>
							#DEC_LAT_MIN#,
						<cfelse>
							NULL,
						</cfif>
						<cfif len(LAT_MIN) gt 0>
							#LAT_MIN#,
						<cfelse>
							NULL,
						</cfif>
						<cfif len(LAT_SEC) gt 0>
							#LAT_SEC#,
						<cfelse>
							NULL,
						</cfif>
						'#LAT_DIR#',
						<cfif len(LONG_DEG) gt 0>
							#LONG_DEG#,
						<cfelse>
							NULL,
						</cfif>
						<cfif len(DEC_LONG_MIN) gt 0>
							#DEC_LONG_MIN#,
						<cfelse>
							NULL,
						</cfif>
						<cfif len(LONG_MIN) gt 0>
							#LONG_MIN#,
						<cfelse>
							NULL,
						</cfif>
						<cfif len(LONG_SEC) gt 0>
							#LONG_SEC#,
						<cfelse>
							NULL,
						</cfif>
						'#LONG_DIR#',
						<cfif len(DEC_LAT) gt 0>
							#DEC_LAT#,
						<cfelse>
							NULL,
						</cfif>
						<cfif len(DEC_LONG) gt 0>
							#DEC_LONG#,
						<cfelse>
							NULL,
						</cfif>
						'#DATUM#',
						'#UTM_ZONE#',
						<cfif len(UTM_EW) gt 0>
							#UTM_EW#,
						<cfelse>
							NULL,
						</cfif>
						<cfif len(UTM_NS) gt 0>
							#UTM_NS#,
						<cfelse>
							NULL,
						</cfif>
						'#ORIG_LAT_LONG_UNITS#',
						<cfif len(DETERMINED_BY_AGENT_ID) gt 0>
							#DETERMINED_BY_AGENT_ID#,
						<cfelse>
							NULL,
						</cfif>
						to_date('#DETERMINED_DATE#'),
						'#escapeQuotes(LAT_LONG_REF_SOURCE)#',
						'#escapeQuotes(LAT_LONG_REMARKS)#',
						<cfif len(MAX_ERROR_DISTANCE) gt 0>
							#MAX_ERROR_DISTANCE#,
						<cfelse>
							NULL,
						</cfif>
						'#MAX_ERROR_UNITS#',
						1,
						<cfif len(EXTENT) gt 0>
							#EXTENT#,
						<cfelse>
							NULL,
						</cfif>
						<cfif len(GPSACCURACY) gt 0>
							#GPSACCURACY#,
						<cfelse>
							NULL,
						</cfif>
						'#escapeQuotes(GEOREFMETHOD)#',
						'#escapeQuotes(VERIFICATIONSTATUS)#'
					)
				</cfquery>
inserted coordinates......
<cfset etime=now()>
<cfset tt=DateDiff("s", btime, etime)>
<br>Runtime: #tt#
			</cfif>
		</cfif><!--- end make new locality --->
		<!--- we now have a locality --->
		<cfquery name="hasColl" datasource="uam_god">
			select 
	 			nvl(min(collecting_event_id),-1) collecting_event_id
			FROM 
				collecting_event 
			WHERE
				locality_id = #nLocalityId# AND
				NVL(VERBATIM_DATE,'NULL') = NVL('#VERBATIM_DATE#','NULL') AND
				NVL(BEGAN_DATE,'1-JAN-1600') = NVL(to_date('#BEGAN_DATE#'),'1-JAN-1600') AND 
				NVL(ENDED_DATE,'1-JAN-1600') = NVL(to_date('#ENDED_DATE#'),'1-JAN-1600') AND 
				NVL(VERBATIM_LOCALITY,'NULL') = NVL('#escapeQuotes(VERBATIM_LOCALITY)#','NULL') AND
				NVL(COLL_EVENT_REMARKS,'NULL') = NVL('#escapeQuotes(COLL_EVENT_REMARKS)#','NULL') AND
				NVL(COLLECTING_SOURCE,'NULL') = NVL('#escapeQuotes(COLLECTING_SOURCE)#','NULL') AND
				NVL(COLLECTING_METHOD,'NULL') = NVL('#escapeQuotes(COLLECTING_METHOD)#','NULL') AND
				NVL(HABITAT_DESC,'NULL') = NVL('#escapeQuotes(HABITAT_DESC)#','NULL')
		</cfquery>
gor event....
		<cfif hasColl.collecting_event_id is -1>
			<!--- need a collecting event --->
			<cfquery name="ncid" datasource="uam_god">
				select sq_collecting_event_id.nextval ncid from dual
			 </cfquery>
			 <cfset ncollecting_event_id=ncid.ncid>
making event....
			<cfquery name="newEvent" datasource="uam_god">
				INSERT INTO collecting_event (
					COLLECTING_EVENT_ID,
					LOCALITY_ID,
					BEGAN_DATE,
					ENDED_DATE,
					VERBATIM_DATE,
					VERBATIM_LOCALITY,
					COLL_EVENT_REMARKS,
					COLLECTING_SOURCE,
					COLLECTING_METHOD,
					HABITAT_DESC
				) values (
					#ncollecting_event_id#,
					#nLocalityId#,
					to_date('#dateformat(began_date,"dd-mmm-yyyy")#'),
					to_date('#dateformat(ended_date,"dd-mmm-yyyy")#'),
					'#escapeQuotes(verbatim_date)#',
					'#escapeQuotes(verbatim_locality)#',
					'#escapeQuotes(coll_event_remarks)#',
					'#escapeQuotes(collecting_source)#',
					'#escapeQuotes(collecting_method)#',
					'#escapeQuotes(habitat_desc)#'
				)
			</cfquery>	
		<cfelse>
			<cfset ncollecting_event_id=hasColl.collecting_event_id>
		</cfif>
event spiffy....
		<cfquery name="upCatItem" datasource="uam_god">
			update cataloged_item set 
    			collecting_event_id = #ncollecting_event_id# 
    		where collection_object_id = #collection_object_id#
		</cfquery>
updated catitem....	
		<cfquery name="canKill"  datasource="uam_god">
			SELECT COUNT(*) c 
			FROM 
				cataloged_item,
				collecting_event,
				locality
 			WHERE
				cataloged_item.collecting_event_id=collecting_event.collecting_event_id AND
 				collecting_event.locality_id = locality.locality_id AND
 				locality.locality_id=#old.locality_id#
		</cfquery>
got cankill.....
		<cfif canKill.c is 0>
			<cftry>
				<cfquery name="killEvnt"  datasource="uam_god">
					DELETE FROM collecting_event WHERE collecting_event_id=#old.collecting_event_id#
				</cfquery>
			<cfcatch></cfcatch>
			</cftry>
			<cftry>
				<cfquery name="killLatLong"  datasource="uam_god">
					DELETE FROM lat_long WHERE locality_id=#old.locality_id#
				</cfquery>
			<cfcatch></cfcatch>
			</cftry>
			<cftry>
				<cfquery name="killGeol"  datasource="uam_god">
					DELETE FROM geology_attributes WHERE locality_id=#old.locality_id#
				</cfquery>
			<cfcatch></cfcatch>
			</cftry>
			<cftry>
				<cfquery name="killLoc"  datasource="uam_god">
					DELETE FROM locality WHERE locality_id=#old.locality_id#
				</cfquery>
			<cfcatch></cfcatch>
			</cftry>	
		</cfif>
	</cftransaction>
done.....

	<cflocation url="specLocality.cfm?collection_object_id=#collection_object_id#">		

<!---

	--->
</cfoutput>
</cfif>	  