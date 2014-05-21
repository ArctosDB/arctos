<cfcomponent>
<!--------------------------------------------------------------------------------------------------------->
<cffunction name="getSpecimenResults" access="remote" returnformat="plain" queryFormat="column">
	<cfparam name="jtStartIndex" type="numeric" default="0">
	<cfparam name="jtPageSize" type="numeric" default="10">
	<cfparam name="jtSorting" type="string" default="GUID ASC">
	<cfset jtStopIndex=jtStartIndex+jtPageSize>
	<cfset obj = CreateObject("component","component.docs")>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		Select * from (
				Select a.*, rownum rnum From (
					select * from #session.SpecSrchTab# order by #jtSorting#
				) a where rownum <= #jtStopIndex#
			) where rnum >= #jtStartIndex#
	</cfquery>
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
	<cfreturn result>
</cffunction>

<!--------------------------------------------------------------------------------------->
<cffunction name="get_specSrchTermWidget" access="remote" returnformat="plain">
	<cfquery name="ssrch_field_doc" datasource="cf_dbuser">
		select * from ssrch_field_doc where SPECIMEN_QUERY_TERM=1 order by cf_variable
	</cfquery>
	<cfoutput>
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
			});
			function setThisName(tv){
				$("##newValue").attr('name',tv);
			}
			function removeTerm(key){
				$("##" + key).remove();
				$("##row_" + key).remove();
			}
		</script>
		<span class="infoLink" id="showsearchterms">[ Show/Hide Search Terms ]</span>
		<cfif session.ResultsBrowsePrefs is 1>
			<cfset thisStyle='display:block;'>
		<cfelse>
			<cfset thisStyle='display:none;'>
		</cfif>
		<div id="refineSearchTerms" style="#thisStyle#">
			<div style="font-size:small;">
				This is an experiment. 
				Change values and press ENTER or click the button. 
				Clear a value to remove it from the search. 
				Use the contact link at the bottom to provide feedback.
			</div>
			<form name="refineResults" method="get" action="/SpecimenResults.cfm">
				<table border>
				<tr>
					<th>Term</th>
					<th></th>
					<th>Value</th>
					<th>Vocabulary *</th>
					<th>Remove</th>
				</tr>
				<CFSET KEYLIST="">
				<cfloop list="#session.mapURL#" delimiters="&" index="kvp">
					<cfif listlen(kvp,"=") is 2>
						<cfset thisKey=listgetat(kvp,1,"=")>
						<cfset keylist=listappend(keylist,thisKey)>
						<cfset thisValue=listgetat(kvp,2,"=")>
					<cfelse>
						<!--- variable only - tests for existence of attribtues ---->
						<cfset thisKey=replace(kvp,'=','','all')>
						<cfset keylist=listappend(keylist,thisKey)>
						<cfset thisValue=''>
					</cfif>
					<tr id="row_#thisKey#">
						<td>
							<cfquery name="thisMoreInfo" dbtype="query">
								select * from ssrch_field_doc where CF_VARIABLE='#lcase(thisKey)#'
							</cfquery>
							<cfif len(thisMoreInfo.DEFINITION) gt 0>
								<cfset thisSpanClass="helpLink">
							<cfelse>
								<cfset thisSpanClass="">
							</cfif>
							<span class="#thisSpanClass#" id="_#thisMoreInfo.CF_VARIABLE#" title="#thisMoreInfo.DEFINITION#">
							<cfif len(thisMoreInfo.DISPLAY_TEXT) gt 0>
								#thisMoreInfo.DISPLAY_TEXT#
							<cfelse>
								#thisKey#
							</cfif>
							</span>					
						</td>
						<td>=</td>
						<td>
							<!--- attributes take units as part of the variable, so no code tables ---->
							<input type="text" name="#thisKey#" id="#thisKey#" value="#thisvalue#" placeholder="#thisMoreInfo.PLACEHOLDER_TEXT#" size="50">
						</td>
						<td>
							<div style="height:1em; overflow:scroll;">
								<cfif len(thisMoreInfo.CONTROLLED_VOCABULARY) gt 0>
									<cfif left(thisMoreInfo.CONTROLLED_VOCABULARY,2) is "ct">
										<cfquery name="tct" datasource="cf_dbuser">
											select * from #thisMoreInfo.CONTROLLED_VOCABULARY#
										</cfquery>
										<cfloop list="#tct.columnlist#" index="i">
											<cfif i is not "description" and i is not "collection_cde">
												<cfset ctColName=i>
											</cfif>
										</cfloop>
										<cfquery name="cto" dbtype="query">
											select #ctColName# as thisctvalue from tct group by #ctColName# order by #ctColName#
										</cfquery>
										<cfloop query="cto">
											<div class="likeLink" onclick="$('###thisKey#').val('#thisctvalue#');">#thisctvalue#</div>
										</cfloop>
									<cfelse>
										<cfloop list="#thisMoreInfo.CONTROLLED_VOCABULARY#" index="i">
											<div class="likeLink"  onclick="$('###thisKey#').val('#i#');">#i#</div>
										</cfloop>
									</cfif>
								</cfif>
							</div>
						</td>
						<td>
							<span onclick="removeTerm('#thisKey#');" class="likeLink"><img src="/images/del.gif"></span>
						</td>
					</tr>
				</cfloop>
				<cfif len(keylist) is 0>
					<cfset keylist='doesNotExist'>
				</cfif>
				<cfquery name="newkeys" dbtype="query">
					SELECT * FROM ssrch_field_doc WHERE specimen_query_term=1 and CF_VARIABLE NOT IN  (#listqualify(lcase(keylist),chr(39))#) 
				</cfquery>
					<tr>
						<td>
						
							<select id="newTerm" onchange="setThisName(this.value);">
								<option value=''>Add new term</option>
								<cfloop query="newkeys">
									<option value="#cf_variable#">#DISPLAY_TEXT#</option>
								</cfloop>
							</select>
							
						</td>
						<td>=</td>
						<td>
							<input type="text" name="newValue" id="newValue" size="50">
						</td>
					</tr>
				</table>
				<input type="submit" value="Requery">
				<div style="font-size:x-small">
					* Attributes will accept non-code-table values and operators: "2 mm" or "<2mm," for example.
				</div>
			</form>
		</div>
	</cfsavecontent>
	</cfoutput>
	<cfreturn widget>	
</cffunction>
<!-------------------------------------------------->
<cffunction name="mapUserSpecResults" access="remote">
	<cftry>
		<cfquery name="summary" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				distinct(round(dec_lat) || ',' || round(dec_long)) coords
			from 
				#session.SpecSrchTab#
		</cfquery>
		<cfset obj = CreateObject("component","functions")>
		<!--- build and return a HTML block for a map ---->
 		<cfset params='markers=color:red|size:tiny|label:X|#URLEncodedFormat("#valuelist(summary.coords,"|")#")#'>
		<cfset params=params & '&maptype=roadmap&zoom=0&size=200x200'>
		<cfset signedURL = obj.googleSignURL(
			urlPath="/maps/api/staticmap",
			urlParams="#params#")>
		<cfif len(signedURL) gt 2048>
			<cfreturn "[too many results: no map available]">
		</cfif>
		<cfset mapImage='<img src="#signedURL#" alt="[ map of your query ]">'>
		<cfreturn mapImage>
	<cfcatch>
		<cfreturn #cfcatch.detail#>
	</cfcatch>
	</cftry>
</cffunction>
<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getMedia" access="remote">
	<cfargument name="idList" type="string" required="yes">
	<cfset theResult=queryNew("media_id,collection_object_id,media_relationship")>
	<cfset r=1>
	<cfset tableList="cataloged_item,collecting_event">
	<cftry>
	<cfloop list="#idList#" index="cid">
		<cfloop list="#tableList#" index="tabl">
			<cfquery name="mid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select getMediaBySpecimen('#tabl#',#cid#) midList from dual
			</cfquery>
			<cfif len(mid.midList) gt 0>
				<cfset t = queryaddrow(theResult,1)>
				<cfset t = QuerySetCell(theResult, "collection_object_id", "#cid#", r)>
				<cfset t = QuerySetCell(theResult, "media_id", "#mid.midList#", r)>
				<cfset t = QuerySetCell(theResult, "media_relationship", "#tabl#", r)>
				<cfset r=r+1>
			</cfif>
		</cfloop>
	</cfloop>
	<cfcatch>
				<cfset craps=queryNew("media_id,collection_object_id,media_relationship")>
				<cfset temp = queryaddrow(craps,1)>
				<cfset t = QuerySetCell(craps, "collection_object_id", "12", 1)>
				<cfset t = QuerySetCell(craps, "media_id", "45", 1)>
				<cfset t = QuerySetCell(craps, "media_relationship", "#cfcatch.message# #cfcatch.detail#", 1)>
				<cfreturn craps>
		</cfcatch>
	</cftry>
	<cfreturn theResult>
</cffunction>

<!----------------------------------------------------------------------------------------------------------------->
<cffunction name="getTypes" access="remote">
	<cfargument name="idList" type="string" required="yes">
	<cfset theResult=queryNew("collection_object_id,typeList")>
	<cfset r=1>
	<cftry>
	<cfloop list="#idList#" index="cid">
		<cfquery name="ts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select  type_status || decode(count(*),1,'','(' || count(*) || ')') type_status from citation where collection_object_id=#cid# group by type_status
		</cfquery>
		<cfif ts.recordcount gt 0>
			<cfset tl=valuelist(ts.type_status,";")>
			<cfset t = queryaddrow(theResult,1)>
			<cfset t = QuerySetCell(theResult, "collection_object_id", "#cid#", r)>
			<cfset t = QuerySetCell(theResult, "typeList", "#tl#", r)>
			<cfset r=r+1>
		</cfif>
	</cfloop>
	<cfcatch>
		<cfset t = queryaddrow(theResult,1)>
		<cfset t = QuerySetCell(theResult, "collection_object_id", "-1", 1)>
		<cfset t = QuerySetCell(theResult, "typeList", "#cfcatch.detail#", 1)>
	</cfcatch>
	</cftry>
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
