<cfinclude template="/includes/_header.cfm">
<cfhtmlhead text="<title>Specimen Results</title>">
<!--- must process the title before FLUSHing 
<cf_get_header collection_id="#exclusive_collection_id#">
--->
<script type='text/javascript' src='/includes/_specimenResults.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<script type='text/javascript' src='/includes/_myArctos.js'></script>
<cfoutput>
<script type="text/javascript" language="javascript">
jQuery( function($) {

	$("##sPrefs").click(function(e){
		var id=this.id;
		var theDiv = document.createElement('div');
		theDiv.id = 'helpDiv';
		theDiv.className = 'helpBox';
		theDiv.innerHTML='<span onclick="removeHelpDiv()" class="docControl">X</span>';

		theDiv.innerHTML+='<label for="displayRows">Rows Per Page</label>';
		theDiv.innerHTML+='<select name="displayRows" id="displayRows" onchange="this.className=' + "'red'" + ';changedisplayRows(this.value);" size="1"><option  <cfif #session.displayRows# is "10"> selected </cfif> value="10">10</option><option  <cfif #session.displayRows# is "20"> selected </cfif> value="20" >20</option><option  <cfif #session.displayRows# is "50"> selected </cfif> value="50">50</option><option  <cfif #session.displayRows# is "100"> selected </cfif> value="100">100</option></select>';
		var resultList=document.getElementById('resultList').value;
		var customID=document.getElementById('customID').value;
		var result_sort=document.getElementById('result_sort').value;
		var displayRows=document.getElementById('displayRows').value;		
		
		theDiv.innerHTML+='<label for="result_sort">Primary Sort</label>';
		var temp='<select name="result_sort" id="result_sort" onchange="this.className=' + "'red'" + ';changeresultSort(this.value);" size="1">';
		if (customID.length > 0) {
			temp+='<option value="' + customID + '">' + customID + '</option>';			
		}
		var rAry=resultList.split(',');
		for (i = 0; i < rAry.length; i++) {
			temp+='<option value="' + rAry[i] + '">' + rAry[i] + '</option>';
		}	
		temp+='</select>';
		theDiv.innerHTML+=temp;
		document.body.appendChild(theDiv);
		document.getElementById('result_sort').value=result_sort;
		document.getElementById('displayRows').value=displayRows;
		$("##helpDiv").css({position:"absolute", top: e.pageY, left: e.pageX});

	});
});
function removeHelpDiv() {
	if (document.getElementById('helpDiv')) {
		$('##helpDiv').remove();
	}
}
</script>
</cfoutput>
<div id="loading" style="position:absolute;top:50%;right:50%;z-index:999;background-color:green;color:white;font-size:large;font-weight:bold;padding:15px;">
	Page loading....
</div>
<cfflush>
	<cfoutput>
<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>
	<cfset flatTableName = "flat">
<cfelse>
	<cfset flatTableName = "filtered_flat">
</cfif>
<cfif not isdefined("detail_level") OR len(#detail_level#) is 0>
	<cfif isdefined("session.detailLevel") AND #session.detailLevel# gt 0>
		<cfset detail_level = #session.detailLevel#>
	<cfelse>
		<cfset detail_level = 1>
	</cfif>	
</cfif>
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
<cfif #action# contains ",">
	<cfset action = #left(action,find(",",action)-1)#>
</cfif>
<cfif #detail_level# contains ",">
	<cfset detail_level = #left(detail_level,find(",",detail_level)-1)#>
</cfif>

<!--- make sure session.resultColumnList has all the required stuff here --->
<cfif not isdefined("session.resultColumnList")>
	<cfset session.resultColumnList=''>
</cfif>
<cfquery name="r_d" datasource="#Application.web_user#">
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


<!---

---->
<cfset basSelect = " SELECT distinct #flatTableName#.collection_object_id">
<cfif len(#session.CustomOtherIdentifier#) gt 0>
		<cfset basSelect = "#basSelect# 
			,concatSingleOtherId(#flatTableName#.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			'#session.CustomOtherIdentifier#' as myCustomIdType,
			to_number(ConcatSingleOtherIdInt(#flatTableName#.collection_object_id,'#session.CustomOtherIdentifier#')) AS CustomIDInt">
	</cfif>
<cfloop query="r_d">
	<cfif left(column_name,1) is not "_" and (
		ListContainsNoCase(session.resultColumnList,column_name) OR category is 'required')>
		<cfset basSelect = "#basSelect#,#evaluate("sql_element")# #column_name#">
	</cfif>
</cfloop>

<!--- things that start with _ need special handling 
they also need special handling at TAG:SORTRESULT (do find in this document)--->
<!--- this special handling is how to add it to the select statement --->
<cfif ListContainsNoCase(session.resultColumnList,"_elev_in_m")>
	<cfset basSelect = "#basSelect#,min_elev_in_m,max_elev_in_m">
</cfif>
<cfif ListContainsNoCase(session.resultColumnList,"_original_elevation")>
	<cfset basSelect = "#basSelect#,MINIMUM_ELEVATION,MAXIMUM_ELEVATION,ORIG_ELEV_UNITS">
</cfif> 
<cfif ListContainsNoCase(session.resultColumnList,"_gref_collnum")>
	<!---<cfset basSelect = "#basSelect#,concatGrefLinksCollObj(#Application.gref_base_url#,#flatTableName#.collection_object_id) as gref_collnum">--->
	<!---TODO: Implement this in media table so that you no longer have to rely on this hardcoded link generation. --->
	<cfset basSelect = "#basSelect#,(select the_link from (
select
		'http://bg.berkeley.edu/gref/session.html?pageid=' || gref_roi_ng.page_id 
	  || Chr(38) ||'publicationid=' || book_section.publication_id 
	  || Chr(38) || 'otherid=' || #flatTableName#.collection_object_id
	  || Chr(38) || 'otheridtype=' || gref_roi_value_ng.collection_object_id as the_link, 
          section_page_order, 
          min(section_page_order)
		from
		  gref_roi_ng, gref_roi_value_ng, book_section, page, #flatTableName#
		where
		  book_section.book_id = gref_roi_ng.publication_id
		  and gref_roi_value_ng.id = gref_roi_ng.ROI_VALUE_NG_ID
		  and gref_roi_ng.section_number = book_section.book_section_order
                  and page.page_id = gref_roi_ng.page_id
                  and page.PUBLICATION_ID = book_section.PUBLICATION_ID
and gref_roi_value_ng.collection_object_id = #flatTableName#.collection_object_id
group by gref_roi_ng.page_id, book_section.publication_id, gref_roi_value_ng.collection_object_id , section_page_order, #flatTableName#.collection_object_id
having min(section_page_order) = section_page_order)) as gref_collnum">
</cfif>

	
	<cfset basFrom = " FROM #flatTableName#">
	<cfset basJoin = "INNER JOIN cataloged_item ON (#flatTableName#.collection_object_id =cataloged_item.collection_object_id)">
	<cfset basWhere = " WHERE #flatTableName#.collection_object_id IS NOT NULL ">	

	<cfset basQual = "">
	<cfset mapurl="">
	<cfinclude template="includes/SearchSql.cfm">
	<!--- wrap everything up in a string --->
	<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual#">
	
	<cfset sqlstring = replace(sqlstring,"flatTableName","#flatTableName#","all")>	

	<!--- define the list of search paramaters that we need to get back here --->

		<cfif len(#basQual#) is 0 AND basFrom does not contain "binary_object">
			<CFSETTING ENABLECFOUTPUTONLY=0>
			
			<font color="##FF0000" size="+2">You must enter some search criteria!</font>	  
			<cfabort>
		</cfif>

<!-------------------------- dlkm debug -----------------<--------------------->	
	<cfif isdefined("session.username") and (#session.username# is "dlm" or #session.username# is "dusty" or #session.username# is "lam" or #session.username# is "pdevore")>
		
	<cfoutput>
	#preserveSingleQuotes(SqlString)#
	</cfoutput>
	</cfif>
	
	<!-------------------------- / dlm debug ----------------------
	
	<cfif isdefined("session.username") and (#session.username# is "dlm" or #session.username# is "dusty")>
		
	<cfoutput>
	--#session.username#--
	#preserveSingleQuotes(SqlString)#
	<br>ReturnURL: #returnURL#
	<br>MapURL: #mapURL#
	<cfdump var=#variables#>
	</cfoutput>
	</cfif>
	
	<cfdump var=#variables#>
<cfdump var=#client#>
<cfoutput>
	#preserveSingleQuotes(SqlString)#
	</cfoutput>
---------------->

<cfset thisTableName = "SearchResults_#cfid#_#cftoken#">	
		</cfoutput>
<!--- try to kill any old tables that they may have laying around --->
<cftry>
	<cfquery name="die" datasource="#Application.web_user#">
		drop table #thisTableName#
	</cfquery>
	<cfcatch><!--- not there, so what? ---></cfcatch>
</cftry>
<!---- build a temp table --->
<Cfset SqlString = "create table #thisTableName# AS #SqlString#">



<cfquery name="buildIt" datasource="#Application.web_user#">
	#preserveSingleQuotes(SqlString)#
</cfquery>
<cfoutput>
<form name="defaults">
	<input type="hidden" name="killrow" id="killrow" value="#session.killrow#">
	<input type="hidden" name="displayrows" id="displayrows" value="#session.displayrows#">
	<input type="hidden" name="action" id="action" value="#action#">
	<input type="hidden" name="mapURL" id="mapURL" value="#mapURL#">
	<cfif isdefined("transaction_id")>
			<input type="hidden" name="transaction_id" id="transaction_id" value="#transaction_id#">
	</cfif>
	<cfif isdefined("loan_request_coll_id")>
			<input type="hidden" name="loan_request_coll_id" id="loan_request_coll_id" value="#loan_request_coll_id#">
	</cfif>
	
</form>
<cfquery name="summary" datasource="#Application.web_user#">
	select distinct collection_object_id from #thisTableName#
</cfquery>
<cfif #summary.recordcount# is 0>
	<div id="loading" style="position:absolute;top:50%;right:50%;z-index:999;background-color:green;color:white;font-size:large;font-weight:bold;padding:15px;">
		Your query returned no results.
		<ul>
			<li>
				If you searched by taxonomy, please consult <a href="/TaxonomySearch.cfm" target="#session.target#" class="novisit">Arctos Taxonomy</a>.
			</li>
			<li>
				Try broadening your search criteria. Try the next-higher geographic element, remove criteria, etc. Don't assume we've accurately or predictably recorded data!
			</li>
			<li>
				Use dropdowns or partial word matches instead of text strings, which may be entered in unexpected ways. "Doe" is a good choice for a collector if "John P. Doe" didn't match anything, for example.
			</li>
			<li>
				Read the documentation for individual search fields (click the title of the field to see documentation). Arctos fields may not be what you expect them to be.
			</li>
		</ul>
	</div>
	<cfabort>
</cfif>
<cfset collObjIdList = valuelist(summary.collection_object_id)>
<script>
	hidePageLoad();
</script>
<cfquery name="mappable" datasource="#Application.web_user#">
	select count(distinct(collection_object_id)) cnt from #thisTableName# where dec_lat is not null and dec_long is not null
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
<cfif ListContainsNoCase(resultList,"_gref_collnum")>
	<cftry>
		<cfset resultList = ListDeleteAt(resultList, ListFindNoCase(resultList,"_gref_collnum"))>
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
				onmouseover="this.className='controlButton btnhov'" 
				onmouseout="this.className='controlButton'"
				onclick="window.open('/bnhmMaps/bnhmMapData.cfm?#mapurl#','_blank');">BerkeleyMapper</span>			
			<span class="infoLink" onclick="getDocs('maps');">
				What's this?
			</span>
			<a href="bnhmMaps/kml.cfm?table_name=#thisTableName#">Google Earth/Maps</a>
			<a href="SpecimenResultsHTML.cfm?#mapurl#" class="infoLink">&nbsp;&nbsp;&nbsp;Problems viewing this page? Click for HTML version</a>
			&nbsp;&nbsp;&nbsp;<a class="infoLink" href="/info/reportBadData.cfm?collection_object_id=#collObjIdList#">Report Bad Data</a>	
<div style="border:2px solid blue;">
<cfif isdefined("transaction_id")>
	<a href="Loan.cfm?action=editLoan&transaction_id=#transaction_id#">back to loan</a>
</cfif>

<table border="0">
	<tr>
		<td>
		<!--- the function accepts:
				startrow <- first record of the page we want to view
				numRecs <- session.displayrows
				orderBy < current values from dropdown
		--->
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
			<label for="orderBy1">Primary Order</label>
			<select name="orderBy1" id="orderBy1" size="1">
				<!--- prepend their CustomID and integer sort of their custom ID to the list --->
				<cfif isdefined("customOtherIdentifier") and len(#session.CustomOtherIdentifier#) gt 0>
					<option <cfif #session.result_sort# is "custom_id">selected="selected" </cfif>value="CustomID">#session.CustomOtherIdentifier#</option>
					<option value="CustomIDInt">#session.CustomOtherIdentifier# (INT)</option>
				</cfif>
				<cfloop list="#resultList#" index="i">
					<option <cfif #session.result_sort# is #i#>selected="selected" </cfif>value="#i#">#i#</option>
				</cfloop>
			</select>
			
		</td>
		<td>
			<label for="orderBy2">Secondary Order</label>
			<select name="orderBy2" id="orderBy2" size="1">
				<cfloop list="#resultList#" index="i">
					<option value="#i#">#i#</option>
				</cfloop>
			</select>
		</td>
		<td>
			<label for="">&nbsp;</label>
			<span class="controlButton" 
				onmouseover="this.className='controlButton btnhov'" 
				onmouseout="this.className='controlButton'"
				onclick="document.getElementById('page_record').selectedIndex=0;
					var obv=document.getElementById('orderBy1').value + ',' + document.getElementById('orderBy2').value;
					getSpecResultsData(1,#session.displayrows#,obv,'ASC');">&uarr;</span>
		</td>
		<td>
			<label for="">&nbsp;</label>
			<span class="controlButton"
				onmouseover="this.className='controlButton btnhov'" 
				onmouseout="this.className='controlButton'"
				onclick="document.getElementById('page_record').selectedIndex=0;
					var obv=document.getElementById('orderBy1').value + ',' + document.getElementById('orderBy2').value;
					getSpecResultsData(1,#session.displayrows#,obv,'DESC');">&darr;</span>
		</td>
		<td>
			<span id="sPrefs" class="infoLink">Save...</span>
		</td>
		<td><div style="width:100px;">&nbsp;</div></td>
		<td>
			<label for="">&nbsp;</label>
			<input type="hidden" name="killRowList" id="killRowList">
			<span id="removeChecked"
				style="display:none;"
				class="controlButton" 
				onmouseover="this.className='controlButton btnhov'" 
				onmouseout="this.className='controlButton'"
				onclick="removeItems();">Remove&nbsp;Checked</span>	
		</td>
		<td>
			<label for="">&nbsp;</label>
			<span class="controlButton" 
				onmouseover="this.className='controlButton btnhov'" 
				onmouseout="this.className='controlButton'"
				onclick="openCustomize();">Customize&nbsp;Form</span>	
		</td>
		<td>
			<label for="">&nbsp;</label>
			<span class="controlButton"
				onmouseover="this.className='controlButton btnhov'" 
				onmouseout="this.className='controlButton'"
				onclick="window.open('/SpecimenResultsDownload.cfm?tableName=#thisTableName#','_blank');">Download</span>
		</td>
		<td>
			<label for="">&nbsp;</label>
			<span class="controlButton"
				onmouseover="this.className='controlButton btnhov'" 
				onmouseout="this.className='controlButton'"
				onclick="saveSearch();">Save&nbsp;Search</span>
		</td>
		<td nowrap="nowrap">
			<cfif summary.recordcount lt 1000 and (isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user"))>					
				<label for="goWhere">Manage...</label>
				<select name="goWhere" id="goWhere" size="1">
					<option value="Encumbrances.cfm">
						Encumbrances
					</option>
					<option value="UamMammalVialLabels_pdffile.cfm">
						UAM Mammals Vial Labels
					</option>
					<option value="/Reports/mammalLabels.cfm">
						UAM Mammals Box Labels
					</option>
					<option value="MSBMammLabels.cfm">
						MSB Mammals Labels
					</option>
					<!---<option value="/Reports/msbLabels.cfm?collection_object_id=#collObjIdList#">
						MSB  Labels
					</option>--->
                    <option value="/Reports/msbLabelDataDown.cfm">
						Label Data Download
					</option>
					<option value="narrowLabels.cfm">
						MVZ narrow Labels
					</option>
					<option value="wideLabels.cfm">
						MVZ wide Labels
					</option>
					<cfif isdefined('accn_number') and len(accn_number) gt 0>
						<option value="Reports/ledger.cfm">
							MVZ Ledger
						</option>
					</cfif>
					<cfif isdefined('permit_num') and len(permit_num) gt 0>
						<option value="Reports/permit.cfm">
							MVZ Permit Report
						</option>
					</cfif>
					<option value="tissueParts.cfm">
						Flag Parts as Tissues
					</option>
					<option value="editIdentification.cfm">
						Identification
					</option>
					<option value="location_tree.cfm">
						Part Locations
					</option>
					<option value="bulkCollEvent.cfm">
						Collecting Events
					</option>
					<option value="addAccn.cfm">
						Accession
					</option>
					<option value="compDGR.cfm">
						MSB<->DGR
					</option>
					<option value="/Reports/print_nk.cfm">
						Print NK pages
					</option>
					<option value="/Reports/report_printer.cfm?report=ala_label">
						ALA Labels
					</option>
					<option value="/bnhmMaps/SpecimensByLocality.cfm?table_name=#thisTableName#">
						Map By Locality
					</option>
					<option value="/tools/bulkPart.cfm?table_name=#thisTableName#">
						Add Parts
					</option>
                    <option value="/Reports/report_printer.cfm?collection_object_id=#collObjIdList#">
						Print Any Report
					</option>
				</select>
				<input type="button" 
					value="Go" 
					class="lnkBtn"
		   			onmouseover="this.className='lnkBtn btnhov'" 
					onmouseout="this.className='lnkBtn'"
					onClick="reporter();">
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
	var i='#collObjIdList#';
	var t='#thisTableName#';
	var o1=document.getElementById('orderBy1').value;
	var o2=document.getElementById('orderBy2').value;
	var s=o1 + ',' + o2;
	var u = f;
	var sep="?";
	if (f.indexOf('?') > 0) {
		sep='&';
	}
	u += sep + 'collection_object_id=' + i;
	u += '&table_name=' + t;
	u += '&sort=' + s;
	//alert(u);	
	var reportWin=window.open(u,'#session.target#');
}
</script>
</cfoutput>
<cf_get_footer collection_id="#exclusive_collection_id#">
