<cfinclude template="../includes/_pickHeader.cfm">
<script>
	function fireEvent (fEvent) {
		//alert('event thingy: ' + fEvent);
		if (fEvent.length > 0 && fEvent != 'undefined') {
			var fireThis = "opener." + fEvent + "()";
			eval(fireThis);
		}
		self.close();
	}
</script>
<cfset title = "Locality Pick Search">
<cfquery name="ctIslandGroup" datasource="#Application.web_user#">
	select island_group from ctisland_group order by island_group
</cfquery>
<cfquery name="ctGeogSrcAuth" datasource="#Application.web_user#">
	select source_authority from ctgeog_source_authority order by source_authority
</cfquery>

<cfquery name="ctElevUnit" datasource="#Application.web_user#">
	select orig_elev_units from ctorig_elev_units order by orig_elev_units
</cfquery>

<cfif #Action# is "nothing">
<cfoutput>
<table border="1">
<cfform name="getLoc" method="post" action="LocalityPick.cfm">
	<input type="hidden" name="Action" value="findLocality">
	<input type="hidden" name="localityIdFld" value="#localityIdFld#">
		<input type="hidden" name="speclocFld" value="#speclocFld#">
		<input type="hidden" name="formName" value="#formName#">
		<input type="hidden" name="fireEvent" value="#fireEvent#">
	<tr>
		<td align="right">Specific Locality:</td>
		<td><input type="text" name="spec_locality"></td>
	</tr>
	<tr>
		<td align="right">Min. Elevation:</td>
		<td><select name="minElevOper" size="1">
			<option value="=">is</option>
			<option value="<>">is not</option>
			<option value=">">more than</option>
			<option value="<">less than</option>
		</select>
	<input type="text" name="MINIMUM_ELEVATION"></td>
	</tr>
	<tr>
		<td align="right">Max. Elevation: </td>
		<td><select name="maxElevOper" size="1">
			<option value="=">is</option>
			<option value="<>">is not</option>
			<option value=">">more than</option>
			<option value="<">less than</option>
		</select>
	<input type="text" name="MAXIMUM_ELEVATION"></td>
	</tr>
	<tr>
		<td align="right">Elev. Units: </td>
		<td><select name="ORIG_ELEV_UNITS" size="1">
		<option value=""></option>
		<cfloop query="ctElevUnit">
			<option value="#ctElevUnit.orig_elev_units#">#ctElevUnit.orig_elev_units#</option>
		</cfloop>
	</select></td>
	</tr>
	<tr>
		<td align="right">Locality Remarks:</td>
		<td><input type="text" name="LOCALITY_REMARKS"></td>
	</tr>
	<tr>
		<td align="right">Continent or Ocean:</td>
		<td><input type="text" name="continent_ocean"></td>
	</tr>
	<tr>
		<td align="right">Country:</td>
		<td><input type="text" name="country"></td>
	</tr>
	<tr>
		<td align="right">State:</td>
		<td><input type="text" name="state_prov"></td>
	</tr>
	<tr>
		<td align="right">County:</td>
		<td><input type="text" name="county"></td>
	</tr>
	<tr>
		<td align="right">Quad:</td>
		<td><input type="text" name="quad"></td>
	</tr>
	<tr>
		<td align="right">Feature:</td>
		<td><input type=" text" name="feature"></td>
	</tr>
	<tr>
		<td align="right">Island Group:</td>
		<td><select name="island_group" size="1">
			<option value=""></option>
			<cfloop query="ctIslandGroup">
				<option value="#ctIslandGroup.island_group#">#ctIslandGroup.island_group#</option>
			</cfloop>
		</select></td>
	</tr>
	<tr>
		<td align="right">Island:</td>
		<td><input type="text" name="island"></td>
	</tr>
	<tr>
		<td align="right">Sea:</td>
		<td><input type="text" name="sea"></td>
	</tr>
	<tr>
		<td align="right">Valid?</td>
		<td><select name="valid_catalog_term_fg">
			<option value=""></option>
			<option value="1">yes</option>
			<option value="0">no</option>
		</select></td>
	</tr>
	<tr>
		<td align="right">Geog. Src. Auth.:</td>
		<td><select name="source_authority" size="1">
			<option value=""></option>
			<cfloop query="ctGeogSrcAuth">
				<option value="#ctGeogSrcAuth.source_authority#">#ctGeogSrcAuth.source_authority#</option>
			</cfloop>
		</select></td>
	</tr>
	<tr>
		<td align="right">Locality ID:</td>
		<td><input type="text" name="locality_id"></td>
	</tr>
	<tr>
		<td align="center" colspan="2">
		<cfoutput>
		<input type="submit" value="Search" class="schBtn"
   onmouseover="this.className='schBtn btnhov'" onmouseout="this.className='schBtn'">
			
		</cfoutput>
		</td>
		
	</tr>
	
	
	
		
</cfform>
</table>
</cfoutput>
</cfif>
<!-------------------------------------------------------------------->
<cfif #Action# is "findLocality">
<cfset title = "Select a Locality">
	<cfset sql = "
		select 
					geog_auth_rec.geog_auth_rec_id,
					locality.locality_id,
					higher_geog,
					spec_locality,
					lat_deg,
					dec_lat_min,
					lat_min,
					lat_sec,
					lat_dir,
					long_deg,
					dec_long_min,
					long_min,
					long_sec,
					long_dir,
					dec_lat,
					dec_long,
					datum,
					minimum_elevation,
					minimum_elevation,
					orig_elev_units,
					decode(orig_lat_long_units,
							'decimal degrees',to_char(dec_lat) || '&deg; ',
							'deg. min. sec.', to_char(lat_deg) || '&deg; ' || to_char(lat_min) || '&acute; ' || to_char(lat_sec) || '&acute;&acute; ' || lat_dir,
							'degrees dec. minutes', to_char(lat_deg) || '&deg; ' || to_char(dec_lat_min) || '&acute; ' || lat_dir
						)  VerbatimLatitude,
						decode(orig_lat_long_units,
							'decimal degrees',to_char(dec_long) || '&deg;',
							'deg. min. sec.', to_char(long_deg) || '&deg; ' || to_char(long_min) || '&acute; ' || to_char(long_sec) || '&acute;&acute; ' || long_dir,
							'degrees dec. minutes', to_char(long_deg) || '&deg; ' || to_char(dec_long_min) || '&acute; ' || long_dir
						)  VerbatimLongitude,
					orig_lat_long_units,
					lat_long_ref_source,
					max_error_distance,
					max_error_units,
					accepted_lat_long_fg
				 FROM 
					locality, 
					geog_auth_rec, 
					accepted_lat_long 
				where 
					locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id
					AND locality.locality_id = accepted_lat_long.locality_id (+)">
						
	<cfif len(#spec_locality#) gt 0>
		<cfset spec_locality = #replace(spec_locality,"'","''")#>
		<cfset sql = "#sql# AND upper(spec_locality) like '%#ucase(spec_locality)#%'">
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
		<cfset sql = "#sql# AND upper(feature) LIKE '%#cuase(feature)#%'">
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
	<cfif len(#locality_id#) gt 0>
		<cfset sql = "#sql# AND locality.locality_id = #locality_id#">
	</cfif>

	
	<cfquery name="getLoc" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>
	<table border>
    	<tr> 
      		<td><b>&nbsp;</b></td>
	   		<td><b>Spec Locality</b></td>
    	</tr>
    	<cfoutput query="getLoc" group="locality_id"> 
      		<tr #iif(currentrow MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
       			<td>
		  			<cfset thisValue=#replace(spec_locality,"'","`","all")#>
		  			<cfset thisValue=#replace(thisValue,'"','``',"all")#>
		  			<input type="button" value="Accept" class="lnkBtn"
   						onmouseover="this.className='lnkBtn btnhov'" onmouseout="this.className='lnkBtn'"
  						onClick="javascript: opener.document.#formName#.#localityIdFld#.value='#locality_id#';
						opener.document.#formName#.#speclocFld#.value='#thisValue#';
						self.close();">
				</td>
				<td> 
          			#getLoc.spec_locality#
		  			<br>
		  			<font size="-2">#higher_geog#
						<cfif len(#orig_elev_units#) gt 0>
							&nbsp;&nbsp;&nbsp;Elevation: #minimum_elevation#-#minimum_elevation# #orig_elev_units#
						</cfif>
					</font>
					<br><font size="-2">#verbatimLatitude# #verbatimLongitude#</font>
				</td>
				
</tr>   

    </cfoutput> 
                          </table>
  
  
		
		
		<!---
		<br><a href="javascript: opener.document.#formName#.#localityIdFld#.value='#locality_id#';opener.document.#formName#.#speclocFld#.value='#spec_locality#';self.close();" onClick="">#spec_locality#</a>
--->
	
</cfif>
<cfinclude template="../includes/_pickFooter.cfm">
