<cfinclude template="/includes/_header.cfm">
<cfset mapRecordLimit=1000>
<cfif not isdefined("session.RESULTSBROWSEPREFS")>
	<cfset session.RESULTSBROWSEPREFS=0>
</cfif>
<cfset title="Specimen Results">
<cfif not isdefined("session.srmapclass") or len(session.srmapclass) is 0>
	<cfset session.srmapclass='nomap'>
</cfif>
<script type='text/javascript' language="javascript" src='/includes/jtable/jquery.jtable.min.js'></script>
<script type='text/javascript' language="javascript" src='/includes/SpecimenResults.js?v=3.43'></script>
<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
<link rel="stylesheet" title="lightcolor-blue"  href="/includes/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">
<cfhtmlhead text='<script src="https://maps.googleapis.com/maps/api/js?client=gme-museumofvertebrate1&libraries=places,geometry" type="text/javascript"></script>'>
<style>
	#usertools{border:3px solid #417bb5; }
	#goWhere{border:3px solid #417bb5; }
	[id^="partdetail_"] {
		max-height:10em;
		max-width: 40em;
		overflow:auto;
	}
	.noshrink{
		max-height: none;
		max-width: none;
	}
</style>
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
	<cfquery name="buildIt" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" timeout="60">
		#preserveSingleQuotes(SqlString)#
	</cfquery>
	<cfquery name="trc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select count(*) c from #session.SpecSrchTab#
	</cfquery>
	<cfif isdefined("archive_record_count") and archive_record_count is not trc.c>
		<div class="importantNotification">
			Caution: You are not seeing all of the Archive. If that is not intended, remove search terms, log out, adjust your
			collection preferences, or
			<span class="likeLink" onclick="changeCollection('/archive/#archive_name#')">try again in the public portal</span>.
			Use the contact link in the footer for additional assistance.
		</div>
	</cfif>
	<cfset loginfo="#dateformat(now(),'yyyy-mm-dd')#T#TimeFormat(now(), 'HH:mm:ss')#||#session.username#||#request.ipaddress#||#mapurl#||#session.resultColumnList#||#trc.c#||#request.uuid#">
	<cfthread name="log#request.uuid#" action="run" priority="LOW" loginfo="#loginfo#">
		<cffile action="append" file="#Application.querylog#" output="#loginfo#">
    </cfthread>
	<cfset numFlds=usercols.recordcount>
	<cfset thisLoopNum=1>
	<script type="text/javascript">
	    $(document).ready(function () {
			$("##usertools").menu();
			$("##goWhere").menu();
	        $('##specresults').jtable({
	            title: 'Specimen Results',
				paging: true, //Enable paging
	            pageSize: 100, //Set page size (default: 10)
	            sorting: true, //Enable sorting
	            defaultSorting: 'GUID ASC', //Set default sorting
				columnResizable: true,
				recordsLoaded: getPostLoadJunk,
				multiSorting: true,
				columnSelectable: false,
				multiselect: true,
				selectingCheckboxes: true,
  				selecting: true, //Enable selecting
          		selectingCheckboxes: true, //Show checkboxes on first column
            	selectOnRowClick: false, //Enable this to only select using checkboxes
				pageSizes: [10, 25, 50, 100, 250, 500,5000],
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
		<cfif cpc lt mapRecordLimit>
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
					"include all IDs" option.
				</li>
				<li>
					Try broadening your search criteria. Try the next-higher geographic element, remove criteria, or use a substring match.
					Don't assume we've accurately or predictably recorded data.
				</li>
				<li>
					 Not all specimens have coordinates, and the spatial query tool will not locate all specimens.
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
				<cfif session.srmapclass is "nomap">
					<cfset d1="display:none;">
					<cfset d2="">
				<cfelse>
					<cfset d1="">
					<cfset d2="display:none;">
				</cfif>
				<div id="spresmapdiv" style="#d1#" class="#session.srmapclass#"></div>
				<div id="srmapctrls" style="text-align:center; #d1#">
					<span class="infoLink" onclick="resizeMap('nomap');">none</span>~
					<span class="infoLink" onclick="resizeMap('tinymap');">tiny</span>~
					<span class="infoLink" onclick="resizeMap('smallmap');">small</span>~
					<span class="infoLink" onclick="resizeMap('largemap');">large</span>~
					<span class="infoLink" onclick="resizeMap('hugemap');">huge</span>~
					<span class="infoLink #session.srmapclass#" onclick="queryByViewport();">QueryByViewport</span>
				</div>
				<div id="srmapctrls-nomap" style="#d2#" class="likeLink">[ Show Map ]</div>
			</td>
		</tr>
	</table>
		<!--- keep stuff around for JS to get at --->
		<input type="hidden" name="transaction_id" id="transaction_id" value="#transaction_id#">
		<input type="hidden" name="mapURL" id="mapURL" value="#mapURL#">
		<input type="hidden" name="SpecSrchTab" id="SpecSrchTab" value="#session.SpecSrchTab#">
		<input type="hidden" name="ServerRootUrl" id="ServerRootUrl" value="#application.ServerRootUrl#">

		<input type="hidden" name="customID" id="customID" value="#session.customOtherIdentifier#">
		<input type="hidden" name="result_sort" id="result_sort" value="#session.result_sort#">
		<input type="hidden" name="displayRows" id="displayRows" value="#session.displayRows#">
		<cfif cpc gte mapRecordLimit>
			(The inline map contains only the first #mapRecordLimit# localities.)
		</cfif>
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
							count(distinct(specimen_part.derived_from_cat_item)) numRecWithThisPart
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
						<label for="loan_all_part_name">Part Name</label>
						<select name="loan_all_part_name" id="loan_all_part_name">
							<cfloop query="partsForLoan">
								<option value="#part_name#">#part_name#</option>
							</cfloop>
						</select>
						<br>
						<input type="button" value="Add All PARTS to this Loan" onclick="confirmAddAllPartLoan();">
						<input type="button" value="Create SUBSAMPLES for all parts, add them to this Loan" onclick="confirmAddAllPartLoanSS();">
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
				<strong>Found #summary.recordcount# specimens.</strong>
			</td>
				<cfif willmap.recordcount gt 0>
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
				</cfif>
					<td>
						<select name="usertools" id="usertools" onchange="pickedTool()">
							<option value="">Tools: Map, Customize, or Download</option>
							<cfif willmap.recordcount gt 0>
								<optgroup label="Mapping Tools">
									<option value="BerkeleyMapper">Map results in BerkeleyMapper</option>
									<cfif listlen(gen) is 1 and listlen(sp) is 1>
										<option value="BerkeleyMapperRM">Map results in BerkeleyMapper+RangeMap</option>
									</cfif>
									<option value="google">Map results in Google Maps/download for Google Earth</option>
								</optgroup>
							</cfif>
							<optgroup label="Customize Form">
								<option value="customize">Add or Remove Data Fields (columns)</option>
								<option value="removeRows">Remove Checked Rows</option>
							</optgroup>
							<optgroup label="Data Tools">
								<cfif len(Session.username) gt 0>
									<option value="saveSearch">Save Search</option>
									<option value="archiveSpecimens">Archive Results</option>
									<option value="download">Download</option>
								<cfelse>
									<option value="">Log in for access</option>
								</cfif>

							</optgroup>
						</select>
					</td>
				<cfif (isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user"))>
					<td nowrap="nowrap">
						<select name="goWhere" id="goWhere" size="1" onchange="reporter('#session.SpecSrchTab#');">
							<option value="">Manage...</option>
							<optgroup label="Change Stuff">
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
							</optgroup>
							<optgroup label="Print Stuff">
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
								<option value="/Reports/specrescollevent.cfm">
									download Collecting Event CSV
								</option>
								<option value="/Reports/report_printer.cfm?report=ala_label">
									ALA Labels
								</option>
								<option value="/info/part_data_download.cfm">
									Parts table/download
								</option>
			                    <option value="/SpecimenResultsDownload.cfm?action=bulkloaderFormat">
									Download for Specimen Bulkloader
								</option>
								 <option value="/SpecimenResultsDownload.cfm?action=citationFormat">
									Download for Citation Bulkloader
								</option>
			                    <option value="/Reports/report_printer.cfm">
									Print Any Report
								</option>
							</optgroup>
							<optgroup label="Related">
								 <option value="/Locality.cfm?action=findLocality">
									Locality
								</option>
								 <option value="/Locality.cfm?action=findCollEvent">
									CollectingEvent
								</option>
							</optgroup>
						</select>
					</td>
				</cfif>
				<td>
					<a href="/SpecimenResultsHTML.cfm?#mapurl#" class="likeLink">HTML version</a>
				</td>
				<td>
					<cfif listlen(collObjIdList) lt 1000>
						<a href="javascript: openAnnotation('collection_object_id=#collObjIdList#')">
						Report Bad Data
						</a>
					</cfif>
				</td>
			</tr>
		</table>
	</div>
	<div id="specresults"></div>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">