<cfinclude template="/includes/_header.cfm">
	<cfset title="SpecimenResults Test">
	
	<style>
		#cpick {
			max-height:2em;
			overflow:auto;
		}
	</style>
	<script type='text/javascript' language="javascript" src='/fix/jtable/jquery.jtable.min.js'></script>
	
	<link rel="stylesheet" title="lightcolor-blue"  href="/fix/jtable/themes/lightcolor/blue/jtable.min.css" type="text/css">
	
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
	
	
	<br>Click View/Page Style in your browser to try alternative CSS
<!--- 

	if this works, global replace cf_spec_res_cols_exp for cf_spec_res_cols
	
	create table cf_spec_res_cols_exp as select * from cf_spec_res_cols;
	create public synonym cf_spec_res_cols_exp for cf_spec_res_cols_exp;
	grant select on cf_spec_res_cols_exp to public;
	
	COLUMN_NAME								    VARCHAR2(38)
	 SQL_ELEMENT								    VARCHAR2(255)
	 CATEGORY								    VARCHAR2(255)
	 CF_SPEC_RES_COLS_ID						   NOT NULL NUMBER
	 DISP_ORDER							   NOT NULL NUMBER


	update cf_spec_res_cols_exp set category='admin' where column_name ='collection_id';
	update cf_spec_res_cols_exp set category='admin' where column_name ='institution_acronym';

	-- table header display
	alter table cf_spec_res_cols_exp add thdisplay varchar2(20);
	
	update cf_spec_res_cols_exp set thdisplay=COLUMN_NAME;
		alter table cf_spec_res_cols_exp modify thdisplay varchar2(50);

	update cf_spec_res_cols_exp set thdisplay='GUID' where thdisplay ='guid';
	update cf_spec_res_cols_exp set thdisplay='ScientificName' where thdisplay ='scientific_name';
	update cf_spec_res_cols_exp set thdisplay='OtherIDs' where thdisplay ='othercatalognumbers';
	update cf_spec_res_cols_exp set thdisplay='CoordinateError(m)' where thdisplay ='coordinateuncertaintyinmeters';
	update cf_spec_res_cols_exp set thdisplay='Country' where thdisplay ='country';
	update cf_spec_res_cols_exp set thdisplay='State' where thdisplay ='state_prov';
	update cf_spec_res_cols_exp set thdisplay='Locality' where thdisplay ='spec_locality';
	update cf_spec_res_cols_exp set thdisplay='VerbatimDate' where thdisplay ='verbatim_date';
	update cf_spec_res_cols_exp set thdisplay='Parts' where thdisplay ='parts';
	update cf_spec_res_cols_exp set thdisplay='DecLat' where thdisplay ='dec_lat';
	update cf_spec_res_cols_exp set thdisplay='DecLong' where thdisplay ='dec_long';
	update cf_spec_res_cols_exp set thdisplay='Sex' where thdisplay ='sex';


--->



<cfoutput>



<cfif not isdefined("session.resultColumnList") or len(session.resultColumnList) is 0>
	<cfset session.resultColumnList='GUID'>
</cfif>
	<cfquery name="usercols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT from (
			select CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT from ssrch_field_doc where SPECIMEN_RESULTS_COL =1 and cf_variable in (#listqualify(lcase(session.resultColumnList),chr(39))#)
			union
			select CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT from ssrch_field_doc where SPECIMEN_RESULTS_COL =1 and category='required'
		) group by CF_VARIABLE,DISPLAY_TEXT,disp_order,SQL_ELEMENT order by disp_order
	</cfquery>
	
	<cfset session.resultColumnList=valuelist(usercols.CF_VARIABLE)>
	<!---- session.resultColumnList should now be correct and current.... ---->
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
	<div id="cntr_refineSearchTerms"></div>
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
<cfif not isdefined("limit")>
	<cfset limit=20000>
</cfif>
<cfparam name="transaction_id" default="">
<input type="hidden" name="transaction_id" id="transaction_id" value="#transaction_id#">
<cfquery name="trc" datasource="uam_god">
	select count(*) c from #session.dbuser#.#session.SpecSrchTab#
</cfquery>	
<input type="hidden" name="mapURL" id="mapURL" value="#mapURL#">
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
			multiSorting: true,
			selectingCheckboxes: true,
			actions: {
                listAction: '/fix/dataTablesAjax.cfc?totalRecordCount=#trc.c#&method=t'
            },
            fields:  {
				<cfloop query="usercols">
					#ucase(CF_VARIABLE)#: {title: '#DISPLAY_TEXT#'}
					<cfif len(session.CustomOtherIdentifier) gt 0 and thisLoopNum eq 1>
						,#ucase(session.CustomOtherIdentifier)#: {title: '#session.CustomOtherIdentifier#'}
						<cfset thisLoopNum=thisLoopNum+1>
					</cfif>
					<cfif thisLoopNum lt numFlds>,</cfif>
					<cfset thisLoopNum=thisLoopNum+1>
				</cfloop>
            }
        });
        $('##specresults').jtable('load');

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
			});
		});
		var ptl='/component/functions.cfc?method=get_specSrchTermWidget_exp&returnformat=plain';
		jQuery.get(ptl, function(data){
			jQuery("##cntr_refineSearchTerms").html(data);
		});
		var ptl='/component/functions.cfc?method=mapUserSpecResults&returnformat=plain';
	    jQuery.get(ptl, function(data){
			jQuery("##mapGoHere").html(data);
		});
    });
	function closeCustom() {
		var theDiv = document.getElementById('customDiv');
		document.body.removeChild(theDiv);
		var murl='/fix/dataTablesTest.cfm?' + document.getElementById('mapURL').value;
		window.location=murl;
	}
	function closeCustomNoRefresh() {
		var theDiv = document.getElementById('customDiv');
		document.body.removeChild(theDiv);	
		var theDiv = document.getElementById('bgDiv');
		document.body.removeChild(theDiv);
	}

	function getPostLoadJunk(){
		var coidlistAR=new Array();
		$("div[id^='CatItem_']").each(function() {
			var id = this.id.split('_')[1];
			coidlistAR.push(id);
		});
		var coidList = coidlistAR.toString();
		insertMedia(coidList);
		insertTypes(coidList);
		injectLoanPick();
		displayMedia();
	}

	function displayMedia(idList){
		$("div[id^='jsonmedia_']").each(function() {
			var r = $.parseJSON($("##" + this.id).html());
			if (r.ROWCOUNT>0){
				var theHTML='<div class="shortThumb"><div class="thumb_spcr">&nbsp;</div>';
				for (i=0; i<r.ROWCOUNT; ++i) {
					var theURL='/component/functions.cfc?method=getMediaPreview&preview_uri=' + r.DATA.preview_uri[i] + '&media_type=' +  r.DATA.media_type[i] + '&returnformat=json&queryformat=column';
					$.ajax({
						url: theURL,
						dataType: 'json',
						async: false,
						success: function(result) {
							theHTML+='<div class="one_thumb">';
							theHTML+='<a href="/exit.cfm?target=' + r.DATA.media_uri[i] + '" target="_blank">';
							theHTML+='<img src="' + result + '" class="theThumb"></a>';
							theHTML+='<p>' + r.DATA.mimecat[i] + ' (' + r.DATA.mime_type[i] + ')';
							theHTML+='<br><a target="_blank" href="/media/' + r.DATA.media_id[i] + '">Media Detail</a></p></div>';
						}
					});
				}
				theHTML+='<div class="thumb_spcr">&nbsp;</div></div>';
				$("##" + this.id).html(theHTML);
			} else {
				$("##" + this.id).html('');
			}
		});
	}

	function insertMedia(idList) {
		var s=document.createElement('DIV');
		s.id='ajaxStatus';
		s.className='ajaxStatus';
		s.innerHTML='Checking for Media...';
		document.body.appendChild(s);
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getMedia",
				idList : idList,
				returnformat : "json",
				queryformat : 'column'
			},
			function (result) {
				try{
					var sBox=document.getElementById('ajaxStatus');
					sBox.innerHTML='Processing Media....';
					for (i=0; i<result.ROWCOUNT; ++i) {
						var sel;
						var sid=result.DATA.COLLECTION_OBJECT_ID[i];
						var mid=result.DATA.MEDIA_ID[i];
						var rel=result.DATA.MEDIA_RELATIONSHIP[i];
						if (rel=='cataloged_item') {
							sel='CatItem_' + sid;
						} else if (rel=='collecting_event') {
							sel='SpecLocality_' + sid;
						}
						if (sel.length>0){
							var el=document.getElementById(sel);
							var ns='<a href="/MediaSearch.cfm?action=search&media_id='+mid+'" class="mediaLink" target="_blank" id="mediaSpan_'+sid+'">';
							ns+='Media';
							ns+='</a>';
							el.innerHTML+=ns;
						}
					}
					document.body.removeChild(sBox);
					}
				catch(e) {
					sBox=document.getElementById('ajaxStatus');
					document.body.removeChild(sBox);
				}
			}
		);
	}

	function insertTypes(idList) {
		var s=document.createElement('DIV');
		s.id='ajaxStatus';
		s.className='ajaxStatus';
		s.innerHTML='Checking for Types...';
		document.body.appendChild(s);
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getTypes",
				idList : idList,
				returnformat : "json",
				queryformat : 'column'
			},
			function (result) {
				var sBox=document.getElementById('ajaxStatus');
				try{
					sBox.innerHTML='Processing Types....';
					for (i=0; i<result.ROWCOUNT; ++i) {
						var sid=result.DATA.COLLECTION_OBJECT_ID[i];
						var tl=result.DATA.TYPELIST[i];
						var sel='CatItem_' + sid;
						if (sel.length>0){
							var el=document.getElementById(sel);
							var ns='<div class="showType">' + tl + '</div>';
							el.innerHTML+=ns;
						}
					}
				}
				catch(e){}
				document.body.removeChild(sBox);
			}
		);
	}
	function injectLoanPick() {
		var transaction_id=$("##transaction_id").val();
		if (transaction_id) {
			var lastID;
			var s=document.createElement('DIV');
			s.id='ajaxStatus';
			s.className='ajaxStatus';
			s.innerHTML='Feching Loan Pick...';
			document.body.appendChild(s);	
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "getLoanPartResults",
					transaction_id : transaction_id,
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					for (i=0; i<r.ROWCOUNT; ++i) {
						var cid = 'CatItem_' + r.DATA.COLLECTION_OBJECT_ID[i];
						if (document.getElementById(cid)){
							var theCell = document.getElementById(cid);
							if (lastID == r.DATA.COLLECTION_OBJECT_ID[i]) {
								theTable += "<tr>";
							} else {
								theTable = '<table border width="100%"><tr>';
							}
							theTable += '<td nowrap="nowrap" class="specResultPartCell">';
							theTable += '<i>' + r.DATA.PART_NAME[i];
							if (r.DATA.SAMPLED_FROM_OBJ_ID[i] > 0) {
								theTable += '&nbsp;sample';
							}
							theTable += "&nbsp;(" + r.DATA.COLL_OBJ_DISPOSITION[i] + ")</i> [" + r.DATA.BARCODE[i] + "]";
							theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
							theTable += 'Remark:&nbsp;<input type="text" name="item_remark" size="10" id="item_remark_' + r.DATA.PARTID[i] + '">';
							theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
							theTable += 'Instr.:&nbsp;<input type="text" name="item_instructions" size="10" id="item_instructions_' + r.DATA.PARTID[i] + '">';
							theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
							theTable += 'Subsample?:&nbsp;<input type="checkbox" name="subsample" id="subsample_' + r.DATA.PARTID[i] + '">';
							theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
							theTable += '<input type="button" id="theButton_' + r.DATA.PARTID[i] + '"';
							theTable += ' class="insBtn"';
							if (r.DATA.TRANSACTION_ID[i] > 0) {
								theTable += ' onclick="" value="In Loan">';
							} else {
								theTable += ' value="Add" onclick="addPartToLoan(';
								theTable += r.DATA.PARTID[i] + ');">';
							}
							if (r.DATA.ENCUMBRANCE_ACTION[i]!==null) {
								theTable += '<br><i>Encumbrances:&nbsp;' + r.DATA.ENCUMBRANCE_ACTION[i] + '</i>';
							}
							theTable +="</td>";
							if (r.DATA.COLLECTION_OBJECT_ID[i+1] && r.DATA.COLLECTION_OBJECT_ID[i+1] == r.DATA.COLLECTION_OBJECT_ID[i]) {
								theTable += "</tr>";
							} else {
								theTable += "</tr></table>";
							}
							lastID = r.DATA.COLLECTION_OBJECT_ID[i];
							$("##" + cid).append(theTable);
						} // if item isn't in viewport, do nothing
					} // loopity
				} // end return fn
			);
		} // no transaction_id just abort
	}
	
	function addPartToLoan(partID) {
		var rs = "item_remark_" + partID;
		var is = "item_instructions_" + partID;
		var ss = "subsample_" + partID;
		var remark=document.getElementById(rs).value;
		var instructions=document.getElementById(is).value;
		var subsample=document.getElementById(ss).checked;
		if (subsample==true) {
			subsample=1;
		} else {
			subsample=0;
		}
		var transaction_id=document.getElementById('transaction_id').value;
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "addPartToLoan",
				transaction_id : transaction_id,
				partID : partID,
				remark : remark,
				instructions : instructions,
				subsample : subsample,
				returnformat : "json",
				queryformat : 'column'
			},
			function (result) {
				var rar = result.split("|");
				var status=rar[0];
				if (status==1){
					var b = "theButton_" + rar[1];
					var theBtn = document.getElementById(b);
					theBtn.value="In Loan";
					theBtn.onclick="";	
				}else{
					var msg = rar[1];
					alert('An error occured!\n' + msg);
				}
			}
		);
	}

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
		u += sep;
		u += '&table_name=' + t;
		u += '&sort=' + s;
		var reportWin=window.open(u);
	}


</script>
<cfquery name="summary" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		collection_object_id,
			dec_lat,
		dec_long,
			to_number(decode(coordinateuncertaintyinmeters,
			0,NULL,
			coordinateuncertaintyinmeters)) coordinateuncertaintyinmeters,
		scientific_name
	from 
		#session.SpecSrchTab#
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
	<cfabort>
</cfif>
<cfset collObjIdList = valuelist(summary.collection_object_id)>
<script>
	hidePageLoad();
</script>
<form name="controls">
	<!--- keep stuff around for JS to get at --->
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
			<td>
				
			</td>
			<td align="right">
				<div id="mapGoHere"></div>
			</td>
		</tr>
	</table>		
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
			<label for="">&nbsp;</label>
			<input type="hidden" name="killRowList" id="killRowList">
			<span id="removeChecked"
				style="display:none;"
				class="controlButton redButton"
				onclick="removeItems();">Remove&nbsp;Checked&nbsp;Rows</span>
		</td>
		<td>
			<label for="">&nbsp;</label>
			<span class="controlButton"	id="customizeButton">Add/Remove&nbsp;Data&nbsp;Fields</span>
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
					<!----
					<option value="/compDGR.cfm">
						MSB<->DGR
					</option>
					---->
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
					<option value="/Reports/print_nk.cfm">
						Print NK pages
					</option>
					<option value="/Reports/report_printer.cfm?report=ala_label">
						ALA Labels
					</option>
					<!----
					<option value="/bnhmMaps/SpecimensByLocality.cfm">
						Map By Locality
					</option>
					---->
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
<div id="mapGoHere"></div>
<div id="cntr_refineSearchTerms"></div>
<div id="specresults"></div>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">