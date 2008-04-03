<script type='text/javascript' src='/includes/SpecSearch/jqLoad.js'></script>	
<cfquery name="ctElevUnits" datasource="#Application.web_user#">
	select orig_elev_units from CTORIG_ELEV_UNITS
</cfquery>
<cfquery name="ContOcean" datasource="#Application.web_user#">
	select continent_ocean from ctContinent ORDER BY continent_ocean
</cfquery>
<cfquery name="Country" datasource="#Application.web_user#">
	select distinct(country) from geog_auth_rec order by country
</cfquery>
<cfquery name="IslGrp" datasource="#Application.web_user#">
	select island_group from ctIsland_Group order by Island_Group
</cfquery>
<cfquery name="Feature" datasource="#Application.web_user#">
	select distinct(Feature) from geog_auth_rec order by Feature
</cfquery>							
<table id="t_identifiers" class="ssrch">
	<tr>
		<td class="lbl">
			<span class="helpLink" id="continent_ocean">Continent/Ocean:</span>
		</td>
		<td class="srch">
			<select name="continent_ocean" size="1">
				<option value=""></option>
				<cfloop query="ContOcean"> 
					<option value="#ContOcean.continent_ocean#">#ContOcean.continent_ocean#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="country">Country:</span>
		</td>
		<td class="srch">
			<select name="Country" size="1">
				<option value=""></option>
				<cfloop query="Country">
					<option value="#Country.Country#">#Country.Country#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="state_prov">State/Province:</span>
		</td>
		<td class="srch">
			<input type="text" name="state_prov" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="quad">Map Name:</span>
		</td>
		<td class="srch">
			<input type="text" name="Quad" size="50">
			<span class="infoLink" onclick="getQuadHelp();">Choose</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="county">County:</span>
		</td>
		<td class="srch">
			<input type="text" name="County" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="island_group">Island Group:</span>
		</td>
		<td class="srch">
			<select name="island_group" size="1">
				  <option value=""></option>
				  <cfloop query="IslGrp"> 
					<option value="#IslGrp.Island_Group#">#IslGrp.Island_Group#</option>
				  </cfloop> 
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="island">Island:</span>
		</td>
		<td class="srch">
			<input type="text" name="Island" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="feature">Geographic Feature:</span>
		</td>
		<td class="srch">
			<select name="Feature" size="1">
				<option value=""></option>
				<cfloop query="Feature">
					<option value="#Feature.Feature#">#Feature.Feature#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="spec_locality">Specific&nbsp;Locality:</span>
		</td>
		<td class="srch">
			<input type="text" name="spec_locality" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="elevation">Elevation:</span>
		</td>
		<td class="srch">
			<input type="text" name="minimum_elevation" size="5"> - 
			<input type="text" name="maximum_elevation" size="5">
			<select name="orig_elev_units" size="1">
				<option value=""></option>
				<cfloop query="ctElevUnits">
					<option value="#ctElevUnits.orig_elev_units#">#ctElevUnits.orig_elev_units#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="max_error_in_meters">Coordinate Error (meters):</span>
		</td>
		<td class="srch">
			<input type="text" name="max_error_in_meters">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<span class="helpLink" id="bounding_box">Bounding Box:</span>
		</td>
		<td class="srch">
			<table cellpadding="0" cellspacing="0">
				<tr>
					<td align="left" width="250" colspan="2">
						
					</td>
				</tr>
				<tr>
					<td align="left" nowrap>
						<strong><em>NW Latitude:</em></strong> <input type="text" name="nwLat" size="8">
						<strong><em>NW Longitude:</em></strong> <input type="text" name="nwlong" size="8">
						
					</td>
				</tr>
				<tr>
					<td align="left" nowrap>
						<strong><em>SE Latitude:</em></strong> <input type="text" name="selat" size="8">
						<strong><em>SE Longitude:</em></strong> <input type="text" name="selong" size="8">
					</td>
				</tr>
			</table>
		</td>
	</tr>	
</table>