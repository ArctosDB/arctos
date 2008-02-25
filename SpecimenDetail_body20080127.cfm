<cfinclude template="/includes/_frameHeader.cfm">
	<script type='text/javascript' src='/includes/annotate.js'></script>
	<link rel="stylesheet" type="text/css" href="/includes/annotate.css">
	
<cfset detSelect = "
	SELECT DISTINCT
		collection.institution_acronym,
		geog_auth_rec.geog_auth_rec_id,
		collecting_event.collecting_event_id,	
		cataloged_item.cat_num,
		cataloged_item.collection_object_id as collection_object_id,
		cataloged_item.collection_cde,
		identification.scientific_name,
		identification_remarks,
		identification_id,
		locality.locality_id,
		continent_ocean,
		country,
		state_prov,
		quad,
		county,
		island,
		island_group,
		minimum_elevation,
		maximum_elevation,
		orig_elev_units,
		spec_locality,
		coll_object_remarks,
		verbatim_date,
		BEGAN_DATE,
		ended_date,
		sea,
		feature,
		identification.made_date,
		concatidagent(identification.identification_id) id_by,
		colls.agent_name as colls,
		nature_of_id,
		coll_object.coll_obj_disposition,
		coll_object.coll_object_entered_date,
		coll_object.last_edit_date,
		enteredPerson.agent_name EnteredBy,
		editedPerson.agent_name EditedBy,
		other_id_type,
		display_value,
		colls.agent_name as collector,
		collector_role,
		coll_order,
		type_status,
		occurs_page_number,
		cited_taxa.scientific_name as cited_name,
		cited_taxa.taxon_name_id as cited_name_id,	
		publication.publication_id,
		concatparts(cataloged_item.collection_object_id) partString,
		biol_indiv_relationship as relationship, 
		related_coll_object_id,
		related_cat_item.cat_num as related_cat_num,
		related_cat_item.collection_cde as related_collection_cde,
		concatEncumbrances(cataloged_item.collection_object_id) encumbrance_action,
		concatEncumbranceDetails(cataloged_item.collection_object_id) encumbrance_details,
		cataloged_item.accn_id,
		attribute_type,
		attribute_value,
		attribute_units,
		attribute_remark,
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
		dec_lat,
		dec_long,
		max_error_distance,
		max_error_units,
		trans.INSTITUTION_ACRONYM || ' ' || 
			accn_number
			AS accession,
		latLongDeterminer.agent_name lat_long_determiner,
			ACCEPTED_LAT_LONG.determined_date latLongDeterminedDate,
			lat_long_ref_source,
			lat_long_remarks,
			habitat_desc,
			associated_species,
			habitat,
			flags
	FROM 
		collection,
		cataloged_item,
		identification,
		taxonomy cited_taxa,
		collecting_event,
		locality,
		geog_auth_rec,
		coll_object_remark,
		preferred_agent_name colls,
		Coll_object,
		coll_obj_other_id_num,
		collector,
		formatted_publication,
		publication,
		citation,
		biol_indiv_relations,
		cataloged_item related_cat_item,
		attributes,
		accepted_lat_long,
			accn,
			trans,
			preferred_agent_name latLongDeterminer,
			preferred_agent_name enteredPerson,
			preferred_agent_name editedPerson
	WHERE 
		cataloged_item.collection_id = collection.collection_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		collecting_event.locality_id = locality.locality_id  AND
		Cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
		cataloged_item.collection_object_id = citation.collection_object_id (+) AND
		citation.cited_taxon_name_id = cited_taxa.taxon_name_id (+) AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.accepted_id_fg = 1 AND
		coll_object.collection_object_id = cataloged_item.collection_object_id AND
		cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id (+) AND
		cataloged_item.collection_object_id = collector.collection_object_id AND
		collector.agent_id = colls.agent_id AND
		cataloged_item.collection_object_id = citation.collection_object_id (+) AND
		citation.publication_id = publication.publication_id (+) AND
		citation.publication_id = formatted_publication.publication_id (+) AND
		cataloged_item.collection_object_id = biol_indiv_relations.collection_object_id (+) AND
		biol_indiv_relations.related_coll_object_id = related_cat_item.collection_object_id (+) AND
		cataloged_item.collection_object_id=attributes.collection_object_id (+) AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		accepted_lat_long.determined_by_agent_id = latLongDeterminer.agent_id (+) AND
		cataloged_item.accn_id =  accn.transaction_id  AND
		accn.transaction_id = trans.transaction_id AND
		coll_object.entered_person_id = enteredPerson.agent_id (+) AND
		coll_object.last_edited_person_id = editedPerson.agent_id (+) AND
		cataloged_item.collection_object_id = #collection_object_id#
	ORDER BY
		cat_num">

<cfquery name="detail" datasource = "#Application.web_user#">
	#preservesinglequotes(detSelect)#
</cfquery>
<cfquery name="colls"  dbtype="query">
	SELECT 
		collector,
		encumbrance_action
	FROM 
		detail
	WHERE
		collector_role='c' 
	ORDER BY 
		coll_order,
		collector
</cfquery>
<cfquery name="preps"  dbtype="query">
	SELECT 
		collector,
		encumbrance_action
	FROM
		detail
	WHERE
		collector_role='p' 
	ORDER BY 
		coll_order,
		collector
</cfquery>
<cfquery name="relns"  dbtype="query">
	SELECT 
		related_coll_object_id 
	FROM
		detail 
	GROUP BY
		related_coll_object_id
</cfquery>
<cfquery name="attribute"  dbtype="query">
	SELECT 
		attribute_type,
		attribute_value,
		attribute_units,
		attribute_remark
	FROM
		detail 
	GROUP BY
		attribute_type,
		attribute_value,
		attribute_units,
		attribute_remark
</cfquery>

<cfquery name="oid" dbtype="query">
	SELECT 
		display_value,
		other_id_type,
		encumbrance_action
	FROM
		detail
	GROUP BY
		display_value,
		other_id_type,
		encumbrance_action
	ORDER BY
		display_value,
		other_id_type
</cfquery>
<cfquery name="citations" dbtype="query">
	SELECT 
		publication_id,
		cited_name,
		type_status,
		cited_name_id,
		occurs_page_number
	FROM
		detail 
	GROUP BY
		publication_id,
		cited_name,
		type_status,
		cited_name_id,
		occurs_page_number
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
<cfoutput query="detail" group="cat_num">
<form name="editStuffLinks" method="post" action="SpecimenDetail.cfm">
	<input type="hidden" name="collection_object_id" value="#detail.collection_object_id#">
	<input type="hidden" name="content_url" value="#content_url#">
	<input type="hidden" name="suppressHeader" value="true">
	<input type="hidden" name="action" value="nothing">
	<input type="hidden" name="Srch" value="Part">
	<input type="hidden" name="collecting_event_id" value="#detail.collecting_event_id#">
<table width="95%" cellpadding="0" cellspacing="0"><!---- full page table ---->
	<tr>
		<td valign="top" width="50%" align="center">
			<table><!--- left column --->
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
					<tr>
						<td colspan="2">
							<div class="isAButton"
								onmouseover="this.className='isAButton btnhov'" 
								onmouseout="this.className='isAButton'"
								onclick="window.parent.switchIFrame('editIdentification');"
							>
								<strong>Taxonomic Determination</strong>
							</div>
						</td>
					</tr>
					<tr>
						<td align="right"><b>ID By:</b></td>
						<td>#id_by#</td>
					</tr>
					<tr>
						<td align="right"><b>ID Date:</b></td>
						<td>#dateformat(made_date,"dd mmm yyyy")#</td>
					</tr>
					<tr>
						<td align="right" nowrap><b>Nature of ID:</b></td>
						<td>#nature_of_id#</td>
					</tr>
					<cfif len(#identification_remarks#) gt 0>
						<tr>
							<td align="right" nowrap><b>ID Remark:</b></td>
							<td>#identification_remarks#</td>
						</tr>
					</cfif>
				</cfif>
<!------------------------------------ accession ---------------------------------------------->
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
<tr>
	<td colspan="2">
		<div class="isAButton"
			onmouseover="this.className='isAButton btnhov'" 
			onmouseout="this.className='isAButton'"
			onclick="window.parent.switchIFrame('addAccn');">
				<strong>Accession</strong>
		</div>   			
	</td>
</tr>
<tr>
	<td colspan="2">
		<a href="editAccn.cfm?Action=edit&transaction_id=#accn_id#" target="#client.target#">#accession#</a>
	</td>
</tr>
</cfif>			
</cfoutput>
<!------------------------------------------------- citations ------------------------------------------>
<cfif len(#citations.cited_name#) gt 0>  
	<TR>
		<td colspan="2">
			<div class="isAButton">
				<strong>Citations</strong>
			</div>
		</td>
	</TR>
	<tr>
		<td colspan="2">
			<cfoutput query="citations">
				<cfquery name="formPub" datasource="#Application.web_user#">
					SELECT
						formatted_publication 
					FROM
						formatted_publication
					WHERE 
						publication_id = #publication_id# AND 
						format_style = 'author-year'
				</cfquery>
				<a href="PublicationResults.cfm?publication_id=#publication_id#" 
					target="_mainFrame">
					#formPub.formatted_publication#</a>, page #occurs_page_number#, #type_status#</a>
					 as <a href="TaxonomyDetails.cfm?taxon_name_id=#cited_name_id#" target="_mainFrame"><i>#replace(cited_name," ","&nbsp;","all")#</i></a>
					<br>
			</cfoutput>
		</td>
	</tr>
</cfif> 
<!--------------- locality, lat_long, geog ---------------------------------------->		
<cfoutput query="detail" group="cat_num">
<tr>
	<td colspan="2" nowrap="nowrap">
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
		<div class="isAButton"
			onmouseover="this.className='isAButton btnhov'" 
			onmouseout="this.className='isAButton'"
			onclick="window.parent.switchIFrame('specLocality');">
			<strong>Locality</strong>
		</div>
		<cfelse>
			<div class="isAButton">
				<strong>Locality</strong>
			</div>
		</cfif>
	</td>
</tr>
<tr>
	<td colspan="2">
		<cfset hg="">
		<cfif len(#continent_ocean#) gt 0>
			<cfif len(#hg#) gt 0>
				<cfset hg="#hg#, #continent_ocean#">
			<cfelse>
				<cfset hg="#continent_ocean#">
			</cfif>
		</cfif>
		<cfif len(#sea#) gt 0>
			<cfif len(#hg#) gt 0>
				<cfset hg="#hg#, #sea#">
			<cfelse>
				<cfset hg="#sea#">
			</cfif>
		</cfif>
		<cfif len(#country#) gt 0>
			<cfif len(#hg#) gt 0>
				<cfset hg="#hg#, #country#">
			<cfelse>
				<cfset hg="#country#">
			</cfif>
		</cfif>
		<cfif len(#state_prov#) gt 0>
			<cfif len(#hg#) gt 0>
				<cfset hg="#hg#, #state_prov#">
			<cfelse>
				<cfset hg="#state_prov#">
			</cfif>
		</cfif>
		<cfif len(#feature#) gt 0>
			<cfif len(#hg#) gt 0>
				<cfset hg="#hg#, #feature#">
			<cfelse>
				<cfset hg="#feature#">
			</cfif>
		</cfif>
		<cfif len(#county#) gt 0>
			<cfif len(#hg#) gt 0>
				<cfset hg="#hg#, #county#">
			<cfelse>
				<cfset hg="#county#">
			</cfif>
		</cfif>
		<cfif len(#island_group#) gt 0>
			<cfif len(#hg#) gt 0>
				<cfset hg="#hg#, #island_group#">
			<cfelse>
				<cfset hg="#island_group#">
			</cfif>
		</cfif>
		<cfif len(#island#) gt 0>
			<cfif len(#hg#) gt 0>
				<cfset hg="#hg#, #island#">
			<cfelse>
				<cfset hg="#island#">
			</cfif>
		</cfif>
		<cfif len(#quad#) gt 0>
			<cfif len(#hg#) gt 0>
				<cfset hg="#hg#, #quad# Quad">
			<cfelse>
				<cfset hg="#quad# Quad">
			</cfif>
		</cfif>
		#hg#
		<br><em>#spec_locality#</em>
	</td>
</tr>
<cfif len(#habitat#) gt 0>
  	<tr>
		<td align="right">
			Habitat:
		</td>
		<td>#habitat#</td>
	</tr>
</cfif>
<cfif len(#habitat_desc#) gt 0>
	<tr>
		<td align="right">
			General Habitat:
		</td>
		<td>#habitat_desc#</td>
	</tr>
</cfif>
<cfif len(#associated_species#) gt 0>
  	<tr>
		<td align="right">
				Associated Species:
			</td>
			<td>#associated_species#</td>
		</tr>
	  </cfif>
	 
<cfif #minimum_elevation# is not "">
<tr>	
	<td align="right">
		<b>Elevation:</b>
	</td>
	<td>
		#minimum_elevation# to #maximum_elevation# #orig_elev_units#
	</td>
</tr>
</cfif>

<cfif (len(#verbatimLatitude#) gt 0 and len(#verbatimLongitude#) gt 0)>
<tr>
	<td align="right">
		<b>Lat/Long:</b>
	</td>
	<td>	
		<cfif #encumbrance_action# does not contain "coordinates" OR
							(isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user"))>					
		
				#VerbatimLatitude# #verbatimLongitude# 
					<cfif #max_error_distance# gt 0>
						&##177; #max_error_distance# #max_error_units#
					</cfif>
					<span class="infoLink" onClick="getInfo('lat_long','#locality_id#');">
						Details			  			
					</span>
		<cfelse>
			Coordinates masked.
		</cfif>
	</td>
</tr>
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
		<tr>
			<td align="right"><b>Determined By:</b></td>
			<td>
			<cfif len(#latLongDeterminedDate#) gt 0>
				<cfset llDate = #dateformat(latLongDeterminedDate,"dd mmm yyyy")#>
			<cfelse>
				<cfset llDate = "unknown">
			</cfif>
			#lat_long_determiner# <em>on</em> #llDate# <em>using</em> #lat_long_ref_source#
			</td>
		</tr>
		<cfif len(#lat_long_remarks#) gt 0>
		<tr>
			<td align="right" valign="top"><b>Remarks:</b></td>
			<td>#lat_long_remarks#</td>
			
		</tr>
		</cfif>
	</cfif>
</cfif>
<tr>
	<td align="right" valign="top" nowrap>
		<b>Collecting Date:</b>
	</td>
	<td>
		<cfif #encumbrance_action# does not contain "year collected" OR
							(isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user"))>					
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
		<Cfelse>
			<cfif #began_date# is #ended_date#>
				<cfset thisDate = #dateformat(began_date,"dd mmm 8888")#>
			<cfelse>
				<cfset thisDate = '#dateformat(began_date,"dd mmm 8888")#-&nbsp;#dateformat(ended_date,"dd mmm 8888")#'>
			</cfif>
			
		</cfif>
			#thisDate#
	</td>
</tr>
</cfoutput>
<!------------------------------ collectors ------------------------>
<tr>
	<td colspan="2">
	<cfoutput>
		<div class="isAButton"
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
			onmouseover="this.className='isAButton btnhov'" 
			onmouseout="this.className='isAButton'"
			onclick="window.parent.switchIFrame('editColls');"
			</cfif>
			>
									<strong>Collectors</strong>
								</div> 
	</cfoutput>
	</td>
</tr>
<tr>
	<td colspan="2" valign="top">
		<cfoutput query="colls" group="collector">
			<cfif #encumbrance_action# does not contain 'mask collector' 
				OR (isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user"))>					
				#collector#<br>
			<cfelse>
				Anonymous<br>
		  </cfif>
		</cfoutput>
	</td>
</tr>
<cfif len(#preps.collector#) gt 0>
						<tr>
							<td colspan="2">
								<div class="isAButton">
									<strong>Preparators</strong>
								</div>
							</td>
						</tr>
	<tr>
<td colspan="2">
<cfoutput query="preps" group="collector">
	<cfif  #encumbrance_action# does not contain 'mask preparator'
		OR ( isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user"))>					
			#collector#<br>
	<cfelse>
			Anonymous<br>
 </cfif>
</cfoutput>
	</td>
	</tr>
</cfif>
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
<cfoutput>
		<tr>
	<td colspan="2">

		<div class="isAButton"
			onmouseover="this.className='isAButton btnhov'" 
			onmouseout="this.className='isAButton'"
			onclick="window.parent.switchIFrame('editRelationship');">
									<strong>Relationships</strong>
								</div> 
		
	</td>
</tr>
		</cfoutput>
<cfelseif len(#relns.related_coll_object_id#) gt 0>
	<tr>
	<td colspan="2">

	<div class="isAButton">
									<strong>Relationships</strong>
								</div> 
	</td>
</tr>
</cfif>
<cfif len(#relns.related_coll_object_id#) gt 0>
<tr>
	<td colspan="2">
	<cfset relatedCollObjList = "">
	<cfoutput>
		<table width="75%" border="0" >
			<cfloop query="relns">
				<cfquery name="related_details" dbtype="query">
					select relationship, related_collection_cde, related_cat_num from detail where 
					related_coll_object_id = #relns.related_coll_object_id#
				</cfquery>
				<tr>
					<td align="right"><strong>#related_details.relationship#</strong></td>
					<td><a href="SpecimenDetail.cfm?collection_object_id=#relns.related_coll_object_id#" 
								target="_top">#related_details.related_collection_cde# #related_details.related_cat_num#</a>
								</td>
				</tr>
				<cfif len(#relatedCollObjList#) is 0>
									<cfset relatedCollObjList = "#relatedCollObjList##relns.related_coll_object_id#">
								<cfelse>
									<cfset relatedCollObjList = "#relatedCollObjList#,#relns.related_coll_object_id#">
								</cfif>
			</cfloop>
		</table>
	</cfoutput>
<cfif #relns.recordcount# gt 1>
<tr>
	<td colspan="2">
		<cfoutput>
							<a href="SpecimenResults.cfm?collection_object_id=#relatedCollObjList#" target="#client.target#">Related Specimens List</a>
							</cfoutput>
	</td>
</tr>
</cfif>
</td>
</tr>
</cfif>
<cfquery name="invRel" datasource="#Application.web_user#">
			select 
			institution_acronym,
			collection.collection_cde,
			cat_num,
			biol_indiv_relations.collection_object_id,
			BIOL_INDIV_RELATIONSHIP from 
			biol_indiv_relations,cataloged_item,collection
			where 
			biol_indiv_relations.collection_object_id = cataloged_item.collection_object_id and
			cataloged_item.collection_id = collection.collection_id AND
			RELATED_COLL_OBJECT_ID = #collection_object_id#
		</cfquery>
<cfif #invRel.recordcount# gt 0>
	<tr>
		<td colspan="2">
		<cfoutput>
			<table>
				<tr>
					<td colspan="2">
						Related to This Specimen
					</td>
					<cfloop query="invRel">
						<tr>
							<td align="right"><strong>#replace(invRel.BIOL_INDIV_RELATIONSHIP," of"," IS","all")#</strong></td>
							<td><a href="SpecimenDetail.cfm?collection_object_id=#invRel.collection_object_id#" 
								target="_top">#invRel.institution_acronym# #invRel.collection_cde# #invRel.cat_num#</a>
								</td>
			
						</tr>
					</cfloop>
				</tr>
			</table>
		</cfoutput>
		</td>
	</tr>
</cfif>
<!---- see if this specimen belongs to any projects --->
  <cfoutput>
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
  
 <cfif isProj.recordcount gt 0>
<tr>
	<td colspan="2">
		<div class="isAButton">
			<strong>Projects</strong>
		</div>
	</td>
</tr>
  <tr>
  	<td align="right" valign="top" nowrap>
		<b>Contributed By:</b>
	</td>
	<td>
		<cfif #isProj.recordcount# gt 1>
			<ul>
			<cfloop query="isProj">
			<li>
				 <a href="ProjectDetail.cfm?src=proj&project_id=#isProj.project_id#" target="#client.target#">#isProj.project_name#</a>
			</li>
			</cfloop>
			</ul>
		<cfelse>
			<a href="ProjectDetail.cfm?src=proj&project_id=#isProj.project_id#" target="#client.target#">#isProj.project_name#</a>
		</cfif>
	</td>
  </tr>
  </cfif>
  <cfif isLoan.recordcount gt 0>
  <tr>
  	<td align="right" valign="top">
		<b>Used By:</b>
	</td>
	<td>
	<cfif #isLoan.recordcount# gt 1>
		<ul>
		<cfloop query="isLoan">
		 <li>
		 <a href="ProjectDetail.cfm?src=proj&project_id=#isLoan.project_id#" target="_mainFrame">#isLoan.project_name#</a><br>
			</li>
		</cfloop>
		</ul>
	<cfelse>
		<a href="ProjectDetail.cfm?src=proj&project_id=#isLoan.project_id#" target="_mainFrame">#isLoan.project_name#</a><br>
	</cfif>
	</td>
  </tr>
  </cfif>
  </cfoutput>
</table>
</td>
<td valign="top" align="center" width="50%"><!---- cell for right table --->
<table><!---- right table ---->
<tr>
	<td colspan="2" >
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
	<cfoutput>
			<div class="HalfAButton"
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
			onmouseover="this.className='HalfAButton btnhov'" 
			onmouseout="this.className='HalfAButton'"
			onclick="window.parent.switchIFrame('editParts');"
			</cfif>
			>
									<strong>Parts</strong>
								</div> 
			<div class="HalfAButton"
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
			onmouseover="this.className='HalfAButton btnhov'" 
			onmouseout="this.className='HalfAButton'"
			onclick="window.parent.switchIFrame('Container');"
			</cfif>
			>
									<strong>Part Locations</strong>
								</div> 
								
					
						</cfoutput>
			<cfelse>
		<div class="isAButton">
									<strong>Parts:</strong>
								</div>
	</cfif>
	</td>
</tr>
<tr>	
	<td colspan="2">
	
								<cfoutput>
								#detail.partString#
		<span class="infoLink" onClick="getInfo('parts','#detail.collection_object_id#');">
			Details			  			
		</span>
		</cfoutput>
	</td>
 </tr>
<cfoutput>
		<tr>
			<td colspan="2" nowrap>
	<div class="isAButton"
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
			onmouseover="this.className='isAButton btnhov'" 
			onmouseout="this.className='isAButton'"
			onclick="window.parent.switchIFrame('editBiolIndiv');"
			</cfif>
			><strong>Individual Attributes</strong>
									</div>
	
			</td>
		</tr>
	<cfif #attribute.recordcount# gt 0>
	<tr>
		<td></td>
		<td align="right">
			
		</td>
	</tr>
		<cfif #detail.collection_cde# is "Mamm">
								<cfquery name="sex" dbtype="query">
									select * from attribute where attribute_type = 'sex'
								</cfquery>
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
								<tr>
									<td align="right"><b>Sex:</b></td>
									<td>
									
		#sex.attribute_value#
		<span class="likeLink" onClick="getInfo('attributes','#detail.collection_object_id#');">
			Details
		</span>
		</td>
								</tr>
								
									<cfif len(#total_length.attribute_units#) gt 0 OR
										len(#tail_length.attribute_units#) gt 0 OR
										len(#hf.attribute_units#) gt 0  OR
										len(#efn.attribute_units#) gt 0  OR
										len(#weight.attribute_units#) gt 0><!---semi-standard measurements --->
									<tr>
									<td align="right"><b>Standard Measurements:</b></b></td>
									<td>
										
		<table border>
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
										
										</td>
									</tr>
									</cfif>
									<cfloop query="theRest">
									<cfif len(#theRest.attribute_type#) gt 0>
										<tr>
											<td align="right">
												<b>#replace(theRest.attribute_type," ","&nbsp;","all")#:</b>
											</td>
											<td width="100%">
											
												#theRest.attribute_value# 
												#theRest.attribute_units#
												<cfif len(#theRest.attribute_remark#) gt 0>
													<br>
													<font size="-1"><i>#theRest.attribute_remark#</i></font>
												</cfif> 
												
											</td>
										</tr>
									</cfif>
								</cfloop>
									
									</td>
											
											</tr>
											
								<cfelse>
								<cfset i=1>
								<cfloop query="attribute">
		<cfif len(#attribute.attribute_type#) gt 0>
			<tr>
			<td align="right">
			<b>#attribute.attribute_type#</b>
			:</td>
			<td>
				#attribute.attribute_value# #attribute.attribute_units# 
				<span style="font-size:smaller; font-style:oblique;">#attribute.attribute_remark#</span>
				
			<cfif #i# is 1>
				<span class="infoLink" onClick="getInfo('attributes','#detail.collection_object_id#');">
					Details
				</span>
			</cfif>
			
		</td>
		</tr>
		
		</cfif>
		<cfset i=#i#+1>
		</cfloop>
		</cfif>
		
	</cfif>			
	 
	 
	
	</cfoutput>
	 
	 
  	<cfoutput query="detail" group="cat_num">
	 
	 
  	<tr>
  	<cfif #coll_object_remarks# is not "">
   	 <td valign="top" align="right"><b>Remarks:</b></td>
   	 <td>#coll_object_remarks#</td>
	</cfif>
  </tr>
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
  <tr>
    <td align="right"><b>Disposition:</b></td>
    <td>
#coll_obj_disposition#</td>
  </tr>
</cfif>
</cfoutput>
	<tr>
		<td colspan="2">
			<cfoutput>
				<div class="isAButton"
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
						onmouseover="this.className='isAButton btnhov'" 
						onmouseout="this.className='isAButton'"
						onclick="window.parent.switchIFrame('editIdentifiers');"
					</cfif>
				>
					<strong>Identifying Numbers</strong>
				</div> 
			</cfoutput>
			</td>
		</tr>
<cfoutput query="oid">
	<cfif len(#display_value#) gt 0>
		<cfif #other_id_type# is "GenBank">
			<tr>
   				<td valign="top" align="right" nowrap="nowrap">
					<strong>#other_id_type#:</strong>
				</td>
				<td>
					<a href="http://www.ncbi.nlm.nih.gov:80/entrez/query.fcgi?cmd=search&db=nucleotide&term=#display_value#&doptcmdl=GenBank" 
						target="_blank" 
						>#display_value#</a>
				</td>
			</tr>
		<cfelse>
			<cfif #encumbrance_action# contains "mask original field number" 
				AND #other_id_type# is "original field number"
				AND not (isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user"))>					
				<tr>
    				<td valign="top" align="right" nowrap><b>Original field number:</b></td>
					<td>Masked</td>
				</tr>
			<cfelse>
				<tr>
    				<td valign="top" align="right" nowrap><b>#other_id_type#:</b></td>
					<td>#display_value#</td>
				</tr>
			</cfif>
		</cfif>
	</cfif>
</cfoutput>



			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
	<tr>
		<td colspan="2">
			<cfoutput>
				<div class="isAButton" onmouseover="this.className='isAButton btnhov'" 
								onmouseout="this.className='isAButton'"
								onclick="window.parent.switchIFrame('editImages');">
					<strong>Images</strong>
				</div>
			</cfoutput>		
		</td>
	</tr>
</cfif>
 <cfif #images.recordcount# gt 0>
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
   		<tr>
			<td colspan="2">
			 
			 <div class="isAButton">
				<strong>Images</strong>
			</div>
			</td>
		</tr>
  </cfif>
 <tr>
 <td colspan="2">			
 <table>
 <cfoutput query="images">
	<!--- if the files are stored locally.... --->
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
			<cfset sizeInK='unknown'>
		</cfif>
	<cfelse>
		<cfset sizeInK='external link'>
	</cfif>
		<tr>
		<td valign="top">
			<cfset thisPad = (level - 1) * 50>
			<div style="padding-left:#thisPad#px;">
				<cfif len(#thumbnail_url#) gt 0>
					<a href="#images.full_url#"  target="_blank"><img src="#thumbnail_url#" alt="#description#"></a>
				<cfelse>
					<a href="#images.full_url#"  target="_blank"><img src="/images/noThumb.jpg" alt="#description#"></a>
				</cfif>
				<span style="font-size:small"><br>#description# (#sizeInK#)</span>
			</div>
		</td>
		</tr>
</cfoutput>
</table>
	  </td>
 </tr>
</cfif>
	  
					
			<cfif isdefined("client.roles") and listfindnocase(client.roles,"coldfusion_user")>					
 <tr>
	<td colspan="2">
		<div class="isAButton">
			<strong>Curatorial Stuff</strong>
		</div>
	</td>
</tr> 

	<cfoutput query="detail" group="cat_num">
	<tr>
		<td align="right"><b>Entered By:</b></td>
		<td>#EnteredBy# on #dateformat(coll_object_entered_date,"dd mmm yyyy")#</td>
	</tr>
	<cfif #EditedBy# is not "unknown" OR len(#last_edit_date#) is not 0>
		<tr>
			<td align="right"><b>Last Edited By:</b></td>
			<td>#EditedBy# on #dateformat(last_edit_date,"dd mmm yyyy")#</td>
		</tr>
	</cfif>
	<cfif len(#flags#) is not 0>
		<tr>
			<td align="right"><b>Missing:</b></td>
			<td>#flags#</td>
		</tr>
	</cfif>
	<cfquery name="isPartLoan" datasource="#Application.web_user#">
		SELECT loan_item.collection_object_id FROM
		loan_item,specimen_part
		WHERE loan_item.collection_object_id=specimen_part.collection_object_id AND
		specimen_part.derived_from_cat_item=#detail.collection_object_id#
	</cfquery>
	<cfquery name="isCatLoan" datasource="#Application.web_user#">
		SELECT loan_item.collection_object_id FROM
		loan_item,cataloged_item
		WHERE loan_item.collection_object_id=cataloged_item.collection_object_id AND
		cataloged_item.collection_object_id=#detail.collection_object_id#
	</cfquery>
	<cfset loanIDs="0">
	<cfloop query="isPartLoan">
		<cfset loanIDs="#loanIDs#,#isPartLoan.collection_object_id#">
	</cfloop>
	<cfloop query="isCatLoan">
		<cfset loanIDs="#loanIDs#,#isCatLoan.collection_object_id#">
	</cfloop>
	<cfif #loanIDs# is not "0">
	<tr>
		<td align="right"><b>Loan History:</b></td>
		<td>
			<a href="Loan.cfm?action=listLoans&collection_object_id=#loanIDs#" 
				target="_mainFrame">Click for loan list</a>
		</td>
	</tr>	
	</cfif>
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
</cfoutput>
</cfif>
	</table>
 		</td>
		</tr>
</table>
</form>
<cfquery name="getColl" dbtype="query">
	select distinct(collection_cde) from detail
</cfquery>
<cfset coll = valuelist(getColl.collection_cde)>
<cf_log cnt=1 coll=#coll#>
<cf_customizeIFrame>