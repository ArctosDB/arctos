<cfinclude template="includes/_header.cfm">
<cfinclude template="includes/functionLib.cfm">


<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "nothing">
<cfset title = "Change Coll Event">
	<!--- edit IDs for a list of specimens passed in from specimenresults --->
	<!--- no security --->
<cfset title = "Change Coll Event">

<cfoutput>
<cfquery name="ctIslandGroup" datasource="#Application.web_user#">
	select island_group from ctisland_group
</cfquery>
<cfquery name="ctGeogSrcAuth" datasource="#Application.web_user#">
	select source_authority from ctgeog_source_authority
</cfquery>
<cfquery name="ctElevUnit" datasource="#Application.web_user#">
	select orig_elev_units from ctorig_elev_units
</cfquery>
<cfquery name="ctCollecting_Source" datasource="#Application.web_user#">
	select collecting_source from ctCollecting_Source
</cfquery>
<cfquery name="ctFeature" datasource="#Application.web_user#">
	select distinct(feature) from geog_auth_rec order by feature
</cfquery>
</cfoutput> 
  <br>Find new collecting event:

<cfoutput> 
        <cfform name="getCol" method="post" action="bulkCollEvent.cfm">
           <input type="hidden" name="Action" value="findCollEvent">
		   <input type="hidden" name="collection_object_id" value="#collection_object_id#">
        <table border="1">
            <tr> 
              <td><div align="right">Specific Locality:</div></td>
              <td><input type="text" name="spec_locality" size="50"> </td>
            </tr>
            <tr> 
              <td><div align="right">Minimum Elevation:</div></td>
              <td><select name="MinElevOper" size="1">
                  <option value="=">is</option>
                  <option value="<>">is not</option>
                  <option value=">">more than</option>
                  <option value="<">less than</option>
                </select> <input type="text" name="MINIMUM_ELEVATION"> </td>
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
              <td><input type="text" name="BEGAN_DATE"> </td>
				<td align="right">Began Until Date (leave blank otherwise)</td>
				<td><input type="text" name="began_until_date"></td>
            </tr>
            <tr> 
              <td><div align="right">Ended Date:</div></td>
              <td><input type="text" name="ENDED_DATE"> </td>
				<td align="right">Ended Until Date (leave blank otherwise)</td>
				<td><input type="text" name="ENDED_until_date"></td>
            </tr>
            <tr> 
              <td><div align="right">Verbatim Date:</div></td>
              <td><input type="text" name="VERBATIM_DATE"></td>
            </tr>
            <tr> 
              <td><div align="right">Verbatim Locality:</div></td>
              <td><input type="text" name="VERBATIM_LOCALITY"></td>
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
              <td><div align="right">Locality ID:</div></td>
              <td><input type="text" name="locality_id"></td>
            </tr>
            <tr> 
              <td colspan="2"> <div align="center"> 
		  <input type="submit" 
				value="Find Matches" 
				class="schBtn"
				onmouseover="this.className='schBtn btnhov'" 
				onmouseout="this.className='schBtn'">
           <input type="reset"
				value="Clear Form"
				class="clrBtn"
				onmouseover="this.className='clrBtn btnhov'"
				onmouseout="this.className='clrBtn'">

                </div></td>
            </tr>
          </table>
          <p><br>
          </p>
        </cfform>
      </cfoutput>
</cfif>




  
<cfif #action# is "findCollEvent">
<cfoutput>
	 <cfset sql = "select * from locality, geog_auth_rec, collecting_event
		 where collecting_event.locality_id = locality.locality_id and
		 locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id">
	
	
		
		<cfif isdefined("BEGAN_DATE") and len(#BEGAN_DATE#) gt 0>
			<cfif isdefined("began_until_date") and len(#began_until_date#) gt 0>
				<cfset sql = "#sql# AND upper(BEGAN_DATE) between to_date('#BEGAN_DATE#', 'DD Mon YYYY') 
																and to_date('#began_until_date#', 'DD Mon YYYY')">
			<cfelse>
				<cfset sql = "#sql# AND upper(BEGAN_DATE) like to_date('#BEGAN_DATE#', 'DD Mon YYYY')">
			</cfif>
		</cfif>
		
		<cfif isdefined("ENDED_DATE") and len(#ended_DATE#) gt 0>
			<cfif isdefined("ended_until_date") and len(#ended_until_date#) gt 0>
				<cfset sql = "#sql# AND upper(ended_DATE) between to_date('#ended_DATE#', 'DD Mon YYYY') 
																and to_date('#ended_until_date#', 'DD Mon YYYY')">
			<cfelse>
				<cfset sql = "#sql# AND upper(ended_DATE) like to_date('#ended_DATE#', 'DD Mon YYYY')">
			</cfif>
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
		<cfif len(#locality_id#) gt 0>
			<cfset sql = "#sql# AND collecting_event.locality_id =#locality_id#">
		</cfif>
		
		
		
	<cfif len(#spec_locality#) gt 0>
		<cfset sql = "#sql# AND upper(spec_locality) like '%#ucase(escapeQuotes(spec_locality))#%'">
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
	
	<cfif len(#source_authority#) gt 0>
		<cfset srcAuth = #replace(source_authority,"'","''")#>
		<cfset sql = "#sql# AND source_authority = '#srcAuth#'">
	</cfif>
	<cftry>
		#preservesinglequotes(sql)#
	<cfquery name="getCollEvent" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfcatch type="database">
		<cf_queryError>
	</cfcatch>
	</cftry>
	<table border>
		<tr>
			<td><b>Geog ID</b></td>
			<td><b>Locality ID</b></td>
			<td><b>&nbsp;</b></td>
			<td><b>Verb. Loc</b></td>
			<td><b>Beg. Date</b></td>
			<td><b>End Date</b></td>
			<td><b>Verb. Date</b></td>
			<td><b>Source</b></td>
			<td><b>Method</b></td>
		</tr>
	<cfset i = 1>
	<cfloop query="getCollEvent">
		<tr>
			<td> <a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#" 
					target="#client.target#">#geog_auth_rec_id#</a></td>
			<td><a href="editLocality.cfm?locality_id=#locality_id#" 
					target="#client.target#">#locality_id#</a></td>
			<td>
			<form name="coll#i#" method="post" action="bulkCollEvent.cfm">
				<input type="hidden" name="collection_object_id" value="#collection_object_id#">
				<input type="hidden" name="collecting_event_id" value="#collecting_event_id#">
				<input type="hidden" name="action" value="updateCollEvent">
				<input type="submit" 
					 	value="Change ALL listed specimens to this coll event" 
						class="savBtn"
   						onmouseover="this.className='savBtn btnhov'" 
						onmouseout="this.className='savBtn'">
			</form>
			</td>
			<td>#verbatim_locality#
				<cfif #spec_locality# neq #verbatim_locality#>
					<br><strong><em>Spec. Locality:</em></strong> #spec_locality#
				</cfif>
			</td>
			<td>#dateformat(began_date,"dd mmm yyyy")#</td>
			<td>#dateformat(ended_date,"dd mmm yyyy")#</td>
			<td>#verbatim_date#</td>
			<td>#collecting_source#</td>
			<td>#collecting_method#</td>
		</tr>
	<cfset i=#i#+1>
	</cfloop>
		</cfoutput>
	</table>
</cfif>



<cfquery name="specimenList" datasource="#Application.web_user#">
	 SELECT 
	 	cataloged_item.collection_object_id as collection_object_id, 
		cat_num,
		concatSingleOtherId(cataloged_item.collection_object_id,'#Client.CustomOtherIdentifier#') AS CustomID,
		scientific_name,
		spec_locality,
		country,
		state_prov,
		county,
		quad,
		institution_acronym,
		collection.collection_cde
	FROM 
		identification, 
		collecting_event,
		locality,
		geog_auth_rec,
		cataloged_item,
		collection
	WHERE 
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id 
		AND collecting_event.locality_id = locality.locality_id 
		AND cataloged_item.collecting_event_id = collecting_event.collecting_event_id 
		AND cataloged_item.collection_object_id = identification.collection_object_id 
		AND cataloged_item.collection_id = collection.collection_id
		AND identification.accepted_id_fg = 1 
		AND cataloged_item.collection_object_id IN (#collection_object_id#)
	ORDER BY 
		collection_object_id
</cfquery>

<br><b>Specimens Being Changed:</b>

<table width="95%" border="1">
<tr>
	<td><strong>Catalog Number</strong></td>
	<td>
		<cfoutput>
			<strong>#Client.CustomOtherIdentifier#</strong>
		</cfoutput>
	</td>
	<td><strong>Accepted Scientific Name</strong></td>
	<td><strong>Spec Locality</strong></td>
	<td><strong>Country</strong></td>
	<td><strong>State</strong></td>
	<td><strong>County</strong></td>
	<td><strong>Quad</strong></td>
</tr>
 <cfoutput query="specimenList" group="collection_object_id">
    <tr>
	  <td>
	  	<a href="/SpecimenDetail.cfm?collection_object_id=#collection_object_id#">
	  	#institution_acronym#&nbsp;#collection_cde#&nbsp;#cat_num#
	  	</a>
	  </td>	  
	<td>
		#CustomID#&nbsp;
	</td>
	<td><i>#Scientific_Name#</i></td>
	<td>#spec_locality#</td>
	<td>#Country#&nbsp;</td>
	<td>#State_Prov#&nbsp;</td>
	<td>
		#county#&nbsp;
	</td>
	<td>
		#quad#&nbsp;
	</td>
</tr>


</cfoutput>
</table>
<!----------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------->
<cfif #action# is "updateCollEvent">
<cfoutput>
	<cfquery name="user" datasource="#Application.uam_dbo#">
		select agent_id from agent_name where agent_name = '#client.username#'
	</cfquery>
	<cfif len(#user.agent_id#) lt 1>
		You aren't a recognized agent!
		<cfabort>
	</cfif>
	<cfset thisDate = #dateformat(now(),"dd-mmm-yyyy")#>
	<cftransaction>
		<cfloop list="#collection_object_id#" index="i">
			<cfquery name="newCollEvent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				UPDATE cataloged_item SET collecting_event_id = #collecting_event_id# WHERE
				collection_object_id=#i#
			</cfquery>
			<cfquery name="upEd" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				UPDATE coll_object SET
					last_edited_person_id=#user.agent_id#,
					last_edit_date='#thisDate#'
				WHERE
					collection_object_id = #i#
			</cfquery>
		</cfloop>
	</cftransaction>
	<cflocation url="bulkCollEvent.cfm?collection_object_id=#collection_object_id#">
</cfoutput>

</cfif>
<cfinclude template="includes/_footer.cfm">