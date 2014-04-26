<cfset extendedErrorMsg="">
<cfif not isdefined("basQual")>
	<cfset basQual = "">
</cfif>
<cfif not isdefined("mapurl")>
	<cfset mapurl="">
</cfif>
<!----------------------------------- translate deprecated terms when possible ---------------------------->
<cfif isdefined("listcatnum")>
	<cfset catnum = listcatnum>
</cfif>
<cfif isdefined("cat_num")>
	<cfset catnum = cat_num>
</cfif>


<cfif isdefined("year") AND len(year) gt 0>
	<cfset begYear=year>
	<cfset endYear=year>
</cfif>

<cfif isdefined("sciname") and len(sciname) gt 0>
	<cfset scientific_name=sciname>
	<cfset scientific_name_match_type="contains">
</cfif>
<cfif isdefined("scientific_name") AND len(scientific_name) gt 0>
	<cfif left(scientific_name,1) is '='>
		<cfset scientific_name=right(scientific_name,len(scientific_name)-1)>
		<cfset scientific_name_match_type="contains">
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

<cfif isdefined("cataloged_item_type") AND len(cataloged_item_type) gt 0>
	<cfset mapurl = "#mapurl#&cataloged_item_type=#cataloged_item_type#">
	<cfset basQual = "#basQual#  AND  #session.flatTableName#.cataloged_item_type='#cataloged_item_type#'" >
</cfif>
<!---- rcoords is round(n,2) concatenated coordinates from spatial browse ---->
<cfif isdefined("rcoords") AND len(rcoords) gt 0>
	<cfset mapurl = "#mapurl#&rcoords=#rcoords#">
	<cfset basQual = "#basQual#  AND  round(#session.flatTableName#.dec_lat,1) || ',' || round(#session.flatTableName#.dec_long,1)='#rcoords#'" >
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
<cfif isdefined("cited_taxon_name_id") AND len(cited_taxon_name_id) gt 0>
	<cfif basJoin does not contain " citation ">
		<cfset basJoin = " #basJoin# INNER JOIN citation ON (#session.flatTableName#.collection_object_id = citation.collection_object_id)">
	</cfif>
	<cfset basJoin = " #basJoin# INNER JOIN identification_taxonomy ident_cit_tax ON (citation.identification_id = ident_cit_tax.identification_id)">
	<cfset basQual = " #basQual# AND ident_cit_tax.taxon_name_id = #cited_taxon_name_id#">
	<cfset mapurl = "#mapurl#&cited_taxon_name_id=#cited_taxon_name_id#">
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
	<cfset basQual = " #basQual# AND identification_taxonomy.taxon_name_id = #taxon_name_id#
		AND identification.accepted_id_fg=1">
	<cfset mapurl = "#mapurl#&taxon_name_id=#taxon_name_id#">
</cfif>

<cfif isdefined("scientific_name") AND len(scientific_name) gt 0>
	<cfif not isdefined("scientific_name_scope") OR len(scientific_name_scope) is 0>
		<cfset scientific_name_scope = "currentID">
	</cfif>
	<cfif not isdefined("scientific_name_match_type") OR len(scientific_name_match_type) is 0>
		<cfset scientific_name_match_type = "contains">
	</cfif>
	<cfset mapurl = "#mapurl#&scientific_name=#scientific_name#">
	<cfset mapurl = "#mapurl#&scientific_name_scope=#scientific_name_scope#">
	<cfset mapurl = "#mapurl#&scientific_name_match_type=#scientific_name_match_type#">
	
	<cfif scientific_name_scope is "currentID">
		<cfif scientific_name_match_type is "contains">
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) LIKE '#ucase(escapeQuotes(scientific_name))#%'">
		<cfelseif scientific_name_match_type is "exact">
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) = '#ucase(escapeQuotes(scientific_name))#'">
		<cfelseif scientific_name_match_type is "notcontains">
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) NOT LIKE '%#ucase(escapeQuotes(scientific_name))#%'">
		<cfelseif scientific_name_match_type is "inlist">
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) in (#listqualify(ucase(scientific_name),chr(39))#)">
		<cfelseif scientific_name_match_type is "inlist_substring">
			<cfset basQual = " #basQual# AND (">
			<cfloop list="#scientific_name#" index="i" delimiters=",">
				<cfset basQual = " #basQual# upper(#session.flatTableName#.scientific_name) like '%#ucase(i)#%' OR ">
			</cfloop>
			<cfset basQual = left(basQual,len(basQual)-4) & ")">
		</cfif>
	<cfelseif scientific_name_scope is "allID">
		<cfif basJoin does not contain " identification ">
			<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
		</cfif>
		<cfif scientific_name_match_type is "contains">
			<cfset basQual = " #basQual# AND upper(identification.scientific_name) LIKE '%#ucase(escapeQuotes(scientific_name))#%'">
		<cfelseif scientific_name_match_type is "exact">
			<cfset basQual = " #basQual# AND upper(identification.scientific_name) = '#ucase(escapeQuotes(scientific_name))#'">
		<cfelseif scientific_name_match_type is "notcontains">
			<cfset basQual = " #basQual# upper(identification.scientific_name) NOT LIKE '%#ucase(escapeQuotes(scientific_name))#%'">
		<cfelseif scientific_name_match_type is "inlist">
			<cfset basQual = " #basQual# AND upper(identification.scientific_name) in (#listqualify(ucase(scientific_name),chr(39))#)">
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
	
	
	<cfset basQual = basQual & " and identification_taxonomy.taxon_name_id in ( #combinedTaxIDs# )">
	
	
	 		
	<!----	
		if we have a taxon_term, it may be accompanied by any of the following:
			taxon_source
				collection_preferred (DEFAULT) - join to collection source
				all - don't join to collection; hit anything
				somethingelse: taxon_term.source=somethingelse
			taxon_rank
				empty: ignore
				something: match
			taxon_term_scope
				currentID: identification.accepted_id_fg filter
				allID: just join to identification
			taxon_term_match_type
				contains (default) 
				exact
				notcontains
				inlist
		also do whatever we're doing for related taxa
		
		
		
		IN seems to perform just as well, and is nice to write SQL to, so.....
		
		
	<cfif not isdefined("taxon_source") OR len(taxon_source) is 0>
		<cfset taxon_source = "collection_preferred">
	</cfif>
	<cfif not isdefined("taxon_rank")>
		<cfset taxon_rank = "">
	</cfif>
	<cfif not isdefined("taxon_term_scope") OR len(taxon_term_scope) is 0>
		<cfset taxon_term_scope = "currentID">
	</cfif>
	<cfif not isdefined("taxon_term_match_type") OR len(taxon_term_match_type) is 0>
		<cfset taxon_term_match_type = "contains">
	</cfif>
	
	<cfset mapurl = "#mapurl#&taxon_name=#taxon_name#">
	<cfset mapurl = "#mapurl#&taxon_source=#taxon_source#">
	<cfset mapurl = "#mapurl#&taxon_rank=#taxon_rank#">
	<cfset mapurl = "#mapurl#&taxon_term_scope=#taxon_term_scope#">
	<cfset mapurl = "#mapurl#&taxon_term_match_type=#taxon_term_match_type#">
	
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " identification_taxonomy ">
		<cfset basJoin = " #basJoin# inner join identification_taxonomy on (identification.identification_id = identification_taxonomy.identification_id)">
	</cfif>
	<cfif taxon_term_scope is "currentID">
		<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 ">
	</cfif>

	<cfset currTaxIDs=" select taxon_name_id from taxon_term where upper(taxon_term.term) ">
	<cfset relTaxIDs=" select related_taxon_name_id from taxon_relations,taxon_term where taxon_relations.taxon_name_id=taxon_term.taxon_name_id and upper(taxon_term.term) ">
	<cfset invRelTaxIDs=" select taxon_term.taxon_name_id from taxon_relations,taxon_term where taxon_relations.related_taxon_name_id=taxon_term.taxon_name_id and upper(taxon_term.term) ">
	
	<cfif taxon_term_match_type is "contains">
		<cfset currTaxIDs = currTaxIDs & " LIKE '%#ucase(escapeQuotes(taxon_name))#%' ">
		<cfset relTaxIDs = relTaxIDs & " LIKE '%#ucase(escapeQuotes(taxon_name))#%' ">
		<cfset invRelTaxIDs = invRelTaxIDs & " LIKE '%#ucase(escapeQuotes(taxon_name))#%' ">
	<cfelseif taxon_term_match_type is "exact">
		<cfset currTaxIDs = currTaxIDs & " = '#ucase(escapeQuotes(taxon_name))#' ">
		<cfset relTaxIDs = relTaxIDs & " = '#ucase(escapeQuotes(taxon_name))#' ">
		<cfset invRelTaxIDs = invRelTaxIDs & " = '#ucase(escapeQuotes(taxon_name))#' ">		
	<cfelseif taxon_term_match_type is "notcontains">
		<cfset currTaxIDs = currTaxIDs & " NOT LIKE '%#ucase(escapeQuotes(taxon_name))#%' ">
	<cfelseif taxon_term_match_type is "inlist">
		<cfset currTaxIDs = currTaxIDs & " in ( #listqualify(ucase(taxon_name),chr(39))# ) ">
		<cfset relTaxIDs = relTaxIDs & " in ( #listqualify(ucase(taxon_name),chr(39))# ) ">
		<cfset invRelTaxIDs = invRelTaxIDs & " in ( #listqualify(ucase(taxon_name),chr(39))# ) ">
	 </cfif>
	 
	<cfif taxon_source is "all">
		<!--- do nothing --->
	<cfelseif taxon_source is "collection_preferred">
		 <cfset currTaxIDs=currTaxIDs & " and taxon_term.source = (select preferred_taxonomy_source from collection where collection_id=#session.flatTableName#.collection_id ) ">
	<cfelse>
	 	<cfset currTaxIDs=currTaxIDs & " and taxon_term.source = '#taxon_source#' ">
	 	<cfset relTaxIDs=relTaxIDs & " and taxon_term.source = '#taxon_source#' ">
	 	<cfset invRelTaxIDs=invRelTaxIDs & " and taxon_term.source = '#taxon_source#' ">
	 </cfif>
	 
	 <cfif len(taxon_rank) gt 0>
		<cfset currTaxIDs = currTaxIDs & " AND taxon_term.term_type = '#taxon_rank#' ">
		<cfset relTaxIDs = relTaxIDs & " AND taxon_term.term_type = '#taxon_rank#' ">
		<cfset invRelTaxIDs = invRelTaxIDs & " AND taxon_term.term_type = '#taxon_rank#' ">
	</cfif>
		
	
	
	
	<cfif taxon_term_match_type is "notcontains">
		<cfset combinedTaxIDs=currTaxIDs>
	<cfelse>
		<cfset combinedTaxIDs=currTaxIDs & " union " & relTaxIDs & " union " & invRelTaxIDs>
	</cfif>
	
	
	<cfset combinedTaxIDs=currTaxIDs>
	
	
	<cfset basQual = basQual & " and identification_taxonomy.taxon_name_id in ( #combinedTaxIDs# )">
	
	
	
<!----



	<cfif taxon_source is "collection_preferred">
		<cfif basJoin does not contain " collection ">
			<cfset basJoin = " #basJoin# inner join collection on (#session.flatTableName#.collection_id = collection.collection_id)">
			<cfset basQual = " #basQual# AND taxon_term.source = collection.preferred_taxonomy_source ">
		</cfif>
	</cfif>
	
	
	
		 
    union 
     LIKE '%MARMOTINI%'
    UNION
		
	<cfif basJoin does not contain " taxon_name ">
		<cfset basJoin = " #basJoin# inner join taxon_name on (identification_taxonomy.taxon_name_id = taxon_name.taxon_name_id)">
	</cfif>
	<cfif basJoin does not contain " taxon_term ">
		<cfset basJoin = " #basJoin# inner join taxon_term on (taxon_name.taxon_name_id = taxon_term.taxon_name_id)">
	</cfif>
	
	---->
	
	
	
	
	
	<!--- criteria and qualifications --->
	
	
	

	
	<!----------
	
		<cfelseif taxon_source is "all">
		<!--- do nothing --->
	<cfelse>
		<cfset basQual = " #basQual# AND taxon_term.source = '#taxon_source#' ">
	</cfif>
	<cfif len(taxon_rank) gt 0>
		<cfset basQual = " #basQual# AND taxon_term.term_type = '#taxon_rank#' ">
	</cfif>
	
	<!--- always hit relationships ---->
	<cfif basJoin does not contain " taxon_relations ">
		<cfset basJoin = " #basJoin# left outer join taxon_relations on (taxon_name.taxon_name_id = taxon_relations.taxon_name_id)">
	</cfif>
	<cfset basJoin = " #basJoin# left outer JOIN taxon_term relatedtaxonomy ON (taxon_relations.RELATED_TAXON_NAME_ID = taxon_term.taxon_name_id)">
	<cfset basJoin = " #basJoin# left outer JOIN taxon_relations invrelations ON (taxon_name.taxon_name_id = invrelations.RELATED_TAXON_NAME_ID)">
	<cfset basJoin = " #basJoin# left outer JOIN taxon_term invrelatedtaxonomy ON (invrelations.taxon_name_id = invrelatedtaxonomy.taxon_name_id)">
		
	<cfif taxon_term_match_type is "contains">
		<cfset basQual = " #basQual# AND (
			upper(taxon_term.term) LIKE '%#ucase(escapeQuotes(taxon_name))#%' )">
			
			<!---- OR
			upper(relatedtaxonomy.term) LIKE '%#ucase(escapeQuotes(taxon_name))#%' OR
			upper(invrelatedtaxonomy.term) LIKE '%#ucase(escapeQuotes(taxon_name))#%'
		)">
		---->
	<cfelseif taxon_term_match_type is "exact">
		<cfset basQual = " #basQual# AND (
			upper(taxon_term.term) = '#ucase(escapeQuotes(taxon_name))#')">
			<!----  OR
			upper(relatedtaxonomy.term) = '#ucase(escapeQuotes(taxon_name))#' OR
			upper(invrelatedtaxonomy.term) = '#ucase(escapeQuotes(taxon_name))#'
		)">
		---->
	<cfelseif taxon_term_match_type is "notcontains">
		<cfset basQual = " #basQual# AND upper(taxon_term.term) = '#ucase(escapeQuotes(taxon_name))#' ">
	<cfelseif taxon_term_match_type is "inlist">
		<cfset basQual = " #basQual# AND (
			upper(taxon_term.term) in (#listqualify(ucase(taxon_name),chr(39))#)  ) ">
			<!---- OR
			upper(relatedtaxonomy.term)  in (#listqualify(ucase(taxon_name),chr(39))#) OR
			upper(invrelatedtaxonomy.term)  in (#listqualify(ucase(taxon_name),chr(39))#---->
	</cfif>
	
	---------->	
		
		
	
	
	
	
	
	
	
		
		
		
	<!--------------
		
		
		<cfif taxon_term_match_type is "contains">
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%'">
		<cfelseif taxon_match_type is "exact">
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) = '#ucase(escapeQuotes(taxon_term))#'">
		<cfelseif taxon_match_type is "notcontains">
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) NOT LIKE '%#ucase(escapeQuotes(taxon_term))#%'">
		<cfelseif taxon_match_type is "inlist">
			<cfset basQual = " #basQual# AND upper(#session.flatTableName#.scientific_name) in (#listqualify(ucase(taxon_term),chr(39))#)">

		</cfif>
		
	<cfelseif taxon_scope is "anyID">
		<!---- current or previous identifications ---->
		<cfif basJoin does not contain " identification ">
			<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
		</cfif>
		<cfif taxon_match_type is "contains">
			<cfset basQual = " #basQual# AND upper(identification.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%'">
		<cfelseif taxon_match_type is "exact">
			<cfset basQual = " #basQual# AND upper(identification.scientific_name) = '#ucase(escapeQuotes(taxon_term))#'">
		<cfelseif taxon_match_type is "notcontains">
			<cfset basQual = " #basQual# upper(identification.scientific_name) NOT LIKE '%#ucase(escapeQuotes(taxon_term))#%'">
		<cfelseif taxon_match_type is "inlist">
			<cfset basQual = " #basQual# AND upper(identification.scientific_name) in (#listqualify(ucase(taxon_term),chr(39))#)">
		</cfif>
	<cfelseif taxon_scope is "taxonomy">
		<!--- collection preferred taxonomy of any ID ---->
		<cfif basJoin does not contain " identification ">
			<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
		</cfif>
		<cfif basJoin does not contain " identification_taxonomy ">
			<cfset basJoin = " #basJoin# inner join identification_taxonomy on (identification.identification_id = identification_taxonomy.identification_id)">
		</cfif>
		<cfif basJoin does not contain " taxon_name ">
			<cfset basJoin = " #basJoin# inner join taxon_name on (identification_taxonomy.taxon_name_id = taxon_name.taxon_name_id)">
		</cfif>
		<cfif basJoin does not contain " taxon_term ">
			<cfset basJoin = " #basJoin# inner join taxon_term on (taxon_name.taxon_name_id = taxon_term.taxon_name_id)">
		</cfif>
		<cfif basJoin does not contain " collection_taxon_source ">
			<cfset basJoin = " #basJoin# inner join collection collection_taxon_source on (taxon_term.source = collection_taxon_source.preferred_taxonomy_source)">
		</cfif>
		<cfif taxon_match_type is "contains">
			<cfset basQual = " #basQual# AND (
				upper(taxon_term.term) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR upper(taxon_name.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%')">
		<cfelseif taxon_match_type is "exact">
			<cfset basQual = " #basQual# AND ( upper(taxon_term.term) = '#ucase(escapeQuotes(taxon_term))#'">
		<cfelseif taxon_match_type is "notcontains">
			<cfset basQual = " #basQual# AND ( upper(taxon_term.term) = '#ucase(escapeQuotes(taxon_term))#' 
				OR upper(taxon_name.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%')">
		<cfelseif taxon_match_type is "inlist">
			<cfset basQual = " #basQual# AND (upper(taxon_term.term) in (#listqualify(ucase(taxon_term),chr(39))#) OR
			upper(taxon_name.scientific_name) in (#listqualify(ucase(taxon_term),chr(39))#)">
		</cfif>
		
	<cfelseif taxon_scope is "anyID_is">
		<cfif basJoin does not contain " identification ">
			<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
		</cfif>
		<cfset basQual = " #basQual# AND upper(identification.scientific_name) = '#ucase(escapeQuotes(taxon_term))#'">
	<cfelseif taxon_scope is "anyID_list">
		<cfif basJoin does not contain " identification ">
			<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
		</cfif>
		<cfset basQual = " #basQual# AND upper(identification.scientific_name) in (#listqualify(ucase(taxon_term),chr(39))#)">
	<cfelseif taxon_scope is "anyID_not">
		<cfif basJoin does not contain " identification ">
			<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
		</cfif>
		<cfset basQual = " #basQual# AND upper(identification.scientific_name) != '#ucase(escapeQuotes(taxon_term))#'">
	<cfelseif taxon_scope is "currentTaxonomy">
		<cfif basJoin does not contain " identification ">
			<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
		</cfif>
		<cfif basJoin does not contain " identification_taxonomy ">
			<cfset basJoin = " #basJoin# inner join identification_taxonomy on (identification.identification_id = identification_taxonomy.identification_id)">
		</cfif>
		<cfif basJoin does not contain " taxon_term_aggregate ">
			<cfset basJoin = " #basJoin# inner join taxon_term_aggregate on (identification_taxonomy.taxon_name_id = taxon_term_aggregate.taxon_name_id)">
		</cfif>	
		<cfset basQual = " #basQual# AND (
			upper(taxon_term_aggregate.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%' or
			upper(taxon_term_aggregate.terms) LIKE '%#ucase(escapeQuotes(taxon_term))#%'
			)">
	<cfelseif taxon_scope is "relatedTaxonomy">
		<cfif basJoin does not contain " identification ">
			<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
		</cfif>
		<cfif basJoin does not contain " identification_taxonomy ">
			<cfset basJoin = " #basJoin# inner join identification_taxonomy on (identification.identification_id = identification_taxonomy.identification_id)">
		</cfif>
		<cfif basJoin does not contain " taxon_term_aggregate ">
			<cfset basJoin = " #basJoin# inner join taxon_term_aggregate on (identification_taxonomy.taxon_name_id = taxon_term_aggregate.taxon_name_id)">
		</cfif>	
		<cfif basJoin does not contain " taxon_relations ">
			<cfset basJoin = " #basJoin# left outer join taxon_relations on (taxon_term_aggregate.taxon_name_id = taxon_relations.taxon_name_id)">
		</cfif>
		<cfset basJoin = " #basJoin# left outer JOIN taxon_term_aggregate relatedtaxonomy ON (taxon_relations.RELATED_TAXON_NAME_ID = relatedtaxonomy.taxon_name_id)">

		<cfset basJoin = " #basJoin# left outer JOIN taxon_relations invrelations ON (taxon_term_aggregate.taxon_name_id = invrelations.RELATED_TAXON_NAME_ID)">
		<cfset basJoin = " #basJoin# left outer JOIN taxon_term_aggregate invrelatedtaxonomy ON (invrelations.taxon_name_id = invrelatedtaxonomy.taxon_name_id)">
		<cfset basQual = " #basQual# AND (
			upper(taxon_term_aggregate.terms) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(taxon_term_aggregate.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(relatedtaxonomy.terms) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(relatedtaxonomy.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(invrelatedtaxonomy.terms) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(invrelatedtaxonomy.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(identification.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%'
		)">
		
		
	<cfelseif taxon_scope is "common">
		<cfif basJoin does not contain " identification ">
			<cfset basJoin = " #basJoin# inner join identification on (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
		</cfif>
		<cfif basJoin does not contain " identification_taxonomy ">
			<cfset basJoin = " #basJoin# inner join identification_taxonomy on (identification.identification_id = identification_taxonomy.identification_id)">
		</cfif>
		<cfif basJoin does not contain " taxon_term_aggregate ">
			<cfset basJoin = " #basJoin# inner join taxon_term_aggregate on (identification_taxonomy.taxon_name_id = taxon_term_aggregate.taxon_name_id)">
		</cfif>	
		<cfif basJoin does not contain " taxon_relations ">
			<cfset basJoin = " #basJoin# left outer join taxon_relations on (taxon_term_aggregate.taxon_name_id = taxon_relations.taxon_name_id)">
		</cfif>
		<cfset basJoin = " #basJoin# left outer JOIN taxon_term_aggregate relatedtaxonomy ON (taxon_relations.RELATED_TAXON_NAME_ID = relatedtaxonomy.taxon_name_id)">

		<cfset basJoin = " #basJoin# left outer JOIN taxon_relations invrelations ON (taxon_term_aggregate.taxon_name_id = invrelations.RELATED_TAXON_NAME_ID)">
		<cfset basJoin = " #basJoin# left outer JOIN taxon_term_aggregate invrelatedtaxonomy ON (invrelations.taxon_name_id = invrelatedtaxonomy.taxon_name_id)">
		<cfset basJoin = " #basJoin# left outer JOIN common_name ON (taxon_term_aggregate.taxon_name_id = common_name.taxon_name_id)">
		<cfset basJoin = " #basJoin# left outer JOIN common_name relcommon_name ON (relatedtaxonomy.taxon_name_id = relcommon_name.taxon_name_id)">
		<cfset basJoin = " #basJoin# left outer JOIN common_name invcommon_name ON (invrelatedtaxonomy.taxon_name_id = invcommon_name.taxon_name_id)">
		
		
		
		
		<cfset basQual = " #basQual# AND (
			upper(common_name.common_name) LIKE '%#ucase(taxon_term)#%' OR
			upper(relcommon_name.common_name) LIKE '%#ucase(taxon_term)#%' OR
			upper(invcommon_name.common_name) LIKE '%#ucase(taxon_term)#%' OR
			upper(taxon_term_aggregate.terms) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(taxon_term_aggregate.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(relatedtaxonomy.terms) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(relatedtaxonomy.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(invrelatedtaxonomy.terms) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(invrelatedtaxonomy.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%' OR
			upper(identification.scientific_name) LIKE '%#ucase(escapeQuotes(taxon_term))#%'
		)">
	<cfelse>
		not sure what to do with taxon_scope....<cfabort>
	</cfif>
	
	----------->
	------------->
</cfif>
<cfif isdefined("ImgNoConfirm") and len(ImgNoConfirm) gt 0>
	<cfset mapurl = "#mapurl#&ImgNoConfirm=#ImgNoConfirm#">
   	<cfset basQual = "#basQual#  AND #session.flatTableName#.collection_object_id not in (select
		collection_object_id from attributes where attribute_type='image confirmed' and attribute_value='yes')" >
</cfif>
<cfif isdefined("catnum") and len(trim(catnum)) gt 0>
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
		<cfset catnum=replace(catnum,' ',',','all')>
		<cfset catnum=replace(catnum,';',',','all')>
		<cfset basQual = " #basQual# AND #session.flatTableName#.cat_num IN ( #ListQualify(catnum,'''')# ) " >
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
	</cfif>
    <cfif media_type is not "any">
        <cfset basJoin = " #basJoin# INNER JOIN media ci_media ON (ci_media_relations.media_id = ci_media.media_id)">
        <cfset basQual = "#basQual#  AND ci_media.media_type = '#media_type#' and ci_media_relations.media_relationship='shows cataloged_item'">
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
	<cfset basQual = "#basQual#  AND upper(#session.flatTableName#.guid)  IN (#ucase(listqualify(ListChangeDelims(guid,','),chr(39)))#) ">
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
			INNER JOIN agent_name srchColl ON (collector.agent_id = srchColl.agent_id)">
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
	<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 AND upper(identification.identification_remarks) like '%#ucase(identification_remarks)#%'">
</cfif>

<cfif isdefined("taxa_formula") AND len(taxa_formula) gt 0>
	<cfset mapurl = "#mapurl#&taxa_formula=#taxa_formula#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 AND identification.taxa_formula = '#taxa_formula#'">
</cfif>
<cfif isdefined("nature_of_id") AND len(nature_of_id) gt 0>
	<cfset mapurl = "#mapurl#&nature_of_id=#nature_of_id#">
	<cfif basJoin does not contain " identification ">
		<cfset basJoin = " #basJoin# INNER JOIN identification ON (#session.flatTableName#.collection_object_id = identification.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND identification.accepted_id_fg=1 AND identification.nature_of_id = '#nature_of_id#'">
</cfif>
<cfif isdefined("identified_agent") AND len(identified_agent) gt 0>
	<cfset mapurl = "#mapurl#&identified_agent=#identified_agent#">
	<cfset basQual = " #basQual# AND upper(#session.flatTableName#.IDENTIFIEDBY) LIKE '%#ucase(identified_agent)#%'">
</cfif>
<cfif isdefined("begDate") AND len(begDate) gt 0>
	<cfset mapurl = "#mapurl#&begDate=#begDate#">
	<cfquery name="isdate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select is_iso8601('#begDate#') isdate from dual
	</cfquery>
	<cfif isdate.isdate is not "valid">
		<div class="error">
			The begin date you entered is not a valid ISO8601 date.
			See <a target="_blank" href="http://arctosdb.org/documentation/dates/">About Arctos Dates</a>
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset basQual = " #basQual# AND #session.flatTableName#.began_date >= '#begDate#'">
</cfif>
<cfif isdefined("endDate") AND len(endDate) gt 0>
	<cfset mapurl = "#mapurl#&endDate=#endDate#">
	<cfquery name="isdate" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select is_iso8601('#endDate#') isdate from dual
	</cfquery>
	<cfif isdate.isdate is not "valid">
		<div class="error">
			The ended date you entered is not a valid ISO8601 date.
			See <a target="_blank" href="http://arctosdb.org/documentation/dates/">About Arctos Dates</a>
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
	<cfset basQual = " #basQual# AND #session.flatTableName#.ended_date <= '#endDate#'">
</cfif>
<cfif isdefined("begYear") AND len(begYear) gt 0>
	<cfif not isYear(begYear)>
		<div class="error">
			Begin year must be a 4-digit number.
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
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
	<cfif not isYear(begYear)>
		<div class="error">
			End year must be a 4-digit number.
		</div>
		<script>hidePageLoad();</script>
		<cfabort>
	</cfif>
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
	<cfset mapurl = "#mapurl#&accn_inst=#accn_inst#">
	<cfif basJoin does not contain " accn ">
		<cfset basJoin = " #basJoin# INNER JOIN accn ON (#session.flatTableName#.accn_id = accn.transaction_id)">
	</cfif>
	<cfif basJoin does not contain " trans ">
		<cfset basJoin = " #basJoin# INNER JOIN trans ON (accn.transaction_id=trans.transaction_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(trans.institution_acronym) like '%#ucase(accn_inst)#%'">
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
	<cfif basJoin does not contain " specimen_part ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id=specimen_part.derived_from_cat_item) ">
	</cfif>
	<cfif basJoin does not contain " loan_item ">
		<cfset basJoin = " #basJoin# INNER JOIN loan_item ON (specimen_part.collection_object_id=loan_item.collection_object_id) ">
	</cfif>
	<cfif basJoin does not contain " loan ">
		<cfset basJoin = " #basJoin# INNER JOIN loan ON (loan_item.transaction_id=loan.transaction_id) ">
	</cfif>
	<cfif left(loan_number,1) is '='>
		<cfset basQual = " #basQual# AND upper(loan.loan_number) = '#ucase(right(loan_number,len(loan_number)-1))#'">
	<cfelseif loan_number is "*">
		<!-- don't do anything, just make the join --->
	<cfelse>
		<cfset basQual = " #basQual# AND upper(loan.loan_number) LIKE '%#ucase(loan_number)#%'">
	</cfif>
</cfif>
<cfif isdefined("accn_agency") and len(accn_agency) gt 0>
	<cfset mapurl = "#mapurl#&accn_agency=#accn_agency#">
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
	<cfset mapurl = "#mapurl#&CustomIdentifierValue=#CustomIdentifierValue#">
	<cfset mapurl = "#mapurl#&CustomOidOper=#CustomOidOper#">
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
	<cfset mapurl = "#mapurl#&OIDType=#OIDType#">
	<cfif basJoin does not contain " otherIdSearch ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdSearch ON (#session.flatTableName#.collection_object_id = otherIdSearch.collection_object_id)">
	</cfif>
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
	<cfset mapurl = "#mapurl#&related_term_1=#related_term_1#">
	<cfif basJoin does not contain " otherIdRefSearch ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdRefSearch ON (#session.flatTableName#.collection_object_id = otherIdRefSearch.collection_object_id)">
	</cfif>
	<cfif basJoin does not contain " otherIdRefRelTerms1 ">
		<cfset basJoin = " #basJoin# INNER JOIN cf_relations_cache otherIdRefRelTerms1 ON (otherIdRefSearch.COLL_OBJ_OTHER_ID_NUM_ID = otherIdRefRelTerms1.COLL_OBJ_OTHER_ID_NUM_ID)">
	</cfif>
	<cfset basQual = " #basQual# and otherIdRefSearch.id_references != 'self' AND otherIdRefRelTerms1.term='#related_term_1#'">
</cfif>
<cfif isdefined("RelatedOIDType") AND len(RelatedOIDType) gt 0>
	<cfset mapurl = "#mapurl#&RelatedOIDType=#RelatedOIDType#">
	<cfif basJoin does not contain " otherIdRefSearch ">
		<cfset basJoin = " #basJoin# INNER JOIN coll_obj_other_id_num otherIdRefSearch ON (#session.flatTableName#.collection_object_id = otherIdRefSearch.collection_object_id)">
	</cfif>
	<cfset basQual = "  #basQual# and otherIdRefSearch.id_references != 'self' AND otherIdRefSearch.other_id_type='#RelatedOIDType#'">
</cfif>
<cfif isdefined("related_term_val_1") AND len(related_term_val_1) gt 0>
	<cfset mapurl = "#mapurl#&related_term_val_1=#related_term_val_1#">
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
	<cfset mapurl = "#mapurl#&OIDNum=#OIDNum#">
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
	
			<cfdump var=#OIDNum#>

	
		<cfset oidList=replace(OIDNum,' ',',','all')>
		<cfset oidList=replace(oidList,';',',','all')>
		<cfset oidList=replace(oidList,chr(10),',','all')>
		<cfset oidList=replace(oidList,chr(13),',','all')>
		
		<cfset oidList=replace(oidList,",,",',','all')>
		
		<cfdump var=#oidList#>
		
		<cfset basQual = " #basQual# AND upper(otherIdSearch.display_value) IN ( #ListQualify(oidList,'''')# ) " >
		
		
		
		<!----
		<cfset oidList="">
		<cfloop list="#OIDNum#" delimiters="," index="i">
			<cfif len(oidList) is 0>
				<cfset oidList = "AND ( upper(otherIdSearch.display_value) = '#ucase(i)#'">
			<cfelse>
				<cfset oidList = "#oidList# OR upper(otherIdSearch.display_value) = '#ucase(i)#'">
			</cfif>
		</cfloop>
		<cfset oidList = "#oidList# )">
		<cfset basQual = " #basQual# #oidList#">
		
		---->
		
		
		
	
	</cfif>
	<cfif session.flatTableName is not "flat">
		<cfset basQual = " #basQual# AND (#session.flatTableName#.encumbrances is null or #session.flatTableName#.encumbrances not like '%mask original field number%') ">
	</cfif>
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
		<cfset basQual = " #basQual# AND sea = '#sea#'">
	</cfif>
	<cfset mapurl = "#mapurl#&sea=#sea#">
</cfif>
<cfif isdefined("Country") AND len(Country) gt 0>
	<cfif compare(country,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.country is null">
	<cfelse>
		<cfset basQual = " #basQual# AND #session.flatTableName#.country = '#Country#'">
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
				 <cfset basQual = " #basQual# UPPER(#session.flatTableName#.state_prov) LIKE '%#UCASE(trim(escapeQuotes(s)))#%'">
				 <cfset i=i+1>
			</cfloop>
		<cfset basQual = " #basQual# ) ">
	<cfelse>
		<cfset basQual = " #basQual# AND UPPER(#session.flatTableName#.state_prov) LIKE '%#UCASE(escapeQuotes(state_prov))#%'">
	</cfif>
	<cfset mapurl = "#mapurl#&state_prov=#state_prov#">
</cfif>
<cfif isdefined("island_group") AND len(island_group) gt 0>
	<cfif compare(island_group,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.island_group is null">
	<cfelse>
		<cfset basQual = " #basQual# AND #session.flatTableName#.Island_Group LIKE '#island_group#'">
	</cfif>
	<cfset mapurl = "#mapurl#&island_group=#island_group#">
</cfif>
<cfif isdefined("Island") AND len(Island) gt 0>
	<cfif compare(Island,"NULL") is 0>
		<cfset basQual = " #basQual# AND #session.flatTableName#.Island is null">
	<cfelse>
		<cfset basQual = " #basQual# AND UPPER(#session.flatTableName#.Island) LIKE '%#UCASE(Island)#%'">
	</cfif>
	<cfset mapurl = "#mapurl#&island=#island#">
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
<cfif isdefined("locality_remarks") and len(locality_remarks) gt 0>
	<cfset mapurl = "#mapurl#&locality_remarks=#locality_remarks#">
	<cfif basJoin does not contain " locality ">
		<cfset basJoin = " #basJoin# INNER JOIN locality ON (#session.flatTableName#.locality_id = locality.locality_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(locality.locality_remarks) like '%#ucase(escapeQuotes(locality_remarks))#%'">
</cfif>
<cfif isdefined("habitat") and len(habitat) gt 0>
	<cfset mapurl = "#mapurl#&habitat=#habitat#">
	<cfset basQual = " #basQual# AND upper(#session.flatTableName#.habitat) like '%#ucase(escapeQuotes(habitat))#%'">
</cfif>
<cfif isdefined("verbatim_locality") and len(verbatim_locality) gt 0>
	<cfset mapurl = "#mapurl#&verbatim_locality=#verbatim_locality#">
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
	<cfset mapurl = "#mapurl#&feature=#feature#">
</cfif>
<cfif isdefined("any_geog") AND len(any_geog) gt 0>
	<cfset mapurl = "#mapurl#&any_geog=#any_geog#">
	<cfif basJoin does not contain " locality ">
		<cfset basJoin = " #basJoin# INNER JOIN locality ON (#session.flatTableName#.locality_id = locality.locality_id)">
	</cfif>
	<cfset basQual = " #basQual# AND
		upper(#session.flatTableName#.higher_geog) || ' ' || upper(#session.flatTableName#.spec_locality)
			|| ' ' || upper(#session.flatTableName#.verbatim_locality) || ' ' || upper(locality.S$GEOGRAPHY)  LIKE '%#ucase(escapeQuotes(any_geog))#%'">
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
<cfif isdefined("part_attribute") AND len(part_attribute) gt 0>
	<cfset mapurl = "#mapurl#&part_attribute=#part_attribute#">
	<cfif basJoin does not contain " specimen_part ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfif basJoin does not contain " specimen_part_attribute ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part_attribute ON (specimen_part.collection_object_id = specimen_part_attribute.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND specimen_part_attribute.attribute_type = '#part_attribute#'">
</cfif>
<cfif isdefined("part_attribute_value") AND len(part_attribute_value) gt 0>
	<cfset mapurl = "#mapurl#&part_attribute_value=#part_attribute_value#">
	<cfif basJoin does not contain " specimen_part ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfif basJoin does not contain " specimen_part_attribute ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part_attribute ON (specimen_part.collection_object_id = specimen_part_attribute.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND upper(specimen_part_attribute.attribute_value) like '%#ucase(escapeQuotes(part_attribute_value))#%'">
</cfif>

<cfif isdefined("part_remark") AND len(part_remark) gt 0>
	<cfset mapurl = "#mapurl#&part_remark=#part_remark#">
	<cfif basJoin does not contain " specimen_part ">
		<cfset basJoin = " #basJoin# INNER JOIN specimen_part ON (#session.flatTableName#.collection_object_id = specimen_part.derived_from_cat_item)">
	</cfif>
	<cfset basJoin = " #basJoin# INNER JOIN coll_object_remark ON (specimen_part.collection_object_id = coll_object_remark.collection_object_id)">
	<cfset basQual = " #basQual# AND upper(coll_object_remark.coll_object_remarks) like '%#ucase(part_remark)#%'">
</cfif>
<cfif isdefined("part_name") AND len(part_name) gt 0>
	<cfset mapurl = "#mapurl#&part_name=#part_name#">
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
		<cfset basQual = " #basQual# AND upper(PARTS) LIKE '%#ucase(part_name)#%'">
	</cfif>
</cfif>
<cfif isdefined("is_tissue") AND is_tissue is 1>
	<cfset mapurl = "#mapurl#&is_tissue=#is_tissue#">
	<cfset basJoin = " #basJoin# INNER JOIN specimen_part spt ON (#session.flatTableName#.collection_object_id = spt.derived_from_cat_item)
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
<cfif isdefined("part_condition") AND len(part_condition) gt 0>
	<cfset basJoin = " #basJoin#
			INNER JOIN specimen_part spdisp ON (#session.flatTableName#.collection_object_id = spdisp.derived_from_cat_item)
			inner join coll_object partCollObj on (spdisp.collection_object_id=partCollObj.collection_object_id)">
	<cfset basQual = " #basQual# AND upper(partCollObj.condition) like '%#ucase(part_condition)#%'">
	<cfset mapurl = "#mapurl#&part_condition=#part_condition#">
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
	<cfset basQual = " #basQual# AND identification.accepted_id_fg = 1 AND UPPER(common_name.Common_Name) LIKE '%#ucase(stripQuotes(Common_Name))#%'">
	<cfset mapurl = "#mapurl#&Common_Name=#Common_Name#">
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
	<cfset mapurl = "#mapurl#&publication_title=#publication_title#">
</cfif>

<cfif isdefined("publication_id") AND len(publication_id) gt 0>
	<cfif basJoin does not contain " citation ">
		<cfset basJoin = " #basJoin# INNER JOIN citation ON (#session.flatTableName#.collection_object_id = citation.collection_object_id)">
	</cfif>
	<cfset basQual = " #basQual# AND publication_id = #publication_id#">
	<cfset mapurl = "#mapurl#&publication_id=#publication_id#">
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
	<cfset mapurl = "#mapurl#&project_sponsor=#project_sponsor#">
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
	<cfset mapurl = "#mapurl#&loan_project_name=#loan_project_name#">
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
			project_trans.project_id = #loan_project_id#
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
			project_trans.project_id = #loan_project_id#)">
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
	<cfset mapurl = "#mapurl#&project_name=#project_name#">
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
	<cfset mapurl = "#mapurl#&permit_issued_by=#permit_issued_by#">
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
	<cfset mapurl = "#mapurl#&permit_issued_to=#permit_issued_to#">
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
	<cfset mapurl = "#mapurl#&remark=#remark#">
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
<cfif isdefined("attribute_type_1") AND len(attribute_type_1) gt 0>
	<cfset mapurl = "#mapurl#&attribute_type_1=#attribute_type_1#">
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
	<cfset mapurl = "#mapurl#&attribute_type_2=#attribute_type_2#">
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



<!----------------- 
	autogenerated attribute handlers - run code at /Admin/buildAttributeSearchByNameCode.cfm to refresh this
	DO NOT MANUALLY MODIFY THIS CODE!!
------------------->


<cfset attrunits="M,METERS,METER,FT,FEET,FOOT,KM,KILOMETER,KILOMETERS,MM,MILLIMETER,MILLIMETERS,CM,CENTIMETER,CENTIMETERS,MI,MILE,MILES,YD,YARD,YARDS,FM,FATHOM,FATHOMS"><cfset charattrschops="=,!"><cfset numattrschops="=,!,<,>">
<cfif isdefined("SNV_results")>
    <cfset mapurl = "#mapurl#&SNV_results=#SNV_results#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_SNV_results ON (#session.flatTableName#.collection_object_id = t_SNV_results.collection_object_id)">
    <cfset basQual = " #basQual# AND t_SNV_results.attribute_type = 'SNV results'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_SNV_results.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(SNV_results) gt 0>
        <cfset oper=left(SNV_results,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(SNV_results,len(SNV_results)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(SNV_results)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_SNV_results.attribute_value,t_SNV_results.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_SNV_results.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_SNV_results.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("abundance")>
    <cfset mapurl = "#mapurl#&abundance=#abundance#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_abundance ON (#session.flatTableName#.collection_object_id = t_abundance.collection_object_id)">
    <cfset basQual = " #basQual# AND t_abundance.attribute_type = 'abundance'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_abundance.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(abundance) gt 0>
        <cfset oper=left(abundance,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(abundance,len(abundance)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(abundance)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_abundance.attribute_value,t_abundance.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_abundance.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_abundance.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("age")>
    <cfset mapurl = "#mapurl#&age=#age#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_age ON (#session.flatTableName#.collection_object_id = t_age.collection_object_id)">
    <cfset basQual = " #basQual# AND t_age.attribute_type = 'age'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_age.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(age) gt 0>
        <cfset oper=left(age,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(age,len(age)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(age)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_age.attribute_value,t_age.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_age.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_age.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("age_class")>
    <cfset mapurl = "#mapurl#&age_class=#age_class#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_age_class ON (#session.flatTableName#.collection_object_id = t_age_class.collection_object_id)">
    <cfset basQual = " #basQual# AND t_age_class.attribute_type = 'age class'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_age_class.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(age_class) gt 0>
        <cfset oper=left(age_class,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(age_class,len(age_class)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(age_class)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_age_class.attribute_value,t_age_class.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_age_class.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_age_class.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("appraised_value")>
    <cfset mapurl = "#mapurl#&appraised_value=#appraised_value#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_appraised_value ON (#session.flatTableName#.collection_object_id = t_appraised_value.collection_object_id)">
    <cfset basQual = " #basQual# AND t_appraised_value.attribute_type = 'appraised value'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_appraised_value.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(appraised_value) gt 0>
        <cfset oper=left(appraised_value,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(appraised_value,len(appraised_value)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(appraised_value)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_appraised_value.attribute_value,t_appraised_value.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_appraised_value.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_appraised_value.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("axillary_girth")>
    <cfset mapurl = "#mapurl#&axillary_girth=#axillary_girth#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_axillary_girth ON (#session.flatTableName#.collection_object_id = t_axillary_girth.collection_object_id)">
    <cfset basQual = " #basQual# AND t_axillary_girth.attribute_type = 'axillary girth'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_axillary_girth.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(axillary_girth) gt 0>
        <cfset oper=left(axillary_girth,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(axillary_girth,len(axillary_girth)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(axillary_girth)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_axillary_girth.attribute_value,t_axillary_girth.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_axillary_girth.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_axillary_girth.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("body_condition")>
    <cfset mapurl = "#mapurl#&body_condition=#body_condition#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_body_condition ON (#session.flatTableName#.collection_object_id = t_body_condition.collection_object_id)">
    <cfset basQual = " #basQual# AND t_body_condition.attribute_type = 'body condition'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_body_condition.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(body_condition) gt 0>
        <cfset oper=left(body_condition,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(body_condition,len(body_condition)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(body_condition)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_body_condition.attribute_value,t_body_condition.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_body_condition.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_body_condition.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("body_width")>
    <cfset mapurl = "#mapurl#&body_width=#body_width#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_body_width ON (#session.flatTableName#.collection_object_id = t_body_width.collection_object_id)">
    <cfset basQual = " #basQual# AND t_body_width.attribute_type = 'body width'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_body_width.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(body_width) gt 0>
        <cfset oper=left(body_width,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(body_width,len(body_width)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(body_width)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_body_width.attribute_value,t_body_width.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_body_width.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_body_width.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("breadth")>
    <cfset mapurl = "#mapurl#&breadth=#breadth#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_breadth ON (#session.flatTableName#.collection_object_id = t_breadth.collection_object_id)">
    <cfset basQual = " #basQual# AND t_breadth.attribute_type = 'breadth'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_breadth.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(breadth) gt 0>
        <cfset oper=left(breadth,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(breadth,len(breadth)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(breadth)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_breadth.attribute_value,t_breadth.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_breadth.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_breadth.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("bursa")>
    <cfset mapurl = "#mapurl#&bursa=#bursa#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_bursa ON (#session.flatTableName#.collection_object_id = t_bursa.collection_object_id)">
    <cfset basQual = " #basQual# AND t_bursa.attribute_type = 'bursa'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_bursa.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(bursa) gt 0>
        <cfset oper=left(bursa,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(bursa,len(bursa)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(bursa)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_bursa.attribute_value,t_bursa.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_bursa.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_bursa.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("bursa_length")>
    <cfset mapurl = "#mapurl#&bursa_length=#bursa_length#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_bursa_length ON (#session.flatTableName#.collection_object_id = t_bursa_length.collection_object_id)">
    <cfset basQual = " #basQual# AND t_bursa_length.attribute_type = 'bursa length'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_bursa_length.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(bursa_length) gt 0>
        <cfset oper=left(bursa_length,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(bursa_length,len(bursa_length)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(bursa_length)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_bursa_length.attribute_value,t_bursa_length.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_bursa_length.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_bursa_length.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("carapace_length")>
    <cfset mapurl = "#mapurl#&carapace_length=#carapace_length#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_carapace_length ON (#session.flatTableName#.collection_object_id = t_carapace_length.collection_object_id)">
    <cfset basQual = " #basQual# AND t_carapace_length.attribute_type = 'carapace length'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_carapace_length.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(carapace_length) gt 0>
        <cfset oper=left(carapace_length,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(carapace_length,len(carapace_length)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(carapace_length)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_carapace_length.attribute_value,t_carapace_length.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_carapace_length.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_carapace_length.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("caste")>
    <cfset mapurl = "#mapurl#&caste=#caste#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_caste ON (#session.flatTableName#.collection_object_id = t_caste.collection_object_id)">
    <cfset basQual = " #basQual# AND t_caste.attribute_type = 'caste'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_caste.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(caste) gt 0>
        <cfset oper=left(caste,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(caste,len(caste)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(caste)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_caste.attribute_value,t_caste.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_caste.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_caste.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("clutch_size")>
    <cfset mapurl = "#mapurl#&clutch_size=#clutch_size#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_clutch_size ON (#session.flatTableName#.collection_object_id = t_clutch_size.collection_object_id)">
    <cfset basQual = " #basQual# AND t_clutch_size.attribute_type = 'clutch size'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_clutch_size.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(clutch_size) gt 0>
        <cfset oper=left(clutch_size,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(clutch_size,len(clutch_size)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(clutch_size)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_clutch_size.attribute_value,t_clutch_size.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_clutch_size.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_clutch_size.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("clutch_size_of_nest_parasite")>
    <cfset mapurl = "#mapurl#&clutch_size_of_nest_parasite=#clutch_size_of_nest_parasite#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_clutch_size_of_nest_parasite ON (#session.flatTableName#.collection_object_id = t_clutch_size_of_nest_parasite.collection_object_id)">
    <cfset basQual = " #basQual# AND t_clutch_size_of_nest_parasite.attribute_type = 'clutch size of nest parasite'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_clutch_size_of_nest_parasite.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(clutch_size_of_nest_parasite) gt 0>
        <cfset oper=left(clutch_size_of_nest_parasite,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(clutch_size_of_nest_parasite,len(clutch_size_of_nest_parasite)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(clutch_size_of_nest_parasite)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_clutch_size_of_nest_parasite.attribute_value,t_clutch_size_of_nest_parasite.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_clutch_size_of_nest_parasite.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_clutch_size_of_nest_parasite.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("colors")>
    <cfset mapurl = "#mapurl#&colors=#colors#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_colors ON (#session.flatTableName#.collection_object_id = t_colors.collection_object_id)">
    <cfset basQual = " #basQual# AND t_colors.attribute_type = 'colors'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_colors.is_encumbered = 0">
    </cfif>
    <cfset schunits="">
    <cfif len(colors) gt 0>
        <cfset oper=left(colors,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(colors,len(colors)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(colors)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_colors.attribute_value,t_colors.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_colors.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_colors.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("crown_rump_length")>
    <cfset mapurl = "#mapurl#&crown_rump_length=#crown_rump_length#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_crown_rump_length ON (#session.flatTableName#.collection_object_id = t_crown_rump_length.collection_object_id)">
    <cfset basQual = " #basQual# AND t_crown_rump_length.attribute_type = 'crown-rump length'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_crown_rump_length.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(crown_rump_length) gt 0>
        <cfset oper=left(crown_rump_length,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(crown_rump_length,len(crown_rump_length)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(crown_rump_length)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_crown_rump_length.attribute_value,t_crown_rump_length.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_crown_rump_length.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_crown_rump_length.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("curvilinear_length")>
    <cfset mapurl = "#mapurl#&curvilinear_length=#curvilinear_length#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_curvilinear_length ON (#session.flatTableName#.collection_object_id = t_curvilinear_length.collection_object_id)">
    <cfset basQual = " #basQual# AND t_curvilinear_length.attribute_type = 'curvilinear length'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_curvilinear_length.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(curvilinear_length) gt 0>
        <cfset oper=left(curvilinear_length,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(curvilinear_length,len(curvilinear_length)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(curvilinear_length)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_curvilinear_length.attribute_value,t_curvilinear_length.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_curvilinear_length.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_curvilinear_length.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("depth")>
    <cfset mapurl = "#mapurl#&depth=#depth#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_depth ON (#session.flatTableName#.collection_object_id = t_depth.collection_object_id)">
    <cfset basQual = " #basQual# AND t_depth.attribute_type = 'depth'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_depth.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(depth) gt 0>
        <cfset oper=left(depth,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(depth,len(depth)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(depth)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_depth.attribute_value,t_depth.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_depth.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_depth.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("description")>
    <cfset mapurl = "#mapurl#&description=#description#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_description ON (#session.flatTableName#.collection_object_id = t_description.collection_object_id)">
    <cfset basQual = " #basQual# AND t_description.attribute_type = 'description'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_description.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(description) gt 0>
        <cfset oper=left(description,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(description,len(description)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(description)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_description.attribute_value,t_description.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_description.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_description.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("diploid_number")>
    <cfset mapurl = "#mapurl#&diploid_number=#diploid_number#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_diploid_number ON (#session.flatTableName#.collection_object_id = t_diploid_number.collection_object_id)">
    <cfset basQual = " #basQual# AND t_diploid_number.attribute_type = 'diploid number'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_diploid_number.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(diploid_number) gt 0>
        <cfset oper=left(diploid_number,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(diploid_number,len(diploid_number)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(diploid_number)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_diploid_number.attribute_value,t_diploid_number.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_diploid_number.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_diploid_number.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("ear_from_crown")>
    <cfset mapurl = "#mapurl#&ear_from_crown=#ear_from_crown#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_ear_from_crown ON (#session.flatTableName#.collection_object_id = t_ear_from_crown.collection_object_id)">
    <cfset basQual = " #basQual# AND t_ear_from_crown.attribute_type = 'ear from crown'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_ear_from_crown.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(ear_from_crown) gt 0>
        <cfset oper=left(ear_from_crown,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(ear_from_crown,len(ear_from_crown)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(ear_from_crown)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_ear_from_crown.attribute_value,t_ear_from_crown.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_ear_from_crown.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_ear_from_crown.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("ear_from_notch")>
    <cfset mapurl = "#mapurl#&ear_from_notch=#ear_from_notch#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_ear_from_notch ON (#session.flatTableName#.collection_object_id = t_ear_from_notch.collection_object_id)">
    <cfset basQual = " #basQual# AND t_ear_from_notch.attribute_type = 'ear from notch'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_ear_from_notch.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(ear_from_notch) gt 0>
        <cfset oper=left(ear_from_notch,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(ear_from_notch,len(ear_from_notch)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(ear_from_notch)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_ear_from_notch.attribute_value,t_ear_from_notch.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_ear_from_notch.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_ear_from_notch.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("egg_content_weight")>
    <cfset mapurl = "#mapurl#&egg_content_weight=#egg_content_weight#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_egg_content_weight ON (#session.flatTableName#.collection_object_id = t_egg_content_weight.collection_object_id)">
    <cfset basQual = " #basQual# AND t_egg_content_weight.attribute_type = 'egg content weight'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_egg_content_weight.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(egg_content_weight) gt 0>
        <cfset oper=left(egg_content_weight,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(egg_content_weight,len(egg_content_weight)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(egg_content_weight)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_egg_content_weight.attribute_value,t_egg_content_weight.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_egg_content_weight.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_egg_content_weight.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("eggshell_thickness")>
    <cfset mapurl = "#mapurl#&eggshell_thickness=#eggshell_thickness#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_eggshell_thickness ON (#session.flatTableName#.collection_object_id = t_eggshell_thickness.collection_object_id)">
    <cfset basQual = " #basQual# AND t_eggshell_thickness.attribute_type = 'eggshell thickness'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_eggshell_thickness.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(eggshell_thickness) gt 0>
        <cfset oper=left(eggshell_thickness,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(eggshell_thickness,len(eggshell_thickness)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(eggshell_thickness)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_eggshell_thickness.attribute_value,t_eggshell_thickness.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_eggshell_thickness.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_eggshell_thickness.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("embryo_weight")>
    <cfset mapurl = "#mapurl#&embryo_weight=#embryo_weight#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_embryo_weight ON (#session.flatTableName#.collection_object_id = t_embryo_weight.collection_object_id)">
    <cfset basQual = " #basQual# AND t_embryo_weight.attribute_type = 'embryo weight'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_embryo_weight.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(embryo_weight) gt 0>
        <cfset oper=left(embryo_weight,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(embryo_weight,len(embryo_weight)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(embryo_weight)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_embryo_weight.attribute_value,t_embryo_weight.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_embryo_weight.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_embryo_weight.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("experimental_infection")>
    <cfset mapurl = "#mapurl#&experimental_infection=#experimental_infection#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_experimental_infection ON (#session.flatTableName#.collection_object_id = t_experimental_infection.collection_object_id)">
    <cfset basQual = " #basQual# AND t_experimental_infection.attribute_type = 'experimental infection'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_experimental_infection.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(experimental_infection) gt 0>
        <cfset oper=left(experimental_infection,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(experimental_infection,len(experimental_infection)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(experimental_infection)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_experimental_infection.attribute_value,t_experimental_infection.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_experimental_infection.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_experimental_infection.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("extension")>
    <cfset mapurl = "#mapurl#&extension=#extension#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_extension ON (#session.flatTableName#.collection_object_id = t_extension.collection_object_id)">
    <cfset basQual = " #basQual# AND t_extension.attribute_type = 'extension'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_extension.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(extension) gt 0>
        <cfset oper=left(extension,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(extension,len(extension)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(extension)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_extension.attribute_value,t_extension.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_extension.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_extension.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("fat_deposition")>
    <cfset mapurl = "#mapurl#&fat_deposition=#fat_deposition#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_fat_deposition ON (#session.flatTableName#.collection_object_id = t_fat_deposition.collection_object_id)">
    <cfset basQual = " #basQual# AND t_fat_deposition.attribute_type = 'fat deposition'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_fat_deposition.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(fat_deposition) gt 0>
        <cfset oper=left(fat_deposition,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(fat_deposition,len(fat_deposition)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(fat_deposition)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_fat_deposition.attribute_value,t_fat_deposition.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_fat_deposition.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_fat_deposition.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("forearm_length")>
    <cfset mapurl = "#mapurl#&forearm_length=#forearm_length#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_forearm_length ON (#session.flatTableName#.collection_object_id = t_forearm_length.collection_object_id)">
    <cfset basQual = " #basQual# AND t_forearm_length.attribute_type = 'forearm length'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_forearm_length.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(forearm_length) gt 0>
        <cfset oper=left(forearm_length,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(forearm_length,len(forearm_length)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(forearm_length)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_forearm_length.attribute_value,t_forearm_length.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_forearm_length.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_forearm_length.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("gonad")>
    <cfset mapurl = "#mapurl#&gonad=#gonad#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_gonad ON (#session.flatTableName#.collection_object_id = t_gonad.collection_object_id)">
    <cfset basQual = " #basQual# AND t_gonad.attribute_type = 'gonad'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_gonad.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(gonad) gt 0>
        <cfset oper=left(gonad,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(gonad,len(gonad)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(gonad)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_gonad.attribute_value,t_gonad.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_gonad.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_gonad.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("head_length")>
    <cfset mapurl = "#mapurl#&head_length=#head_length#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_head_length ON (#session.flatTableName#.collection_object_id = t_head_length.collection_object_id)">
    <cfset basQual = " #basQual# AND t_head_length.attribute_type = 'head length'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_head_length.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(head_length) gt 0>
        <cfset oper=left(head_length,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(head_length,len(head_length)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(head_length)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_head_length.attribute_value,t_head_length.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_head_length.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_head_length.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("head_width")>
    <cfset mapurl = "#mapurl#&head_width=#head_width#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_head_width ON (#session.flatTableName#.collection_object_id = t_head_width.collection_object_id)">
    <cfset basQual = " #basQual# AND t_head_width.attribute_type = 'head width'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_head_width.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(head_width) gt 0>
        <cfset oper=left(head_width,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(head_width,len(head_width)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(head_width)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_head_width.attribute_value,t_head_width.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_head_width.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_head_width.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("height")>
    <cfset mapurl = "#mapurl#&height=#height#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_height ON (#session.flatTableName#.collection_object_id = t_height.collection_object_id)">
    <cfset basQual = " #basQual# AND t_height.attribute_type = 'height'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_height.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(height) gt 0>
        <cfset oper=left(height,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(height,len(height)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(height)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_height.attribute_value,t_height.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_height.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_height.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("hind_foot_with_claw")>
    <cfset mapurl = "#mapurl#&hind_foot_with_claw=#hind_foot_with_claw#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_hind_foot_with_claw ON (#session.flatTableName#.collection_object_id = t_hind_foot_with_claw.collection_object_id)">
    <cfset basQual = " #basQual# AND t_hind_foot_with_claw.attribute_type = 'hind foot with claw'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_hind_foot_with_claw.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(hind_foot_with_claw) gt 0>
        <cfset oper=left(hind_foot_with_claw,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(hind_foot_with_claw,len(hind_foot_with_claw)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(hind_foot_with_claw)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_hind_foot_with_claw.attribute_value,t_hind_foot_with_claw.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_hind_foot_with_claw.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_hind_foot_with_claw.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("hind_foot_without_claw")>
    <cfset mapurl = "#mapurl#&hind_foot_without_claw=#hind_foot_without_claw#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_hind_foot_without_claw ON (#session.flatTableName#.collection_object_id = t_hind_foot_without_claw.collection_object_id)">
    <cfset basQual = " #basQual# AND t_hind_foot_without_claw.attribute_type = 'hind foot without claw'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_hind_foot_without_claw.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(hind_foot_without_claw) gt 0>
        <cfset oper=left(hind_foot_without_claw,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(hind_foot_without_claw,len(hind_foot_without_claw)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(hind_foot_without_claw)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_hind_foot_without_claw.attribute_value,t_hind_foot_without_claw.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_hind_foot_without_claw.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_hind_foot_without_claw.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("image_confirmed")>
    <cfset mapurl = "#mapurl#&image_confirmed=#image_confirmed#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_image_confirmed ON (#session.flatTableName#.collection_object_id = t_image_confirmed.collection_object_id)">
    <cfset basQual = " #basQual# AND t_image_confirmed.attribute_type = 'image confirmed'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_image_confirmed.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(image_confirmed) gt 0>
        <cfset oper=left(image_confirmed,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(image_confirmed,len(image_confirmed)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(image_confirmed)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_image_confirmed.attribute_value,t_image_confirmed.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_image_confirmed.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_image_confirmed.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("incubation_stage")>
    <cfset mapurl = "#mapurl#&incubation_stage=#incubation_stage#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_incubation_stage ON (#session.flatTableName#.collection_object_id = t_incubation_stage.collection_object_id)">
    <cfset basQual = " #basQual# AND t_incubation_stage.attribute_type = 'incubation stage'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_incubation_stage.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(incubation_stage) gt 0>
        <cfset oper=left(incubation_stage,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(incubation_stage,len(incubation_stage)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(incubation_stage)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_incubation_stage.attribute_value,t_incubation_stage.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_incubation_stage.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_incubation_stage.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("location_in_host")>
    <cfset mapurl = "#mapurl#&location_in_host=#location_in_host#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_location_in_host ON (#session.flatTableName#.collection_object_id = t_location_in_host.collection_object_id)">
    <cfset basQual = " #basQual# AND t_location_in_host.attribute_type = 'location in host'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_location_in_host.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(location_in_host) gt 0>
        <cfset oper=left(location_in_host,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(location_in_host,len(location_in_host)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(location_in_host)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_location_in_host.attribute_value,t_location_in_host.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_location_in_host.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_location_in_host.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("molt_condition")>
    <cfset mapurl = "#mapurl#&molt_condition=#molt_condition#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_molt_condition ON (#session.flatTableName#.collection_object_id = t_molt_condition.collection_object_id)">
    <cfset basQual = " #basQual# AND t_molt_condition.attribute_type = 'molt condition'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_molt_condition.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(molt_condition) gt 0>
        <cfset oper=left(molt_condition,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(molt_condition,len(molt_condition)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(molt_condition)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_molt_condition.attribute_value,t_molt_condition.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_molt_condition.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_molt_condition.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("neck_width")>
    <cfset mapurl = "#mapurl#&neck_width=#neck_width#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_neck_width ON (#session.flatTableName#.collection_object_id = t_neck_width.collection_object_id)">
    <cfset basQual = " #basQual# AND t_neck_width.attribute_type = 'neck width'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_neck_width.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(neck_width) gt 0>
        <cfset oper=left(neck_width,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(neck_width,len(neck_width)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(neck_width)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_neck_width.attribute_value,t_neck_width.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_neck_width.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_neck_width.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("nest_description")>
    <cfset mapurl = "#mapurl#&nest_description=#nest_description#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_nest_description ON (#session.flatTableName#.collection_object_id = t_nest_description.collection_object_id)">
    <cfset basQual = " #basQual# AND t_nest_description.attribute_type = 'nest description'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_nest_description.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(nest_description) gt 0>
        <cfset oper=left(nest_description,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(nest_description,len(nest_description)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(nest_description)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_nest_description.attribute_value,t_nest_description.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_nest_description.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_nest_description.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("nest_phenology")>
    <cfset mapurl = "#mapurl#&nest_phenology=#nest_phenology#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_nest_phenology ON (#session.flatTableName#.collection_object_id = t_nest_phenology.collection_object_id)">
    <cfset basQual = " #basQual# AND t_nest_phenology.attribute_type = 'nest phenology'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_nest_phenology.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(nest_phenology) gt 0>
        <cfset oper=left(nest_phenology,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(nest_phenology,len(nest_phenology)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(nest_phenology)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_nest_phenology.attribute_value,t_nest_phenology.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_nest_phenology.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_nest_phenology.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("number_of_labels")>
    <cfset mapurl = "#mapurl#&number_of_labels=#number_of_labels#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_number_of_labels ON (#session.flatTableName#.collection_object_id = t_number_of_labels.collection_object_id)">
    <cfset basQual = " #basQual# AND t_number_of_labels.attribute_type = 'number of labels'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_number_of_labels.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(number_of_labels) gt 0>
        <cfset oper=left(number_of_labels,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(number_of_labels,len(number_of_labels)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(number_of_labels)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_number_of_labels.attribute_value,t_number_of_labels.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_number_of_labels.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_number_of_labels.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("numeric_age")>
    <cfset mapurl = "#mapurl#&numeric_age=#numeric_age#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_numeric_age ON (#session.flatTableName#.collection_object_id = t_numeric_age.collection_object_id)">
    <cfset basQual = " #basQual# AND t_numeric_age.attribute_type = 'numeric age'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_numeric_age.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(numeric_age) gt 0>
        <cfset oper=left(numeric_age,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(numeric_age,len(numeric_age)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(numeric_age)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_numeric_age.attribute_value,t_numeric_age.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_numeric_age.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_numeric_age.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("ovum")>
    <cfset mapurl = "#mapurl#&ovum=#ovum#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_ovum ON (#session.flatTableName#.collection_object_id = t_ovum.collection_object_id)">
    <cfset basQual = " #basQual# AND t_ovum.attribute_type = 'ovum'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_ovum.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(ovum) gt 0>
        <cfset oper=left(ovum,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(ovum,len(ovum)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(ovum)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_ovum.attribute_value,t_ovum.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_ovum.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_ovum.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("parasite_yes_no")>
    <cfset mapurl = "#mapurl#&parasite_yes_no=#parasite_yes_no#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_parasite_yes_no ON (#session.flatTableName#.collection_object_id = t_parasite_yes_no.collection_object_id)">
    <cfset basQual = " #basQual# AND t_parasite_yes_no.attribute_type = 'parasite yes/no'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_parasite_yes_no.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(parasite_yes_no) gt 0>
        <cfset oper=left(parasite_yes_no,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(parasite_yes_no,len(parasite_yes_no)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(parasite_yes_no)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_parasite_yes_no.attribute_value,t_parasite_yes_no.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_parasite_yes_no.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_parasite_yes_no.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("parasites_found")>
    <cfset mapurl = "#mapurl#&parasites_found=#parasites_found#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_parasites_found ON (#session.flatTableName#.collection_object_id = t_parasites_found.collection_object_id)">
    <cfset basQual = " #basQual# AND t_parasites_found.attribute_type = 'parasites found'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_parasites_found.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(parasites_found) gt 0>
        <cfset oper=left(parasites_found,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(parasites_found,len(parasites_found)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(parasites_found)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_parasites_found.attribute_value,t_parasites_found.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_parasites_found.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_parasites_found.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("purchase_value")>
    <cfset mapurl = "#mapurl#&purchase_value=#purchase_value#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_purchase_value ON (#session.flatTableName#.collection_object_id = t_purchase_value.collection_object_id)">
    <cfset basQual = " #basQual# AND t_purchase_value.attribute_type = 'purchase value'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_purchase_value.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(purchase_value) gt 0>
        <cfset oper=left(purchase_value,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(purchase_value,len(purchase_value)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(purchase_value)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_purchase_value.attribute_value,t_purchase_value.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_purchase_value.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_purchase_value.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("reproductive_data")>
    <cfset mapurl = "#mapurl#&reproductive_data=#reproductive_data#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_reproductive_data ON (#session.flatTableName#.collection_object_id = t_reproductive_data.collection_object_id)">
    <cfset basQual = " #basQual# AND t_reproductive_data.attribute_type = 'reproductive data'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_reproductive_data.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(reproductive_data) gt 0>
        <cfset oper=left(reproductive_data,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(reproductive_data,len(reproductive_data)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(reproductive_data)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_reproductive_data.attribute_value,t_reproductive_data.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_reproductive_data.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_reproductive_data.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("sex")>
    <cfset mapurl = "#mapurl#&sex=#sex#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_sex ON (#session.flatTableName#.collection_object_id = t_sex.collection_object_id)">
    <cfset basQual = " #basQual# AND t_sex.attribute_type = 'sex'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_sex.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(sex) gt 0>
        <cfset oper=left(sex,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(sex,len(sex)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(sex)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_sex.attribute_value,t_sex.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_sex.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_sex.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("skull_ossification")>
    <cfset mapurl = "#mapurl#&skull_ossification=#skull_ossification#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_skull_ossification ON (#session.flatTableName#.collection_object_id = t_skull_ossification.collection_object_id)">
    <cfset basQual = " #basQual# AND t_skull_ossification.attribute_type = 'skull ossification'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_skull_ossification.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(skull_ossification) gt 0>
        <cfset oper=left(skull_ossification,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(skull_ossification,len(skull_ossification)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(skull_ossification)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_skull_ossification.attribute_value,t_skull_ossification.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_skull_ossification.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_skull_ossification.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("snout_vent_length")>
    <cfset mapurl = "#mapurl#&snout_vent_length=#snout_vent_length#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_snout_vent_length ON (#session.flatTableName#.collection_object_id = t_snout_vent_length.collection_object_id)">
    <cfset basQual = " #basQual# AND t_snout_vent_length.attribute_type = 'snout-vent length'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_snout_vent_length.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(snout_vent_length) gt 0>
        <cfset oper=left(snout_vent_length,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(snout_vent_length,len(snout_vent_length)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(snout_vent_length)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_snout_vent_length.attribute_value,t_snout_vent_length.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_snout_vent_length.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_snout_vent_length.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("soft_part_color")>
    <cfset mapurl = "#mapurl#&soft_part_color=#soft_part_color#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_soft_part_color ON (#session.flatTableName#.collection_object_id = t_soft_part_color.collection_object_id)">
    <cfset basQual = " #basQual# AND t_soft_part_color.attribute_type = 'soft part color'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_soft_part_color.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(soft_part_color) gt 0>
        <cfset oper=left(soft_part_color,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(soft_part_color,len(soft_part_color)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(soft_part_color)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_soft_part_color.attribute_value,t_soft_part_color.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_soft_part_color.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_soft_part_color.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("soft_parts")>
    <cfset mapurl = "#mapurl#&soft_parts=#soft_parts#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_soft_parts ON (#session.flatTableName#.collection_object_id = t_soft_parts.collection_object_id)">
    <cfset basQual = " #basQual# AND t_soft_parts.attribute_type = 'soft parts'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_soft_parts.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(soft_parts) gt 0>
        <cfset oper=left(soft_parts,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(soft_parts,len(soft_parts)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(soft_parts)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_soft_parts.attribute_value,t_soft_parts.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_soft_parts.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_soft_parts.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("stomach_contents")>
    <cfset mapurl = "#mapurl#&stomach_contents=#stomach_contents#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_stomach_contents ON (#session.flatTableName#.collection_object_id = t_stomach_contents.collection_object_id)">
    <cfset basQual = " #basQual# AND t_stomach_contents.attribute_type = 'stomach contents'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_stomach_contents.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(stomach_contents) gt 0>
        <cfset oper=left(stomach_contents,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(stomach_contents,len(stomach_contents)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(stomach_contents)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_stomach_contents.attribute_value,t_stomach_contents.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_stomach_contents.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_stomach_contents.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("tail_base_width")>
    <cfset mapurl = "#mapurl#&tail_base_width=#tail_base_width#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_tail_base_width ON (#session.flatTableName#.collection_object_id = t_tail_base_width.collection_object_id)">
    <cfset basQual = " #basQual# AND t_tail_base_width.attribute_type = 'tail base width'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_tail_base_width.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(tail_base_width) gt 0>
        <cfset oper=left(tail_base_width,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(tail_base_width,len(tail_base_width)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(tail_base_width)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_tail_base_width.attribute_value,t_tail_base_width.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_tail_base_width.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_tail_base_width.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("tail_condition")>
    <cfset mapurl = "#mapurl#&tail_condition=#tail_condition#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_tail_condition ON (#session.flatTableName#.collection_object_id = t_tail_condition.collection_object_id)">
    <cfset basQual = " #basQual# AND t_tail_condition.attribute_type = 'tail condition'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_tail_condition.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(tail_condition) gt 0>
        <cfset oper=left(tail_condition,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(tail_condition,len(tail_condition)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(tail_condition)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_tail_condition.attribute_value,t_tail_condition.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_tail_condition.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_tail_condition.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("tail_length")>
    <cfset mapurl = "#mapurl#&tail_length=#tail_length#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_tail_length ON (#session.flatTableName#.collection_object_id = t_tail_length.collection_object_id)">
    <cfset basQual = " #basQual# AND t_tail_length.attribute_type = 'tail length'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_tail_length.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(tail_length) gt 0>
        <cfset oper=left(tail_length,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(tail_length,len(tail_length)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(tail_length)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_tail_length.attribute_value,t_tail_length.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_tail_length.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_tail_length.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("title")>
    <cfset mapurl = "#mapurl#&title=#title#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_title ON (#session.flatTableName#.collection_object_id = t_title.collection_object_id)">
    <cfset basQual = " #basQual# AND t_title.attribute_type = 'title'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_title.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(title) gt 0>
        <cfset oper=left(title,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(title,len(title)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(title)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_title.attribute_value,t_title.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_title.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_title.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("total_length")>
    <cfset mapurl = "#mapurl#&total_length=#total_length#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_total_length ON (#session.flatTableName#.collection_object_id = t_total_length.collection_object_id)">
    <cfset basQual = " #basQual# AND t_total_length.attribute_type = 'total length'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_total_length.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(total_length) gt 0>
        <cfset oper=left(total_length,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(total_length,len(total_length)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(total_length)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_total_length.attribute_value,t_total_length.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_total_length.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_total_length.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("tragus_length")>
    <cfset mapurl = "#mapurl#&tragus_length=#tragus_length#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_tragus_length ON (#session.flatTableName#.collection_object_id = t_tragus_length.collection_object_id)">
    <cfset basQual = " #basQual# AND t_tragus_length.attribute_type = 'tragus length'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_tragus_length.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(tragus_length) gt 0>
        <cfset oper=left(tragus_length,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(tragus_length,len(tragus_length)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(tragus_length)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_tragus_length.attribute_value,t_tragus_length.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_tragus_length.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_tragus_length.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("trap_identifier")>
    <cfset mapurl = "#mapurl#&trap_identifier=#trap_identifier#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_trap_identifier ON (#session.flatTableName#.collection_object_id = t_trap_identifier.collection_object_id)">
    <cfset basQual = " #basQual# AND t_trap_identifier.attribute_type = 'trap identifier'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_trap_identifier.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(trap_identifier) gt 0>
        <cfset oper=left(trap_identifier,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(trap_identifier,len(trap_identifier)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(trap_identifier)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_trap_identifier.attribute_value,t_trap_identifier.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_trap_identifier.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_trap_identifier.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("trap_type")>
    <cfset mapurl = "#mapurl#&trap_type=#trap_type#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_trap_type ON (#session.flatTableName#.collection_object_id = t_trap_type.collection_object_id)">
    <cfset basQual = " #basQual# AND t_trap_type.attribute_type = 'trap type'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_trap_type.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(trap_type) gt 0>
        <cfset oper=left(trap_type,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(trap_type,len(trap_type)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(trap_type)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_trap_type.attribute_value,t_trap_type.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_trap_type.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_trap_type.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("unformatted_measurements")>
    <cfset mapurl = "#mapurl#&unformatted_measurements=#unformatted_measurements#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_unformatted_measurements ON (#session.flatTableName#.collection_object_id = t_unformatted_measurements.collection_object_id)">
    <cfset basQual = " #basQual# AND t_unformatted_measurements.attribute_type = 'unformatted measurements'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_unformatted_measurements.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(unformatted_measurements) gt 0>
        <cfset oper=left(unformatted_measurements,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(unformatted_measurements,len(unformatted_measurements)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(unformatted_measurements)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_unformatted_measurements.attribute_value,t_unformatted_measurements.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_unformatted_measurements.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_unformatted_measurements.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("verbatim_host_ID")>
    <cfset mapurl = "#mapurl#&verbatim_host_ID=#verbatim_host_ID#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_verbatim_host_ID ON (#session.flatTableName#.collection_object_id = t_verbatim_host_ID.collection_object_id)">
    <cfset basQual = " #basQual# AND t_verbatim_host_ID.attribute_type = 'verbatim host ID'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_verbatim_host_ID.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(verbatim_host_ID) gt 0>
        <cfset oper=left(verbatim_host_ID,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(verbatim_host_ID,len(verbatim_host_ID)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(verbatim_host_ID)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_verbatim_host_ID.attribute_value,t_verbatim_host_ID.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_verbatim_host_ID.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_verbatim_host_ID.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("verbatim_host_age")>
    <cfset mapurl = "#mapurl#&verbatim_host_age=#verbatim_host_age#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_verbatim_host_age ON (#session.flatTableName#.collection_object_id = t_verbatim_host_age.collection_object_id)">
    <cfset basQual = " #basQual# AND t_verbatim_host_age.attribute_type = 'verbatim host age'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_verbatim_host_age.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(verbatim_host_age) gt 0>
        <cfset oper=left(verbatim_host_age,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(verbatim_host_age,len(verbatim_host_age)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(verbatim_host_age)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_verbatim_host_age.attribute_value,t_verbatim_host_age.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_verbatim_host_age.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_verbatim_host_age.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("verbatim_host_sex")>
    <cfset mapurl = "#mapurl#&verbatim_host_sex=#verbatim_host_sex#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_verbatim_host_sex ON (#session.flatTableName#.collection_object_id = t_verbatim_host_sex.collection_object_id)">
    <cfset basQual = " #basQual# AND t_verbatim_host_sex.attribute_type = 'verbatim host sex'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_verbatim_host_sex.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(verbatim_host_sex) gt 0>
        <cfset oper=left(verbatim_host_sex,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(verbatim_host_sex,len(verbatim_host_sex)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(verbatim_host_sex)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_verbatim_host_sex.attribute_value,t_verbatim_host_sex.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_verbatim_host_sex.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_verbatim_host_sex.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("verbatim_preservation_date")>
    <cfset mapurl = "#mapurl#&verbatim_preservation_date=#verbatim_preservation_date#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_verbatim_preservation_date ON (#session.flatTableName#.collection_object_id = t_verbatim_preservation_date.collection_object_id)">
    <cfset basQual = " #basQual# AND t_verbatim_preservation_date.attribute_type = 'verbatim preservation date'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_verbatim_preservation_date.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(verbatim_preservation_date) gt 0>
        <cfset oper=left(verbatim_preservation_date,1)>
        <cfif listfind(charattrschops,oper)>
            <cfset schTerm=ucase(right(verbatim_preservation_date,len(verbatim_preservation_date)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(verbatim_preservation_date)>
        </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_verbatim_preservation_date.attribute_value,t_verbatim_preservation_date.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_verbatim_preservation_date.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_verbatim_preservation_date.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("weight")>
    <cfset mapurl = "#mapurl#&weight=#weight#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_weight ON (#session.flatTableName#.collection_object_id = t_weight.collection_object_id)">
    <cfset basQual = " #basQual# AND t_weight.attribute_type = 'weight'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_weight.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(weight) gt 0>
        <cfset oper=left(weight,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(weight,len(weight)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(weight)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_weight.attribute_value,t_weight.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_weight.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_weight.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("width")>
    <cfset mapurl = "#mapurl#&width=#width#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_width ON (#session.flatTableName#.collection_object_id = t_width.collection_object_id)">
    <cfset basQual = " #basQual# AND t_width.attribute_type = 'width'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_width.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(width) gt 0>
        <cfset oper=left(width,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(width,len(width)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(width)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_width.attribute_value,t_width.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_width.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_width.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>

<cfif isdefined("wing_chord")>
    <cfset mapurl = "#mapurl#&wing_chord=#wing_chord#">
    <cfset basJoin = " #basJoin# INNER JOIN v_attributes t_wing_chord ON (#session.flatTableName#.collection_object_id = t_wing_chord.collection_object_id)">
    <cfset basQual = " #basQual# AND t_wing_chord.attribute_type = 'wing chord'">
    <cfif session.flatTableName is not "flat">
        <cfset basQual = " #basQual# AND t_wing_chord.is_encumbered = 0">
    </cfif>
    <cfset extendedErrorMsg=listappend(extendedErrorMsg,'Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and <a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">code table datatypes</a> documentation.',";")>
    <cfset schunits="">
    <cfif len(wing_chord) gt 0>
        <cfset oper=left(wing_chord,1)>
        <cfif listfind(numattrschops,oper)>
            <cfset schTerm=ucase(right(wing_chord,len(wing_chord)-1))>
        <cfelse>
            <cfset oper="like"><cfset schTerm=ucase(wing_chord)>
        </cfif>
     <cfset temp=trim(rereplace(schTerm,"[0-9]","","all"))>
     <cfif len(temp) gt 0 and listfindnocase(attrunits,temp) and isnumeric(replace(schTerm,temp,""))>
         <cfset schTerm=replace(schTerm,temp,"")><cfset schunits=temp>
     </cfif>
      <cfif len(schunits) gt 0>
         <cfset basQual = " #basQual# AND to_meters(t_wing_chord.attribute_value,t_wing_chord.attribute_units) #oper# to_meters(#schTerm#,'#schunits#')">
     <cfelseif oper is not "like" and len(schunits) is 0>
         <cfset basQual = " #basQual# AND upper(t_wing_chord.attribute_value) #oper# '#escapeQuotes(schTerm)#')">
     <cfelse>
         <cfset basQual = " #basQual# AND upper(t_wing_chord.attribute_value) like '%#ucase(escapeQuotes(schTerm))#%'">
     </cfif>
    </cfif>
</cfif>
	
