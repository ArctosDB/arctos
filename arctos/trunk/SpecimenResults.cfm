<cfinclude template="/includes/_header.cfm">
<cfif not isdefined("session.RESULTSBROWSEPREFS")>
	<cfset session.RESULTSBROWSEPREFS=0>
</cfif>
<cfset title="Specimen Results">
<cfif not isdefined("session.srmapclass") or len(session.srmapclass) is 0>
	<cfset session.srmapclass='smallmap'>
</cfif>
<script type='text/javascript' language="javascript" src='/includes/jtable/jquery.jtable.min.js'></script>
<script type='text/javascript' language="javascript" src='/includes/SpecimenResults.js'></script>

<link rel="stylesheet" title="lightcolor-blue"  href="/includes/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">



<cfhtmlhead text='<script src="http://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&sensor=false&libraries=places,geometry" type="text/javascript"></script>'>


<style>
 .ssw_sngselect{max-width:30em;};

</style>
<!----
<link rel="alternate stylesheet" title="jtable_jqueryui"  href="/fix/jtable/themes/jqueryui/jtable_jqueryui.min.css" type="text/css">
<link rel="alternate stylesheet" title="jtable_basic"  href="/fix/jtable/themes/basic/jtable_basic.min.css" type="text/css">
<link rel="alternate stylesheet" title="lightcolor-blue"  href="/fix/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="lightcolor-gray"  href="/fix/jtable/themes/lightcolor/gray/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="lightcolor-green"  href="/fix/jtable/themes/lightcolor/green/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="lightcolor-orange"  href="/fix/jtable/themes/lightcolor/orange/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="lightcolor-red"  href="/fix/jtable/themes/lightcolor/red/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="metro-blue"  href="/fix/jtable/themes/metro/blue/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="metro-brown"  href="/fix/jtable/themes/metro/brown/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="metro-crimson"  href="/fix/jtable/themes/metro/crimson/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="metro-darkgray"  href="/fix/jtable/themes/metro/darkgray/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="metro-darkorange"  href="/fix/jtable/themes/metro/darkorange/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="metro-green"  href="/fix/jtable/themes/metro/green/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="metro-lightgray"  href="/fix/jtable/themes/metro/lightgray/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="metro-pink"  href="/fix/jtable/themes/metro/pink/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="metro-purple"  href="/fix/jtable/themes/metro/purple/jtable.min.css" type="text/css">
<link rel="alternate stylesheet" title="metro-red"  href="/fix/jtable/themes/metro/red/jtable.min.css" type="text/css">
---->
<cfoutput>
	<cfif not isdefined("session.resultColumnList") or len(session.resultColumnList) is 0>
		<cfset session.resultColumnList='GUID'>
	</cfif>
	<cfquery name="usercols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT from (
			select CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT from ssrch_field_doc where SPECIMEN_RESULTS_COL=1 and cf_variable in (#listqualify(lcase(session.resultColumnList),chr(39))#)
			union
			select CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT from ssrch_field_doc where SPECIMEN_RESULTS_COL=1 and category='required'
		) 
		group by CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT 
		order by disp_order
	</cfquery>
	<cfset session.resultColumnList=valuelist(usercols.CF_VARIABLE)>
	<cfset basSelect = " SELECT distinct #session.flatTableName#.collection_object_id">
	<cfif len(session.CustomOtherIdentifier) gt 0>
		<cfset basSelect = "#basSelect#
			,concatSingleOtherId(#session.flatTableName#.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			'#session.CustomOtherIdentifier#' as myCustomIdType,
			to_number(ConcatSingleOtherIdInt(#session.flatTableName#.collection_object_id,'#session.CustomOtherIdentifier#')) AS CustomIDInt">
	</cfif>
	<cfloop query="usercols">
		<cfset basSelect = "#basSelect#,#evaluate("sql_element")# #CF_VARIABLE#">
	</cfloop>
	<cfset basFrom = " FROM #session.flatTableName#">
	<cfset basJoin = "">
	<cfset basWhere = " WHERE #session.flatTableName#.collection_object_id IS NOT NULL ">
	<cfset basQual = "">
	<cfset mapurl="">
	<cfinclude template="/includes/SearchSql.cfm">
	<cfset session.mapurl=mapurl>
	<!--- wrap everything up in a string --->
	<cfset SqlString = "#basSelect# #basFrom# #basJoin# #basWhere# #basQual#">
	<cfset sqlstring = replace(sqlstring,"flatTableName","#session.flatTableName#","all")>
	<!--- require some actual searching --->
	<cfset srchTerms="">
	<cfloop list="#mapurl#" delimiters="&" index="t">
		<cfset tt=listgetat(t,1,"=")>
		<cfset srchTerms=listappend(srchTerms,tt)>
	</cfloop>
	<cfif listcontains(srchTerms,"collection_id")>
		<cfset srchTerms=listdeleteat(srchTerms,listfindnocase(srchTerms,'collection_id'))>
	</cfif>
	<!--- ... and abort if there's nothing left --->
	<cfif len(srchTerms) is 0>
		<CFSETTING ENABLECFOUTPUTONLY=0>
		<font color="##FF0000" size="+2">You must enter some search criteria!</font>
		<cfabort>
	</cfif>
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
	<cfquery name="trc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from #session.SpecSrchTab#
	</cfquery>
	<cfset numFlds=usercols.recordcount>
	<cfset thisLoopNum=1>
	<script type="text/javascript">
	    $(document).ready(function () {
	        $('##specresults').jtable({
	            title: 'Specimen Results',       
				paging: true, //Enable paging
	            pageSize: 10, //Set page size (default: 10)
	            sorting: true, //Enable sorting
	            defaultSorting: 'GUID ASC', //Set default sorting
				columnResizable: true,
				multiSorting: true,
				columnSelectable: false,
				recordsLoaded: getPostLoadJunk,
				multiselect: true,
				selectingCheckboxes: true,
  				selecting: true, //Enable selecting
          		selectingCheckboxes: true, //Show checkboxes on first column
            	selectOnRowClick: false, //Enable this to only select using checkboxes
				actions: {
	                listAction: '/component/SpecimenResults.cfc?totalRecordCount=#trc.c#&method=getSpecimenResults'
	            },
	            fields:  {
					 COLLECTION_OBJECT_ID: {
	                    key: true,
	                    create: false,
	                    edit: false,
	                    list: false
	                },
					<cfloop query="usercols">
						#ucase(CF_VARIABLE)#: {title: '#replace(DISPLAY_TEXT," ","&nbsp;","all")#'}
						<cfif len(session.CustomOtherIdentifier) gt 0 and thisLoopNum eq 1>,CUSTOMID: {title: '#session.CustomOtherIdentifier#'}</cfif>
						<cfif thisLoopNum lt numFlds>,</cfif>
						<cfset thisLoopNum=thisLoopNum+1>
					</cfloop>
	            } 
	        });
	        $('##specresults').jtable('load');
	    });
	</script>
	<div id="SelectedRowList"></div>
	<cfquery name="summary" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			collection_object_id,
				dec_lat,
			dec_long,
				round(
					to_number(
						decode(
							coordinateuncertaintyinmeters,
							0,NULL,
							coordinateuncertaintyinmeters
						)
					)
				) coordinateuncertaintyinmeters,
			scientific_name
		from 
			#session.SpecSrchTab#
	</cfquery>
	

	<cfquery name="hascoords" dbtype="query">
		select 
			count(*) as numspecs,
			dec_lat,
			dec_long,
			coordinateuncertaintyinmeters
		from 
			summary 
		where 
			dec_lat is not null 
		group by
			dec_lat,
			dec_long,
			coordinateuncertaintyinmeters
	</cfquery>
	
	<cfset cfgml="">
	<cfset cpc=1>
	<cfloop query="hascoords">
		<cfif cpc lt 500>
			<cfif len(coordinateuncertaintyinmeters) is 0>
				<cfset radius=0>
			<cfelse>
				<cfset radius=coordinateuncertaintyinmeters>
			</cfif>
			<cfset cep="#numspecs#,#dec_lat#,#dec_long#,#radius#">
			<cfset cfgml=listappend(cfgml,cep,';')>
			<cfset cpc=cpc+1>
		</cfif>
	</cfloop>
	
	
	<input type="hidden" id="cfgml" value="#cfgml#">
	
	<cfif summary.recordcount is 0>
		<div>
			Your query returned no results.
			<ul>
				<li>Check your form input, or use the Clear Form button to start over.</li>
				<li>
					If you searched by taxonomy, consult <a href="/taxonomy.cfm" class="novisit">Arctos Taxonomy</a>.
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
					Check <a href="/info/ctDocumentation.cfm" target="_blank">code table documentation</a> and 
					<a href="/info/ctDocumentation.cfm?table=CTATTRIBUTE_CODE_TABLES" target="_blank">attribute data definitions</a> documentation for terms,
					vocabulary, and standards.
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
	</cfif>
	<cfset collObjIdList = valuelist(summary.collection_object_id)>
	<cfparam name="transaction_id" default="">
	<form name="controls">
		<!--- keep stuff around for JS to get at --->
		<input type="hidden" name="transaction_id" id="transaction_id" value="#transaction_id#">
		<input type="hidden" name="mapURL" id="mapURL" value="#mapURL#">
		<input type="hidden" name="customID" id="customID" value="#session.customOtherIdentifier#">
		<input type="hidden" name="result_sort" id="result_sort" value="#session.result_sort#">
		<input type="hidden" name="displayRows" id="displayRows" value="#session.displayRows#">		
		<!---- see if users have searched for min-max/max-mar error ---->
		<cfset userSrchMaxErr=99999999999999999999999>
		<cfset precisionmapurl=mapurl>
		<cfif mapurl contains "max_max_error">
			<cfloop list="#mapurl#" delimiters="&?" index="i">
				<cfif listgetat(i,1,"=") is "max_max_error">
					<cfset precisionmapurl = reReplaceNoCase(precisionmapurl, "max_max_error=[^&]+&?", "")>
					<cfset userSrchMaxErr=listgetat(i,2,"=")>
				<cfelseif listgetat(i,1,"=") is "min_max_error">
					<cfset precisionmapurl = reReplaceNoCase(precisionmapurl, "min_max_error=[^&]+&?", "")>
					<cfset meu=listgetat(i,2,"=")>
				<cfelseif listgetat(i,1,"=") is "max_error_units">
					<cfset precisionmapurl = reReplaceNoCase(precisionmapurl, "max_error_units=[^&]+&?", "")>
				</cfif>
			</cfloop>
		</cfif>
		<cfif isdefined("meu") and meu is not "m">
			<cfif meu is "ft">
				<cfset userSrchMaxErr=userSrchMaxErr * .3048>
			<cfelseif meu is "km">
				<cfset userSrchMaxErr=userSrchMaxErr * 1000>
			<cfelseif meu is "mi">
				<cfset userSrchMaxErr=userSrchMaxErr * 1609.344>
			<cfelseif meu is "yd">
				<cfset userSrchMaxErr=userSrchMaxErr * .9144>
			</cfif>
		</cfif>
		<cfquery dbtype="query" name="willmap">
			select * from summary where dec_lat is not null
		</cfquery>
		<cfquery dbtype="query" name="noerr">
			select count(*) c from willmap where coordinateuncertaintyinmeters is null
		</cfquery>
		<cfquery dbtype="query" name="err_lt100">
			select count(*) c from willmap where coordinateuncertaintyinmeters is not null and coordinateuncertaintyinmeters <= 100
		</cfquery>
		<cfquery dbtype="query" name="err_lt1000">
			select count(*) c from willmap where coordinateuncertaintyinmeters is not null and coordinateuncertaintyinmeters <=1000
		</cfquery>
		<cfquery dbtype="query" name="err_lt10000">
			select count(*) c from summary where coordinateuncertaintyinmeters is not null and coordinateuncertaintyinmeters <=10000
		</cfquery>
		<cfquery dbtype="query" name="haserr">
			select count(*) c from willmap where coordinateuncertaintyinmeters is not null
		</cfquery>
		<cfset numWillNotMap=summary.recordcount-willmap.recordcount>
		<!--- if they came in with min/max, the out-with-min/max urls are wonky so....---->
		
		<table width="100%">
			<tr>
				<td  class="valigntop" width="65%">
					<div id="cntr_refineSearchTerms"></div>
				</td>
				<td class="valigntop" align="center">
					<div id="spresmapdiv" class="#session.srmapclass#"></div>
					<div style="text-align:center">
						<span class="infoLink" onclick="resizeMap('tinymap');">tiny</span>~
						<span class="infoLink" onclick="resizeMap('smallmap');">small</span>~
						<span class="infoLink" onclick="resizeMap('largemap');">large</span>~
						<span class="infoLink" onclick="resizeMap('hugemap');">huge</span>~
						<span class="infoLink" onclick="queryByViewport();">QueryByViewport</span>
					</div>
				</td>
			</tr>
		</table>
		<strong>Found #summary.recordcount# specimens.</strong>
		<cfif cpc gte 500>
			(The inline map contains only the first 500 localities.)
		</cfif>
	
		
		<!----
		<table width="100%">
			<tr>
				<td>
					<strong>Found #summary.recordcount# specimens.</strong>
					<span class="infoLink" onclick="alert('The following links are ADDITIVE; the \'1000 meter\' link contains the \'100 meter\' specimens.\nIf your previous search included precision, or followed a link such as these, then these links may return records that were not in your previous query.')">
						about these links
					</span>
					<ul>
						<cfif err_lt100.c gt 0 and userSrchMaxErr gte 100>
							<li>
								<a href="/SpecimenResults.cfm?#precisionmapurl#&max_max_error=100">#val(err_lt100.c)# specimens</a> have a coordinate precision of 100 meters or less.
							</li>
						</cfif>
						<cfif err_lt1000.c gt 0 and userSrchMaxErr gte 1000>
							<li>
								<a href="/SpecimenResults.cfm?#precisionmapurl#&max_max_error=1000">#val(err_lt1000.c)# specimens</a> have a coordinate precision of 1 kilometer or less.
							</li>
						</cfif>
						<cfif err_lt10000.c gt 0 and userSrchMaxErr gte 10000>
							<li>
								<a href="/SpecimenResults.cfm?#precisionmapurl#&max_max_error=10000">#val(err_lt10000.c)# specimens</a> have a coordinate precision of 10 kilometers or less.
							</li>
						</cfif>
						<cfif haserr.c gt 0>
							<li>
								<a href="/SpecimenResults.cfm?#precisionmapurl#&max_max_error=99999999999999999999999">#val(haserr.c)# specimens</a> have a coordinate precision.
							</li>
						</cfif>
						<cfif willmap.recordcount gt 0 and willmap.recordcount neq haserr.c>
							<li>
								<a href="/SpecimenResults.cfm?#precisionmapurl#&isGeoreferenced=true">#val(willmap.recordcount)# specimens</a> have coordinates.
							</li>
						</cfif>
						<cfif noerr.c gt 0>
							<li>
								<a href="/SpecimenResults.cfm?#precisionmapurl#&min_max_error=NULL">#val(noerr.c)# specimens</a> have coordinates with no indication of precision.
							</li>
						</cfif>
						<cfif numWillNotMap gt 0>
							<li>
								<a href="/SpecimenResults.cfm?#precisionmapurl#&isGeoreferenced=false">#val(numWillNotMap)# specimens</a> do not have coordinates.
							</li>
						</cfif>
					</ul>
				</td>
			</tr>
		</table>
		---->
		<div style="border:2px solid blue;" id="ssControl">
			<cfif len(transaction_id) gt 0>
				<cfquery name="isDataLoan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					select LOAN_TYPE from loan where transaction_id=#transaction_id#
				</cfquery>
				<cfif isDataLoan.LOAN_TYPE is 'data'>
					<input type="hidden" name="isDataLoan" id="isDataLoan" value="yes">
					<br>You are adding cataloged items to a data loan.
					<br>Customize, turn on Remove Rows option to remove anything that should not be added to this loan.
					<br>Then <span class="likeLink" onclick="confirmAddAllDL();">Add All Cataloged Items to this Data Loan</span>
				<cfelse>
					<cfquery name="commonParts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
						select 
							part_name,
							count(*) numRecWithThisPart
						from
							specimen_part,
							#session.SpecSrchTab#
						where
							specimen_part.derived_from_cat_item=#session.SpecSrchTab#.collection_object_id and
							specimen_part.sampled_from_obj_id is null
						group by
							part_name
					</cfquery>
					<cfquery name="partsForLoan" dbtype="query">
						select part_name from commonParts where numRecWithThisPart=#summary.recordcount#
						group by part_name order by part_name
					</cfquery>
					<cfif partsForLoan.recordcount gte 1>
						<br>Customize, turn on Remove Rows option to remove anything that should not be added to this loan, them you can
						use this form to add an item from all found specimens (not necessarily just the ones visible on this page)
						to your loan.
						<p>
							For all specimens, add this:
						</p>
						<label for="part_name">Part Name</label>
						<select name="part_name" id="part_name">
							<cfloop query="partsForLoan">
								<option value="#part_name#">#part_name#</option>
							</cfloop>
						</select>
						<br>
						<input type="button" value="Add All to this Loan" onclick="confirmAddAllPartLoan();">
					<cfelse>
						<br>No common Parts - group-add tools not available.
					</cfif>
					<br><a href="/tools/loanBulkload.cfm?action=downloadForBulkSpecSrchRslt&transaction_id=#transaction_id#">Download in loan bulkloader format</a>
					<input type="hidden" name="isDataLoan" id="isDataLoan" value="no">
				</cfif>
				<input type="hidden" name="transaction_id" id="transaction_id" value="#transaction_id#">
				<cfset mapURL=listappend(mapurl,"transaction_id=#transaction_id#","&")>
				<br><a href="Loan.cfm?action=editLoan&transaction_id=#transaction_id#">back to loan</a>
			</cfif>
			<cfset session.mapURL=mapURL>
	
		<table border="0" width="100%">
			<tr>
				<td>
					<span class="controlButton"	id="customizeButton">Add/Remove&nbsp;Data&nbsp;Fields</span>
				</td>
				<td id="removeRowsCell">
					<span class="controlButton" onclick="removeRows();">Remove Checked Rows</span>
				</td>
				<td>
					<span class="controlButton" onclick="window.open('/SpecimenResultsDownload.cfm?tableName=#session.SpecSrchTab#','_blank');">Download</span>
				</td>
				<td>
					<span class="controlButton" onclick="saveSearch('#Application.ServerRootUrl#/SpecimenResults.cfm?#mapURL#');">Save&nbsp;Search</span>
				</td>
				<cfif willmap.recordcount gt 0>
					<td>
						<a href="/bnhmMaps/bnhmMapData.cfm?#mapurl#" target="_blank" class="external">BerkeleyMapper</a>
					</td>
					<!--- far from perfect, but see if we can prevent some frustration by sending fewer bound-to-fail queries to rangemaps ---->
					<cfquery dbtype="query" name="willItRangeMap">
						select scientific_name from summary group by scientific_name
					</cfquery>
					<cfset gen=''>
					<cfset sp=''>
					<cfloop query="willItRangeMap">
						<cfif listlen(scientific_name," ") is 1>
							<cfif not listcontains(gen,scientific_name)>
								<cfset gen=listappend(gen,scientific_name)>
							</cfif>
						<cfelseif listlen(scientific_name," ") gte 2>
							<cfif not listcontains(gen,listgetat(scientific_name,1," "))>
								<cfset gen=listappend(gen,listgetat(scientific_name,1," "))>
							</cfif>
							<cfif not listcontains(sp,listgetat(scientific_name,2," "))>
								<cfset sp=listappend(sp,listgetat(scientific_name,2," "))>
							</cfif>
						</cfif>
					</cfloop>
					<cfif listlen(gen) is 1 and listlen(sp) is 1>
						<td>
							<a href="/bnhmMaps/bnhmMapData.cfm?showRangeMaps=true&#mapurl#" target="_blank" class="external">BerkeleyMapper+Rangemaps</a>
						</td>
					</cfif>
					<td>
						<a href="/bnhmMaps/kml.cfm" target="_blank">Google Maps/Google Earth</a>
					</td>
				</cfif>
				<cfif (isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user"))>
					<td nowrap="nowrap">
						<select name="goWhere" id="goWhere" size="1">
							<option value="">Manage...</option>
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
							<option value="/bulkSpecimenEvent.cfm">
								Specimen Events
							</option>
							<option value="/addAccn.cfm">
								Accession
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
							<option value="/Reports/uamento.cfm">
								download UAM Ento CSV
							</option>
								<!----
							<option value="/Reports/print_nk.cfm">
								Print NK pages
							</option>
									---->
							<option value="/Reports/report_printer.cfm?report=ala_label">
								ALA Labels
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
						<input type="button" value="Go" class="lnkBtn" onClick="reporter('#session.SpecSrchTab#');">
					</td>
				</cfif>
				<td>
					<a href="/SpecimenResultsHTML.cfm?#mapurl#" class="likeLink">HTML version</a>
				</td>
				<td>
					<a class="likeLink" href="/info/reportBadData.cfm?collection_object_id=#collObjIdList#">Report Bad Data</a>
				</td>
			</tr>
		</table>
	</div>
	</form>
	<div id="specresults"></div>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">