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
			Continent/Ocean:
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
			Country:
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
			<a href="javascript:void(0);"
				onClick="getHelp('state_prov'); return false;"
				onMouseOver="self.status='Click for State/Province help.';return true;"
				onmouseout="self.status='';return true;">State/Province:
			</a>
		</td>
		<td class="srch">
			<input type="text" name="state_prov" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<a href="javascript:void(0);" 
				onClick="getHelp('quad'); return false;"
				onMouseOver="self.status='Click for Quad help.';return true;" 
				onmouseout="self.status='';return true;">Map Name:
			</a>
		</td>
		<td class="srch">
			<input type="text" name="Quad" size="50">
			<span class="infoLink" onclick="getQuadHelp();">Choose</span>
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<a href="javascript:void(0);" 
				onClick="getHelp('county'); return false;"
				onMouseOver="self.status='Click for County help.';return true;" 
				onmouseout="self.status='';return true;">County:
			</a>
		</td>
		<td class="srch">
			<input type="text" name="County" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Island Group:
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
			<a href="javascript:void(0);"
				onClick="getHelp('island'); return false;"
				onMouseOver="self.status='Click for Island help.';return true;"
				onmouseout="self.status='';return true;">Island:
			</a>
		</td>
		<td class="srch">
			<input type="text" name="Island" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			<a href="javascript:void(0);" 
				onClick="getHelp('feature'); return false;"
				onMouseOver="self.status='Click for Feature help.';return true;" 
				onmouseout="self.status='';return true;">Geographic Feature:
			</a>
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
			<a href="javascript:void(0);" 
				onClick="getHelp('spec_locality'); return false;"
				onMouseOver="self.status='Click for Specific Locality help.';return true;" 
				onmouseout="self.status='';return true;">Specific&nbsp;Locality:
			</a>
		</td>
		<td class="srch">
			<input type="text" name="spec_locality" size="50">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Elevation:
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
			<a href="javascript:void(0);" 
				onClick="getHelp('max_error_in_meters'); return false;"
				onMouseOver="self.status='Click for Coordinate Error help.';return true;" 
				onmouseout="self.status='';return true;">Coordinate Error (meters):
			</a>
		</td>
		<td class="srch">
			<input type="text" name="max_error_in_meters">
		</td>
	</tr>
	<tr>
		<td class="lbl">
			Bounding Box:
		</td>
		<td class="srch">
			<table cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td align="left" width="250" colspan="2">
						
					</td>
				</tr>
				<tr>
					<td align="right" width="250">
						Northwest Corner:&nbsp;
					</td>
					<td align="left" nowrap>
						<strong><em>Latitude:</em></strong> <input type="text" name="nwLat" size="8">
						<strong><em>Longitude:</em></strong> <input type="text" name="nwlong" size="8">
						
					</td>
				</tr>
				<tr>
					<td align="right" width="250">
						Southeast Corner:&nbsp;
					</td>
					<td align="left" nowrap>
						
						<strong><em>Latitude:</em></strong> <input type="text" name="selat" size="8">
						<strong><em>Longitude:</em></strong> <input type="text" name="selong" size="8">
					</td>
				</tr>
			</table>
		</td>
	</tr>	
</table>