<div id="theHead">
	<cfinclude template="includes/_header.cfm">
</div>
<cfoutput>
<!--- see if action is duplicated --->
<cfif #action# contains ",">
	<cfset i=1>
	<cfloop list="#action#" delimiters="," index="a">
		<cfif #i# is 1>
			<cfset firstAction = #a#>
		<cfelse>
			<cfif #a# neq #firstAction#>
				An error has occured! Multiple Action in Locality. Please submit a bug report.
				<cfabort>
			</cfif>
		</cfif>
	</cfloop>
	<cfset action = #firstAction#>
</cfif>
<cfif isdefined("collection_object_id") AND #collection_object_id# gt 0 AND #action# is "nothing">
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
<cfif #action# is "findCollEventIdForSpecDetail">
	<!--- get a collecting event ID and relocate to editCollEvnt --->
	<cfquery name="ceid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collecting_event_id from cataloged_item where
		collection_object_id=#collection_object_id#
	</cfquery>
	<cflocation url="Locality.cfm?action=editCollEvnt&collecting_event_id=#ceid.collecting_event_id#">
</cfif>
<!--- only put a header on if we aren't in a frame --->

</div><!--- kill content div --->

</cfoutput>
<cfif not isdefined("collection_object_id")>
		<cfset collection_object_id=-1>
	</cfif>
 <cfif not isdefined("anchor")>
		   		<cfset anchor="">
		   </cfif>
<!--------------------------- Code-table queries --------------------------------------------------> 

<cfquery name="ctIslandGroup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select island_group from ctisland_group order by island_group
</cfquery>
<cfquery name="ctGeogSrcAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select source_authority from ctgeog_source_authority order by source_authority
</cfquery>
<cfquery name="ctElevUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select orig_elev_units from ctorig_elev_units order by orig_elev_units
</cfquery>
<cfquery name="ctCollecting_Source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collecting_source from ctCollecting_Source order by collecting_source
</cfquery>
<cfquery name="ctFeature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(feature) from ctfeature order by feature
</cfquery>
	<cfquery name="ctGeorefMethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select georefMethod from ctgeorefmethod order by georefMethod
</cfquery>
<cfquery name="ctVerificationStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select VerificationStatus from ctVerificationStatus order by VerificationStatus
</cfquery>

<!--------------------------- End Code-table queries -------------------------------------------------->

<!--------------------------- Forms -------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "nothing">
<cfoutput>
<cfset title="Manage Localities">
<table border>
	<tr>
		<td>Higher Geography</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="findHG">
				  <input type="submit" value="Find" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">	
			</form>
		</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="newHG">
				<input type="submit" value="New Higher Geog" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">
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
				<input type="submit" value="Find" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">
			
			</form>	
		</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="newLocality">
				<input type="submit" value="New Locality" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">
			</form>
		</td>
		<td>
			<!---<a href="javascript:void(0);" onClick="getDocs('locality')"><img src="/images/what.gif" border="0"></a>--->
			<span class="infoLink" onclick="getDocs('locality');">Define</span>
		</td>
	</tr>
	<tr>
		<td>Collecting Events</td>
		<td>
			<form name="nothing" method="post" action="Locality.cfm">
				<input type="hidden" name="Action" value="findCO">
				<input type="submit" value="Find" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'">
			</form>		
		</td>
		<td>(Find and clone to create new)</td>
		<td>
			<!---<a href="javascript:void(0);" onClick="getDocs('collecting_event')"><img src="/images/what.gif" border="0"></a>--->
			<span class="infoLink" onclick="getDocs('collecting_event');">Define</span>
		</td>
	</tr>
</table>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "findHG">
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
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "newHG">
<cfoutput>
<cfset title="Create Higher Geography">
<b>Create Higher Geography:</b>

<cfform name="getHG" method="post" action="Locality.cfm">
	<input type="hidden" name="Action" value="makeGeog">
	
	<table>
		<tr>
			<td align="right">Continent or Ocean:</td>
			<td><input type="text" name="continent_ocean" 
		<cfif isdefined("continent_ocean")> value = "#continent_ocean#"</cfif>></td>
		</tr>
		<tr>
			<td align="right">Country:</td>
			<td><input type="text" name="country"
		<cfif isdefined("country")> value = "#country#"</cfif>></td>
		</tr>
		<tr>
			<td align="right">State:</td>
			<td><input type="text" name="state_prov"
		<cfif isdefined("state_prov")> value = "#state_prov#"</cfif>></td>
		</tr>
		<tr>
			<td align="right">County:</td>
			<td><input type="text" name="county"
		<cfif isdefined("county")> value = "#county#"</cfif>></td>
		</tr>
		<tr>
			<td align="right">Quad:</td>
			<td><input type="text" name="quad"
		<cfif isdefined("quad")> value = "#quad#"</cfif>></td>
		</tr>
		<tr>
			<td align="right">Feature:</td>
			<td>
			<cfif isdefined("feature")>
				<cfset thisFeature = #feature#>
			<cfelse>
				<cfset thisFeature = "">
			</cfif>
			<select name="feature">
				<option value=""></option>
					<cfloop query="ctFeature">
						<option 
							<cfif #thisFeature# is "#ctFeature.feature#"> selected </cfif>
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
						<cfif #ctIslandGroup.island_group# is #islandgroup#> selected </cfif>
					</cfif>value="#ctIslandGroup.island_group#">#ctIslandGroup.island_group#
				</option>
			</cfloop>
		</select></td>
		</tr>
		<tr>
			<td align="right">Island:</td>
			<td><input type="text" name="island"
		<cfif isdefined("island")> value = "#island#"</cfif> size="50"></td>
		</tr>
		<tr>
			<td align="right">Sea:</td>
			<td><input type="text" name="sea"
		<cfif isdefined("sea")> value = "#sea#"</cfif>></td>
		</tr>
		<tr>
			<td align="right">Valid?</td>
			<td><select name="valid_catalog_term_fg" class="reqdClr">
			<option value=""></option>
			<option value="1">yes</option>
			<option value="0">no</option>
		</select></td>
		</tr>
		<tr>
			<td align="right">Source Authority:</td>
			<td><select name="source_authority" size="1" class="reqdClr">
			<option value=""></option>
			<cfloop query="ctGeogSrcAuth">
				<option value="#ctGeogSrcAuth.source_authority#">#ctGeogSrcAuth.source_authority#</option>
			</cfloop>
		</select></td>
		</tr>
		<tr>
			<td colspan="2">
			
   
   	
   <input type="submit" value="Create" class="insBtn"
   onmouseover="this.className='insBtn btnhov'" onmouseout="this.className='insBtn'">
   
    <input type="button" value="Quit" class="qutBtn"
   onmouseover="this.className='qutBtn btnhov'" onmouseout="this.className='qutBtn'"
   onclick="document.location='Locality.cfm';" >	
   
	</td>
		</tr>
	</table>
</cfform>
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "findLO">
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
<cfif #Action# is "findCO">
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
<cfif #Action# is "editGeog">
<cfset title = "Edit Geography">
  <cfoutput> 
          <cfquery name="geogDetails" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
         	 select * from geog_auth_rec where geog_auth_rec_id = #geog_auth_rec_id# 
          </cfquery>
		<font size="+1"><strong>Edit Higher Geography</strong></font>
		  <a href="javascript:void(0);" onClick="getDocs('higher_geography')"><img src="/images/info.gif" border="0"></a>
		 
		<cfquery name="localities" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(*) c from locality where geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>
		<cfquery name="collecting_events" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(*) c from locality,collecting_event
			where
			locality.locality_id = collecting_event.locality_id AND
			 geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>
		<cfquery name="specimen" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(*) c from locality,collecting_event,cataloged_item
			where
			locality.locality_id = collecting_event.locality_id AND
			collecting_event.collecting_event_id = cataloged_item.collecting_event_id AND
			 geog_auth_rec_id=#geog_auth_rec_id#
		</cfquery>
		<div style="border:2px solid blue; background-color:red;">
			Altering this record will update:
			<ul>
				<li>#localities.c# localities</li>
				<li>#collecting_events.c# collecting events</li>
				<li>#specimen.c# specimens</li>
			</ul>
		</div>
    </cfoutput> <cfoutput query="geogDetails"> 
		   <br><em>#higher_geog#</em>
          <cfform name="getHG" method="post" action="Locality.cfm">
            <p> 
              <input name="Action" type="hidden" value="saveGeogEdits">
              <input type="hidden" name="geog_auth_rec_id" value="#geog_auth_rec_id#">
            </p>
            <table cellpadding="0" cellspacing="0">
              <tr valign="bottom"> 
                <td><div align="left">
				<a href="javascript:void(0);" class="novisit "onClick="getDocs('higher_geography','continent_ocean')">
				Continent or Ocean</a>
				</div></td>
				<td ><div align="left">
				<a href="javascript:void(0);" class="novisit "onClick="getDocs('higher_geography','country')">
				Country</a>
				</div></td>
				<td><div align="left">
				<a href="javascript:void(0);" class="novisit "onClick="getDocs('higher_geography','state_province')">
				State</a>
				</div></td>
				 <td><div align="left">
				 <a href="javascript:void(0);" class="novisit "onClick="getDocs('higher_geography','sea')">
				Sea</a>
				</div></td>
                
              </tr>
              <tr> 
                <td><input type="text" name="continent_ocean" value="#continent_ocean#"></td>
                <td><input type="text" name="country" value="#country#"></td>
				<td><input type="text" name="state_prov" value="#state_prov#"></td>
				 <td><input type="text" name="sea" value="#sea#"></td>
              </tr>
           
              <tr valign="bottom"> 
			  	
                <td><div align="left">
				<a href="javascript:void(0);" class="novisit "onClick="getDocs('higher_geography','count')">
				County</a>
				</div></td>
				  <td><div align="left">
				  <a href="javascript:void(0);" class="novisit "onClick="getDocs('higher_geography','map_name')">
				Quad</a>
				</div></td>
				  <td colspan="2">
				   <a href="javascript:void(0);" class="novisit "onClick="getDocs('higher_geography','feature')">
				Feature</a>
				</td>
               
              </tr>
              <tr> 
              	
				  <td><input type="text" name="county" value="#county#"></td>
                <td><input type="text" name="quad" value="#quad#"></td>
				<td colspan="2">
					<cfif isdefined("feature")>
						<cfset thisFeature = #feature#>
					<cfelse>
						<cfset thisFeature = "">
					</cfif>
					<select name="feature">
						<option value=""></option>
							<cfloop query="ctFeature">
								<option 
									<cfif #thisFeature# is "#ctFeature.feature#"> selected </cfif>
									value = "#ctFeature.feature#">#ctFeature.feature#</option>
							</cfloop>
					</select>
				</td>
              </tr>
              
              <tr> 
                <td colspan="2">
				 <a href="javascript:void(0);" class="novisit "onClick="getDocs('higher_geography','island_group')">
				Island Group</a>
				</td>
                <td colspan="2"> <a href="javascript:void(0);" class="novisit "onClick="getDocs('higher_geography','island')">
				Island</a></td>
              </tr>
			  <tr>
			  	<td colspan="2">
					<select name="island_group" size="1">
                    <option value=""></option>
                    <cfloop query="ctIslandGroup">
                      <option 
					<cfif #geogdetails.island_group# is "#ctislandgroup.island_group#"> selected </cfif>value="#ctIslandGroup.island_group#">#ctIslandGroup.island_group#</option>
                    </cfloop>
                  </select>
				</td>
				<td colspan="2"><input type="text" name="island" value="#island#" size="50"></td>
			  </tr>
			 
              <tr> 
                <td colspan="2">Authority</td>
                <td>
					Valid?
				</td>
				<td>&nbsp;</td>
			</tr>
			<tr> 
                <td colspan="2"><select name="source_authority" size="1" class="reqdClr">
                    <option value=""></option>
                    <cfloop query="ctGeogSrcAuth">
                      <option <cfif #geogdetails.source_authority# is "#ctgeogsrcauth.source_authority#"> selected </cfif>value="#ctGeogSrcAuth.source_authority#">#ctGeogSrcAuth.source_authority#</option>
                    </cfloop>
                  </select></td>
                <td>
					<select name="valid_catalog_term_fg" class="reqdClr">
                    <option value=""></option>
                    <option <cfif #geogdetails.valid_catalog_term_fg# is "1"> selected </cfif>value="1">yes</option>
                    <option <cfif #geogdetails.valid_catalog_term_fg# is "0"> selected </cfif>value="0">no</option>
                  </select>
				</td>
				<td>&nbsp;</td>
			</tr>
			
              <tr> 
                <td colspan="4" nowrap align="center"> 
				<input type="submit" 
					value="Save Edits" 
					class="savBtn"
					onmouseover="this.className='savBtn btnhov'" 
					onmouseout="this.className='savBtn'">	
				<input type="button" 
					value="Delete"
					class="delBtn"
					onmouseover="this.className='delBtn btnhov'"
					onmouseout="this.className='delBtn'"
					onClick="document.location='Locality.cfm?Action=deleteGeog&geog_auth_rec_id=#geog_auth_rec_id#';">
				<input type="button" 
					value="See Localities" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onClick="document.location='Locality.cfm?Action=findLocality&geog_auth_rec_id=#geog_auth_rec_id#';">	
					      
                  </cfform>
                  <form name="newGeog" method="post" action="Locality.cfm">
                   
                      <input type="hidden" name="Action" value="newHG">
                      <input type="hidden" name="continent_ocean" value="#continent_ocean#">
                      <input type="hidden" name="country" value="#country#">
                      <input type="hidden" name="state_prov" value="#state_prov#">
                      <input type="hidden" name="county" value="#county#">
                      <input type="hidden" name="quad" value="#quad#">
                      <input type="hidden" name="feature" value="#feature#">
                      <input type="hidden" name="islandgroup" value="#island_group#">
					  <input type="hidden" name="island" value="#island#">
                      <input type="hidden" name="sea" value="#sea#">
                      <input type="submit" 
							value="Create Clone" 
							class="insBtn"
							onmouseover="this.className='insBtn btnhov'" 
							onmouseout="this.className='insBtn'">

                  </form></td>
              </tr>
            </table>
           
        
          
        </cfoutput> </cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "editCollEvnt">
<cfset title="Edit Collecting Event">
<cfoutput> 
      <cfquery name="locDet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
    select 
		higher_geog,
		spec_locality,
		collecting_event.collecting_event_id,
		locality.locality_id,
		verbatim_locality,
		BEGAN_DATE,
		ENDED_DATE,
		VERBATIM_DATE,
		COLL_EVENT_REMARKS,
		COLLECTING_SOURCE,
		COLLECTING_METHOD,
		HABITAT_DESC,
		CASE orig_lat_long_units
				WHEN 'decimal degrees' THEN dec_lat || 'd'
				WHEN 'deg. min. sec.' THEN lat_deg || 'd ' || lat_min || 'm ' || lat_sec || 's ' || lat_dir
				WHEN 'degrees dec. minutes' THEN lat_deg || 'd ' || dec_lat_min || 'm ' || lat_dir
			END as VerbatimLatitude,
			CASE orig_lat_long_units
				WHEN 'decimal degrees' THEN dec_long || 'd'
				WHEN'degrees dec. minutes' THEN long_deg || 'd ' || dec_long_min || 'm ' || long_dir
				WHEN 'deg. min. sec.' THEN long_deg || 'd ' || long_min || 'm ' || long_sec || 's ' || long_dir
			END as VerbatimLongitude,
		max_error_distance,
		max_error_units
	from 
		locality
		inner join geog_auth_rec on (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
		inner join collecting_event on ( locality.locality_id=collecting_event.locality_id )
		left outer join accepted_lat_long on (locality.locality_id=accepted_lat_long.locality_id)
		left outer join preferred_agent_name on (accepted_lat_long.determined_by_agent_id = preferred_agent_name.agent_id)
	where collecting_event.collecting_event_id=#collecting_event_id# 
    </cfquery>
 
  <cfquery name="whatSpecs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
  	SELECT count(cat_num) as numOfSpecs, collection_cde
	from cataloged_item WHERE
	collecting_event_id=#collecting_event_id# 
	GROUP BY collection_cde
  </cfquery>
  <table>
  <tr>
  	<td>
  <cfif #whatSpecs.recordcount# is 0>
  		<font color="##FF0000"><strong>This Collecting Event</strong></font>	
		<span style="font-size:small;">
		(#collecting_event_id#) 
		</span>
		<font color="##FF0000"><strong>
		<a href="javascript:void(0);" onClick="getDocs('collecting_event')"><img src="/images/info.gif" border="0"></a>
		contains no specimens. Please delete it if you don't have plans for it!</strong></font>	
  	<cfelseif #whatSpecs.recordcount# is 1>
		<font color="##FF0000"><strong>This Collecting Event </strong></font>	
		<span style="font-size:small;">
		(#collecting_event_id#) 
		</span>
		<font color="##FF0000"><strong>
		<a href="javascript:void(0);" onClick="getDocs('collecting_event')"><img src="/images/info.gif" border="0"></a>
		contains #whatSpecs.numOfSpecs# #whatSpecs.collection_cde#
		<a href="SpecimenResults.cfm?collecting_event_id=#collecting_event_id#">specimens</a>.</strong></font>	
	<cfelse>
		<font color="##FF0000"><strong>This Collecting Event 
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
  
</td>
  </tr>
  <cfif #cgi.SCRIPT_NAME# contains "SpecimenDetail.cfm">
  		<!--- provide a link to change coll event if we're in a specimen detail page ---->
		<form name="goChange" method="post" action="SpecimenDetail.cfm">
			<input type="hidden" name="content_url" value="changeCollEvent.cfm">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#">
			<tr>
				<td>
					<input type="submit" 
						value="Change Collecting Event for this Specimen" 
						class="lnkBtn"
						onmouseover="this.className='lnkBtn btnhov'" 
						onmouseout="this.className='lnkBtn'">
				</td>
			</tr>
			
			
		</form>
		<tr>
			<td colspan="2" nowrap valign="middle">
				<table width="100%" cellpadding="0" cellspacing="0">
					<tr>
						<td width="45%" align="left" valign="middle">
							<img src="/images/black.gif" width="100%" height="1">
						</td>
						<td align="center" valign="middle">
							<strong>OR</strong>
						</td>
						<td width="45%" align="right" valign="middle">
							<img src="/images/black.gif" width="100%" height="1">
						</td>
					</tr>
				</table>
			</td>
		</tr>
  </cfif>
</cfoutput>
 <cfoutput query="locDet"> 	
	 <form name="localitypick" action="Locality.cfm" method="post">
	 	<input type="hidden" name="Action" value="changeLocality">
      	<input type="hidden" name="locality_id">
	 	 <input type="hidden" name="collecting_event_id" value="#collecting_event_id#">
		 <cfif not isdefined("collection_object_id")>
		 	<cfset collection_object_id=-1>
		 </cfif>
		 <input type="hidden" name="collection_object_id" value="#collection_object_id#">
		<tr>
			<td>
					<input type="button" 
						value="Change Locality for this Collecting Event" 
						class="picBtn"
						onmouseover="this.className='picBtn btnhov'" 
						onmouseout="this.className='picBtn'"
						onclick="document.getElementById('locDesc').style.background='red';
							document.getElementById('hiddenButton').style.visibility='visible';
							LocalityPick('locality_id','spec_locality','localitypick'); return false;" >
				</td>
		</tr>
		<tr>
			<td>
				<table width="100%">
					<tr>
						<td width="20%" align="right" valign="top">
							Currently: 
						</td>
						<td>
							<div id="locDesc">
							#higher_geog#
							<cfif len(#VerbatimLatitude#) gt 0>
								<br>
								#VerbatimLatitude# #VerbatimLongitude#
								<cfif #max_error_distance# gt 0>
									&##177; #max_error_distance# #max_error_units#
								</cfif>
							</cfif>
							<br><em>#spec_locality#</em>
							<br>
							</div>
							
							<div id="hiddenButton" style="visibility:hidden ">
							Picked:
							<input type="text" name="spec_locality" size="50">
							<input type="submit" 
								value="Save Change" 
								class="savBtn"
								onmouseover="this.className='savBtn btnhov'" 
								onmouseout="this.className='savBtn'">
							</div>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2" nowrap valign="middle">
				<table width="100%" cellpadding="0" cellspacing="0">
					<tr>
						<td width="45%" align="left" valign="middle">
							<img src="/images/black.gif" width="100%" height="1">
						</td>
						<td align="center" valign="middle">
							<strong>OR</strong>
						</td>
						<td width="45%" align="right" valign="middle">
							<img src="/images/black.gif" width="100%" height="1">
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<input type="button" 
					value="Edit the current Locality" 
					class="lnkBtn"
					onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onClick="document.location='editLocality.cfm?locality_id=#locality_id#'">	
			</td>
		</tr>
</form>
<tr>
			<td colspan="2" nowrap valign="middle">
				<table width="100%" cellpadding="0" cellspacing="0">
					<tr>
						<td width="45%" align="left" valign="middle">
							<img src="/images/black.gif" width="100%" height="1">
						</td>
						<td align="center" valign="middle">
							<strong>OR</strong>
						</td>
						<td width="45%" align="right" valign="middle">
							<img src="/images/black.gif" width="100%" height="1">
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<strong>Edit this Collecting Event:</strong>
			</td>
		</tr>
</table>
    <cfform name="locality" method="post" action="Locality.cfm">
      <input type="hidden" name="Action" value="saveCollEventEdit">
      <input type="hidden" name="collecting_event_id" value="#collecting_event_id#">
	  <input type="hidden" name="collection_object_id" value="#collection_object_id#">
	
      <table>
        <tr> 
          <td valign="top" nowrap><div align="right">
		  
		  <a href="javascript:void(0);" onClick="getDocs('collecting_event','verbatim_locality')">Verbatim Locality:</a>
		  
		 </div></td>
          <td><input type="text" name="verbatim_locality" value='#stripQuotes(verbatim_locality)#' size="50">
        </tr>
		<tr> 
          <td valign="top"><div align="right">
		  	<a href="javascript:void(0);" onClick="getDocs('locality','specific_locality')">Specific Locality:</a>
		  
		 </div></td>
		 <td>
		 	#spec_locality#
		 </td>
          
        </tr>
		 <tr> 
          <td><div align="right">
		   <a href="javascript:void(0);" onClick="getDocs('collecting_event','verbatim_date')"> Verbatim Date:</a>
		  </div></td>
          <td><input type="text" name="VERBATIM_DATE" value="#VERBATIM_DATE#" class="reqdClr"></td>
        </tr>
        <tr> 
         	<td><div align="right"> <a href="javascript:void(0);" onClick="getDocs('collecting_event','began_date')">Date:</a>
			</div></td>
			<td>
				<table cellpadding="0" cellspacing="0">
					<tr>
						<td><div align="right">Began:&nbsp;</div></td>
						<td><input type="text" name="BEGAN_DATE" value="#dateformat(BEGAN_DATE,'dd mmm yyyy')#" size="10"></td>
						  <td><div align="right">Ended:&nbsp;</div></td>
						   <td><input type="text" name="ENDED_DATE" value="#dateformat(ENDED_DATE,'dd mmm yyyy')#" size="10"></td>
					</tr>
				</table>
			</td>
		 
          
        </tr>       
        <tr> 
          <td><div align="right">Remarks:</div></td>
          <td><input type="text" name="COLL_EVENT_REMARKS" value="#COLL_EVENT_REMARKS#" size="50"></td>
        </tr>
        <tr> 
          <td colspan="2">
		  <table cellpadding="0" cellspacing="0">
		  	<tr>
				<td nowrap><div align="right">
		 			 <a href="javascript:void(0);" onClick="getDocs('collecting_event','collecting_source')"> Collecting Source:</a>
					 &nbsp;</div>
				</td>
				<td>
					<select name="COLLECTING_SOURCE" size="1">
						<cfloop query="ctCollecting_Source">
							<option 
								<cfif #ctCollecting_Source.Collecting_Source# is #locDet.collecting_source#> selected </cfif>
								value="#ctCollecting_Source.Collecting_Source#">#ctCollecting_Source.Collecting_Source#</option>
						</cfloop>
					</select>
				</td>
				
			</tr>
		  </table>
		  
		  	
		 </td>
        </tr>
		 <tr> 
          <td><div align="right">
		  <a href="javascript:void(0);" onClick="getDocs('collecting_event','collecting_method')">Collecting Method:</a>
		  </div></td>
          <td><input type="text" name="COLLECTING_METHOD" value="#COLLECTING_METHOD#"></td>
        </tr>
        <tr> 
          <td><div align="right">
		  <a href="javascript:void(0);" onClick="getDocs('collecting_event','habitat')">Habitat:</a>
		  </div></td>
          <td><input type="text" name="HABITAT_DESC" value="#HABITAT_DESC#"></td>
        </tr>
        <tr> 
          <td colspan="2"><div align="center"> 
		  	<input type="submit" 
				value="Save" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'" 
				onmouseout="this.className='savBtn'">	
			<input type="button"
				value="Quit"
				class="qutBtn"
				onmouseover="this.className='qutBtn btnhov'"
				onmouseout="this.className='qutBtn'"
				onClick="document.location='Locality.cfm';">
		<input type="button" 
			value="Delete"
			class="delBtn"
			onmouseover="this.className='delBtn btnhov'"
			onmouseout="this.className='delBtn'"
			onClick="document.location='Locality.cfm?Action=deleteCollEvent&collecting_event_id=#collecting_event_id#';">
	        </div></td>
        </tr>
        <tr> 
         
			<td colspan="2">
			<div align="center">
			 </cfform>
				<form name="newCollEvnt" method="post" action="Locality.cfm">
					<input type="hidden" name="Action" value="newCollEvent">
					<input type="hidden" name="locality_id" value="#locality_id#">
					<input type="hidden" name="verbatim_locality" value="#verbatim_locality#">
					<input type="hidden" name="BEGAN_DATE" value="#dateformat(BEGAN_DATE,'dd-mmm-yyyy')#">
					<input type="hidden" name="ENDED_DATE" value="#dateformat(ENDED_DATE,'dd-mmm-yyyy')#">
					<input type="hidden" name="VERBATIM_DATE" value="#VERBATIM_DATE#">
					<input type="hidden" name="COLL_EVENT_REMARKS" value="#COLL_EVENT_REMARKS#">
					<input type="hidden" name="COLLECTING_SOURCE" value="#COLLECTING_SOURCE#">
					<input type="hidden" name="COLLECTING_METHOD" value="#COLLECTING_METHOD#">
					<input type="hidden" name="HABITAT_DESC" value="#HABITAT_DESC#">
					<input type="submit" 
						value="Create Clone" 
						class="insBtn"
						onmouseover="this.className='insBtn btnhov'" 
						onmouseout="this.className='insBtn'">
					
				</form>
				</div>
			</td>
        </tr>
      </table>
      
   
  </cfoutput> 
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "newCollEvent">
<cfset title="Create Collecting Event">
  <cfoutput> 
  <!--- see if we're creating clone --->
  
 
  	<cfquery name="getLoc"	 datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select  spec_locality, geog_auth_rec_id from locality 
		where locality_id=#locality_id#
	</cfquery>
	<cfquery name="getGeo" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select higher_geog from geog_auth_rec where
		geog_auth_rec_id=#getLoc.geog_auth_rec_id#
	</cfquery>

<b> Create Collecting Event:</b>
   <br>Higher Geography:  #getGeo.higher_geog#
    <br>Spec Locality: #getLoc.spec_locality#
    <form name="newCollEvnt" action="Locality.cfm" method="post">
      <input type="hidden" name="Action" value="newColl">
     	<input type="hidden" name="locality_id" value="#locality_id#">
     
      <table>
        <tr> 
          <td><div align="right">Verbatim Locality:</div></td>
          <td><input type="text" name="verbatim_locality" 
		  	<cfif isdefined("verbatim_locality")>
				value="#stripQuotes(verbatim_locality)#"
			<cfelseif isdefined("getLoc.spec_locality")>
				value="#stripQuotes(getLoc.spec_locality)#"
			</cfif> size="60"></td>
        </tr>
		<tr> 
          <td><div align="right">Verbatim Date:</div></td>
          <td><input type="text" name="VERBATIM_DATE" class="reqdClr"
		  		<cfif isdefined("VERBATIM_DATE")>
				value="#VERBATIM_DATE#"
			</cfif>
			 >
			<input type="button" 
				value="Copy" 
				class="insBtn"
				onmouseover="this.className='insBtn btnhov'" 
				onmouseout="this.className='insBtn'"
				onClick="newCollEvnt.BEGAN_DATE.value=newCollEvnt.VERBATIM_DATE.value;
				newCollEvnt.ENDED_DATE.value=newCollEvnt.VERBATIM_DATE.value;">
				</td>
        </tr>
        <tr> 
          <td><div align="right">Began Date:</div></td>
          <td><input type="text" name="BEGAN_DATE" 
		  		<cfif isdefined("BEGAN_DATE")>
				value="#BEGAN_DATE#"
			</cfif>
			></td>
        </tr>
        <tr> 
          <td><div align="right">Ended Date:</div></td>
          <td><input type="text" name="ENDED_DATE" 
		  		<cfif isdefined("ENDED_DATE")>
				value="#ENDED_DATE#"
			</cfif>
			></td>
        </tr>
        <tr> 
          <td><div align="right">Remarks:</div></td>
          <td><input type="text" name="COLL_EVENT_REMARKS" 
		  		<cfif isdefined("COLL_EVENT_REMARKS")>
				value="#COLL_EVENT_REMARKS#"
			</cfif>
			 size="50"></td>
        </tr>
       
        <tr> 
          <td><div align="right">Collecting Source:</div></td>
          <td>
		  	<cfif isdefined("COLLECTING_SOURCE")>
				<cfset collsrc = "#COLLECTING_SOURCE#">
			<cfelse>
				<cfset collsrc = "">
			</cfif>
		  	<select name="COLLECTING_SOURCE" size="1" class="reqdClr">
				<cfloop query="ctCollecting_Source">
					<option 
						<cfif #ctCollecting_Source.Collecting_Source# is #collsrc#> selected </cfif>
						value="#ctCollecting_Source.Collecting_Source#">#ctCollecting_Source.Collecting_Source#</option>
				</cfloop>
			</select>
		 </td>
        </tr>
        <tr> 
          <td><div align="right">Collecting Method:</div></td>
          <td><input type="text" name="COLLECTING_METHOD" 
		  		<cfif isdefined("COLLECTING_METHOD")>
				value="#COLLECTING_METHOD#"
			</cfif>
			></td>
        </tr>
        <tr> 
          <td><div align="right">Habitat:</div></td>
          <td><input type="text" name="HABITAT_DESC" 
		  	
				<cfif isdefined("HABITAT_DESC")>
				value="#HABITAT_DESC#"
			</cfif>
			></td>
        </tr>
        <tr> 
          <td colspan="2"><div align="center"> 
             <input type="submit" 
				value="Save" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'" 
				onmouseout="this.className='savBtn'">
			<input type="button"
				value="Quit"
				class="qutBtn"
				onmouseover="this.className='qutBtn btnhov'"
				onmouseout="this.className='qutBtn'"
				onClick="document.location='Locality.cfm';">

           
            </div></td>
        </tr>
        <tr> 
          
			
        </tr>
      </table>
      
    </form>
  </cfoutput> 
</cfif>
<!---------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "newLocalityWithLL">
	newLocalityWithLL
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "newLocality">
<!--- see if this is a copy --->
<cfif isdefined('geog_auth_rec_id')>
	<cfquery name="getHG" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select higher_geog from geog_auth_rec where geog_auth_rec_id=#geog_auth_rec_id#
	</cfquery>
</cfif>
        <cfoutput> 
        
          <b>Create locality</b>
		  <br><b>Higher Geography: </b>
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
   onmouseover="this.className='picBtn btnhov'" onmouseout="this.className='picBtn'"
  onclick="GeogPick('geog_auth_rec_id','higher_geog','geog'); return false;">	
   
   
            <cfif isdefined("geog_auth_rec_id")>
			  <input type="button" value="Details" class="lnkBtn"
   onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
  onclick="document.location='Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#'">	
  
         	</cfif>
           
            <table border="1">
              <tr> 
                <td><div align="right">Specific Locality:</div></td>
                <td><input type="text" name="spec_locality" 
						<cfif isdefined("spec_locality")>
							value = "#spec_locality#"
						</cfif>
					>
				</td>
              </tr>
              <tr> 
                <td><div align="right">Minimum Elevation:</div></td>
                <td><input type="text" name="MINIMUM_ELEVATION" 
						<cfif isdefined("MINIMUM_ELEVATION")>
							value = "#MINIMUM_ELEVATION#"
						</cfif>
				></td>
              </tr>
              <tr> 
                <td><div align="right">Max Elevation:</div></td>
                <td><input type="text" name="MAXIMUM_ELEVATION" 
						<cfif isdefined("MAXIMUM_ELEVATION")>
							value = "#MAXIMUM_ELEVATION#"
						</cfif>
					></td>
              </tr>
              <tr> 
                <td><div align="right">Elevation Units:</div></td>
                <td><select name="orig_elev_units" size="1">
					<option value=""></option>
                    <cfloop query="ctElevUnit">
                      <option <cfif isdefined("origelevunits") AND #ctelevunit.orig_elev_units# is "#origelevunits#"> selected </cfif>value="#ctElevUnit.orig_elev_units#">#ctElevUnit.orig_elev_units#</option>
                    </cfloop>
                  </select></td>
              </tr>
              <tr> 
                <td><div align="right">Locality Remarks:</div></td>
                <td><input type="text" name="LOCALITY_REMARKS"></td>
              </tr>
			   <cfif isdefined("locality_id") and len(#locality_id#) gt 0>
			   <input type="hidden" name="locality_id" value="#locality_id#" />
			    <tr> 
                <td><div align="right">Include coordinates from <a href="/editLocality.cfm?locality_id=#locality_id#">#locality_id#</a>:</div></td>
                <td>
					Yes <input type="radio" name="cloneCoords" value="yes" />
					<br />No <input type="radio" name="cloneCoords" value="no" checked="checked" />
				
				</td>
              </tr>
		 </cfif>
              <tr> 
                <td colspan="2"><div align="center"> 
                     <input type="submit" value="Save" class="savBtn"
   onmouseover="this.className='savBtn btnhov'" onmouseout="this.className='savBtn'">	
  					 <input type="button" value="Quit" class="qutBtn"
   onmouseover="this.className='qutBtn btnhov'" onmouseout="this.className='qutBtn'"
    onClick="document.location='Locality.cfm';">	
  
  
                    
                  </div></td>
              </tr>
              <tr> 
                <td colspan="2"></td>
              </tr>
              
            </table>
          
          </form>
       
        </cfoutput> 
		</cfif> 
      <!---------------------------------------------------------------------------------------------------->
	 
<!--------------------------- End Forms -------------------------------------------------->



<!--------------------------- Queries -------------------------------------------------->


<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "deleteGeog">
<cfoutput>
	<cfquery name="isLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select geog_auth_rec_id from locality where geog_auth_rec_id=#geog_auth_rec_id#
	</cfquery>
<cfif len(#isLocality.geog_auth_rec_id#) gt 0>
	There are active localities for this Geog. It cannot be deleted.
	<br><a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">Return</a> to editing.
	<cfabort>
<cfelseif len(#isLocality.geog_auth_rec_id#) is 0>
	<cfquery name="deleGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	delete from geog_auth_rec where geog_auth_rec_id=#geog_auth_rec_id#
	</cfquery>
	<cf_ActivityLog sql="delete from geog_auth_rec where geog_auth_rec_id=#geog_auth_rec_id#">
</cfif>	
<cflocation addtoken="no" url="#cgi.HTTP_REFERER#">	
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "deleteCollEvent">
<cfoutput>
	<cfquery name="isSpec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_object_id from cataloged_item where collecting_event_id=#collecting_event_id#
	</cfquery>
<cfif len(#isSpec.collection_object_id#) gt 0>
	There are specimens for this collecting event. It cannot be deleted. If you can't see them, perhaps they aren't in 
	the collection list you've set in your preferences.
	<br><a href="Locality.cfm?Action=editCollEvent&collecting_event_id=#collecting_event_id#">Return</a> to editing.
	<cfabort>
<cfelseif len(#isSpec.collection_object_id#) is 0>
	<cfquery name="deleCollEv" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	delete from collecting_event where collecting_event_id=#collecting_event_id#
	</cfquery>
	<cf_ActivityLog sql="delete from collecting_event where collecting_event_id=#collecting_event_id#">
</cfif>	
You deleted a collecting event.
<br>Go back to <a href="Locality.cfm">localities</a>.
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "changeLocality">
<cfoutput>
	<cfquery name="upColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		UPDATE collecting_event SET locality_id=#locality_id# where collecting_event_id=#collecting_event_id#
	</cfquery>
	<cf_ActivityLog sql="UPDATE collecting_event SET locality_id=#locality_id# where collecting_event_id=#collecting_event_id#">
		 <cfif not isdefined("collection_object_id")>
		 	<cfset collection_object_id=-1>
		 </cfif>
	<cflocation addtoken="no" url="Locality.cfm?collection_object_id=#collection_object_id#&action=editCollEvnt&collecting_event_id=#collecting_event_id#">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "saveCollEventEdit">
	<cfoutput>
	<cfset sql = "UPDATE collecting_event SET 
		BEGAN_DATE = '#BEGAN_DATE#'
		,ENDED_DATE = '#ENDED_DATE#'
		,VERBATIM_DATE = '#VERBATIM_DATE#'
		,COLLECTING_SOURCE = '#COLLECTING_SOURCE#'">
	<cfif len(#verbatim_locality#) gt 0>
		<cfset sql = "#sql#,verbatim_locality = '#escapeQuotes(verbatim_locality)#'">
	<cfelse>
		<cfset sql = "#sql#,verbatim_locality = null">
	</cfif>
	<cfif len(#COLL_EVENT_REMARKS#) gt 0>
		<cfset sql = "#sql#,COLL_EVENT_REMARKS = '#escapeQuotes(COLL_EVENT_REMARKS)#'">
	<cfelse>
		<cfset sql = "#sql#,COLL_EVENT_REMARKS = null">
	</cfif>
	<cfif len(#COLLECTING_METHOD#) gt 0>
		<cfset sql = "#sql#,COLLECTING_METHOD = '#COLLECTING_METHOD#'">
	<cfelse>
		<cfset sql = "#sql#,COLLECTING_METHOD = null">
	</cfif>
	<cfif len(#HABITAT_DESC#) gt 0>
		<cfset sql = "#sql#,HABITAT_DESC = '#escapeQuotes(HABITAT_DESC)#'">
	<cfelse>
		<cfset sql = "#sql#,HABITAT_DESC = null">
	</cfif>
	<cfset sql = "#sql# where collecting_event_id = #collecting_event_id#">
	<cfquery name="upColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#		
	</cfquery>
	<cf_ActivityLog sql="#sql#">
	
	<cfif #cgi.HTTP_REFERER# contains "editCollEvnt">
		<cfset refURL = "#cgi.HTTP_REFERER#">
	<cfelse>
		<cfset refURL = "#cgi.HTTP_REFERER#?content_url=Locality.cfm&collection_object_id=#collection_object_id#&action=editCollEvnt&collecting_event_id=#collecting_event_id#">
	</cfif>
	
	
	<cflocation addtoken="no" url="#refURL#">
	
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "saveGeogEdits">
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
	<cfquery name="edGe" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#		
	</cfquery>
	<cf_ActivityLog sql="#sql#">
	<cflocation addtoken="no" url="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "makeGeog">
<cfoutput>
<cfquery name="nextGEO" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select sq_geog_auth_rec_id.nextval nextid from dual
</cfquery>


<cfquery name="newGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
<cflocation addtoken="no" url="#cgi.HTTP_REFERER#?Action=editGeog&geog_auth_rec_id=#nextGEO.nextid#">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "newColl">
<cfoutput>
	<cfquery name="nextColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select sq_collecting_event_id.nextval nextColl from dual
	</cfquery>
	
	<cfquery name="newCollEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		INSERT INTO collecting_event (
		collecting_event_id,
		LOCALITY_ID
		,BEGAN_DATE
		,ENDED_DATE
		,VERBATIM_DATE
		,COLLECTING_SOURCE
		,VERBATIM_LOCALITY
		,COLL_EVENT_REMARKS
		,COLLECTING_METHOD
		,HABITAT_DESC
		)
	VALUES (
		#nextColl.nextColl#,
		#LOCALITY_ID#
		,'#BEGAN_DATE#'
		,'#ENDED_DATE#'
		,'#VERBATIM_DATE#'
		,'#COLLECTING_SOURCE#'
		<cfif len(#VERBATIM_LOCALITY#) gt 0>
			,'#VERBATIM_LOCALITY#'
		<cfelse>
			,NULL
		</cfif>
		<cfif len(#COLL_EVENT_REMARKS#) gt 0>
			,'#COLL_EVENT_REMARKS#'
		<cfelse>
			,NULL
		</cfif>
		<cfif len(#COLLECTING_METHOD#) gt 0>
			,'#COLLECTING_METHOD#'
		<cfelse>
			,NULL
		</cfif>
		<cfif len(#HABITAT_DESC#) gt 0>
			,'#HABITAT_DESC#'
		<cfelse>
			,NULL
		</cfif>
		)
		</cfquery>
		
<cflocation addtoken="no" url="#cgi.HTTP_REFERER#?Action=editCollEvnt&collecting_event_id=#nextColl.nextColl#">

</cfoutput>	
</cfif>
<!---------------------------------------------------------------------------------------------------->

<!----------------------------------------------------------------------------------------------------> 
<cfif #Action# is "makenewLocality">
	<cfoutput>
	<cftransaction>
	<cfif not isdefined("cloneCoords") or #cloneCoords# is not "yes">
		<cfset cloneCoords = "no">
	</cfif>
	<cfquery name="nextLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select sq_locality_id.nextval nextLoc from dual
	</cfquery>
	<cfquery name="newLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
			<cfquery name="cloneCoordinates" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from lat_long where locality_id = #locality_id#
			</cfquery>
			<cfloop query="cloneCoordinates">
				<cfset thisLatLongId = #llID.mLatLongId# + 1>
				<cfquery name="newLL" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
						,'#dateformat(DETERMINED_DATE,"dd-mmm-yyyy")#'
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

<!--------------------------- End Queries -------------------------------------------------->

<!--------------------------- Results -------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "findCollEvent">
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
					VerbatimLatitude,
					VerbatimLongitude,
					nogeorefbecause,
					locality_id,
					verbatim_locality,
					began_date,
					ended_date,
					verbatim_date,
					collecting_source,
					collecting_method
				from localityResults
				group by 
					collecting_event_id,
					higher_geog,
					geog_auth_rec_id,
					spec_locality,
					geolAtts,
					VerbatimLatitude,
					VerbatimLongitude,
					nogeorefbecause,
					locality_id,
					verbatim_locality,
					began_date,
					ended_date,
					verbatim_date,
					collecting_source,
					collecting_method
			</cfquery>
	
<table border>
	<tr>
		<td><b>Geog</b></td>
		<td><b>Locality</b></td>
		<td><b>Verbatim&nbsp;Locality</b></td>
		<td><b>Began&nbsp;Date</b></td>
		<td><b>End&nbsp;Date</b></td>
		<td><b>Verb.&nbsp;Date</b></td>
		<td><b>Source</b></td>
		<td><b>Method</b></td>
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
					<cfif len(#VerbatimLatitude#) gt 0>
						<br>#VerbatimLatitude#/#VerbatimLongitude#
					<cfelse>
						<br>#nogeorefbecause#
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
			<td>#dateformat(began_date,"dd mmm yyyy")#</td>
			<td>#dateformat(ended_date,"dd mmm yyyy")#</td>
			<td>#verbatim_date#</td>
			<td>#collecting_source#</td>
			<td>#collecting_method#</td>
		</tr>
	</cfloop>
</table>
			<input type="submit" 
				value="Move These Collecting Events to new Locality" 
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'" 
				onmouseout="this.className='savBtn'" />
		</form>
	</cfoutput>
	<!---
	<cfset sql = "select
					geog_auth_rec.geog_auth_rec_id,
					locality.locality_id,
					collecting_event.collecting_event_id,
					higher_geog,
					spec_locality,
					began_date,
					ended_date,
					verbatim_date,
					verbatim_locality,
					collecting_source,
					collecting_method,
					CASE orig_lat_long_units
				WHEN 'decimal degrees' THEN dec_lat || 'd'
				WHEN 'deg. min. sec.' THEN lat_deg || 'd ' || lat_min || 'm ' || lat_sec || 's ' || lat_dir
				WHEN 'degrees dec. minutes' THEN lat_deg || 'd ' || dec_lat_min || 'm ' || lat_dir
			END as VerbatimLatitude,
			CASE orig_lat_long_units
				WHEN 'decimal degrees' THEN dec_long || 'd'
				WHEN'degrees dec. minutes' THEN long_deg || 'd ' || dec_long_min || 'm ' || long_dir
				WHEN 'deg. min. sec.' THEN long_deg || 'd ' || long_min || 'm ' || long_sec || 's ' || long_dir
			END as VerbatimLongitude,
				nogeorefbecause
				 from locality
				 left outer join lat_long on (locality.locality_id = lat_long.locality_id)
				 inner join geog_auth_rec on (locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id)
				  inner join collecting_event on (locality.locality_id=collecting_event.locality_id)
		 where  locality.locality_id > -1 ">
	
		<cfif isdefined("locality_id") and len(#locality_id#) gt 0>
			<cfset sql = "#sql# AND collecting_event.locality_id = #locality_id#">
		<cfelse><!--- normal search --->
		
		
		<cfif len(#BEGAN_DATE#) gt 0>
			<cfset sql = "#sql# AND BEGAN_DATE #begDateOper# to_date('#BEGAN_DATE#')">
		</cfif>
		
		<cfif len(#ENDED_DATE#) gt 0>
			<cfset sql = "#sql# AND ENDED_DATE #endDateOper# to_date('#ENDED_DATE#')">
		</cfif>
		
		<cfif len(#VERBATIM_DATE#) gt 0>
			<cfset sql = "#sql# AND upper(VERBATIM_DATE) like '%#ucase(VERBATIM_DATE)#%'">
		</cfif>
		
		<cfif len(#VERBATIM_LOCALITY#) gt 0>
			<cfset sql = "#sql# AND upper(VERBATIM_LOCALITY) like '%#ucase(VERBATIM_LOCALITY)#%'">
		</cfif>
		<cfif len(#COLL_EVENT_REMARKS#) gt 0>
			<cfset sql = "#sql# AND upper(COLL_EVENT_REMARKS) like '%#ucase(COLL_EVENT_REMARKS)#%'">
		</cfif>
		
		<cfif len(#COLLECTING_SOURCE#) gt 0>
			<cfset sql = "#sql# AND upper(COLLECTING_SOURCE) like '%#ucase(COLLECTING_SOURCE)#%'">
		</cfif>
		
		<cfif len(#COLLECTING_METHOD#) gt 0>
			<cfset sql = "#sql# AND upper(COLLECTING_METHOD) like '%#ucase(COLLECTING_METHOD)#%'">
		</cfif>
		
		<cfif len(#HABITAT_DESC#) gt 0>
			<cfset sql = "#sql# AND upper(HABITAT_DESC) like '%#ucase(HABITAT_DESC)#%'">
		</cfif>
		
		
		
		
	<cfif len(#spec_locality#) gt 0>
		<cfset sloc = #ucase(replace(spec_locality,"'","''","all"))#>
		<cfset sql = "#sql# AND upper(spec_locality) like '%#sloc#%'">
	</cfif>
	<cfif len(#MAXIMUM_ELEVATION#) gt 0>
		<cfset sql = "#sql# AND MAXIMUM_ELEVATION maxElevOper #MAXIMUM_ELEVATION#">
	</cfif>
	<cfif len(#MINIMUM_ELEVATION#) gt 0>
		<cfset sql = "#sql# AND MINIMUM_ELEVATION minElevOper #MINIMUM_ELEVATION#">
	</cfif>
	<cfif len(#ORIG_ELEV_UNITS#) gt 0>
		<cfset sql = "#sql# AND ORIG_ELEV_UNITS = '#ORIG_ELEV_UNITS#'">
	</cfif>
	<cfif len(#LOCALITY_REMARKS#) gt 0>
		<cfset sql = "#sql# AND upper(LOCALITY_REMARKS) like '%#ucase(LOCALITY_REMARKS)#%'">
	</cfif>
	<cfif len(#continent_ocean#) gt 0>
		<cfset sql = "#sql# AND upper(continent_ocean) LIKE '%#ucase(continent_ocean)#%'">
	</cfif>
	<cfif len(#country#) gt 0>
		<cfset sql = "#sql# AND upper(country) LIKE '%#ucase(country)#%'">
	</cfif>
	<cfif len(#state_prov#) gt 0>
		<cfset sql = "#sql# AND upper(state_prov) LIKE '%#ucase(state_prov)#%'">
	</cfif>
	<cfif len(#county#) gt 0>
		<cfset sql = "#sql# AND upper(county) LIKE '%#ucase(county)#%'">
	</cfif>
	<cfif len(#quad#) gt 0>
		<cfset sql = "#sql# AND upper(quad) LIKE '%#ucase(quad)#%'">
	</cfif>
	<cfif len(#feature#) gt 0>
		<cfset sql = "#sql# AND feature = '#feature#'">
	</cfif>
	<cfif len(#island_group#) gt 0>
		<cfset sql = "#sql# AND island_group = '#island_group#'">
	</cfif>
	<cfif len(#island#) gt 0>
		<cfset sql = "#sql# AND upper(island) LIKE '%#ucase(island)#%'">
	</cfif>
	<cfif len(#sea#) gt 0>
		<cfset sql = "#sql# AND upper(sea) LIKE '%#ucase(sea)#%'">
	</cfif>
	<cfif len(#valid_catalog_term_fg#) gt 0>
		<cfset sql = "#sql# AND valid_catalog_term_fg = #valid_catalog_term_fg#">
	</cfif>
	<cfif len(#source_authority#) gt 0>
		<cfset srcAuth = #replace(source_authority,"'","''")#>
		<cfset sql = "#sql# AND source_authority = '#srcAuth#'">
	</cfif>
	</cfif><!--- end locality_id pass bypass --->
		<cfset sql = "#sql# ORDER BY
			higher_geog,
			spec_locality,
			verbatim_locality,
			verbatimLatitude">
			<Cfoutput>
				#preservesinglequotes(sql)#
			</Cfoutput>
	<cfquery name="getCollEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	
	<table border>
		<tr>
			<td><b>Geog</b></td>
			<td><b>Locality</b></td>
			<td><b>Coll Evnt Id</b></td>
			<td><b>Verb. Loc</b></td>
			<td><b>Beg. Date</b></td>
			<td><b>End Date</b></td>
			<td><b>Verb. Date</b></td>
			<td><b>Source</b></td>
			<td><b>Method</b></td>
		</tr>
		<cfoutput query="getCollEvent">
			<input type="hidden" name="collecting_event_id" value="#collecting_event_id#" />
		<tr>
			<td> <div class="smaller">#higher_geog#
				(<a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#" 
					target="#session.target#">#geog_auth_rec_id#</a>)
				</div>
			</td>
			<td>
				 <div class="smaller">
				 #spec_locality#
					<cfif len(#VerbatimLatitude#) gt 0>
						<br>#VerbatimLatitude#/#VerbatimLongitude#
					<cfelse>
						<br>#nogeorefbecause#
					</cfif> 
					(<a href="editLocality.cfm?locality_id=#locality_id#" 
						target="#session.target#">#locality_id#</a>)
				</div>
			<!---&nbsp;<a href="/fix/DupLocs.cfm?action=killDups&locid=#locality_id#" target="_blank"><font size="-2"><i>kill dups</i></font></a>---></td>
			<td><a href="Locality.cfm?Action=editCollEvnt&collecting_event_id=#collecting_event_id#">#collecting_event_id#</a></td>
			<td>#verbatim_locality#</td>
			<td>#dateformat(began_date,"dd mmm yyyy")#</td>
			<td>#dateformat(ended_date,"dd mmm yyyy")#</td>
			<td>#verbatim_date#</td>
			<td>#collecting_source#</td>
			<td>#collecting_method#</td>
		</tr>
	
	</cfoutput>
		
	</table>
	--->
</cfif>
<!---------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "massMoveCollEvent">
	<cfoutput>
		<cfset numCollEvents = listlen(collecting_event_id)>
		
		
		
  <cfquery name="whatSpecs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
  
  <cfquery name="cd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
<cfif #Action# is "mmCollEvnt2">
	<cfoutput>
		<cftransaction>
		<cfloop list="#collecting_event_id#" index="ceid">
			<cfquery name="upCollLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			update collecting_event set locality_id = #locality_id#
			where collecting_event_id = #ceid#
			</cfquery>
		</cfloop>
		</cftransaction>
		<cflocation url="Locality.cfm?Action=findCollEvent&locality_id=#locality_id#">
	</cfoutput>
</cfif>


<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "findLocality">
	<cfoutput>
	<cf_findLocality>
	<!--- need to filter out distinct --->
	<cfquery name="localityResults" dbtype="query">
		select 
			locality_id,
            geog_auth_rec_id,
            spec_locality,
            higher_geog,
            verbatimLatitude,
            verbatimLongitude,
            NoGeorefBecause,
            coordinateDeterminer,
            lat_long_ref_source,
            determined_date,
			geolAtts           
		from localityResults
		group by
            locality_id,
            geog_auth_rec_id,
            spec_locality,
            higher_geog,
            verbatimLatitude,
            verbatimLongitude,
            NoGeorefBecause,
            coordinateDeterminer,
            lat_long_ref_source,
            determined_date,
			geolAtts
	</cfquery>
<cfif #localityResults.recordcount# lt 1000>
	<cfset thisLocId="">
	<cfloop query="localityResults">
		<cfif len(#thisLocId#) is 0>
			<cfset thisLocId="#locality_id#">
		<cfelse>
			<cfset thisLocId="#thisLocId#,#locality_id#">
		</cfif>
	</cfloop>
	<a href="/bnhmMaps/bnhmPointMapper.cfm?locality_id=#thisLocId#" target="_blank">BerkeleyMapper</a>
<cfelse>
	1000 record limit on mapping, sorry...
</cfif>
<br /><strong>Your query found #localityResults.recordcount# localities.</strong>

	
  <table border>
    <tr> 
      <td><b>Geog ID</b></td>
      <td><b>Locality ID</b></td>
      <td><b>Spec Locality</b></td>
	   <td><b>Geog</b></td>
    </tr>
	<cfset i=1>
    <cfloop query="localityResults"> 
      <tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
        <td rowspan="2"> 
          <a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">#geog_auth_rec_id#</a> </td>
        <td rowspan="2"> 
          <a href="editLocality.cfm?locality_id=#locality_id#">#locality_id#</a> 
		  <!----&nbsp;<a href="/fix/DupLocs.cfm?action=killDups&locid=#locality_id#" target="_blank"><font size="-2"><i>kill dups</i></font>----></a>
		  </td>
        <td> 
          #spec_locality#
		<cfif len(geolAtts) gt 0>[#geolAtts#]</cfif>
		</td>
		  
		  <td rowspan="2">#higher_geog#</td>
      </tr>
      <tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
        <td> 
          <font size="-1"> 
		 &nbsp;
          <cfif len(verbatimLatitude) gt 0>
            #verbatimLatitude# / #verbatimLongitude#
            <cfelse>
            <b>NoGeorefBecause: #NoGeorefBecause#</b> 
          </cfif>
          Determined by #coordinateDeterminer# on #dateformat(determined_date,"dd mmm yyyy")# using #lat_long_ref_source#
          </font> </td>
      </tr>
	  <cfset i=#i#+1>
	  </cfloop>
    </cfoutput> 
  </table>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------------->
<cfif #Action# is "findGeog">
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

<!--------------------------- End Results -------------------------------------------------->
<div id="theFoot">
	<cfinclude template="includes/_footer.cfm">
</div>
<script>
	var thePar = parent.location.href;
	var isFrame = thePar.indexOf('Locality.cfm');
	if (isFrame == -1) {
		document.getElementById("theHead").style.display='none';
		document.getElementById("theFoot").style.display='none';
		parent.dyniframesize();
	}
</script>