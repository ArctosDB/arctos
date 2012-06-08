<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cf_customizeIFrame>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$("#began_date").datepicker();
		$("#ended_date").datepicker();
	});
</script>
<cfoutput>
<!--- see if action is duplicated --->
<cfif action contains ",">
	<cfset i=1>
	<cfloop list="#action#" delimiters="," index="a">
		<cfif i is 1>
			<cfset firstAction = a>
		<cfelse>
			<cfif a neq firstAction>
				An error has occured! Multiple Action in Locality. Please submit a bug report.
				<cfabort>
			</cfif>
		</cfif>
	</cfloop>
	<cfset action = firstAction>
</cfif>
<cfif isdefined("collection_object_id") AND collection_object_id gt 0 AND action is "nothing">
	<!--- probably got here from SpecimenDetail, make sure we're in a frame --->
	<script>
		var thePar = parent.location.href;
		var isFrame = thePar.indexOf('Locality.cfm');
		if (isFrame == -1) {
			// we're in a frame, action is NOTHING, we have a collection_object_id; redirect to 
			// get a collecting_event_id 
			//alert('in a frame');
			document.location='Locality.cfm?action=findCollEventIdForSpecDetail&collection_object_id=#collection_object_id#';
		}
	</script>
</cfif>
<cfif action is "findCollEventIdForSpecDetail">
	<!--- get a collecting event ID and relocate to editCollEvnt --->
	<cfquery name="ceid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collecting_event_id from cataloged_item where
		collection_object_id=#collection_object_id#
	</cfquery>
	<cflocation url="Locality.cfm?action=editCollEvnt&collecting_event_id=#ceid.collecting_event_id#">
</cfif>
</cfoutput>
<cfif not isdefined("collection_object_id")>
	<cfset collection_object_id=-1>
</cfif>
<cfif not isdefined("anchor")>
	<cfset anchor="">
</cfif>
<!--------------------------- Code-table queries --------------------------------------------------> 
<cfquery name="ctIslandGroup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select island_group from ctisland_group order by island_group
</cfquery>
<cfquery name="ctElevUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select orig_elev_units from ctorig_elev_units order by orig_elev_units
</cfquery>
<cfquery name="ctCollecting_Source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select collecting_source from ctCollecting_Source order by collecting_source
</cfquery>
<cfquery name="ctFeature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select distinct(feature) from ctfeature order by feature
</cfquery>
	<cfquery name="ctGeorefMethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select georefMethod from ctgeorefmethod order by georefMethod
</cfquery>
<cfquery name="ctVerificationStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select VerificationStatus from ctVerificationStatus order by VerificationStatus
</cfquery>
<cfquery name="ctlat_long_units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select ORIG_LAT_LONG_UNITS from ctlat_long_units order by ORIG_LAT_LONG_UNITS
</cfquery>
<cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select datum from ctdatum order by datum
</cfquery>



<!---------------------------------------------------------------------------------------------------->
<cfif action is "nothing">
<cfoutput>
<cfset title="Manage Localities">
<table border>
	<tr>
		<td>Higher Geography</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="findHG">
				<input type="submit" value="Find" class="lnkBtn">	
			</form>
		</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="newHG">
				<input type="submit" value="New Higher Geog" class="insBtn">
			</form>
		</td>
		<td>
			<!---<a href="javascript:void(0);" onClick="getDocs('higher_geography')"><img src="/images/what.gif" border="0"></a>--->
			<span class="infoLink" onclick="getDocs('higher_geography');">Define</span>
		</td>
	</tr>
	<tr>
		<td>Localities</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="findLO">
				<input type="submit" value="Find" class="lnkBtn">			
			</form>	
		</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="newLocality">
				<input type="submit" value="New Locality" class="insBtn">
			</form>
		</td>
		<td>
			<span class="infoLink" onclick="getDocs('locality');">Define</span>
		</td>
	</tr>
	<tr>
		<td>Collecting Events</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="findCO">
				<input type="submit" value="Find" class="lnkBtn">
			</form>		
		</td>
		<td>(Find and clone to create new)</td>
		<td>
			<span class="infoLink" onclick="getDocs('collecting_event');">Define</span>
		</td>
	</tr>
</table>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findHG">
	<cfoutput>
		<cfset title="Find Geography">
		<strong>Find Higher Geography:</strong>
		<form name="getCol" method="post" action="Locality.cfm">
		    <input type="hidden" name="Action" value="findGeog">	
			<cfinclude template="/includes/frmFindLocation_guts.cfm">
		</form>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newHG">
<cfoutput>
	<cfset title="Create Higher Geography">
	<b>Create Higher Geography:</b>
	<cfform name="getHG" method="post" action="Locality.cfm">
		<input type="hidden" name="Action" value="makeGeog">
		<table>
			<tr>
				<td align="right">Continent or Ocean:</td>
				<td>
					<input type="text" name="continent_ocean" <cfif isdefined("continent_ocean")> value = "#continent_ocean#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">Country:</td>
				<td>
					<input type="text" name="country" <cfif isdefined("country")> value = "#country#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">State:</td>
				<td>
					<input type="text" name="state_prov" <cfif isdefined("state_prov")> value = "#state_prov#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">County:</td>
				<td>
					<input type="text" name="county" <cfif isdefined("county")> value = "#county#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">Quad:</td>
				<td>
					<input type="text" name="quad" <cfif isdefined("quad")> value = "#quad#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">Feature:</td>
				<td>
				<cfif isdefined("feature")>
					<cfset thisFeature = feature>
				<cfelse>
					<cfset thisFeature = "">
				</cfif>
				<select name="feature">
					<option value=""></option>
						<cfloop query="ctFeature">
							<option 
								<cfif thisFeature is ctFeature.feature> selected="selected" </cfif>
								value = "#ctFeature.feature#">#ctFeature.feature#</option>
						</cfloop>
				</select>
			</td>
			</tr>
			<tr>
				<td align="right">Island Group:</td>
				<td><select name="island_group" size="1">
				<option value=""></option>
				<cfloop query="ctIslandGroup">
					<option 
						<cfif isdefined("islandgroup")>
							<cfif ctIslandGroup.island_group is islandgroup> selected="selected" </cfif>
						</cfif>value="#ctIslandGroup.island_group#">#ctIslandGroup.island_group#
					</option>
				</cfloop>
			</select></td>
			</tr>
			<tr>
				<td align="right">Island:</td>
				<td>
					<input type="text" name="island" <cfif isdefined("island")> value = "#island#"</cfif> size="50">
				</td>
			</tr>
			<tr>
				<td align="right">Sea:</td>
				<td>
					<input type="text" name="sea" <cfif isdefined("sea")> value = "#sea#"</cfif>>
				</td>
			</tr>
			<tr>
				<td align="right">Valid?</td>
				<td>
					<select name="valid_catalog_term_fg" class="reqdClr">
						<option value="1">yes</option>
						<option value="0">no</option>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right">Source Authority:</td>
				<td>
					<input name="source_authority" id="source_authority" class="reqdClr">
				</td>
			</tr>
			<tr>
			<td colspan="2">
				<input type="submit" value="Create" class="insBtn">
				<input type="button" value="Quit" class="qutBtn" onclick="document.location='Locality.cfm';">	
			</td>
		</tr>
	</table>
	</cfform>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findLO">
	<cfoutput>
		<cfset title="Find Locality">
		<cfset showLocality=1>
		<strong>Find Locality:</strong>
	    <form name="getCol" method="post" action="Locality.cfm">
			<input type="hidden" name="Action" value="findLocality">	
			<cfinclude template="/includes/frmFindLocation_guts.cfm">
	     </form>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findCO">
<cfoutput> 
	<cfset title="Find Collecting Events">
	<cfset showLocality=1>
	<cfset showEvent=1>
	<strong>Find Collecting Events:</strong>
    <form name="getCol" method="post" action="Locality.cfm">
		<input type="hidden" name="Action" value="findCollEvent">	
		<cfinclude template="/includes/frmFindLocation_guts.cfm">
     </form>
</cfoutput>
</cfif> 
<!---------------------------------------------------------------------------------------------------->
<cfif action is "editGeog">
<cfset title = "Edit Geography">
	<cfoutput> 
		<cfquery name="geogDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		 select * from geog_auth_rec where geog_auth_rec_id = #geog_auth_rec_id# 
		</cfquery>
		<h3>Edit Higher Geography</h3>
		<span class="infoLink" onClick="getDocs('higher_geography')">help</span>
		<cfquery name="localities" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from locality where geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>
		<cfquery name="collecting_events" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select count(*) c from locality,collecting_event
			where
			locality.locality_id = collecting_event.locality_id AND
			geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>
		<cfquery name="specimen" datasource="uam_god">
			select 
				collection.collection_id,
				collection.collection,
				count(*) c 
			from 
				locality,
				collecting_event,
				cataloged_item,
				collection
			where
				locality.locality_id = collecting_event.locality_id AND
				collecting_event.collecting_event_id = cataloged_item.collecting_event_id AND
			 	cataloged_item.collection_id=collection.collection_id and
			 	geog_auth_rec_id=#geog_auth_rec_id#
			 group by 
			 	collection.collection_id,
				collection.collection
			order by
				collection.collection
		</cfquery>
		<div style="border:2px solid blue; background-color:red;">
			Altering this record will update:
			<ul>
				<li>#localities.c# localities</li>
				<li>#collecting_events.c# collecting events</li>
				<cfloop query="specimen">
					<li>
						<a href="/SpecimenResults.cfm?geog_auth_rec_id=#geog_auth_rec_id#&collection_id=#specimen.collection_id#">
							#specimen.c# #collection# specimens
						</a>
					</li>
				</cfloop>
			</ul>
		</div>
    </cfoutput>
	<cfoutput query="geogDetails">
		<br><em>#higher_geog#</em>
        <cfform name="getHG" method="post" action="Locality.cfm">
	        <input name="Action" type="hidden" value="saveGeogEdits">
            <input type="hidden" name="geog_auth_rec_id" value="#geog_auth_rec_id#">
            <table>
				<tr> 
	                <td>
						<label for="continent_ocean" class="likeLink" onClick="getDocs('higher_geography','continent_ocean')">
							Continent or Ocean
						</label>
						<input type="text" name="continent_ocean" id="continent_ocean" value="#continent_ocean#"></td>
	                <td>
						<label for="country" class="likeLink" onClick="getDocs('higher_geography','country')">
							Country
						</label>
						<input type="text" name="country" id="country" value="#country#">
					</td>
					<td>
						<label for="state_prov" class="likeLink" onClick="getDocs('higher_geography','state_province')">
							State/Province
						</label>
						<input type="text" name="state_prov" id="state_prov" value="#state_prov#">
					</td>
					<td>
						<label for="sea" class="likeLink" onClick="getDocs('higher_geography','sea')">
							Sea
						</label>
						<input type="text" name="sea" id="sea" value="#sea#">
					</td>
				</tr>
				<tr>
					<td>
						<label for="county" class="likeLink" onClick="getDocs('higher_geography','county')">
							County
						</label>
						<input type="text" name="county" id="county" value="#county#">
					</td>
                	<td>
						<label for="quad" class="likeLink" onClick="getDocs('higher_geography','map_name')">
							Quad
						</label>
						<input type="text" name="quad" id="quad" value="#quad#">
					</td>
					<td colspan="2">
						<cfif isdefined("feature")>
							<cfset thisFeature = feature>
						<cfelse>
							<cfset thisFeature = "">
						</cfif>
						<label for="feature" class="likeLink" onClick="getDocs('higher_geography','feature')">
							Feature
						</label>
						<select name="feature" id="feature">
							<option value=""></option>
							<cfloop query="ctFeature">
								<option	<cfif thisFeature is ctFeature.feature> selected="selected" </cfif>
									value = "#ctFeature.feature#">#ctFeature.feature#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="island_group" class="likeLink" onClick="getDocs('higher_geography','island_group')">
							Island Group
						</label>
						<select name="island_group" id="island_group" size="1">
		                	<option value=""></option>
		                    <cfloop query="ctIslandGroup">
		                      <option 
							<cfif geogdetails.island_group is ctislandgroup.island_group> selected="selected" </cfif>value="#ctIslandGroup.island_group#">#ctIslandGroup.island_group#</option>
		                    </cfloop>
		                  </select>
					</td>
					<td colspan="2">
						<label for="island" class="likeLink" onClick="getDocs('higher_geography','island')">
							Island
						</label>
						<input type="text" name="island" id="island" value="#island#" size="50">
					</td>
				</tr>
				<tr> 
	                <td colspan="2">
						<label for="source_authority">
							Authority
						</label>
						<input name="source_authority" id="source_authority" class="reqdClr" value="#source_authority#">
					</td>
	                <td>
						<label for="valid_catalog_term_fg">
							Valid?
						</label>
						<select name="valid_catalog_term_fg" id="valid_catalog_term_fg" class="reqdClr">
		                    <option value=""></option>
		                    <option <cfif geogdetails.valid_catalog_term_fg is "1"> selected="selected" </cfif>value="1">yes</option>
		                    <option <cfif geogdetails.valid_catalog_term_fg is "0"> selected="selected" </cfif>value="0">no</option>
		                  </select>
					</td>
					<td>&nbsp;</td>
				</tr>
				<tr> 
	                <td colspan="4" nowrap align="center"> 
						<input type="submit" value="Save Edits"	class="savBtn">	
						<input type="button" value="Delete" class="delBtn"
							onClick="document.location='Locality.cfm?Action=deleteGeog&geog_auth_rec_id=#geog_auth_rec_id#';">
						<input type="button" value="See Localities" class="lnkBtn"
							onClick="document.location='Locality.cfm?Action=findLocality&geog_auth_rec_id=#geog_auth_rec_id#';">
						<cfset dloc="Locality.cfm?action=newHG&continent_ocean=#continent_ocean#&country=#country#&state_prov=#state_prov#&county=#county#&quad=#quad#&feature=#feature#&island_group=#island_group#&island=#island#&sea=#sea#">
						<input type="button" value="Create Clone" class="insBtn" onclick="document.location='#dloc#';">
					</td>
				</tr>
			</table>
		</cfform>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "editCollEvnt">
<cfset title="Edit Collecting Event">
<cfoutput> 
      <cfquery name="locDet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
    	select 
			higher_geog,
			spec_locality,
			locality_name,
			collecting_event.collecting_event_id,
			locality.locality_id,
			verbatim_locality,
			BEGAN_DATE,
			ENDED_DATE,
			VERBATIM_DATE,
			COLL_EVENT_REMARKS,
			Verbatim_coordinates,
			max_error_distance,
			max_error_units,
			collecting_event_name,
			locality.DEC_LAT loclat,
			locality.DEC_LONG loclong,
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
			locality.DATUM localityDATUM,
			collecting_event.DEC_LAT,
			collecting_event.DEC_LONG,
			collecting_event.DATUM,
			UTM_ZONE,
			UTM_EW,
			UTM_NS,
			ORIG_LAT_LONG_UNITS,
			caclulated_dlat,
			calculated_dlong,
			MINIMUM_ELEVATION,
			MAXIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			MIN_DEPTH,
			MAX_DEPTH,
			DEPTH_UNITS,
			LOCALITY_REMARKS,
			georeference_source,
			georeference_protocol
		from 
			locality,
			geog_auth_rec,
			collecting_event
		where 
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and
			locality.locality_id=collecting_event.locality_id and
			collecting_event.collecting_event_id=<cfqueryparam value = "#collecting_event_id#" CFSQLType = "CF_SQL_INTEGER">
    </cfquery>
	<cfinvoke component="component.functions" method="getEventContents" returnvariable="contents">
	    <cfinvokeargument name="collecting_event_id" value="#collecting_event_id#">
	</cfinvoke>
	#contents#
	<br>
	<form name="localitypick" action="Locality.cfm" method="post">
		<input type="hidden" name="Action" value="changeLocality">
    	<input type="hidden" name="locality_id" value="#locDet.locality_id#">
	 	<input type="hidden" name="collecting_event_id" value="#locDet.collecting_event_id#">
		 <cfif not isdefined("collection_object_id")>
		 	<cfset collection_object_id=-1>
		 </cfif>
	 	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		
		<h4>
			Locality
			<a style="font-size:small;" href="/editLocality.cfm?locality_id=#locDet.locality_id#" target="_top">[ Edit Locality ]</a>
			<input type="button" value="Pick New Locality for this Collecting Event" class="picBtn"
				onclick="document.getElementById('locDesc').style.background='red';
				document.getElementById('hiddenButton').style.visibility='visible';
				LocalityPick('locality_id','spec_locality','localitypick'); return false;" >
		</h4>
		<table width="100%"><tr><td valign="top">
			<ul>
				<li>Higher Geog: #locDet.higher_geog#</li>
				<cfif len(locDet.locality_name) gt 0>
					<li>Locality Name: #locDet.locality_name#</li>
				</cfif>
				<cfif len(locDet.SPEC_LOCALITY) gt 0>
					<li>Specific Locality: #locDet.SPEC_LOCALITY#</li>
				</cfif>
				<cfif len(locDet.ORIG_ELEV_UNITS) gt 0>
					<li>Elevation: #locDet.MINIMUM_ELEVATION#-#locDet.MAXIMUM_ELEVATION# #locDet.ORIG_ELEV_UNITS#</li>
				</cfif>
				<cfif len(locDet.DEPTH_UNITS) gt 0>
					<li>Depth: #locDet.MIN_DEPTH#-#locDet.MAX_DEPTH# #locDet.DEPTH_UNITS#</li>
				</cfif>
				<cfif len(locDet.LOCALITY_REMARKS) gt 0>
					<li>Remark: #locDet.LOCALITY_REMARKS#</li>
				</cfif>
			</ul>
		</td>
		<td valign="top">
			<cfif len(locDet.loclat) gt 0>
				<cfset iu="http://maps.google.com/maps/api/staticmap?center=#locDet.loclat#,#locDet.loclong#">
				<cfset iu=iu & "&markers=color:red|size:tiny|#locDet.loclat#,#locDet.loclong#&sensor=false&size=200x200&zoom=2">
				<cfset iu=iu & "&maptype=roadmap">
				<a href="/bnhmMaps/bnhmPointMapper.cfm?locality_id=#locDet.locality_id#" target="_blank"><img src="#iu#" alt="Google Map"></a>
				<span style="font-size:small;">
					<br>#locDet.loclat# / #locDet.loclong#
					<br>Datum: #locDet.DATUM#
					<br>Error : #locDet.MAX_ERROR_DISTANCE# #locDet.MAX_ERROR_UNITS#
					<br>Georeference Source : #locDet.georeference_source#
					<br>Georeference Protocol : #locDet.georeference_protocol#
				</span>
			</cfif>
		</td></tr></table>
		<div id="hiddenButton" style="visibility:hidden ">
			Picked Locality:
			<input type="text" name="spec_locality" size="50">
			<input type="submit" value="Save Change" class="savBtn">
		</div>
	</form>
	
	<h4>Edit this Collecting Event:</h4>
	<cfform name="locality" method="post" action="Locality.cfm">
    	<input type="hidden" name="Action" value="saveCollEventEdit">
	    <input type="hidden" name="collecting_event_id" value="#locDet.collecting_event_id#">
		<input type="hidden" name="collection_object_id" value="#collection_object_id#">
		<label for="verbatim_locality" class="likeLink" onclick="getDocs('collecting_event','verbatim_locality')">
			Verbatim Locality
		</label>
		<input type="text" name="verbatim_locality" id="verbatim_locality" value='#stripQuotes(locDet.verbatim_locality)#' size="50">
		<label for="specific_locality" class="likeLink" onclick="getDocs('locality','specific_locality')">
			Specific Locality
		</label>
		<div id="specific_locality">
			#locDet.spec_locality#
		</div>
		<label for="verbatim_date" class="likeLink" onclick="getDocs('collecting_event','verbatim_date')">
			Verbatim Date
		</label>
		<input type="text" name="VERBATIM_DATE" id="verbatim_date" value="#locDet.VERBATIM_DATE#" class="reqdClr">
		<table>
			<tr>
				<td>
					<label for="began_date" class="likeLink" onclick="getDocs('collecting_event','began_date')">
						Began Date/Time
					</label>
					<input type="text" name="began_date" id="began_date" value="#locDet.began_date#" size="20">
				</td>
				<td>
					<label for="ended_date" class="likeLink" onclick="getDocs('collecting_event','ended_date')">
						Ended Date/Time
					</label>
					<input type="text" name="ended_date" id="ended_date" value="#locDet.ended_date#" size="20">
				</td>
			</tr>
		</table>
		<label for="coll_event_remarks">coll_event_remarks</label>
		<input type="text" name="coll_event_remarks" id="coll_event_remarks" value="#locDet.COLL_EVENT_REMARKS#" size="50">
		<label for="collecting_event_name">collecting_event_name</label>
		<input type="text" name="collecting_event_name" id="collecting_event_name" value="#locDet.collecting_event_name#" size="50">
		<label>Verbatim Coordinates (These are NOT necessarily the same as the mappable coordinate
		data given for Locality. Entering verbatim coordinates and picking an appropriate locality are separate tasks.)</label>
		<script>
			function showLLFormat(orig_units) {
				$("##dd").hide();
				$("##dms").hide();
				$("##dmm").hide();
				$("##utm").hide();
				
				<!----
				$("##DEC_LAT").val('');
				$("##DEC_LONG").val('');
				$("##LAT_DEG").val('');
				$("##LAT_MIN").val('');
				$("##LAT_SEC").val('');
				$("##LAT_DIR").val('');
				$("##LONG_DEG").val('');
				$("##LONG_MIN").val('');
				$("##LONG_SEC").val('');
				$("##LONG_DIR").val('');
				$("##dmLAT_DEG").val('');
				$("##DEC_LAT_MIN").val('');
				$("##dmLAT_DIR").val('');
				$("##dmLONG_DEG").val('');
				$("##DEC_LONG_MIN").val('');
				$("##dmLONG_DIR").val('');
				$("##UTM_ZONE").val('');
				$("##UTM_EW").val('');
				$("##UTM_NS").val('');
				---->
				if (orig_units == 'decimal degrees') {
					$("##dd").show();
				} 
				else if (orig_units == 'UTM') {
					$("##utm").show();
				}
				else if (orig_units == 'degrees dec. minutes') {
					$("##dmm").show();
				}
				else if (orig_units == 'deg. min. sec.') {
					$("##dms").show();
				}
				$("##orig_lat_long_units").val(orig_units);
			}
		</script>
		
		<div style="border:2px solid black">
			<label for="orig_lat_long_units">orig_lat_long_units</label>
			<select name="orig_lat_long_units" id="orig_lat_long_units" size="1" class="reqdClr" onchange="showLLFormat(this.value);">
				<option value="">none</option>
				<cfloop query="ctlat_long_units">
					<option 
						<cfif ctlat_long_units.orig_lat_long_units is locDet.orig_lat_long_units> selected="selected" </cfif>
						value="#ctlat_long_units.orig_lat_long_units#">#ctlat_long_units.orig_lat_long_units#</option>
				</cfloop>
			</select>
			<label for="datum">datum</label>
			<select name="datum" id="datum" size="1" class="reqdClr">
				<option value="">none</option>
				<cfloop query="ctdatum">
					<option 
						<cfif ctdatum.datum is locDet.datum> selected="selected" </cfif>
						value="#ctdatum.datum#">#ctdatum.datum#</option>
				</cfloop>
			</select>
			<table id="dd" style="display:none;">
				<tr>
					<td>
						<label for="DEC_LAT">DEC_LAT</label>
						<input type="text" name="DEC_LAT" id="DEC_LAT" value="#locDet.DEC_LAT#" size="10">
					</td>
					<td>
						<label for="DEC_LONG">DEC_LONG</label>
						<input type="text" name="DEC_LONG" id="DEC_LONG" value="#locDet.DEC_LONG#" size="10">
					</td>
				</tr>
			</table>
			<table id="dms" style="display:none;">
				<tr>
					<td>
						<label for="LAT_DEG">LAT_DEG</label>
						<input type="text" name="LAT_DEG" id="LAT_DEG" value="#locDet.LAT_DEG#" size="10">
					</td>
					<td>
						<label for="LAT_MIN">LAT_MIN</label>
						<input type="text" name="LAT_MIN" id="LAT_MIN" value="#locDet.LAT_MIN#" size="10">
					</td>
					<td>
						<label for="LAT_SEC">LAT_SEC</label>
						<input type="text" name="LAT_SEC" id="LAT_SEC" value="#locDet.LAT_SEC#" size="10">
					</td>
					<td>
						<label for="LAT_DIR">LAT_DIR</label>
						<select name="LAT_DIR" id="LAT_DIR">
							<option></option>
							<option <cfif locDet.LAT_DIR is "N">selected="selected" </cfif> value="N">N</option>
							<option <cfif locDet.LAT_DIR is "S">selected="selected" </cfif> value="S">S</option>
						</select>
					</td>
					<td>
						<label for="LONG_DEG">LONG_DEG</label>
						<input type="text" name="LONG_DEG" id="LONG_DEG" value="#locDet.LONG_DEG#" size="10">
					</td>
					<td>
						<label for="LONG_MIN">LONG_MIN</label>
						<input type="text" name="LONG_MIN" id="LONG_MIN" value="#locDet.LONG_MIN#" size="10">
					</td>
					<td>
						<label for="LONG_SEC">LONG_SEC</label>
						<input type="text" name="LONG_SEC" id="LONG_SEC" value="#locDet.LONG_SEC#" size="10">
					</td>
					<td>
						<label for="LONG_DIR">LONG_DIR</label>
						<select name="LONG_DIR" id="LONG_DIR">
							<option></option>
							<option <cfif locDet.LONG_DIR is "W">selected="selected" </cfif> value="W">W</option>
							<option <cfif locDet.LONG_DIR is "E">selected="selected" </cfif> value="E">E</option>
						</select>
					</td>
				</tr>
			</table>
			
			<table id="dmm" style="display:none;">
				<tr>
					<td>
						<label for="dmLAT_DEG">LAT_DEG</label>
						<input type="text" name="dmLAT_DEG" id="dmLAT_DEG" value="#locDet.LAT_DEG#" size="10">
					</td>
					<td>
						<label for="DEC_LAT_MIN">DEC_LAT_MIN</label>
						<input type="text" name="DEC_LAT_MIN" id="DEC_LAT_MIN" value="#locDet.DEC_LAT_MIN#" size="10">
					</td>
					<td>
						<label for="dmLAT_DIR">LAT_DIR</label>
						<select name="dmLAT_DIR" id="dmLAT_DIR">
							<option></option>
							<option <cfif locDet.LAT_DIR is "N">selected="selected" </cfif> value="N">N</option>
							<option <cfif locDet.LAT_DIR is "S">selected="selected" </cfif> value="S">S</option>
						</select>
					</td>
					<td>
						<label for="dmLONG_DEG">LONG_DEG</label>
						<input type="text" name="dmLONG_DEG" id="dmLONG_DEG" value="#locDet.LONG_DEG#" size="10">
					</td>
					<td>
						<label for="DEC_LONG_MIN">DEC_LONG_MIN</label>
						<input type="text" name="DEC_LONG_MIN" id="DEC_LONG_MIN" value="#locDet.DEC_LONG_MIN#" size="10">
					</td>
					<td>
						<label for="dmLONG_DIR">LONG_DIR</label>
						<select name="dmLONG_DIR" id="dmLONG_DIR">
							<option></option>
							<option <cfif locDet.LONG_DIR is "W">selected="selected" </cfif> value="W">W</option>
							<option <cfif locDet.LONG_DIR is "E">selected="selected" </cfif> value="E">E</option>
						</select>
					</td>
				</tr>
			</table>
			
			<table id="utm" style="display:none;">
				<tr>
					<td>
						<label for="UTM_ZONE">UTM_ZONE</label>
						<input type="text" name="UTM_ZONE" id="UTM_ZONE" value="#locDet.UTM_ZONE#" size="10">
					</td>
					<td>
						<label for="UTM_EW">UTM_EW</label>
						<input type="text" name="UTM_EW" id="UTM_EW" value="#locDet.UTM_EW#" size="10">
					</td>
				
					<td>
						<label for="UTM_NS">UTM_NS</label>
						<input type="text" name="UTM_NS" id="UTM_NS" value="#locDet.UTM_NS#" size="10">
					</td>
				</tr>
			</table>
		</div>
		
		<script>
			showLLFormat('#locDet.orig_lat_long_units#');
		</script>
        <br><input type="submit" value="Save" class="savBtn">	
			<input type="button" value="Quit" class="qutBtn" onClick="document.location='Locality.cfm';">
		<input type="button" value="Delete" class="delBtn"
			onClick="document.location='Locality.cfm?Action=deleteCollEvent&collecting_event_id=#locDet.collecting_event_id#';">
			<!---
		<cfset dLoc="Locality.cfm?action=newCollEvent&locality_id=#locDet.locality_id#&verbatim_locality=#locDet.verbatim_locality#&began_date=#locDet.began_date#&ended_date=#locDet.began_date#&verbatim_date=#locDet.verbatim_date#&coll_event_remarks=#locDet.coll_event_remarks#&collecting_source=#locDet.collecting_source#&collecting_method=#locDet.collecting_method#&habitat_desc=#locDet.habitat_desc#">
		<input type="button" value="Create Clone" class="insBtn" onClick="document.location='#dLoc#';">				
		---->
	</cfform>
  </cfoutput> 
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "newCollEvent">
<cfoutput>
	<cfquery name="nextColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select sq_collecting_event_id.nextval nextColl from dual
	</cfquery>
	<cfquery name="newCollEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		INSERT INTO collecting_event (
			collecting_event_id,
			LOCALITY_ID
		) values (
			#nextColl.nextColl#,
			#LOCALITY_ID#
		)
	</cfquery>
	<cflocation addtoken="no" url="Locality.cfm?Action=editCollEvnt&collecting_event_id=#nextColl.nextColl#">
</cfoutput>	
</cfif>
<!-------------------------------------------------------------------->
<cfif action is "newLocality">
	<cfif isdefined('geog_auth_rec_id')>
		<cfquery name="getHG" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select higher_geog from geog_auth_rec where geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>
	</cfif>
	<cfoutput>
		<h3>Create locality</h3>
		<br><b>Higher Geography:</b>
		<form name="geog" action="Locality.cfm" method="post">
            <input type="hidden" name="Action" value="makenewLocality">
            <input type="hidden" name="geog_auth_rec_id"
				<cfif isdefined("geog_auth_rec_id")>
					value = "#geog_auth_rec_id#"
				</cfif>>
			<input type="text" name="higher_geog" class="readClr"
				<cfif isdefined("getHG.higher_geog")>
					value = "#getHG.higher_geog#"
				</cfif>
			size="50"  readonly="yes" >
			<input type="button" value="Pick" class="picBtn"
				onclick="GeogPick('geog_auth_rec_id','higher_geog','geog'); return false;">	
   			<cfif isdefined("geog_auth_rec_id")>
				<input type="button" value="Details" class="lnkBtn"
					onclick="document.location='Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#'">	
         	</cfif>
           <label for="spec_locality">Specific Locality</label>
           <input type="text" name="spec_locality" id="spec_locality" 
				<cfif isdefined("spec_locality")>
					value= "#spec_locality#"
				</cfif>
			>
			<label for="minimum_elevation">Minimum Elevation</label>
            <input type="text" name="minimum_elevation" id="minimum_elevation"
				<cfif isdefined("minimum_elevation")>
					value = "#minimum_elevation#"
				</cfif>
			>
			<label for="maximum_elevation">Maximum Elevation</label>
			<input type="text" name="maximum_elevation" id="maximum_elevation"
				<cfif isdefined("maximum_elevation")>
					value = "#maximum_elevation#"
				</cfif>
			>
			<label for="orig_elev_units">Elevation Units</label>
			<select name="orig_elev_units" id="orig_elev_units" size="1">
				<option value=""></option>
                <cfloop query="ctElevUnit">
            	    <option <cfif isdefined("origelevunits") AND ctelevunit.orig_elev_units is origelevunits> selected="selected" </cfif>value="#ctElevUnit.orig_elev_units#">#ctElevUnit.orig_elev_units#</option>
                </cfloop>
			</select>
			<label for="locality_remarks">Locality Remarks</label>
			<input type="text" name="locality_remarks" id="locality_remarks">
			<cfif isdefined("locality_id") and len(locality_id) gt 0>
				<input type="hidden" name="locality_id" value="locality_id" />
				<label for="">Include coordinates from <a href="/editLocality.cfm?locality_id=#locality_id#">#locality_id#</a>?</label>
				Y<input type="radio" name="cloneCoords" value="yes" />
				<br>N<input type="radio" name="cloneCoords" value="no" checked="checked" />
		 	</cfif>
            <br><input type="submit" value="Save" class="savBtn">	
  			<input type="button" value="Quit" class="qutBtn" onClick="document.location='Locality.cfm';">
		</form>
	</cfoutput>
</cfif> 

<!---------------------------------------------------------------------------------------------------->
<cfif action is "deleteGeog">
<cfoutput>
	<cfquery name="isLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select geog_auth_rec_id from locality where geog_auth_rec_id=#geog_auth_rec_id#
	</cfquery>
<cfif len(#isLocality.geog_auth_rec_id#) gt 0>
	There are active localities for this Geog. It cannot be deleted.
	<br><a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">Return</a> to editing.
	<cfabort>
<cfelseif len(#isLocality.geog_auth_rec_id#) is 0>
	<cfquery name="deleGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from geog_auth_rec where geog_auth_rec_id=#geog_auth_rec_id#
	</cfquery>
</cfif>	
<cflocation addtoken="no" url="#cgi.HTTP_REFERER#">	
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "deleteCollEvent">
<cfoutput>
	<cfquery name="isSpec" datasource="uam_god">
		select collection_object_id from cataloged_item where collecting_event_id=#collecting_event_id#
	</cfquery>
<cfif len(#isSpec.collection_object_id#) gt 0>
	There are specimens for this collecting event. It cannot be deleted. If you can't see them, perhaps they aren't in 
	the collection list you've set in your preferences.
	<br><a href="Locality.cfm?Action=editCollEvent&collecting_event_id=#collecting_event_id#">Return</a> to editing.
	<cfabort>
<cfelseif len(#isSpec.collection_object_id#) is 0>
	<cfquery name="deleCollEv" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	delete from collecting_event where collecting_event_id=#collecting_event_id#
	</cfquery>
</cfif>	
You deleted a collecting event.
<br>Go back to <a href="Locality.cfm">localities</a>.
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "changeLocality">
<cfoutput>
	<cfquery name="upColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE collecting_event SET locality_id=#locality_id# where collecting_event_id=#collecting_event_id#
	</cfquery>
		 <cfif not isdefined("collection_object_id")>
		 	<cfset collection_object_id=-1>
		 </cfif>
	<cflocation addtoken="no" url="Locality.cfm?collection_object_id=#collection_object_id#&action=editCollEvnt&collecting_event_id=#collecting_event_id#">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveCollEventEdit">
	<cfoutput>
		
		
			
	<cfquery name="upColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		UPDATE 
			collecting_event 
		SET 
			BEGAN_DATE = '#BEGAN_DATE#',
			ENDED_DATE = '#ENDED_DATE#',
			VERBATIM_DATE = '#escapeQuotes(VERBATIM_DATE)#',
			verbatim_locality = '#escapeQuotes(verbatim_locality)#',
			COLL_EVENT_REMARKS = '#escapeQuotes(COLL_EVENT_REMARKS)#',
			collecting_event_name = '#escapeQuotes(collecting_event_name)#',
			orig_lat_long_units = '#escapeQuotes(orig_lat_long_units)#',
			
				
			
			<cfif orig_lat_long_units is "degrees dec. minutes">
				LAT_DEG=#dmLAT_DEG#,
				LONG_DEG=#dmLONG_DEG#,
				LAT_DIR = '#dmLAT_DIR#',
				LONG_DIR = '#dmLONG_DIR#',
				DEC_LAT_MIN=#DEC_LAT_MIN#,
				dec_long_min=#dec_long_min#,
				LAT_MIN=NULL,
				LAT_SEC=NULL,
				LONG_MIN=NULL,
				LONG_SEC=NULL,
				UTM_EW=NULL,
				UTM_NS=NULL,
				UTM_ZONE = NULL,
			<cfelseif orig_lat_long_units is "UTM">
				dec_lat=NULL,
				DEC_LONG=NULL,
				LAT_DEG=NULL,
				LONG_DEG=NULL,
				LAT_MIN=NULL,
				LAT_SEC=NULL,
				LONG_MIN=NULL,
				LONG_SEC=NULL,
				DEC_LAT_MIN=NULL,
				dec_long_min=NULL,
				UTM_EW=#UTM_EW#,
				UTM_NS=#UTM_NS#,
				UTM_ZONE = '#UTM_ZONE#',
			<cfelseif orig_lat_long_units is "decimal degrees">
				dec_lat=#dec_lat#,
				DEC_LONG=#DEC_LONG#,
				LAT_DEG=NULL,
				LAT_MIN=NULL,
				LAT_SEC=NULL,
				LONG_DEG=NULL,
				LONG_MIN=NULL,
				LONG_SEC=NULL,
				DEC_LAT_MIN=NULL,
				dec_long_min=NULL,
				UTM_EW=NULL,
				UTM_NS=NULL,
				UTM_ZONE = NULL,
				LAT_DIR=NULL,
				LONG_DIR=NULL,
			<cfelseif orig_lat_long_units is "deg. min. sec.">
				LAT_DEG=#LAT_DEG#,
				LAT_MIN=#LAT_MIN#,
				LAT_SEC=#LAT_SEC#,
				LONG_DEG=#LONG_DEG#,
				LONG_MIN=#LONG_MIN#,
				LONG_SEC=#LONG_SEC#,
				dec_lat=NULL,
				DEC_LONG=NULL,
				DEC_LAT_MIN=NULL,
				dec_long_min=NULL,
				UTM_EW=NULL,
				UTM_NS=NULL,
				UTM_ZONE = NULL,
			<cfelse>
				dec_lat=NULL,
				DEC_LONG=NULL,
				LAT_DEG=NULL,
				LAT_MIN=NULL,
				LAT_SEC=NULL,
				LONG_DEG=NULL,
				LONG_MIN=NULL,
				LONG_SEC=NULL,
				DEC_LAT_MIN=NULL,
				dec_long_min=NULL,
				UTM_EW=NULL,
				UTM_NS=NULL,
				UTM_ZONE = NULL,
				LAT_DIR=NULL,
				LONG_DIR=NULL,
			</cfif> 
			datum = '#escapeQuotes(datum)#'
		where collecting_event_id = <cfqueryparam value = "#collecting_event_id#" CFSQLType = "CF_SQL_INTEGER">
	</cfquery>	
		
	<cfif #cgi.HTTP_REFERER# contains "editCollEvnt">
		<cfset refURL = "#cgi.HTTP_REFERER#">
	<cfelse>
		<cfset refURL = "#cgi.HTTP_REFERER#?collection_object_id=#collection_object_id#&action=editCollEvnt&collecting_event_id=#collecting_event_id#">
	</cfif>
	<cflocation addtoken="no" url="#refURL#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveGeogEdits">
	<cfoutput>
	<cfset srcAuth = #replace(source_authority,"'","''")#>
	<cfset sql = "UPDATE geog_auth_rec SET source_authority = '#srcAuth#'
		,valid_catalog_term_fg = #valid_catalog_term_fg#">
	<cfif len(#continent_ocean#) gt 0>
		<cfset sql = "#sql#,continent_ocean = '#continent_ocean#'">
	<cfelse>
		<cfset sql = "#sql#,continent_ocean = null">
	</cfif>
	
	<cfif len(#country#) gt 0>
		<cfset sql = "#sql#,country = '#country#'">
	<cfelse>
		<cfset sql = "#sql#,country = null">
	</cfif>
	
	<cfif len(#state_prov#) gt 0>
		<cfset sql = "#sql#,state_prov = '#state_prov#'">
	<cfelse>
		<cfset sql = "#sql#,state_prov = null">
	</cfif>
	
	<cfif len(#county#) gt 0>
		<cfset sql = "#sql#,county = '#county#'">
	<cfelse>
		<cfset sql = "#sql#,county = null">
	</cfif>
	
	<cfif len(#quad#) gt 0>
		<cfset sql = "#sql#,quad = '#quad#'">
	<cfelse>
		<cfset sql = "#sql#,quad = null">
	</cfif>
	<cfif len(#feature#) gt 0>
		<cfset sql = "#sql#,feature = '#feature#'">
	<cfelse>
		<cfset sql = "#sql#,feature = null">
	</cfif>
	<cfif len(#island_group#) gt 0>
		<cfset sql = "#sql#,island_group = '#island_group#'">
	<cfelse>
		<cfset sql = "#sql#,island_group = null">
	</cfif>
	<cfif len(#island#) gt 0>
		<cfset sql = "#sql#,island = '#island#'">
	<cfelse>
		<cfset sql = "#sql#,island = null">
	</cfif>
	<cfif len(#sea#) gt 0>
		<cfset sql = "#sql#,sea = '#sea#'">
	<cfelse>
		<cfset sql = "#sql#,sea = null">
	</cfif>
	<cfset sql = "#sql# where geog_auth_rec_id = #geog_auth_rec_id#">
	<cfquery name="edGe" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#		
	</cfquery>
	<cflocation addtoken="no" url="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "makeGeog">
<cfoutput>
<cfquery name="nextGEO" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select sq_geog_auth_rec_id.nextval nextid from dual
</cfquery>
<cfquery name="newGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
INSERT INTO geog_auth_rec (
	geog_auth_rec_id
	<cfif len(#continent_ocean#) gt 0>
		,continent_ocean
	</cfif>
	<cfif len(#country#) gt 0>
		,country
	</cfif>
	<cfif len(#state_prov#) gt 0>
		,state_prov
	</cfif>
	<cfif len(#county#) gt 0>
		,county
	</cfif>
	<cfif len(#quad#) gt 0>
		,quad
	</cfif>
	<cfif len(#feature#) gt 0>
		,feature
	</cfif>
	<cfif len(#island_group#) gt 0>
		,island_group
	</cfif>
	<cfif len(#island#) gt 0>
		,island
	</cfif>
	<cfif len(#sea#) gt 0>
		,sea
	</cfif>
		,valid_catalog_term_fg
		,source_authority
		)
	VALUES (
		#nextGEO.nextid#
		<cfif len(#continent_ocean#) gt 0>
		,'#continent_ocean#'
	</cfif>
	<cfif len(#country#) gt 0>
		,'#country#'
	</cfif>
	<cfif len(#state_prov#) gt 0>
		,'#state_prov#'
	</cfif>
	<cfif len(#county#) gt 0>
		,'#county#'
	</cfif>
	<cfif len(#quad#) gt 0>
		,'#quad#'
	</cfif>
	<cfif len(#feature#) gt 0>
		,'#feature#'
	</cfif>
	<cfif len(#island_group#) gt 0>
		,'#island_group#'
	</cfif>
	<cfif len(#island#) gt 0>
		,'#island#'
	</cfif>
	<cfif len(#sea#) gt 0>
		,'#sea#'
	</cfif>
		,#valid_catalog_term_fg#
		,'#source_authority#'
)
</cfquery>
<cflocation addtoken="no" url="Locality.cfm?Action=editGeog&geog_auth_rec_id=#nextGEO.nextid#">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "makenewLocality">
	<cfoutput>
	<cftransaction>
	<cfif not isdefined("cloneCoords") or #cloneCoords# is not "yes">
		<cfset cloneCoords = "no">
	</cfif>
	<cfquery name="nextLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select sq_locality_id.nextval nextLoc from dual
	</cfquery>
	<cfquery name="newLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	INSERT INTO locality (
		LOCALITY_ID,
		GEOG_AUTH_REC_ID
		,MAXIMUM_ELEVATION
		,MINIMUM_ELEVATION
		,ORIG_ELEV_UNITS
		,SPEC_LOCALITY
		,LOCALITY_REMARKS
		,LEGACY_SPEC_LOCALITY_FG )
	VALUES (
		#nextLoc.nextLoc#,
		#GEOG_AUTH_REC_ID#
		<cfif len(#MAXIMUM_ELEVATION#) gt 0>
			,#MAXIMUM_ELEVATION#
		<cfelse>
			,NULL
		</cfif>
		<cfif len(#MINIMUM_ELEVATION#) gt 0>
			,#MINIMUM_ELEVATION#
		<cfelse>
			,NULL
		</cfif>
		<cfif len(#orig_elev_units#) gt 0>
			,'#orig_elev_units#'
		<cfelse>
			,NULL
		</cfif>
		<cfif len(#SPEC_LOCALITY#) gt 0>
			,'#SPEC_LOCALITY#'
		<cfelse>
			,NULL
		</cfif>
		<cfif len(#LOCALITY_REMARKS#) gt 0>
			,'#LOCALITY_REMARKS#'
		<cfelse>
			,NULL
		</cfif>
		,0 )
		</cfquery>
		<cfif #cloneCoords# is "yes">
			<cfquery name="cloneCoordinates" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select * from lat_long where locality_id = #locality_id#
			</cfquery>
			<cfloop query="cloneCoordinates">
				<cfset thisLatLongId = #llID.mLatLongId# + 1>
				<cfquery name="newLL" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					INSERT INTO lat_long (
						LAT_LONG_ID,
						LOCALITY_ID
						,LAT_DEG
						,DEC_LAT_MIN
						,LAT_MIN
						,LAT_SEC
						,LAT_DIR
						,LONG_DEG
						,DEC_LONG_MIN
						,LONG_MIN
						,LONG_SEC
						,LONG_DIR
						,DEC_LAT
						,DEC_LONG
						,DATUM
						,UTM_ZONE
						,UTM_EW
						,UTM_NS
						,ORIG_LAT_LONG_UNITS
						,DETERMINED_BY_AGENT_ID
						,DETERMINED_DATE
						,LAT_LONG_REF_SOURCE
						,LAT_LONG_REMARKS
						,MAX_ERROR_DISTANCE
						,MAX_ERROR_UNITS
						,NEAREST_NAMED_PLACE
						,LAT_LONG_FOR_NNP_FG
						,FIELD_VERIFIED_FG
						,ACCEPTED_LAT_LONG_FG
						,EXTENT
						,GPSACCURACY
						,GEOREFMETHOD
						,VERIFICATIONSTATUS)
					VALUES (
						sq_lat_long_id.nextval,
						#nextLoc.nextLoc#
						<cfif len(#LAT_DEG#) gt 0>
							,#LAT_DEG#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#DEC_LAT_MIN#) gt 0>
							,#DEC_LAT_MIN#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#LAT_MIN#) gt 0>
							,#LAT_MIN#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#LAT_SEC#) gt 0>
							,#LAT_SEC#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#LAT_DIR#) gt 0>
							,'#LAT_DIR#'
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#LONG_DEG#) gt 0>
							,#LONG_DEG#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#DEC_LONG_MIN#) gt 0>
							,#DEC_LONG_MIN#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#LONG_MIN#) gt 0>
							,#LONG_MIN#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#LONG_SEC#) gt 0>
							,#LONG_SEC#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#LONG_DIR#) gt 0>
							,'#LONG_DIR#'
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#DEC_LAT#) gt 0>
							,#DEC_LAT#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#DEC_LONG#) gt 0>
							,#DEC_LONG#
						<cfelse>
							,NULL
						</cfif>
						,'#DATUM#'
						<cfif len(#UTM_ZONE#) gt 0>
							,'#UTM_ZONE#'
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#UTM_EW#) gt 0>
							,'#UTM_EW#'
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#UTM_NS#) gt 0>
							,'#UTM_NS#'
						<cfelse>
							,NULL
						</cfif>
						,'#ORIG_LAT_LONG_UNITS#'
						,#DETERMINED_BY_AGENT_ID#
						,'#dateformat(DETERMINED_DATE,"yyyy-mm-dd")#'
						,'#LAT_LONG_REF_SOURCE#'
						<cfif len(#LAT_LONG_REMARKS#) gt 0>
							,'#LAT_LONG_REMARKS#'
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#MAX_ERROR_DISTANCE#) gt 0>
							,#MAX_ERROR_DISTANCE#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#MAX_ERROR_UNITS#) gt 0>
							,'#MAX_ERROR_UNITS#'
						<cfelse>
							,NULL
						</cfif>			
						<cfif len(#NEAREST_NAMED_PLACE#) gt 0>
							,'#NEAREST_NAMED_PLACE#'
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#LAT_LONG_FOR_NNP_FG#) gt 0>
							,#LAT_LONG_FOR_NNP_FG#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#FIELD_VERIFIED_FG#) gt 0>
							,#FIELD_VERIFIED_FG#
						<cfelse>
							,NULL
						</cfif>
						,#ACCEPTED_LAT_LONG_FG#
						<cfif len(#EXTENT#) gt 0>
							,#EXTENT#
						<cfelse>
							,NULL
						</cfif>
						<cfif len(#GPSACCURACY#) gt 0>
							,#GPSACCURACY#
						<cfelse>
							,NULL
						</cfif>
						,'#GEOREFMETHOD#'
						,'#VERIFICATIONSTATUS#')
				</cfquery>
			</cfloop>
			

		</cfif>
		</cftransaction>
	<cflocation addtoken="no" url="editLocality.cfm?locality_id=#nextLoc.nextLoc#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findCollEvent">
	<cfoutput>
		<form name="tools" method="post" action="Locality.cfm">
			<input type="hidden" name="action" value="massMoveCollEvent" />
			<cf_findLocality>
			<cfquery name="localityResults" dbtype="query">
				select
					collecting_event_id,
					higher_geog,
					geog_auth_rec_id,
					spec_locality,
					geolAtts,
					Verbatim_coordinates,
					locality_id,
					verbatim_locality,
					began_date,
					ended_date,
					verbatim_date
				from localityResults
				group by 
					collecting_event_id,
					higher_geog,
					geog_auth_rec_id,
					spec_locality,
					geolAtts,
					Verbatim_coordinates,
					locality_id,
					verbatim_locality,
					began_date,
					ended_date,
					verbatim_date
			</cfquery>
	
<table border>
	<tr>
		<td><b>Geog</b></td>
		<td><b>Locality</b></td>
		<td><b>Verbatim&nbsp;Locality</b></td>
		<td><b>Began&nbsp;Date</b></td>
		<td><b>End&nbsp;Date</b></td>
		<td><b>Verb.&nbsp;Date</b></td>
	</tr>
	<cfloop query="localityResults">
		<input type="hidden" name="collecting_event_id" value="#collecting_event_id#" />
		<tr>
			<td> <div class="smaller">#higher_geog#
				(<a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">#geog_auth_rec_id#</a>)
				</div>
			</td>
			<td>
				 <div class="smaller">
				 #spec_locality# <cfif len(geolAtts) gt 0>[#geolAtts#]</cfif>
					<cfif len(#Verbatim_coordinates#) gt 0>
						<br>#Verbatim_coordinates#
					</cfif> 
					(<a href="editLocality.cfm?locality_id=#locality_id#">#locality_id#</a>)
				</div>
			<!---&nbsp;<a href="/fix/DupLocs.cfm?action=killDups&locid=#locality_id#" target="_blank"><font size="-2"><i>kill dups</i></font></a>---></td>
			<td>
				<div class="smaller">
				 	#verbatim_locality#
					(<a href="Locality.cfm?Action=editCollEvnt&collecting_event_id=#collecting_event_id#">#collecting_event_id#</a>)
				</div>
			</td>
			<td>#began_date#</td>
			<td>#ended_date#</td>
			<td>#verbatim_date#</td>
		</tr>
	</cfloop>
</table>
			<input type="submit" value="Move These Collecting Events to new Locality" class="savBtn">
		</form>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "massMoveCollEvent">
	<cfoutput>
		<cfset numCollEvents = listlen(collecting_event_id)>
		
		
		
  <cfquery name="whatSpecs" datasource="uam_god">
  	SELECT count(cat_num) as numOfSpecs, 
	collection.collection_cde,
	collection.institution_acronym
	from cataloged_item,collection WHERE
	cataloged_item.collection_id = collection.collection_id AND
	collecting_event_id IN (#collecting_event_id#) 
	GROUP BY collection.collection_cde,collection.institution_acronym
  </cfquery>
  <table>
  <tr>
  	<td>
  <cfif #whatSpecs.recordcount# is 0>
  		<font color="##FF0000"><strong>These #numCollEvents# Collecting Events</strong></font>	
		<span style="font-size:small;">
		(#collecting_event_id#) 
		</span>
		<font color="##FF0000"><strong>
		<a href="javascript:void(0);" onClick="getDocs('collecting_event')"><img src="/images/info.gif" border="0"></a>
		contains no specimens. Please delete it if you don't have plans for it!</strong></font>	
  	<cfelseif #whatSpecs.recordcount# is 1>
		<font color="##FF0000"><strong>These #numCollEvents# Collecting Events </strong></font>	
		<span style="font-size:small;">
		(#collecting_event_id#) 
		</span>
		<font color="##FF0000"><strong>
		<a href="javascript:void(0);" onClick="getDocs('collecting_event')"><img src="/images/info.gif" border="0"></a>
		contains #whatSpecs.numOfSpecs# #whatSpecs.collection_cde#
		<a href="SpecimenResults.cfm?collecting_event_id=#collecting_event_id#">specimens</a>.</strong></font>	
	<cfelse>
		<font color="##FF0000"><strong>These #numCollEvents# Collecting Events
		 </strong></font>	
		<span style="font-size:small;">
		(#collecting_event_id#) 
		</span>
		<font color="##FF0000"><strong>
		<a href="javascript:void(0);" onClick="getDocs('collecting_event')"><img src="/images/info.gif" border="0"></a>
		contains the following <a href="SpecimenResults.cfm?collecting_event_id=#collecting_event_id#">specimens</a>:</strong></font>	  
		<ul>	
			<cfloop query="whatSpecs">
				<li><font color="##FF0000"><strong>#numOfSpecs# #collection_cde#</strong></font></li>
			</cfloop>			
		</ul>
  </cfif>
  
  <cfquery name="cd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
  	select * from collecting_event
	inner join locality on (collecting_event.locality_id = locality.locality_id)
	inner join geog_auth_rec on (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
	left outer join accepted_lat_long on (locality.locality_id = accepted_lat_long.locality_id)
	where collecting_event.collecting_event_id IN (#collecting_event_id#)
  </cfquery>
  <p></p>Current Data:
  <table border>
  	<tr>
		<td>Spec Loc</td>
		<td>Geog</td>
		<td>Lat/Long</td>
	</tr>
	<cfloop query="cd">
		<tr>
			<td><a href="editLocality.cfm?locality_id=#locality_id#">#spec_locality#</a></td>
			<td>#higher_geog#</td>
			<td>#dec_lat# #dec_long#</td>
		</tr>
	</cfloop>
  </table>
  <p>
	<form name="mlc" method="post" action="Locality.cfm">
		<input type="hidden" name="action" value="mmCollEvnt2" />
		<input type="hidden" name="collecting_event_id" value="#collecting_event_id#" />
		<input type="hidden" name="locality_id" />
		
		<input type="button" 
			value="Pick New Locality" 
			class="picBtn"
			onmouseover="this.className='picBtn btnhov'" 
			onmouseout="this.className='picBtn'"
			onclick="document.getElementById('theSpanSaveThingy').style.display='';LocalityPick('locality_id','spec_locality','mlc'); return false;" >
			<input type="text" name="spec_locality" readonly="readonly" border="0" size="60"/>
			<span id="theSpanSaveThingy" style="display:none;">
				<input type="submit" value="Save" />	
			</span>
				
		</form>
  </p>
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "mmCollEvnt2">
	<cfoutput>
		<cftransaction>
		<cfloop list="#collecting_event_id#" index="ceid">
			<cfquery name="upCollLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update collecting_event set locality_id = #locality_id#
			where collecting_event_id = #ceid#
			</cfquery>
		</cfloop>
		</cftransaction>
		<cflocation url="Locality.cfm?Action=findCollEvent&locality_id=#locality_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findLocality">
<cfoutput>
	<cf_findLocality>
	<cfset title="Locality Search Results">
	<!--- need to filter out distinct --->
	<cfquery name="localityResults" dbtype="query">
		select 
			locality_id,
            geog_auth_rec_id,
            spec_locality,
            higher_geog,
            verbatim_coordinates,
			geolAtts           
		from localityResults
		group by
            locality_id,
            geog_auth_rec_id,
            spec_locality,
            higher_geog,
            verbatim_coordinates,
			geolAtts  
	</cfquery>
	<cfif localityResults.recordcount lt 1000>
		<a href="/bnhmMaps/bnhmPointMapper.cfm?locality_id=#valuelist(localityResults.locality_id)#" target="_blank">BerkeleyMapper</a>
	<cfelse>
		1000 record limit on mapping, sorry...
	</cfif>
	<br /><strong>Your query found #localityResults.recordcount# localities.</strong>
	<table border id="t" class="sortable">
		<tr>
			<th><b>Geog</b></th>
	    	<th><b>Locality</b></th>
	    	<th><b>Locality Metadata</b></th>
		</tr>
		<cfset i=1>
		<cfloop query="localityResults">
			<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
				<td>
					#higher_geog# <a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">(#geog_auth_rec_id#)</a>
				</td>
				<td>
					<div>
						#spec_locality# <a href="editLocality.cfm?locality_id=#locality_id#">(#locality_id#)</a>
					</div>
				</td>
				<td>
					<cfif len(geolAtts) gt 0>
						<div>
							Geology: #geolAtts#]
						</div>
					</cfif>
					<div>
						<cfif len(verbatim_coordinates) gt 0>
							#verbatim_coordinates#
							<span style='font-size:smaller'>
								<em>Determined by</em>....
							</span>
			
						</cfif>
					</div>
				</td>
			</tr>
			<cfset i=i+1>
		</cfloop>
	</table>
</cfoutput> 
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "findGeog">
<cfoutput>
		<cf_findLocality>
		<!--- need to filter out distinct --->
		<cfquery name="localityResults" dbtype="query">
			select geog_auth_rec_id,higher_geog
			from localityResults
			group by geog_auth_rec_id,higher_geog
		</cfquery>
<table border>
<tr><td><b>Geog ID</b></td><td><b>Higher Geog</b></td></tr>
<cfloop query="localityResults">
<tr>
	<td><a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">#geog_auth_rec_id#</a></td>
	<td>
		<!--- make this as input that looks like test to make copying easier --->
		<input style="border:none;" value="#higher_geog#" size="80" readonly="yes"/>
	</td>
</tr>
</cfloop>
</cfoutput>
</table>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfinclude template="includes/_footer.cfm">