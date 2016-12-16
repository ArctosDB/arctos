<cfset utilities = CreateObject("component","component.utilities")>
<cfset getFlatSQL=utilities.getFlatSQL>
<!----------------------------------------------------------------------------------------------------------->
<cfset extendedErrorMsg="">
<cfif not isdefined("basQual")>
	<cfset basQual = "">
</cfif>
<cfif not isdefined("mapurl")>
	<cfset mapurl="">
</cfif>
<cfif not isdefined("escapeQuotes")>
	<cfinclude template="/includes/functionLib.cfm">
</cfif>
<!----------------------------------- translate deprecated terms when possible ---------------------------->
<cfif isdefined("listcatnum")>
	<cfset catnum = listcatnum>
</cfif>
<cfif isdefined("cat_num")>
	<cfset catnum = cat_num>
</cfif>
<cfif isdefined("sciname") and len(sciname) gt 0>
	<cfset scientific_name=sciname>
	<cfset scientific_name_match_type="contains">
</cfif>
<cfif isdefined("scientific_name") AND len(scientific_name) gt 0>
	<cfif left(scientific_name,1) is '='>
		<cfset scientific_name=right(scientific_name,len(scientific_name)-1)>
		<cfset scientific_name_match_type="exact">
	</cfif>
</cfif>
<cfif isdefined("HighTaxa") AND len(HighTaxa) gt 0>
	<cfset taxon_name=HighTaxa>
</cfif>
<cfif isdefined("AnySciName") AND len(AnySciName) gt 0>
	<cfset scientific_name=AnySciName>
	<cfset scientific_name_match_type="contains">
</cfif>
<cfif isdefined("any_taxa_term") AND len(any_taxa_term) gt 0>
	<cfset taxon_name=any_taxa_term>
</cfif>
<cfif isdefined("begdate") AND len(begdate) gt 0>
	<cfset began_date=begdate>
</cfif>
<cfif isdefined("enddate") AND len(enddate) gt 0>
	<cfset ended_date=enddate>
</cfif>
<cfif isdefined("identifiedby") and len(identifiedby) gt 0>
	<cfset identified_agent=identifiedby>
</cfif>
<!---- old taxonomy model used taxon_scope - see if we can translate it to new stuff to not break links ---->
<cfif isdefined("taxon_scope") and len(taxon_scope) gt 0 and isdefined("taxon_term") and len(taxon_term) gt 0>
	<!--- theyre coming in from old search params ---->
	<cfif taxon_scope is "currentID_like">
		<!--- current identification contains ---->
		<cfset scientific_name=taxon_term>
		<cfset taxon_term=''>
		<cfset scientific_name_match_type = "contains">
	<cfelseif taxon_scope is "currentID_is">
		<!--- current identification IS ---->
		<cfset scientific_name=taxon_term>
		<cfset taxon_term=''>
		<cfset scientific_name_match_type = "exact">
	<cfelseif taxon_scope is "currentID_list">
		<!--- current identification IN LIST ---->
		<cfset scientific_name=taxon_term>
		<cfset taxon_term=''>
		<cfset scientific_name_match_type = "inlist">
	<cfelseif taxon_scope is "currentID_not">
		<!--- current identification IS NOT ---->
		<cfset scientific_name=taxon_term>
		<cfset taxon_term=''>
		<cfset scientific_name_match_type = "notcontains">
	<cfelseif taxon_scope is "anyID_like">
		<!--- any identification contains ---->
		<cfset scientific_name=taxon_term>
		<cfset taxon_term=''>
		<cfset scientific_name_match_type="contains">
		<cfset scientific_name_scope = "allID">
	<cfelseif taxon_scope is "anyID_is">
		<!--- any identification IS ---->
		<cfset scientific_name=taxon_term>
		<cfset taxon_term=''>
		<cfset scientific_name_scope = "allID">
		<cfset scientific_name_match_type="exact">


	<cfelseif taxon_scope is "anyID_list">
		<!--- any identification IN LIST ---->
		<cfset scientific_name_scope = "allID">
		<cfset scientific_name_match_type="inlist">
		cfset scientific_name=taxon_term>
		<cfset taxon_term=''>

	<cfelseif taxon_scope is "anyID_not">
		<!--- any identification IS NOT ---->
		<cfset scientific_name_scope = "allID">
		<cfset scientific_name_match_type="notcontains">
		cfset scientific_name=taxon_term>
		<cfset taxon_term=''>



	<cfelseif taxon_scope is "currentTaxonomy">
		<!--- collection taxonomy LIKE ---->
		<cfset taxon_name=taxon_term>
	<cfelseif taxon_scope is "relatedTaxonomy">
		<cfset taxon_name=taxon_term>
	<cfelseif taxon_scope is "common">
		<!--- not taxonomy ay all ---->
		<cfset Common_Name=taxon_term>
		<cfset taxon_term=''>
	</cfif>
</cfif>
<!--------------------------- / end old stuff --------------------------------------->
<!--- filtered_flat isn't VPD-striped, so join up to something that is if they're coming from it ---->
<cfif session.flatTableName is "filtered_flat">
 <cfif basJoin does not contain "cataloged_item">
       <cfset basJoin = " #basJoin# INNER JOIN cataloged_item ON (#session.flatTableName#.collection_object_id = cataloged_item.collection_object_id)">
   </cfif>
</cfif>

<cfif isdefined("anyid") and len(trim(anyid)) gt 0>
	<cfset mapurl = "#mapurl#&anyid=#anyid#">
	<!----
		because Oracle optimizer is weird,
		a in (union everything) query performs
		much better than ORs
		See v7.4.1 for old code
	---->
	<cfset basQual = " #basQual# AND #session.flatTableName#.collection_object_id IN (
		 select collection_object_id from coll_obj_other_id_num where upper(display_value) LIKE '#ucase(anyid)#'
		 union select collection_object_id from #session.flatTableName# where upper(cat_num) like '#ucase(anyid)#'
		 union select collection_object_id from #session.flatTableName# where upper(guid) like '#ucase(anyid)#'
		 union select collection_object_id from #session.flatTableName# where upper(accession) like '#ucase(anyid)#'
		 union select derived_from_cat_item from specimen_part,coll_obj_cont_hist,container c, container p
    		where specimen_part.COLLECTION_OBJECT_ID=coll_obj_cont_hist.COLLECTION_OBJECT_ID and
    		coll_obj_cont_hist.container_id=c.container_id and
    		c.parent_container_id=p.container_id and
    		upper(p.barcode) like '#ucase(anyid)#'
		)">
</cfif>
<cfif isdefined("cataloged_item_type") AND len(cataloged_item_type) gt 0>
	<cfset mapurl = "#mapurl#&cataloged_item_type=#cataloged_item_type#">
	<cfset basQual = "#basQual#  AND  #session.flatTableName#.cataloged_item_type='#cataloged_item_type#'" >
</cfif>
<!---- rcoords is round(n,1) concatenated coordinates from spatial browse ---->
<cfif isdefined("rcoords") AND len(rcoords) gt 0>
	<cfset mapurl = "#mapurl#&rcoords=#rcoords#">
	<cfset basQual = "#basQual#  AND  round(#session.flatTableName#.dec_lat,1) || ',' || round(#session.flatTableName#.dec_long,1)='#rcoords#'" >
</cfif>
<!----
	rcoordslist is round(n,1) concatenated coordinates
	in a pipe-separated list
	Currently from edit geog
---->

<cfif isdefined("rcoordslist") AND len(rcoordslist) gt 0>
	<cfset rcl=listqualify(rcoordslist,"'","|")>
	<cfset rcl=listchangedelims(rcl,",","|")>
	<cfset mapurl = "#mapurl#&rcoordslist=#rcoordslist#">
	<cfset basQual = "#basQual# AND round(#session.flatTableName#.dec_lat,1) || ',' || round(#session.flatTableName#.dec_long,1) in (#rcl#)" >
</cfif>
<cfif isdefined("coordinates") AND len(coordinates) gt 0>
	<cfset mapurl = "#mapurl#&coordinates=#coordinates#">
	<cfset basQual = "#basQual#  AND  #session.flatTableName#.dec_lat=#listgetat(coordinates,1)# and #session.flatTableName#.dec_long=#listgetat(coordinates,2)#" >
</cfif>
<!----
	coordslist is a pipe-separated list of coordinate pairs
---->

<cfif isdefined("coordslist") AND len(coordslist) gt 0>
	<cfset mapurl = "#mapurl#&coordslist=#coordslist#">
	<cfset basQual = "#basQual# AND ( ">
	<cfloop list="#coordslist#" delimiters="|" index="c">
		<cfset basQual = "#basQual#  #session.flatTableName#.dec_lat=#listgetat(c,1)# and #session.flatTableName#.dec_long=#listgetat(c,2)#" >
		<cfif listlast(coordslist,"|") is not c>
			<cfset basQual = "#basQual# OR ">
		</cfif>
	</cfloop>
	<cfset basQual = "#basQual# ) ">
</cfif>
<cfif isdefined("isGeoreferenced") AND len(isGeoreferenced) gt 0>
	<cfset mapurl = "#mapurl#&isGeoreferenced=#isGeoreferenced#">
	<cfif isGeoreferenced is true>
		<cfset basQual = "#basQual#  AND  #session.flatTableName#.dec_lat is not null" >
	<cfelse>
		<cfset basQual = "#basQual#  AND  #session.flatTableName#.dec_lat is null" >
	</cfif>
</cfif>
<cfif isdefined("collecting_method") AND len(collecting_method) gt 0>
	<cfset mapurl = "#mapurl#&collecting_method=#collecting_method#">
	<cfif basJoin does not contain " specimen_event ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_event ON (#session.flatTableName#.collection_object_id = specimen_event.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(specimen_event.collecting_method) like '%#ucase(escapeQuotes(collecting_method))#%'">
</cfif>
<cfif isdefined("collecting_source") AND len(collecting_source) gt 0>
	<cfset mapurl = "#mapurl#&collecting_source=#collecting_source#">
	<cfif basJoin does not contain " specimen_event ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_event ON (#session.flatTableName#.collection_object_id = specimen_event.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND specimen_event.collecting_source = '#collecting_source#'">
</cfif>
<cfif isdefined("specimen_event_remark") AND len(specimen_event_remark) gt 0>
	<cfset mapurl = "#mapurl#&specimen_event_remark=#specimen_event_remark#">
	<cfif basJoin does not contain " specimen_event ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_event ON (#session.flatTableName#.collection_object_id = specimen_event.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(specimen_event.specimen_event_remark) like '%#ucase(escapequotes(specimen_event_remark))#%'">
</cfif>
<cfif isdefined("specimen_event_type") AND len(specimen_event_type) gt 0>
	<cfset mapurl = "#mapurl#&specimen_event_type=#specimen_event_type#">
	<cfif basJoin does not contain " specimen_event ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_event ON (#session.flatTableName#.collection_object_id = specimen_event.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND specimen_event.specimen_event_type = '#specimen_event_type#'">
</cfif>
<cfif isdefined("ocr_text") AND len(ocr_text) gt 0>
	<cfset mapurl = "#mapurl#&ocr_text=#ocr_text#">
	<cfif basJoin does not contain "ocr_text">
		<cfset basJoin = " #basJoin# INNER JOIN ocr_text ON (#session.flatTableName#.collection_object_id = ocr_text.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual# AND upper(ocr_text.ocr_text) like '%#ucase(ocr_text)#%'" >
</cfif>
<cfif isdefined("anyTaxId") AND len(anyTaxId) gt 0>
	<cfset mapurl = "#mapurl#&anyTaxId=#anyTaxId#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON (identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfset basQual = " #basQual# AND identification_taxonomy.taxon_name_id=#anyTaxId#">
</cfif>
<cfif isdefined("id_pub_id") AND len(id_pub_id) gt 0>
	<cfset mapurl = "#mapurl#&id_pub_id=#id_pub_id#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND identification.publication_id=#val(id_pub_id)#">
</cfif>
<cfif isdefined("cited_taxon_name_id") AND len(cited_taxon_name_id) gt 0>
	<cfif basJoin does not contain " citation ">
		<cfset basJoin = " #basJoin# INNER JOIN citation ON (#session.flatTableName#.collection_object_id = citation.collection_object_id)">
	</cfif>
	<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ident_cit_tax ON (citation.identification_id = ident_cit_tax.identification_id)">
	<cfset basQual = " #basQual# AND ident_cit_tax.taxon_name_id = #cited_taxon_name_id#">
	<cfset mapurl = "#mapurl#&cited_taxon_name_id=#cited_taxon_name_id#">
</cfif>
<cfif isdefined("cited_scientific_name") AND len(cited_scientific_name) gt 0>
	<cfset mapurl = "#mapurl#&cited_scientific_name=#URLEncodedFormat(cited_scientific_name)#">
	<cfif basJoin does not contain " citation ">
		<cfset basJoin = " #basJoin# INNER JOIN citation cname ON (#session.flatTableName#.collection_object_id = cname.collection_object_id)">
	</cfif>
	<cfset basJoin = " #basJoin# INNER JOIN identification cited_name ON (cname.identification_id = cited_name.identification_id)">
	<cfset basQual = " #basQual# AND upper(cited_name.scientific_name) like '%#ucase(escapeQuotes(cited_scientific_name))#%'">
</cfif>
<cfif isdefined("taxon_name_id") AND len(taxon_name_id) gt 0>
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON
		(#session.flatTableName#.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON
		(identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfset basQual = " #basQual# AND identification_taxonomy.taxon_name_id = #taxon_name_id#">
	<cfif isdefined("scientific_name_scope") and scientific_name_scope is "currentID">
		<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 ">
	</cfif>
	<cfset mapurl = "#mapurl#&taxon_name_id=#taxon_name_id#">
</cfif>

<cfif isdefined("formatted_scientific_name") AND len(formatted_scientific_name) gt 0>
	<cfset mapurl = "#mapurl#&formatted_scientific_name=#URLEncodedFormat(formatted_scientific_name)#">
	<cfif compare(formatted_scientific_name,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.formatted_scientific_name is null">
	<cfelse>
		<cfif left(formatted_scientific_name,1) is '='>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.formatted_scientific_name) = '#ucase(escapeQuotes(right(formatted_scientific_name,len(formatted_scientific_name)-1)))#'">
		<cfelse>
			<cfset basQual = " #basQual# AND UPPER(#session.flatTableName#.formatted_scientific_name) LIKE '%#UCASE(escapeQuotes(formatted_scientific_name))#%'">
		</cfif>
	</cfif>
</cfif>
<cfif isdefined("scientific_name") AND len(scientific_name) gt 0>
	<cfif not isdefined("scientific_name_scope") OR len(scientific_name_scope) is 0>
		<cfset scientific_name_scope = "currentID">
	</cfif>
	<cfif not isdefined("scientific_name_match_type") OR len(scientific_name_match_type) is 0>
		<cfset scientific_name_match_type = "contains">
	</cfif>
	<cfset mapurl = "#mapurl#&scientific_name=#URLEncodedFormat(scientific_name)#">
	<cfset mapurl = "#mapurl#&scientific_name_scope=#scientific_name_scope#">
	<cfset mapurl = "#mapurl#&scientific_name_match_type=#scientific_name_match_type#">
	<cfif scientific_name_scope is "currentID">
		<cfif scientific_name_match_type is "exact">
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) = '#ucase(escapeQuotes(scientific_name))#'">
		<cfelseif scientific_name_match_type is "notcontains">
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) NOT LIKE '%#ucase(escapeQuotes(scientific_name))#%'">
		<cfelseif scientific_name_match_type is "inlist">
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) in (#listqualify(ucase(escapeQuotes(scientific_name)),chr(39))#)">
		<cfelseif scientific_name_match_type is "inlist_substring">
			<cfset basQual = " #basQual# AND (">
			<cfloop list="#scientific_name#" index="i" delimiters=",">
				<cfset basQual = " #basQual# upper(#session.flatTableName#.scientific_name) like '%#ucase(escapeQuotes(i))#%' OR ">
			</cfloop>
			<cfset basQual = left(basQual,len(basQual)-4) & ")">
		<cfelse>
			<!--- old "contains" new "startswith" whatever - just the default ---->
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) LIKE '#ucase(escapeQuotes(scientific_name))#%'">
		</cfif>
	<cfelseif scientific_name_scope is "allID">
		<cfif basJoin does not contain " identification ">
			<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
		</cfif>
		<cfif scientific_name_match_type is "exact">
			<cfset basQual = " #basQual# AND upper(identification.scientific_name) = '#ucase(escapeQuotes(scientific_name))#'">
		<cfelseif scientific_name_match_type is "notcontains">
			<cfset basQual = " #basQual# AND upper(identification.scientific_name) NOT LIKE '%#ucase(escapeQuotes(scientific_name))#%'">
		<cfelseif scientific_name_match_type is "inlist">
			<cfset basQual = " #basQual# AND upper(identification.scientific_name) in (#ucase(listqualify(scientific_name,chr(39)))#)">
		<cfelse><!---- startswith ---->
			<cfset basQual = " #basQual# AND upper(identification.scientific_name) LIKE '%#ucase(escapeQuotes(scientific_name))#%'">
		</cfif>
	</cfif>
</cfif>


<cfif isdefined("taxon_name") AND len(taxon_name) gt 0>
	<!---- version: lots
		approach:
			taxon term: very broad net
			family, etc: collection's stuff
		------------>
	<cfset mapurl = "#mapurl#&taxon_name=#taxon_name#">
	<cfif left(taxon_name,1) is "=">
		<cfset strm=ucase(mid(taxon_name,2,len(taxon_name)-1))>

		<cfset basQual = basQual & " and #session.flatTableName#.COLLECTION_OBJECT_ID in (
		      select collection_object_id from identification where upper(scientific_name) = '#strm#'
		      union
		      select collection_object_id from identification,identification_taxonomy,taxon_term
		         where
		      identification.identification_id=identification_taxonomy.identification_id and
		      identification_taxonomy.taxon_name_id=taxon_term.taxon_name_id and
		         upper(term) = '#strm#'
		      union
		      select collection_object_id from identification,identification_taxonomy,common_name
		         where
		      identification.identification_id=identification_taxonomy.identification_id and
		      identification_taxonomy.taxon_name_id=common_name.taxon_name_id and
		         upper(common_name) = '#strm#'
		      union
		       select collection_object_id from identification,identification_taxonomy,taxon_relations,taxon_term
		         where
		      identification.identification_id=identification_taxonomy.identification_id and
		      identification_taxonomy.taxon_name_id=taxon_relations.taxon_name_id and
		      taxon_relations.related_taxon_name_id=taxon_term.taxon_name_id and
		         upper(term) = '#strm#'
		      UNION
		       select collection_object_id from identification,identification_taxonomy,taxon_relations,taxon_term
		         where
		      identification.identification_id=identification_taxonomy.identification_id and
		      identification_taxonomy.taxon_name_id=taxon_relations.related_taxon_name_id  and
		      taxon_relations.taxon_name_id=taxon_term.taxon_name_id and
		         upper(term) = '#strm#'
		)">
	<cfelse>

		<cfset basQual = basQual & " and #session.flatTableName#.COLLECTION_OBJECT_ID in (
	      select collection_object_id from identification where upper(scientific_name) LIKE '#ucase(escapeQuotes(taxon_name))#%'
	      union
	      select collection_object_id from identification,identification_taxonomy,taxon_term
	         where
	      identification.identification_id=identification_taxonomy.identification_id and
	      identification_taxonomy.taxon_name_id=taxon_term.taxon_name_id and
	         upper(term) LIKE '#ucase(escapeQuotes(taxon_name))#%'
	      union
	      select collection_object_id from identification,identification_taxonomy,common_name
	         where
	      identification.identification_id=identification_taxonomy.identification_id and
	      identification_taxonomy.taxon_name_id=common_name.taxon_name_id and
	         upper(common_name) LIKE '#ucase(escapeQuotes(taxon_name))#%'
	      union
	       select collection_object_id from identification,identification_taxonomy,taxon_relations,taxon_term
	         where
	      identification.identification_id=identification_taxonomy.identification_id and
	      identification_taxonomy.taxon_name_id=taxon_relations.taxon_name_id and
	      taxon_relations.related_taxon_name_id=taxon_term.taxon_name_id and
	         upper(term) LIKE '#ucase(escapeQuotes(taxon_name))#%'
	      UNION
	       select collection_object_id from identification,identification_taxonomy,taxon_relations,taxon_term
	         where
	      identification.identification_id=identification_taxonomy.identification_id and
	      identification_taxonomy.taxon_name_id=taxon_relations.related_taxon_name_id  and
	      taxon_relations.taxon_name_id=taxon_term.taxon_name_id and
	         upper(term) LIKE '#ucase(escapeQuotes(taxon_name))#%'
	)">
	</cfif>







	<!------------
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# inner join identification_taxonomy on (identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfset currTaxIDs=" select taxon_name_id from taxon_term where upper(taxon_term.term) ">
	<cfset relTaxIDs=" select related_taxon_name_id from taxon_relations,taxon_term where taxon_relations.taxon_name_id=taxon_term.taxon_name_id and upper(taxon_term.term) ">
	<cfset invRelTaxIDs=" select taxon_relations.taxon_name_id from taxon_relations,taxon_term where taxon_relations.related_taxon_name_id=taxon_term.taxon_name_id and upper(taxon_term.term) ">

	<cfset currTaxIDs = currTaxIDs & " LIKE '#ucase(escapeQuotes(taxon_name))#%' ">
	<cfset relTaxIDs = relTaxIDs & " LIKE '#ucase(escapeQuotes(taxon_name))#%' ">
	<cfset invRelTaxIDs = invRelTaxIDs & " LIKE '#ucase(escapeQuotes(taxon_name))#%' ">

	<cfset combinedTaxIDs=currTaxIDs & " union " & relTaxIDs & " union " & invRelTaxIDs>


	<cfset basQual = basQual & " and ( identification_taxonomy.taxon_name_id in ( #combinedTaxIDs# ) )">

	------------------>

	<!----giant comment section removed - see v6.8.7 for comment ---->


</cfif>
<cfif isdefined("ImgNoConfirm") and len(ImgNoConfirm) gt 0>
	<cfset mapurl = "#mapurl#&ImgNoConfirm=#ImgNoConfirm#">
   	<cfset basQual = "#basQual#  AND #session.flatTableName#.collection_object_id not in (select
		collection_object_id from attributes where attribute_type='image confirmed' and attribute_value='yes')" >
</cfif>

<cfif isdefined("catnum") and len(trim(catnum)) gt 0>
	<cfset mapurl = "#mapurl#&catnum=#catnum#">
	<cfif left(catnum,1) is "=">
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.cat_num) = '#ucase(mid(catnum,2,len(catnum)-1))#'" >
	<cfelseif catnum contains "," or catnum contains " " or catnum contains "#chr(9)#" or catnum contains "#chr(10)#" or catnum contains "#chr(13)#">
		<cfset l=ListChangeDelims(catnum,',','#chr(9)##chr(10)##chr(13)#, ;')>
		<cfset basQual = "#basQual#  AND upper(#session.flatTableName#.cat_num) IN (#ucase(listqualify(l,chr(39)))#) ">
	<cfelseif
		listlen(catnum,'-') is 2 and
		isnumeric(listgetat(catnum,1,'-')) and
		isnumeric(listgetat(catnum,2,'-')) and
		compare(listgetat(catnum,1,'-'), numberformat(listgetat(catnum,1,'-'),0)) EQ 0 and
		compare(listgetat(catnum,2,'-'), numberformat(listgetat(catnum,2,'-'),0)) EQ 0 and
		listgetat(catnum,1,'-') lt listgetat(catnum,2,'-')>
		<cfset clist="">
		<cfloop from="#listgetat(catnum,1,'-')#" to="#listgetat(catnum,2,'-')#" index="i">
			<cfset clist=listappend(clist,i)>
		</cfloop>
		<cfif listlen(clist) gte 1000>
			<div class="error">Catalog number span searches have a 1000 record limit</div>
			<script>hidePageLoad();</script>
			<cfabort>
		</cfif>
		<cfset basQual = " #basQual# AND #session.flatTableName#.cat_num in ( #ListQualify(clist,'''')# ) " >
	<cfelseif catnum contains "%" or catnum contains "_">
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.cat_num) like '#ucase(catnum)#'" >
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.cat_num) = '#ucase(catnum)#'" >
	</cfif>
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
		<cfset basJoin = " #basJoin# INNER JOIN geology_attributes ON (#session.flatTableName#.locality_id = geology_attributes.locality_id)">
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
<cfif isdefined("last_edit_by") AND len(last_edit_by) gt 0>
	<cfset mapurl = "#mapurl#&last_edit_by=#last_edit_by#">
	<cfif basJoin does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON (#session.flatTableName#.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basJoin = " #basJoin# INNER JOIN agent_name edit_agent ON	(CatItemCollObject.last_edited_person_id = edit_agent.agent_id)">
	<cfset basQual = "#basQual#  AND upper(edit_agent.agent_name) like '%#ucase(last_edit_by)#%'" >
</cfif>
<cfif isdefined("entered_by") AND len(entered_by) gt 0>
	<cfset mapurl = "#mapurl#&entered_by=#entered_by#">
	<cfif basJoin does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON (#session.flatTableName#.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basJoin = " #basJoin# INNER JOIN agent_name entered_agent ON	(CatItemCollObject.entered_person_id = entered_agent.agent_id)">
	<cfset basQual = "#basQual#  AND upper(entered_agent.agent_name) like '%#ucase(entered_by)#%'" >
</cfif>


	<!----
		spec_media_relation options:
			cataloged_item
				flat-->media_relations
				media_relationship like '% cataloged_item%'
			locality
				flat-->specimen_event
				specimen_event-->collecting_event
				collection_event-->locality
				locality-->media_relations
				media_relationship like '% locality%'
	--->



<cfif isdefined("media_keywords") AND len(media_keywords) gt 0>
	<cfset mapurl = "#mapurl#&media_keywords=#media_keywords#">
	<cfset basQual = "#basQual# and #session.flatTableName#.collection_object_id in (
		select related_primary_key from media_relations,media_flat where media_relations.media_id=media_flat.media_id and
			media_relationship like '% cataloged_item' and
			upper(keywords) like '%#ucase(media_keywords)#%'
		UNION
			select collection_object_id from specimen_event,media_relations,media_flat where
				media_relationship like '% collecting_event' and
				specimen_event.collecting_event_id=media_relations.related_primary_key and
				media_relations.media_id=media_flat.media_id and
				upper(keywords) like '%#ucase(media_keywords)#%'
			)">
</cfif>


<cfif isdefined("media_type") AND len(media_type) gt 0>
	<!---- cataloged item media type ---->
	<cfset mapurl = "#mapurl#&media_type=#media_type#">
	<cfif basJoin does not contain " ci_media_relations ">
		<cfset basJoin = " #basJoin# INNER JOIN media_relations ci_media_relations ON (#session.flatTableName#.collection_object_id = ci_media_relations.related_primary_key)">
		<cfset basQual = "#basQual#  AND ci_media_relations.media_relationship='shows cataloged_item'">
	</cfif>
    <cfif media_type is not "any">
        <cfset basJoin = " #basJoin# INNER JOIN media ci_media ON (ci_media_relations.media_id = ci_media.media_id)">
        <cfset basQual = "#basQual#  AND ci_media.media_type = '#media_type#' ">
    </cfif>
</cfif>
<cfif isdefined("mime_type") AND len(mime_type) gt 0>
	<cfset mapurl = "#mapurl#&mime_type=#mime_type#">
	<cfif basJoin does not contain " ci_media_relations ">
		<cfset basJoin = " #basJoin# INNER JOIN media_relations ci_media_relations ON (#session.flatTableName#.ci_media_relations = media_relations.related_primary_key)">
	</cfif>
	<cfset basQual = "#basQual#  AND ci_media_relations.media_relationship like '% cataloged_item'" >
   	<cfif basJoin does not contain " media ">
        <cfset basJoin = " #basJoin# INNER JOIN ci_media ON (ci_media_relations.media_id = ci_media.media_id)">
    </cfif>
	<cfset basQual = "#basQual#  AND ci_media.mime_type = '#mime_type#'" >
</cfif>

<cfif isdefined("coll_obj_flags") AND len(coll_obj_flags) gt 0>
	<cfif basJoin does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON (#session.flatTableName#.collection_object_id = CatItemCollObject.collection_object_id)">
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
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON (#session.flatTableName#.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual# AND to_date(CatItemCollObject.COLL_OBJECT_ENTERED_DATE,'yyyy-mm-dd') BETWEEN to_date('#beEntDate#','yyyy-mm-dd') and
			to_date('#edEntDate#','yyyy-mm-dd')" >
	<cfset mapurl = "#mapurl#&beg_entered_date=#beg_entered_date#">
	<cfset mapurl = "#mapurl#&end_entered_date=#end_entered_date#">
</cfif>
<cfif isdefined("beg_last_edit_date") AND len(beg_last_edit_date) gt 0>
	<cfif not isdefined("end_last_edit_date")>
		<cfset end_last_edit_date=beg_last_edit_date>
	</cfif>
	<cfset mapurl = "#mapurl#&beg_last_edit_date=#beg_last_edit_date#">
	<cfset mapurl = "#mapurl#&end_last_edit_date=#end_last_edit_date#">
	<cfset basQual = "#basQual#  AND (
					to_date(to_char(#session.flatTableName#.lastdate,'yyyy-mm-dd')) between
						to_date('#dateformat(beg_last_edit_date,"yyyy-mm-dd")#')
						and to_date('#dateformat(end_last_edit_date,"yyyy-mm-dd")#')
				)" >
</cfif>
<cfif isdefined("print_fg") AND len(print_fg) gt 0>
	<!---- get data for printing labels ---->
	<cfset basQual = "#basQual#  AND #session.flatTableName#.collection_object_id IN (
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
		">
	<cfset mapurl = "#mapurl#&print_fg=#print_fg#">
</cfif>
<cfif isdefined("anybarcode") AND len(anybarcode) gt 0>
	<cfset basQual = "#basQual#  AND #session.flatTableName#.collection_object_id IN (
		select
			derived_from_cat_item
		from
			coll_obj_cont_hist,
			specimen_part
		where
			coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id and
			coll_obj_cont_hist.container_id in (
				select
					container.container_id
				from
					container,
					container p
				where
					container.parent_container_id=p.container_id (+) and
					container.container_type='collection object'
				start with
					upper(container.barcode)='#trim(ucase(anybarcode))#'
				connect by
					container.parent_container_id = prior container.container_id
			)
		)" >
	<cfset mapurl = "#mapurl#&anybarcode=#anybarcode#">
</cfif>



<!--- everything above here is in doc/field_documentation.cfm ---->



<cfif isdefined("anyContainerId") AND len(anyContainerId) gt 0>
	<cfset basQual = "#basQual#  AND #session.flatTableName#.collection_object_id IN (
		select
			derived_from_cat_item
		from
			coll_obj_cont_hist,
			specimen_part
		where
			coll_obj_cont_hist.collection_object_id=specimen_part.collection_object_id and
			coll_obj_cont_hist.container_id in (
				select
					container.container_id
				from
					container,
					container p
				where
					container.parent_container_id=p.container_id (+) and
					container.container_type='collection object'
				start with
					container.container_id=#anyContainerId#
				connect by
					container.parent_container_id = prior container.container_id
			)
		)">
	<cfset mapurl = "#mapurl#&anyContainerId=#anyContainerId#">
</cfif>
<cfif isdefined("guid") AND len(guid) gt 0>
	<cfset guidList=replace(guid,' ',',','all')>
	<cfset guidList=replace(guidList,';',',','all')>
	<cfset guidList=replace(guidList,chr(10),',','all')>
	<cfset guidList=replace(guidList,chr(13),',','all')>
	<cfset guidList=replace(guidList,chr(9),',','all')>
	<cfset guidList=replace(guidList,",,",',','all')>
	<cfset basQual = "#basQual#  AND upper(#session.flatTableName#.guid)  IN (#ucase(listqualify(guidList,chr(39)))#) ">
	<cfset mapurl = "#mapurl#&guid=#guid#">
</cfif>

<cfif isdefined("barcode") AND len(barcode) gt 0>
	<cfif basJoin does not contain "specimen_part">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfif basJoin does not contain "coll_obj_cont_hist">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_cont_hist ON (specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain "coll_obj_container">
		<cfset basJoin = " #basJoin# INNER JOIN container coll_obj_container ON (coll_obj_cont_hist.container_id = coll_obj_container.container_id)">
	</cfif>
	<cfif basJoin does not contain "parent_container">
		<cfset basJoin = " #basJoin# INNER JOIN container parent_container ON (coll_obj_container.parent_container_id = parent_container.container_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND parent_container.barcode  IN (#listqualify(ListChangeDelims(barcode,','),chr(39))#) ">
	<cfset mapurl = "#mapurl#&barcode=#barcode#">
</cfif>
<cfif isdefined("beg_pbcscan_date") AND len(beg_pbcscan_date) gt 0>
	<cfif basJoin does not contain "specimen_part">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfif basJoin does not contain "coll_obj_cont_hist">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_cont_hist ON (specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain "coll_obj_container">
		<cfset basJoin = " #basJoin# INNER JOIN container coll_obj_container ON (coll_obj_cont_hist.container_id = coll_obj_container.container_id)">
	</cfif>
	<cfif basJoin does not contain "parent_container">
		<cfset basJoin = " #basJoin# INNER JOIN container parent_container ON (coll_obj_container.parent_container_id = parent_container.container_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND to_char(parent_container.PARENT_INSTALL_DATE,'YYYY-MM-DD""T""HH24:MI:SS') >= '#beg_pbcscan_date#'">
	<cfset mapurl = "#mapurl#&beg_pbcscan_date=#beg_pbcscan_date#">
</cfif>
<cfif isdefined("end_pbcscan_date") AND len(end_pbcscan_date) gt 0>
	<cfif basJoin does not contain "specimen_part">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfif basJoin does not contain "coll_obj_cont_hist">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_cont_hist ON (specimen_part.collection_object_id = coll_obj_cont_hist.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain "coll_obj_container">
		<cfset basJoin = " #basJoin# INNER JOIN container coll_obj_container ON (coll_obj_cont_hist.container_id = coll_obj_container.container_id)">
	</cfif>
	<cfif basJoin does not contain "parent_container">
		<cfset basJoin = " #basJoin# INNER JOIN container parent_container ON (coll_obj_container.parent_container_id = parent_container.container_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND to_char(parent_container.PARENT_INSTALL_DATE,'YYYY-MM-DD""T""HH24:MI:SS') <= '#end_pbcscan_date#'">
	<cfset mapurl = "#mapurl#&beg_pbcscan_date=#beg_pbcscan_date#">
</cfif>

<!----
<cfif isdefined("session.ShowObservations") AND session.ShowObservations is false>
	<cfset mapurl = "#mapurl#&ShowObservations=false">
	<cfset basQual = "#basQual#  AND lower( #session.flatTableName#.institution_acronym) not like '%obs'" >
</cfif>
---->
<cfif isdefined("edited_by_id") AND len(edited_by_id) gt 0>
	<cfif basJoin does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON (#session.flatTableName#.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND CatItemCollObject.last_edited_person_id = #edited_by_id#" >
	<cfset mapurl = "#mapurl#&edited_by_id=#edited_by_id#">
</cfif>
<cfif isdefined("coll_obj_condition") AND len(coll_obj_condition) gt 0>
	<cfif basJoin does not contain "CatItemCollObject">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object CatItemCollObject ON (#session.flatTableName#.collection_object_id = CatItemCollObject.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND upper(CatItemCollObject.condition) like '%#ucase(coll_obj_condition)#%'" >
	<cfset mapurl = "#mapurl#&coll_obj_condition=#coll_obj_condition#">
</cfif>
<cfif isdefined("encumbrance_id") AND isnumeric(encumbrance_id)>
	<cfif basJoin does not contain "coll_object_encumbrance">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object_encumbrance ON (#session.flatTableName#.collection_object_id = coll_object_encumbrance.collection_object_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND coll_object_encumbrance.encumbrance_id = #encumbrance_id#" >
	<cfset mapurl = "#mapurl#&encumbrance_id=#encumbrance_id#">
</cfif>
<cfif isdefined("encumbering_agent_id") AND isnumeric(encumbering_agent_id)>
	<cfif basJoin does not contain " coll_object_encumbrance ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_object_encumbrance ON (#session.flatTableName#.collection_object_id = coll_object_encumbrance.collection_object_id)">
 	</cfif>
	<cfif basJoin does not contain " encumbrance ">
		<cfset basJoin = " #basJoin# INNER JOIN encumbrance ON (coll_object_encumbrance.encumbrance_id = encumbrance.encumbrance_id)">
	</cfif>
	<cfset basQual = "#basQual#  AND encumbering_agent_id = #encumbering_agent_id#" >
	<cfset mapurl = "#mapurl#&encumbering_agent_id=#encumbering_agent_id#">
</cfif>
<cfif isdefined("collection_id") AND len(collection_id) gt 0>
	<cfset basQual = "#basQual#  AND #session.flatTableName#.collection_id IN ( #collection_id# )" >
	<cfset mapurl = "#mapurl#&collection_id=#collection_id#">
</cfif>

<cfif isdefined("guid_prefix") AND len(guid_prefix) gt 0>
	<cfset basQual = "#basQual#  AND #session.flatTableName#.collection_id IN (
			select collection_id from collection where upper(guid_prefix) IN (#listqualify(guid_prefix,chr(39))#)
		)" >
	<cfset mapurl = "#mapurl#&guid_prefix=#guid_prefix#">
</cfif>
<cfif isdefined("session.collection") and len(session.collection) gt 0>
	<cfset collection_cde=session.collection>
</cfif>
<cfif isdefined("collection_cde") and len(collection_cde) gt 0>
	<cfset basQual = "#basQual#  AND #session.flatTableName#.collection_cde IN (#listqualify(collection_cde,chr(39))#)" >
	<cfset mapurl = "#mapurl#&collection_cde=#collection_cde#">
</cfif>
<cfif isdefined("coll") AND len(coll) gt 0>
	<cfif basJoin does not contain " srchColl ">
		<cfset basJoin = " #basJoin# INNER JOIN collector ON
			(#session.flatTableName#.collection_object_id = collector.collection_object_id)
			INNER JOIN agent srchColl ON (collector.agent_id = srchColl.agent_id)">
	</cfif>
	<cfSet basQual = " #basQual# AND srchColl.agent_id in (
		select agent_id from agent_name where UPPER(agent_name) LIKE '%#UCASE(escapeQuotes(coll))#%'
		union
		select GROUP_AGENT_ID from group_member,agent_name where group_member.MEMBER_AGENT_ID=agent_name.agent_id and UPPER(agent_name) LIKE  '%#UCASE(escapeQuotes(coll))#%'
		) ">
	<cfif isdefined("coll_role") and len(coll_role) gt 0>
		<cfset mapurl = "#mapurl#&coll_role=#coll_role#">
		<cfSet basQual = " #basQual# AND collector.collector_role='#coll_role#'">
	</cfif>
	<cfif session.flatTableName is not "flat">
		<cfSet basQual = " #basQual# AND (#session.flatTableName#.encumbrances is null OR #session.flatTableName#.encumbrances not like '%collector%') ">
	</cfif>
	<cfset mapurl = "#mapurl#&coll=#coll#">
</cfif>
<cfif isDefined ("notCollector") and len(notCollector) gt 0>
	<cfset mapurl = "#mapurl#&notCollector=#notCollector#">
	<cfif basJoin does not contain " srchColl ">
		<cfset basJoin = " #basJoin# INNER JOIN collector ON
			(#session.flatTableName#.collection_object_id = collector.collection_object_id)
			INNER JOIN agent_name srchColl ON (collector.agent_id = srchColl.agent_id)">
	</cfif>
	<cfSet basQual = " #basQual# AND UPPER(srchColl.agent_name) NOT LIKE '%#UCASE(notCollector)#%'">
</cfif>
<cfif isdefined("collector_agent_id") AND len(collector_agent_id) gt 0>
	<cfset mapurl = "#mapurl#&collector_agent_id=#collector_agent_id#">
	<cfif basJoin does not contain " srchColl ">
		<cfset basJoin = " #basJoin# INNER JOIN collector ON
			(#session.flatTableName#.collection_object_id = collector.collection_object_id)
			INNER JOIN agent_name srchColl ON (collector.agent_id = srchColl.agent_id)">
	</cfif>
	<cfset basQual = " #basQual# AND collector.agent_id = #collector_agent_id#">
	<cfif isdefined("coll_role") and len(coll_role) gt 0>
		<cfset mapurl = "#mapurl#&coll_role=#coll_role#">
		<cfSet basQual = " #basQual# AND collector.collector_role='#coll_role#'">
	</cfif>
</cfif>
<cfif isdefined("begin_made_date") AND len(begin_made_date) gt 0>
	<cfquery name="isdate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select is_iso8601('#begin_made_date#') isdate from dual
	</cfquery>
	<cfif isdate.isdate is not "valid">
		<div class="error">
			The begin made date you entered is not a valid ISO8601 date.
			See <a target="_blank" href="http://arctosdb.org/documentation/dates/">About Arctos Dates</a>
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset basQual = " #basQual# AND #session.flatTableName#.made_date >= '#begin_made_date#'">
	<cfset mapurl = "#mapurl#&begin_made_date=#begin_made_date#">
</cfif>
<cfif isdefined("end_made_date") AND len(end_made_date) gt 0>
	<cfquery name="isdate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select is_iso8601('#end_made_date#') isdate from dual
	</cfquery>
	<cfif isdate.isdate is not "valid">
		<div class="error">
			The end made date you entered is not a valid ISO8601 date.
			See <a target="_blank" href="http://arctosdb.org/documentation/dates/">About Arctos Dates</a>
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset basQual = " #basQual# AND #session.flatTableName#.made_date <= '#end_made_date#'">
	<cfset mapurl = "#mapurl#&end_made_date=#end_made_date#">
</cfif>


<cfif isdefined("family") AND len(family) gt 0>
	<cfset mapurl = "#mapurl#&family=#family#">
	<cfif left(family,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.family) = '#ucase(right(family,len(family)-1))#'">
	<cfelseif left(family,1) is '!'>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.family) != '#ucase(right(family,len(family)-1))#'">
	<cfelseif compare(family,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.family is NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.family) like '%#ucase(family)#%'">
	</cfif>
</cfif>
<cfif isdefined("subfamily") AND len(subfamily) gt 0>
	<cfset mapurl = "#mapurl#&subfamily=#subfamily#">
	<cfif left(subfamily,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.subfamily) = '#ucase(right(subfamily,len(subfamily)-1))#'">
	<cfelseif left(subfamily,1) is '!'>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.subfamily) != '#ucase(right(subfamily,len(subfamily)-1))#'">
	<cfelseif compare(subfamily,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.subfamily is NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.subfamily) like '%#ucase(subfamily)#%'">
	</cfif>
</cfif>

<cfif isdefined("tribe") AND len(tribe) gt 0>
	<cfset mapurl = "#mapurl#&tribe=#tribe#">
	<cfif left(tribe,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.tribe) = '#ucase(right(tribe,len(tribe)-1))#'">
	<cfelseif left(tribe,1) is '!'>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.tribe) != '#ucase(right(tribe,len(tribe)-1))#'">
	<cfelseif compare(tribe,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.tribe is NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.tribe) like '%#ucase(tribe)#%'">
	</cfif>
</cfif>

<cfif isdefined("subtribe") AND len(subtribe) gt 0>
	<cfset mapurl = "#mapurl#&subtribe=#subtribe#">
	<cfif left(subtribe,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.subtribe) = '#ucase(right(subtribe,len(subtribe)-1))#'">
	<cfelseif left(subtribe,1) is '!'>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.subtribe) != '#ucase(right(subtribe,len(subtribe)-1))#'">
	<cfelseif compare(subtribe,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.subtribe is NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.subtribe) like '%#ucase(subtribe)#%'">
	</cfif>
</cfif>
<cfif isdefined("genus") AND len(genus) gt 0>
	<cfset mapurl = "#mapurl#&genus=#genus#">
	<cfif left(genus,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.genus) = '#ucase(right(genus,len(genus)-1))#'">
	<cfelseif left(genus,1) is '!'>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.genus) != '#ucase(right(genus,len(genus)-1))#'">
	<cfelseif compare(genus,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.genus is NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.genus) like '%#ucase(genus)#%'">
	</cfif>
</cfif>
<cfif isdefined("species") AND len(species) gt 0>
	<cfset mapurl = "#mapurl#&species=#species#">
	<cfif left(species,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.species) = '#ucase(right(species,len(species)-1))#'">
	<cfelseif left(species,1) is '!'>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.species) != '#ucase(right(species,len(species)-1))#'">
	<cfelseif compare(species,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.species is NULL">
	<cfelseif compare(species,"NOTNULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.species is not NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.species) like '%#ucase(species)#%'">
	</cfif>
</cfif>
<cfif isdefined("subspecies") AND len(subspecies) gt 0>
	<cfset mapurl = "#mapurl#&subspecies=#subspecies#">
	<cfif left(subspecies,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.subspecies) = '#ucase(right(subspecies,len(subspecies)-1))#'">
	<cfelseif left(subspecies,1) is '!'>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.subspecies) != '#ucase(right(subspecies,len(subspecies)-1))#'">
	<cfelseif compare(subspecies,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.subspecies is NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.subspecies) like '%#ucase(subspecies)#%'">
	</cfif>
</cfif>


<cfif isdefined("phylum") AND len(phylum) gt 0>
	<cfset mapurl = "#mapurl#&phylum=#phylum#">
	<cfif left(phylum,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.phylum) = '#ucase(right(phylum,len(phylum)-1))#'">
	<cfelseif left(phylum,1) is '!'>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.phylum) != '#ucase(right(phylum,len(phylum)-1))#'">
	<cfelseif compare(phylum,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.phylum is NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.phylum) like '%#ucase(phylum)#%'">
	</cfif>
</cfif>

<cfif isdefined("phylorder") AND len(phylorder) gt 0>
	<cfset mapurl = "#mapurl#&phylorder=#phylorder#">
	<cfif left(phylorder,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.phylorder) = '#ucase(right(phylorder,len(phylorder)-1))#'">
	<cfelseif left(phylorder,1) is '!'>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.phylorder) != '#ucase(right(phylorder,len(phylorder)-1))#'">
	<cfelseif compare(phylorder,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.phylorder is NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.phylorder) like '#ucase(phylorder)#%'">
	</cfif>
</cfif>
<cfif isdefined("kingdom") AND len(kingdom) gt 0>
	<cfset mapurl = "#mapurl#&kingdom=#kingdom#">
	<cfif left(kingdom,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.kingdom) = '#ucase(right(kingdom,len(kingdom)-1))#'">
	<cfelseif left(kingdom,1) is '!'>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.kingdom) != '#ucase(right(kingdom,len(kingdom)-1))#'">
	<cfelseif compare(kingdom,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.kingdom is NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.kingdom) like '%#ucase(kingdom)#%'">
	</cfif>
</cfif>

<cfif isdefined("Phylclass") AND len(Phylclass) gt 0>
	<cfset mapurl = "#mapurl#&Phylclass=#Phylclass#">
	<cfif left(phylclass,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.phylclass) = '#ucase(right(phylclass,len(phylclass)-1))#'">
	<cfelseif left(phylclass,1) is '!'>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.phylclass) != '#ucase(right(phylclass,len(phylclass)-1))#'">
	<cfelseif compare(phylclass,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.phylclass is NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.phylclass) like '%#ucase(phylclass)#%'">
	</cfif>
</cfif>
<cfif isdefined("identified_agent_id") AND len(identified_agent_id) gt 0>
	<cfset mapurl = "#mapurl#&identified_agent_id=#identified_agent_id#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON (#session.flatTableName#.collection_object_id = identification.collection_object_id)
		INNER JOIN identification_agent ON (identification.identification_id = identification_agent.identification_id)	">
	</cfif>
	<cfset basQual = " #basQual# AND identification_agent.agent_id = #identified_agent_id#">
</cfif>
<cfif isdefined("identification_remarks") AND len(identification_remarks) gt 0>
	<cfset mapurl = "#mapurl#&identification_remarks=#identification_remarks#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfif isdefined("scientific_name_scope") and scientific_name_scope is "currentID">
		<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 ">
	</cfif>
	<cfset basQual = " #basQual#  AND upper(identification.identification_remarks) like '%#ucase(identification_remarks)#%'">
</cfif>

<cfif isdefined("taxa_formula") AND len(taxa_formula) gt 0>
	<cfset mapurl = "#mapurl#&taxa_formula=#taxa_formula#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
	</cfif>

	<cfset basQual = " #basQual# AND identification.taxa_formula = '#taxa_formula#'">

	<cfif isdefined("scientific_name_scope") and scientific_name_scope is "currentID">
		<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 ">
	</cfif>


</cfif>
<cfif isdefined("nature_of_id") AND len(nature_of_id) gt 0>
	<cfset mapurl = "#mapurl#&nature_of_id=#nature_of_id#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND identification.nature_of_id = '#nature_of_id#'">
	<cfif isdefined("scientific_name_scope") and scientific_name_scope is "currentID">
		<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 ">
	</cfif>

</cfif>

<cfif isdefined("identified_agent") AND len(identified_agent) gt 0>
	<cfset mapurl = "#mapurl#&identified_agent=#identified_agent#">
	<cfif compare(identified_agent,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.IDENTIFIEDBY is null">
	<cfelse>
		<cfif left(identified_agent,1) is '='>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.IDENTIFIEDBY) = '#ucase(escapeQuotes(right(identified_agent,len(identified_agent)-1)))#'">
		<cfelse>
			<cfset basQual = " #basQual# AND UPPER(#session.flatTableName#.IDENTIFIEDBY) LIKE '%#UCASE(escapeQuotes(identified_agent))#%'">
		</cfif>
	</cfif>
</cfif>
<cfif isdefined("began_date") AND len(began_date) gt 0>
	<cfset mapurl = "#mapurl#&began_date=#began_date#">
	<cfquery name="isdate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select is_iso8601('#began_date#') isdate from dual
	</cfquery>
	<cfif isdate.isdate is not "valid">
		<div class="error">
			The begin date you entered is not a valid ISO8601 date.
			See <a target="_blank" href="http://arctosdb.org/documentation/dates/">About Arctos Dates</a>
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset basQual = " #basQual# AND #session.flatTableName#.began_date >= '#began_date#'">
</cfif>
<cfif isdefined("ended_date") AND len(ended_date) gt 0>
	<cfset mapurl = "#mapurl#&ended_date=#ended_date#">
	<cfquery name="isdate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select is_iso8601('#ended_date#') isdate from dual
	</cfquery>
	<cfif isdate.isdate is not "valid">
		<div class="error">
			The ended date you entered is not a valid ISO8601 date.
			See <a target="_blank" href="http://arctosdb.org/documentation/dates/">About Arctos Dates</a>
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset basQual = " #basQual# AND #session.flatTableName#.ended_date <= '#ended_date#'">
</cfif>

<cfif isdefined("year") AND len(year) gt 0>
		<!--- ignore, already exact-match ---->
	<cfif left(year,1) is '='>
		<cfset year=right(year,len(year)-1)>
	</cfif>
	<cfif not isYear(year) and compare(year,"NULL") is not 0>
		<div class="error">
			Year (<cfoutput>#year#</cfoutput>) must be a 4-digit number.
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset mapurl = "#mapurl#&year=#year#">
	<cfif  compare(year,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.year is null ">
	<cfelse>
		<cfset basQual = " #basQual# AND #session.flatTableName#.year = #year#">
	</cfif>
</cfif>
<cfif isdefined("month") AND len(month) gt 0>
		<!--- ignore, already exact-match ---->
	<cfif left(month,1) is '='>
		<cfset month=right(month,len(month)-1)>
	</cfif>
	<cfif compare(month,"NULL") is not 0 and not (month gte 1 and month lte 12)>
		<div class="error">
			month (<cfoutput>#month#</cfoutput>) must be between 1 and 12.
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset mapurl = "#mapurl#&month=#month#">
	<cfif  compare(month,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.month is null ">
	<cfelse>
		<cfset basQual = " #basQual# AND #session.flatTableName#.month = #month#">
	</cfif>
</cfif>
<cfif isdefined("day") AND len(day) gt 0>
		<!--- ignore, already exact-match ---->
	<cfif left(day,1) is '='>
		<cfset day=right(day,len(day)-1)>
	</cfif>
	<cfif compare(day,"NULL") is not 0 and not (day gte 1 and day lte 31)>
		<div class="error">
			day (<cfoutput>#day#</cfoutput>) must be between 1 and 31.
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset mapurl = "#mapurl#&day=#day#">
	<cfif  compare(day,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.day is null ">
	<cfelse>
		<cfset basQual = " #basQual# AND #session.flatTableName#.day = #day#">
	</cfif>
</cfif>
<cfif isdefined("begYear") AND len(begYear) gt 0>
	<cfif not isYear(begYear) and compare(begYear,"NULL") is not 0>
		<div class="error">
			Begin year must be a 4-digit number.
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset mapurl = "#mapurl#&begYear=#begYear#">
	<cfif  compare(begYear,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.began_date is null ">
	<cfelse>
		<cfset basQual = " #basQual# AND #session.flatTableName#.year >= #begYear#">
	</cfif>
</cfif>
<cfif isdefined("begMon") AND len(begMon) gt 0>
	<cfset mapurl = "#mapurl#&begMon=#begMon#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.month >= #begMon#">
</cfif>
<cfif isdefined("begDay") AND len(begDay) gt 0>
	<cfset mapurl = "#mapurl#&begDay=#begDay#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.day >= #begDay#">
</cfif>

<cfif isdefined("endYear") AND len(endYear) gt 0>
	<cfif not isYear(endYear) and compare(endYear,"NULL") is not 0>
		<div class="error">
			End year must be a 4-digit number.
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset mapurl = "#mapurl#&endYear=#endYear#">
	<cfif  compare(endYear,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.ended_date is null ">
	<cfelse>
		<cfset basQual = " #basQual# AND #session.flatTableName#.year <= #endYear#">
	</cfif>
</cfif>
<cfif isdefined("endMon") AND len(endMon) gt 0>
	<cfset mapurl = "#mapurl#&endMon=#endMon#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.month <= #endMon#">
</cfif>
<cfif isdefined("endDay") AND len(endDay) gt 0>
	<cfset mapurl = "#mapurl#&endDay=#endDay#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.day <= #endDay#">
</cfif>
<cfif isdefined("specimen_event_id") AND len(specimen_event_id) gt 0>
	<cfset mapurl = "#mapurl#&specimen_event_id=#specimen_event_id#">
	<cfif basJoin does not contain " specimen_event ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_event ON (#session.flatTableName#.collection_object_id = specimen_event.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND specimen_event.specimen_event_id = #val(specimen_event_id)#">
</cfif>
<cfif isdefined("collecting_event_id") AND len(collecting_event_id) gt 0>
	<cfset mapurl = "#mapurl#&collecting_event_id=#collecting_event_id#">
	<cfif basJoin does not contain " specimen_event ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_event ON (#session.flatTableName#.collection_object_id = specimen_event.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND specimen_event.collecting_event_id IN ( #collecting_event_id# )">
</cfif>
<cfif isdefined("coll_event_remarks") AND len(coll_event_remarks) gt 0>
	<cfset mapurl = "#mapurl#&coll_event_remarks=#coll_event_remarks#">
	<cfif basJoin does not contain " specimen_event ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_event ON (#session.flatTableName#.collection_object_id = specimen_event.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " collecting_event ">
		<cfset basJoin = " #basJoin# INNER JOIN collecting_event ON (specimen_event.collecting_event_id = collecting_event.collecting_event_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(collecting_event.coll_event_remarks) like '%#ucase(coll_event_remarks)#%'">
</cfif>
<cfif isdefined("verificationstatus") AND len(verificationstatus) gt 0>
	<cfset mapurl = "#mapurl#&verificationstatus=#verificationstatus#">
	<cfif basJoin does not contain " specimen_event ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_event ON (#session.flatTableName#.collection_object_id = specimen_event.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(specimen_event.verificationstatus) like '%#ucase(verificationstatus)#%'">
</cfif>

<cfif isdefined("locality_id") AND len(locality_id) gt 0>
	<cfset mapurl = "#mapurl#&locality_id=#locality_id#">
	<cfif basJoin does not contain " specimen_event ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_event ON (#session.flatTableName#.collection_object_id = specimen_event.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " collecting_event ">
		<cfset basJoin = " #basJoin# INNER JOIN collecting_event ON (specimen_event.collecting_event_id = collecting_event.collecting_event_id)">
	</cfif>
	<cfset basQual = " #basQual# AND collecting_event.locality_id IN ( #locality_id# )">
</cfif>
<cfif isdefined("inMon") AND len(inMon) gt 0>
	<cfset mapurl = "#mapurl#&inMon=#inMon#">
	<cfset basQual = " #basQual# AND TO_NUMBER(substr(#session.flatTableName#.began_date,6,2)) IN (#inMon#)">
</cfif>
<cfif isdefined("verbatim_date") AND len(verbatim_date) gt 0>
	<cfset mapurl = "#mapurl#&verbatim_date=#verbatim_date#">
	<cfset basQual = " #basQual# AND upper(#session.flatTableName#.verbatim_date) LIKE '%#ucase(escapeQuotes(verbatim_date))#%'">
</cfif>
<cfif isdefined("accn_trans_id") AND len(accn_trans_id) gt 0>
	<cfset mapurl = "#mapurl#&accn_trans_id=#accn_trans_id#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.accn_id IN (#accn_trans_id#)">
</cfif>
<cfif isdefined("accn_inst") and len(accn_inst) gt 0>
	accn_inst is deprecated - please contact us<cfabort>
	<!----
	<cfset mapurl = "#mapurl#&accn_inst=#accn_inst#">
	<cfif basJoin does not contain " accn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn ON (#session.flatTableName#.accn_id = accn.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " trans ">
		<cfset basJoin = " #basJoin# INNER JOIN trans ON (accn.transaction_id=trans.transaction_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(trans.institution_acronym) like '%#ucase(accn_inst)#%'">
	--------->
</cfif>
<cfif isdefined("accn_number") and len(accn_number) gt 0>
	<cfif accn_number contains ",">
		<cfset accn_list=accn_number>
	<cfelse>
		<cfset mapurl = "#mapurl#&accn_number=#accn_number#">
		<cfif left(accn_number,1) is '='>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.accession) = '#ucase(right(accn_number,len(accn_number)-1))#'">
		<cfelse>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.accession) LIKE '%#ucase(accn_number)#%'">
		</cfif>
	</cfif>
</cfif>
<cfif isdefined("accn_list") and len(accn_list) gt 0>
	<cfset mapurl = "#mapurl#&accn_list=#accn_list#">
	<cfif basJoin does not contain " accn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn ON (#session.flatTableName#.accn_id = accn.transaction_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(accn.accn_number) IN (#ucase(listqualify(accn_list,chr(39)))#)">
</cfif>
<cfif isdefined("loan_number") and len(loan_number) gt 0>
	<cfset mapurl = "#mapurl#&loan_number=#loan_number#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.collection_object_id in (
		select collection_object_id from loan,loan_item where loan.transaction_id=loan_item.transaction_id">
	<cfif left(loan_number,1) is '='>
		<cfset basQual = " #basQual# AND upper(loan.loan_number) = '#ucase(right(loan_number,len(loan_number)-1))#'">
	<cfelseif loan_number is "*">
		<!-- don't do anything, just make the join --->
	<cfelse>
		<cfset basQual = " #basQual# AND upper(loan.loan_number) LIKE '%#ucase(loan_number)#%'">
	</cfif>
	<cfset basQual = " #basQual# UNION
		select derived_from_cat_item from loan,specimen_part,loan_item where specimen_part.collection_object_id=loan_item.collection_object_id and
		loan.transaction_id=loan_item.transaction_id">
	<cfif left(loan_number,1) is '='>
		<cfset basQual = " #basQual# AND upper(loan.loan_number) = '#ucase(right(loan_number,len(loan_number)-1))#'">
	<cfelseif loan_number is "*">
		<!-- don't do anything, just make the join --->
	<cfelse>
		<cfset basQual = " #basQual# AND upper(loan.loan_number) LIKE '%#ucase(loan_number)#%'">
	</cfif>
	<cfset basQual = " #basQual# )">
</cfif>
<cfif isdefined("accn_agency") and len(accn_agency) gt 0>
	<cfset mapurl = "#mapurl#&accn_agency=#URLEncodedFormat(accn_agency)#">
	<cfif basJoin does not contain " accn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn ON (#session.flatTableName#.accn_id = accn.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " trans ">
		<cfset basJoin = " #basJoin# INNER JOIN trans ON (accn.transaction_id=trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " accn_agency ">
		<cfset basJoin = " #basJoin# inner join trans_agent on (trans.transaction_id = trans_agent.transaction_id)
			INNER JOIN agent_name accn_agency ON (trans_agent.AGENT_ID = accn_agency.agent_id)">
	</cfif>
	<cfset basQual = " #basQual# AND trans_agent.TRANS_AGENT_ROLE='associated with agency' and upper(accn_agency.agent_name) LIKE '%#ucase(accn_agency)#%'">
</cfif>
<cfif isdefined("custom_id_prefix") and len(custom_id_prefix) gt 0>
	<cfset mapurl = "#mapurl#&custom_id_prefix=#custom_id_prefix#">
	<cfif basJoin does not contain " customIdentifier ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num customIdentifier ON (#session.flatTableName#.collection_object_id = customIdentifier.collection_object_id)">
	</cfif>
	<cfif #basQual# does not contain "customIdentifier.other_id_type">
		<cfset basQual = " #basQual# AND customIdentifier.other_id_type = '#session.CustomOtherIdentifier#'">
	</cfif>
	<cfset basQual = " #basQual# AND upper(customIdentifier.other_id_prefix) LIKE '%#ucase(custom_id_prefix)#%'">
</cfif>
<cfif isdefined("custom_id_suffix") and len(custom_id_suffix) gt 0>
	<cfset mapurl = "#mapurl#&custom_id_suffix=#custom_id_suffix#">
	<cfif basJoin does not contain " customIdentifier ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num customIdentifier ON (#session.flatTableName#.collection_object_id = customIdentifier.collection_object_id)">
	</cfif>
	<cfif basQual does not contain "customIdentifier.other_id_type">
		<cfset basQual = " #basQual# AND customIdentifier.other_id_type = '#session.CustomOtherIdentifier#'">
	</cfif>
	<cfset basQual = " #basQual# AND upper(customIdentifier.other_id_suffix) LIKE '%#ucase(custom_id_suffixid_prefix)#%'">
</cfif>
<cfif isdefined("custom_id_number") and len(custom_id_number) gt 0>
	<cfset mapurl = "#mapurl#&custom_id_number=#custom_id_number#">
	<cfif basJoin does not contain " customIdentifier ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num customIdentifier ON (#session.flatTableName#.collection_object_id = customIdentifier.collection_object_id)">
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
	<cfset mapurl = "#mapurl#&CustomIdentifierValue=#URLEncodedFormat(CustomIdentifierValue)#">
	<cfset mapurl = "#mapurl#&CustomOidOper=#URLEncodedFormat(CustomOidOper)#">
	<cfif basJoin does not contain " customIdentifier ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num customIdentifier ON (#session.flatTableName#.collection_object_id = customIdentifier.collection_object_id)">
	</cfif>
	<cfif basQual does not contain "customIdentifier.other_id_type">
		<cfset basQual = " #basQual# AND customIdentifier.other_id_type = '#session.CustomOtherIdentifier#'">
	</cfif>
	<cfif CustomOidOper is "IS">
		<cfset basQual = " #basQual# AND customIdentifier.DISPLAY_VALUE = '#CustomIdentifierValue#'">
	<cfelseif CustomOidOper is "LIST">
		<cfset noSpace=replace(CustomIdentifierValue,' ','','all')>
		<cfset basQual = " #basQual# AND upper(customIdentifier.DISPLAY_VALUE) IN (#ucase(ListQualify(ListChangeDelims(noSpace,','),''''))#)">
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
	<cfset mapurl = "#mapurl#&OIDType=#URLEncodedFormat(OIDType)#">
	<cfif basJoin does not contain " otherIdSearch ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdSearch ON (#session.flatTableName#.collection_object_id = otherIdSearch.collection_object_id)">
	</cfif>
	<cfset oidType=replace(OIDType,"'","''","all")>
	<cfset oidType=listqualify(OIDType,chr(39),",")>
	<cfset oidType=replace(OIDType,"|",",","all")>
	<cfset basQual = " #basQual# and otherIdSearch.id_references='self' AND otherIdSearch.other_id_type in (#OIDType#)">
</cfif>
<cfif isdefined("id_references") AND len(id_references) gt 0>
	<cfset mapurl = "#mapurl#&id_references=#id_references#">
	<cfif basJoin does not contain " otherIdRefSearch ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdRefSearch ON (#session.flatTableName#.collection_object_id = otherIdRefSearch.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND otherIdRefSearch.id_references = '#id_references#'">
</cfif>
<cfif isdefined("related_term_1") AND len(related_term_1) gt 0>
	<cfset mapurl = "#mapurl#&related_term_1=#URLEncodedFormat(related_term_1)#">
	<cfif basJoin does not contain " otherIdRefSearch ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdRefSearch ON (#session.flatTableName#.collection_object_id = otherIdRefSearch.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " otherIdRefRelTerms1 ">
		<cfset basJoin = " #basJoin# INNER JOIN cf_relations_cache otherIdRefRelTerms1 ON (otherIdRefSearch.COLL_OBJ_OTHER_ID_NUM_ID = otherIdRefRelTerms1.COLL_OBJ_OTHER_ID_NUM_ID)">
	</cfif>
	<cfset basQual = " #basQual# and otherIdRefSearch.id_references != 'self' AND otherIdRefRelTerms1.term='#related_term_1#'">
</cfif>
<cfif isdefined("RelatedOIDType") AND len(RelatedOIDType) gt 0>
	<cfset mapurl = "#mapurl#&RelatedOIDType=#URLEncodedFormat(RelatedOIDType)#">
	<cfif basJoin does not contain " otherIdRefSearch ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdRefSearch ON (#session.flatTableName#.collection_object_id = otherIdRefSearch.collection_object_id)">
	</cfif>
	<cfset basQual = "  #basQual# and otherIdRefSearch.id_references != 'self' AND otherIdRefSearch.other_id_type='#RelatedOIDType#'">
</cfif>
<cfif isdefined("related_term_val_1") AND len(related_term_val_1) gt 0>
	<cfset mapurl = "#mapurl#&related_term_val_1=#URLEncodedFormat(related_term_val_1)#">
	<cfif basJoin does not contain " otherIdRefSearch ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdRefSearch ON (#session.flatTableName#.collection_object_id = otherIdRefSearch.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " otherIdRefRelTerms1 ">
		<cfset basJoin = " #basJoin# INNER JOIN cf_relations_cache otherIdRefRelTerms1 ON (otherIdRefSearch.COLL_OBJ_OTHER_ID_NUM_ID = otherIdRefRelTerms1.COLL_OBJ_OTHER_ID_NUM_ID)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(otherIdRefRelTerms1.VALUE) like '%#ucase(related_term_val_1)#%'">
</cfif>

<cfif isdefined("OIDNum") and len(OIDNum) gt 0>
	<cfif not isdefined("oidOper") OR len(oidOper) is 0>
		<cfset oidOper = "LIKE">
	</cfif>
	<cfset mapurl = "#mapurl#&OIDNum=#URLEncodedFormat(OIDNum)#">
	<cfset mapurl = "#mapurl#&oidOper=#oidOper#">
	<cfif basJoin does not contain " otherIdSearch ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdSearch ON (#session.flatTableName#.collection_object_id = otherIdSearch.collection_object_id)">
	</cfif>
	<cfif oidOper is "LIKE">
		<cfset basQual = " #basQual# and otherIdSearch.id_references='self' and upper(otherIdSearch.display_value) LIKE '%#ucase(OIDNum)#%'">
	<cfelseif oidOper is "IS">
		<cfset basQual = " #basQual# and otherIdSearch.id_references='self' and upper(otherIdSearch.display_value) = '#ucase(OIDNum)#'">
	<cfelse>
		<!----
			list
				* remove spaces
				* change semicolon to comma
				* change chr(10) to comma
		---->
		<cfset oidList=replace(OIDNum,' ',',','all')>
		<cfset oidList=replace(oidList,';',',','all')>
		<cfset oidList=replace(oidList,chr(10),',','all')>
		<cfset oidList=replace(oidList,chr(13),',','all')>
		<cfset oidList=replace(oidList,chr(9),',','all')>
		<cfset oidList=replace(oidList,",,",',','all')>
		<cfset basQual = " #basQual# AND upper(otherIdSearch.display_value) IN ( #ListQualify(oidList,'''')# ) " >
	</cfif>
	<cfif session.flatTableName is not "flat">
		<cfset basQual = " #basQual# AND (#session.flatTableName#.encumbrances is null or #session.flatTableName#.encumbrances not like '%mask original field number%') ">
	</cfif>
</cfif>
<cfif isdefined("continent_ocean") AND len(continent_ocean) gt 0>
	<cfif compare(continent_ocean,"NULL") is 0>
		<cfset basQual = " #basQual# AND continent_ocean is null">
	<cfelse>
		<cfif left(continent_ocean,1) is '='>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.continent_ocean) = '#ucase(escapeQuotes(right(continent_ocean,len(continent_ocean)-1)))#'">
		<cfelse>
			<cfset basQual = " #basQual# AND UPPER(#session.flatTableName#.continent_ocean) LIKE '%#UCASE(escapeQuotes(continent_ocean))#%'">
		</cfif>
	</cfif>
	<cfset mapurl = "#mapurl#&continent_ocean=#URLEncodedFormat(continent_ocean)#">
</cfif>
<cfif isdefined("sea") AND len(sea) gt 0>
	<cfset temp=getFlatSql(fld="sea", val=sea)>
</cfif>
<cfif isdefined("Country") AND len(Country) gt 0>
	<cfset temp=getFlatSql(fld="Country", val=Country)>
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
				 <cfset basQual = " #basQual# UPPER(#session.flatTableName#.state_prov) LIKE '%#UCASE(trim(escapeQuotes(s)))#%'">
				 <cfset i=i+1>
			</cfloop>
		<cfset basQual = " #basQual# ) ">
	<cfelse>
		<cfif left(state_prov,1) is '='>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.state_prov) = '#ucase(escapeQuotes(right(state_prov,len(state_prov)-1)))#'">
		<cfelse>
			<cfset basQual = " #basQual# AND UPPER(#session.flatTableName#.state_prov) LIKE '%#UCASE(escapeQuotes(state_prov))#%'">
		</cfif>
	</cfif>
	<cfset mapurl = "#mapurl#&state_prov=#URLEncodedFormat(state_prov)#">
</cfif>





<cfif isdefined("island_group") AND len(island_group) gt 0>
	<cfset temp=getFlatSql(fld="island_group", val=island_group)>
</cfif>
<cfif isdefined("Island") AND len(Island) gt 0>
	<cfset temp=getFlatSql(fld="Island", val=Island)>

</cfif>
<cfif (isdefined("min_max_error") AND len(min_max_error) gt 0) or (isdefined("max_max_error") AND len(max_max_error) gt 0)>
	<cfif (isdefined("min_max_error") AND len(min_max_error) gt 0) and ((not isdefined("max_max_error")) or len(max_max_error) eq 0)>
		<!---got min, not max - set max to some improbably large number----->
		<cfset max_max_error=999999999999999999999999999>
	<cfelseif (isdefined("max_max_error") AND len(max_max_error) gt 0) and ((not isdefined("min_max_error")) or len(min_max_error) eq 0)>
		<!---got max , not min - set min to some 0---->
		<cfset min_max_error=0>
	</cfif>
	<cfif 	min_max_error contains "," or max_max_error contains ",">
		<div class="error">min and max precision must be integers.
		<br>Searching by precision and then clicking some "specimens with precision...." links can also cause this error.</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfif not isdefined("max_error_units") or len(max_error_units) is 0>
		<cfset max_error_units='m'>
	</cfif>
	<cfset mapurl = "#mapurl#&min_max_error=#min_max_error#&max_max_error=#max_max_error#&max_error_units=#max_error_units#">
	<cfif compare(min_max_error,"NULL") is 0>
		<!-- return only records with coordinates BUT with no error ---->
		<cfset basQual = " #basQual# AND #session.flatTableName#.dec_lat is not null and (#session.flatTableName#.COORDINATEUNCERTAINTYINMETERS is null OR #session.flatTableName#.COORDINATEUNCERTAINTYINMETERS=0)">
	<cfelse>
		<cfset basQual = " #basQual# AND #session.flatTableName#.COORDINATEUNCERTAINTYINMETERS
			> to_meters(#min_max_error#,'#max_error_units#') and #session.flatTableName#.COORDINATEUNCERTAINTYINMETERS <= to_meters(#max_max_error#,'#max_error_units#')">
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
<cfif (isdefined("NELat") and len(NELat) gt 0)
	OR (isdefined("NELong") and len(NELong) gt 0)
	OR (isdefined("SWLat") and len(SWLat) gt 0)
	OR (isdefined("SWLong") and len(SWLong) gt 0)>
	<!--- got at least one point, see if we got enough to run ---->
	<cfif (isdefined("NELat") and isnumeric(NELat))
		AND (isdefined("SWLat") and isnumeric(SWLat))
		AND (isdefined("NELong") and isnumeric(NELong))
		AND (isdefined("SWLong") and isnumeric(SWLong))>
		<cfif not isdefined("sq_error")>
			<cfset sq_error='false'>
		</cfif>
		<cfif sq_error is true>
			<cfset basJoin = " #basJoin# INNER JOIN fake_coordinate_error ON (#session.flatTableName#.locality_id = fake_coordinate_error.locality_id)">
			<cfif NELong lt 0 and SWLong gt 0><!--- overlaps 180, need a pair of extra statements ----->
				<cfset basQual = " #basQual# AND
					(
						(
							#NELat# between fake_coordinate_error.swlat and fake_coordinate_error.nelat OR
							#SWLat# between fake_coordinate_error.swlat and fake_coordinate_error.nelat OR
							fake_coordinate_error.swlat between #SWLat# and #NELat# OR
							fake_coordinate_error.nelat between #SWLat# and #NELat#
						) AND (
							#swlong# between fake_coordinate_error.swlong and fake_coordinate_error.nelong OR
							#nelong# between fake_coordinate_error.swlong and fake_coordinate_error.nelong OR
							fake_coordinate_error.swlong between #swlong# and 180 OR
							fake_coordinate_error.swlong between -180 and #nelong# OR
							fake_coordinate_error.nelong between #swlong# and 180 OR
							fake_coordinate_error.nelong between -180 and #nelong#
						)
					)">
			<cfelse><!--- longitude does not overlap 180 --->
				<cfset basQual = " #basQual# AND
					(
						(
							#NELat# between fake_coordinate_error.swlat and fake_coordinate_error.nelat OR
							#SWLat# between fake_coordinate_error.swlat and fake_coordinate_error.nelat OR
							fake_coordinate_error.swlat between #SWLat# and #NELat# OR
							fake_coordinate_error.nelat between #SWLat# and #NELat#
						) AND (
							#swlong# between fake_coordinate_error.swlong and fake_coordinate_error.nelong OR
							#nelong# between fake_coordinate_error.swlong and fake_coordinate_error.nelong OR
							fake_coordinate_error.swlong between #swlong# and #nelong# OR
							fake_coordinate_error.nelong between #swlong# and #nelong#
						)
					)">
			</cfif>
		<cfelse>
			<cfset basQual = " #basQual# AND #session.flatTableName#.dec_lat BETWEEN #SWLat# AND #NELat#">
			<cfif NELong lt 0 and SWLong gt 0>
				<cfset basQual = " #basQual# AND (#session.flatTableName#.dec_long between #SWLong# and 180 OR
					#session.flatTableName#.dec_long between -180 and #NELong#)">
			<cfelse>
				<cfset basQual = " #basQual# AND #session.flatTableName#.dec_long BETWEEN #SWLong# AND #NELong#">
			</cfif>
		</cfif>
		<cfset mapurl = "#mapurl#&NELat=#NELat#&NELong=#NELong#&SWLat=#SWLat#&SWLong=#SWLong#&sq_error=#sq_error#">
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


<!--------- this is legacy from the old spatial query and can probably be deprecated rather than updated when that becomes an issue ---->
<cfif (isdefined("NWLat") and len(NWLat) gt 0)
	OR (isdefined("NWLong") and len(NWLong) gt 0)
	OR (isdefined("SELat") and len(SELat) gt 0)
	OR (isdefined("SELong") and len(SELong) gt 0)>
	<!--- got at least one point, see if we got enough to run ---->
	<cfif (isdefined("NWLat") and isnumeric(NWLat))
		AND (isdefined("NWLong") and isnumeric(NWLong))
		AND (isdefined("SELat") and isnumeric(SELat))
		AND (isdefined("SELong") and isnumeric(SELong))>
		<cfset basQual = " #basQual# AND #session.flatTableName#.dec_lat BETWEEN #SELat# AND #NWLat#">
		<cfif nwlong gt 0 and selong lt 0>
			<cfset basQual = " #basQual# AND (#session.flatTableName#.dec_long between #nwlong# and 180 OR #session.flatTableName#.dec_long between -180 and #selong#)">
		<cfelse>
			<cfset basQual = " #basQual# AND #session.flatTableName#.dec_long BETWEEN #NWLong# AND #SELong#">
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
<!--------- the above is legacy from the old spatial query and can probably be deprecated rather than updated when that becomes an issue ---->

<cfif isdefined("spec_locality") and len(spec_locality) gt 0>
	<cfset mapurl = "#mapurl#&spec_locality=#URLEncodedFormat(spec_locality)#">
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
<cfif isdefined("coord_serv_diff") and len(coord_serv_diff) gt 0>
	<cfset mapurl = "#mapurl#&coord_serv_diff=#coord_serv_diff#">
	<cfif not listfind("=,<,>",left(coord_serv_diff,1)) or
		not isnumeric(mid(coord_serv_diff,2,999))>
		<p>
			coord_serv_diff format is (=,<, or >) followed by an integer (in KM). Example, in a form:
			<ul>
				<li>=10</li>
				<li>>10</li>
				<li><10</li>
			</ul>
			Example, in a URL:
			<ul>
				<li>==10</li>
				<li>=>10</li>
				<li>=<10</li>
			</ul>
		</p>
		<cfabort>
	</cfif><cfif basJoin does not contain " locality ">
		<cfset basJoin = " #basJoin# INNER JOIN locality ON (#session.flatTableName#.locality_id = locality.locality_id)">
	</cfif>
	<cfset basQual = " #basQual# AND checkLocalityError(locality.locality_id) #coord_serv_diff#">
</cfif>
<cfif isdefined("locality_remarks") and len(locality_remarks) gt 0>
	<cfset mapurl = "#mapurl#&locality_remarks=#URLEncodedFormat(locality_remarks)#">
	<cfif basJoin does not contain " locality ">
		<cfset basJoin = " #basJoin# INNER JOIN locality ON (#session.flatTableName#.locality_id = locality.locality_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(locality.locality_remarks) like '%#ucase(escapeQuotes(locality_remarks))#%'">
</cfif>
<cfif isdefined("habitat") and len(habitat) gt 0>
	<cfset mapurl = "#mapurl#&habitat=#URLEncodedFormat(habitat)#">
	<cfset basQual = " #basQual# AND upper(#session.flatTableName#.habitat) like '%#ucase(escapeQuotes(habitat))#%'">
</cfif>
<cfif isdefined("verbatim_locality") and len(verbatim_locality) gt 0>
	<cfset mapurl = "#mapurl#&verbatim_locality=#URLEncodedFormat(verbatim_locality)#">
	<cfif left(verbatim_locality,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.verbatim_locality) = '#ucase(escapeQuotes(right(verbatim_locality,len(verbatim_locality)-1)))#'">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.verbatim_locality) like '%#ucase(escapeQuotes(verbatim_locality))#%'">
	</cfif>
</cfif>
<cfif isdefined("minimum_elevation") and len(minimum_elevation) gt 0>
	<cfif not isdefined("orig_elev_units") OR len(orig_elev_units) is 0>
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
	<cfset mapurl = "#mapurl#&minimum_elevation=#minimum_elevation#&orig_elev_units=#orig_elev_units#">
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
	<cfif mapurl does not contain "orig_elev_units">
		<cfset mapurl = "#mapurl#&orig_elev_units=#orig_elev_units#">
	</cfif>
</cfif>
<cfif isdefined("feature") AND len(feature) gt 0>
	<cfif compare(feature,"NULL") is 0>
		<cfset basQual = " #basQual# AND feature is null">
	<cfelse>
		<cfif left(feature,1) is '='>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.feature) = '#ucase(escapeQuotes(right(feature,len(feature)-1)))#'">
		<cfelse>
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.feature) LIKE '%#ucase(escapeQuotes(feature))#%'">
		</cfif>
	</cfif>
	<cfset mapurl = "#mapurl#&feature=#URLEncodedFormat(feature)#">
</cfif>
<cfif isdefined("any_geog") AND len(any_geog) gt 0>
	<cfset mapurl = "#mapurl#&any_geog=#URLEncodedFormat(any_geog)#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.locality_id IN (
		select locality_id from locality,geog_search_term where locality.geog_auth_rec_id=geog_search_term.geog_auth_rec_id and
      		upper(geog_search_term.search_term) like '%#ucase(escapeQuotes(any_geog))#%'
		UNION
		select locality_id from locality where upper(spec_locality) LIKE '%#ucase(escapeQuotes(any_geog))#%'
		UNION
		select locality_id from locality,geog_auth_rec where locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and
        	upper(higher_geog) LIKE '%#ucase(escapeQuotes(any_geog))#%'
		UNION
		select locality_id from locality where upper(S$GEOGRAPHY) LIKE '%#ucase(escapeQuotes(any_geog))#%'
		UNION
		select locality_id from locality where upper(LOCALITY_NAME) LIKE '%#ucase(escapeQuotes(any_geog))#%'
		UNION
		select locality_id from collecting_event where upper(verbatim_locality) LIKE '%#ucase(escapeQuotes(any_geog))#%'
	)">
</cfif>
<cfif isdefined("geog_auth_rec_id") AND len(geog_auth_rec_id) gt 0>
	<cfset basQual = " #basQual# AND #session.flatTableName#.geog_auth_rec_id=#geog_auth_rec_id#">
	<cfset mapurl = "#mapurl#&geog_auth_rec_id=#geog_auth_rec_id#">
</cfif>
<cfif isdefined("higher_geog") AND len(higher_geog) gt 0>
	<cfset basQual = " #basQual# AND upper(higher_geog) LIKE '%#ucase(higher_geog)#%'">
	<cfset mapurl = "#mapurl#&higher_geog=#URLEncodedFormat(higher_geog)#">
</cfif>

<cfif isdefined("datum") AND len(datum) gt 0>
	<cfset basQual = " #basQual# AND upper(#session.flatTableName#.datum) LIKE '%#UCASE(datum)#%'">
	<cfset mapurl = "#mapurl#&datum=#datum#">
</cfif>
<cfif isdefined("county") AND len(county) gt 0>
	<cfif compare(County,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.County is null">
	<cfelseif left(county,1) is '='>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.County) = '#UCASE(escapeQuotes(right(County,len(County)-1)))#'">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.County) LIKE '%#UCASE(County)#%'">
	</cfif>
	<cfset mapurl = "#mapurl#&county=#URLEncodedFormat(county)#">
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
	<cfset mapurl = "#mapurl#&inCounty=#URLEncodedFormat(inCounty)#">
</cfif>
<cfif isdefined("Quad") AND len(Quad) gt 0>
	<cfset temp=getFlatSql(fld="Quad", val=Quad)>
</cfif>
<cfif isdefined("partname") AND len(partname) gt 0>
	<cfset part_name=partname>
</cfif>
<cfif isdefined("part_attribute") AND len(part_attribute) gt 0>
	<cfset mapurl = "#mapurl#&part_attribute=#URLEncodedFormat(part_attribute)#">
	<cfif basJoin does not contain " specimen_part ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfif basJoin does not contain " specimen_part_attribute ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part_attribute ON (specimen_part.collection_object_id = specimen_part_attribute.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND specimen_part_attribute.attribute_type = '#part_attribute#'">
	<cfif session.flatTableName is not "flat">
		<cfset basQual = " #basQual# AND (#session.flatTableName#.encumbrances is null or #session.flatTableName#.encumbrances not like '%mask part attribute%') ">
	</cfif>
</cfif>
<cfif isdefined("part_attribute_value") AND len(part_attribute_value) gt 0>
	<cfset mapurl = "#mapurl#&part_attribute_value=#URLEncodedFormat(part_attribute_value)#">
	<cfif basJoin does not contain " specimen_part ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfif basJoin does not contain " specimen_part_attribute ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part_attribute ON (specimen_part.collection_object_id = specimen_part_attribute.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(specimen_part_attribute.attribute_value) like '%#ucase(escapeQuotes(part_attribute_value))#%'">
</cfif>

<cfif isdefined("part_remark") AND len(part_remark) gt 0>
	<cfset mapurl = "#mapurl#&part_remark=#URLEncodedFormat(part_remark)#">
	<cfif basJoin does not contain " specimen_part ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfset basJoin = " #basJoin# INNER JOIN coll_object_remark ON (specimen_part.collection_object_id = coll_object_remark.collection_object_id)">
	<cfset basQual = " #basQual# AND upper(coll_object_remark.coll_object_remarks) like '%#ucase(part_remark)#%'">
</cfif>
<cfif isdefined("part_name") AND len(part_name) gt 0>
	<cfset mapurl = "#mapurl#&part_name=#URLEncodedFormat(part_name)#">
	<cfif part_name contains "|">
		<cfset i=1>
		<cfloop list="#part_name#" delimiters="|" index="p">
			<cfset basJoin = " #basJoin# INNER JOIN specimen_part sp#i# ON (#session.flatTableName#.collection_object_id = sp#i#.derived_from_cat_item)">
			<cfset basQual = " #basQual# AND sp#i#.part_name = '#p#'">
			<cfset i=i+1>
		</cfloop>
	<cfelseif left(part_name,1) is '='>
		<cfif basJoin does not contain " specimen_part ">
			<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id = specimen_part.derived_from_cat_item)">
		</cfif>
		<cfset basQual = " #basQual# AND specimen_part.part_name = '#right(part_name,len(part_name)-1)#'">
	<cfelse><!--- part name only --->
		<cfset basQual = " #basQual# AND upper(PARTS) LIKE '%#ucase(escapeQuotes(part_name))#%'">
	</cfif>
</cfif>
<cfif isdefined("is_tissue") AND is_tissue is 1>
	<cfset mapurl = "#mapurl#&is_tissue=#is_tissue#">
	<cfset basJoin = " #basJoin# INNER JOIN specimen_part spt ON (#session.flatTableName#.collection_object_id = spt.derived_from_cat_item)
		inner join ctspecimen_part_name on (spt.part_name=ctspecimen_part_name.part_name)">
	<cfset basQual = " #basQual# AND ctspecimen_part_name.is_tissue = 1">
</cfif>
<cfif isdefined("part_disposition") AND len(part_disposition) gt 0>
	<cfset mapurl = "#mapurl#&part_disposition=#URLEncodedFormat(part_disposition)#">
	<cfset basJoin = " #basJoin#
		INNER JOIN specimen_part spdisp ON (#session.flatTableName#.collection_object_id = spdisp.derived_from_cat_item)
		inner join coll_object partCollObj on (spdisp.collection_object_id=partCollObj.collection_object_id)">
	<cfset basQual = " #basQual# AND partCollObj.coll_obj_disposition='#part_disposition#'">
</cfif>
<cfif isdefined("part_condition") AND len(part_condition) gt 0>
	<cfset basJoin = " #basJoin#
			INNER JOIN specimen_part spdisp ON (#session.flatTableName#.collection_object_id = spdisp.derived_from_cat_item)
			inner join coll_object partCollObj on (spdisp.collection_object_id=partCollObj.collection_object_id)">
	<cfset basQual = " #basQual# AND upper(partCollObj.condition) like '%#ucase(part_condition)#%'">
	<cfset mapurl = "#mapurl#&part_condition=#URLEncodedFormat(part_condition)#">
</cfif>
<cfif isdefined("Common_Name") AND len(Common_Name) gt 0>
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ON (identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfif basJoin does not contain " common_name ">
		<cfset basJoin = " #basJoin# INNER JOIN common_name ON (identification_taxonomy.taxon_name_id = common_name.taxon_name_id)">
	</cfif>
	<cfset basQual = " #basQual#  AND UPPER(common_name.Common_Name) LIKE '%#ucase(stripQuotes(Common_Name))#%'">
	<cfif isdefined("scientific_name_scope") and scientific_name_scope is "currentID">
		<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 ">
	</cfif>
	<cfset mapurl = "#mapurl#&Common_Name=#URLEncodedFormat(Common_Name)#">
</cfif>
<cfif isdefined("publication_doi") AND len(publication_doi) gt 0>
	<!--- see if we can peel off any of the junk that comes with DOIs ---->
	<cfset stripDOI=ucase(trim(publication_doi))>
	<cfset stripDOI=replace(stripDOI,'DOI:','','first')>
	<cfset stripDOI=replace(stripDOI,'HTTPS://','','first')>
	<cfset stripDOI=replace(stripDOI,'HTTP://','','first')>
	<cfset stripDOI=replace(stripDOI,'DX.DOI.ORG/','','first')>
	<cfif basJoin does not contain " citation ">
		<cfset basJoin = " #basJoin# INNER JOIN citation ON (#session.flatTableName#.collection_object_id = citation.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " publication ">
		<cfset basJoin = " #basJoin# INNER JOIN publication ON (citation.publication_id = publication.publication_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(publication.doi) = '#stripDOI#' ">
	<cfset mapurl = "#mapurl#&publication_doi=#URLEncodedFormat(publication_doi)#">
</cfif>

<cfif isdefined("publication_title") AND len(publication_title) gt 0>
	<cfif basJoin does not contain " citation ">
		<cfset basJoin = " #basJoin# INNER JOIN citation ON (#session.flatTableName#.collection_object_id = citation.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " publication ">
		<cfset basJoin = " #basJoin# INNER JOIN publication ON (citation.publication_id = publication.publication_id)">
	</cfif>
	<cfset basQual = " #basQual# AND (upper(publication.FULL_CITATION) like '%#ucase(stripQuotes(publication_title))#%'
		OR upper(publication.SHORT_CITATION) like '%#ucase(stripQuotes(publication_title))#%')">
	<cfset mapurl = "#mapurl#&publication_title=#URLEncodedFormat(publication_title)#">
</cfif>

<cfif isdefined("publication_id") AND len(publication_id) gt 0>
	<cfif basJoin does not contain " citation ">
		<cfset basJoin = " #basJoin# INNER JOIN citation ON (#session.flatTableName#.collection_object_id = citation.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND publication_id = #VAL(publication_id)#">
	<cfset mapurl = "#mapurl#&publication_id=#publication_id#">
</cfif>
<cfif isdefined("ispublished") and len(ispublished) gt 0>
	<!---
		from specimenresults, should be "yes" or "no" and double-equal-orefixed
		MAKE SURE THIS IS PROCESSED BEFORE type_status!!
	---->
	<cfif ispublished contains "yes">
		<cfset 	type_status='any'>
	<cfelse>
		<cfset 	type_status='NULL'>
	</cfif>
</cfif>
<cfif isdefined("type_status") and len(type_status) gt 0>
	<cfif compare(type_status,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.TYPESTATUS IS NULL">
	<cfelseif type_status is "any">
		<cfset basQual = " #basQual# AND #session.flatTableName#.TYPESTATUS IS NOT NULL">
	<cfelse>
		<cfset basQual = " #basQual# AND upper(#session.flatTableName#.TYPESTATUS) LIKE '%#ucase(type_status)#%'">
	</cfif>
	<cfset mapurl = "#mapurl#&type_status=#URLEncodedFormat(type_status)#">
</cfif>
<cfif isdefined("collection_object_id") AND len(collection_object_id) gt 0>
	<cfset basQual = " #basQual# AND #session.flatTableName#.collection_object_id IN (#collection_object_id#)">
	<cfset mapurl = "#mapurl#&collection_object_id=#collection_object_id#">
</cfif>
<cfif isdefined("project_id") AND len(project_id) gt 0>
	<cfif basJoin does not contain " projAccn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn projAccn ON (#session.flatTableName#.accn_id = projAccn.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " project_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN project_trans ON (projAccn.transaction_id = project_trans.transaction_id)">
	</cfif>
	<cfset basQual = " #basQual# AND project_trans.project_id = #project_id#">
	<cfset mapurl = "#mapurl#&project_id=#project_id#">
</cfif>
<cfif isdefined("project_sponsor") AND len(project_sponsor) gt 0>
	<cfset basJoin = " #basJoin# INNER JOIN project_trans sProjTrans ON (#session.flatTableName#.accn_id = sProjTrans.transaction_id)
		INNER JOIN PROJECT_AGENT ON (sProjTrans.project_id = PROJECT_AGENT.project_id)
		INNER JOIN preferred_agent_name sAgentName ON (PROJECT_AGENT.agent_id = sAgentName.agent_id)">
	<cfset basQual = " #basQual# AND upper(sAgentName.agent_name) LIKE '%#ucase(project_sponsor)#%' and PROJECT_AGENT.PROJECT_AGENT_ROLE='Sponsor'">
	<cfset mapurl = "#mapurl#&project_sponsor=#URLEncodedFormat(project_sponsor)#">
</cfif>
<cfif isdefined("loan_project_name") AND len(loan_project_name) gt 0>
	<cfif basJoin does not contain " specimen_part ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfif basJoin does not contain " loan_item ">
		<cfset basJoin = " #basJoin# INNER JOIN loan_item ON (specimen_part.collection_object_id = loan_item.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " project_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN project_trans ON (loan_item.transaction_id = project_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " project ">
		<cfset basJoin = " #basJoin# INNER JOIN project ON (project_trans.project_id = project.project_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(regexp_replace(project.project_name,'<[^>]*>')) like '%#ucase(loan_project_name)#%'">
	<cfset mapurl = "#mapurl#&loan_project_name=#URLEncodedFormat(loan_project_name)#">
</cfif>

<cfif isdefined("loan_project_id") AND len(loan_project_id) gt 0>
	<cfset mapurl = "#mapurl#&loan_project_id=#loan_project_id#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.collection_object_id IN (
		SELECT
			#session.flatTableName#.collection_object_id
		FROM
			#session.flatTableName#,
			specimen_part,
			loan_item,
			project_trans
		WHERE
			#session.flatTableName#.collection_object_id=specimen_part.derived_from_cat_item AND
			specimen_part.collection_object_id = loan_item.collection_object_id AND
			loan_item.transaction_id = project_trans.transaction_id AND
			project_trans.project_id in ( #loan_project_id# )
		UNION -- data loans
		SELECT
			#session.flatTableName#.collection_object_id
		FROM
			#session.flatTableName#,
			loan_item,
			project_trans
		WHERE
			#session.flatTableName#.collection_object_id = loan_item.collection_object_id AND
			loan_item.transaction_id = project_trans.transaction_id AND
			project_trans.project_id in ( #loan_project_id# ) )">
</cfif>
<cfif isdefined("project_name") AND len(project_name) gt 0>
	<cfif basJoin does not contain " projAccn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn projAccn ON (#session.flatTableName#.accn_id = projAccn.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " project_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN project_trans ON (projAccn.transaction_id = project_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " project ">
		<cfset basJoin = " #basJoin# INNER JOIN project ON (project_trans.project_id = project.project_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(regexp_replace(project.project_name,'<[^>]*>')) like '%#ucase(project_name)#%'">
	<cfset mapurl = "#mapurl#&project_name=#URLEncodedFormat(project_name)#">
</cfif>

<cfif isdefined("data_loan_trans_id") and len(data_loan_trans_id) gt 0>
	<cfset mapurl = "#mapurl#&data_loan_trans_id=#data_loan_trans_id#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.collection_object_id IN (
		select loan_item.collection_object_id from loan_item where loan_item.transaction_id in (#data_loan_trans_id#)
	)">
</cfif>
<cfif isdefined("loan_trans_id") and len(loan_trans_id) gt 0>
	<cfset mapurl = "#mapurl#&loan_trans_id=#loan_trans_id#">
	<cfset basQual = " #basQual# AND #session.flatTableName#.collection_object_id IN (
		select derived_from_cat_item from specimen_part,loan_item where
			specimen_part.collection_object_id=loan_item.collection_object_id and loan_item.transaction_id in (#loan_trans_id#)
		union
			select loan_item.collection_object_id from loan_item where loan_item.transaction_id in (#loan_trans_id#)
			)">
</cfif>
<cfif isdefined("loan_permit_trans_id") and len(loan_permit_trans_id) gt 0>
	<cfset mapurl = "#mapurl#&loan_permit_trans_id=#loan_permit_trans_id#">
	<cfif basJoin does not contain " loan_permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part loan_part ON (#session.flatTableName#.collection_object_id = loan_part.derived_from_cat_item)
			INNER JOIN loan_item ON (loan_part.collection_object_id = loan_item.collection_object_id)
			INNER JOIN permit_trans loan_permit_trans ON (loan_item.transaction_id = loan_permit_trans.transaction_id)">
	</cfif>
	<cfset basQual = " #basQual# AND loan_permit_trans.transaction_id IN (#loan_permit_trans_id#)">
</cfif>
<cfif isdefined("accn_permit_trans_id") and len(accn_permit_trans_id) gt 0>
	<cfset mapurl = "#mapurl#&accn_permit_trans_id=#accn_permit_trans_id#">
	<cfif basJoin does not contain " permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON (#session.flatTableName#.accn_id = permit_trans.transaction_id)">
	</cfif>
	<cfset basQual = " #basQual# AND permit_trans.transaction_id IN (#accn_permit_trans_id#)">
</cfif>
<cfif isdefined("permit_issued_by") AND len(permit_issued_by) gt 0>
	<cfset mapurl = "#mapurl#&permit_issued_by=#URLEncodedFormat(permit_issued_by)#">
	<cfif basJoin does not contain " permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON (#session.flatTableName#.accn_id = permit_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " permit ">
		<cfset basJoin = " #basJoin# INNER JOIN permit ON (permit_trans.permit_id = permit.permit_id)">
	</cfif>
	<cfif basJoin does not contain " permit_issued ">
		<cfset basJoin = " #basJoin# INNER JOIN agent_name permit_issued ON (permit.issued_by_agent_id = permit_issued.agent_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(permit_issued.agent_name) like '%#ucase(permit_issued_by)#%'">
</cfif>
<cfif isdefined("permit_issued_to") AND len(permit_issued_to) gt 0>
	<cfset mapurl = "#mapurl#&permit_issued_to=#URLEncodedFormat(permit_issued_to)#">
	<cfif basJoin does not contain " permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON (#session.flatTableName#.accn_id = permit_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " permit ">
		<cfset basJoin = " #basJoin# INNER JOIN permit ON (permit_trans.permit_id = permit.permit_id)">
	</cfif>
	<cfif basJoin does not contain " permit_to ">
		<cfset basJoin = " #basJoin# INNER JOIN agent_name permit_to ON (permit.issued_by_agent_id = permit_to.agent_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(permit_to.agent_name) like '%#ucase(permit_issued_to)#%'">
</cfif>
<cfif isdefined("permit_type") AND len(permit_type) gt 0>
<cfset mapurl = "#mapurl#&permit_type=#permit_type#">
	<cfif basJoin does not contain " permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON (#session.flatTableName#.accn_id = permit_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " permit ">
		<cfset basJoin = " #basJoin# INNER JOIN permit ON (permit_trans.permit_id = permit.permit_id)">
	</cfif>
	<cfset basQual = " #basQual# AND permit_type='#escapeQuotes(permit_type)#'">
</cfif>
<cfif isdefined("permit_num") AND len(permit_num) gt 0>
	<cfset mapurl = "#mapurl#&permit_num=#permit_num#">
	<cfif basJoin does not contain " permit_trans ">
		<cfset basJoin = " #basJoin# INNER JOIN permit_trans ON (#session.flatTableName#.accn_id = permit_trans.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " permit ">
		<cfset basJoin = " #basJoin# INNER JOIN permit ON (permit_trans.permit_id = permit.permit_id)">
	</cfif>
	<cfset basQual = " #basQual# AND permit_num='#permit_num#'">
</cfif>
<cfif isdefined("remark") AND len(remark) gt 0>
	<cfset mapurl = "#mapurl#&remark=#URLEncodedFormat(remark)#">
	<cfset basQual = " #basQual# AND upper(#session.flatTableName#.remarks) LIKE '%#ucase(remark)#%'">
</cfif>
<cfif isdefined("attributed_determiner_agent_id") AND len(attributed_determiner_agent_id) gt 0>
	<cfset mapurl = "#mapurl#&attributed_determiner_agent_id=#attributed_determiner_agent_id#">
	<cfif basJoin does not contain " attributes ">
		<cfset basJoin = " #basJoin# INNER JOIN attributes ON
		(#session.flatTableName#.collection_object_id = attributes.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND attributes.determined_by_agent_id = #attributed_determiner_agent_id#">
</cfif>
<cfif isdefined("attribute_type") AND len(attribute_type) gt 0>
	<cfset attribute_type_1=attribute_type>
</cfif>
<cfif isdefined("attribute_operator") AND len(attribute_operator) gt 0>
	<cfset attOper_1=attribute_operator>
</cfif>
<!---- use DDL/admin/buildCFCodeToQueryAttributeByName.sql to build this code ---->


<!--- end of code built by DDL/admin/buildCFCodeToQueryAttributeByName.sql ---->
<cfif isdefined("attribute_value") AND len(attribute_value) gt 0>
	<cfset attribute_value_1=attribute_value>
</cfif>
<cfif isdefined("attribute_remark") AND len(attribute_remark) gt 0>
	<cfset mapurl = "#mapurl#&attribute_remark=#URLEncodedFormat(attribute_remark)#">
	<cfset basJoin = " #basJoin# INNER JOIN v_attributes attributes_rmk ON (#session.flatTableName#.collection_object_id = attributes_rmk.collection_object_id)">
	<cfif session.flatTableName is not "flat">
		<cfset basQual = " #basQual# AND attributes_rmk.is_encumbered = 0">
	</cfif>
	<cfset basQual = " #basQual# AND upper(attributes_rmk.attribute_REMARK) LIKE '%#ucase(escapeQuotes(attribute_remark))#%'">
</cfif>
<cfif isdefined("attribute_type_1") AND len(attribute_type_1) gt 0>
	<cfset mapurl = "#mapurl#&attribute_type_1=#URLEncodedFormat(attribute_type_1)#">
	<cfif basJoin does not contain " attributes_1 ">
		<cfset basJoin = " #basJoin# INNER JOIN v_attributes attributes_1 ON (#session.flatTableName#.collection_object_id = attributes_1.collection_object_id)">
	</cfif>
	<cfif session.flatTableName is not "flat">
		<cfset basQual = " #basQual# AND attributes_1.is_encumbered = 0">
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
	<cfset mapurl = "#mapurl#&attribute_type_2=#URLEncodedFormat(attribute_type_2)#">
	<cfif basJoin does not contain " attributes_2 ">
		<cfset basJoin = " #basJoin# INNER JOIN v_attributes attributes_2 ON (#session.flatTableName#.collection_object_id = attributes_2.collection_object_id)">
	</cfif>
	<cfif session.flatTableName is not "flat">
		<cfset basQual = " #basQual# AND attributes_2.is_encumbered = 0">
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
		<cfset basJoin = " #basJoin# INNER JOIN v_attributes attributes_3 ON
		(#session.flatTableName#.collection_object_id = attributes_3.collection_object_id)">
	</cfif>
	<cfif session.flatTableName is not "flat">
		<cfset basQual = " #basQual# AND attributes_3.is_encumbered = 0">
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
	<cfset basQual = " #basQual# AND #session.flatTableName#.collection_object_id NOT IN (#exclCollObjId#)">
</cfif>
<cfif isdefined("institution_appearance") AND len(institution_appearance) gt 0>
	<cfquery name="whatInst" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select collection_id from collection where institution_acronym='#institution_appearance#'
	</cfquery>
	<cfset goodCollIds = valuelist(whatInst.collection_id,",")>
	<cfset basQual = " #basQual# AND #session.flatTableName#.collection_id  IN (#goodCollIds#)">
</cfif>

<cfinclude template="/includes/SearchSql_attributes.cfm">



<!---------- SPECIAL NOTE: Archives may not be combined with anything else. This MUST be the last thing in the code ----->

<cfif isdefined("archive_name") AND len(archive_name) gt 0>
	<cfquery name="archive_check" datasource="uam_god">
		select
			is_locked,
			creator,
			count(*)c
		from
			archive_name,
			specimen_archive
		where
			archive_name='#archive_name#' and
			archive_name.archive_id=specimen_archive.archive_id (+)
		group by is_locked,creator
	</cfquery>
	<!--- pass this on to results so we can alert people if something is wonky ---->
	<cfset archive_record_count=archive_check.c>
	<cfif len(archive_record_count) is 0>
		<cfset archive_record_count=0>
		<div class="importantNotification">
			Caution: The Archive does not seem to exist. Contact the person who shared the link, of use the Contact link in the footer
			at the bottom of this page.
		</div>
	</cfif>
	<!----
		<cfif archive_check.is_locked eq 1>
			<div class="importantNotification">
				Important Note: You are viewing a locked Archive. Archives may not be combined with other search terms;
				any additional terms will be ignored.
			</div>
			<cfset mapurl = "archive_name=#archive_name#">
			<cfset basJoin = " INNER JOIN specimen_archive ON (#session.flatTableName#.guid = specimen_archive.guid)
				INNER JOIN archive_name ON 	(specimen_archive.archive_id = archive_name.archive_id)">
			<cfset basQual = " and archive_name='#lcase(archive_name)#'" >
		</cfif>
		<cfif archive_check.is_locked eq 0>
		---->
			<cfset mapurl = "#mapurl#&archive_name=#archive_name#">
			<cfset basJoin = " #basJoin# INNER JOIN specimen_archive ON (#session.flatTableName#.guid = specimen_archive.guid)
				INNER JOIN archive_name ON 	(specimen_archive.archive_id = archive_name.archive_id)">
			<cfset basQual = " #basQual# and archive_name='#lcase(archive_name)#'" >
			<!----

			<cfif archive_check.creator is session.username and session.roles contains "manage_collection">
				<cfoutput>
					<div class="importantNotification">
						<strong>
							READ THIS!
							<br>Locked Archives may not be unlocked or modified for any purpose.
							<br>Specimens in locked archives may not be encumbered or deleted.
							<br>Clicking the button below invokes a long-term curatorial committment.
						</strong>
						<span class="likeLink" onclick="lockArchive('#archive_name#')">Click here to lock</span>.
					</div>
				</cfoutput>
			</cfif>

		</cfif>
		---->
</cfif>