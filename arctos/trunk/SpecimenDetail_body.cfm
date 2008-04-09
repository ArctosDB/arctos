<cfinclude template="/includes/_frameHeader.cfm">
	<script type='text/javascript' src='/includes/annotate.js'></script>
	<link rel="stylesheet" type="text/css" href="/includes/annotate.css">
<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>
	<cfset oneOfUs = 1>
	<cfset isClicky = "likeLink">
<cfelse>
	<cfset oneOfUs = 0>
	<cfset isClicky = "">
</cfif>
<!---
<cfquery name="detail" datasource = "#Application.web_user#">
	select 
	case when 
		#oneOfUs# != 1 and concatencumbrances(cataloged_item.collection_object_id) like '%record%' then 'masky'
else 'nomasky'
end cmask,
	decode(concatencumbrances(cataloged_item.collection_object_id),
		'%record%','masked',
		'not masked') mask,
	concatencumbrances(cataloged_item.collection_object_id) from cataloged_item where
	collection_object_id in (6237,1,4,2494856)
</cfquery>
--->


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
		coll_obj_other_id_num.other_id_type,
		case when 
			#oneOfUs# != 1 and 
				concatencumbrances(cataloged_item.collection_object_id) like '%mask original field number%' and
				coll_obj_other_id_num.other_id_type = 'original identifier'				
			then 'Masked'
		else
			coll_obj_other_id_num.display_value  
		end display_value,
		attributes.attribute_type,
		attributes.attribute_value,
		attributes.attribute_units,
		attributes.attribute_remark,
		attributes.determination_method,
		attributes.determined_date,
		attribute_determiner.agent_name attributeDeterminer,
		trans.institution_acronym || ' ' || accn_number accession,
		biol_indiv_relations.biol_indiv_relationship, 
		biol_indiv_relations.related_coll_object_id,
		related_cat_item.cat_num related_cat_num,
		related_coll.collection as related_collection,
		specimen_part.collection_object_id part_id,
		specimen_part.part_name,
		specimen_part.part_modifier,
		specimen_part.sampled_from_obj_id,
		specimen_part.preserve_method,
		specimen_part.is_tissue,
		part_object.coll_obj_disposition part_disposition,
		part_object.condition part_condition,
		part_object.lot_count,
		concatencumbrances(cataloged_item.collection_object_id) concatenatedEncumbrances,
		concatEncumbranceDetails(cataloged_item.collection_object_id) encumbranceDetail,
		locality.locality_remarks,
		verbatim_locality	
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
		coll_obj_other_id_num,
		attributes,
		preferred_agent_name attribute_determiner,
		accn,
		trans,
		biol_indiv_relations,
		cataloged_item related_cat_item,
		collection related_coll,
		specimen_part,
		coll_object part_object
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
		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
		coll_object.entered_person_id = enteredPerson.agent_id AND
		coll_object.last_edited_person_id = editedPerson.agent_id (+) AND
		cataloged_item.collection_object_id = collector.collection_object_id (+) AND
		collector.agent_id = colls.agent_id (+) AND
		cataloged_item.collection_object_id = preparator.collection_object_id (+) AND	
		preparator.agent_id = preps.agent_id (+) AND
		cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id (+) AND
		cataloged_item.collection_object_id=attributes.collection_object_id (+) AND
		attributes.determined_by_agent_id = attribute_determiner.agent_id (+) and
		cataloged_item.accn_id =  accn.transaction_id  AND
		accn.transaction_id = trans.transaction_id AND
		cataloged_item.collection_object_id = biol_indiv_relations.collection_object_id (+) AND
		biol_indiv_relations.related_coll_object_id = related_cat_item.collection_object_id (+) AND
		related_cat_item.collection_id = related_coll.collection_id (+) and
		cataloged_item.collection_object_id = specimen_part.derived_from_cat_item (+) and
		specimen_part.collection_object_id = part_object.collection_object_id (+) and
	cataloged_item.collection_object_id = #collection_object_id#
	">

<cfquery name="detail" datasource = "#Application.web_user#">
	#preservesinglequotes(detSelect)#
</cfquery>
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
		verbatim_locality
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
		verbatim_locality
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
<cfquery name="oid" dbtype="query">
	SELECT 
		display_value,
		other_id_type
	FROM
		detail
	GROUP BY
		display_value,
		other_id_type
	ORDER BY
		display_value,
		other_id_type
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
						
<cfquery name="parts"  dbtype="query">
	SELECT 
		part_id,
		part_name,
		part_modifier,
		sampled_from_obj_id,
		preserve_method,
		is_tissue,
		part_disposition,
		part_condition,
		lot_count
	FROM
		detail 
	GROUP BY
		part_id,
		part_name,
		part_modifier,
		sampled_from_obj_id,
		preserve_method,
		is_tissue,
		part_disposition,
		part_condition,
		lot_count
	order by
		part_name
</cfquery>




<cfquery name="images" datasource="#Application.web_user#">
	SELECT
		level,
		full_url,
		thumbnail_url,
		subject,
		description,
		aspect
	FROM
		binary_object
	WHERE
		derived_from_cat_item = #collection_object_id#
	connect by prior binary_object.collection_object_id = derived_from_coll_obj
	start with derived_from_coll_obj is null
</cfquery>


<!---
				
				--->
				
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
			<div class="detailCell">
				<div class="detailLabel"><!---Taxonomy--->
					<cfif #oneOfUs# is 1>
						<span class="detailEditCell" onclick="window.parent.switchIFrame('editIdentification');">Edit</span>
					<!---<cfelse>
						<span class="detailEditCell" onClick="getInfo('identification','#one.collection_object_id#');">Details</span>
					---></cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<span class="innerDetailLabel">Identified As:</span>
						<i>#scientific_name#</i>
					</span>
				</div>
				<div class="detailBlock">					
					<span class="detailData">
						<span class="innerDetailLabel">Identifier:</span>
						#valuelist(identifiers.id_by)#
					</span>
				</div>
				<div class="detailBlock">					
					<span class="detailData">
						<span class="innerDetailLabel">Date Identified:</span>
						#dateformat(made_date,"dd mmm yyyy")#
					</span>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<span class="innerDetailLabel">Nature of Identification:</span>
						#nature_of_id#
					</span>
				</div>
				<cfif len(#identification_remarks#) gt 0>
					<div class="detailBlock">
						<span class="detailData">
							<span class="innerDetailLabel">Identification Remarks:</span>
							#identification_remarks#
						</span>
					</div>
				</cfif>
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
				<div class="detailLabel"><!---Locality--->
					<cfif #oneOfUs# is 1>
						<span class="detailEditCell" onclick="window.parent.switchIFrame('specLocality');">Edit</span>
					</cfif>
				</div>
				<cfif len(#one.continent_ocean#) gt 0>						
					<div class="detailBlock">
						<span class="detailData">
							<span class="innerDetailLabel">Continent/Ocean:</span>
							#one.continent_ocean#
						</span>
					</div>
					</cfif>
					<cfif len(#one.sea#) gt 0>						
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Sea:</span>
								#one.sea#
							</span>
						</div>
					</cfif>
					<cfif len(#one.country#) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Country:</span>
								#one.country#
							</span>
						</div>
					</cfif>
					<cfif len(#one.state_prov#) gt 0>						
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">State/Province:</span>
								#one.state_prov#
							</span>
						</div>
					</cfif>
					<cfif len(#one.feature#) gt 0>						
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Feature:</span>
								#one.feature#
							</span>
						</div>
					</cfif>
					<cfif len(#one.county#) gt 0>
							<div class="detailBlock"><span class="detailData">
								<span class="innerDetailLabel">County:</span>
								#one.county#
							</span>
						</div>
					</cfif>
					<cfif len(#one.island_group#) gt 0>						
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Island Group:</span>
								#one.island_group#
							</span>
						</div>
					</cfif>
					<cfif len(#one.island#) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Island:</span>
								#one.island#
							</span>
						</div>
					</cfif>
					<cfif len(#one.quad#) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">USGS Quad:</span>
								#one.quad#
							</span>
						</div>
					</cfif>					
					<cfif len(#one.spec_locality#) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Specific Locality:</span>
								#one.spec_locality#
							</span>
						</div>
					</cfif>
					<cfif #one.verbatim_locality# is not #one.spec_locality#>
						<cfif len(#one.verbatim_locality#) gt 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Verbatim Locality:</span>
									#one.verbatim_locality#
								</span>
							</div>
						</cfif>
					</cfif>					
					<cfif len(#one.locality_remarks#) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Locality Remarks:</span>
								#one.locality_remarks#
							</span>
						</div>
					</cfif>
					<cfif len(#one.habitat_desc#) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">General Habitat:</span>
								#one.habitat_desc#
							</span>
						</div>
					</cfif>
					<cfif len(#one.habitat#) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Microhabitat:</span>
								#one.habitat#
							</span>
						</div>
					</cfif>
					<cfif len(#one.associated_species#) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Associated Species:</span>
								#one.associated_species#
							</span>
						</div>
					</cfif>
					<cfif len(#one.minimum_elevation#) gt 0>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Elevation:</span>
								#one.minimum_elevation# to #one.maximum_elevation# #one.orig_elev_units#
							</span>
						</div>
					</cfif>
					<cfif (len(#verbatimLatitude#) gt 0 and len(#verbatimLongitude#) gt 0)>
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Coordinates:</span>
								#one.VerbatimLatitude# #one.verbatimLongitude#
							</span>
						</div>
						<cfif len(#one.max_error_distance#) gt 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Error:</span>
									#one.max_error_distance# #one.max_error_units#
								</span>
							</div>
						</cfif>
						<cfif len(#one.latLongDeterminer#) gt 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Coordinate Determiner:</span>
									#one.latLongDeterminer#
								</span>
							</div>
						</cfif>
						<cfif len(#one.latLongDeterminedDate#) gt 0>
							<div class="detailBlock">
								<span class="detailData">
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
						</cfif>
						<cfif len(#one.lat_long_remarks#) gt 0>
							<div class="detailBlock">
								<span class="detailData">
									<span class="innerDetailLabel">Coordinate Remarks:</span>
									#one.lat_long_remarks#
								</span>
							</div>
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
					<div class="detailBlock">
						<span class="detailData">
							<span class="innerDetailLabel">Collecting Date:</span>
							#thisDate#
						</span>
					</div>
				</div>
				
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
									<cfif #other_id_type# is "GenBank">
										<a href="http://www.ncbi.nlm.nih.gov:80/entrez/query.fcgi?cmd=search&db=nucleotide&term=#display_value#&doptcmdl=GenBank" 
											target="_blank" 
												>#display_value#</a>
									<cfelseif #cgi.HTTP_HOST# contains "berkeley.edu" and #other_id_type# is "collector number">		
										<!---Adding in GReF code --->
										<cfquery name="gref" datasource="#Application.web_user#">
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
									href="http://bg.berkeley.edu/gref/Client.html?pageId=#gref.page_id#&publicationId=#gref.publication_id#" 
															target="_blank">click here for reference on field notebook page</a>)
										<cfelse>
											#display_value#
										</cfif>
									<cfelse>
										#display_value#
									</cfif>
								</span>
							</div>
						</cfloop>
				</div>
			</cfif>
<!------------------------------------ accession ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">Accession
					<cfif #oneOfUs# is 1>
						<span class="detailEditCell" onclick="window.parent.switchIFrame('addAccn');">Edit</span>
					</cfif>
				</div>
				<div class="detailBlock">
					<span class="detailData">
						<a href="editAccn.cfm?Action=edit&transaction_id=#one.accn_id#" target="#client.target#">#accession#</a>
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
			<cfquery name="invRel" datasource="#Application.web_user#">
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
								<a href="/SpecimenDetail.cfm?collection_object_id=#related_coll_object_id#" target="#client.target#">
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
											target="#client.target#">"Related To" Specimens List</a>										
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
											target="#client.target#">"Related IS" Specimens List</a>
							</span>
						</div>
					</cfif>
				</div>
			</cfif>
			<cfquery name="isProj" datasource="#Application.web_user#">
				SELECT project_name, project.project_id project_id FROM 
				project, project_trans
				WHERE 
				project_trans.project_id = project.project_id AND
				project_trans.transaction_id=#detail.accn_id#
				GROUP BY project_name, project.project_id
		  </cfquery>
		  <cfquery name="isLoan" datasource="#Application.web_user#">
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
		<cfquery name="isLoanedItem" datasource="#Application.web_user#">
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
	
	
<!------------------------------------ usage ---------------------------------------------->
		<cfif isProj.recordcount gt 0 OR isLoan.recordcount gt 0 or (#oneOfUs# is 1 and #isLoanedItem.collection_object_id# gt 0)>
			<div class="detailCell">
				<div class="detailLabel">Usage</div>
					<cfloop query="isProj">
						<div class="detailBlock">
							<span class="detailData">
								<span class="innerDetailLabel">Contributed By Project:</span>
									<a href="ProjectDetail.cfm?src=proj&project_id=#isProj.project_id#" target="#client.target#">#isProj.project_name#</a>
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
		</td>
		<td valign="top" width="50%">
<!------------------------------------ parts ---------------------------------------------->
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
								<th>Part Name</th>
								<th>Condition</th>
								<th>Disposition</th>
								<th>##</th>
								<th>Tiss?</th>
							</tr>
							<cfloop query="parts">
								<tr>
									<td>
										#part_modifier# #part_name#
										<cfif len(#sampled_from_obj_id#) gt 0>&nbsp;subsample</cfif>
									</td>
									<td>#part_condition#</td>
									<td>#part_disposition#</td>
									<td>#lot_count#</td>
									<td><cfif #is_tissue# is 1>yes<cfelse>no</cfif></td>
								</tr>
							</cfloop>
						</table>
					</span>
				</div>
			</div>
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
									<span class="innerDetailLabel">Sex:</span>
									#attribute_value#
										<span class="detailCellSmall">
										<!---<cfif len(#attributeDeterminer#) gt 0>
											<div class="detailBlock">
												<span class="detailData">
													&nbsp;&nbsp;<span class="innerDetailLabel">Determined By:</span>
													#attributeDeterminer#
												</span>
											</div>
										</cfif>
										<cfif len(#determination_method#) gt 0>
											<div class="detailBlock">
												<span class="detailData">
													&nbsp;&nbsp;<span class="innerDetailLabel">Determination Method:</span>
													#determination_method#
												</span>
											</div>
										</cfif>
										<cfif len(#determined_date#) gt 0>
											<div class="detailBlock">
												<span class="detailData">
													&nbsp;&nbsp;<span class="innerDetailLabel">Determination Date:</span>
													#dateformat(determined_date,"dd mmm yyyy")#
												</span>
											</div>
										</cfif>--->
										<cfif len(#attributeDeterminer#) gt 0>
											<cfset determination = "#attributeDeterminer#">
											<cfif len(#determined_date#) gt 0>
												<cfset determination = '#determination#, #dateformat(determined_date,"dd mmm yyyy")#'>
											</cfif>
											<cfif len(#determination_method#) gt 0>,
												<cfset determination = '#determination#, #determination_method#'>
											</cfif>
											<div class="detailBlock">
												<span class="detailData">
													#determination#
												</span>
											</div>
										</cfif>
										
										<cfif len(#attribute_remark#) gt 0>
											<div class="detailBlock">
												<span class="detailData">
													&nbsp;&nbsp;<span class="innerDetailLabel">Remark:</span>
													#attribute_remark#
												</span>
											</div>
										</cfif>	
									</span>	
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
								<span class="detailCellSmall">
										<cfif len(#attributeDeterminer#) gt 0>
											<cfset determination = "#attributeDeterminer#">
											<cfif len(#determined_date#) gt 0>
												<cfset determination = '#determination#, #dateformat(determined_date,"dd mmm yyyy")#'>
											</cfif>
											<cfif len(#determination_method#) gt 0>,
												<cfset determination = '#determination#, #determination_method#'>
											</cfif>
											<div class="detailBlock">
												<span class="detailData">
													#determination#
												</span>
											</div>
										</cfif>
									<cfif len(#attribute_remark#) gt 0>
										<div class="detailBlock">
											<span class="detailData">
												&nbsp;&nbsp;<span class="innerDetailLabel">Remark:</span>
												#attribute_remark#
											</span>
										</div>
									</cfif>	
								</span>
							</div> 
						</span>
					</cfloop>		
				</div>
			</div>
			</cfif>
<!------------------------------------ cataloged item ---------------------------------------------->
			<div class="detailCell">
				<div class="detailLabel">Cataloged Item</div>
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
<!------------------------------------ binary objects ---------------------------------------------->
			<cfif #images.recordcount# gt 0>
				<div class="detailCell">
					<div class="detailLabel">Binary Objects
						<cfif #oneOfUs# is 1>
							<span class="detailEditCell" onclick="window.parent.switchIFrame('editImages');">Edit</span>
						</cfif>						
					</div>
					<cfloop query="images">
						<cfif #full_url# contains #Application.ServerRootUrl#>
							<!--- get filesize --->
							<cfset thisImgFile = "#Application.webDirectory##right(full_url,len(full_url) - len(Application.serverRootUrl))#">
							<!--- how the server gets to the image --->
							<cfset imgDir = #left(thisImgFile,len(thisImgFile) - find("/",reverse(thisImgFile)))#>
							<!--- directory the image is in --->
							<cfset thisFileName = #right(thisImgFile,find("/",reverse(thisImgFile))-1)#>
							<!--- name of the file - everything after the last / in full_url ---->
							<cfset thisExtension = #right(thisImgFile,find(".",reverse(thisImgFile)))#>
							<!--- grab the extension, just cuz we can --->
							<cfset thisRelativePath = replace(full_url,Application.serverRootUrl,"")>
							<cfset thisRelativePath = replace(thisRelativePath,thisFileName,"")>
							<cfdirectory action="list" name="thisDir" directory="#imgDir#" filter="#thisFileName#">
							<cfset thisAspect = #aspect#>
							<cfif #thisDir.size# gt 0>
								<cfset sizeInK = #round(thisDir.size / 1024)#>
								<cfset sizeInK="#sizeInK#&nbsp;K&nbsp;#thisExtension#">
							<cfelse>
								<cfset sizeInK='unknown K'>
							</cfif>
						<cfelse>
							<cfset sizeInK='external link'>
						</cfif>
						<div class="detailBlock">
							<span class="innerDetailLabel"></span>
								<cfset thisPad = (level - 1) * 50>
								<div style="padding-left:#thisPad#px;">
									<cfif len(#thumbnail_url#) gt 0>
										<a href="#images.full_url#"  target="_blank">
											<img src="#thumbnail_url#" alt="#description#"></a>
									<cfelse>
										<a href="#images.full_url#"  target="_blank">
											<img src="/images/noThumb.jpg" alt="#description#"></a>
									</cfif>
									<span style="font-size:small"><br>#description# (#sizeInK#)</span>
								</div>
							</span>
						</cfloop>
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
href="http://bg.berkeley.edu/gref/Client.html?pageId=#page_id#&publicationId=#publication_id#" 
						target="_blank">click here</a>
			</div>
		</cfloop>
		<!--- Insert here more media in detail blocks here --->
</cfif>--->
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