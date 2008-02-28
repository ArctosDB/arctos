<table>
	<tr>
		<td colspan="2">
			<label for="spec_locality">Specific Locality</label>
			<input type="text" name="spec_locality" id="spec_locality" size="50">
		</td>
	</tr>
	<tr>
		<td>
			<label for="MinElevOper">Minimum Elevation</label>
			<select name="MinElevOper" id="MinElevOper" size="1">
            	<option value="=">is</option>
                <option value="<>">is not</option>
                <option value=">">more than</option>
                <option value="<">less than</option>
             </select> 
			<input type="text" name="minimum_elevation" id="minimum_elevation">
		</td>
	</tr>
</table>

<hr>

 </td>
            </tr>
            <tr> 
              <td><div align="right">:</div></td>
              <td>< </td>
            </tr>
            <tr> 
              <td><div align="right">Maximum Elevation:</div></td>
              <td> <select name="MaxElevOper" size="1">
                  <option value="=">is</option>
                  <option value="<>">is not</option>
                  <option value=">">more than</option>
                  <option value="<">less than</option>
                </select> <input type="text" name="MAXIMUM_ELEVATION"> </td>
            </tr>
            <tr> 
              <td><div align="right">Elevation Units: </div></td>
              <td><select name="orig_elev_units" size="1">
                  <option value=""></option>
                  <cfloop query="ctElevUnit">
                    <option value="#ctElevUnit.orig_elev_units#">#ctElevUnit.orig_elev_units#</option>
                  </cfloop>
                </select></td>
            </tr>
            <tr> 
              <td height="24"> <div align="right">Locality Remarks: </div></td>
              <td><input type="text" name="LOCALITY_REMARKS" size="50"> </td>
            </tr>
            <tr> 
              <td><div align="right">Continent or Ocean:</div></td>
              <td><input type="text" name="continent_ocean"></td>
            </tr>
            <tr> 
              <td><div align="right">Country:</div></td>
              <td><input type="text" name="country"></td>
            </tr>
            <tr> 
              <td><div align="right">State: </div></td>
              <td><input type="text" name="state_prov"></td>
            </tr>
            <tr> 
              <td><div align="right">County:</div></td>
              <td><input type="text" name="county"></td>
            </tr>
            <tr> 
              <td><div align="right">Quad:</div></td>
              <td><input type="text" name="quad"></td>
            </tr>
            <tr> 
              <td><div align="right">Feature:</div></td>
              <td><select name="feature">
				<option value=""></option>
					<cfloop query="ctFeature">
						<option value = "#ctFeature.feature#">#ctFeature.feature#</option>
					</cfloop>
			</select></td>
            </tr>
            <tr> 
              <td><div align="right">Island Group</div></td>
              <td><select name="island_group" size="1">
                  <option value=""></option>
                  <cfloop query="ctIslandGroup">
                    <option value="#ctIslandGroup.island_group#">#ctIslandGroup.island_group#</option>
                  </cfloop>
                </select></td>
            </tr>
            <tr> 
              <td><div align="right">Island</div></td>
              <td><input type="text" name="island" size="50"></td>
            </tr>
            <tr> 
              <td><div align="right">Sea:</div></td>
              <td><input type="text" name="sea"></td>
            </tr>
            <tr> 
              <td><div align="right">Valid Term?</div></td>
              <td><select name="valid_catalog_term_fg">
                  <option value=""></option>
                  <option value="1">yes</option>
                  <option value="0">no</option>
                </select></td>
            </tr>
            <tr> 
              <td><div align="right">Source Authority:</div></td>
              <td><select name="source_authority" size="1">
                  <option value=""></option>
                  <cfloop query="ctGeogSrcAuth">
                    <option value="#ctGeogSrcAuth.source_authority#">#ctGeogSrcAuth.source_authority#</option>
                  </cfloop>
                </select></td>
            </tr>
            <tr> 
              <td><div align="right">Verbatim Locality:</div></td>
              <td><input type="text" name="verbatim_locality" size="50"></td>
            </tr>
            <tr> 
              <td><div align="right">Began Date:</div></td>
              <td><select name="begDateOper" size="1">
                  <option value="=">is</option>
                  <option value="<">before</option>
                  <option value=">">after</option>
                </select> <input type="text" name="BEGAN_DATE"> </td>
            </tr>
            <tr> 
              <td><div align="right">Ended Date:</div></td>
              <td><select name="endDateOper" size="1">
                  <option value="=">is</option>
                  <option value="<">before</option>
                  <option value=">">after</option>
                </select> <input type="text" name="ENDED_DATE"> </td>
            </tr>
            <tr> 
              <td><div align="right">Verbatim Date:</div></td>
              <td><input type="text" name="VERBATIM_DATE"></td>
            </tr>
            <tr> 
              <td><div align="right">Remarks:</div></td>
              <td><input type="text" name="COLL_EVENT_REMARKS" size="50"></td>
            </tr>
         
            <tr> 
              <td><div align="right">Collecting Source: </div></td>
              <td><input type="text" name="COLLECTING_SOURCE"></td>
            </tr>
            <tr> 
              <td><div align="right">Collecting Method: </div></td>
              <td><input type="text" name="COLLECTING_METHOD"></td>
            </tr>
            <tr> 
              <td><div align="right">Habitat:</div></td>
              <td><input type="text" name="HABITAT_DESC"></td>
            </tr>
            <tr> 
              <td colspan="2"> <div align="center"> 
		  <input type="submit" 
				value="Find Matches" 
				class="schBtn"
				onmouseover="this.className='schBtn btnhov'" 
				onmouseout="this.className='schBtn'">
           <input type="button"
				value="Quit"
				class="qutBtn"
				onmouseover="this.className='qutBtn btnhov'"
				onmouseout="this.className='qutBtn'"
				onClick="document.location='Locality.cfm';">

                </div></td>
            </tr>
          </table>