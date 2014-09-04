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
				<td id="voccell_#term#">
					<cfif len(tquery.CONTROLLED_VOCABULARY) gt 0>
						<span class="likeLink" onclick="fetchSrchWgtVocab('#term#');">fetch vocabulary</span>
					<cfelse>
						&nbsp;
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
<cffunction name="getVocabulary" access="remote">
	<cfargument name="key" required="true" type="string">
	<cfargument name="scope" required="false" default="" type="string">
	<cfif scope is "results">
		<!---- just get values from their data ----->
		<cfquery name="currentdata" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select #key# v,2 m from #session.SpecSrchTab# where #key# is not null group by #key# order by #key#
		</cfquery>
		<cfreturn currentdata>
	</cfif>
	<cfquery name="v" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
		select CONTROLLED_VOCABULARY from ssrch_field_doc where CF_VARIABLE='#key#'
	</cfquery>
	<cfif len(v.CONTROLLED_VOCABULARY) is 0>
		<cfreturn>
	<cfelseif left(v.CONTROLLED_VOCABULARY,2) is "ct">
		<cfquery name="tct" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,0,0)#">
			select * from #v.CONTROLLED_VOCABULARY#
		</cfquery>
		<cfloop list="#tct.columnlist#" index="tcname">
			<cfif tcname is not "description" and tcname is not "collection_cde">
				<cfset ctColName=tcname>
			</cfif>
		</cfloop>		
		<cfquery name="r" dbtype="query">
			select #ctColName# as v from tct where #ctColName# is not null group by #ctColName# order by #ctColName#
		</cfquery>
		<cfquery name="currentdata" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select #key# from #session.SpecSrchTab# where #key# is not null group by #key#
		</cfquery>
		<cfquery name="r2" dbtype="query">
			select v from r union all select #key# from currentdata
		</cfquery>
		<cfquery name="rtn" dbtype="query">
			select v ,count(*) m from r2 group by v order by v
		</cfquery>
		<cfreturn rtn>
	<cfelse>
		<!--- list ---->
		<cfset r = querynew("v,m")>
		<cfset idx=1>
		<cfloop list="#v.CONTROLLED_VOCABULARY#" index="i">
			<cfset temp = queryaddrow(r,1)>
			<cfset temp = QuerySetCell(r, "v", i, idx)>
			<cfset temp = QuerySetCell(r, "m", 0, idx)>
			<cfset idx=idx+1>
		</cfloop>
		<cfreturn r>
	</cfif>
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
				<span class="infoLink" onclick="toggleSearchTerms()" id="showsearchterms">[ Show/Hide Search Terms ]</span>
			</cfsavecontent>
			<cfreturn widget>
		</cfif>
		<cfquery name="ssrch_field_doc" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
			select * from ssrch_field_doc where SPECIMEN_QUERY_TERM=1 order by cf_variable
		</cfquery>
		<cfset stuffToIgnore="locality_remarks,specimen_event_remark,identification_remarks,made_date,Accession,guid,BEGAN_DATE,COLLECTION_OBJECT_ID,COORDINATEUNCERTAINTYINMETERS,CUSTOMID,CUSTOMIDINT,DEC_LAT,DEC_LONG,ENDED_DATE,MYCUSTOMIDTYPE,VERBATIM_DATE">
				<cfdump var=#stuffToIgnore#>

		<!---- just need columns ---->
		<cfquery name="srchcols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from #session.SpecSrchTab# where 1=2
		</cfquery>
		<CFSET KEYLIST="">
		<!--- pre-build table of
			-- things they searched on
			-- select things from their results
			-- existing search value, when available
		---->
		<!--- a table for stuff that's turned on ---->
		<cfset sugntab = querynew("key,val,definition,vocab,display_text,placeholder_text,search_hint,indata")>



		<!---- BEGIN: then loop over the things they searched for 
			- ignore listtoignore here
			- update when searched-on value is in the results and so already in the query---->
		<cfset idx=1>
		<cfset thisValue="">
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
			
			<cfif not listfindnocase(keylist,thisKey)>
				<cfset keylist=listappend(keylist,thisKey)>
				<cfquery name="thisMoreInfo" dbtype="query">
					select * from ssrch_field_doc where CF_VARIABLE='#lcase(thisKey)#'
				</cfquery>	
				<cfset temp = queryaddrow(sugntab,1)>
				<cfset temp = QuerySetCell(sugntab, "key", lcase(thisKey), idx)>	
				<cfset temp = QuerySetCell(sugntab, "val", thisValue, idx)>
				<cfset temp = QuerySetCell(sugntab, "definition", thisMoreInfo.definition, idx)>
				<cfset temp = QuerySetCell(sugntab, "display_text", thisMoreInfo.display_text, idx)>
				<cfset temp = QuerySetCell(sugntab, "vocab", thisMoreInfo.controlled_vocabulary, idx)>
				<cfset temp = QuerySetCell(sugntab, "placeholder_text", thisMoreInfo.placeholder_text, idx)>
				<cfset temp = QuerySetCell(sugntab, "search_hint", thisMoreInfo.search_hint, idx)>
				<cfset temp = QuerySetCell(sugntab, "indata", listfindnocase(srchcols.columnlist,thisKey), idx)>
				<cfset idx=idx+1>
			</cfif>
		</cfloop>
		<!---- END: then loop over the things they searched for - ignore listtoignore here---->
		
		<cfdump var=#srchcols.columnlist#>
		
		<!---- BEGIN: first loop over the things in their results so that we can filter OR exapand ---->
		<cfset thisValue="">
		<cfloop list="#srchcols.columnlist#" index="thisKey">
			<br>thisKey: #thisKey#
			<cfif not listfindnocase(stuffToIgnore,thisKey) and not listfindnocase(keylist,thisKey)>
			<br>made it with #thisKey#
				<cfset keylist=listappend(keylist,thisKey)>
				<cfquery name="thisMoreInfo" dbtype="query">
					select * from ssrch_field_doc where CF_VARIABLE='#lcase(thisKey)#'
				</cfquery>
				
						<cfdump var=#thisMoreInfo#>

				<cfif thisMoreInfo.recordcount is 1>
					<cfset temp = queryaddrow(sugntab,1)>
					<cfset temp = QuerySetCell(sugntab, "key", lcase(thisKey), idx)>	
					<cfset temp = QuerySetCell(sugntab, "val", thisValue, idx)>
					<cfset temp = QuerySetCell(sugntab, "definition", thisMoreInfo.definition, idx)>
					<cfset temp = QuerySetCell(sugntab, "display_text", thisMoreInfo.display_text, idx)>
					<cfset temp = QuerySetCell(sugntab, "vocab", thisMoreInfo.controlled_vocabulary, idx)>
					<cfset temp = QuerySetCell(sugntab, "placeholder_text", thisMoreInfo.placeholder_text, idx)>
					<cfset temp = QuerySetCell(sugntab, "search_hint", thisMoreInfo.search_hint, idx)>
					<cfset temp = QuerySetCell(sugntab, "indata", 1, idx)>
					<cfset idx=idx+1>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfdump var=#sugntab#>
		<!---- END: first loop over the things in their results so that we can filter OR exapand ---->
		
		
		<cfsavecontent variable="widget">
			<span class="infoLink" onclick="toggleSearchTerms()" id="showsearchterms">[ Show/Hide Search Terms ]</span>
			<cfif session.ResultsBrowsePrefs is 1>
				<cfset thisStyle='display:block;'>
			<cfelse>
				<cfset thisStyle='display:none;'>
			</cfif>
			<a id="aboutSTWH" class="infoLink external" href="http://arctosdb.org/how-to/specimen-search-refine/" target="_blank">[ About this Widget ]</a>
			<a id="fbSWT" class="infoLink" href="/contact.cfm?ref=SpecimenResultsWidget">[ provide feedback ]</a>
			<div id="refineSearchTerms" style="#thisStyle#">
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
									<td id="voccell_#sugntab.key#">
										<cfif len(sugntab.vocab) gt 0>
											fetch <span class="likeLink" onclick="fetchSrchWgtVocab('#sugntab.key#');">all vocabulary</span>
											<cfif sugntab.indata gt 0>
												or <span class="likeLink" onclick="fetchSrchWgtVocab('#sugntab.key#','results');">from results</span>
											</cfif>
										<cfelse>
											&nbsp;
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
						<input class="clrBtn" type="reset" value="Reset Filters">
						<span style="width:10em">&nbsp;</span>
						<select id="newTerm" onchange="addARow(this.value);">
							<option value=''>Add a row....</option>
							<cfloop query="newkeys">
								<option value="#cf_variable#">#DISPLAY_TEXT#</option>
							</cfloop>
						</select>
						<input class="schBtn" type="submit" value="Requery">
					<div style="font-size:x-small">
						* Click on a term for search help.
					</div>
				</form>
			</div>
		</cfsavecontent>
	</cfoutput>
	<cfcatch>
		<cfdump var=#cfcatch#>
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
