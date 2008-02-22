<cfinclude template="/includes/alwaysInclude.cfm">
<cfinclude template="/includes/functionLib.cfm">
<script language="JavaScript" src="includes/CalendarPopup.js" type="text/javascript"></script>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
		var cal1 = new CalendarPopup("theCalendar");
		cal1.showYearNavigation();
		cal1.showYearNavigationInput();
	</SCRIPT>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">document.write(getCalendarStyles());</SCRIPT>
	
<span class="pageHelp">
	<a href="javascript:void(0);" 
				onClick="pageHelp('specLocality'); return false;"
				class="info">
				<img src="/images/what.gif" border="0" alt="Click for page help.">
	<span>Page Help</span>
	</a>
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
	<cfquery name="l" datasource="#Application.web_user#">
    	select 
			*
		from 
			spec_with_loc
		where 
			collection_object_id = #collection_object_id#
	</cfquery>
	<cfquery name="ctElevUnit" datasource="#Application.web_user#">
		select orig_elev_units from ctorig_elev_units
	</cfquery>
	<cfquery name="ctdepthUnit" datasource="#Application.web_user#">
		select depth_units from ctdepth_units
	</cfquery>
     <cfquery name="ctdatum" datasource="#Application.web_user#">
        select datum from ctdatum 
     </cfquery>
     <cfquery name="ctrefsrc" datasource="#Application.web_user#">
        select lat_long_ref_source from ctlat_long_ref_source 
     </cfquery>
	<cfquery name="ctGeorefMethod" datasource="#Application.web_user#">
		select georefMethod from ctgeorefmethod
	</cfquery>
	<cfquery name="ctVerificationStatus" datasource="#Application.web_user#">
		select VerificationStatus from ctVerificationStatus
	</cfquery>
     <cfquery name="cterror" datasource="#Application.web_user#">
        select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS 
     </cfquery>
     <cfquery name="ctew" datasource="#Application.web_user#">
        select e_or_w from ctew 
     </cfquery>
     <cfquery name="ctns" datasource="#Application.web_user#">
        select n_or_s from ctns 
     </cfquery>
     <cfquery name="ctunits" datasource="#Application.web_user#">
        select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS 
     </cfquery>
	<cfquery name="ctcollecting_source" datasource="#Application.web_user#">
        select COLLECTING_SOURCE from ctcollecting_source 
     </cfquery>
	
	<form name="loc" method="post" action="specLocality.cfm">
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
				<input type="text" 
					name="spec_locality" 
					id="spec_locality"
					value="#stripQuotes(l.spec_locality)#"  
					size="75">
			</td>
		</tr>
		<tr>
			<td>
				<label for="verbatim_locality">
					<a href="javascript:void(0);" onClick="getDocs('locality','verbatim_locality')">
						Verbatim Locality</a>
				</label>
				<input type="text" 
					name="verbatim_locality" 
					id="verbatim_locality"
					value="#stripQuotes(l.verbatim_locality)#"  
					size="75">
			</td>
		</tr>
		<tr>
			<td>
				<label for="verbatim_date">
						<a href="javascript:void(0);" onClick="getDocs('locality','verbatim_date')">
							Verbatim Date</a>
				</label>
				<input type="text" 
					name="verbatim_date"
					id="verbatim_date" 
					value="#stripQuotes(l.verbatim_date)#"  
					size="75">
			</td>
		</tr>
		<tr>
			<td>
				<table>
					<td>
							<label for="began_date"><a href="javascript:void(0);" onClick="getDocs('locality','began_date')">
								Began Date</a></label>
							<input type="text" 
								name="began_date"
								id="began_date"
								value="#dateformat(l.began_date,'dd mmm yyyy')#"
								class="reqdClr">		
								<span class="infoLink"
										name="anchor1"
										id="anchor1"
										onClick="cal1.select(document.loc.began_date,'anchor1','dd-MMM-yyyy'); return false;">
											Pick
										</span>
										
						</td>
						<td>
							<label for="ended_date">
								<a href="javascript:void(0);" onClick="getDocs('locality','ended_date')">
									Ended Date</a>
							</label>
							<input type="text" 
								name="ended_date"
								id="ended_date" 
								value="#dateformat(l.ended_date,'dd mmm yyyy')#"
								class="reqdClr">
								<span class="infoLink"
										name="anchor2"
										id="anchor2"
										onClick="cal1.select(document.loc.ended_date,'anchor2','dd-MMM-yyyy'); return false;">
											Pick
										</span>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<!---
		<tr>
			<td>
				<label for="date_determiner">
					<a href="javascript:void(0);" 
						onClick="getDocs('collecting_source','date_determiner')">Date Determiner</a>
				</label>
				<input type="text" 
					name="date_determiner" id="date_determiner" class="reqdClr" value="#l.date_determiner#" size="40"
					 onchange="getAgent('DATE_DETERMINED_BY_AGENT_ID','date_determiner','loc',this.value); return false;"
					 onKeyPress="return noenter(event);">
					<input type="hidden" name="DATE_DETERMINED_BY_AGENT_ID" value="#l.DATE_DETERMINED_BY_AGENT_ID#">
			</td>
		</tr>
		--->
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
							<input type="text" name="minimum_elevation" id="minimum_elevation" value="#l.MINIMUM_ELEVATION#" size="3">
						</td>
						<td>
							<label for="maximum_elevation">
								<a href="javascript:void(0);" class="novisit" onClick="getDocs('locality','elevation')">
									Maximum Elevation</a>
							</label>
							<input type="text" id="maximum_elevation" name="maximum_elevation" 
								value="#l.MAXIMUM_ELEVATION#" size="3">
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
							<input type="text" name="min_depth" id="min_depth" value="#l.min_depth#" size="3">
						</td>
						<td>
							<label for="max_depth"  onClick="getDocs('locality','depth')" class="likeLink">
									Maximum Depth
							</label>
							<input type="text" id="max_depth" name="max_depth" 
								value="#l.max_depth#" size="3">
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
				<span class="infoLink"
					name="anchor3"
					id="anchor3"
					onClick="cal1.select(document.loc.determined_date,'anchor3','dd-MMM-yyyy'); return false;">
						Pick
				</span>
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
				<input type="text" name="DEC_LAT" id="dec_lat" value="#l.DEC_LAT#" class="reqdClr">
			</td>
			<td>
				<label for="dec_long">Decimal Longitude</label>
				<input type="text" name="DEC_LONG" value="#l.DEC_LONG#" id="dec_long" class="reqdClr">
			</td>
		</tr>
	</table>
	<table id="dms" style="display:none;">
		<tr> 
			<td>
				<label for="lat_deg">Lat. Deg.</label>
				<input type="text" name="LAT_DEG" value="#l.LAT_DEG#" size="4" id="lat_deg" class="reqdClr">
			</td>
			<td>
				<label for="lat_min">Lat. Min.</label>
				<input type="text" name="LAT_MIN" value="#l.LAT_MIN#" size="4" id="lat_min" class="reqdClr">
			</td>
			<td>
				<label for="lat_sec">Lat. Sec.</label>
				<input type="text" name="LAT_SEC" value="#l.LAT_SEC#" id="lat_sec" class="reqdClr">
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
				<input type="text" name="LONG_DEG" value="#l.LONG_DEG#" size="4" id="long_deg" class="reqdClr">
			</td>
			<td>
				<label for="long_min">Long. Min.</label>
				<input type="text" name="LONG_MIN" value="#l.LONG_MIN#" size="4" id="long_min" class="reqdClr">
			</td>
			<td>
				<label for="long_sec">Long. Sec.</label>
				<input type="text" name="LONG_SEC" value="#l.LONG_SEC#" id="long_sec"  class="reqdClr">
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
				<input type="text" name="DEC_LAT_MIN" value="#l.DEC_LAT_MIN#" id="dec_lat_min" class="reqdClr">
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
				<input type="text" name="dmLONG_DEG" value="#l.LONG_DEG#" size="4" id="dmlong_deg" class="reqdClr">
			</td>
			<td>
				<label for="dec_long_min">Long. Dec. Min.<label>
				<input type="text" name="DEC_LONG_MIN" value="#l.DEC_LONG_MIN#" id="dec_long_min" class="reqdClr">
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
				<input type="text" name="UTM_ZONE" value="#l.UTM_ZONE#" id="utm_zone" class="reqdClr">
			</td>
			<td>
				<label for="utm_ew">UTM East/West<label>
				<input type="text" name="UTM_EW" value="#l.UTM_EW#" id="utm_ew" class="reqdClr">
			</td>
			<td>
				<label for="utm_ns">UTM North/South<label>
				<input type="text" name="UTM_NS" value="#l.UTM_NS#" id="utm_ns" class="reqdClr">
			</td>
		</tr>
	</td>
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
  	
	
	</form>
	<script>
		showLLFormat('#l.ORIG_LAT_LONG_UNITS#');	
	</script>
	</cfoutput>
</cfif> 		
      <!---------------------------------------------------------------------------------------------------->
<cfif #action# is "saveChange">
<cfoutput>
	<cfset sql = "UPDATE spec_with_loc SET
		higher_geog = '#higher_geog#',
		spec_locality = '#replace(spec_locality,"'","''","all")#'">
		<cfif len(#MINIMUM_ELEVATION#) is 0>
			<cfset sql = "#sql# ,MINIMUM_ELEVATION = NULL">
		<cfelse>
			<cfset sql = "#sql# ,MINIMUM_ELEVATION = #MINIMUM_ELEVATION#">
		</cfif>
		<cfif len(#MAXIMUM_ELEVATION#) is 0>
			<cfset sql = "#sql# ,MAXIMUM_ELEVATION = NULL">
		<cfelse>
			<cfset sql = "#sql# ,MAXIMUM_ELEVATION = #MAXIMUM_ELEVATION#">
		</cfif>
		<cfset sql = "#sql# ,orig_elev_units = '#orig_elev_units#'">
		<cfif len(#min_depth#) is 0>
			<cfset sql = "#sql# ,min_depth = NULL">
		<cfelse>
			<cfset sql = "#sql# ,min_depth = #min_depth#">
		</cfif>
		<cfif len(#max_depth#) is 0>
			<cfset sql = "#sql# ,max_depth = NULL">
		<cfelse>
			<cfset sql = "#sql# ,max_depth = #max_depth#">
		</cfif>
		<cfset locrem=replace(LOCALITY_REMARKS,"'","''","all")>
		<cfset sql = "#sql# ,depth_units = '#depth_units#',
		LOCALITY_REMARKS = '#locrem#',
		verbatim_locality = '#replace(verbatim_locality,"'","''","all")#',
		verbatim_date = '#verbatim_date#',
		began_date = '#dateformat(began_date,"dd-mmm-yyyy")#',
		ended_date = '#dateformat(ended_date,"dd-mmm-yyyy")#',
		COLL_EVENT_REMARKS = '#COLL_EVENT_REMARKS#',
		COLLECTING_SOURCE = '#COLLECTING_SOURCE#',
		COLLECTING_METHOD = '#COLLECTING_METHOD#',
		habitat_desc = '#habitat_desc#',
		NoGeorefBecause='#NoGeorefBecause#'
			">	
		
	<cfif len(#ORIG_LAT_LONG_UNITS#) gt 0>
		<cfset sql = "#sql#, ORIG_LAT_LONG_UNITS = '#ORIG_LAT_LONG_UNITS#',
			DETERMINED_DATE = '#DETERMINED_DATE#',
			DETERMINED_BY_AGENT_ID = #DETERMINED_BY_AGENT_ID#,
			MAX_ERROR_UNITS = '#MAX_ERROR_UNITS#',
			DATUM = '#DATUM#',
			georefMethod = '#georefMethod#'">
			<cfif len(#MAX_ERROR_DISTANCE#) gt 0>
				<cfset sql = "#sql#,MAX_ERROR_DISTANCE = #MAX_ERROR_DISTANCE#">
			<cfelse>
				<cfset sql = "#sql#,MAX_ERROR_DISTANCE = NULL">
			</cfif>
			<cfif len(#GpsAccuracy#) gt 0>
				<cfset sql = "#sql#,GpsAccuracy = #GpsAccuracy#">
			<cfelse>
				<cfset sql = "#sql#,GpsAccuracy = NULL">
			</cfif>
			<cfif len(#extent#) gt 0>
				<cfset sql = "#sql#,extent = #extent#">
			<cfelse>
				<cfset sql = "#sql#,extent = NULL">
			</cfif>
			<cfset llrem=replace(LAT_LONG_REMARKS,"'","''","all")>
			<cfset sql = "#sql#,VerificationStatus = '#VerificationStatus#',
			LAT_LONG_REF_SOURCE = '#LAT_LONG_REF_SOURCE#',
			LAT_LONG_REMARKS = '#llrem#'">
		<cfif #ORIG_LAT_LONG_UNITS# is "decimal degrees">
			<cfset sql = "#sql#,
				DEC_LAT = #DEC_LAT#,
				DEC_LONG = #DEC_LONG#">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "UTM">
			<cfset sql = "#sql#,
				UTM_ZONE = '#UTM_ZONE#',
				UTM_EW = #UTM_EW#,
				UTM_NS = #UTM_NS#">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "degrees dec. minutes">
			<cfset sql = "#sql#,
				LAT_DEG = #dmLAT_DEG#,
				DEC_LAT_MIN = #DEC_LAT_MIN#,
				LAT_DIR = '#dmLAT_DIR#',
				LONG_DEG = #dmLONG_DEG#,
				DEC_LONG_MIN = #DEC_LONG_MIN#,
				LONG_DIR = '#dmLONG_DIR#'">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "deg. min. sec.">
			<cfset sql = "#sql#,
				LAT_DEG = #LAT_DEG#,
				LAT_MIN = #LAT_MIN#,
				LAT_SEC = #LAT_SEC#,
				LAT_DIR = '#LAT_DIR#',
				LONG_DEG = #LONG_DEG#,
				LONG_MIN = #LONG_MIN#,
				LONG_SEC = #LONG_SEC#,
				LONG_DIR = '#LONG_DIR#'">		
		</cfif>
	<cfelse>
		<cfset sql = "#sql#,
			ORIG_LAT_LONG_UNITS = NULL,
			DETERMINED_DATE = NULL,
			MAX_ERROR_DISTANCE = NULL,
			MAX_ERROR_UNITS = NULL,
			DATUM = NULL,
			georefMethod = NULL,
			extent = NULL,
			GpsAccuracy = NULL,
			VerificationStatus = NULL,
			LAT_LONG_REF_SOURCE = NULL,
			LAT_LONG_REMARKS = NULL,
			DEC_LAT = NULL,
			DEC_LONG = NULL,
			LAT_DEG = NULL,
			LAT_MIN = NULL,
			LAT_SEC = NULL,
			LAT_DIR = NULL,
			LONG_DEG = NULL,
			LONG_MIN = NULL,
			LONG_SEC = NULL,
			LONG_DIR = NULL,
			DEC_LAT_MIN = NULL,
			DEC_LONG_MIN = NULL,
			UTM_ZONE = NULL,
			UTM_EW = NULL,
			UTM_NS = NULL">
	</cfif>

	
	<!----
	<cfif #client.username# is "dlm">
		#preservesinglequotes(sql)#
		<cfabort>
	</cfif>
---->

<cfset sql = "#sql# WHERE collection_object_id = #collection_object_id#">
	#preservesinglequotes(sql)#
	<cfabort>
	
		<cfquery name="upCollLocLatLong" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>

		<cf_ActivityLog sql="#sql#">
		

	<cflocation url="specLocality.cfm?collection_object_id=#collection_object_id#">

	
</cfoutput>
</cfif>	 
<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV> 
	  