 
  <cfinclude template="/includes/alwaysInclude.cfm">
 <cfset title = "Change Collecting Event">
<cfquery name="ctIslandGroup" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select island_group from ctisland_group
</cfquery>
<cfquery name="ctGeogSrcAuth" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select source_authority from ctgeog_source_authority
</cfquery>
<cfquery name="ctElevUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select orig_elev_units from ctorig_elev_units
</cfquery>
<cfquery name="ctCollecting_Source" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collecting_source from ctCollecting_Source
</cfquery>
<cfquery name="ctFeature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(feature) from geog_auth_rec order by feature
</cfquery>
<!--------------------------------------------------------------------------------->
<cfif #action# is "nothing">
  <cfoutput>
 <cfquery name="getLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 	SELECT
		cat_num,
		collection_cde,
		began_date,
		ended_date,
		verbatim_date,
		verbatim_locality,
		coll_event_remarks,
		valid_distribution_fg,
		collecting_source,
		collecting_method,
		habitat_desc,
		MAXIMUM_ELEVATION,
		MINIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		SPEC_LOCALITY,
		LOCALITY_REMARKS,
		DEPTH_UNITS,
		min_DEPTH,
		max_depth,
		higher_geog,
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
		DATUM,
		agent_name as determined_agent,
		DETERMINED_DATE,
		LAT_LONG_REF_SOURCE,
		LAT_LONG_REMARKS,
		MAX_ERROR_DISTANCE,
		MAX_ERROR_UNITS,
		NEAREST_NAMED_PLACE,
		LAT_LONG_FOR_NNP_FG
	FROM
		cataloged_item,
		collecting_event,
		locality,
		geog_auth_rec,
		accepted_lat_long,
		preferred_agent_name
	WHERE
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		accepted_lat_long.determined_by_agent_id = preferred_agent_name.agent_id (+) AND
		cataloged_item.collection_object_id = #collection_object_id#
 </cfquery>
 <b>Existing collecting Event for <a href="SpecimenDetail.cfm?collection_object_id=#collection_object_id#">#getLoc.collection_cde# #getLoc.cat_num#</a>:</b>
 <form name="newCollEvent" method="post" action="changeCollEvent.cfm">
 	<input type="hidden" name="content_url" value="changeCollEvent.cfm">
	<input type="hidden" name="collection_object_id" value="#collection_object_id#">
	<input type="hidden" name="collecting_event_id" value="">
	<input type="hidden" name="action" value="makeSaveGoNow">
	<input type="button" 
								value="Change Collecting Event" 
								class="picBtn"
								onmouseover="this.className='picBtn btnhov'" 
								onmouseout="this.className='picBtn'"
								onClick="pickCollEvent('collecting_event_id','newCollEvent','#collection_object_id#');">
 </form>
 
 
 </cfoutput>
 <cfoutput query="getLoc">
 <div style="border-color:##3366CC; border-style:groove; width:620px;" align="center">
 	<table border width="600">
		<tr>
			<td align="right" width="30%"><strong>Higher Geog</strong></td>
			<td>#higher_geog#</td>
		</tr>
	</table>
 </div>
 <div style="border-color:##339966; border-style:groove; width:620px;" align="center">
 	<table border width="600">
		<tr>
			<td align="right" width="30%"><strong>Specific Locality</strong></td>
			<td>
				<cfif len(#SPEC_LOCALITY#) gt 0>
					#SPEC_LOCALITY#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Elevation</strong></td>
			<td>
				<cfif len(#MINIMUM_ELEVATION#) gt 0 OR len(#MAXIMUM_ELEVATION#) gt 0>
					#MINIMUM_ELEVATION# - #MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Locality Remarks</strong></td>
			<td>
				<cfif len(#LOCALITY_REMARKS#) gt 0>
					#LOCALITY_REMARKS#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Depth</strong></td>
			<td>
				<cfif len(#min_DEPTH#) gt 0 OR len(#max_depth#) gt 0>
					#min_DEPTH# - #max_depth# #DEPTH_UNITS#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
		
		
	</table>
 </div>
  <div style="border-color:##CC6633; border-style:groove; width:620px;" align="center">
 	<table border width="600">
		<tr>
			<td align="right" width="30%"><strong>Collecting Date</strong></td>
			<td>
				<cfif (#verbatim_date# is #began_date#) AND
			 		(#verbatim_date# is #ended_date#)>
					<cfset thisDate = #dateformat(began_date,"dd mmm yyyy")#>
				<cfelseif (
						(#verbatim_date# is not #began_date#) OR
			 			(#verbatim_date# is not #ended_date#)
					)
					AND
					#began_date# is #ended_date#>
					<cfset thisDate = "#verbatim_date# (#dateformat(began_date,"dd mmm yyyy")#)">
			<cfelse>
					<cfset thisDate = "#verbatim_date# (#dateformat(began_date,"dd mmm yyyy")# - #dateformat(ended_date,"dd mmm yyyy")#)">
			</cfif>
			#thisDate#
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Verbatim Locality</strong></td>
			<td>
				<cfif len(#verbatim_locality#) gt 0>
					#verbatim_locality#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Collecting Event Remarks</strong></td>
			<td>
				<cfif len(#coll_event_remarks#) gt 0>
					#coll_event_remarks#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Valid Distribution</strong></td>
			<td>
				<cfif #valid_distribution_fg# is 1>
				yes
			  <cfelse>
			  	no
			</cfif>
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Collecting Source</strong></td>
			<td>
				#collecting_source#
		  </td>
		</tr>
		
		<tr>
			<td align="right" width="30%"><strong>Habitat Description</strong></td>
			<td>
				<cfif len(#habitat_desc#) gt 0>
					#habitat_desc#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
	</table>
 </div>
 <div style="border-color:##33FF66; border-style:groove; width:620px;" align="center">
 	<table border width="600">
		<tr>
			<td align="right" width="30%"><strong>Coordinates</strong></td>
			<td>
				<cfif len(#verbatimLatitude#) gt 0>
					#verbatimLatitude# #verbatimLongitude#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Datum</strong></td>
			<td>
				<cfif len(#Datum#) gt 0>
					#Datum#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Determined By</strong></td>
			<td>
				<cfif len(#determined_agent#) gt 0>
					#determined_agent#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Determined Date</strong></td>
			<td>
				<cfif len(#DETERMINED_DATE#) gt 0>
					#dateformat(DETERMINED_DATE,"dd mmm yyyy")#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Reference</strong></td>
			<td>
				<cfif len(#LAT_LONG_REF_SOURCE#) gt 0>
					#LAT_LONG_REF_SOURCE#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
		<tr>
			<td align="right" width="30%"><strong>Remarks</strong></td>
			<td>
				<cfif len(#LAT_LONG_REMARKS#) gt 0>
					#LAT_LONG_REMARKS#
				<cfelse>
					<font color="##FF0000">Not given</font>			
			  </cfif>
		  </td>
		</tr>
	</table>
 </div>
		
 </cfoutput>
 

</cfif>
<!--------------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------------->
<cfif #action# is "makeSaveGoNow">
<cfoutput>
	<cfquery name="upCollEvent" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		UPDATE cataloged_item SET collecting_event_id = #collecting_event_id# where collection_object_id = #collection_object_id#
	</cfquery>
		<cf_logEdit collection_object_id="#collection_object_id#">
	<cflocation url="changeCollEvent.cfm?collection_object_id=#collection_object_id#&content_url=changeCollEvent.cfm" addtoken="no">
	
	
</cfoutput>
</cfif>
<cfoutput>
<script type="text/javascript" language="javascript">
	parent.dyniframesize();
</script>
</cfoutput>
<!--------------------------------------------------------------------------------------->