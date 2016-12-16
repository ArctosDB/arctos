<cfcomponent>

<!--------------------------------------------------------------------------------------------------------->
<cffunction name="getSpecimenSummary" access="remote" returnformat="plain" queryFormat="column">
		<cfparam name="querystring" type="string" default="">
		<cfparam name="groupby" type="string" default="">
		<cfparam name="jtStartIndex" type="numeric" default="0">
		<cfparam name="jtPageSize" type="numeric" default="10">
		<cfparam name="jtSorting" type="string" default="#groupby# ASC">
		<cfparam name="totalRecordCount" type="numeric" default="0">
		<cfparam name="totalSpecimenCount" type="numeric" default="0">
		<cfparam name="qid" type="string" default="">
		<!----
			2 options here:
				pass in querystring,groupby-->initial query + qid
				pass in qid --> query of cache (eg, paging)
		---->
		<cftry>
			<cfif len(qid) is 0>
				<cfset querystring=URLDecode(querystring)>
				<cfloop list="#querystring#" index="kv" delimiters="&?">
					<cfif listlen(kv,"=") is 2>
						<cfset vname=listgetat(kv,1,"=")>
						<cfset vval=listgetat(kv,2,"=")>
						<cfset "#vname#"=vval>
					</cfif>
				</cfloop>
				<cfif not listfindnocase(groupby,'collection_object_id')>
					<cfset groupBy=listprepend(groupby,"collection_object_id")>
				</cfif>
				<cfset prefixed_cols="">
				<cfset spcols="">
				<cfloop list="#groupBy#" index="x">
					<cfset prefixed_cols = listappend(prefixed_cols,"#session.flatTableName#.#x#")>
					<cfif x is not "collection_object_id" and x is not "individualcount">
						<cfset spcols = listappend(spcols,"#session.flatTableName#.#x#")>
					</cfif>
				</cfloop>

				<p>
				prefixed_cols: #prefixed_cols#
				</p>
				<cfif prefixed_cols contains "#session.flatTableName#.guid_prefix">
					<cfset prefixed_cols=replace(
						prefixed_cols,
						"#session.flatTableName#.guid_prefix",
						"substr(#session.flatTableName#.guid, 1,instr(#session.flatTableName#.guid,':',1,2) - 1) guid_prefix")>
				</cfif>

				<p>
				prefixed_cols: #prefixed_cols#
				</p>

				<cfset basSelect = " SELECT #prefixed_cols# ">
				<cfset basFrom = " FROM #session.flatTableName#">
				<cfset basJoin = "">
				<cfset basWhere = " WHERE #session.flatTableName#.collection_object_id IS NOT NULL ">
				<cfset basQual = "">
				<cfset mapurl="">
				<!----
				<cfoutput>
				<p>
					basSelect: #basSelect#
				</p>
				</cfoutput>
				---->
				<cfinclude template="/includes/SearchSql.cfm">
				<cfset group_cols = groupBy>
				<cfset group_cols=listdeleteat(group_cols,listfindnocase(group_cols,'collection_object_id'))>
				<cfif listfindnocase(group_cols,'individualcount')>
					<cfset group_cols=listdeleteat(group_cols,listfindnocase(group_cols,'individualcount'))>
				</cfif>
				<cfif listfindnocase(group_cols,'guid_prefix')>
					<cfset group_cols=listdeleteat(group_cols,listfindnocase(group_cols,'guid_prefix'))>
				</cfif>


				<!--- require some actual searching --->
				<cfset srchTerms="">
				<cfloop list="#mapurl#" delimiters="&" index="t">
					<cfset tt=listgetat(t,1,"=")>
					<cfset srchTerms=listappend(srchTerms,tt)>
				</cfloop>
				<!--- remove standard criteria that kill Oracle... --->
				<cfif listcontains(srchTerms,"collection_id")>
					<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'collection_id'))>
				</cfif>
				<!--- ... and abort if there's nothing left --->
				<cfif len(srchTerms) is 0>
					<cfset result='{"Result":"ERROR","Message":"You must provide search criteria."}'>
					<cfreturn result>
				</cfif>
				<cfset thisLink=mapurl>
				<!---
					mapURL probably contains taxon_scope
					We have to over-ride that here to get the
					correct links - eg, the no-subspecies name
					should not contain all the subspecies
				---->
				<cfif thisLink contains "scientific_name_match_type">
					<cfset delPos=listcontains(thisLink,"scientific_name_match_type=","?&")>
					<cfset thisLink=listdeleteat(thisLink,delPos,"?&")>
				</cfif>
				<cfset thisLink="#thisLink#&scientific_name_match_type=exact">

				<cfloop list="#spcols#" index="pt">
					<cfset x=listgetat(pt,2,'.')>
					<cfif thisLink contains x>
						<!---
							they searched for something that they also grouped by
							REMOVE the thing they searched (eg, more general)
							ADD the thing grouped (eg, more specific)
						---->
						<!--- replace search terms with stuff here ---->
						<cfset delPos=listcontainsnocase(thisLink,x,"?&")>
						<cfset thisLink=listdeleteat(thisLink,delPos,"?&")>
						<cfset thisLink=listappend(thisLink,"#x#==' || urlescape(nvl(to_char(#pt#),'NULL')) || '","&")>
					<cfelse>
						<!--- they grouped by something they did not search by, add it to the specimen-link ---->
						<cfset thisLink=listappend(thisLink,"#x#==' || urlescape(nvl(to_char(#pt#),'NULL')) || '","&")>
					</cfif>
				</cfloop>
				<cfif left(thislink,1) is '&'>
					<cfset thisLInk=right(thisLink,len(thisLink)-1)>
				</cfif>
				<cfif right(thisLink,5) is " || '">
					<cfset thisLink=left(thisLink,len(thisLink)-5)>
				</cfif>
				<cfset thisLink=replace(thisLink,'==NULL','=NULL','all')>
				<cfset thisLink="'" & thisLInk>
				<cfset basSelect=basSelect & ",replace(#thisLink#,'==NULL','=NULL') AS linktospecimens ">
				<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual# ">

<p>
				SqlString: <cfdump var=#SqlString#>
				</p>
				<!----
				<p>
				SqlString: <cfdump var=#SqlString#>
				</p>
				---->



				<!----
				<cfset checkSql(SqlString)>
				---->
				<cfset InnerSqlString = 'select COUNT(distinct(collection_object_id)) CountOfCatalogedItem, linktospecimens,'>
				<cfif listfindnocase(groupBy,'individualcount')>
					<cfset InnerSqlString = InnerSqlString & 'sum(individualcount) individualcount, '>
				</cfif>
				<cfif listfindnocase(groupBy,'individualcount')>
					<cfset InnerSqlString = InnerSqlString & 'sum(individualcount) individualcount, '>
				</cfif>

				guid_prefix


				<cfset InnerSqlString = InnerSqlString & '#group_cols# from (#SqlString#) group by #group_cols#,linktospecimens order by #group_cols#'>
				<!----
				<p>
				InnerSqlString: <cfdump var=#InnerSqlString#>
				</p>
				---->


				<cfset InnerSqlString = 'create table #session.SpecSumTab# as ' & InnerSqlString>
				<cftry>
					<cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						drop table #session.SpecSumTab#
					</cfquery>
					<cfcatch><!--- not there, so what? --->
					</cfcatch>
				</cftry>
				<cfquery name="mktbl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					#preserveSingleQuotes(InnerSqlString)#
				</cfquery>
				<cfquery name="trc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select count(*) c,sum(COUNTOFCATALOGEDITEM) ttl from #session.SpecSumTab#
				</cfquery>
				<cfif trc.c is 0>
					<cfset result='{"Result":"ERROR","Message":"No Data Found: Please try another search."}'>
					<cfreturn result>
				</cfif>
				<!----- now assign values to the "pager" variables and proceed as normal ---->
				<cfset totalRecordCount=trc.c>
				<cfset totalSpecimenCount=trc.ttl>
				<cfset qid=1>
			</cfif>
			<cfset jtStopIndex=jtStartIndex+jtPageSize>
			<cfset obj = CreateObject("component","component.docs")>
			<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				Select * from (
						Select a.*, rownum rnum From (
							select * from #session.SpecSumTab# order by #jtSorting#
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
						<cfif i is "LINKTOSPECIMENS">
		                    <cfset temp ='"LINKTOSPECIMENS":"<a target=\"_blank\" href=\"/SpecimenResults.cfm?' & theData &'\">specimens</a>"'>
						<cfelse>
							<cfset temp = '"#i#":"' & theData & '"'>
						</cfif>
						<cfset trow=listappend(trow,temp)>
					</cfloop>
					<cfset trow="{" & trow & "}">
					<cfset x=listappend(x,trow)>
				</cfloop>
				<cfset result='{"Result":"OK","Records":[' & x & '],
					"TotalRecordCount":#TotalRecordCount#,
					"TotalSpecimenCount":#totalSpecimenCount#,
					"qid":#qid#}'>
			</cfoutput>
		<cfcatch>
			<cf_logError subject="Specimen Summary Error" attributeCollection=#cfcatch#>
			<cfset result='{"Result":"ERROR","Message":"Error: #cfcatch.message#: #cfcatch.detail#"}'>
			<cfset result = REReplace(result, "\r\n|\n\r|\n|\r", "", "all")>
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>
	<!--------------------------------------------------------------------------------------------------------->
	<cffunction name="downloadSpecimenSummary" access="remote" returnformat="plain">
		<cfset  util = CreateObject("component","component.utilities")>
		<cfquery name="cols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from #session.SpecSumTab# where 1=2
		</cfquery>
		<cfset thisci=1>
		<cfset numcols=listlen(cols.columnlist)>
		<cfquery name="dla" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select
				<cfloop list="#cols.columnlist#" index="x">
					<cfif x is "LINKTOSPECIMENS">
						'#Application.serverRootURL#/SpecimenResults.cfm?' || #x# AS #x#
					<cfelse>
						#x#
					</cfif>
					<cfif thisci lt numcols>,</cfif>
					<cfset thisci=thisci+1>
				</cfloop>
			 from #session.SpecSumTab#
		</cfquery>
		<cfset csv = util.QueryToCSV2(Query=dla,Fields=dla.columnlist)>
		<cffile action = "write"
		    file = "#Application.webDirectory#/download/ArctosSpecimenSummary.csv"
	    	output = "#csv#"
	    	addNewLine = "no">
	    	<cfreturn>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------->
<cffunction name="getSpecimenResults" access="remote" returnformat="plain" queryFormat="column">
	<cfparam name="jtStartIndex" type="numeric" default="0">
	<cfparam name="jtPageSize" type="numeric" default="10">
	<cfparam name="jtSorting" type="string" default="GUID ASC">
	<cfif not isdefined("m")>
	   <cfset m=false>
	</cfif>
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
						<cfif m is true>
                            <cfset temp ='"GUID":"<div id=\"CatItem_#collection_object_id#\"><a target=\"_blank\" href=\"/m/guid/' & theData &'\">' &theData & '</a></div>"'>
						<cfelse>
                            <cfset temp ='"GUID":"<div id=\"CatItem_#collection_object_id#\"><a target=\"_blank\" href=\"/guid/' & theData &'\">' &theData & '</a></div>"'>
						</cfif>
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
		<!---- handle this asynchronously ---->
		<cfthread action="run" name="lerr">
			<cf_logError subject="specresults error" attributeCollection=#cfcatch#>
		</cfthread>

		<!----
		<cfmail subject="specresults error" to="arctos.database@gmail.com" from="srerror@arctos.database.museum" type="html">
			<cfdump var=#cfcatch#>
		</cfmail>
		---->
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
						<span class="infoLink" onclick="fetchSrchWgtVocab('#term#');">[ all vocabulary ]</span>
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
		<cfquery name="tct" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,60,0)#">
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
		<!--- is the term is in the current data, provide BOLDing ---->
		<cftry>
			<cfquery name="currentdata" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select #key# from #session.SpecSrchTab# where #key# is not null group by #key#
			</cfquery>
			<cfquery name="r2" dbtype="query">
				select v from r union all select #key# from currentdata
			</cfquery>
			<cfquery name="rtn" dbtype="query">
				select v ,count(*) m from r2 group by v order by v
			</cfquery>
		<cfcatch>
			<cfquery name="rtn" dbtype="query">
				select v ,0 m from r group by v order by v
			</cfquery>
		</cfcatch>
		</cftry>
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
	<cfif session.resultsbrowseprefs neq 1>
		<cfsavecontent variable="widget">
			<span class="likeLink" onclick="toggleSearchTerms()" id="showsearchterms">[ Show/Hide Search Terms ]</span>
		</cfsavecontent>
		<cfreturn widget>
	</cfif>
	<script>
		$(document).ready(function () {
			$("#refineResults").submit(function(event){
				event.preventDefault();
				var serializedForm = $("#refineResults").serializeArray();
				var nnvals=[];
				for(var i =0, len = serializedForm.length;i<len;i++){
					if (serializedForm[i].value.length >  0){
						nnvals.push(serializedForm[i].name + '=' + encodeURIComponent(serializedForm[i].value));
					}
				}
				var str = nnvals.join('&');
				document.location="/SpecimenResults.cfm?" + str;
			});
		});
	</script>
	<cfset  util = CreateObject("component","component.utilities")>
	<cfquery name="ssrch_field_doc" datasource="cf_dbuser" cachedwithin="#createtimespan(0,0,0,0)#">
		select * from ssrch_field_doc where SPECIMEN_QUERY_TERM=1 order by cf_variable
	</cfquery>
	<cfset stuffToIgnore="locality_remarks,specimen_event_remark,identification_remarks,made_date,Accession,guid,BEGAN_DATE,COLLECTION_OBJECT_ID,COORDINATEUNCERTAINTYINMETERS,CUSTOMID,CUSTOMIDINT,DEC_LAT,DEC_LONG,ENDED_DATE,MYCUSTOMIDTYPE,VERBATIM_DATE">
	<cfoutput>
		<cfquery name="srchcols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from #session.SpecSrchTab# where 1=2
		</cfquery>
		<CFSET KEYLIST="">
		<cfset sugntab = querynew("key,val,definition,vocab,display_text,placeholder_text,search_hint,indata")>
		<cfset idx=1>
		<cfset thisValue="">
		<cfloop list="#session.mapURL#" delimiters="&" index="kvp">
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
		<cfset thisValue="">
		<cfloop list="#srchcols.columnlist#" index="thisKey">
			<cfif not listfindnocase(stuffToIgnore,thisKey) and not listfindnocase(keylist,thisKey)>
				<cfset keylist=listappend(keylist,thisKey)>
				<cfquery name="thisMoreInfo" dbtype="query">
					select * from ssrch_field_doc where CF_VARIABLE='#lcase(thisKey)#'
				</cfquery>
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
		<cfsavecontent variable="widget">
			<span class="likeLink" onclick="toggleSearchTerms()" id="showsearchterms">[ Show/Hide Search Terms ]</span>
			<cfif session.ResultsBrowsePrefs is 1>
				<cfset thisStyle='display:block;'>
			<cfelse>
				<cfset thisStyle='display:none;'>
			</cfif>
			<a id="aboutSTWH" class="infoLink external" href="http://arctosdb.org/how-to/specimen-search-refine/" target="_blank">[ About this Widget ]</a>
			<a id="fbSWT" class="infoLink" href="/contact.cfm?ref=SpecimenResultsWidget">[ provide feedback ]</a>
			<div id="refineSearchTerms" style="#thisStyle#">
			<form name="refineResults" id="refineResults">
				<div id="ssttble_ctr">
				<table id="stermwdgtbl" border>
					<tr>
						<th>Term</th>
						<th>Value</th>
						<th>Vocabulary</th>
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
								<span class="#thisSpanClass#" id="_#sugntab.key#" title="#sugntab.DEFINITION#">#replace(sugntab.DISPLAY_TEXT," ","&nbsp;","all")#</span>
							</td>
								<td>
									<input type="text" name="#sugntab.key#" id="#sugntab.key#" value="#util.stripQuotes(URLDecode(sugntab.val))#" placeholder="#sugntab.PLACEHOLDER_TEXT#" size="50">
								</td>

								<td id="voccell_#sugntab.key#">
									<cfif len(sugntab.vocab) gt 0>
										 <span class="infoLink" onclick="fetchSrchWgtVocab('#sugntab.key#');">[ all vocabulary ]</span>
									</cfif>
									<cfif sugntab.indata gt 0>
										<span class="infoLink" onclick="fetchSrchWgtVocab('#sugntab.key#','results');">[ from results ]</span>
									</cfif>
								</td>
								<td>
									<span onclick="$('###sugntab.key#').val('');" class="likeLink">[&nbsp;clear&nbsp;]</span>&nbsp;<span onclick="$('###sugntab.key#').val('_');" class="likeLink">[&nbsp;require&nbsp;]</span>
								</td>
							</tr>
					</cfloop>
					</table>
					</div>
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
				</form>
			</div>
		</cfsavecontent>
	</cfoutput>
	<cfcatch>
		<!---- handle this asynchronously ---->
		<cfthread action="run" name="lerr">
		<cf_logError subject="specimenresults widget error" attributeCollection=#cfcatch#>
		</cfthread>
		<cfreturn "An error occurred: #cfcatch.message#">
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
	<!--- cachedwithin="#createtimespan(0,0,60,0)#"---->
	<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
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
		union
		select
			#session.flatTableName#.collection_object_id,
			media_relations.media_id
		from
			#session.flatTableName#,
			specimen_event,
			media_relations,
			collecting_event spce,
			collecting_event loce
		where
			#session.flatTableName#.collection_object_id=specimen_event.collection_object_id and
			specimen_event.collecting_event_id=spce.collecting_event_id and
			spce.locality_id=loce.locality_id and
			loce.collecting_event_id = media_relations.related_primary_key and
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
