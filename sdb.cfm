
<cfset detSelect = "
	SELECT DISTINCT
		institution_acronym,
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
		id_agent_name.agent_name as id_by,
		colls.agent_name as colls,
		nature_of_id,
		coll_object.coll_obj_disposition,
		coll_object.coll_object_entered_date,
		coll_object.last_edit_date,
		enteredPerson.agent_name EnteredBy,
		editedPerson.agent_name EditedBy,
		other_id_type,
		other_id_num,
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
		to_number(af_num) af_num,
		accn_num_prefix,
		accn_num,
		accn_num_suffix,
		latLongDeterminer.agent_name lat_long_determiner,
			ACCEPTED_LAT_LONG.determined_date latLongDeterminedDate,
			lat_long_ref_source,
			lat_long_remarks,
			habitat_desc,
			associated_species,
			habitat
	FROM 
		collection,
		cataloged_item,
		identification,
		taxonomy cited_taxa,
		collecting_event,
		locality,
		geog_auth_rec,
		coll_object_remark,
		preferred_agent_name id_agent_name,
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
			af_num,
			accn,
			preferred_agent_name latLongDeterminer,
			preferred_agent_name enteredPerson,
			preferred_agent_name editedPerson
	WHERE 
		cataloged_item.collection_id = collection.collection_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		collecting_event.locality_id = locality.locality_id  AND
		Cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		identification.id_made_by_agent_id = id_agent_name.agent_id AND
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
		cataloged_item.collection_object_id =  af_num.collection_object_id (+) AND
		cataloged_item.accn_id =  accn.transaction_id (+) AND
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
		other_id_num,
		other_id_type,
		encumbrance_action
	FROM
		detail
	ORDER BY
		other_id_num,
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
		full_url,
		subject,
		description,
		aspect
	FROM
		binary_object
	WHERE
		derived_from_cat_item = #collection_object_id#
</cfquery>
<cfset collEventWarning = "Please note that there are TWO collecting event buttons. They do very different things! Edit Coll Event makes CHANGES to a collecting event. This change is effective for this AND ALL OTHER specimens that use that collecting event. Select New Coll Event allows you to select a new collecting event for this specimen, and does not affect any other specimen records.">
<cfoutput query="detail" group="cat_num">
<form name="editStuffLinks" method="post" action="SpecimenDetail.cfm">
	<input type="hidden" name="collection_object_id" value="#detail.collection_object_id#">
	<input type="hidden" name="content_url" value="#content_url#">
	<input type="hidden" name="suppressHeader" value="true">
	<input type="hidden" name="action" value="nothing">
	<input type="hidden" name="Srch" value="Part">
	<input type="hidden" name="collecting_event_id" value="#detail.collecting_event_id#">
<div align="center">
	<table width="95%" cellpadding="0" cellspacing="0"><!---- full page table ---->
	<!--- cell for table --->
		<tr>
			<td valign="top" width="50%" align="center">
				<table><!--- left column --->
					<cfif #client.rights# contains "student1">
						<tr>
							<td colspan="2">
								
									
									<div class="isAButton"
									
										 onmouseover="this.className='isAButton btnhov'" 
										onmouseout="this.className='isAButton'"
										onclick="editStuffLinks.content_url.value='editIdentification.cfm';editStuffLinks.submit();"
										>
									<strong>Identification</strong>
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
</cfif>
<!------------------------------------ accession ---------------------------------------------->
<cfif #client.rights# contains "student1">
							<cfset accn="#accn_num_prefix#.#numberformat(accn_num,000)#">
							<cfif len(#accn_num_suffix#) gt 0>
								<cfset accn="#accn#.#accn_num_suffix#">
							</cfif>
							
<tr>
	<td colspan="2">
		<div class="isAButton"
			onmouseover="this.className='isAButton btnhov'" 
			onmouseout="this.className='isAButton'"
			onclick="editStuffLinks.content_url.value='addAccn.cfm';editStuffLinks.submit();">
									<strong>Accession</strong>
								</div>   			
			</td>
	  </tr>
	<tr>
								
								<td colspan="2">#accn#</td>
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
	<td colspan="2" nowrap>
<cfif #client.rights# contains "student0">
		<div class="HalfAButton"
			onmouseover="this.className='HalfAButton btnhov'" 
			onmouseout="this.className='HalfAButton'"
			onclick="editStuffLinks.action.value='editCollEvnt';editStuffLinks.content_url.value='Locality.cfm';editStuffLinks.submit();">
			<strong>Edit Coll Event</strong>
								</div>   
		<div class="HalfAButton"
			onmouseover="this.className='HalfAButton btnhov'" 
			onmouseout="this.className='HalfAButton'"
			onclick="editStuffLinks.content_url.value='changeCollEvent.cfm';editStuffLinks.submit();">
			<strong>Select New Coll Event</strong>
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
							(isdefined("client.rights") AND #client.rights# contains "student0")>
		
		<a href="javascript:void(0);" 
			onClick="getInfo('lat_long','#locality_id#'); return false;"
			onMouseOver="self.status='Click for Lat/Long Details.';return true;" 
			onmouseout="self.status='';return true;">
				#VerbatimLatitude# #verbatimLongitude# 
					<cfif #max_error_distance# gt 0>
						&##177; #max_error_distance# #max_error_units#
					</cfif>
			</a>
		<cfelse>
			Coordinates masked.
		</cfif>
	
	</td>
</tr>
 
<cfif #client.rights# contains "student0">
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
			
	

</cfoutput>
<!------------------------------ collectors ------------------------>
  			
<tr>
	<td colspan="2">
	
	<cfoutput>
		<div class="isAButton"
			<cfif #client.rights# contains "student0">
			onmouseover="this.className='isAButton btnhov'" 
			onmouseout="this.className='isAButton'"
			onclick="editStuffLinks.content_url.value='editColls.cfm';editStuffLinks.submit();"
			</cfif>
			>
									<strong>Collectors</strong>
								</div> 
	</cfoutput>
	</td>
</tr>

			<tr>
    			<td valign="top" align="right">&nbsp;
					 </td>
	<td>
				<table width="75%" cellpadding="0" cellspacing="0">
  					<tr>
 						<td valign="top">
							<cfoutput query="colls" group="collector">
								<cfif #encumbrance_action# does not contain 'mask collector' 
									OR #client.rights# contains "student0">
									#collector#<br>
								<cfelse>
									Anonymous<br>
							  </cfif>
							</cfoutput>
					  </td>
				  </tr>
		</table>
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
<td align="right">&nbsp;

</td>
<td>
<cfoutput query="preps" group="collector">
	<cfif  #encumbrance_action# does not contain 'mask preparator'
		OR #client.rights# contains "student0">
			#collector#<br>
	<cfelse>
			Anonymous<br>
 </cfif>
</cfoutput>
	</td>
	</tr>
</cfif>
<cfif #client.rights# contains "student0">
<cfoutput>
		<tr>
	<td colspan="2">

		<div class="isAButton"
			onmouseover="this.className='isAButton btnhov'" 
			onmouseout="this.className='isAButton'"
			onclick="editStuffLinks.content_url.value='editRelationship.cfm';editStuffLinks.submit();">
									<strong>Relationships</strong>
								</div> 
		
	</td>
</tr>
		</cfoutput>
<cfelseif #client.rights# does not contain "student0"
	AND len(#relns.related_coll_object_id#) gt 0>
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
</cfif></td>
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

</td>
</tr>
</table>
<td valign="top" align="center" width="50%"><!---- cell for right table --->
<table><!---- right table ---->
<tr>
	<td colspan="2" >
	<cfif #client.rights# contains "student1">
	<cfoutput>
			<div class="HalfAButton"
			<cfif #client.rights# contains "student0">
			onmouseover="this.className='HalfAButton btnhov'" 
			onmouseout="this.className='HalfAButton'"
			onclick="editStuffLinks.content_url.value='editParts.cfm';editStuffLinks.submit();"
			</cfif>
			>
									<strong>Parts</strong>
								</div> 
			<div class="HalfAButton"
			<cfif #client.rights# contains "student0">
			onmouseover="this.className='HalfAButton btnhov'" 
			onmouseout="this.className='HalfAButton'"
			onclick="window.open('Locations.cfm?srch=Part&cat_num=#detail.cat_num#&collection_cde=#detail.collection_cde#', '_blank');"
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
								<a href="javascript:void(0);" 
		onClick="getInfo('parts','#detail.collection_object_id#'); return false;"
		onMouseOver="self.status='Click for Part Details.';return true;" 
		onmouseout="self.status='';return true;">#detail.partString#</a>
		</cfoutput>
								
		
	</td>
	
	  </tr>
<cfoutput>

		<tr>
			<td colspan="2">
	<div class="isAButton"
			<cfif #client.rights# contains "student0">
			onmouseover="this.className='isAButton btnhov'" 
			onmouseout="this.className='isAButton'"
			onclick="editStuffLinks.content_url.value='editBiolIndiv.cfm';editStuffLinks.submit();"
			</cfif>
			>
									<strong>Individual Attributes</strong>
								</div> 
								
			
			</td>
		</tr>
	
	
	
	<cfif #attribute.recordcount# gt 0>
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
									<a href="javascript:void(0);" 
		onClick="getInfo('attributes','#detail.collection_object_id#'); return false;"
		onMouseOver="self.status='Click for Attribute Details.';return true;" 
		onmouseout="self.status='';return true;">
		#sex.attribute_value#
									</a></td>
								</tr>
								
									<cfif len(#total_length.attribute_units#) gt 0 OR
										len(#tail_length.attribute_units#) gt 0 OR
										len(#hf.attribute_units#) gt 0  OR
										len(#efn.attribute_units#) gt 0  OR
										len(#weight.attribute_units#) gt 0><!---semi-standard measurements --->
									<tr>
									<td align="right"><b>Standard Measurements:</b></b></td>
									<td>
										<a href="javascript:void(0);" 
		onClick="getInfo('attributes','#detail.collection_object_id#'); return false;"
		onMouseOver="self.status='Click for Attribute Details.';return true;" 
		onmouseout="self.status='';return true;">
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
										</a>
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
											<a href="javascript:void(0);" 
		onClick="getInfo('attributes','#detail.collection_object_id#'); return false;"
		onMouseOver="self.status='Click for Attribute Details.';return true;" 
		onmouseout="self.status='';return true;">
												#theRest.attribute_value# 
												#theRest.attribute_units#
												<cfif len(#theRest.attribute_remark#) gt 0>
													<br>
													<font size="-1"><i>#theRest.attribute_remark#</i></font>
												</cfif> 
												</a>
											</td>
										</tr>
									</cfif>
								</cfloop>
									
									</td>
											
											</tr>
											
								<cfelse>
								<cfloop query="attribute">
		<cfif len(#attribute.attribute_type#) gt 0>
			<tr>
			<td align="right">
			<a href="javascript:void(0);" 
		onClick="getInfo('attributes','#detail.collection_object_id#'); return false;"
		onMouseOver="self.status='Click for Attribute Details.';return true;" 
		onmouseout="self.status='';return true;"><b>#attribute.attribute_type#</b></a>
			:</td>
			<td>
				<a href="javascript:void(0);" 
		onClick="getInfo('attributes','#detail.collection_object_id#'); return false;"
		onMouseOver="self.status='Click for Attribute Details.';return true;" 
		onmouseout="self.status='';return true;">#attribute.attribute_value# #attribute.attribute_units# #attribute.attribute_remark#</a>
		
			
		</td>
		</tr>
		
		</cfif>
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
  <cfif #client.rights# contains "student0">
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
			<cfif #client.rights# contains "student0">
			onmouseover="this.className='isAButton btnhov'" 
			onmouseout="this.className='isAButton'"
			onclick="editStuffLinks.content_url.value='editIdentifiers.cfm';editStuffLinks.submit();"
			</cfif>
			>
									<strong>Identifying Numbers</strong>
								</div> 
			</cfoutput>
			</td>
		</tr>
	


<cfoutput query="oid" group="other_id_num">


	<cfif len(#other_id_num#) gt 0>
		<cfif #other_id_type# is "GenBank sequence accession">
		<tr>
    <td valign="top" align="right" nowrap><b>#other_id_type#:</b></td>
	<td>
	<a href="http://www.ncbi.nlm.nih.gov:80/entrez/query.fcgi?cmd=search&db=nucleotide&term=#other_id_num#&doptcmdl=GenBank" 
		target="_blank" 
		>#other_id_num#</a>
	</td>
	</tr>
	
		<!---onMouseUp="writeLog('GenBank click','#detail.collection_cde#','1'); return false;"--->
			<cfelse>
				<cfif #encumbrance_action# contains "mask original field number" 
					AND #other_id_type# is "original field number"
					AND #client.rights# does not contain "student0">
					<tr>
    <td valign="top" align="right" nowrap><b>Original field number:</b></td>
	<td>
	Masked
	</td>
	</tr>
					
				<cfelse>
					<tr>
    <td valign="top" align="right" nowrap><b>#other_id_type#:</b></td>
	<td>
	#other_id_num#
	</td>
	</tr>
	
				</cfif>
		
		</cfif>
	</cfif>
	
</cfoutput>



 <cfif #client.rights# contains "student0">
		<tr>
			<td colspan="2">
			<cfoutput>
				<div class="isAButton" onmouseover="this.className='isAButton btnhov'" 
								onmouseout="this.className='isAButton'"
								onclick="editStuffLinks.content_url.value='editImages.cfm';editStuffLinks.submit();">
			<strong>Images</strong>
			</div>
				 
								</cfoutput>		
			</td>
		</tr>
	</cfif>
 <cfif #images.recordcount# gt 0>
  <cfif #client.rights# does not contain "student0">
   		<tr>
			<td colspan="2">
			 
			 <div class="isAButton">
				<strong>Images</strong>
			</div>
			</td>
		</tr>
  </cfif>
  
 
		
								
									
								<cfoutput query="images">
									<!--- get filesize --->
									<cfset webDir = "/var/www/html/">
										<!---- static web dir for this server --->
									<cfset thisServer = "http://arctos.database.museum/">
										<!--- first bit of the full_url --->
									<cfset thisImgFile = "#webDir##right(full_url,len(full_url) - len(thisServer))#">
										<!--- how the server gets to the image --->
									<cfset imgDir = #left(thisImgFile,len(thisImgFile) - find("/",reverse(thisImgFile)))#>
										<!--- directory the image is in --->
									<cfset thisFileName = #right(thisImgFile,find("/",reverse(thisImgFile))-1)#>
										<!--- name of the file - everything after the last / in full_url ---->
									<cfset thisExtension = #right(thisImgFile,find(".",reverse(thisImgFile)))#>
										<!--- grab the extension, just cuz we can --->
									<cfdirectory action="list" name="thisDir" directory="#imgDir#">
									<tr>
										<td align="right" valign="top">
											<a href="#full_url#" target="_blank">
												#replace(subject," ","&nbsp;","all")#
											</a>
											<cfset thisAspect = #aspect#>
											<cfloop query="thisDir">
												<cfif #thisDir.name# is #thisFileName#>
													<cfset sizeInK = #round(thisDir.size / 1024)#>
													<br><font size="-1">
													(<cfif len(#thisAspect#) gt 0>#thisAspect# view, 
													</cfif>
													#sizeInK# K, #thisExtension#)
													</font>                                            
											  </cfif> 
											</cfloop>
										</td>
										<td>#description#</td>
									</tr>
								</cfoutput>
							
	  </cfif>
  	<cfif #client.rights# contains "student0">
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
			onclick="editStuffLinks.content_url.value='Encumbrances.cfm';editStuffLinks.submit();">
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





  </tr>
	</table>
 		</td>
		</tr>
</table>
</div>
</form>
<cfquery name="getColl" dbtype="query">
	select distinct(collection_cde) from detail
</cfquery>
<cfset coll = valuelist(getColl.collection_cde)>
<cf_log cnt=1 coll=#coll#>
<cf_get_footer institution="#detail.institution_acronym#">