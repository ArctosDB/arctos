<cfinclude template="includes/_header.cfm">
<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "nothing">
<cfset title = "Change Coll Event">
	<!--- edit IDs for a list of specimens passed in from specimenresults --->
	<!--- no security --->
<cfset title = "Change Coll Event">
<cfset showLocality=1>
<cfset showEvent=1>
<cfoutput>
 <h3>Find new collecting event</h3>
<form name="getCol" method="post" action="bulkCollEvent.cfm">
	<input type="hidden" name="Action" value="findCollEvent">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<cfinclude template="/includes/frmFindLocation_guts.cfm">	   
</form>
</cfoutput>
</cfif>
  
<cfif #action# is "findCollEvent">
<cfoutput>
	<cf_findLocality>
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
	<cfloop query="localityResults">
		<tr>
			<td> <a href="Locality.cfm?Action=editGeog&geog_auth_rec_id=#geog_auth_rec_id#">#geog_auth_rec_id#</a></td>
			<td><a href="editLocality.cfm?locality_id=#locality_id#">#locality_id#</a></td>
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



<cfquery name="specimenList" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	 SELECT 
	 	cataloged_item.collection_object_id as collection_object_id, 
		cat_num,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
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
			<strong>#session.CustomOtherIdentifier#</strong>
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
		select agent_id from agent_name where agent_name = '#session.username#'
	</cfquery>
	<cfif len(#user.agent_id#) lt 1>
		You aren't a recognized agent!
		<cfabort>
	</cfif>
	<cfset thisDate = #dateformat(now(),"dd-mmm-yyyy")#>
	<cftransaction>
		<cfloop list="#collection_object_id#" index="i">
			<cfquery name="newCollEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				UPDATE cataloged_item SET collecting_event_id = #collecting_event_id# WHERE
				collection_object_id=#i#
			</cfquery>
			<cfquery name="upEd" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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