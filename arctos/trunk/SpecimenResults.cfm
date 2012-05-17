<cfinclude template="/includes/_header.cfm">

<cfset debug=true>


<script type='text/javascript' language="javascript" src='/includes/SpecimenResults.min.js'></script>
<cfif len(session.displayrows) is 0>
	<cfset session.displayrows=20>
</cfif>
<cfhtmlhead text="<title>Specimen Results</title>">
<cfoutput>
<script type="text/javascript" language="javascript">
jQuery( function($) {
	$("##customizeButton").live('click', function(e){
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeCustomNoRefresh()');
		document.body.appendChild(bgDiv);
		var type=this.type;
		var type=$(this).attr('type');
		var dval=$(this).attr('dval');
		var theDiv = document.createElement('div');
		theDiv.id = 'customDiv';
		theDiv.className = 'customBox';		
		document.body.appendChild(theDiv);
		var guts = "/info/SpecimenResultsPrefs.cfm";
		$('##customDiv').load(guts,{},function(){
			viewport.init("##customDiv");
			viewport.init("##bgDiv");
		});		
	});
	$(".browseLink").live('click', function(e){
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeBrowse()');
		document.body.appendChild(bgDiv);
		var type=this.type;
		var type=$(this).attr('type');
		var dval=$(this).attr('dval');
		var theDiv = document.createElement('div');
		theDiv.id = 'browseDiv';
		theDiv.className = 'sscustomBox';
		theDiv.style.position="absolute";
		ih='<span onclick="closeBrowse()" class="likeLink" style="position:absolute;top:0;right:0;color:red;">Close Window</span>';
		ih+='<p>Search for ' + type + '....'
		ih+='<br>LIKE <a href="/SpecimenResults.cfm?' + type + '=' + dval + '"> ' + decodeURI(dval) + '</a>';
		ih+='<br>IS <a href="/SpecimenResults.cfm?' + type + '==' + dval + '"> ' + decodeURI(dval) + '</a></p>';
		if (type=='scientific_name'){
			ih+='<p><a href="/name/' + dval + '"> ' + decodeURI(dval) + ' taxonomy</a></p>';
		}
		theDiv.innerHTML=ih;
		document.body.appendChild(theDiv);
		viewport.init("##browseDiv");
		//viewport.init("##bgDiv");
	});
});
function closeBrowse(){
	var theDiv = document.getElementById('browseDiv');
	document.body.removeChild(theDiv);
	var theDiv = document.getElementById('bgDiv');
	document.body.removeChild(theDiv);
}
function removeHelpDiv() {
	if (document.getElementById('helpDiv')) {
		jQuery('##helpDiv').remove();
	}
}
</script>
</cfoutput>
<div id="loading" class="status">
	Page loading....
</div>
<cfflush>
<cfoutput>
<cfif not isdefined("displayrows")>
	<cfset displayrows = session.displayrows>
</cfif>
<cfif not isdefined("SearchParams")>
	<cfset SearchParams = "">
</cfif>
<cfif not isdefined("sciNameOper")>
	<cfset sciNameOper = "LIKE">
</cfif>
<cfif not isdefined("oidOper")>
	<cfset oidOper = "LIKE">
</cfif>
<cfif not isdefined("mapurl")>
	<cfset mapurl = "null">
</cfif>
<cfif action contains ",">
	<cfset action = left(action,find(",",action)-1)>
</cfif>
<cfif not isdefined("session.resultColumnList")>
	<cfset session.resultColumnList=''>
</cfif>
<cfquery name="r_d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select * from cf_spec_res_cols order by disp_order
</cfquery>
<cfquery name="reqd" dbtype="query">
	select * from r_d where category='required'
</cfquery>
<cfloop query="reqd">
	<cfif not ListContainsNoCase(session.resultColumnList,COLUMN_NAME)>
		<cfset session.resultColumnList = ListAppend(session.resultColumnList, COLUMN_NAME)>
	</cfif>
</cfloop>
<cfset basSelect = " SELECT #session.flatTableName#.collection_object_id">
<cfif len(session.CustomOtherIdentifier) gt 0>
	<cfset basSelect = "#basSelect# 
		,concatSingleOtherId(#session.flatTableName#.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
		'#session.CustomOtherIdentifier#' as myCustomIdType,
		to_number(ConcatSingleOtherIdInt(#session.flatTableName#.collection_object_id,'#session.CustomOtherIdentifier#')) AS CustomIDInt">
</cfif>
<cfloop query="r_d">
	<cfif left(column_name,1) is not "_" and (
		ListContainsNoCase(session.resultColumnList,column_name) OR category is 'required')>
		<cfset basSelect = "#basSelect#,#evaluate("sql_element")# #column_name#">
	</cfif>
</cfloop>
<cfif ListContainsNoCase(session.resultColumnList,"_elev_in_m")>
	<cfset basSelect = "#basSelect#,min_elev_in_m,max_elev_in_m">
</cfif>
<cfif ListContainsNoCase(session.resultColumnList,"_day_of_ymd")>
	<cfset basSelect = "#basSelect#,getYearCollected(#session.flatTableName#.began_date,#session.flatTableName#.ended_date) YearColl,
		getMonthCollected(#session.flatTableName#.began_date,#session.flatTableName#.ended_date) MonColl,
		getDayCollected(#session.flatTableName#.began_date,#session.flatTableName#.ended_date) DayColl">
</cfif>
<cfif ListContainsNoCase(session.resultColumnList,"_original_elevation")>
	<cfset basSelect = "#basSelect#,MINIMUM_ELEVATION,MAXIMUM_ELEVATION,ORIG_ELEV_UNITS">
</cfif> 
	<cfset basFrom = " FROM #session.flatTableName#">
	<cfset basJoin = "">
	<cfset basWhere = " WHERE #session.flatTableName#.collection_object_id IS NOT NULL ">	

	<cfset basQual = "">
	<cfset mapurl="">
	<cfinclude template="includes/SearchSql.cfm">
	<!--- wrap everything up in a string --->
	<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual#">
	
	<cfset sqlstring = replace(sqlstring,"flatTableName","#session.flatTableName#","all")>
	<!--- require some actual searching --->
	<cfset srchTerms="">
	<cfloop list="#mapurl#" delimiters="&" index="t">
		<cfset tt=listgetat(t,1,"=")>
		<cfset srchTerms=listappend(srchTerms,tt)>
	</cfloop>
	<!--- remove standard criteria that kill Oracle... --->
	<cfif listcontains(srchTerms,"ShowObservations")>
		<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'ShowObservations'))>
	</cfif>
	<cfif listcontains(srchTerms,"collection_id")>
		<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'collection_id'))>
	</cfif>
	<!--- ... and abort if there's nothing left --->
	<cfif len(srchTerms) is 0>
		<CFSETTING ENABLECFOUTPUTONLY=0>			
		<font color="##FF0000" size="+2">You must enter some search criteria!</font>	  
		<cfabort>
	</cfif>
<cfset thisTableName = "SearchResults_#left(session.sessionKey,10)#">	
<!--- try to kill any old tables that they may have laying around --->
<cftry>
	<cfquery name="die" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		drop table #session.SpecSrchTab#
	</cfquery>
	<cfcatch><!--- not there, so what? --->
	</cfcatch>
</cftry>
<!---- build a temp table --->
<cfset checkSql(SqlString)>
<cfif isdefined("debug") and debug is true>
	#preserveSingleQuotes(SqlString)#
</cfif>
<cfset SqlString = "create table #session.SpecSrchTab# AS #SqlString#">
	<cfquery name="buildIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preserveSingleQuotes(SqlString)#
	</cfquery>
<form name="defaults">
	<input type="hidden" name="killrow" id="killrow" value="#session.killrow#">
	<input type="hidden" name="displayrows" id="displayrows" value="#session.displayrows#">
	<input type="hidden" name="action" id="action" value="#action#">
	<input type="hidden" name="mapURL" id="mapURL" value="#mapURL#">
	<cfset session.mapURL = mapURL>
	<cfif isdefined("transaction_id")>
			<input type="hidden" name="transaction_id" id="transaction_id" value="#transaction_id#">
	</cfif>
	<cfif isdefined("loan_request_coll_id")>
			<input type="hidden" name="loan_request_coll_id" id="loan_request_coll_id" value="#loan_request_coll_id#">
	</cfif>
</form>
	<cfquery name="summary" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct collection_object_id from #session.SpecSrchTab#
	</cfquery>
<cfif summary.recordcount is 0>
	<script>
		hidePageLoad();
	</script>
	<div>
		Your query returned no results.
		<ul>
			<li>Check your form input, or use the Clear Form button to start over.</li>
			<li>
				If you searched by taxonomy, consult <a href="/TaxonomySearch.cfm" class="novisit">Arctos Taxonomy</a>.
				Taxa are often synonymized and revised, and may not be consistent across collections. Previous Identifications, 
				which are separate from the taxonomy used in Identifications, may be located using the scientific name 
				"is/was/cited/related" option.
			</li>
			<li>
				Try broadening your search criteria. Try the next-higher geographic element, remove criteria, or use a substring match. 
				Don't assume we've accurately or predictably recorded data.
			</li>
			<li>
				 Not all specimens have coordinates - the spatial query tool will not locate all specimens.
			</li>
			<li>
				Use dropdowns or partial word matches instead of text strings, which may be entered in unexpected ways. 
				"Doe" is a good choice for a collector if "John P. Doe" didn't match anything, for example.
			</li>
			<li>
				Read the documentation for individual search fields (click the title of the field to see documentation). 
				Arctos fields may not be what you expect them to be.
			</li>
			<li>
				<a href="/googlesearch.cfm">Try our Google search</a>. Not everything in Arctos 
				is indexed in Google, but it may provide a starting point to locate specific items.  		
			</li>
			<li>
				<a href="/contact.cfm">Contact us</a> if you still can't find what you need. We'll help if we can.
			</li>
		</ul>
	</div>
	<cfabort>
</cfif>
<cfset collObjIdList = valuelist(summary.collection_object_id)>
<script>
	hidePageLoad();
</script>
<cfquery name="mappable" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select count(distinct(collection_object_id)) cnt from #session.SpecSrchTab# where dec_lat is not null and dec_long is not null
</cfquery>

<form name="saveme" id="saveme" method="post" action="saveSearch.cfm" target="myWin">
	<input type="hidden" name="returnURL" value="#Application.ServerRootUrl#/SpecimenResults.cfm?#mapURL#" />
</form>
<!--- clean up things we'll let them sort by --->
<cfset resultList = session.resultColumnList>
<cfset tabooItems="institution_acronym,collection_id,collection_cde">
<cfloop list="#tabooItems#" index="item">
		<cfif ListContainsNoCase(resultList,item)>
		<cfset resultList = ListDeleteAt(resultList, ListFindNoCase(resultList,item))>
	</cfif>
</cfloop>
<!--- things that start with _ require special handling here as well --->
<!--- TAG:SORTRESULT
if you have an item that starts with _, you must change how it is sorted!
For example, if your item cannot be sorted, then remove it from resultList.
If your item needs to be sorted in a special way, then do that here. --->
<cfif ListContainsNoCase(resultList,"_elev_in_m")>
<cfflush>
	<cftry>
	<cfset resultList = listappend(resultList,"min_elev_in_m")>
	<cfset resultList = listappend(resultList,"max_elev_in_m")>
	<cfset resultList = ListDeleteAt(resultList, ListFindNoCase(resultList,"_elev_in_m"))>
	<cfcatch></cfcatch>
	</cftry>
</cfif>
<cfif ListContainsNoCase(resultList,"_original_elevation")>
	<cftry>
	<cfset resultList = listappend(resultList,"minimum_elevation")>
	<cfset resultList = listappend(resultList,"maximum_elevation")>
	<cfset resultList = listappend(resultList,"orig_elev_units")>
	<cfset resultList = ListDeleteAt(resultList, ListFindNoCase(resultList,"_original_elevation"))>
	<cfcatch></cfcatch>
	</cftry>
</cfif>
<form name="controls">
	<!--- keep stuff around for JS to get at --->
	<input type="hidden" name="resultList" id="resultList" value="#resultList#">
	<input type="hidden" name="customID" id="customID" value="#session.customOtherIdentifier#">
	<input type="hidden" name="result_sort" id="result_sort" value="#session.result_sort#">
	<input type="hidden" name="displayRows" id="displayRows" value="#session.displayRows#">
<strong>#mappable.cnt#</strong> of these <strong>#summary.recordcount#</strong> records have coordinates and can be displayed with 
			<span class="controlButton"
				onclick="window.open('/bnhmMaps/bnhmMapData.cfm?#mapurl#','_blank');">BerkeleyMapper</span>
			<span class="controlButton"
				onclick="window.open('/bnhmMaps/bnhmMapData.cfm?showRangeMaps=true&#mapurl#','_blank');">BerkeleyMapper+Rangemaps</span>
			<span class="infoLink" onclick="getDocs('maps');">
				What's this?
			</span>
			<a href="bnhmMaps/kml.cfm">Google Earth/Maps</a>
			<a href="SpecimenResultsHTML.cfm?#mapurl#" class="infoLink">&nbsp;&nbsp;&nbsp;Problems viewing this page? Click for HTML version</a>
			&nbsp;&nbsp;&nbsp;<a class="infoLink" href="/info/reportBadData.cfm?collection_object_id=#collObjIdList#">Report Bad Data</a>	
<div style="border:2px solid blue;" id="ssControl">
<cfif isdefined("transaction_id")>
	<a href="Loan.cfm?action=editLoan&transaction_id=#transaction_id#">back to loan</a>
</cfif>
<table border="0">
	<tr>
		<td>
		<cfset numPages= ceiling(summary.recordcount/session.displayrows)>
		<cfset loopTo=numPages-2>
		<label for="page_record">Records...</label>
		<select name="page_record" id="page_record" size="1" onchange="getSpecResultsData(this.value);">
			<cfloop from="0" to="#loopTo#" index="i">
				<cfset bDispVal = (i * session.displayrows + 1)>
				<cfset eDispval = (i + 1) * session.displayrows>
				<option value="#bDispVal#,#session.displayrows#">#bDispVal# - #eDispval#</option>
			</cfloop>
			<!--- last set of records --->
			<cfset bDispVal = ((loopTo + 1) * session.displayrows )+ 1>
			<cfset eDispval = summary.recordcount>
			<option value="#bDispVal#,#session.displayrows#">#bDispVal# - #eDispval#</option>
			<!--- all records --->
			<option value="1,#summary.recordcount#">1 - #summary.recordcount#</option>
		</select>
		</td>
		<td nowrap="nowrap">
			<label for="orderBy1">Order by...</label>
			<select name="orderBy1" id="orderBy1" size="1" onchange="changeresultSort(this.value)">
				<!--- prepend their CustomID and integer sort of their custom ID to the list --->
				<cfif len(session.CustomOtherIdentifier) gt 0>
					<option <cfif session.result_sort is "custom_id">selected="selected" </cfif>value="CustomID">#session.CustomOtherIdentifier#</option>
					<option value="CustomIDInt">#session.CustomOtherIdentifier# (INT)</option>
				</cfif>
				<cfloop list="#resultList#" index="i">
					<option <cfif #session.result_sort# is #i#>selected="selected" </cfif>value="#i#">#i#</option>
				</cfloop>
			</select>			
		</td>
		<td>
			<label for="orderBy2">...then order by</label>
			<select name="orderBy2" id="orderBy2" size="1">
				<cfloop list="#resultList#" index="i">
					<option value="#i#">#i#</option>
				</cfloop>
			</select>
		</td>
		<td>
			<label for="">&nbsp;</label>
			<span class="controlButton"
				onclick="var pr=document.getElementById('page_record');
					var c=pr.value;
					var obv=document.getElementById('orderBy1').value + ',' + document.getElementById('orderBy2').value;
					if (c=='1,#summary.recordcount#')
						{var numRec=#summary.recordcount#}else{var numRec=#session.displayrows#;pr.selectedIndex=0;};
						getSpecResultsData(1,numRec,obv,'ASC');">&uarr;</span>
		</td>
		<td>
			<label for="">&nbsp;</label>
			<span class="controlButton"
				onclick="var pr=document.getElementById('page_record');
					var c=pr.value;
					var obv=document.getElementById('orderBy1').value + ',' + document.getElementById('orderBy2').value;
					if (c=='1,#summary.recordcount#')
						{var numRec=#summary.recordcount#}else{var numRec=#session.displayrows#;pr.selectedIndex=0;};
					getSpecResultsData(1,numRec,obv,'DESC');">&darr;</span>
		</td>
		<td><div style="width:100px;">&nbsp;</div></td>
		<td>
			<label for="">&nbsp;</label>
			<input type="hidden" name="killRowList" id="killRowList">
			<span id="removeChecked"
				style="display:none;"
				class="controlButton redButton"
				onclick="removeItems();">Remove&nbsp;Checked&nbsp;Rows</span>	
		</td>
		<td>
			<label for="">&nbsp;</label>
			<span class="controlButton"	id="customizeButton">Customize&nbsp;Form</span>
			<!----onclick="openCustomize();"---->
		</td>
		<td>
			<label for="">&nbsp;</label>
			<span class="controlButton"
				onclick="window.open('/SpecimenResultsDownload.cfm?tableName=#session.SpecSrchTab#','_blank');">Download</span>
		</td>
		<td>
			<label for="">&nbsp;</label>
			<span class="controlButton"
				onclick="saveSearch('#Application.ServerRootUrl#/SpecimenResults.cfm?#mapURL#');">Save&nbsp;Search</span>
		</td>
		<td nowrap="nowrap">
			<cfif (isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user"))>					
				<label for="goWhere">Manage...</label>
				<select name="goWhere" id="goWhere" size="1">
					<option value="">::Change Stuff::</option>
					<option value="/Encumbrances.cfm">
						Encumbrances
					</option>
					<option value="/multiIdentification.cfm">
						Identification
					</option>
					<option value="/multiAgent.cfm">
						Agents
					</option>
					<option value="/findContainer.cfm?showControl=1">
						Part Locations
					</option>
					<option value="/bulkCollEvent.cfm">
						Collecting Events
					</option>
					<option value="/addAccn.cfm">
						Accession
					</option>
					<option value="/compDGR.cfm">
						MSB<->DGR
					</option>
					<option value="/tools/bulkPart.cfm">
						Modify Parts
					</option>
					
					<option value="">::Print Stuff::</option>
					<option value="/Reports/report_printer.cfm?report=uam_mamm_vial">
						UAM Mammals Vial Labels
					</option>
					<option value="/Reports/report_printer.cfm?report=uam_mamm_box">
						UAM Mammals Box Labels
					</option>					
					<option value="/Reports/report_printer.cfm?report=MSB_vial_label">
						MSB Mammals Vial Labels
					</option>
					<cfif isdefined('permit_num') and len(permit_num) gt 0>
						<option value="/Reports/permit.cfm">
							MVZ Permit Report
						</option>
					</cfif>
					<option value="/Reports/kenai.cfm">
						download bug .tex
					</option>
					<option value="/Reports/print_nk.cfm">
						Print NK pages
					</option>
					<option value="/Reports/report_printer.cfm?report=ala_label">
						ALA Labels
					</option>
					<option value="/bnhmMaps/SpecimensByLocality.cfm">
						Map By Locality
					</option>
					<option value="/info/part_data_download.cfm">
						Parts table/download
					</option>
                    <option value="/SpecimenResultsDownload.cfm?action=bulkloaderFormat">
						Download for Bulkloader
					</option>
                    <option value="/Reports/report_printer.cfm">
						Print Any Report
					</option>
				</select>
				<input type="button" value="Go" class="lnkBtn" onClick="reporter();">
			</cfif>
		</td>
	</tr>
</table>
</div>
</form>

<div id="resultsGoHere"></div>
<script language="javascript" type="text/javascript">
	getSpecResultsData(1,#session.displayrows#);
</script>
<script language="javascript" type="text/javascript">
	function reporter() {
		var f=document.getElementById('goWhere').value;
		var t='#session.SpecSrchTab#';
		var o1=document.getElementById('orderBy1').value;
		var o2=document.getElementById('orderBy2').value;
		var s=o1 + ',' + o2;
		var u = f;
		var sep="?";
		if (f.indexOf('?') > 0) {
			sep='&';
		}
		var lla='#collObjIdList#'.split(',');
		var i;
		if (lla.length>999){
			i='';
		} else {
			i='#collObjIdList#';
		}
		u += sep + 'collection_object_id=' + i;
		u += '&table_name=' + t;
		u += '&sort=' + s;
		var reportWin=window.open(u);
	}
</script>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
