<cfinclude template="/includes/_frameHeader.cfm">
<cfset btime=now()>
	<script type='text/javascript' src='/includes/annotate.js'></script>
	<link rel="stylesheet" type="text/css" href="/includes/annotate.css">
<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
	<cfset oneOfUs = 1>
	<cfset isClicky = "likeLink">
<cfelse>
	<cfset oneOfUs = 0>
	<cfset isClicky = "">
</cfif>
<cfset detSelect = "
	SELECT
		cataloged_item.collection_object_id as collection_object_id,
		collection.collection_cde,
		cataloged_item.accn_id,
		collection.collection,
		identification.scientific_name,
		identification.identification_remarks,
		identification.identification_id,
		identification.made_date,
		identification.nature_of_id,
		idagentname.agent_name id_by,
		identification_agent.identifier_order,
		collecting_event.collecting_event_id,
		case when 
			#oneOfUs# != 1 and concatencumbrances(cataloged_item.collection_object_id) like '%mask year collected%' then
				to_date(to_char(collecting_event.began_date,'dd-Mon')||'-8888')
		else 
			collecting_event.began_date  
		end began_date,
		case when 
			#oneOfUs# != 1 and concatencumbrances(cataloged_item.collection_object_id) like '%mask year collected%' then
				to_date(to_char(collecting_event.ended_date,'dd-Mon')||'-8888')
		else 
			collecting_event.ended_date  
		end ended_date,
		case when 
			#oneOfUs# != 1 and concatencumbrances(cataloged_item.collection_object_id) like '%mask year collected%' then
				'Masked'
		else 
			collecting_event.verbatim_date  
		end verbatim_date,
		collecting_event.habitat_desc,
		locality.locality_id,
		locality.minimum_elevation,
		locality.maximum_elevation,
		locality.orig_elev_units,
		locality.spec_locality,		
		case when 
			#oneOfUs# != 1 and 
				concatencumbrances(cataloged_item.collection_object_id) like '%mask coordinates%' and
					accepted_lat_long.orig_lat_long_units is not null
				then 'Masked'
		else
			decode(accepted_lat_long.orig_lat_long_units,
				'decimal degrees',to_char(accepted_lat_long.dec_lat) || '&deg; ',
				'deg. min. sec.', to_char(accepted_lat_long.lat_deg) || '&deg; ' ||
					to_char(accepted_lat_long.lat_min) || '&acute; ' || 
					to_char(accepted_lat_long.lat_sec) || '&acute;&acute; ' || accepted_lat_long.lat_dir,
				'degrees dec. minutes', to_char(accepted_lat_long.lat_deg) || '&deg; ' || 
					to_char(accepted_lat_long.dec_lat_min) || '&acute; ' || accepted_lat_long.lat_dir
			) 
		end VerbatimLatitude,
		case when 
			#oneOfUs# != 1 and 
				concatencumbrances(cataloged_item.collection_object_id) like '%mask coordinates%' and
					accepted_lat_long.orig_lat_long_units is not null
				then 'Masked'
		else
			decode(accepted_lat_long.orig_lat_long_units,
				'decimal degrees',to_char(accepted_lat_long.dec_long) || '&deg;',
				'deg. min. sec.', to_char(accepted_lat_long.long_deg) || '&deg; ' || 
					to_char(accepted_lat_long.long_min) || '&acute; ' || 
					to_char(accepted_lat_long.long_sec) || '&acute;&acute; ' || accepted_lat_long.long_dir,
				'degrees dec. minutes', to_char(accepted_lat_long.long_deg) || '&deg; ' || 
					to_char(accepted_lat_long.dec_long_min) || '&acute; ' || accepted_lat_long.long_dir
			)
		end VerbatimLongitude,
		accepted_lat_long.dec_lat,
		accepted_lat_long.dec_long,
		accepted_lat_long.max_error_distance,
		accepted_lat_long.max_error_units,
		accepted_lat_long.determined_date latLongDeterminedDate,
		accepted_lat_long.lat_long_ref_source,
		accepted_lat_long.lat_long_remarks,
		accepted_lat_long.datum,
		latLongAgnt.agent_name latLongDeterminer,
		geog_auth_rec.geog_auth_rec_id,
		geog_auth_rec.continent_ocean,
		geog_auth_rec.country,
		geog_auth_rec.state_prov,
		geog_auth_rec.quad,
		geog_auth_rec.county,
		geog_auth_rec.island,
		geog_auth_rec.island_group,
		geog_auth_rec.sea,
		geog_auth_rec.feature,
		citation.type_status,
		citation.occurs_page_number,
		cited_taxa.scientific_name as cited_name,
		cited_taxa.taxon_name_id as cited_name_id,	
		formatted_publication.formatted_publication,
		formatted_publication.publication_id,
		coll_object.coll_obj_disposition,
		coll_object.coll_object_entered_date,
		coll_object.last_edit_date,
		coll_object.flags,
		coll_object_remark.coll_object_remarks,
		coll_object_remark.associated_species,
		coll_object_remark.habitat,
		enteredPerson.agent_name EnteredBy,
		editedPerson.agent_name EditedBy,
		collector.coll_order,
		case when 
			#oneOfUs# != 1 and concatencumbrances(cataloged_item.collection_object_id) like '%mask collector%' then 'Anonymous'
		else 
			colls.agent_name  
		end collectors,
		preparator.coll_order prep_order,
		case when 
			#oneOfUs# != 1 and concatencumbrances(cataloged_item.collection_object_id) like '%mask preparator%' then 'Anonymous'
		else 
			preps.agent_name  
		end preparators,
		attributes.attribute_type,
		attributes.attribute_value,
		attributes.attribute_units,
		attributes.attribute_remark,
		attributes.determination_method,
		attributes.determined_date,
		attribute_determiner.agent_name attributeDeterminer,
		accn_number accession,
		biol_indiv_relations.biol_indiv_relationship, 
		biol_indiv_relations.related_coll_object_id,
		related_cat_item.cat_num related_cat_num,
		related_coll.collection as related_collection,
		concatencumbrances(cataloged_item.collection_object_id) concatenatedEncumbrances,
		concatEncumbranceDetails(cataloged_item.collection_object_id) encumbranceDetail,
		locality.locality_remarks,
		verbatim_locality,
		min_depth,
		max_depth,
		depth_units,
		collecting_method,
		collecting_source
	FROM 
		cataloged_item,
		collection,
		identification,
		identification_agent,
		preferred_agent_name idagentname,
		collecting_event,
		locality,
		accepted_lat_long,
		preferred_agent_name latLongAgnt,
		geog_auth_rec,
		citation,
		taxonomy cited_taxa,
		(select * from formatted_publication where format_style='author-year')  formatted_publication,
		coll_object,
		coll_object_remark,
		preferred_agent_name enteredPerson,
		preferred_agent_name editedPerson,
		(select * from collector where collector_role='c') collector,
		preferred_agent_name colls,
		(select * from collector where collector_role='p') preparator,
		preferred_agent_name preps,
		attributes,
		preferred_agent_name attribute_determiner,
		accn,
		trans,
		biol_indiv_relations,
		cataloged_item related_cat_item,
		collection related_coll
	WHERE 
		cataloged_item.collection_id = collection.collection_id AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		identification.identification_id = identification_agent.identification_id (+) and
		identification_agent.agent_id = idagentname.agent_id (+) and
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id  AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		accepted_lat_long.determined_by_agent_id = latLongAgnt.agent_id (+) AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		cataloged_item.collection_object_id = citation.collection_object_id (+) AND
		citation.cited_taxon_name_id = cited_taxa.taxon_name_id (+) AND
		citation.publication_id = formatted_publication.publication_id (+) AND
		cataloged_item.collection_object_id = coll_object.collection_object_id AND
		coll_object.collection_object_id = coll_object_remark.collection_object_id (+) AND
		coll_object.entered_person_id = enteredPerson.agent_id AND
		coll_object.last_edited_person_id = editedPerson.agent_id (+) AND
		cataloged_item.collection_object_id = collector.collection_object_id (+) AND
		collector.agent_id = colls.agent_id (+) AND
		cataloged_item.collection_object_id = preparator.collection_object_id (+) AND	
		preparator.agent_id = preps.agent_id (+) AND
		cataloged_item.collection_object_id=attributes.collection_object_id (+) AND
		attributes.determined_by_agent_id = attribute_determiner.agent_id (+) and
		cataloged_item.accn_id =  accn.transaction_id  AND
		accn.transaction_id = trans.transaction_id AND
		cataloged_item.collection_object_id = biol_indiv_relations.collection_object_id (+) AND
		biol_indiv_relations.related_coll_object_id = related_cat_item.collection_object_id (+) AND
		related_cat_item.collection_id = related_coll.collection_id (+) and
	cataloged_item.collection_object_id = #collection_object_id#
	">
<cfset checkSql(detSelect)>
<cfquery name="detail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(detSelect)#
</cfquery>
<cfoutput>
	<cfset etime=now()>
	<cfset tt=DateDiff("s", btime, etime)>
	<br>Runtime: #tt#
	
</cfoutput>
<cfif #detail.concatenatedEncumbrances# contains "mask record" and #oneOfUs# neq 1>
	Record masked.
	<cfabort>
</cfif>

<cfquery name="one" dbtype="query">
	select
		collection_object_id,
		collection_cde,
		accn_id,
		collection,
		scientific_name,
		identification_remarks,
		identification_id,
		made_date,
		nature_of_id,
		collecting_event_id,	
		verbatim_date,
		began_date,
		ended_date,
		habitat_desc,
		locality_id,
		minimum_elevation,
		maximum_elevation,
		orig_elev_units,
		spec_locality,		
		VerbatimLatitude,
		VerbatimLongitude,
		dec_lat,
		dec_long,
		max_error_distance,
		max_error_units,
		latLongDeterminedDate,
		lat_long_ref_source,
		lat_long_remarks,
		latLongDeterminer,
		datum,
		geog_auth_rec_id,
		continent_ocean,
		country,
		state_prov,
		quad,
		county,
		island,
		island_group,
		sea,
		feature,
		coll_obj_disposition,
		coll_object_entered_date,
		last_edit_date,
		flags,
		coll_object_remarks,
		associated_species,
		habitat,
		EnteredBy,
		EditedBy,
		accession,
		encumbranceDetail,
		locality_remarks,
		verbatim_locality,
		min_depth,
		max_depth,
		depth_units,
		collecting_method,
		collecting_source
	from
		detail
	group by
		collection_object_id,
		collection_cde,
		accn_id,
		collection,
		scientific_name,
		identification_remarks,
		identification_id,
		made_date,
		nature_of_id,
		collecting_event_id,	
		verbatim_date,
		began_date,
		ended_date,
		habitat_desc,
		locality_id,
		minimum_elevation,
		maximum_elevation,
		orig_elev_units,
		spec_locality,		
		VerbatimLatitude,
		VerbatimLongitude,
		dec_lat,
		dec_long,
		max_error_distance,
		max_error_units,
		latLongDeterminedDate,
		lat_long_ref_source,
		lat_long_remarks,
		latLongDeterminer,
		datum,
		geog_auth_rec_id,
		continent_ocean,
		country,
		state_prov,
		quad,
		county,
		island,
		island_group,
		sea,
		feature,
		coll_obj_disposition,
		coll_object_entered_date,
		last_edit_date,
		flags,
		coll_object_remarks,
		associated_species,
		habitat,
		EnteredBy,
		EditedBy,
		accession,
		encumbranceDetail,
		locality_remarks,
		verbatim_locality,
		min_depth,
		max_depth,
		depth_units,
		collecting_method,
		collecting_source
</cfquery>
<cfquery name="colls"  dbtype="query">
	SELECT 
		collectors
	FROM 
		detail
	group by
		collectors
	ORDER BY 
		coll_order
</cfquery>
<cfquery name="preps"  dbtype="query">
	SELECT 
		preparators
	FROM
		detail
	group by
		preparators
	ORDER BY 
		prep_order
</cfquery>
<cfquery name="identifiers"  dbtype="query">
	SELECT 
		id_by
	FROM
		detail
	group by
		id_by
	ORDER BY 
		identifier_order
</cfquery>
<cfquery name="attribute"  dbtype="query">
	SELECT 
		attribute_type,
		attribute_value,
		attribute_units,
		attribute_remark,
		attributeDeterminer,
		determination_method,
		determined_date
	FROM
		detail 
	GROUP BY
		attribute_type,
		attribute_value,
		attribute_units,
		attribute_remark,
		attributeDeterminer,
		determination_method,
		determined_date
</cfquery>
<cfquery name="relns"  dbtype="query">
	SELECT 
		biol_indiv_relationship,
		related_coll_object_id,
		related_cat_num,
		related_collection
	FROM
		detail 
	GROUP BY
		biol_indiv_relationship,
		related_coll_object_id,
		related_cat_num,
		related_collection
</cfquery>			
<cfquery name="citations" dbtype="query">
	SELECT 
		publication_id,
		cited_name,
		type_status,
		cited_name_id,
		occurs_page_number,
		formatted_publication
	FROM
		detail 
	GROUP BY
		publication_id,
		cited_name,
		type_status,
		cited_name_id,
		occurs_page_number,
		formatted_publication
	order by
		formatted_publication
</cfquery>




				
<cfoutput query="one">
<form name="editStuffLinks" method="post" action="SpecimenDetail.cfm">
	<input type="hidden" name="collection_object_id" value="#detail.collection_object_id#">
	<input type="hidden" name="content_url" value="#content_url#">
	<input type="hidden" name="suppressHeader" value="true">
	<input type="hidden" name="action" value="nothing">
	<input type="hidden" name="Srch" value="Part">
	<input type="hidden" name="collecting_event_id" value="#detail.collecting_event_id#">
<table width="95%" cellpadding="0" cellspacing="0"><!---- full page table ---->
	<tr>
		<td valign="top" width="50%">
<!------------------------------------ Taxonomy ---------------------------------------------->
			<div class="detailCell">				
				<div class="detailLabel">
					<cfif #oneOfUs# is 1>
						<span class="detailEditCell" onclick="window.parent.switchIFrame('editIdentification');">Edit</span>
					</cfif>
				</div>
				<table id="SD">		
				<tr><td id="SDCellRight"><i>#scientific_name#</i></td>
				</tr>
				<tr><td id="SDCellRight">Determined by #valuelist(identifiers.id_by)#, #dateformat(made_date,"dd mmm yyyy")#</td>
				</tr>
				<tr><td id="SDCellRight" class="detailElements">#nature_of_id#</td>
				</tr>
				<cfif len(#identification_remarks#) gt 0>
					<tr><td id="SDCellRight" class="detailElements">#identification_remarks#</td>
					</tr>
				</cfif>
				</table>
			</div>
			
<!------------------------------------ citations ---------------------------------------------->
			<cfif len(#citations.cited_name#) gt 0>  
				<div class="detailCell">
					<div class="detailLabel">Citations</div>
					<cfloop query="citations">
						<div class="detailBlock">
							<span class="detailData">
								<a href="PublicationResults.cfm?publication_id=#publication_id#" 
									target="_mainFrame">
										#formatted_publication#</a>, 
								<cfif len(#occurs_page_number#) gt 0>
									Page #occurs_page_number#,
								</cfif>
								#type_status# of 
								<a href="TaxonomyDetails.cfm?taxon_name_id=#cited_name_id#" target="_mainFrame"><i>#replace(cited_name," ","&nbsp;","all")#</i></a>
							</span>
						</div>
					</cfloop>
				</div>
			</cfif>
<!------------------------------------ locality ---------------------------------------------->
<div class="detailCell">
				<div class="detailLabel">
					<cfif #oneOfUs# is 1>
						<span class="detailEditCell" onclick="window.parent.switchIFrame('specLocality');">Edit</span>
					</cfif>
				</div>
				<table id="SD">
					<cfif len(#one.continent_ocean#) gt 0>						
						<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Continent/Ocean:</td>
								<td id="SDCellRight">#one.continent_ocean#</td>
						</tr>
					</cfif>
					<cfif len(#one.sea#) gt 0>			
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Sea:</td>
							<td id="SDCellRight">#one.sea#</td>
						</tr>
					</cfif>
					<cfif len(#one.country#) gt 0>
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Country:</td>
							<td id="SDCellRight">#one.country#</td>
						</tr>
					</cfif>
					<cfif len(#one.state_prov#) gt 0>	
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">State/Province:</td>
							<td id="SDCellRight">#one.state_prov#</td>
						</tr>
					</cfif>
					<cfif len(#one.feature#) gt 0>	
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Feature:</td>
							<td id="SDCellRight">#one.feature#</td>
						</tr>
					</cfif>
					<cfif len(#one.county#) gt 0>
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">County:</td>
							<td id="SDCellRight">#one.county#</td>
						</tr>
					</cfif>
					<cfif len(#one.island_group#) gt 0>	
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Island Group:</td>
							<td id="SDCellRight">#one.island_group#</td>
						</tr>
					</cfif>
					<cfif len(#one.island#) gt 0>
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Island:</td>
							<td id="SDCellRight">#one.island#</td>
						</tr>
					</cfif>
					<cfif len(#one.quad#) gt 0>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">USGS Quad:</td>
								<td id="SDCellRight">#one.quad#</td>
							</tr>
					</cfif>					
					<cfif len(#one.spec_locality#) gt 0>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Specific Locality:</td>
								<td id="SDCellRight">#one.spec_locality#</td>
							</tr>
					</cfif>
					<cfif #one.verbatim_locality# is not #one.spec_locality#>
						<cfif len(#one.verbatim_locality#) gt 0>
								<tr class="detailData">
									<td id="SDCellLeft" class="innerDetailLabel">Verbatim Locality:</td>
									<td id="SDCellRight">#one.verbatim_locality#</td>
								</tr>
						</cfif>
					</cfif>					
					<cfif len(#one.locality_remarks#) gt 0>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Locality Remarks:</td>
								<td id="SDCellRight">#one.locality_remarks#</td>
							</tr>
					</cfif>
					<cfif len(#one.habitat_desc#) gt 0>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">General Habitat:</td>
								<td id="SDCellRight">#one.habitat_desc#</td>
							</tr>
					</cfif>
					<cfif len(#one.habitat#) gt 0>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Microhabitat:</td>
								<td id="SDCellRight">#one.habitat#</td>
							</tr>
					</cfif>
					<cfif len(#one.associated_species#) gt 0>
						<div class="detailBlock">
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Associated Species:</td>
								<td id="SDCellRight">#one.associated_species#</td>
							</tr>
						</div>
					</cfif>
					<cfif len(#one.collecting_method#) gt 0>
						<div class="detailBlock">
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Collecting&nbsp;Method:</td>
								<td id="SDCellRight">#one.collecting_method#</td>
							</tr>
						</div>
					</cfif>
					<div class="detailBlock">
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Collecting&nbsp;Source:</td>
							<td id="SDCellRight">#one.collecting_source#</td>
						</tr>
					</div>
					<cfif len(#one.minimum_elevation#) gt 0>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Elevation:</td>
								<td id="SDCellRight">#one.minimum_elevation# to #one.maximum_elevation# #one.orig_elev_units#</td>
							</tr>
					</cfif>
					
					<cfif len(#one.depth_units#) gt 0>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Depth:</td>
								<td id="SDCellRight">#one.min_depth#
									<cfif #one.min_depth# neq  #one.max_depth#>to #one.max_depth# </cfif> #one.depth_units#</td>
							</tr>
					</cfif>
					<cfif (len(#verbatimLatitude#) gt 0 and len(#verbatimLongitude#) gt 0)>
							<tr class="detailData">
								<td id="SDCellLeft" class="innerDetailLabel">Coordinates:</td>
								<td id="SDCellRight">#one.VerbatimLatitude# #one.verbatimLongitude#
								<cfif len(#one.datum#) gt 0>
									(#one.datum#)
								</cfif>
								<cfif len(#one.max_error_distance#) gt 0>
									, Error:
									#one.max_error_distance# #one.max_error_units#
								</td>
						</cfif>
							</tr>
						
						<!--- determination --->
						<cfif len(#one.latLongDeterminer#) gt 0>
							<cfset determination = "#one.latLongDeterminer#">
							<cfif len(#one.latLongDeterminedDate#) gt 0>
								<cfset determination = '#determination#; #dateformat(one.latLongDeterminedDate, "dd mmm yyyy")#'>
							</cfif>
							<cfif len(#one.lat_long_ref_source#) gt 0>
								<cfset determination = '#determination#; #one.lat_long_ref_source#'>
							</cfif>
								<tr>
									<td></td>
									<td id="SDCellRight" class="detailCellSmall">
									#determination#
									</td>
								</tr>
						</cfif>
						<cfquery name="geology" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
							select * from 
							geology_attributes,
							preferred_agent_name
							where
							geology_attributes.GEO_ATT_DETERMINER_ID=preferred_agent_name.agent_id (+) and
							 locality_id=#one.locality_id#
						</cfquery>
						<cfloop query="geology">
							 <td id="SDCellLeft" class="innerDetailLabel">#GEOLOGY_ATTRIBUTE#:</td>
							 <td id="SDCellRight">
								 #GEO_ATT_VALUE#								 
							</td>
							<tr>
								<td></td>
								<td id="SDCellRight" class="detailCellSmall">
									Determined by 
									<cfif len(agent_name) gt 0>
										#agent_name#
									<cfelse>
										unknown
									</cfif>
									<cfif len(GEO_ATT_DETERMINED_DATE) gt 0>
										on #dateformat(GEO_ATT_DETERMINED_DATE,"dd mmm yyyy")#
									</cfif>
									<cfif len(GEO_ATT_DETERMINED_METHOD) gt 0>
										Method: #GEO_ATT_DETERMINED_METHOD#
									</cfif>
									<cfif len(GEO_ATT_REMARK) gt 0>
										Remark: #GEO_ATT_REMARK#
									</cfif>
									
								</td>
							</tr>
						</cfloop>
						<!---<cfif len(#one.latLongDeterminer#) gt 0>
							<div class="detailBlock">
								<span class="detailCellSmall">
									<span class="innerDetailLabel">Coordinate Determiner:</span>
									#one.latLongDeterminer#
								</span>
							</div>
						</cfif>
						<cfif len(#one.latLongDeterminedDate#) gt 0>
							<div class="detailBlock">
								<span class="detailCellSmall">
									<span class="innerDetailLabel">Coordinate Determined Date:</span>
									#dateformat(one.latLongDeterminedDate,"dd mmm yyyy")#
								</span>
							</div>
						</cfif>
						<cfif len(#one.lat_long_ref_source#) gt 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Coordinate Reference:</span>
									#one.lat_long_ref_source#
								</span>
							</div>
						</cfif>--->
						<cfif len(#one.lat_long_remarks#) gt 0>
								<tr class="detailCellSmall">
									<td></td>
									<td class="innerDetailLabel">Coordinate Remarks:
										#one.lat_long_remarks#
									</td>
								</tr>
						</cfif>
					</cfif>
					<cfif (#one.verbatim_date# is #one.began_date#) AND (#one.verbatim_date# is #one.ended_date#)>
						<cfset thisDate = #dateformat(one.began_date,"dd mmm yyyy")#>
					<cfelseif (
						(#one.verbatim_date# is not #one.began_date#) OR
			 			(#one.verbatim_date# is not #one.ended_date#)
						) AND #one.began_date# is #one.ended_date#>
						<cfset thisDate = "#one.verbatim_date# (#dateformat(one.began_date,"dd mmm yyyy")#)">
					<cfelse>
						<cfset thisDate = "#one.verbatim_date# (#dateformat(one.began_date,"dd mmm yyyy")# - #dateformat(one.ended_date,"dd mmm yyyy")#)">
					</cfif>
						<tr class="detailData">
							<td id="SDCellLeft" class="innerDetailLabel">Collecting Date:</td>
							<td id="SDCellRight">#thisDate#</td>
						</tr>
					</table>
				</div>
				
<!------------------------------------ parts ---------------------------------------------->
	

<cfquery name="parts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select
		specimen_part.collection_object_id part_id,
		pc.label,
		part_name,
		part_modifier,
		sampled_from_obj_id,
		preserve_method,
		is_tissue,
		coll_object.COLL_OBJ_DISPOSITION part_disposition,
		coll_object.CONDITION part_condition,
		lot_count,
		coll_object_remarks part_remarks
	from
		specimen_part,
		coll_object,
		coll_object_remark,
		coll_obj_cont_hist,
		container oc,
		container pc
	where
		specimen_part.collection_object_id=coll_object.collection_object_id and
		coll_object.collection_object_id=coll_obj_cont_hist.collection_object_id and
		coll_object.collection_object_id=coll_object_remark.collection_object_id (+) and
		coll_obj_cont_hist.container_id=oc.container_id and
		oc.parent_container_id=pc.container_id (+) and
		specimen_part.derived_from_cat_item=#one.collection_object_id#
</cfquery>
<cfquery name="mPart" dbtype="query">
	select * from parts where sampled_from_obj_id is null order by part_name
</cfquery>
			<div class="detailCell">
				<div class="detailLabel">&nbsp;<!---Parts--->
					<cfif #oneOfUs# is 1>
						<span class="detailEditCell" onclick="window.parent.switchIFrame('editParts');">Edit</span>
						<!---	onclick="window.parent.switchIFrame('Container');"--->
					<cfelse>
						<span class="detailEditCell" onClick="getInfo('parts','#one.collection_object_id#');">Details</span>
					</cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<table border>
							<tr>
								<th><span class="innerDetailLabel">Part Name</span></th>
								<th><span class="innerDetailLabel">Condition</span></th>
								<th><span class="innerDetailLabel">Disposition</span></th>
								<th><span class="innerDetailLabel">##</span></th>
								<th><span class="innerDetailLabel">Label</span></th>
								<th><span class="innerDetailLabel">Remarks</span></th>
							</tr>
							<cfloop query="mPart">
								<tr>
									<td>
										#part_modifier# #part_name#
									</td>
									<td>#part_condition#</td>
									<td>#part_disposition#</td>
									<td>#lot_count#</td>
									<td>#label#</td>
									<td>#part_remarks#</td>
								</tr>
								<cfquery name="sPart" dbtype="query">
									select * from parts where sampled_from_obj_id=#part_id#
								</cfquery>
								<cfloop query="sPart">
									<tr>
										<td>
											&nbsp;&nbsp;&nbsp;
											#part_modifier# #part_name#
										</td>
										<td>#part_condition#</td>
										<td>#part_disposition#</td>
										<td>#lot_count#</td>
										<td>#label#</td>
										<td>#part_remarks#</td>
									</tr>
								</cfloop>
							</cfloop>
						</table>
					</span>
				</div>
			</div>
	
<!------------------------------------ preparators ---------------------------------------------->
			<cfif #len(preps.preparators)# gt 0>
				<div class="detailCell">
					<div class="detailLabel">Preparators
						<cfif #oneOfUs# is 1>
							<span class="detailEditCell" onclick="window.parent.switchIFrame('editColls');">Edit</span>
						</cfif>
					</div>
					<cfloop query="preps">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel"></span>
								#preparators#
							</span>
						</div>
					</cfloop>
				</div>
			</cfif>
<!------------------------------------ relationships ---------------------------------------------->
			<cfquery name="invRel" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select
					collection.collection,
					cat_num,
					biol_indiv_relations.collection_object_id,
					BIOL_INDIV_RELATIONSHIP
				from 
					biol_indiv_relations,cataloged_item,collection
				where 
					biol_indiv_relations.collection_object_id = cataloged_item.collection_object_id and
					cataloged_item.collection_id = collection.collection_id AND
					RELATED_COLL_OBJECT_ID = #collection_object_id#
			</cfquery>
			<cfif #len(relns.biol_indiv_relationship)# gt 0 OR #len(invRel.biol_indiv_relationship)# gt 0>
				<div class="detailCell">
					<div class="detailLabel">Relationships
						<cfif #oneOfUs# is 1>
							<span class="detailEditCell" onclick="window.parent.switchIFrame('editRelationship');">Edit</span>
						</cfif>
					</div>
					<cfloop query="relns">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">#biol_indiv_relationship#</span>
								<a href="/SpecimenDetail.cfm?collection_object_id=#related_coll_object_id#">
									#related_collection# #related_cat_num#
								</a>
							</span>
						</div>
					</cfloop>
					<cfif #len(relns.biol_indiv_relationship)# gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel"></span>
									&nbsp;&nbsp;&nbsp;<a href="SpecimenResults.cfm?collection_object_id=#valuelist(relns.related_coll_object_id)#" 
											>"Related To" Specimens List</a>										
							</span>
						</div>
					</cfif>
					<cfloop query="invRel">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">#replace(invRel.BIOL_INDIV_RELATIONSHIP," of"," IS","all")#</span>
								<a href="SpecimenDetail.cfm?collection_object_id=#invRel.collection_object_id#" 
									target="_top">#invRel.collection# #invRel.cat_num#</a>
							</span>
						</div>
					</cfloop>
					<cfif #len(invRel.biol_indiv_relationship)# gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel"></span>
								&nbsp;&nbsp;&nbsp;<a href="SpecimenResults.cfm?collection_object_id=#valuelist(invRel.collection_object_id)#" 
											>"Related IS" Specimens List</a>
							</span>
						</div>
					</cfif>
				</div>
			</cfif>
			<cfquery name="isProj" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT project_name, project.project_id project_id FROM 
				project, project_trans
				WHERE 
				project_trans.project_id = project.project_id AND
				project_trans.transaction_id=#detail.accn_id#
				GROUP BY project_name, project.project_id
		  </cfquery>
		  <cfquery name="isLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		  		SELECT project_name, project.project_id FROM 
					loan_item,
					project,
					project_trans
				 WHERE 
				 	loan_item.collection_object_id=#detail.collection_object_id# AND
					loan_item.transaction_id=project_trans.transaction_id AND
					project_trans.project_id=project.project_id		
				GROUP BY 
					project_name, project.project_id
				UNION
				SELECT project_name, project.project_id FROM 
					loan_item,
					project,
					project_trans,
					specimen_part
				 WHERE 
				 	specimen_part.derived_from_cat_item = #detail.collection_object_id# AND
					loan_item.transaction_id=project_trans.transaction_id AND
					project_trans.project_id=project.project_id AND
					specimen_part.collection_object_id = loan_item.collection_object_id	
				GROUP BY 
					project_name, project.project_id		
		</cfquery>
		<cfquery name="isLoanedItem" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			SELECT loan_item.collection_object_id FROM
			loan_item,specimen_part
			WHERE loan_item.collection_object_id=specimen_part.collection_object_id AND
			specimen_part.derived_from_cat_item=#detail.collection_object_id#
			union
			SELECT loan_item.collection_object_id FROM
			loan_item,cataloged_item
			WHERE loan_item.collection_object_id=cataloged_item.collection_object_id AND
			cataloged_item.collection_object_id=#detail.collection_object_id#
		</cfquery>
	
	

		</td>
		<td valign="top" width="50%">
<!------------------------------------ collectors ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">Collectors
					<cfif #oneOfUs# is 1>
						<span class="detailEditCell" onclick="window.parent.switchIFrame('editColls');">Edit</span>
					</cfif>
				</div>
				<cfloop query="colls">
					<div class="detailBlock">
						<span class="detailData">
							<span class="innerDetailLabel"></span>
							#collectors#
						</span>
					</div>
				</cfloop>
			</div>
<!------------------------------------ identifiers ---------------------------------------------->
			<cfquery name="oid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				SELECT 
					case when #oneOfUs# != 1 and 
						concatencumbrances(coll_obj_other_id_num.collection_object_id) like '%mask original field number%' and
						coll_obj_other_id_num.other_id_type = 'original identifier'				
						then 'Masked'
					else
						coll_obj_other_id_num.display_value  
					end display_value,
					coll_obj_other_id_num.other_id_type,
					case when base_url is not null then
						ctcoll_other_id_type.base_url || coll_obj_other_id_num.display_value
					else
						null
					end link
				FROM
					coll_obj_other_id_num,
					ctcoll_other_id_type
				where
					collection_object_id=#one.collection_object_id# and
					coll_obj_other_id_num.other_id_type=ctcoll_other_id_type.other_id_type (+)
				ORDER BY
					other_id_type,
					display_value
			</cfquery>
			<cfif #len(oid.other_id_type)# gt 0>
				<div class="detailCell">
					<div class="detailLabel">Identifiers
						<cfif #oneOfUs# is 1>
							<span class="detailEditCell" onclick="window.parent.switchIFrame('editIdentifiers');">Edit</span>
						</cfif>						
					</div>
						<cfloop query="oid">
							<div class="detailBlock">
								<span class="innerDetailLabel">#other_id_type#:</span>
									<cfif #other_id_type# is "collector number">		
										<!---Adding in GReF code --->
										<cfquery name="gref" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
											select
											  book_section.publication_id,page_id
											from
											  gref_roi_ng, gref_roi_value_ng, book_section
											where
											  book_section.book_id = gref_roi_ng.publication_id
											  and gref_roi_value_ng.id = gref_roi_ng.ROI_VALUE_NG_ID
											  and gref_roi_ng.section_number = book_section.book_section_order
											  and gref_roi_value_ng.collection_object_id = #collection_object_id#
										</cfquery>
										<cfif gref.page_id is not "">
											<!---<cfset isMedia = true>--->
											#display_value# 
													(<a class='external'
href="http://bg.berkeley.edu/gref/session.html?pageId=#gref.page_id#&publicationId=#gref.publication_id#&otherid=#collection_object_id#&otheridtype=collection_object" 
															target="_blank">click here for reference on field notebook page</a>)
										<cfelse>
											#display_value#
										</cfif>
									<cfelse>
										<cfif len(link) gt 0>
											<a class="external" href="#link#" target="_blank">#display_value#</a>
										<cfelse>
											#display_value#
										</cfif>
									</cfif>
								</span>
							</div>
						</cfloop>
				</div>
			</cfif>
<!------------------------------------ attributes ---------------------------------------------->
			<cfif len(attribute.attribute_type) gt 0>
				<div class="detailCell">
					<div class="detailLabel"><!---Attributes--->
						<cfif #oneOfUs# is 1>
							<span class="detailEditCell" onclick="window.parent.switchIFrame('editBiolIndiv');">Edit</span>
						<!---<cfelse>
							<span class="detailEditCell" onclick="getInfo('attributes','#one.collection_object_id#');">Details</span>
						---></cfif>
					</div>
					<cfquery name="sex" dbtype="query">
						select * from attribute where attribute_type = 'sex'
					</cfquery>
					<div class="detailBlock">
						<cfloop query="sex">
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">sex:</span>
									#attribute_value#
									<!--- determination --->
										<cfif len(#attributeDeterminer#) gt 0>
											<cfset determination = "#attributeDeterminer#">
											<cfif len(#determined_date#) gt 0>
												<cfset determination = '#determination#, #dateformat(determined_date,"dd mmm yyyy")#'>
											</cfif>
											<cfif len(#determination_method#) gt 0>
												<cfset determination = '#determination#, #determination_method#'>
											</cfif>
											<div class="detailBlock">
												<span class="detailCellSmall">
													#determination#
												</span>
											</div>
										</cfif>
										
										<cfif len(#attribute_remark#) gt 0>
											<div class="detailBlock">
												<span class="detailCellSmall">
													<span class="innerDetailLabel">Remark:</span>
													#attribute_remark#
												</span>
											</div>
										</cfif>	
								</span>
							</div>
						</cfloop>

					<cfif #one.collection_cde# is "Mamm">
						<cfquery name="total_length" dbtype="query">
							select * from attribute where attribute_type = 'total length'
						</cfquery>
						<cfquery name="tail_length" dbtype="query">
							select * from attribute where attribute_type = 'tail length'
						</cfquery>
						<cfquery name="hf" dbtype="query">
							select * from attribute where attribute_type = 'hind foot with claw'
						</cfquery>
						<cfquery name="efn" dbtype="query">
							select * from attribute where attribute_type = 'ear from notch'
						</cfquery>
						<cfquery name="weight" dbtype="query">
							select * from attribute where attribute_type = 'weight'
						</cfquery>
						<cfquery name="theRest" dbtype="query">
							select * from attribute where attribute_type NOT IN (
								'weight','sex','total length','tail length','hind foot with claw','ear from notch'
								)
						</cfquery>
						<cfif len(#total_length.attribute_units#) gt 0 OR
								len(#tail_length.attribute_units#) gt 0 OR
								len(#hf.attribute_units#) gt 0  OR
								len(#efn.attribute_units#) gt 0  OR
								len(#weight.attribute_units#) gt 0><!---semi-standard measurements --->
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Std. Meas.</span>
									<table border width="100%">
										<tr>
											<td><font size="-1">total length</font></td>
											<td><font size="-1">tail length</font></td>
											<td><font size="-1">hind foot</font></td>
											<td><font size="-1">efn</font></td>
											<td><font size="-1">weight</font></td>
										</tr>
										<tr>
											<td>#total_length.attribute_value# #total_length.attribute_units#&nbsp;</td>
											<td>#tail_length.attribute_value# #tail_length.attribute_units#&nbsp;</td>
											<td>#hf.attribute_value# #hf.attribute_units#&nbsp;</td>
											<td>#efn.attribute_value# #efn.attribute_units#&nbsp;</td>
											<td>#weight.attribute_value# #weight.attribute_units#&nbsp;</td>
										</tr>
									</table>
									<cfif isdefined("attributeDeterminer") and len(#attributeDeterminer#) gt 0>
											<cfset determination = "#attributeDeterminer#">
											<cfif len(#determined_date#) gt 0>
												<cfset determination = '#determination#, #dateformat(determined_date,"dd mmm yyyy")#'>
											</cfif>
											<cfif len(#determination_method#) gt 0>
												<cfset determination = '#determination#, #determination_method#'>
											</cfif>
											<div class="detailBlock">
												<span class="detailCellSmall">
													#determination#
												</span>
											</div>
										</cfif>
								</span>
							</div>
						</cfif>
					<cfelse>
						<cfquery name="theRest" dbtype="query">
							select * from attribute where attribute_type NOT IN ('sex')
						</cfquery>
					</cfif>
					<cfloop query="theRest">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">#attribute_type#:</span>
								#attribute_value# 
								<cfif len(#attribute_units#) gt 0>
									#attribute_units#
								</cfif>
										<cfif len(#attributeDeterminer#) gt 0>
											<cfset determination = "&nbsp;&nbsp;#attributeDeterminer#">
											<cfif len(#determined_date#) gt 0>
												<cfset determination = '#determination#, #dateformat(determined_date,"dd mmm yyyy")#'>
											</cfif>
											<cfif len(#determination_method#) gt 0>,
												<cfset determination = '#determination#, #determination_method#'>
											</cfif>
											<div class="detailBlock">
												<span class="detailCellSmall">
													#determination#
												</span>
											</div>
										</cfif>
									<cfif len(#attribute_remark#) gt 0>
										<div class="detailBlock">
											<span class="detailCellSmall">
												&nbsp;&nbsp;<span class="innerDetailLabel">Remark:</span>
												#attribute_remark#
											</span>
										</div>
									</cfif>	
							</div> 
						</span>
					</cfloop>		
				</div>
			</div>
			</cfif>
<!------------------------------------ cataloged item ---------------------------------------------->
			<div class="detailCell">
				<!---<div class="detailLabel">Cataloged Item</div>--->
				<div class="detailLabel"><!---Attributes--->
					<cfif #oneOfUs# is 1>
						<span class="detailEditCell" onclick="window.parent.switchIFrame('editBiolIndiv');">Edit</span>
					</cfif>
					</div>	
					<cfif #one.coll_object_remarks# is not "">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Remarks:</span>
								#one.coll_object_remarks#
							</span>
						</div>
					</cfif>
					<cfif #oneOfUs# is 1>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Disposition:</span>
								#one.coll_obj_disposition#
							</span>
						</div>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Entered By:</span>
								#one.EnteredBy# on #dateformat(one.coll_object_entered_date,"dd mmm yyyy")#
							</span>
						</div>
						<cfif #one.EditedBy# is not "unknown" OR len(#one.last_edit_date#) is not 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Last Edited By:</span>
									#one.EditedBy# on #dateformat(one.last_edit_date,"dd mmm yyyy")#
								</span>
							</div>
						</cfif>
						<cfif len(#one.flags#) is not 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Missing (flags):</span>
									#one.flags#
								</span>
							</div>
						</cfif>
						<cfif len(#one.encumbranceDetail#) is not 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Encumbrances:</span>
									#replace(one.encumbranceDetail,";","<br>","all")#
								</span>
							</div>
						</cfif>
					</cfif>
				</div>
<!------------------------------------ accession ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">Accession
					<cfif #oneOfUs# is 1>
						<span class="detailEditCell" onclick="window.parent.switchIFrame('addAccn');">Edit</span>
					</cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<cfif #oneOfUs# is 1>
							<a href="editAccn.cfm?Action=edit&transaction_id=#one.accn_id#" target="_blank">#accession#</a>
						<cfelse>
							#accession#
						</cfif>

					</span>
				</div>
			</div>		

<!------------------------------------ Media ---------------------------------------------->
<cfquery name="media" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
    select distinct 
        media.media_id,
        media.media_uri,
        media.mime_type,
        media.media_type,
        media.preview_uri
     from
         media,
         media_relations,
         media_labels
     where
         media.media_id=media_relations.media_id and
         media.media_id=media_labels.media_id (+) and
         media_relations.media_relationship like '%cataloged_item' and
         media_relations.related_primary_key = #collection_object_id#
</cfquery>
<cfif #media.recordcount# gt 0>
    <div class="detailCell">
		<div class="detailLabel">Media
			<cfif #oneOfUs# is 1>
				<span class="detailEditCell" onclick="window.parent.switchIFrame('MediaSearch');">Edit</span>
			</cfif>
		</div>
		<div class="detailBlock">
            <span class="detailData">			
				<table border="1">
                <cfloop query="media">
                    <cfquery name="labels"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select
							media_label,
							label_value
						from
							media_labels
						where
							media_id=#media_id#
					</cfquery>
                    <cfset mrel=getMediaRelations(#media_id#)>
                    <tr>
                        <td align="center" style="font-size:.8em">
                            <cfif len(#preview_uri#) gt 0>
                                <a href="#media_uri#" target="_blank"><img src="#preview_uri#" alt="Media Preview Image"></a>
                                <br>#media_type# (#mime_type#)
                            <cfelse>
                                <cfset h=left(media_uri,40) & "...">
                                <a href="#media_uri#" target="_blank">#h#</a>
                                <br>#media_type# (#mime_type#)
                            </cfif>
                        </td>
                        <td style="font-size:.8em">
                            <cfif #mrel.recordcount# gt 0>
                                Relations:
                                <ul>
	                                <cfloop query="mrel">
	                                    <li>#media_relationship#: #summary#</li>
	                                </cfloop>
                                </ul>
                            </cfif>
                            <cfif #labels.recordcount# gt 0>
                                Labels:
                                <ul>
		                            <cfloop query="labels">
		                                <li>#media_label#: #label_value#</li>
		                            </cfloop>
                                </ul>
                            </cfif>
                        </td>
                    </tr>
                </cfloop>
                </table>
	        </span>		
		</div>
	</div>		
</cfif>
<!------------------------------------ usage ---------------------------------------------->
		<cfif isProj.recordcount gt 0 OR isLoan.recordcount gt 0 or (#oneOfUs# is 1 and #isLoanedItem.collection_object_id# gt 0)>
			<div class="detailCell">
				<div class="detailLabel">Usage</div>
					<cfloop query="isProj">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Contributed By Project:</span>
									<a href="ProjectDetail.cfm?src=proj&project_id=#isProj.project_id#">#isProj.project_name#</a>
							</span>
						</div>
					</cfloop>
					<cfloop query="isLoan">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Used By Project:</span>
		 						<a href="ProjectDetail.cfm?src=proj&project_id=#isLoan.project_id#" target="_mainFrame">#isLoan.project_name#</a>
							</span>
						</div>
					</cfloop>
					<cfif #isLoanedItem.collection_object_id# gt 0 and #oneOfUs# is 1>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Loan History:</span>
									<a href="Loan.cfm?action=listLoans&collection_object_id=#valuelist(isLoanedItem.collection_object_id)#" 
										target="_mainFrame">Click for loan list</a>
							</span>
						</div>
					</cfif>
				</div>
		</cfif>
<!--- Idea scrapped for now.

Adding media block of information. 
3 steps required.
1) Do the query looking for relevant media.
2) If a query detects media, do <cfset isMedia = true> after the query.
	Then the media block will appear.	
3) Output it in the media block below, using cfoutput query="your query"
or cfloop with name="your query".
--Peter DeVore, 20080310
--->
<!---<cfset isMedia = false>--->
<!---<cfif isMedia>
	<cfoutput>
		<div class="detailCell">
			<div class="detailLabel">Media</div>
	</cfoutput>
		<cfloop query="gref">
			<div class="detailBlock">
				<span class="innerDetailLabel">Field Notebook Page:</span>
				<a 
href="http://bg.berkeley.edu/gref/session.html?pageId=#page_id#&publicationId=#publication_id#" 
						target="_blank">click here</a>
			</div>
		</cfloop>
		<!--- Insert here more media in detail blocks here --->
</cfif>
--->
	<!---------------------------------------------------------------------------

	 
	<tr>
		<td colspan="2">
			<div class="isAButton"
			onmouseover="this.className='isAButton btnhov'" 
			onmouseout="this.className='isAButton'"
			onclick="window.parent.switchIFrame('Encumbrances');">
									<strong>Encumbrances</strong>
								</div> 
		</td>
	</tr>
	<cfif len(#encumbrance_action#) gt 0>
			<tr>
				<td align="right">&nbsp;
					
				</td>
			<td>
				#encumbrance_details#
			</td>
		</tr>
		</cfif>
	-------------------------------------------------------------------------------->

		</td><!--- end right half of table --->
</table>
</form>
</cfoutput>
<!----

			
</cfoutput>
</table>
	  </td>
 </tr>
</cfif>
	  
					
		
	
</cfoutput>
</cfif>
	</table>
	---> 
 	
<cf_customizeIFrame>