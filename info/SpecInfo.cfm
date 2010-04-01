<cfinclude template="/includes/_pickHeader.cfm">
<cfoutput>
<div align="left">
<cfif #subject# is "lat_long">
	<cfset title="Lat Long Details">
	<cfquery name="getLL" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
			decode(orig_lat_long_units,
				'decimal degrees',to_char(dec_lat) || 'd',
				'deg. min. sec.', to_char(lat_deg) || '&deg; ' || to_char(lat_min) || '&acute; ' || to_char(lat_sec) || '&acute;&acute; ' || lat_dir,
				'degrees dec. minutes', to_char(lat_deg) || '&deg; ' || to_char(dec_lat_min) || '&acute; ' || lat_dir
			)  VerbatimLatitude,
			decode(orig_lat_long_units,
				'decimal degrees',to_char(dec_long) || '&deg;',
				'deg. min. sec.', to_char(long_deg) || '&deg; ' || to_char(long_min) || '&acute; ' || to_char(long_sec) || '&acute;&acute; ' || long_dir,
				'degrees dec. minutes', to_char(long_deg) || '&deg; ' || to_char(dec_long_min) || '&acute; ' || long_dir
			)  VerbatimLongitude,
			accepted_lat_long_fg,
			datum,
			determined_date,
			agent_name,
			lat_long_ref_source,
			max_error_distance,
			max_error_units,
			VerificationStatus,
			GeorefMethod
			 FROM
		 lat_long, 
		 agent_name 
		 WHERE locality_id = #thisId# and 
		 determined_by_agent_id = agent_id and 
		 agent_name_type='preferred' 
		 order by accepted_lat_long_fg desc
	</cfquery>
	<table border>
		<tr>
			<td><b>Accepted?</b></td>
			<td><b>Latitude</b></td>
			<td><b>Longitude</b></td>
			<td><b>Datum</b></td>
			<td><b>Date</b></td>
			<td><b>Determiner</b></td>
			<td><b>Ref. Src.</b></td>
			<td><b>Max Error</b></td>
			<td><b>Verification Status</b></td>
			<td><b>Georef Method</b></td>			
		</tr>
		<cfset i=1>
		<cfloop query="getLL">
		<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
			<td>
				<cfif #getLL.accepted_lat_long_fg# is 1>
              <font color="##00FF66">Yes</font> 
              <cfelse>
              <font color="##FF0000">No</font> 
            </cfif>
			</td>
			<td nowrap>#getLL.verbatimLatitude#</td>
			<td nowrap>#getLL.verbatimLongitude#</td>
			<td>#getLL.datum#</td>
			<td nowrap>		
			#dateformat(getLL.determined_date,"dd mmm yyyy")#</td>
			<td>#getLL.agent_name#</td>
			<td>#getLL.lat_long_ref_source#</td>
			<td nowrap>#getLL.max_error_distance# #getLL.max_error_units#</td>
			<td>#getLL.VerificationStatus#</td>
			<td>#getLL.GeorefMethod#</td>
		</tr>
		<cfset i=#i#+1>
		</cfloop>
	</table>
</cfif>

<!--------------------------------------------------------------------------------------------->
<cfif #subject# is "identification">
<cfquery name="identification" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT
			identification.scientific_name,
			concatidagent(identification.identification_id) agent_name,
			made_date,
			nature_of_id,
			identification_remarks,
			identification.identification_id,
			accepted_id_fg
		FROM
			identification 
		WHERE
			identification.collection_object_id = #thisId# 
		ORDER BY accepted_id_fg DESC
	</cfquery>
	<table border>
		<tr>
			<td><b>Accepted?</b></td>
			<td><b>Scientific Name</b></td>
			<td><b>Identifier</b></td>
			<td><b>ID Date</b></td>
			<td><b>Nature of ID</b></td>
			<td><b>Remarks</b></td>
		</tr>
		<cfset i=1>
		<cfloop query="identification">
			<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
				<td>
					<cfif #accepted_id_fg# is 1>
              <font color="##00FF66">Yes</font> 
              <cfelse>
              <font color="##FF0000">No</font> 
            </cfif></td>
				<td nowrap>
				<cfquery name="getTaxa" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						taxonomy.taxon_name_id,
						scientific_name,
						author_text
					FROM
						identification_taxonomy,
						taxonomy
					WHERE
						identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id and
						identification_id=#identification_id#
				</cfquery>
				<cfif #getTaxa.recordcount# is 1>
					<a href="/TaxonomyDetails.cfm?taxon_name_id=#getTaxa.taxon_name_id#" target="_blank"><i>#scientific_name#</i></a> #getTaxa.author_text#
				<cfelse>
					<cfset link="">
					<cfset i=1>
					<cfset thisSciName="#scientific_name#">
					
					<cfloop query="getTaxa">
						<cfset thisLink='<a href="/TaxonomyDetails.cfm?taxon_name_id=#taxon_name_id#" target="_blank"><i>#scientific_name#</i></a> #author_text#'>
						<cfset thisSciName=#replace(thisSciName,scientific_name,thisLink)#>
						<cfset i=#i#+1>
					</cfloop>
					#thisSciName#
				</cfif>
				
				</td>
				<td nowrap>#agent_name#</td>
				<td nowrap>#dateformat(made_date,"dd mmm yyyy")#</td>
				<td nowrap>#nature_of_id#</td>
				<td>#identification_remarks#&nbsp;</td>
			</tr>
			<cfset i=#i#+1>
		</cfloop>
	</table>
</cfif>
<!--------------------------------------------------------------------------------------------->

<cfif #subject# is "parts">
<cfquery name="id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT
			part_name,
			sampled_from_obj_id,
			condition,
			coll_obj_disposition,
			enteredPerson.agent_name enteredBy,
			editedPerson.agent_name editedBy,
			coll_object_entered_date,
			last_edit_date,
			lot_count
		FROM
			specimen_part,
			coll_object,
			preferred_agent_name enteredPerson,
			preferred_agent_name editedPerson			
		WHERE
			specimen_part.collection_object_id= coll_object.collection_object_id AND
			coll_object.entered_person_id = enteredPerson.agent_id (+) AND
			coll_object.last_edited_person_id = editedPerson.agent_id (+) AND
			specimen_part.derived_from_cat_item= #thisId# 
		ORDER BY part_name
	</cfquery>
	<table border>
		<tr>
			<td><b>Part Name</b></td>
			<td><b>Condition</b></td>
			<td><b>Disposition</b></td>
			<td><b>Cnt</b></td>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
				<td><b>Entered By</b></td>
				<td><b>Edited By</b></td>
			</cfif>
		</tr>
		<cfset i=1>
		<cfloop query="id">
			<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
				
				<td>#part_name#<cfif len(sampled_from_obj_id) gt 0>&nbsp;subsample</cfif>
				</td>
				<td>#part_modifier#&nbsp;</td>
				<td>#preserve_method#&nbsp;</td>
				<td>#condition#</td>
				<td>#coll_obj_disposition#&nbsp;</td>
				<td>#lot_count#&nbsp;</td>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
					<td>#enteredBy# on #dateformat(coll_object_entered_date,"dd mmm yyyy")#</td>
					
					<td>#editedBy# on #dateformat(last_edit_date,"dd mmm yyyy")#</td>
				</cfif>
			</tr>
			<cfset i=#i#+1>
		</cfloop>
	</table>
</cfif>
<cfif #subject# is "attributes">
<cfquery name="atts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT
			*
		FROM
			attributes,
			preferred_agent_name
		WHERE
			attributes.determined_by_agent_id = preferred_agent_name.agent_id AND
			collection_object_id = #thisId#
		ORDER BY 
			attribute_type,
			determined_date
	</cfquery>
	<table border>
		<tr>
			<td><b>Attribute</b></td>
			<td><b>Value</b></td>
			<td><b>Units</b></td>
			<td><b>Det. Date</b></td>
			<td><b>Determiner</b></td>
			<td><b>Remarks</b></td>
			<td><b>Det. Method</b></td>
		</tr>
		<cfset i=1>
		<cfloop query="atts">
			<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#	>
				<td nowrap>#Attribute_type#</td>
				<td>#attribute_Value#</td>
				<td>#attribute_Units#&nbsp;</td>
				<td nowrap>#dateformat(determined_date,"dd mmm yyyy")#</td>
				<td nowrap>#agent_name#</td>
				<td>#attribute_remark#&nbsp;</td>
				<td>#determination_method#&nbsp;</td>
			</tr>
			<cfset i=#i#+1>
		</cfloop>
	</table>
</cfif>


</div>
</cfoutput>

<div align="right">
    <p><a href="javascript: void(0);" onClick="self.close();">Close this window</a></p>
</div>

<cfinclude template="/includes/_pickFooter.cfm">
<!----
<script>
	var contentHeight = document.clientHeight;
	var contentWidth = document.clientWidth;
	//var contentHeight = 200;
	//var contentWidth = 600;
	//var newHeight = contentHeight + 10;
	window.resizeTo(contentWidth,contentHeight);
</script>
---->