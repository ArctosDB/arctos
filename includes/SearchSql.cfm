<cfif not isdefined("basQual")>
	<cfset basQual = "">
</cfif>
<cfif not isdefined("mapurl")>
	<cfset mapurl="">
</cfif>
<cfif isdefined("listcatnum")>
	<cfset catnum = listcatnum>
</cfif>
<cfif isdefined("cat_num")>
	<cfset catnum = cat_num>
</cfif>
<cfif isdefined("mime_type") AND len(mime_type) gt 0>
	<cfset mapurl = "#mapurl#&mime_type=#mime_type#">
	<cfif basJoin does not contain "media_relations">
		<cfset basJoin = " #basJoin# INNER JOIN media_relations ON 
			(cataloged_item.collection_object_id = media_relations.related_primary_key)">
	</cfif>
	<cfset basQual = "#basQual#  AND media_relations.media_relationship like '% cataloged_item'" >
   	<cfif basJoin does not contain " media ">
        <cfset basJoin = " #basJoin# INNER JOIN media ON (media_relations.media_id = media.media_id)">
    </cfif>
	<cfset basQual = "#basQual#  AND media.mime_type = '#mime_type#'" >
</cfif>
<cfif isdefined("ImgNoConfirm") and len(ImgNoConfirm) gt 0>
	<cfset mapurl = "#mapurl#&ImgNoConfirm=#ImgNoConfirm#">
   	<cfset basQual = "#basQual#  AND cataloged_item.collection_object_id not in (select 
		collection_object_id from attributes where attribute_type='image confirmed' and attribute_value='yes')" >
</cfif>
<cfif isdefined("catnum") and len(catnum) gt 0>
	<cfset catnum=replace(catnum," ","","all")>
	<cfset mapurl = "#mapurl#&catnum=#catnum#">
	<cfif catnum contains "-">
		<cfset hyphenPosition=find("-",catnum)>
		<cfif hyphenPosition lt 2>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.cat_num) = '#ucase(catnum)#'" >
		<cfelse>
			<cfset minCatNum=left(catnum,hyphenPosition-1)>
			<cfset maxCatNum=right(catnum,len(catnum)-hyphenPosition)>
			<cfif isnumeric(minCatNum) and isnumeric(maxCatNum)>
				<cfset clist="">
				<cfloop from="#minCatNum#" to="#maxCatNum#" index="i">
					<cfset clist=listappend(clist,i)>
				</cfloop>
				<cfif listlen(clist) gte 1000>
					<div class="error">Catalog number span searches have a 1000 record limit</div>
					<script>hidePageLoad();</script>
					<cfabort>
				</cfif>
				<cfset basQual = " #basQual# AND #session.flatTableName#.cat_num in ( #ListQualify(clist,'''')# ) " >
			<cfelse>
				<cfset basQual = " #basQual# AND upper(#session.flatTableName#.cat_num) = '#ucase(catnum)#'" >
			</cfif>
		</cfif>
	<cfelse>
		<cfset basQual = " #basQual# AND #session.flatTableName#.cat_num IN ( #ListQualify(ListChangeDelims(catnum,','),'''')# ) " >
	</cfif>
<!---
	
--->
</cfif>	
<cfif isdefined("geology_attribute") AND len(geology_attribute) gt 0>
	<cfset mapurl = "#mapurl#&geology_attribute=#geology_attribute#">
	<cfif basJoin does not contain " geology_attributes ">
		<cfset basJoin = " #basJoin# INNER JOIN geology_attributes ON (#session.flatTableName#.locality_id = geology_attributes.locality_id)">
	</cfif>	
	<cfif isdefined("geology_hierarchies") and geology_hierarchies is true>
		<cfset basQual = "#basQual# AND geology_attributes.geology_attribute IN (
				SELECT  
	 				attribute	
	 			FROM
					geology_attribute_hierarchy
				start with 
					attribute = '#geology_attribute#'
				CONNECT BY PRIOR 
					geology_attribute_hierarchy_id = parent_id
				)">
	<cfelse>
		<cfset basQual = "#basQual# AND geology_attributes.geology_attribute = '#geology_attribute#'">
	</cfif>				
</cfif>		
<cfif isdefined("geology_attribute_value") AND len(geology_attribute_value) gt 0>
	<cfset mapurl = "#mapurl#&geology_attribute_value=#geology_attribute_value#">
	<cfif basJoin does not contain " geology_attributes ">
		<cfset basJoin = " #basJoin# INNER JOIN geology_attributes ON 
			(#session.flatTableName#.locality_id = geology_attributes.locality_id)">
	</cfif>	
	<cfif isdefined("geology_hierarchies") and geology_hierarchies is 1>
		<cfset basQual = "#basQual# AND geology_attributes.geo_att_value IN (
				SELECT  
	 				attribute_value	
	 			FROM
					geology_attribute_hierarchy
				start with 
					upper(attribute_value) like '%#ucase(geology_attribute_value)#%'
				CONNECT BY PRIOR 
					geology_attribute_hierarchy_id = parent_id
				)">
	<cfelse>
		<cfset basQual = "#basQual# AND upper(geology_attributes.geo_att_value) like '%#ucase(geology_attribute_value)#%'">
	</cfif>				
</cfif>		
<cfif isdefined("entered_by") AND len(entered_by) gt 0>
	<cfset mapurl = "#mapurl#&entered_by=#entered_by#">
	<cfif basJoin does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON (cataloged_item.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basJoin = " #basJoin# INNER JOIN agent_name entered_agent ON	(CatItemCollObject.entered_person_id = entered_agent.agent_id)">
	<cfset basQual = "#basQual#  AND upper(entered_agent.agent_name) like '%#ucase(entered_by)#%'" >
</cfif>
<cfif isdefined("media_type") AND len(#media_type#) gt 0>
	<cfset mapurl = "#mapurl#&media_type=#media_type#">
	<cfif basJoin does not contain "media_relations">
		<cfset basJoin = " #basJoin# INNER JOIN media_relations ON 
			(cataloged_item.collection_object_id = media_relations.related_primary_key)">
	</cfif>
	<cfset basQual = "#basQual#  AND media_relations.media_relationship like '%cataloged_item%'" >
    <cfif media_type is not "any">
        <cfset basJoin = " #basJoin# INNER JOIN media ON (media_relations.media_id = media.media_id)">
        <cfset basQual = "#basQual#  AND media.media_type = '#media_type#'" >
    </cfif>
</cfif>
<cfif isdefined("coll_obj_flags") AND len(coll_obj_flags) gt 0>
	<cfif basJoin does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON 
			(cataloged_item.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND CatItemCollObject.flags = '#coll_obj_flags#'" >
	<cfset mapurl = "#mapurl#&coll_obj_flags=#coll_obj_flags#">
</cfif>
<cfif isdefined("beg_entered_date") AND len(beg_entered_date) gt 0>
	<cfif not isdefined("end_entered_date") or len(end_entered_date) is 0>
		<cfset end_entered_date = beg_entered_date>
	</cfif>
	<cfset beEntDate = dateformat(beg_entered_date,"yyyy-mm-dd")>
	<cfset edEntDate = dateformat(end_entered_date,"yyyy-mm-dd")>
	<cfif basJoin does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON 
			(cataloged_item.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND CatItemCollObject.COLL_OBJECT_ENTERED_DATE BETWEEN '#beEntDate#' and '#edEntDate#'" >
	<cfset mapurl = "#mapurl#&beg_entered_date=#beg_entered_date#">
	<cfset mapurl = "#mapurl#&end_entered_date=#end_entered_date#">
</cfif>
<cfif isdefined("beg_last_edit_date") AND len(beg_last_edit_date) gt 0>
	<cfif not isdefined("end_last_edit_date")>
		<cfset end_last_edit_date=beg_last_edit_date>
	</cfif>
	<cfset basQual = "#basQual#  AND (
					to_date(to_char(#session.flatTableName#.last_edited_date,'dd-mon-yyy')) between 
						to_date('#dateformat(beg_last_edit_date,"yyyy-mm-dd")#')
						and to_date('#dateformat(end_last_edit_date,"yyyy-mm-dd")#')
				)" >
</cfif>
<cfif isdefined("print_fg") AND len(print_fg) gt 0>
	<!---- get data for printing labels ---->
	<cfset basQual = "#basQual#  AND cataloged_item.collection_object_id IN (
		SELECT
			derived_from_cat_item
		FROM
			specimen_part,
			coll_obj_cont_hist,
			container coll_obj_container,
			container parent_container
		WHERE
			specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id AND
			coll_obj_cont_hist.container_id = coll_obj_container.container_id AND
			coll_obj_container.parent_container_id = parent_container.container_id AND
			parent_container.print_fg = #print_fg# )
		" >
	<cfset mapurl = "#mapurl#&print_fg=#print_fg#">
</cfif>
<cfif isdefined("barcode") AND len(barcode) gt 0>
	<cfset thisBC = #replace(barcode,",","','","all")#>
	<cfset basQual = "#basQual#  AND cataloged_item.collection_object_id IN (
		SELECT
			derived_from_cat_item
		FROM
			specimen_part,
			coll_obj_cont_hist,
			container coll_obj_container,
			container parent_container
		WHERE
			specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id AND
			coll_obj_cont_hist.container_id = coll_obj_container.container_id AND
			coll_obj_container.parent_container_id = parent_container.container_id AND
			parent_container.barcode IN ('#ListChangeDelims(thisBC,',')#') )
		" >
	<cfset mapurl = "#mapurl#&barcode=#barcode#">
</cfif>	
<cfif isdefined("session.ShowObservations") AND session.ShowObservations is true>
	<cfset mapurl = "#mapurl#&ShowObservations=#session.ShowObservations#">
<cfelse>
	<cfset mapurl = "#mapurl#&ShowObservations=false">
	<cfset basQual = "#basQual#  AND lower( #session.flatTableName#.institution_acronym) not like '%obs'" >
</cfif>
<cfif isdefined("edited_by_id") AND len(edited_by_id) gt 0>
	<cfif basJoin does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON 
		(cataloged_item.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND CatItemCollObject.last_edited_person_id = #edited_by_id#" >
	<cfset mapurl = "#mapurl#&edited_by_id=#edited_by_id#">
</cfif>
<cfif isdefined("coll_obj_disposition") AND len(coll_obj_disposition) gt 0>
	<cfif basJoin does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON 
		(cataloged_item.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND CatItemCollObject.coll_obj_disposition = '#coll_obj_disposition#'" >
	<cfset mapurl = "#mapurl#&coll_obj_disposition=#coll_obj_disposition#">
</cfif>	
<cfif isdefined("encumbrance_id") AND isnumeric(encumbrance_id)>
	<cfif basJoin does not contain "coll_object_encumbrance">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object_encumbrance ON 
		(cataloged_item.collection_object_id = coll_object_encumbrance.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND coll_object_encumbrance.encumbrance_id = #encumbrance_id#" >
	<cfset mapurl = "#mapurl#&encumbrance_id=#encumbrance_id#">
</cfif>	
<cfif isdefined("encumbering_agent_id") AND isnumeric(encumbering_agent_id)>
	<cfif basJoin does not contain " coll_object_encumbrance ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object_encumbrance ON 
		(cataloged_item.collection_object_id = coll_object_encumbrance.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " encumbrance ">
		<cfset basJoin = " #basJoin# INNER JOIN encumbrance ON 
		(coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND encumbering_agent_id = #encumbering_agent_id#" >
	<cfset mapurl = "#mapurl#&encumbering_agent_id=#encumbering_agent_id#">
</cfif>	
<cfif isdefined("collection_id") AND isnumeric(collection_id)>
	<cfset basQual = "#basQual#  AND #session.flatTableName#.collection_id = #collection_id#" >
	<cfset mapurl = "#mapurl#&collection_id=#collection_id#">
</cfif>		
<cfif isdefined("session.collection") and len(session.collection) gt 0>
	<cfset collection_cde=session.collection>
</cfif>		
<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
	<cfset collcde = "">
	<cfloop list="#collection_cde#" index="i">
		<cfif len(collcde) is 0>
			<cfset collcde = "'#i#'">
		<cfelse>
			<cfset collcde = "#collcde#,'#i#'">
		</cfif>
	</cfloop>
	<cfset basQual = "#basQual#  AND cataloged_item.collection_cde IN (#collcde#)" >
	<cfset mapurl = "#mapurl#&collection_cde=#collection_cde#">
</cfif>
<cfif isdefined("coll") AND len(coll) gt 0>
	<cfif not isdefined("coll_role") or len(coll_role) is 0>
		<cfset coll_role="c">
	</cfif>
	<cfif coll_role is "p">
		<cfset basJoin = " #basJoin# INNER JOIN collector ON 
			(cataloged_item.collection_object_id = collector.collection_object_id)
			INNER JOIN agent_name srchColl ON (collector.agent_id = srchColl.agent_id)">
		<cfSet basQual = " #basQual# AND UPPER(srchColl.Agent_Name) LIKE '%#UCASE(coll)#%'
			AND collector_role = '#coll_role#'">
	<cfelse>
		<cfSet basQual = " #basQual# AND UPPER(#session.flatTableName#.COLLECTORS) LIKE '%#UCASE(escapeQuotes(coll))#%'">
	</cfif>
	<cfset mapurl = "#mapurl#&coll=#coll#">  
	<cfset mapurl = "#mapurl#&coll_role=#coll_role#">
</cfif>
<cfif isDefined ("notCollector") and len(notCollector) gt 0>
	<cfset mapurl = "#mapurl#&notCollector=#notCollector#"> 
	<cfSet basQual = " #basQual# AND UPPER(#session.flatTableName#.COLLECTORS) NOT LIKE '%#UCASE(notCollector)#%'">
</cfif>
<cfif isdefined("collector_agent_id") AND len(collector_agent_id) gt 0>
	<cfset mapurl = "#mapurl#&collector_agent_id=#collector_agent_id#"> 
	<cfif basJoin does not contain "srchColl">
		<cfset basJoin = " #basJoin# INNER JOIN collector ON 
			(cataloged_item.collection_object_id = collector.collection_object_id)
			INNER JOIN agent_name srchColl ON (collector.agent_id = srchColl.agent_id)">
	</cfif>
	<cfset basQual = " #basQual# AND collector.agent_id = #collector_agent_id#">
</cfif>
<cfif isdefined("sciNameOper") and sciNameOper is "was"><!--- duck out to any name --->
	<cfset AnySciName=scientific_name>
	<cfset scientific_name="">
</cfif>
<cfif isdefined("sciname") and len(sciname) gt 0>
	<cfset scientific_name=sciname>
</cfif>
<cfif isdefined("scientific_name") AND len(scientific_name) gt 0>
	<cfset mapurl = "#mapurl#&scientific_name=#scientific_name#">
	<cfif left(scientific_name,1) is '='>
		<cfset scientific_name=right(scientific_name,len(scientific_name)-1)>
		<cfset sciNameOper = "=">
	</cfif>
	<cfif not isdefined("sciNameOper") OR len(sciNameOper) is 0>
		<cfset sciNameOper = "LIKE">
	</cfif>
	<cfset mapurl = "#mapurl#&sciNameOper=#sciNameOper#">
	<cfif sciNameOper is "LIKE">
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) LIKE '%#ucase(scientific_name)#%'">
	<cfelseif sciNameOper is "OR">
		<cftry>
			<cfset basQual = " #basQual# AND (">
			<cfset nEl=listlen(scientific_name)>
			<cfset i=1>
			<cfloop list="#scientific_name#" index="s">
				<cfset basQual = " #basQual# upper(#session.flatTableName#.scientific_name) LIKE '%#ucase(listgetat(scientific_name,i))#%'">
				<cfif i lt nEl>
					<cfset basQual = " #basQual# OR ">
				</cfif>
				<cfset i=i+1>
			</cfloop>
			<cfcatch>
				<div class="error">
					Oops! Something bad happened! To search for scientific name in list, enter comma-separated values like
					"sorex yukonicus, sorex ugyunak"
					<p>#cfcatch.message#</p>
				</div>
				<script>hidePageLoad();</script>
				<cfabort>
			</cfcatch>
		</cftry>
		<cfset basQual = " #basQual# )">		
	<cfelseif sciNameOper is "=">
		<cfset basQual = " #basQual# AND #session.flatTableName#.scientific_name = '#scientific_name#'">
	<cfelseif sciNameOper is "NOT LIKE">
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) NOT LIKE '%#ucase(scientific_name)#%'">
	</cfif>
</cfif>
<cfif isdefined("HighTaxa") AND len(HighTaxa) gt 0>
	<cfset mapurl = "#mapurl#&HighTaxa=#HighTaxa#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON 
		(cataloged_item.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON 
		(identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfif basJoin does not contain " taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN taxonomy ON 
		(identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id)">
	</cfif>
	<cfset basQual = "#basQual# AND identification.accepted_id_fg=1">
	<cfset basQual = " #basQual# AND UPPER(taxonomy.Full_Taxon_Name) LIKE '%#ucase(HighTaxa)#%'">
</cfif>	
<cfif isdefined("AnySciName") AND len(AnySciName) gt 0>
	<cfset mapurl = "#mapurl#&AnySciName=#AnySciName#">
		<cfset basQual = " #basQual# AND ( cataloged_item.collection_object_id IN
			(select collection_object_id FROM identification where 
				UPPER(scientific_name) LIKE '%#ucase(AnySciName)#%')
			OR cataloged_item.collection_object_id IN
				(select collection_object_id FROM
					citation,
					taxonomy
				WHERE
					citation.cited_taxon_name_id = taxonomy.taxon_name_id AND
					UPPER(scientific_name) LIKE '%#ucase(AnySciName)#%')
				OR cataloged_item.collection_object_id IN (
					select collection_object_id FROM
						identification,
						identification_taxonomy,
						taxonomy AccTax,
						taxonomy RelTax,
						taxon_relations
					WHERE
						identification.identification_id=identification_taxonomy.identification_id AND
						identification_taxonomy.taxon_name_id=AccTax.taxon_name_id AND
						AccTax.taxon_name_id=taxon_relations.taxon_name_id AND
						taxon_relations.related_taxon_name_id = RelTax.taxon_name_id AND
						UPPER(RelTax.scientific_name) LIKE '%#ucase(AnySciName)#%'
					)
					)">
</cfif>
<cfif isdefined("genus") AND len(genus) gt 0>
	<cfset mapurl = "#mapurl#&genus=#genus#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON 
			(cataloged_item.collection_object_id = identification.collection_object_id)">
		<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 ">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON 
		(identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfif basJoin does not contain " taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN taxonomy ON 
		(identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id)">
	</cfif>
	<cfif left(genus,1) is '='>
		<cfset basQual = " #basQual# AND upper(taxonomy.genus) = '#ucase(right(genus,len(genus)-1))#'">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(taxonomy.genus) like '%#ucase(genus)#%'">
	</cfif>
</cfif>
<cfif isdefined("species") AND len(species) gt 0>
	<cfset mapurl = "#mapurl#&species=#species#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON 
			(cataloged_item.collection_object_id = identification.collection_object_id)">
		<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 ">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON 
		(identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfif basJoin does not contain " taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN taxonomy ON 
		(identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id)">
	</cfif>
	<cfif left(species,1) is '='>
		<cfset basQual = " #basQual# AND upper(taxonomy.species) = '#ucase(right(species,len(species)-1))#'">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(taxonomy.species) like '%#ucase(species)#%'">
	</cfif>		
</cfif>
<cfif isdefined("subspecies") AND len(subspecies) gt 0>
	<cfset mapurl = "#mapurl#&subspecies=#subspecies#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON 
			(cataloged_item.collection_object_id = identification.collection_object_id)">
		<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 ">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON 
		(identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfif basJoin does not contain " taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN taxonomy ON 
		(identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id)">
	</cfif>
	<cfif left(subspecies,1) is '='>
		<cfset basQual = " #basQual# AND upper(taxonomy.subspecies) = '#ucase(right(subspecies,len(subspecies)-1))#'">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(taxonomy.subspecies) like '%#ucase(subspecies)#%'">
	</cfif>		
</cfif>
<cfif isdefined("Phylclass") AND len(Phylclass) gt 0>
	<cfset mapurl = "#mapurl#&Phylclass=#Phylclass#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON 
		(cataloged_item.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON 
		(identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfif basJoin does not contain " taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN taxonomy ON 
		(identification_taxonomy.taxon_name_id = taxonomy.taxon_name_id)">
	</cfif>
	<cfif left(phylclass,1) is '='>
		<cfset basQual = " #basQual# AND upper(taxonomy.phylclass) = '#ucase(right(phylclass,len(phylclass)-1))#'">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(taxonomy.phylclass) like '%#ucase(phylclass)#%'">
	</cfif>
</cfif>
<cfif isdefined("any_taxa_term") AND len(any_taxa_term) gt 0>
	<cfset mapurl = "#mapurl#&any_taxa_term=#any_taxa_term#">
	<cfset basJoin = " #basJoin# inner join taxa_terms on (#session.flatTableName#.collection_object_id = taxa_terms.collection_object_id)">
	<cfset basQual = " #basQual# AND taxa_terms.taxa_term like '%#escapeQuotes(ucase(any_taxa_term))#%'">		
</cfif>
<cfif isdefined("identified_agent_id") AND len(identified_agent_id) gt 0>
	<cfset mapurl = "#mapurl#&identified_agent_id=#identified_agent_id#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON 
		(cataloged_item.collection_object_id = identification.collection_object_id)
		INNER JOIN identification_agent ON 
		(identification.identification_id = identification_agent.identification_id)	">
	</cfif>
	<cfset basQual = " #basQual# AND identification_agent.agent_id = #identified_agent_id#">			
</cfif>
<cfif isdefined("identification_remarks") AND len(identification_remarks) gt 0>
	<cfset mapurl = "#mapurl#&identification_remarks=#identification_remarks#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON 
		(cataloged_item.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 AND 
		upper(identification.identification_remarks) like '%#ucase(identification_remarks)#%'">			
</cfif>
<cfif isdefined("nature_of_id") AND len(nature_of_id) gt 0>
	<cfset mapurl = "#mapurl#&nature_of_id=#nature_of_id#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON 
		(cataloged_item.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 AND identification.nature_of_id = '#nature_of_id#'">			
</cfif>
<cfif isdefined("identified_agent") AND len(identified_agent) gt 0>
	<cfset mapurl = "#mapurl#&identified_agent=#identified_agent#">
	<cfset basQual = " #basQual# AND upper(#session.flatTableName#.IDENTIFIEDBY) LIKE '%#ucase(identified_agent)#%'">			
</cfif>


<cfif isdefined("begDate") AND len(begDate) gt 0>		
	<cfset mapurl = "#mapurl#&begDate=#begDate#">
	<cfquery name="isdate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select is_iso8601('#begDate#') isdate from dual
	</cfquery>
	<cfif isdate.isdate is not "valid">
		<div class="error">
			The begin date you entered is not a valid ISO8601 date. 
			See <a target="_blank" href="http://g-arctos.appspot.com/arctosdoc/date.html">About Arctos Dates</a>
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset basQual = " #basQual# AND #session.flatTableName#.began_date >= '#begDate#'">		
</cfif>
<cfif isdefined("endDate") AND len(endDate) gt 0>	
	<cfset mapurl = "#mapurl#&endDate=#endDate#">
	<cfquery name="isdate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select is_iso8601('#endDate#') isdate from dual
	</cfquery>
	<cfif isdate.isdate is not "valid">
		<div class="error">
			The ended date you entered is not a valid ISO8601 date. 
			See <a target="_blank" href="http://g-arctos.appspot.com/arctosdoc/date.html">About Arctos Dates</a>
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset basQual = " #basQual# AND #session.flatTableName#.ended_date <= '#endDate#'">		
</cfif>

<cfif isdefined("begYear") AND len(begYear) gt 0>
	<cfset mapurl = "#mapurl#&begYear=#begYear#">
	<cfset basQual = " #basQual# AND TO_NUMBER(substr(#session.flatTableName#.began_date,1,4)) >= #begYear#">
</cfif>

<cfif isdefined("begMon") AND len(begMon) gt 0>
	<cfset mapurl = "#mapurl#&begMon=#begMon#">
	<cfset basQual = " #basQual# AND TO_NUMBER(substr(#session.flatTableName#.began_date,6,2)) >= #begMon#">
</cfif>
<cfif isdefined("begDay") AND len(begDay) gt 0>
	<cfset mapurl = "#mapurl#&begDay=#begDay#">
	<cfset basQual = " #basQual# AND TO_NUMBER(substr(#session.flatTableName#.began_date,9,2)) >= #begDay#">
</cfif>


<cfif isdefined("endYear") AND len(endYear) gt 0>
	<cfset mapurl = "#mapurl#&endYear=#endYear#">
	<cfset basQual = " #basQual# AND TO_NUMBER(substr(#session.flatTableName#.ended_date,1,4)) <= #endYear#">
</cfif>

<cfif isdefined("endMon") AND len(endMon) gt 0>
	<cfset mapurl = "#mapurl#&endMon=#endMon#">
	<cfset basQual = " #basQual# AND TO_NUMBER(substr(#session.flatTableName#.ended_date,6,2)) <= #endMon#">
</cfif>
<cfif isdefined("endDay") AND len(endDay) gt 0>
	<cfset mapurl = "#mapurl#&endDay=#endDay#">
	<cfset basQual = " #basQual# AND TO_NUMBER(substr(#session.flatTableName#.ended_date,9,2)) <= #endDay#">
</cfif>


<cfif isdefined("verificationstatus") AND len(verificationstatus) gt 0>
	<cfset mapurl = "#mapurl#&verificationstatus=#verificationstatus#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.verificationstatus='#verificationstatus#'">
</cfif>
<cfif isdefined("inMon") AND len(inMon) gt 0>
	<cfset mapurl = "#mapurl#&inMon=#inMon#">
	<cfset basQual = " #basQual# AND TO_NUMBER(substr(#session.flatTableName#.began_date,6,2)) IN (#inMon#)">
</cfif>
<cfif isdefined("verbatim_date") AND len(verbatim_date) gt 0>
	<cfset mapurl = "#mapurl#&verbatim_date=#verbatim_date#">
	<cfset basQual = " #basQual# AND upper(verbatim_date) LIKE '%#ucase(escapeQuotes(#session.flatTableName#.verbatim_date))#%'">
</cfif>
<cfif isdefined("accn_trans_id") AND len(accn_trans_id) gt 0>
	<cfset mapurl = "#mapurl#&accn_trans_id=#accn_trans_id#">
	<cfif basJoin does not contain " accn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn ON 
		(cataloged_item.accn_id = accn.transaction_id)">
	</cfif>
	<cfset basQual = " #basQual# AND accn.transaction_id IN (#accn_trans_id#)">
</cfif>	
<cfif isdefined("accn_inst") and len(accn_inst) gt 0>
	<cfset mapurl = "#mapurl#&accn_inst=#accn_inst#">
	<cfif basJoin does not contain " accn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn ON 
		(cataloged_item.accn_id = accn.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " trans ">
		<cfset basJoin = " #basJoin# INNER JOIN trans ON 
		(accn.transaction_id=trans.transaction_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(trans.institution_acronym) like '%#ucase(accn_inst)#%'">
</cfif>
<cfif isdefined("accn_number") and len(accn_number) gt 0>
	<cfset mapurl = "#mapurl#&accn_number=#accn_number#">
	<cfif left(accn_number,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.accession) = '#ucase(right(accn_number,len(accn_number)-1))#'">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.accession) LIKE '%#ucase(accn_number)#%'">
	</cfif>
</cfif>
<cfif isdefined("loan_number") and len(loan_number) gt 0>
	<cfset mapurl = "#mapurl#&loan_number=#loan_number#">
	<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id=specimen_part.derived_from_cat_item)
		INNER JOIN loan_item ON (specimen_part.collection_object_id=loan_item.collection_object_id)
		INNER JOIN loan ON (loan_item.transaction_id=loan.transaction_id)">	
	<cfif left(loan_number,1) is '='>
		<cfset basQual = " #basQual# AND upper(loan.loan_number) = '#ucase(right(loan_number,len(loan_number)-1))#'">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(loan.loan_number) LIKE '%#ucase(loan_number)#%'">
	</cfif>
</cfif>
<cfif isdefined("accn_list") and len(accn_list) gt 0>
	<cfset mapurl = "#mapurl#&accn_list=#accn_list#">
	<cfif basJoin does not contain " accn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn ON 
		(cataloged_item.accn_id = accn.transaction_id)">
	</cfif>
	<cfset qal="">
	<cfloop list="#accn_list#" index="a" delimiters=",">
		<cfif len(#qal#) is 0>
			<cfset qal="'#a#'">
		<cfelse>
			<cfset qal="#qal#,'#a#'">
		</cfif>
	</cfloop>
	<cfset basQual = " #basQual# AND upper(accn.accn_number) IN (#ucase(qal)#)">				
</cfif>
<cfif isdefined("accn_agency") and len(accn_agency) gt 0>
	<cfset mapurl = "#mapurl#&accn_agency=#accn_agency#">
	<cfif basJoin does not contain " accn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn ON 
		(cataloged_item.accn_id = accn.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " trans ">
		<cfset basJoin = " #basJoin# INNER JOIN trans ON 
		(accn.transaction_id=trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " accn_agency ">
		<cfset basJoin = " #basJoin# inner join trans_agent on (
			trans.transaction_id = trans_agent.transaction_id)
			INNER JOIN agent_name accn_agency ON 
				(trans_agent.AGENT_ID = accn_agency.agent_id)">
	</cfif>
	<cfset basQual = " #basQual# AND trans_agent.TRANS_AGENT_ROLE='associated with agency' and
			upper(accn_agency.agent_name) LIKE '%#ucase(accn_agency)#%'">
</cfif>
<cfif isdefined("custom_id_prefix") and len(custom_id_prefix) gt 0>
	<cfset mapurl = "#mapurl#&custom_id_prefix=#custom_id_prefix#">
	<cfif basJoin does not contain " customIdentifier ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num customIdentifier ON 
		(cataloged_item.collection_object_id = customIdentifier.collection_object_id)">
	</cfif>
	<cfif #basQual# does not contain "customIdentifier.other_id_type">
		<cfset basQual = " #basQual# AND customIdentifier.other_id_type = '#session.CustomOtherIdentifier#'">
	</cfif>
	<cfset basQual = " #basQual# AND upper(customIdentifier.other_id_prefix) LIKE '%#ucase(custom_id_prefix)#%'">
</cfif>
<cfif isdefined("custom_id_suffix") and len(custom_id_suffix) gt 0>
	<cfset mapurl = "#mapurl#&custom_id_suffix=#custom_id_suffix#">
	<cfif basJoin does not contain " customIdentifier ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num customIdentifier ON 
		(cataloged_item.collection_object_id = customIdentifier.collection_object_id)">
	</cfif>
	<cfif basQual does not contain "customIdentifier.other_id_type">
		<cfset basQual = " #basQual# AND customIdentifier.other_id_type = '#session.CustomOtherIdentifier#'">
	</cfif>
	<cfset basQual = " #basQual# AND upper(customIdentifier.other_id_suffix) LIKE '%#ucase(custom_id_suffixid_prefix)#%'">
</cfif>
<cfif isdefined("custom_id_number") and len(custom_id_number) gt 0>
	<cfset mapurl = "#mapurl#&custom_id_number=#custom_id_number#">
	<cfif basJoin does not contain " customIdentifier ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num customIdentifier ON 
		(cataloged_item.collection_object_id = customIdentifier.collection_object_id)">
	</cfif>
	<cfif basQual does not contain "customIdentifier.other_id_type">
		<cfset basQual = " #basQual# AND customIdentifier.other_id_type = '#session.CustomOtherIdentifier#'">
	</cfif>
	<cfif custom_id_number contains "-">
		<!--- range --->
		<cfset start=listgetat(custom_id_number,1,"-")>
		<cfset stop=listgetat(custom_id_number,2,"-")>
		<cfset basQual = " #basQual# AND customIdentifier.other_id_number between #start# and #stop# ">
	<cfelseif custom_id_number contains ",">
		<cfset CustOidList="">
		<cfloop list="#custom_id_number#" delimiters="," index="v">
			<cfif len(CustOidList) is 0>
				<cfset CustOidList = v>
			<cfelse>
				<cfset CustOidList = "#CustOidList#,#v#">
			</cfif>
		</cfloop>
		<cfset basQual = " #basQual# AND customIdentifier.other_id_number IN ( #CustOidList#) ">
	<cfelseif isnumeric(custom_id_number)>
		<cfset basQual = " #basQual# AND customIdentifier.other_id_number = #custom_id_number# ">
	<cfelse>
		<div class="error">
		Custom ID Number may be any of the following formats:
			<ul>
				<li>An integer (1)</li>
				<li>A comma-separated list (1,3,5)</li>
				<li>A hyphen-separated range (1-5)</li>
			</ul>
			Please use your back button to try again.
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>			
</cfif>
<cfif isdefined("CustomIdentifierValue") and len(CustomIdentifierValue) gt 0>
	<cfif not isdefined("CustomOidOper")>
		<cfset CustomOidOper = "LIKE">
	</cfif>
	<cfset mapurl = "#mapurl#&CustomIdentifierValue=#CustomIdentifierValue#">
	<cfset mapurl = "#mapurl#&CustomOidOper=#CustomOidOper#">
	<cfif basJoin does not contain " customIdentifier ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num customIdentifier ON 
		(cataloged_item.collection_object_id = customIdentifier.collection_object_id)">
	</cfif>
	<cfif basQual does not contain "customIdentifier.other_id_type">
		<cfset basQual = " #basQual# AND customIdentifier.other_id_type = '#session.CustomOtherIdentifier#'">
	</cfif>
	<cfif CustomOidOper is "IS">
		<cfset basQual = " #basQual# AND customIdentifier.DISPLAY_VALUE = '#CustomIdentifierValue#'">
	<cfelseif CustomOidOper is "LIST">
		<cfset CustOidList = "">
		<cfloop list="#CustomIdentifierValue#" delimiters="," index="v">
			<cfif len(#CustOidList#) is 0>
				<cfset CustOidList = "'#v#'">
			<cfelse>
				<cfset CustOidList = "#CustOidList#,'#v#'">
			</cfif>
		</cfloop>
		<cfset basQual = " #basQual# AND upper(customIdentifier.DISPLAY_VALUE) IN (#ucase(CustOidList)#)">
	<cfelseif CustomOidOper is "BETWEEN">
		<cfif CustomIdentifierValue does not contain "-">
			<div class="error">
				You must specify a range of values separated by ' - ' to search for ranges of Your Identifier.
			</div>
			<script>hidePageLoad();</script>
			<cfabort>
		</cfif>
		<cfset dash = find("-",CustomIdentifierValue)>
		<cfset idFrom = left(CustomIdentifierValue,dash-1)>
		<cfset idTo = mid(CustomIdentifierValue,dash+1,len(CustomIdentifierValue))>
		<cfset basQual = " #basQual# AND to_number(customIdentifier.DISPLAY_VALUE) BETWEEN #idFrom# and #idTo#">
	<cfelse><!---- LIKE ---->
		<cfset basQual = " #basQual# AND upper(customIdentifier.DISPLAY_VALUE) LIKE '%#ucase(CustomIdentifierValue)#%'">
	</cfif>
</cfif>
<cfif isdefined("OIDType") AND len(OIDType) gt 0>
	<cfset mapurl = "#mapurl#&OIDType=#OIDType#">	
	<cfif basJoin does not contain " otherIdSearch ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdSearch ON 
		(cataloged_item.collection_object_id = otherIdSearch.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND otherIdSearch.other_id_type = '#OIDType#'">
</cfif>
<cfif isdefined("OIDNum") and len(OIDNum) gt 0>
	<cfif not isdefined("oidOper") OR len(oidOper) is 0>
		<cfset oidOper = "LIKE">
	</cfif>
	<cfset mapurl = "#mapurl#&OIDNum=#OIDNum#">	
	<cfset mapurl = "#mapurl#&oidOper=#oidOper#">	
	<cfif basJoin does not contain " otherIdSearch ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdSearch ON 
		(cataloged_item.collection_object_id = otherIdSearch.collection_object_id)">
	</cfif>
	<cfset oidList="">
	<cfloop list="#OIDNum#" delimiters="," index="i">
		<cfif oidOper is "LIKE">
			<cfif len(oidList) is 0>
				<cfset oidList = "AND ( upper(otherIdSearch.display_value) LIKE '%#ucase(i)#%'">
			<cfelse>
				<cfset oidList = "#oidList# OR upper(otherIdSearch.display_value) LIKE '%#ucase(i)#%'">
			</cfif>
		<cfelse>
			<cfif len(oidList) is 0>
				<cfset oidList = "AND ( otherIdSearch.display_value = '#i#'">
			<cfelse>
				<cfset oidList = "#oidList# OR otherIdSearch.display_value = '#i#'">
			</cfif>
		</cfif>
	</cfloop>
	<cfset oidList = "#oidList# )">
	<cfset basQual = " #basQual# #oidList#">
</cfif>
<cfif isdefined("continent_ocean") AND len(continent_ocean) gt 0>
	<cfif compare(continent_ocean,"NULL") is 0>
		<cfset basQual = " #basQual# AND continent_ocean is null">
	<cfelse>
		<cfset basQual = " #basQual# AND continent_ocean = '#continent_ocean#'">
	</cfif>					
	<cfset mapurl = "#mapurl#&continent_ocean=#continent_ocean#">			
</cfif>
<cfif isdefined("sea") AND len(sea) gt 0>
	<cfif compare(sea,"NULL") is 0>
		<cfset basQual = " #basQual# AND sea is null">
	<cfelse>
		<cfset basQual = " #basQual# AND sea LIKE '#sea#'">
	</cfif>					
	<cfset mapurl = "#mapurl#&sea=#sea#">			
</cfif>
<cfif isdefined("Country") AND len(Country) gt 0>
	<cfif compare(country,"NULL") is 0>
		<cfset basQual = " #basQual# AND country is null">
	<cfelse>
		<cfset basQual = " #basQual# AND country = '#Country#'">
	</cfif>					
	<cfset mapurl = "#mapurl#&Country=#Country#">
</cfif>
<cfif isdefined("state_prov") AND len(state_prov) gt 0>
	<cfif compare(state_prov,"NULL") is 0>
		<cfset basQual = " #basQual# AND state_prov is null">
	<cfelseif state_prov contains "|">
		<cfset i=1>
		<cfset basQual = " #basQual# AND ( ">
			<cfloop list="#state_prov#" index="s" delimiters="|">
				  <cfif i gt 1>
				 	<cfset basQual = " #basQual# OR ">
				 </cfif>
				 <cfset basQual = " #basQual# UPPER(state_prov) LIKE '%#UCASE(trim(s))#%'">
				 <cfset i=i+1>
			</cfloop>
		<cfset basQual = " #basQual# ) ">
	<cfelse>
		<cfset basQual = " #basQual# AND UPPER(state_prov) LIKE '%#UCASE(state_prov)#%'">
	</cfif>				
	<cfset mapurl = "#mapurl#&state_prov=#state_prov#">
</cfif>
<cfif isdefined("island_group") AND len(island_group) gt 0>
	<cfif compare(island_group,"NULL") is 0>
		<cfset basQual = " #basQual# AND island_group is null">
	<cfelse>
		<cfset basQual = " #basQual# AND Island_Group LIKE '#island_group#'">
	</cfif>
	<cfset mapurl = "#mapurl#&island_group=#island_group#">
</cfif>
<cfif isdefined("Island") AND len(Island) gt 0>
	<cfif compare(Island,"NULL") is 0>
		<cfset basQual = " #basQual# AND Island is null">
	<cfelse>
		<cfset basQual = " #basQual# AND UPPER(Island) LIKE '%#UCASE(Island)#%'">
	</cfif>			
	<cfset mapurl = "#mapurl#&island=#island#">
</cfif>
<cfif (isdefined("min_max_error") AND len(min_max_error) gt 0) or (isdefined("max_max_error") AND len(max_max_error) gt 0)>
	<cfif not isdefined("max_error_units") or len(max_error_units) is 0>
		<cfset max_error_units='m'>
	</cfif>
	<cfif not isnumeric(min_max_error) or not isnumeric(max_max_error)>
		<div class="error">
			Maximum Error must be numeric.
		</div>
		<script>hidePageLoad();</script>	  
		<cfabort>
	</cfif>
	<cfif len(min_max_error) is 0>
		<cfset min_max_error=0>
	</cfif>
	<cfif len(max_max_error) is 0>
		<cfset max_max_error=9999999999>
	</cfif>
	<cfset mapurl = "#mapurl#&min_max_error=#min_max_error#&max_max_error=#max_max_error#&max_error_units=#max_error_units#">
	<cfif basJoin does not contain " lat_long ">
		<cfset basJoin = " #basJoin# INNER JOIN lat_long ON (#session.flatTableName#.locality_id = lat_long.locality_id)">
	</cfif>
	<cfset basQual = " #basQual# AND lat_long.accepted_lat_long_fg=1">
	<cfset basQual = " #basQual# AND to_meters(lat_long.max_error_distance,max_error_units) between 
		to_meters(#min_max_error#,'#max_error_units#') and to_meters(#max_max_error#,'#max_error_units#')">
</cfif>
<cfif isdefined("max_error_in_meters") AND len(max_error_in_meters) gt 0>
	<cfif not isnumeric(max_error_in_meters)>
		<div class="error">max_error_in_meters must be numeric.</div>
		<script>hidePageLoad();</script>		  
		<cfabort>
	</cfif>
  	<cfset mapurl = "#mapurl#&max_error_in_meters=#max_error_in_meters#">
	<cfset basQual = " #basQual# AND coORDINATEUNCERTAINTYINMETERS <= #max_error_in_meters#">
	<cfif max_error_in_meters gt 0>
		<cfset basQual = " #basQual# AND coORDINATEUNCERTAINTYINMETERS > 0">
	</cfif>
</cfif>
<cfif isdefined("chronological_extent") AND len(chronological_extent) gt 0>
	<cfif not isnumeric(chronological_extent)>
		<div class="error">chronological_extent must be numeric.</div>
		<script>hidePageLoad();</script>	  
		<cfabort>
	</cfif>
	<cfset mapurl = "#mapurl#&chronological_extent=#chronological_extent#">
	<cfset basQual = " #basQual# AND
					length(#session.flatTableName#.ended_date)>=10 and
					length(#session.flatTableName#.began_date)>=10 and
					(				
						to_number(to_char(to_date(substr(#session.flatTableName#.ended_date,1,10),'yyyy-mm-dd'),'J')) - 
						to_number(to_char(to_date(substr(#session.flatTableName#.began_date,1,10),'yyyy-mm-dd'),'J'))
					)
					<= #chronological_extent#">
</cfif>
<cfif (isdefined("NWLat") and len(NWLat) gt 0)
	OR (isdefined("NWLong") and len(NWLong) gt 0)
	OR (isdefined("SELat") and len(SELat) gt 0)
	OR (isdefined("SELong") and len(SELong) gt 0)>
	<!--- got at least one point, see if we got enough to run ---->
	<cfif (isdefined("NWLat") and isnumeric(NWLat))
		AND (isdefined("NWLong") and isnumeric(NWLong))
		AND (isdefined("SELat") and isnumeric(SELat))
		AND (isdefined("SELong") and isnumeric(SELong))>
		<cfset basQual = " #basQual# AND dec_lat BETWEEN #SELat# AND #NWLat#">
		<cfif nwlong gt 0 and selong lt 0>
			<cfset basQual = " #basQual# AND (dec_long between #nwlong# and 180 OR dec_long between -180 and #selong#)">
		<cfelse>
			<cfset basQual = " #basQual# AND dec_long BETWEEN #NWLong# AND #SELong#">
		</cfif>
		<cfset mapurl = "#mapurl#&NWLat=#NWLat#&NWLong=#NWLong#&SELat=#SELat#&SELong=#SELong#">
	<cfelse>
		<div class="error">
			You entered at least one bounding box point, but didn't enter sufficient
			information to finish the query. To search by bounding box, you must specify 2 coordinate sets
			in decimal latitude format.
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
</cfif>
<cfif isdefined("spec_locality") and len(spec_locality) gt 0>
	<cfset mapurl = "#mapurl#&spec_locality=#spec_locality#">
	<cfif compare(spec_locality,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.spec_locality is null">
	<cfelse>
		<cfif left(spec_locality,1) is '='>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.spec_locality) = '#ucase(escapeQuotes(right(spec_locality,len(spec_locality)-1)))#'">
		<cfelse>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.spec_locality) like '%#ucase(escapeQuotes(spec_locality))#%'">
		</cfif>
	</cfif>	
</cfif>
<cfif isdefined("verbatim_locality") and len(verbatim_locality) gt 0>
	<cfset mapurl = "#mapurl#&verbatim_locality=#verbatim_locality#">
	<cfif basJoin does not contain " collecting_event ">
		<cfset basJoin = " #basJoin# INNER JOIN collecting_event ON (cataloged_item.collecting_event_id = collecting_event.collecting_event_id)">
	</cfif>
	<cfif left(verbatim_locality,1) is '='>
		<cfset basQual = " #basQual# AND upper(collecting_event.verbatim_locality) = '#ucase(escapeQuotes(right(verbatim_locality,len(verbatim_locality)-1)))#'">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(collecting_event.verbatim_locality) like '%#ucase(escapeQuotes(verbatim_locality))#%'">
	</cfif>	
</cfif>
<cfif isdefined("minimum_elevation") and len(minimum_elevation) gt 0>
	<cfif not isdefined("orig_elev_units") OR len(#orig_elev_units#) is 0>
		<div class="error">You must supply units to search by elevation.</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfif not isnumeric(minimum_elevation)>
		<div class="error">Minimum Elevation must be numeric.</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset basQual = " #basQual# AND MIN_ELEV_IN_M >= #getMeters(minimum_elevation,orig_elev_units)#" >
	<cfset mapurl = "#mapurl#&minimum_elevation=#minimum_elevation#">
</cfif>
<cfif isdefined("maximum_elevation") and len(maximum_elevation) gt 0>
	<cfif not isdefined("orig_elev_units") OR len(orig_elev_units) is 0>
		<div class="error">You must supply units to search by elevation.</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfif not isnumeric(maximum_elevation)>
		<div class="error">Maximum Elevation must be numeric.</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset basQual = " #basQual# AND MAX_ELEV_IN_M <= #getMeters(maximum_elevation,orig_elev_units)#" >
	<cfset mapurl = "#mapurl#&maximum_elevation=#maximum_elevation#">
</cfif>
<cfif isdefined("feature") AND len(feature) gt 0>
	<cfif compare(feature,"NULL") is 0>
		<cfset basQual = " #basQual# AND feature is null">
	<cfelse>
		<cfset basQual = " #basQual# AND feature LIKE '#escapeQuotes(feature)#'">
	</cfif>		
	<cfset mapurl = "#mapurl#&feature=#feature#">
</cfif>
<cfif isdefined("any_geog") AND len(any_geog) gt 0>
	<cfset mapurl = "#mapurl#&any_geog=#any_geog#">
	<cfif replace(basJoin,"collecting_event flatCollEvent","","all") does not contain " collecting_event ">
		<cfset basJoin = " #basJoin# INNER JOIN collecting_event ON 
		(cataloged_item.collecting_event_id = collecting_event.collecting_event_id)">
	</cfif>
	<cfset basQual = " #basQual# AND 
		upper(#session.flatTableName#.higher_geog) || ' ' || upper(#session.flatTableName#.spec_locality)
			|| ' ' || upper(collecting_event.verbatim_locality)  LIKE '%#ucase(escapeQuotes(any_geog))#%'">
</cfif>
<cfif isdefined("geog_auth_rec_id") AND len(geog_auth_rec_id) gt 0>
	<cfset basQual = " #basQual# AND #session.flatTableName#.geog_auth_rec_id=#geog_auth_rec_id#">
	<cfset mapurl = "#mapurl#&geog_auth_rec_id=#geog_auth_rec_id#">
</cfif>
<cfif isdefined("higher_geog") AND len(higher_geog) gt 0>
	<cfset basQual = " #basQual# AND upper(higher_geog) LIKE '%#ucase(higher_geog)#%'">
	<cfset mapurl = "#mapurl#&higher_geog=#higher_geog#">
</cfif>
<cfif isdefined("county") AND len(county) gt 0>
	<cfif compare(County,"NULL") is 0>
		<cfset basQual = " #basQual# AND County is null">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(County) LIKE '%#UCASE(County)#%'">
	</cfif>				
	<cfset mapurl = "#mapurl#&county=#county#">
</cfif>
<cfif isdefined("inCounty") AND len(inCounty) gt 0>
	<cfset tCounty = "">
	<cfloop list="#inCounty#" delimiters="," index="i">
		<cfif len(#tCounty#) is 0>
			<cfset tCounty = "'#i#'">
		<cfelse>
			<cfset tCounty = "#tCounty#,'#i#'">
		</cfif>
	</cfloop>
	<cfset basQual = " #basQual# AND County IN (#tCounty#)">
	<cfset mapurl = "#mapurl#&inCounty=#inCounty#">
</cfif>
<cfif isdefined("Quad") AND len(Quad) gt 0>
	<cfif compare(Quad,"NULL") is 0>
		<cfset basQual = " #basQual# AND Quad is null">
	<cfelse>
		<cfset basQual = " #basQual# AND UPPER(Quad) LIKE '%#UCASE(Quad)#%'">
	</cfif>
  <cfset mapurl = "#mapurl#&quad=#quad#">
</cfif>
<cfif isdefined("partname") AND len(partname) gt 0>
	<cfset part_name=partname>
</cfif>		
<cfif isdefined("part_name") AND len(part_name) gt 0>
	<cfset mapurl = "#mapurl#&part_name=#part_name#">
	<cfif part_name contains "|">
		<cfset i=1>
		<cfloop list="#part_name#" delimiters="|" index="p">
			<cfset basJoin = " #basJoin# INNER JOIN specimen_part sp#i# ON 
				(cataloged_item.collection_object_id = sp#i#.derived_from_cat_item)">
			<cfset basQual = " #basQual# AND sp#i#.part_name = '#p#'">
			<cfset i=i+1>
		</cfloop>
	<cfelseif left(part_name,1) is '='>
		<cfif basJoin does not contain " specimen_part ">
			<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON 
			(cataloged_item.collection_object_id = specimen_part.derived_from_cat_item)">
		</cfif>
		<cfset basQual = " #basQual# AND specimen_part.part_name = '#right(part_name,len(part_name)-1)#'">
	<cfelse><!--- part name only --->		
		<cfset basQual = " #basQual# AND upper(PARTS) LIKE '%#ucase(part_name)#%'">
	</cfif>
</cfif>
<cfif isdefined("is_tissue") AND is_tissue is 1>
	<cfset mapurl = "#mapurl#&is_tissue=#is_tissue#">
	<cfset basJoin = " #basJoin# INNER JOIN specimen_part spt ON (cataloged_item.collection_object_id = spt.derived_from_cat_item)
		inner join collection spcn on (cataloged_item.collection_id=spcn.collection_id)
		inner join ctspecimen_part_name on (spt.part_name=ctspecimen_part_name.part_name)">	
	<cfset basQual = " #basQual# AND ctspecimen_part_name.is_tissue = 1">
</cfif>
<cfif isdefined("part_disposition") AND len(part_disposition) gt 0>
	<cfset basJoin = " #basJoin# 
			INNER JOIN specimen_part spdisp ON (#session.flatTableName#.collection_object_id = spdisp.derived_from_cat_item)
			inner join coll_object partCollObj on (spdisp.collection_object_id=partCollObj.collection_object_id)">
	<cfset basQual = " #basQual# AND partCollObj.coll_obj_disposition='#part_disposition#'">
	<cfset mapurl = "#mapurl#&part_disposition=#part_disposition#">
</cfif>
<cfif isdefined("srchParts") AND len(srchParts) gt 0>
	<cfif basJoin does not contain " specimen_part ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON 
		(cataloged_item.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfset basQual = " #basQual# 
		AND specimen_part.part_name in (
			SELECT part_name FROM
			part_hierarchy
			start with upper(part_name) LIKE '%#ucase(srchParts)#%'
			connect by prior parent_part_id = part_id)">
	<cfset mapurl = "#mapurl#&srchParts=#srchParts#">
</cfif>
<cfif isdefined("Common_Name") AND len(Common_Name) gt 0>
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON 
		(cataloged_item.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON 
		(identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfif basJoin does not contain " common_name ">
		<cfset basJoin = " #basJoin# INNER JOIN common_name ON 
		(identification_taxonomy.taxon_name_id = common_name.taxon_name_id)">
	</cfif>
	<cfset basQual = " #basQual# AND identification.accepted_id_fg = 1 AND
		 UPPER(common_name.Common_Name) LIKE '%#ucase(stripQuotes(Common_Name))#%'">
	<cfset mapurl = "#mapurl#&Common_Name=#Common_Name#">
</cfif>
<cfif isdefined("cited_taxon_name_id") AND len(cited_taxon_name_id) gt 0>
	<cfif basJoin does not contain " citation ">
		<cfset basJoin = " #basJoin# INNER JOIN citation ON 
		(cataloged_item.collection_object_id = citation.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND citation.cited_taxon_name_id = #cited_taxon_name_id#">
	<cfset mapurl = "#mapurl#&cited_taxon_name_id=#cited_taxon_name_id#">
</cfif>
<cfif isdefined("publication_id") AND len(publication_id) gt 0>
	<cfif basJoin does not contain " citation ">
		<cfset basJoin = " #basJoin# INNER JOIN citation ON 
		(cataloged_item.collection_object_id = citation.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND publication_id = #publication_id#">
	<cfset mapurl = "#mapurl#&publication_id=#publication_id#">
</cfif>
<cfif isdefined("relationship") AND len(relationship) gt 0>
	<cfif basJoin does not contain " biol_indiv_relations ">
		<cfset basJoin = " #basJoin# INNER JOIN biol_indiv_relations ON 
		(cataloged_item.collection_object_id = biol_indiv_relations.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND biol_indiv_relations.biol_indiv_relationship = '#relationship#'">
	<cfset mapurl = "#mapurl#&relationship=#relationship#">
</cfif>
<cfif isdefined("derived_relationship") AND len(derived_relationship) gt 0>
	<cfif derived_relationship is "offspring of">
		<cfset srchReln = "parent of">
		<cfif basJoin does not contain " invRelns ">
			<cfset basJoin = " #basJoin# INNER JOIN biol_indiv_relations invRelns ON 
			(cataloged_item.collection_object_id = invRelns.collection_object_id)">
		</cfif>
		<cfset basQual = " #basQual# AND invRelns.BIOL_INDIV_RELATIONSHIP = '#srchReln#'">
	<cfelse>
		<div class="error">
			I don't know how to handle relationship <cfoutput>"#derived_relationship#".</cfoutput>
			<br />
			Please submit a <a href="/info/bugs.cfm">bug report.</a>
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset mapurl = "#mapurl#&derived_relationship=#derived_relationship#">
</cfif>
<cfif isdefined("type_status") and len(type_status) gt 0>
	<cfif #type_status# is "any">
		<cfset basQual = " #basQual# AND #session.flatTableName#.TYPESTATUS IS NOT NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.TYPESTATUS) LIKE '%#ucase(type_status)#%'">
	</cfif>
	<cfset mapurl = "#mapurl#&type_status=#type_status#">
</cfif>
<cfif isdefined("collection_object_id") AND len(collection_object_id) gt 0>
	<cfset basQual = " #basQual# AND cataloged_item.collection_object_id IN (#collection_object_id#)">
	<cfset mapurl = "#mapurl#&collection_object_id=#collection_object_id#">
</cfif>
<cfif isdefined("taxon_name_id") AND len(taxon_name_id) gt 0>
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON 
		(cataloged_item.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON 
		(identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfset basQual = " #basQual# AND identification_taxonomy.taxon_name_id = #taxon_name_id#
		AND identification.accepted_id_fg=1">
	<cfset mapurl = "#mapurl#&taxon_name_id=#taxon_name_id#">
</cfif>

<cfif isdefined("project_id") AND len(project_id) gt 0>
	<cfif basJoin does not contain " projAccn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn projAccn ON 
		(cataloged_item.accn_id = projAccn.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " project_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN project_trans ON 
		(projAccn.transaction_id = project_trans.transaction_id)">
	</cfif>
	<cfset basQual = " #basQual# AND project_trans.project_id = #project_id#">
	<cfset mapurl = "#mapurl#&project_id=#project_id#">
</cfif>

<cfif isdefined("project_sponsor") AND len(project_sponsor) gt 0>
	<cfset basJoin = " #basJoin# INNER JOIN project_trans sProjTrans ON
		(cataloged_item.accn_id = sProjTrans.transaction_id)
		INNER JOIN project_sponsor ON (
			sProjTrans.project_id = project_sponsor.project_id)
		INNER JOIN agent_name sAgentName ON (project_sponsor.agent_name_id = sAgentName.agent_name_id)"> 
	<cfset basQual = " #basQual# AND upper(sAgentName.agent_name) LIKE '%#ucase(project_sponsor)#%'">
	<cfset mapurl = "#mapurl#&project_sponsor=#project_sponsor#">
</cfif>

<cfif isdefined("loan_project_name") AND len(loan_project_name) gt 0>
	<cfif basJoin does not contain " specimen_part ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON 
		(cataloged_item.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfif basJoin does not contain " loan_item ">
		<cfset basJoin = " #basJoin# INNER JOIN loan_item ON 
		(specimen_part.collection_object_id = loan_item.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " project_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN project_trans ON 
		(loan_item.transaction_id = project_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " project ">
		<cfset basJoin = " #basJoin# INNER JOIN project ON 
		(project_trans.project_id = project.project_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(regexp_replace(project.project_name,'<[^>]*>')) like '%#ucase(loan_project_name)#%'">
	<cfset mapurl = "#mapurl#&loan_project_name=#loan_project_name#">
</cfif>

<cfif isdefined("loan_project_id") AND len(loan_project_id) gt 0>
	<cfset mapurl = "#mapurl#&loan_project_id=#loan_project_id#">
	<cfset basQual = " #basQual# AND cataloged_item.collection_object_id IN (
		SELECT 
			cataloged_item.collection_object_id
		FROM 
			cataloged_item,
			specimen_part,
			loan_item,
			project_trans
		WHERE
			specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
			specimen_part.collection_object_id = loan_item.collection_object_id AND
			loan_item.transaction_id = project_trans.transaction_id AND
			project_trans.project_id = #loan_project_id#
		)">
</cfif>
<cfif isdefined("project_name") AND len(project_name) gt 0>
	<cfif basJoin does not contain " projAccn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn projAccn ON 
		(cataloged_item.accn_id = projAccn.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " project_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN project_trans ON 
		(projAccn.transaction_id = project_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " project ">
		<cfset basJoin = " #basJoin# INNER JOIN project ON 
		(project_trans.project_id = project.project_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(regexp_replace(project.project_name,'<[^>]*>')) like '%#ucase(project_name)#%'">
	<cfset mapurl = "#mapurl#&project_name=#project_name#">
</cfif>

<cfif isdefined("collecting_event_id") AND len(collecting_event_id) gt 0>
	<cfset basQual = " #basQual# AND #session.flatTableName#.collecting_event_id IN ( #collecting_event_id# )">
	<cfset mapurl = "#mapurl#&collecting_event_id=#collecting_event_id#">
</cfif>

<cfif isdefined("locality_id") AND len(locality_id) gt 0>
	<cfset basQual = " #basQual# AND #session.flatTableName#.locality_id = #locality_id#">
	<cfset mapurl = "#mapurl#&locality_id=#locality_id#">
</cfif>

<cfif isdefined("subject") AND len(subject) gt 0>
	<cfif basJoin does not contain " binary_object ">
		<cfset basJoin = " #basJoin# INNER JOIN binary_object ON 
		(cataloged_item.collection_object_id = binary_object.derived_from_cat_item)">
	</cfif>
	<cfset basQual = " #basQual# AND binary_object.subject = '#subject#'">
	<cfset mapurl = "#mapurl#&subject=#subject#">
</cfif>
<cfif isdefined("loan_trans_id") and len(loan_trans_id) gt 0>
	<cfset mapurl = "#mapurl#&loan_trans_id=#loan_trans_id#">
	<cfset basQual = " #basQual# AND cataloged_item.collection_object_id IN (
		select derived_from_cat_item from specimen_part,loan_item where 
			specimen_part.collection_object_id=loan_item.collection_object_id and loan_item.transaction_id=#loan_trans_id#
			)">
</cfif>

<cfif isdefined("loan_permit_trans_id") and len(loan_permit_trans_id) gt 0>
	<cfset mapurl = "#mapurl#&loan_permit_trans_id=#loan_permit_trans_id#">
	<cfif basJoin does not contain " loan_permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part loan_part ON 
				(cataloged_item.collection_object_id = loan_part.derived_from_cat_item)
				INNER JOIN loan_item ON (loan_part.collection_object_id = loan_item.collection_object_id)
				INNER JOIN permit_trans loan_permit_trans ON 
					(loan_item.transaction_id = loan_permit_trans.transaction_id)">
	</cfif>
	<cfset basQual = " #basQual# AND loan_permit_trans.transaction_id IN (#loan_permit_trans_id#)">
</cfif>
<cfif isdefined("accn_permit_trans_id") and len(accn_permit_trans_id) gt 0>
	<cfset mapurl = "#mapurl#&accn_permit_trans_id=#accn_permit_trans_id#">
	<cfif basJoin does not contain " permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON 
		(cataloged_item.accn_id = permit_trans.transaction_id)">
	</cfif>
	<cfset basQual = " #basQual# AND permit_trans.transaction_id IN (#accn_permit_trans_id#)">
</cfif>
<cfif isdefined("permit_issued_by") AND len(permit_issued_by) gt 0>
	<cfset mapurl = "#mapurl#&permit_issued_by=#permit_issued_by#">
	<cfif basJoin does not contain " permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON 
		(cataloged_item.accn_id = permit_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " permit ">
		<cfset basJoin = " #basJoin# INNER JOIN permit ON 
		(permit_trans.permit_id = permit.permit_id)">
	</cfif>
	<cfif basJoin does not contain " permit_issued ">
		<cfset basJoin = " #basJoin# INNER JOIN agent_name permit_issued ON 
		(permit.issued_by_agent_id = permit_issued.agent_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(permit_issued.agent_name) like '%#ucase(permit_issued_by)#%'">
</cfif>
<cfif isdefined("permit_issued_to") AND len(permit_issued_to) gt 0>
	<cfset mapurl = "#mapurl#&permit_issued_to=#permit_issued_to#">
	<cfif basJoin does not contain " permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON 
		(cataloged_item.accn_id = permit_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " permit ">
		<cfset basJoin = " #basJoin# INNER JOIN permit ON 
		(permit_trans.permit_id = permit.permit_id)">
	</cfif>
	<cfif basJoin does not contain " permit_to ">
		<cfset basJoin = " #basJoin# INNER JOIN agent_name permit_to ON 
		(permit.issued_by_agent_id = permit_to.agent_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(permit_to.agent_name) like '%#ucase(permit_issued_to)#%'">
</cfif>

<cfif isdefined("permit_type") AND len(permit_type) gt 0>
<cfset mapurl = "#mapurl#&permit_type=#permit_type#">
	<cfif basJoin does not contain " permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON 
		(cataloged_item.accn_id = permit_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " permit ">
		<cfset basJoin = " #basJoin# INNER JOIN permit ON 
		(permit_trans.permit_id = permit.permit_id)">
	</cfif>
	<cfset basQual = " #basQual# AND permit_type='#escapeQuotes(permit_type)#'">
</cfif>

<cfif isdefined("permit_num") AND len(permit_num) gt 0>
	<cfset mapurl = "#mapurl#&permit_num=#permit_num#">
	<cfif basJoin does not contain " permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON 
		(cataloged_item.accn_id = permit_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " permit ">
		<cfset basJoin = " #basJoin# INNER JOIN permit ON 
		(permit_trans.permit_id = permit.permit_id)">
	</cfif>
	<cfset basQual = " #basQual# AND permit_num='#permit_num#'">
</cfif>

<cfif isdefined("collecting_source") AND len(collecting_source) gt 0>
	<cfset mapurl = "#mapurl#&collecting_source=#collecting_source#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.collecting_source='#collecting_source#'">
</cfif>
<cfif isdefined("remark") AND len(remark) gt 0>
	<cfset mapurl = "#mapurl#&remark=#remark#">
	<cfset basQual = " #basQual# AND upper(#session.flatTableName#.remarks) LIKE '%#ucase(remark)#%'">
</cfif>
<cfif isdefined("attributed_determiner_agent_id") AND len(attributed_determiner_agent_id) gt 0>
	<cfset mapurl = "#mapurl#&attributed_determiner_agent_id=#attributed_determiner_agent_id#">
	<cfif basJoin does not contain " attributes ">
		<cfset basJoin = " #basJoin# INNER JOIN attributes ON 
		(cataloged_item.collection_object_id = attributes.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND attributes.determined_by_agent_id = #attributed_determiner_agent_id#">
</cfif>
<cfif isdefined("attribute_type") AND len(attribute_type) gt 0>
	<cfset attribute_type_1=attribute_type>
</cfif>
<cfif isdefined("attribute_operator") AND len(attribute_operator) gt 0>
	<cfset attOper_1=attribute_operator>
</cfif>
<cfif isdefined("attribute_value") AND len(attribute_value) gt 0>
	<cfset attribute_value_1=attribute_value>
</cfif>
<cfif isdefined("attribute_type_1") AND len(attribute_type_1) gt 0>
	<cfset mapurl = "#mapurl#&attribute_type_1=#attribute_type_1#">
	<cfif basJoin does not contain " attributes_1 ">
		<cfset basJoin = " #basJoin# INNER JOIN attributes attributes_1 ON 
		(cataloged_item.collection_object_id = attributes_1.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND attributes_1.attribute_type = '#attribute_type_1#'">
	<cfif not isdefined("attOper_1") or len(#attOper_1#) is 0>
		<cfset attOper_1 = "equals">
	</cfif>
	<cfset mapurl = "#mapurl#&attOper_1=#attOper_1#">
	<cfif isdefined("attribute_value_1") and len(attribute_value_1) gt 0>
		<cfset mapurl = "#mapurl#&attribute_value_1=#attribute_value_1#">
		<cfset attribute_value_1 = #replace(attribute_value_1,"'","''","all")#>
		<cfif attOper_1 is "like">
			<cfset basQual = " #basQual# AND upper(attributes_1.attribute_value) LIKE '%#ucase(attribute_value_1)#%'">
		<cfelseif attOper_1 is "equals" >
			<cfset basQual = " #basQual# AND attributes_1.attribute_value = '#attribute_value_1#'">
		<cfelseif attOper_1 is "greater" >
			<cfif isnumeric(attribute_value_1)>
				<cfset basQual = " #basQual# AND to_number(attributes_1.attribute_value) > #attribute_value_1#">
			<cfelse>
			  	<div class="error">
					You tried to search for attribute values greater than a non-numeric value.
				</div>
				<script>hidePageLoad();</script>
				<cfabort>
			</cfif>
		<cfelseif attOper_1 is "less" >
			<cfif isnumeric(#attribute_value_1#)>
				<cfset basQual = " #basQual# AND attributes_1.attribute_value < #attribute_value_1#">
			<cfelse>
				<div class="error">
					You tried to search for attribute values less than a non-numeric value.
				</div>
				<script>hidePageLoad();</script>
			</cfif>
		</cfif>
	</cfif>
	<cfif isdefined("attribute_units_1") AND len(attribute_units_1) gt 0>
		<cfset basQual = " #basQual# AND attributes_1.attribute_units = '#attribute_units_1#'">
	</cfif>
</cfif>

<cfif isdefined("attribute_type_2") AND len(attribute_type_2) gt 0>
	<cfset mapurl = "#mapurl#&attribute_type_2=#attribute_type_2#">
	<cfif basJoin does not contain " attributes_2 ">
		<cfset basJoin = " #basJoin# INNER JOIN attributes attributes_2 ON 
		(cataloged_item.collection_object_id = attributes_2.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND attributes_2.attribute_type = '#attribute_type_2#'">
	<cfif not isdefined("attOper_2") or len(attOper_2) is 0>
		<cfset attOper_2 = "equals">
	</cfif>
	<cfset mapurl = "#mapurl#&attOper_2=#attOper_2#">
	<cfif isdefined("attribute_value_2") and len(#attribute_value_2#) gt 0>
		<cfset mapurl = "#mapurl#&attribute_value_2=#attribute_value_2#">
		<cfset attribute_value_2 = #replace(attribute_value_2,"'","''","all")#>
		<cfif attOper_2 is "like">
			<cfset basQual = " #basQual# AND upper(attributes_2.attribute_value) LIKE '%#ucase(attribute_value_2)#%'">
		<cfelseif attOper_2 is "equals" >
			<cfset basQual = " #basQual# AND attributes_2.attribute_value = '#attribute_value_2#'">
		<cfelseif attOper_2 is "greater" >
			<cfif isnumeric(attribute_value_2)>
				<cfset basQual = " #basQual# AND to_number(attributes_2.attribute_value) > #attribute_value_2#">
			<cfelse>
			  	<div class="error">
					You tried to search for attribute values greater than a non-numeric value.
				</div>
				<script>hidePageLoad();</script>
				<cfabort>
			</cfif>
		<cfelseif attOper_2 is "less" >
			<cfif isnumeric(attribute_value_2)>
				<cfset basQual = " #basQual# AND attributes_2.attribute_value < #attribute_value_2#">
			<cfelse>
				<div class="error">
					You tried to search for attribute values less than a non-numeric value.
				</div>
				<script>hidePageLoad();</script>
				<cfabort>
			</cfif>
		</cfif>
	</cfif>
	<cfif isdefined("attribute_units_2") AND len(attribute_units_2) gt 0>
		<cfset basQual = " #basQual# AND attributes_2.attribute_units = '#attribute_units_2#'">
	</cfif>
</cfif>
<cfif isdefined("attribute_type_3") AND len(attribute_type_3) gt 0>
	<cfset mapurl = "#mapurl#&attribute_type_3=#attribute_type_3#">
	<cfif basJoin does not contain " attributes_3 ">
		<cfset basJoin = " #basJoin# INNER JOIN attributes attributes_3 ON 
		(cataloged_item.collection_object_id = attributes_3.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND attributes_3.attribute_type = '#attribute_type_3#'">
	<cfif not isdefined("attOper_3") or len(attOper_3) is 0>
		<cfset attOper_3 = "equals">
	</cfif>
	<cfset mapurl = "#mapurl#&attOper_3=#attOper_3#">
	<cfif isdefined("attribute_value_3") and len(attribute_value_3) gt 0>
		<cfset mapurl = "#mapurl#&attribute_value_3=#attribute_value_3#">
		<cfset attribute_value_3 = #replace(attribute_value_3,"'","''","all")#>
		<cfif attOper_3 is "like">
			<cfset basQual = " #basQual# AND upper(attributes_3.attribute_value) LIKE '%#ucase(attribute_value_3)#%'">
		<cfelseif attOper_3 is "equals" >
			<cfset basQual = " #basQual# AND attributes_3.attribute_value = '#attribute_value_3#'">
		<cfelseif attOper_3 is "greater" >
			<cfif isnumeric(#attribute_value_3#)>
				<cfset basQual = " #basQual# AND to_number(attributes_3.attribute_value) > #attribute_value_3#">
			<cfelse>
			  	<div class="error">
					You tried to search for attribute values greater than a non-numeric value.
				</div>
				<script>hidePageLoad();</script>
				<cfabort>
			</cfif>
		<cfelseif attOper_3 is "less" >
			<cfif isnumeric(#attribute_value_3#)>
				<cfset basQual = " #basQual# AND attributes_3.attribute_value < #attribute_value_3#">
			<cfelse>
				<div class="error">
					You tried to search for attribute values less than a non-numeric value.
				</div>
				<script>hidePageLoad();</script>
				<cfabort>
			</cfif>
		</cfif>
	</cfif>
	<cfif isdefined("attribute_units_3") AND len(attribute_units_3) gt 0>
		<cfset basQual = " #basQual# AND attributes_3.attribute_units = '#attribute_units_3#'">
	</cfif>
</cfif>
<cfif isdefined("exclCollObjId") and len(exclCollObjId) gt 0>
	<cfset mapurl = "#mapurl#&exclCollObjId=#exclCollObjId#">
	<!---- need to strip out any extra commas before we do anything ---->
	<cfset exclCollObjId = trim(exclCollObjId)>
	<cfif left(exclCollObjId,1) is ",">
		<cfset exclCollObjId = right(exclCollObjId,len(exclCollObjId)-1)>
	</cfif>
	<cfif right(exclCollObjId,1) is ",">
		<cfset exclCollObjId = left(exclCollObjId,len(exclCollObjId)-1)>
	</cfif>
	<cfset brkPnt=1>
	<CFLOOP CONDITION="brkPnt LESS THAN OR EQUAL TO 5">
		<cfset exclCollObjId = replace(exclCollObjId,",,",",","all")>
		<cfif exclCollObjId does not contain ",,">
			<cfset brkPnt=999999>
		</cfif>			
	</CFLOOP>
	<cfset basQual = " #basQual# AND cataloged_item.collection_object_id NOT IN (#exclCollObjId#)">
</cfif>
<cfif isdefined("institution_appearance") AND len(institution_appearance) gt 0>
	<cfquery name="whatInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection_id from collection where institution_acronym='#institution_appearance#'
	</cfquery>
	<cfset goodCollIds = valuelist(whatInst.collection_id,",")>
	<cfset basQual = " #basQual# AND cataloged_item.collection_id  IN (#goodCollIds#)">
</cfif>	