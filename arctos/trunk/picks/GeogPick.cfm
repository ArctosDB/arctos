<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Pick Higher Geog">
<cfoutput>
<cfif not isdefined("Action")>
	<cfset Action = "nothing">
</cfif>
<cfquery name="ctIslandGroup" datasource="#Application.web_user#">
	select island_group from ctisland_group
</cfquery>
<cfquery name="ctGeogSrcAuth" datasource="#Application.web_user#">
	select source_authority from ctgeog_source_authority
</cfquery>
	
<b>Find Geography:</b>	
  <table border="1">
    <cfform name="getHG" method="post" action="GeogPick.cfm">
      <input type="hidden" name="Action" value="findGeog">
      <input type="hidden" name="geogIdFld" value="#geogIdFld#">
      <input type="hidden" name="highGeogFld" value="#highGeogFld#">
      <input type="hidden" name="formName" value="#formName#">
      <tr> 
        <td><div align="right">Continent or Ocean:</div></td>
        <td><input type="text" name="continent_ocean"></td>
      </tr>
      <tr> 
        <td><div align="right">Country:</div></td>
        <td><input type="text" name="country"></td>
      </tr>
      <tr> 
        <td><div align="right">State:</div></td>
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
        <td><input type=" text" name="feature"></td>
      </tr>
      <tr> 
        <td><div align="right">Island Group:</div></td>
        <td><select name="island_group" size="1">
            <option value=""></option>
            <cfloop query="ctIslandGroup">
              <option value="#ctIslandGroup.island_group#">#ctIslandGroup.island_group#</option>
            </cfloop>
          </select> </td>
      </tr>
      <tr> 
        <td><div align="right">Island:</div></td>
        <td><input type="text" name="island"></td>
      </tr>
      <tr> 
        <td><div align="right">Sea:</div></td>
        <td><input type="text" name="sea"></td>
      </tr>
      <tr> 
        <td><div align="right">Valid?</div></td>
        <td><select name="valid_catalog_term_fg">
            <option value=""></option>
            <option value="1">yes</option>
            <option value="0">no</option>
          </select> </td>
      </tr>
      <tr> 
        <td><div align="right">Source Authority:</div></td>
        <td><select name="source_authority" size="1">
            <option value=""></option>
            <cfloop query="ctGeogSrcAuth">
              <option value="#ctGeogSrcAuth.source_authority#">#ctGeogSrcAuth.source_authority#</option>
            </cfloop>
          </select> </td>
      </tr>
      <tr> 
        <td><div align="right">Geog ID:</div></td>
        <td><input type="text" name="geog_auth_rec_id"></td>
      </tr>
      <tr> <cfoutput> 
          <td colspan="2"><div align="center">
                 <input type="submit" 
	value="Find Matches" 
	class="schBtn"
   	onmouseover="this.className='schBtn btnhov'" 
   	onmouseout="this.className='schBtn'">	

            </div></td>
        </cfoutput> </tr>
    </cfform>
  </table>
</cfoutput>
<!-------------------------------------------------------------------->
<cfif #Action# is "findGeog">
<cfoutput>
	<cfset sql = "select 
		GEOG_AUTH_REC_ID,
		CONTINENT_OCEAN,
		COUNTRY,
		STATE_PROV,
		COUNTY,
		QUAD,
		FEATURE,
		ISLAND,
		ISLAND_GROUP,
		SEA,
		VALID_CATALOG_TERM_FG,
		SOURCE_AUTHORITY ,
		HIGHER_GEOG 
		from 
		geog_auth_rec WHERE geog_auth_rec_id > 0">
	
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
		<cfset sql = "#sql# AND upper(feature) LIKE '%#ucase(feature)#%'">
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
	<cfif len(#geog_auth_rec_id#) gt 0>
		<cfset sql = "#sql# AND geog_auth_rec_id = #geog_auth_rec_id# ORDER BY higher_geog">
	</cfif>
</cfoutput>
<cfif #sql# is "select * from geog_auth_rec where geog_auth_rec_id > 0 AND valid_catalog_term_fg = #valid_catalog_term_fg#">
	Enter some search terms!<cfabort>
</cfif>

<cfquery name="getGeog" datasource="#Application.web_user#">
	#preservesinglequotes(sql)#
</cfquery>


<cfoutput query="getGeog">

<p><a href="##" onClick="javascript: opener.document.#formName#.#geogIdFld#.value='#geog_auth_rec_id#';opener.document.#formName#.#highGeogFld#.value='#replace(higher_geog,"'","\'","all")#';self.close();">#higher_geog#</a>

</cfoutput>
</cfif>
<cfinclude template="../includes/_pickFooter.cfm">