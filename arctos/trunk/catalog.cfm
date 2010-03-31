<cfinclude template="/includes/alwaysInclude.cfm">
	<link rel="stylesheet" type="text/css" href="/includes/_DEstyle.css">
	<script type='text/javascript' src='/ajax/core/engine.js'></script>
	<script type='text/javascript' src='/ajax/core/util.js'></script>
	<script type='text/javascript' src='/ajax/core/settings.js'></script>
	<script type='text/javascript' src='/includes/_CatAjax.js'></script>
<cfoutput>
<cfset detSelect = "
	SELECT DISTINCT
		concatidagent(identification.identification_id) id_by,
		concatcoll(cataloged_item.collection_object_id) as colls,
		concatprep(cataloged_item.collection_object_id) as preps,
		collection.institution_acronym,
		geog_auth_rec.geog_auth_rec_id,
		collecting_event.collecting_event_id,	
		cataloged_item.cat_num,
		cataloged_item.collection_object_id as collection_object_id,
		cataloged_item.collection_cde,
		identification.scientific_name,
		identification_remarks,
		identification.identification_id,
		locality.locality_id,
		continent_ocean,
		country,
		state_prov,
		quad,
		county,
		island,
		higher_geog,
		island_group,
		minimum_elevation,
		maximum_elevation,
		orig_elev_units,
		spec_locality,
		coll_object_remark.coll_object_remarks,
		verbatim_date,
		BEGAN_DATE,
		ended_date,
		sea,
		feature,
		identification.made_date,
		id_agent.agent_name id_by_agent,
		colls.agent_name as collector,
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
		specimen_part.collection_object_id as partID,
		part_name,
		partcollobj.coll_obj_disposition as part_disposition,
		partcollobj.condition as part_condition,
		sampled_from_obj_id,
		partcollobj.lot_count as part_count,
		parentContainer.barcode,
		parentContainer.label,
		parentContainer.container_id AS parentContainerId,
		thisContainer.container_id AS partContainerId,
		parentContainer.print_fg,
		partremk.coll_object_remarks as part_remark,		
		biol_indiv_relationship as relationship, 
		related_coll_object_id,
		related_cat_item.cat_num as related_cat_num,
		related_cat_item.collection_cde as related_collection_cde,
		concatEncumbrances(cataloged_item.collection_object_id) encumbrance_action,
		concatEncumbranceDetails(cataloged_item.collection_object_id) encumbrance_details,
		cataloged_item.accn_id,
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
        latLongDeterminer.agent_name lat_long_determiner,
        ACCEPTED_LAT_LONG.determined_date latLongDeterminedDate,
        lat_long_ref_source,
		lat_long_remarks,            
		concatsingleotherid(cataloged_item.collection_object_id,'AF') af_num,
		accn_number	AS accession,
			habitat_desc,
			coll_object_remark.associated_species,
			coll_object_remark.habitat,
			coll_object.flags,
			ATTRIBUTE_ID,
			attribute_type,
			attribute_value,
			attribute_units,
			attribute_remark,
			attDetr.agent_name as attribute_determiner,
			attributes.DETERMINED_DATE att_det_date,
			DETERMINATION_METHOD,
			ConcatOtherId(cataloged_item.collection_object_id) other_identifers
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
		preferred_agent_name id_agent,
		preferred_agent_name attDetr,
		identification_agent,
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
			preferred_agent_name editedPerson,
			specimen_part,
			Coll_object partcollobj,
			container parentContainer,
			container thisContainer,
			coll_object_remark partremk,
			coll_obj_cont_hist
	WHERE 
		cataloged_item.collection_id = collection.collection_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		collecting_event.locality_id = locality.locality_id  AND
		Cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
		cataloged_item.collection_object_id = citation.collection_object_id (+) AND
		citation.cited_taxon_name_id = cited_taxa.taxon_name_id (+) AND
		cataloged_item.collection_object_id = identification.collection_object_id AND
		identification.identification_id = identification_agent.identification_id AND
		identification_agent.agent_id = id_agent.agent_id AND
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
		attributes.determined_by_agent_id = attDetr.agent_id (+) AND		
		cataloged_item.collection_object_id = specimen_part.derived_from_cat_item (+) AND
		specimen_part.collection_object_id = partcollobj.collection_object_id (+) AND
		specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id (+) AND
		coll_obj_cont_hist.container_id = thisContainer.container_id (+) AND
		thisContainer.parent_container_id = parentContainer.container_id (+) AND
		specimen_part.collection_object_id = partremk.collection_object_id (+) AND
		cataloged_item.collection_object_id = #collection_object_id#
	ORDER BY
		cat_num">

<cfquery name="detail" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(detSelect)#
</cfquery>
<cfquery name="colls"  dbtype="query">
	SELECT 
		collector,
		collector_role,
		coll_order
	FROM 
		detail
	GROUP BY
		collector,
		collector_role,
		coll_order	
	ORDER BY 
		collector_role,
		coll_order
	
</cfquery>
<cfquery name="attributes"  dbtype="query">
	SELECT 
		ATTRIBUTE_ID,
		attribute_type,
		attribute_value,
		attribute_units,
		attribute_remark,
		attribute_determiner,
		att_det_date,
		DETERMINATION_METHOD
	FROM 
		detail
	GROUP BY
		ATTRIBUTE_ID,
		attribute_type,
		attribute_value,
		attribute_units,
		attribute_remark,
		attribute_determiner,
		att_det_date,
		DETERMINATION_METHOD
	ORDER BY 
		attribute_type	
</cfquery>
<cfquery name="parts" dbtype="query">
	select 
		partID,
		part_name,
		part_disposition,
		part_condition,
		sampled_from_obj_id,
		part_count,
		barcode,
		label,
		parentContainerId,
		partContainerId,
		print_fg,
		part_remark
	from detail group by
		partID,
		part_name,
		part_disposition,
		part_condition,
		sampled_from_obj_id,
		part_count,
		barcode,
		label,
		parentContainerId,
		partContainerId,
		print_fg,
		part_remark
		order by part_name
</cfquery>
<cfquery name="identifiers" dbtype="query">
	select id_by_agent from detail group by id_by_agent
</cfquery>

		
		
<cfset collection_cde = #detail.collection_cde#>
	<!---- get data for dropdowns; cache it to speed up the form; refresh every hour---->
	<cfquery name="ctInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		SELECT institution_acronym || ' ' || collection_cde as instcoll, collection_id FROM collection
			WHERE collection_cde='#collection_cde#'
	</cfquery>
	<cfquery name="ctnature" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select nature_of_id from ctnature_of_id
		order by nature_of_id
	</cfquery>
	<cfquery name="ctunits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS 
		order by ORIG_LAT_LONG_UNITS
     </cfquery>
	 <cfquery name="ctflags" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
        select flags from ctflags order by flags
     </cfquery>
	 <cfquery name="CTCOLL_OBJ_DISP" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
        select COLL_OBJ_DISPOSITION from CTCOLL_OBJ_DISP order by COLL_OBJ_DISPOSITION
     </cfquery>
	 <cfquery name="cterror" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
      		select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS order by LAT_LONG_ERROR_UNITS
      </cfquery>
	   <cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
			select datum from ctdatum order by datum
      </cfquery>
		<cfquery name="ctgeorefmethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
        select georefmethod from ctgeorefmethod order by georefmethod
        </cfquery>
		<cfquery name="ctverificationstatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
        select verificationstatus from ctverificationstatus order by verificationstatus
        </cfquery>
		
        <cfquery name="ctew" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
        select e_or_w from ctew 
        </cfquery>
        <cfquery name="ctns" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
        select n_or_s from ctns 
        </cfquery>
		<cfquery name="ctOtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT distinct(other_id_type) FROM ctColl_Other_id_type
				order by other_id_type
        </cfquery>
		<cfquery name="ctSex_Cde" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT distinct(sex_cde) as sex_cde FROM ctSex_Cde
				WHERE collection_cde='#collection_cde#'
				order by sex_cde
        </cfquery>
		<cfquery name="ctOrigElevUnits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
        	select orig_elev_units from ctorig_elev_units
			order by orig_elev_units
        </cfquery>
		<cfquery name="ctbiol_relations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
        	select BIOL_INDIV_RELATIONSHIP from ctbiol_relations order by BIOL_INDIV_RELATIONSHIP
        </cfquery>
		<cfquery name="ctPartName" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT distinct(part_name) FROM ctSpecimen_part_name
				WHERE collection_cde='#collection_cde#'
				order by part_name
        </cfquery>
		<cfquery name="ctLength_Units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
			select length_units from ctLength_Units
			order by length_units
		</cfquery>
		<cfquery name="ctWeight_Units" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
			select Weight_Units from ctWeight_Units order by Weight_Units
		</cfquery>
		<cfquery name="ctAttributeType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
			SELECT attribute_type FROM ctattribute_type 
			WHERE collection_cde='#collection_cde#'
			order by attribute_type
		</cfquery>
		<cfquery name="ctCodes" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#"  cachedwithin="#createtimespan(0,0,60,0)#">
			select 
				attribute_type,
				value_code_table,
				units_code_table
			 from ctattribute_code_tables
		</cfquery>
</cfoutput>

<cfoutput query="detail"  group="cat_num">
		<form name="catalog" method="post" action="catalog.cfm" onsubmit="return noEnter();" id="catalog">
			<input type="hidden" name="collection_object_id" value="#collection_object_id#"  id="collection_object_id"/>
			<input type="hidden" name="collection_cde" value="#collection_cde#"  id="collection_cde"/>
			<input type="hidden" name="nothing" id="nothing" /> 
<table border>
	<tr>
		<td valign="top"><!--- left half of page --->
			
	<!------------------------------------- agents ---------------------------------------------------->
	<table cellpadding="0" cellspacing="0" class="fs">
		<tr>
			<td>
				<span style="font-size:12px; font-weight:600;">
				<strong>Collector(s):</strong> #colls#
				<cfif len(#preps#) gt 0>
					<br /><strong>Preparator(s):</strong> #preps#
				</cfif>
				</span>
			</td>
		</tr>
	</table>
	<!------------------------------------- /agents ---------------------------------------------------->
<!------------------------------------- Accn and Locality ---------------------------------------------------->
	<table cellpadding="0" cellspacing="0" class="fs">
		<tr>
			<td>
				<span style="font-size:12px; font-weight:600;">
				<strong>Accession:</strong> #accession#
				</span>
			</td>
		</tr>
		<tr>
			<td>
				<span style="font-size:12px; font-weight:600;">
				<strong>Locality:</strong> #higher_geog#
				<br /><i>#spec_locality#</i>
				<br />#VerbatimLatitude# #VerbatimLongitude# Error: #max_error_distance# #max_error_units#
                by #lat_long_determiner# on #dateformat(latLongDeterminedDate,"dd mmm yyyy")# using
                #lat_long_ref_source# <cfif len(#lat_long_remarks#) gt 0>Remark: #lat_long_remarks#</cfif>
            	</span>
			</td>
		</tr>
	</table>
<!------------------------------------- /Accn and Locality ---------------------------------------------------->
	</td>
	<td valign="top"><!----- right half of page ---->
		<table cellpadding="0" cellspacing="0" class="fs">
		<tr>
			<td>
				<span style="font-size:12px; font-weight:600;">
				<strong>Other IDs:</strong> #other_identifers#
				</span>
			</td>
		</tr>
	</table>
	
	<table cellpadding="0" cellspacing="0" class="fs">
		<tr>
			<td colspan="2">
				<input type="hidden" name="taxon_name_id"/>
				<label for="scientific_name">Scientific Name</label>
				<input type="text" name="scientific_name" value="#scientific_name#" 
					id="scientific_name" class="d11a"
					size="40" 
					onchange="this.className = 'saving';taxaPick('taxon_name_id','scientific_name','catalog',this.value); return false;" />					
					<img src="/images/save.gif" class="likeLink" onclick="updateSciName();" />
			</td>
		</tr>
		<tr>
			<td>
			<cfif #identifiers.recordcount# is 1>
				<label for="id_by">Identifier</label>
				<input type="hidden" name="watch_id_by" id="watch_id_by" />
				<input type="text" name="id_by" value="#id_by#" 
					id="id_by" class="d11a"
					onchange="this.className = 'saving';updateid_by(this.value);">
					<span id="idby"></span>
			<cfelse>
				Identifiers: #id_by#
			</cfif>
			</td>
			<td>
				<label for="made_date">ID Date</label>
				<input type="text" name="made_date" value="#dateformat(made_date,'dd mmm yyyy')#" 
					id="made_date" class="d11a"
					onchange="this.className = 'saving';updateimade_date(this.value)">
			</td>
		</tr>
		<tr>
			<td>
				<label for="nature_of_id">Nature:</label>
				<cfset thisNature = #nature_of_id#>
				<select name="nature_of_id" 
					size="1" 
					onchange="this.className = 'saving';updateNature(this.value)"
					class="reqdClr d11a"
					id="nature_of_id">
						  <cfloop query="ctnature">
							<option 
							<cfif #nature_of_id# is #thisNature#> selected </cfif> 
							value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
						  </cfloop>
						</select>
			</td>
			<td>
				<label for="identification_remarks">ID Remark</label>
				<input type="text" name="identification_remarks" value="#identification_remarks#" 
					id="identification_remarks" class="d11a"
					onchange="updateidremk(this.value)">
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<table class="newRec">
					<tr>
						<td>
							
							<input type="hidden" name="newTaxonNameId" id="newTaxonNameId" />
							<label for="newID">New Scientific Name</label>
							<input type="text" name="newID" id="newID" 
								class="d11a" 
								onchange="taxaPick('newTaxonNameId','newID','catalog',this.value); return false;" />
						</td>
						<td>
							<label for="newIDBy">ID By</label>
							<input type="hidden" name="newIdById" id="newIdById" />
							<input type="text" name="newIDBy" id="newIDBy"
								class="d11a" 
								onchange="getAgent('newIdById','newIDBy','catalog',this.value); return false;" />
						</td>
					</tr>
					<tr>
						<td>
							<label for="newIDDate">ID Date</label>
							<input type="text" name="newIDDate" id="newIDDate" 
								class="d11a"  />
						</td>
						<td>
							<label for="newNature">Nature</label>
							<select name="newNature" 
								size="1" 
								class="d11a"
								id="newNature">
									  <cfloop query="ctnature">
										<option value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
									  </cfloop>
									</select>
						</td>
					</tr>
					<tr>
						<td>
							<label for="newIdRemark">Remark</label>
							<input type="text" name="newIdRemark" id="newIdRemark" 
								class="d11a" />
						</td>
						<td>
							<img src="/images/save.gif" class="likeLink" onclick="saveNewId()" />
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	
	</td><!--- end left panel --->
	</tr>
		<td colspan="2"><!--- bottom of page --->
				<!------------------------------------parts----------------------------->

			<cfset thisPartName = "">
	<cfloop query="ctPartName">
		<cfset thisPartName = "#thisPartName#|#part_name#">
	</cfloop>
	<input type="hidden" name="part_name_list" id="part_name_list" value="#thisPartName#" />
	<cfset thisdisp = "">
	<cfloop query="CTCOLL_OBJ_DISP">
		<cfset thisdisp = "#thisdisp#|#coll_obj_disposition#">
	</cfloop>
	<input type="hidden" name="disp_list" id="disp_list" value="#thisdisp#" />
			
		<table cellpadding="0" cellspacing="0" class="fs">
		<tr><td>
		<table border="1">
		<tbody  id="partTable">
			<tr>
				<td>
					<span class="d11a">Part</span>
				</td>
				<td><span class="d11a">Disposition</span></td>
				<td><span class="d11a">Condition</span></td>
				<td><span class="d11a">##</span></td>
				<td><span class="d11a">Container</span></td>
				<td><span class="d11a">Print</span></td>
				<td><span class="d11a">Remark</span></td>
				<td>&nbsp;</td>
			</tr>
			<cfset i=1>
			<cfloop query="parts">
				<input type="hidden" name="partID_#i#" value="#partID#" id="partID_#i#" />
				<tr>
					<td>
						<cfset tpn = #part_name#>
						<select name="part_name_#i#" id="part_name_#i#" size="1" class="d11a reqdClr" 
							onchange="this.className='saving';upPartName(#i#);">
							<cfloop query="ctPartName">
								<option 
									<cfif #tpn# is #part_name#> selected </cfif>
								value="#part_name#">#part_name#</option>
							</cfloop>
						</select>
					</td>
					<td>	
						<cfset pd = #part_disposition#>
						<select name="part_disposition_#i#" id="part_disposition_#i#" size="1" class="d11a reqdClr"
							onchange="this.className='saving';upPartDisp(#i#);">
							<cfloop query="CTCOLL_OBJ_DISP">
								<option 
									<cfif #pd# is #coll_obj_disposition#> selected </cfif>
								value="#coll_obj_disposition#">#coll_obj_disposition#</option>
							</cfloop>
						</select>
					
					</td>
					<td>
						<input type="text" name="part_condition_#i#" id="part_condition_#i#" 
							class="d11a reqdClr" value="#part_condition#" 
							onchange="this.className='saving';upPartCond(#i#);" />
					</td>
					<td>
						<input type="text" name="part_count_#i#" id="part_count_#i#" class="d11a reqdClr" 
							value="#part_count#" size="1"
							onchange="this.className='saving';upPartCount(#i#);" />
					</td>
					<td>
						<input type="hidden" name="barcode_#i#" id="barcode_#i#" value="#barcode#" />
						<input type="text" name="label_#i#" id="label_#i#" class="d11a" value="#label#"
							onchange="this.className='saving';upPartLabel(#i#);" /> 
					</td>
					<td>
						<select name="print_fg_#i#" id="print_fg_#i#" size="1" class="d11a"
							onchange="this.className='saving';upPrintFg(#i#);" />>
							<option  value=""></option>
							<option <cfif #print_fg# is 1> selected </cfif> value="1">Box</option>
							<option <cfif #print_fg# is 2> selected </cfif> value="2">Vial</option>
						</select>
					</td>
					<td>
						<input type="text" name="part_remark_#i#" id="part_remark_#i#" class="d11a" value="#part_remark#" 
							onchange="this.className='saving';upPartRemk(#i#);" />
					</td>
					<td>
						<img src="images/del.gif" class="likeLink" onclick="delPart(#i#)" />
					</td>
				</tr>
			
				<cfset i=#i#+1>
			</cfloop>
			
			</tbody>	
			<input type="hidden" name="numberOfParts" id="numberOfParts" value="#i#" />
				<tr class="newRec">
					<td>
						<select name="part_name_n" id="part_name_n" size="1" class="d11a" >
							<cfloop query="ctPartName">
								<option value="#part_name#">#part_name#</option>
							</cfloop>
						</select>
					</td>
					<td>	
						<select name="part_disposition_n" id="part_disposition_n" size="1" class="d11a">
							<cfloop query="CTCOLL_OBJ_DISP">
								<option value="#coll_obj_disposition#">#coll_obj_disposition#</option>
							</cfloop>
						</select>
					
					</td>
					<td>
						<input type="text" name="part_condition_n" id="part_condition_n" class="d11a"  />
					</td>
					<td>
						<input type="text" name="part_count_n" id="part_count_n" class="d11a" size="1" />
					</td>
					<td>
						<input type="text" name="label_n" id="label_n" class="d11a"  /> 
					</td>
					<td>
						<select name="print_fg_n" id="print_fg_n" size="1" class="d11a"n />
							<option  value=""></option>
							<option value="1">Box</option>
							<option value="2">Vial</option>
						</select>
					</td>
					<td>
						<input type="text" name="part_remark_n" id="part_remark_n" class="d11a" />
					</td>
					<td>
						<img src="images/save.gif" class="likeLink" onclick="newpart();" />
					</td>
				</tr>
		</table>
		</td></tr>
		</table>
		<!------------------------------------/parts----------------------------->
		<!------------------------------------------------------ attributes -------------------------------------->
		
				<table cellpadding="0" cellspacing="0" class="fs">
			<tr>
				<td>
					<cfset i=1>
<table border cellpadding="0" cellspacing="0">
	<tbody id="attrTbod">
	<tr>
		<td><span class="d11a">Attribute</span></td>
		<td><span class="d11a">Value</span></td>
		<td><span class="d11a">Units</span></td>
		<td><span class="d11a">Remarks</span></td>
		<td><span class="d11a">Det. Date</span></td>
		<td><span class="d11a">Det. Meth</span></td>
		<td><span class="d11a">Determiner</span></td>
		<td>&nbsp;</td>
	</tr>
<cfloop query="attributes">
	 <tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
	 	<cfset thisAttId = #attribute_id#>
		<input type="hidden" name="attribute_id_#i#" id="attribute_id_#i#" value="#thisAttId#" />
		<td>
			<cfset thisAttType = #attribute_type#>
			<input type="text" 
				name="attribute_type_#i#"
				id="attribute_type_#i#" 
				value="#thisAttType#" 
				readonly="yes" 
				class="readClr d11a">
		</td>
		<td>
		<!---- see if we should have a code table here --->
		<cfquery name="isValCt" dbtype="query">
			select value_code_table from ctCodes where attribute_type='#thisAttType#'
		</cfquery>
		<cfif isdefined("isValCt.value_code_table") and len(#isValCt.value_code_table#) gt 0>
			<!-- there's a code table --->
			<cfquery name="valCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isValCt.value_code_table#
			</cfquery>
			
			<!---- get column names --->
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isValCt.value_code_table)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
				<cfset collCode = "">
				<cfset columnName = "">
				<cfloop query="getCols">
						<cfif getCols.column_name is "COLLECTION_CDE">
							<cfset collCode = "yes">
						  <cfelse>
							<cfset columnName = "#getCols.column_name#">
						</cfif>
				</cfloop>
				<!--- if we got a collection code, rerun the query to filter ---->
				<cfif len(#collCode#) gt 0>
					<cfquery name="valCodes" dbtype="query">
						SELECT #getCols.column_name# as valCodes from valCT
						WHERE collection_cde='#collection_cde#'
					</cfquery>
				  <cfelse>
				 
				  	<cfquery name="valCodes" dbtype="query">
						SELECT #getCols.column_name# as valCodes from valCT
					</cfquery>
				</cfif>
				<cfset thisAttVal = "#attribute_value#">
				<select name="attribute_value_#i#" 
					id="attribute_value_#i#" 
					size="1" 
					class="reqdClr d11a"
					onchange="this.className='saving';changeAttValue('#i#');">
					<option value=""></option>
					<cfloop query="valCodes">
						<option 
							<cfif #valCodes.valCodes# is "#thisAttVal#"> selected </cfif>
						value="#valCodes.valCodes#">#valCodes.valCodes#</option>
					</cfloop>
				</select>
		<cfelse><!--- free text --->
		  	<input type="text" 
				name="attribute_value_#i#"
				id="attribute_value_#i#" 
				value="#attributes.attribute_value#" 
				class="reqdClr d11a" size="25"
				onchange="this.className='saving';changeAttValue('#i#');">
		</cfif>
		</td>
		<td>		
		<!---- see if we should have a code table here --->
		<cfquery name="isUnitCt" dbtype="query">
			select units_code_table from ctCodes where attribute_type='#thisAttType#'
		</cfquery>
		<cfif isdefined("isUnitCt.units_code_table") and len(#isUnitCt.units_code_table#) gt 0>
			<!-- there's a code table --->
			<!---- get the data --->
			<cfquery name="unitCT" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from #isUnitCt.units_code_table#
			</cfquery>
			<!---- get column names --->
			<cfquery name="getCols" datasource="uam_god">
				select column_name from sys.user_tab_columns where table_name='#ucase(isUnitCt.units_code_table)#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
				<cfset collCode = "">
				<cfset columnName = "">
				<cfloop query="getCols">
					<cfif getCols.column_name is "COLLECTION_CDE">
						<cfset collCde = "yes">
					  <cfelse>
					 	<cfset columnName = "#getCols.column_name#">
					</cfif>
				</cfloop>
				<!--- if we got a collection code, rerun the query to filter ---->
				<cfif len(#collCode#) gt 0>
			
					<cfquery name="unitCodes" dbtype="query">
						SELECT #getCols.column_name# as unitCodes from unitCT
						WHERE collection_cde='#collection_cde#'
					</cfquery>
				  <cfelse>
			
				  	<cfquery name="unitCodes" dbtype="query">
						SELECT #getCols.column_name# as unitCodes from unitCT
					</cfquery>
				</cfif>
				<cfset thisAttUnit = "#attribute_units#">
				<select name="attribute_units_#i#" 
					id="attribute_units_#i#" 
					size="1" 
					class="reqdClr d11a"
					onchange="this.className='saving';changeAttUnit('#i#');">
					<option value=""></option>
					<cfloop query="unitCodes">
						<option 
							<cfif #unitCodes.unitCodes# is "#thisAttUnit#"> selected </cfif>
						value="#unitCodes.unitCodes#">#unitCodes.unitCodes#</option>
					</cfloop>
				</select>
		</cfif>
		
		</td>
		<td>
		<cfset detDate = #dateformat(att_det_date,"dd mmm yyyy")#>
		<input type="text" 
			name="attribute_remark_#i#" 
			value="#attribute_remark#" 
			id="attribute_remark_#i#" 
			class="d11a"
			onchange="this.className='saving';changeAttRemk('#i#');">
		</td>
		<td>
			<input type="text" 
				name="att_det_date_#i#" 
				id="att_det_date_#i#" 
				value="#dateformat(att_det_date,'dd mmm yyyy')#" 
				class="d11a" 
				size="12"
				onchange="this.className='saving';changeAttDate('#i#');">
			</td>
		<td>
			<input type="text" 
				name="determination_method_#i#" 
				id="determination_method_#i#" 
				value="#determination_method#" 
				class="d11a"
				onchange="this.className='saving';changeAttDetMeth('#i#');">
			</td>
		<td>
		<input type="hidden" name="watch_attribute_determiner_#i#" id="watch_attribute_determiner_#i#" />
		<input type="text" 
			name="attribute_determiner_#i#" 
			id="attribute_determiner_#i#" 
			class="reqdClr d11a" 
			value="#attribute_determiner#"
			onchange="this.className='saving';updateattribute_determiner('#i#');">
		<div id="attdetr_#i#"></div>
		
		<!----
		<input type="button" name="pickDeterminer"
				value="Find" 
				class="picBtn"
				onmouseover="this.className='picBtn btnhov'"
				onmouseout="this.className='picBtn'"
				onclick="getAgent('determined_by_agent_id','agent_name','att#i#',att#i#.agent_name.value); return false;">
				---->
				</td>
			<td>
				<img src="images/del.gif" class="likeLink" onclick="delAtt(#i#)" />
			</td>
		
	</tr>
	<cfset i=#i#+1>
</cfloop>
<input type="hidden" name="numberOfAttributes" value="#i#" id="numberOfAttributes" />
				</td>
			</tr>
			</tbody>
			
			
			
			
			
			
			 <tr class="newRec">
		<td>
			<select name="attribute_type_n" size="1"  onChange="getAttributeStuff(this.value,this.id);"
						style="width:100;"
						id="attribute_type_n"
						class="d11a">
						<option value=""></option>
						<cfloop query="ctAttributeType">
							<option value="#attribute_type#">#attribute_type#</option>
						</cfloop>
					  </select>
		</td>
		<td>
					<div id="attribute_value_cell_n">
					<input type="text" 
						name="attribute_value_n" 
						id="attribute_value_n"
						class="d11a"
						size="15">
					</div>
				</td>
		<td>
					<div id="attribute_units_cell_n">
					<input type="text" 
						name="attribute_units_n" 
						id="attribute_units_n"
						size="6"
						class="d11a">
						</div>
				</td>
				<td>
					<input type="text" name="attribute_remarks_n"
						class="d11a"
						id="attribute_remarks_n">
				</td>
				<td>
					<input type="text" 
						class="d11a"
						name="attribute_date_n" 
						id="attribute_date_n"
						size="10">
				</td>
				<td>
					<input type="text" name="attribute_det_meth_n"
						class="d11a"
						id="attribute_det_meth_n"
						size="15">
				</td>
				<td>
					 <input type="hidden" name="attribute_determiner_id_n" id="attribute_determiner_id_n" />
					 <input type="text" name="attribute_determiner_n"
						class="d11a reqdClr"
						onchange="getAgent('attribute_determiner_id_n','attribute_determiner_n','catalog',this.value);"
						id="attribute_determiner_n"
						size="15">
				</td>
				
				
				<td>
					<img src="/images/save.gif" class="likeLink" onclick="saveNewAtt();" />
				</td>
			</tr>
	
	
		</table>
		</td>
			</tr>
		</table>
		<!-----------------------------------/attributes---------------------------->
		</td>
	<tr>
			<!--------------- remarky stuff -------------------------------------------------------------------------------------->
		<table><tr><td>
		<table cellpadding="0" cellspacing="0" class="fs">
			<tr>
				<td>
					<label for="coll_object_remarks">Remarks</label>
					<textarea name="coll_object_remarks" id="coll_object_remarks" class="d11a" rows="2" cols="40" onchange="this.className='saving';upRemarks(this.value);">#coll_object_remarks#</textarea>
					
					<!----nchange=""---->
				</td>
			</tr>
		</table>
		</td>
		<td>
			<cfset thisDisp = #coll_obj_disposition#>
			<label for="coll_obj_disposition">Spec. Disposition</label>
			<select name="coll_obj_disposition" id="coll_obj_disposition" size="1" onchange="this.className='saving';upDispn(this.value);">
				<cfloop query="CTCOLL_OBJ_DISP">
								<option 
									<cfif #thisDisp# is #coll_obj_disposition#> selected </cfif>
								value="#coll_obj_disposition#">#coll_obj_disposition#</option>
							</cfloop>
			</select>
		</td>
		<td> </td>
		</tr>
		</table>
		<!--------------- /remarky stuff -------------------------------------------------------------------------------------->
		
	</td><!---- end right panel ---->
</tr><!--- end top of page --->
<tr><!--- bottom of page --->
	<td colspan="2">
	<!---- stash values for dropdowns up here ---->
	
	</td><!--- end botom cell--->
</tr><!--- end bottom of page --->
</table>
</form>
			
	</table>
<!-------------------------------------- / agents------------------------------------------->	
				</td>
			</tr>
		</table>
<script type="text/javascript" language="javascript">
		changeStyle('#detail.institution_acronym#');
		parent.dyniframesize();
</script>
</cfoutput>
