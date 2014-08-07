<cfcomponent>
<!--------------------------------------------------------------------------------------------------------->
<cffunction name="getSpecimenResults" access="remote" returnformat="plain" queryFormat="column">
	<cfparam name="jtStartIndex" type="numeric" default="0">
	<cfparam name="jtPageSize" type="numeric" default="10">
	<cfparam name="jtSorting" type="string" default="GUID ASC">
	<cftry>
		<cfset jtStopIndex=jtStartIndex+jtPageSize>
		<cfset obj = CreateObject("component","component.docs")>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			Select * from (
					Select a.*, rownum rnum From (
						select * from #session.SpecSrchTab# order by #jtSorting#
					) a where rownum <= #jtStopIndex#
				) where rnum >= #jtStartIndex#
		</cfquery>
		<cfset session.collObjIdList = valuelist(d.collection_object_id)>
		<cfoutput>
			<!--- 
				CF and jtable don't play well together, so roll our own.... 
				parseJSON makes horrid invalud datatype assumptions, so we can't use that either.	
			---->
			<cfset x=''>
			<cfloop query="d">
				<cfset trow="">
				<cfloop list="#d.columnlist#" index="i">
					<cfset theData=evaluate("d." & i)>
					<cfset theData=obj.jsonEscape(theData)>
					
					<cfif i is "guid">
						<cfset temp ='"GUID":"<div id=\"CatItem_#collection_object_id#\"><a target=\"_blank\" href=\"/guid/' & theData &'\">' &theData & '</a></div>"'>
					<cfelseif i is "media">
						<cfset temp ='"MEDIA":"<div id=\"jsonmedia_#collection_object_id#\">' & theData & '</div>"'>
					<cfelse>
						<cfset temp = '"#i#":"' & theData & '"'>
					</cfif>
					<cfset trow=listappend(trow,temp)>
				</cfloop>
				<cfset trow="{" & trow & "}">
				<cfset x=listappend(x,trow)>
			</cfloop>
			<cfset result='{"Result":"OK","Records":[' & x & '],"TotalRecordCount":#TotalRecordCount#}'>
		</cfoutput>
	<cfcatch>
		<cfmail subject="specresults error" to="arctos.database@gmail.com" from="srerror@arctos.database.museum" type="html">
			<cfdump var=#cfcatch#>
		</cfmail>
		<cfset result='{"Result":"ERROR","Message":"#cfcatch.message#: #cfcatch.detail#"}'>
	</cfcatch>
	</cftry>
	<cfreturn result>
</cffunction>
<!--------------------------------------------------------------------------------------->

<cffunction name="specSrchTermWidget_addrow" access="remote" returnformat="plain">
	<cfparam name="term" type="string">
	<!---- takes a term, returns a table row for get_specSrchTermWidget ---->
	<cfquery name="tquery" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
		select * from ssrch_field_doc where cf_variable='#lcase(term)#'
	</cfquery>
	<cfif left(tquery.CONTROLLED_VOCABULARY,2) is "ct">
		<cfquery name="tct" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
			select * from #tquery.CONTROLLED_VOCABULARY#
		</cfquery>
		<cfloop list="#tct.columnlist#" index="tcname">
			<cfif tcname is not "description" and tcname is not "collection_cde">
				<cfset ctColName=tcname>
			</cfif>
		</cfloop>		
		<cfquery name="cto" dbtype="query">
			select #ctColName# as thisctvalue from tct group by #ctColName# order by #ctColName#
		</cfquery>
			
	</cfif>
	<cfif len(tquery.DEFINITION) gt 0>
		<cfset thisSpanClass="helpLink">
	<cfelse>
		<cfset thisSpanClass="">
	</cfif>
	<cfoutput>	
		<cfsavecontent variable="row">
			<tr id="row_#term#">
				<td>
					<span class="#thisSpanClass#" id="_#term#" title="#tquery.DEFINITION#">
						#tquery.DISPLAY_TEXT#
					</span>
				</td>
				<td>
					<input type="text" name="#term#" id="#term#" value="" placeholder="#tquery.PLACEHOLDER_TEXT#" size="50">
				</td>
				<td>
					<cfif isdefined("cto")>
						<select onchange="$('###term#').val(this.value);">
							<option value=""></option>
							<cfloop query="cto">
								<option value="#thisctvalue#">#thisctvalue#</option>
							</cfloop>
						</select>
					</cfif>
				</td>
				<td>
					<span onclick="$('###term#').val('');" class="likeLink">[ clear ]</span>
					<span onclick="$('###term#').val('_');" class="likeLink">[ require ]</span>
				</td>
			</tr>
		</cfsavecontent>
	</cfoutput>
	
	<cfreturn row>		
</cffunction>
<!--------------------------------------------------------------------------------------->
<cffunction name="get_specSrchTermWidget" access="remote" returnformat="plain">
	<cfif not isdefined("session.RESULTSBROWSEPREFS")>
		<cfset session.RESULTSBROWSEPREFS=0>
	</cfif>
	<cftry>
	<cfoutput>
		<cfif session.resultsbrowseprefs neq 1>
			<cfsavecontent variable="widget">
				<script>
					jQuery( function($) {
						$('##showsearchterms').click(function() {
							if($("##refineSearchTerms").is(":visible")) {
								var v=0;
							} else {
								var v=1;
		  					}
							$('##refineSearchTerms').slideToggle("fast");
							jQuery.getJSON("/component/functions.cfc",
								{
									method : "setResultsBrowsePrefs",
									val : v,
									returnformat : "json",
									queryformat : 'column'
								},
								function() {
									if (v==1){
										jQuery("##cntr_refineSearchTerms").html("<img src='/images/indicator.gif'>");
										var ptl='/component/SpecimenResults.cfc?method=get_specSrchTermWidget&returnformat=plain';
										jQuery.get(ptl, function(data){
											jQuery("##cntr_refineSearchTerms").html(data);
										});
									}
								}
							);
							// they had it off, give them the option of turning it on and then fetch with data when they do
							
						});
					});
				</script>
				<span class="infoLink" id="showsearchterms">[ Show/Hide Search Terms ]</span>
				<a class="infoLink external" href="http://arctosdb.org/how-to/specimen-search-refine/" target="_blank">[ About this Widget ]</a>
			</cfsavecontent>
			<cfreturn widget>
		</cfif>
		<cfquery name="ssrch_field_doc" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
			select * from ssrch_field_doc where SPECIMEN_QUERY_TERM=1 order by cf_variable
		</cfquery>
		<cfset stuffToIgnore="locality_remarks,specimen_event_remark,identification_remarks,made_date,Accession,guid,BEGAN_DATE,COLLECTION_OBJECT_ID,COORDINATEUNCERTAINTYINMETERS,CUSTOMID,CUSTOMIDINT,DEC_LAT,DEC_LONG,ENDED_DATE,MYCUSTOMIDTYPE,SEX,VERBATIM_DATE">
		<cfquery name="srchcols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from #session.SpecSrchTab#
		</cfquery>
		<CFSET KEYLIST="">
		<!--- pre-build table of
			-- things they searched on
			-- select things from their results
			-- existing search value, when available
		---->
		<cfset sugntab = querynew("key,val,vocab,indata,definition,display_text,placeholder_text,search_hint")>
		<!---- first loop over the things they searched for ---->
		<cfset idx=1>
		<cfloop list="#session.mapURL#" delimiters="&" index="kvp">
			<!--- deal with equal prefix=exact match --->
			<cfset kvp=replace(kvp,"=","|","first")>
			<cfif listlen(kvp,"|") is 2>
				<cfset thisKey=listgetat(kvp,1,"|")>
				<cfset thisValue=listgetat(kvp,2,"|")>
			<cfelse>
				<!--- variable only - tests for existence of attribtues ---->
				<cfset thisKey=replace(kvp,'|','','all')>
				<cfset thisValue=''>
			</cfif>
			<cfset keylist=listappend(keylist,thisKey)>
			<cfquery name="thisMoreInfo" dbtype="query">
				select * from ssrch_field_doc where CF_VARIABLE='#lcase(thisKey)#'
			</cfquery>
				<cfif left(thisMoreInfo.CONTROLLED_VOCABULARY,2) is "ct">
					<cfquery name="tct" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
						select * from #thisMoreInfo.CONTROLLED_VOCABULARY#
					</cfquery>
					<cfloop list="#tct.columnlist#" index="tcname">
						<cfif tcname is not "description" and tcname is not "collection_cde">
							<cfset ctColName=tcname>
						</cfif>
					</cfloop>		
					<cfquery name="cto" dbtype="query">
						select #ctColName# as thisctvalue from tct group by #ctColName# order by #ctColName#
					</cfquery>
					<cfset v=valuelist(cto.thisctvalue,"|")>
				<cfelse>
					<cfset v=listchangedelims(thisMoreInfo.CONTROLLED_VOCABULARY,"|")>				
				</cfif>
				<cfif listfindnocase(srchcols.columnlist,thisKey)>
					<cfquery name="dvt" dbtype="query">
						select #thisKey# as vals from srchcols group by #thisKey# order by #thisKey#
					</cfquery>
					<cfset indatavals=valuelist(dvt.vals,"|")>
				<cfelse>
					<cfset indatavals="">
				</cfif>
				<cfset temp = queryaddrow(sugntab,1)>
				<cfset temp = QuerySetCell(sugntab, "key", lcase(thisKey), idx)>	
				<cfset temp = QuerySetCell(sugntab, "val", thisValue, idx)>
				<cfset temp = QuerySetCell(sugntab, "vocab", v, idx)>
				<cfset temp = QuerySetCell(sugntab, "indata", indatavals, idx)>
				<cfset temp = QuerySetCell(sugntab, "definition", thisMoreInfo.definition, idx)>
				<cfset temp = QuerySetCell(sugntab, "display_text", thisMoreInfo.display_text, idx)>
				<cfset temp = QuerySetCell(sugntab, "placeholder_text", thisMoreInfo.placeholder_text, idx)>
				<cfset temp = QuerySetCell(sugntab, "search_hint", thisMoreInfo.search_hint, idx)>
				<cfset idx=idx+1>
		</cfloop>
		<!---- then loop over select things from their results ---->
		<cfset thisValue="">
		<cfloop list="#srchcols.columnlist#" index="thisKey">
			<cfif not listfindnocase(stuffToIgnore,thisKey) and  not listfindnocase(keylist,thisKey)>
				<cfset keylist=listappend(keylist,thisKey)>
				<cfquery name="thisMoreInfo" dbtype="query">
					select * from ssrch_field_doc where CF_VARIABLE='#lcase(thisKey)#'
				</cfquery>
				<cfif thisMoreInfo.recordcount is 1>
					<cfif left(thisMoreInfo.CONTROLLED_VOCABULARY,2) is "ct">
						<cfquery name="tct" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
							select * from #thisMoreInfo.CONTROLLED_VOCABULARY#
						</cfquery>
						<cfloop list="#tct.columnlist#" index="thecolname">
							<cfif thecolname is not "description" and thecolname is not "collection_cde">
								<cfset ctColName=thecolname>
							</cfif>
						</cfloop>
						<cfquery name="cto" dbtype="query">
							select #ctColName# as thisctvalue from tct group by #ctColName# order by #ctColName#
						</cfquery>
						<cfset v=valuelist(cto.thisctvalue,"|")>
					<cfelse>
						<cfset v=listchangedelims(thisMoreInfo.CONTROLLED_VOCABULARY,"|")>				
					</cfif>
					<cfif listfindnocase(srchcols.columnlist,thisKey)>
						<cfquery name="dvt" dbtype="query">
							select #thisKey# as vals from srchcols group by #thisKey# order by #thisKey#
						</cfquery>
						<cfset indatavals=valuelist(dvt.vals,"|")>
					<cfelse>
						<cfset indatavals="">
					</cfif>
					<cfset temp = queryaddrow(sugntab,1)>
					<cfset temp = QuerySetCell(sugntab, "key", lcase(thisKey), idx)>	
					<cfset temp = QuerySetCell(sugntab, "val", thisValue, idx)>
					<cfset temp = QuerySetCell(sugntab, "vocab", v, idx)>
					<cfset temp = QuerySetCell(sugntab, "indata", indatavals, idx)>
					<cfset temp = QuerySetCell(sugntab, "definition", thisMoreInfo.definition, idx)>
					<cfset temp = QuerySetCell(sugntab, "display_text", thisMoreInfo.display_text, idx)>
					<cfset temp = QuerySetCell(sugntab, "placeholder_text", thisMoreInfo.placeholder_text, idx)>
					<cfset temp = QuerySetCell(sugntab, "search_hint", thisMoreInfo.search_hint, idx)>
					<cfset idx=idx+1>
				</cfif>
			</cfif>
		</cfloop>
		<cfsavecontent variable="widget">
			<script>
				jQuery( function($) {
					$('##showsearchterms').click(function() {
						if($("##refineSearchTerms").is(":visible")) {
							var v=0;
						} else {
							var v=1;
	  					}
						$('##refineSearchTerms').slideToggle("fast");
						jQuery.getJSON("/component/functions.cfc",
							{
								method : "setResultsBrowsePrefs",
								val : v,
								returnformat : "json",
								queryformat : 'column'
							}
						);
					});
					// after this loads, check if we need to recenter the map.....
					checkMapBB();
				});
				function addARow(tv){
					jQuery.getJSON("/component/SpecimenResults.cfc",
						{
							method : "specSrchTermWidget_addrow",
							term : tv,
							returnformat : "json"
						},
						function (result) {
							$('##stermwdgtbl tr:last').after(result);
							$("##newTerm option[value='" + tv + "']").remove();
						}
					);
				}
				function removeTerm(key){
					$("##" + key).remove();
					$("##row_" + key).remove();
				}
				function clearAll(){
					$("##refineResults").find("input[type=text]").val("");
				}
			</script>
			<span class="infoLink" id="showsearchterms">[ Show/Hide Search Terms ]</span>
			<a class="infoLink external" href="http://arctosdb.org/how-to/specimen-search-refine/" target="_blank">[ About this Widget ]</a>
			
			
			<cfif session.ResultsBrowsePrefs is 1>
				<cfset thisStyle='display:block;'>
			<cfelse>
				<cfset thisStyle='display:none;'>
			</cfif>
			<div id="refineSearchTerms" style="#thisStyle#">
				<div style="font-size:small;">
					This is an experiment. <a href="/contact.cfm?ref=SpecimenResultsWidget">Contact us</a> to provide feedback.
				</div>
				<form name="refineResults" id="refineResults" method="get" action="/SpecimenResults.cfm">
					<table id="stermwdgtbl" border>
						<tr>
							<th>Term</th>
							<th>Value</th>
							<th>Vocabulary *</th>
							<th>Controls</th>
						</tr>
						<cfloop query="sugntab">
							<cfif len(sugntab.DEFINITION) gt 0>
								<cfset thisSpanClass="helpLink">
							<cfelse>
								<cfset thisSpanClass="">
							</cfif>
							<tr id="row_#sugntab.key#">
								<td>
									<span class="#thisSpanClass#" id="_#sugntab.key#" title="#sugntab.DEFINITION#">
										#replace(sugntab.DISPLAY_TEXT," ","&nbsp;","all")#
									</span>
								</td>
									<td>
										<input type="text" name="#sugntab.key#" id="#sugntab.key#" value="#sugntab.val#" placeholder="#sugntab.PLACEHOLDER_TEXT#" size="50">
									</td>
									<td>
										<cfif len(sugntab.vocab) gt 0>
											<!---- controlled vocab - loop through it, make indata values BOLD ---->
											<select class="ssw_sngselect" onchange="$('###sugntab.key#').val(this.value);">
												<option value=""></option>
												<cfloop list="#sugntab.vocab#" index="v" delimiters="|">
													<cfif listfindnocase(sugntab.indata,v,"|")>
														<cfset thisStyle="font-weight:bold;">
													<cfelse>
														<cfset thisStyle="">
													</cfif>
													<option value="#v#" style="#thisStyle#">#v#</option>
												</cfloop>
											</select>
										<cfelseif len(sugntab.indata) gt 0>
											<!---- no controlled vocab, just provide list of INDATA values ---->
											<cfset thisStyle="font-weight:bold;">
											<select  class="ssw_sngselect" onchange="$('###sugntab.key#').val(this.value);">
												<option value=""></option>
												<cfloop list="#sugntab.indata#" index="v" delimiters="|">
													<option value="#v#" style="#thisStyle#">#v#</option>
												</cfloop>
											</select>
										</cfif>
									</td>
									<td>
										<span onclick="$('###sugntab.key#').val('');" class="likeLink">[&nbsp;clear&nbsp;]</span>&nbsp;<span onclick="$('###sugntab.key#').val('_');" class="likeLink">[&nbsp;require&nbsp;]</span>
									</td>
								</tr>
						</cfloop>
						</table>
						<cfif len(keylist) is 0>
							<cfset keylist='doesNotExist'>
						</cfif>
						<cfquery name="newkeys" dbtype="query">
							SELECT * FROM ssrch_field_doc WHERE CF_VARIABLE NOT IN  (#listqualify(lcase(keylist),chr(39))#) 
						</cfquery>
						<select id="newTerm" onchange="addARow(this.value);">
							<option value=''>Add a row....</option>
							<cfloop query="newkeys">
								<option value="#cf_variable#">#DISPLAY_TEXT#</option>
							</cfloop>
						</select>
						<input type="reset" value="Reset Filters">
					<input type="submit" value="Requery">
					<div style="font-size:x-small">
						* Click on a term for search help.
					</div>
				</form>
			</div>
		</cfsavecontent>
	</cfoutput>
	<cfcatch>
		<cf_logError subject="specimenresults widget error" attributeCollection=#cfcatch#>
		<cfreturn "An error occurred">
	</cfcatch>
	</cftry>
	<cfreturn widget>	
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getMedia" access="remote">
	<!----
		Input: List of cataloged_item.collection_object_id
		
		find all media related to any cataloged item in the list by way of
			-- cataloged_item
			-- collecting_event
		
		Return table of 
			COLLECTION_OBJECT_ID
			MEDIA_ID (list)	
			MEDIA_RELATIONSHIP (hard-coded to cataloged_item - consider more specificity later, or not because scattering is probably confusing)
	
		see v6.3.1 for previous DB-intensive but more specific version
	---->
	<cfargument name="idList" type="string" required="yes">
	<cfif len(idList) is 0>
		<cfreturn>
	</cfif>
	<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			#session.flatTableName#.collection_object_id,
			media_relations.media_id
		from 
			media_relations,
			#session.flatTableName#
		where
			#session.flatTableName#.collection_object_id = media_relations.related_primary_key and
			SUBSTR(media_relationship,instr(media_relationship,' ',-1)+1)='cataloged_item' and
			#session.flatTableName#.collection_object_id in (#idList#)
		union
		select 
			#session.flatTableName#.collection_object_id,
			media_relations.media_id
		from 
			media_relations,
			#session.flatTableName#,
			specimen_event
		where
			#session.flatTableName#.collection_object_id=specimen_event.collection_object_id and
			specimen_event.collecting_event_id = media_relations.related_primary_key and
			SUBSTR(media_relationship,instr(media_relationship,' ',-1)+1)='collecting_event' and
			#session.flatTableName#.collection_object_id in (#idList#)	
	</cfquery>
	<cfquery name="did" dbtype="query">
		select distinct collection_object_id from raw
	</cfquery>
	<cfset theResult=queryNew("media_id,collection_object_id,media_relationship")>
	<cfset r=1>
	<cfloop query="did">
		<cfquery name="tm" dbtype="query">
			select media_id from raw where collection_object_id=#collection_object_id#
		</cfquery>
		<cfset t = queryaddrow(theResult,1)>
		<cfset t = QuerySetCell(theResult, "collection_object_id", collection_object_id, r)>
		<cfset t = QuerySetCell(theResult, "media_id", valuelist(tm.media_id), r)>
		<cfset t = QuerySetCell(theResult, "media_relationship", "cataloged_item", r)>
		<cfset r=r+1>
	</cfloop>	
	<cfreturn theResult>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getTypes" access="remote">
	<cfargument name="idList" type="string" required="yes">
	<cfif len(idList) is 0>
		<cfreturn>
	</cfif>
	<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select  
			citation.collection_object_id,
			type_status || decode(count(*),1,'','(' || count(*) || ')') type_status 
		from 
			citation 
		where 
			collection_object_id in (#idList#) 
		group by 
			collection_object_id,
			type_status
	</cfquery>
	<cfquery name="did" dbtype="query">
		select distinct collection_object_id from raw
	</cfquery>
	<cfset theResult=queryNew("collection_object_id,typeList")>
	<cfset r=1>
	<cfloop query="did">
		<cfquery name="tm" dbtype="query">
			select type_status from raw where collection_object_id=#collection_object_id#
		</cfquery>
		<cfset t = queryaddrow(theResult,1)>
		<cfset t = QuerySetCell(theResult, "collection_object_id", collection_object_id, r)>
		<cfset t = QuerySetCell(theResult, "typeList", valuelist(tm.type_status,'; '), r)>
		<cfset r=r+1>
	</cfloop>
	<cfreturn theResult>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getLoanPartResults" access="remote">
	<cfargument name="transaction_id" type="numeric" required="yes">
	<cfoutput>
	<cfquery name="result" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			cataloged_item.COLLECTION_OBJECT_ID,
			specimen_part.collection_object_id partID,
			coll_object.COLL_OBJ_DISPOSITION,
			coll_object.LOT_COUNT,
			coll_object.CONDITION,
			specimen_part.PART_NAME,
			specimen_part.SAMPLED_FROM_OBJ_ID,
			concatEncumbrances(cataloged_item.collection_object_id) as encumbrance_action,
			loan_item.transaction_id,
			nvl(p1.barcode,'NOBARCODE') barcode
		from
			#session.SpecSrchTab#,
			cataloged_item,
			coll_object,
			specimen_part,
			(select * from loan_item where transaction_id = #transaction_id#) loan_item,
			coll_obj_cont_hist,
			container p0,
			container p1
		where
			#session.SpecSrchTab#.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
			specimen_part.collection_object_id = coll_object.collection_object_id and
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id (+) and
			coll_obj_cont_hist.container_id=p0.container_id (+) and
			p0.parent_container_id=p1.container_id (+) and
			specimen_part.SAMPLED_FROM_OBJ_ID is null and
			specimen_part.collection_object_id = loan_item.collection_object_id (+)
		order by
			cataloged_item.collection_object_id, specimen_part.part_name
	</cfquery>
	<cfreturn result>
	</cfoutput>
</cffunction>
</cfcomponent>
