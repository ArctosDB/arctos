<script type="text/javascript" language="javascript">
	jQuery(document).ready(function() {
		jQuery("#geology_attribute_value").autocomplete("/ajax/tData.cfm?action=suggestGeologyAttVal", {
			width: 320,
			max: 20,
			autofill: true,
			highlight: false,
			multiple: false,
			scroll: true,
			scrollHeight: 300
		});	
	});
</script>
<cfquery name="ctElevUnits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select orig_elev_units from CTORIG_ELEV_UNITS
</cfquery>
<cfquery name="ContOcean" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select continent_ocean from geog_auth_rec group by continent_ocean ORDER BY continent_ocean
</cfquery>
<cfquery name="ctsea" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select sea from geog_auth_rec where sea is not null group by sea ORDER BY sea
</cfquery>
<cfquery name="Country" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select distinct(country) from geog_auth_rec order by country
</cfquery>
<cfquery name="IslGrp" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select island_group from ctIsland_Group order by Island_Group
</cfquery>
<cfquery name="Feature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select distinct(Feature) from geog_auth_rec order by Feature
</cfquery>
<cfquery name="ctgeology_attribute"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select attribute from geology_attribute_hierarchy group by attribute order by attribute 
</cfquery>
<cfquery name="ctgeology_attribute_val"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select attribute_value from geology_attribute_hierarchy group by attribute_value order by attribute_value 
</cfquery>
<cfquery name="ctlat_long_error_units"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select lat_long_error_units from ctlat_long_error_units group by lat_long_error_units order by lat_long_error_units 
</cfquery>
<cfoutput>
<table id="t_identifiers" class="ssrch">
	
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_geology_attribute">Geology Attribute:</span>
		</td>
		<td class="srch">
			<select name="geology_attribute" id="geology_attribute" size="1">
				<option value=""></option>
				<cfloop query="ctgeology_attribute">
					<option value="#attribute#">#attribute#</option>
				</cfloop>
			</select>		
		</td>
	</tr>			
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_geology_attribute_value">Geology Attribute Value:</span>
		</td>
		<td class="srch">
			<input type="text" name="geology_attribute_value" id="geology_attribute_value" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_geology_hierarchies">Traverse Geology Hierarchies:</span>
		</td>
		<td class="srch">
			<select name="geology_hierarchies" id="geology_hierarchies" size="1">
				<option value="1">yes</option>
				<option value="0">no</option>
			</select>	
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_continent_ocean">Continent/Ocean:</span>
		</td>
		<td class="srch">
			<select name="continent_ocean" id="continent_ocean" size="1">
				<option value=""></option>
				<option value="NULL">NULL</option>
				<cfloop query="ContOcean"> 
					<option value="#ContOcean.continent_ocean#">#ContOcean.continent_ocean#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_sea">Sea:</span>
		</td>
		<td class="srch">
			<select name="sea" id="sea" size="1">
				<option value=""></option>
				<option value="NULL">NULL</option>
				<cfloop query="ctsea"> 
					<option value="#ctsea.sea#">#ctsea.sea#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_country">Country:</span>
		</td>
		<td class="srch">
			<select name="country" id="country" size="1">
				<option value=""></option>
				<option value="NULL">NULL</option>
				<cfloop query="Country">
					<option value="#Country.Country#">#Country.Country#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_state_prov">State/Province:</span>
		</td>
		<td class="srch">
			<input type="text" name="state_prov" id="state_prov" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_quad">USGS Quad Map:</span>
		</td>
		<td class="srch">
			<input type="text" name="quad" id="quad" size="50">
			<span class="infoLink" onclick="getQuadHelp();">[ Pick AK Quad ]</span>
			<span class="infoLink" onclick="document.getElementById('quad').value='NULL';">[ NULL ]</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_county">County:</span>
		</td>
		<td class="srch">
			<input type="text" name="county" id="county" size="50">
			<span class="infoLink" onclick="document.getElementById('county').value='NULL';">[ NULL ]</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_island_group">Island Group:</span>
		</td>
		<td class="srch">
			<select name="island_group" id="island_group" size="1">
				  <option value=""></option>
				  <option value="NULL">NULL</option>
				  <cfloop query="IslGrp"> 
					<option value="#IslGrp.Island_Group#">#IslGrp.Island_Group#</option>
				  </cfloop> 
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_island">Island:</span>
		</td>
		<td class="srch">
			<input type="text" name="island" id="island" size="50">
			<span class="infoLink" onclick="document.getElementById('island').value='NULL';">[ NULL ]</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_feature">Geographic Feature:</span>
		</td>
		<td class="srch">
			<select name="feature" id="feature" size="1">
				<option value=""></option>
				<option value="NULL">NULL</option>
				<cfloop query="Feature">
					<option value="#Feature.Feature#">#Feature.Feature#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_spec_locality">Specific&nbsp;Locality:</span>
		</td>
		<td class="srch">
			<input type="text" name="spec_locality" id="spec_locality" size="50">
			<span class="infoLink" onclick="var e=document.getElementById('spec_locality');e.value='='+e.value;">Add = for exact match</span>
			<span class="infoLink" onclick="document.getElementById('spec_locality').value='NULL';">[ NULL ]</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="elevation">Elevation:</span>
		</td>
		<td class="srch">
			<input type="text" name="minimum_elevation" id="minimum_elevation" size="5"> - 
			<input type="text" name="maximum_elevation" id="maximum_elevation" size="5">
			<select name="orig_elev_units" id="orig_elev_units" size="1">
				<option value=""></option>
				<cfloop query="ctElevUnits">
					<option value="#ctElevUnits.orig_elev_units#">#ctElevUnits.orig_elev_units#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_habitat">Habitat:</span>
		</td>
		<td class="srch">
			<input type="text" name="habitat" id="habitat" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_isgeoreferenced">Georeferenced?</span>
		</td>
		<td class="srch">
			<select name="isgeoreferenced" id="isgeoreferenced" size="1">
				<option value=""></option>
				<option value="true">Is Georeferenced</option>
				<option value="false">Not Georeferenced</option>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="max_error_distance">Coordinate Precision:</span>
		</td>
		<td class="srch">
			(less than) <input type="text" name="min_max_error" id="min_max_error" size="5"> (and/or more than)
			<input type="text" name="max_max_error" id="max_max_error" size="5">
			<select name="max_error_units" id="max_error_units" size="1">
				<option value=""></option>
				<cfloop query="ctlat_long_error_units">
					<option value="#ctlat_long_error_units.lat_long_error_units#">#ctlat_long_error_units.lat_long_error_units#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="_locality_remarks">Locality Remarks:</span>
		</td>
		<td class="srch">
			<input type="text" name="locality_remarks" id="locality_remarks" size="50">
		</td>
	</tr>
</table>
</cfoutput>