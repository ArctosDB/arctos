function saveSearch(returnURL){
	var sName=prompt("Name this search", "my search");
	if (sName!=null){
		var sn=encodeURIComponent(sName);
		var ru=encodeURI(returnURL);
		$.getJSON("/component/functions.cfc",
			{
				method : "saveSearch",
				returnURL : ru,
				srchName : sn,
				returnformat : "json",
				queryformat : 'column'
			},
			success_saveSearch
		);
	}
}
function success_saveSearch(r) {
	if(r!='success'){
		alert(r);
	}
}
function insertTypes(idList) {
	var s=document.createElement('DIV');
	s.id='ajaxStatus';
	s.className='ajaxStatus';
	s.innerHTML='Checking for Types...';
	document.body.appendChild(s);
	$.getJSON("/component/functions.cfc",
		{
			method : "getTypes",
			idList : idList,
			returnformat : "json",
			queryformat : 'column'
		},
		success_insertTypes
	);
}
function success_insertTypes (result) {
	var sBox=document.getElementById('ajaxStatus');
	try{
		sBox.innerHTML='Processing Types....';
		for (i=0; i<result.ROWCOUNT; ++i) {
			var sid=result.DATA.collection_object_id[i];
			var tl=result.DATA.typeList[i];
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
function insertMedia(idList) {
	var s=document.createElement('DIV');
	s.id='ajaxStatus';
	s.className='ajaxStatus';
	s.innerHTML='Checking for Media...';
	document.body.appendChild(s);
	$.getJSON("/component/functions.cfc",
		{
			method : "getMedia",
			idList : idList,
			returnformat : "json",
			queryformat : 'column'
		},
		success_insertMedia
	);
}
function success_insertMedia (result) {
	try{
		var sBox=document.getElementById('ajaxStatus');
		sBox.innerHTML='Processing Media....';
		for (i=0; i<result.ROWCOUNT; ++i) {
			var sel;
			var sid=result.DATA.collection_object_id[i];
			var mid=result.DATA.media_id[i];
			var rel=result.DATA.media_relationship[i];
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
		var sBox=document.getElementById('ajaxStatus');
		document.body.removeChild(sBox);
	}
}
function showMediaSpan(id){
	alert(id);
	}
function addPartToLoan(partID) {
	var rs = "item_remark_" + partID;
	var is = "item_instructions_" + partID;
	var ss = "subsample_" + partID;
	var remark=document.getElementById(rs).value;
	var instructions=document.getElementById(is).value;
	var subsample=document.getElementById(ss).checked;
	if (subsample == true) {
		subsample=1;
	} else {
		subsample=0;
	}
	var transaction_id=document.getElementById('transaction_id').value;
	//alert("partID: " + partID + "remark: " + remark + "Inst:" + instructions + "ss:" + subsample + "transid:" + transaction_id);
	$.getJSON("/component/functions.cfc",
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
		success_addPartToLoan
	);
}
function success_addPartToLoan(result) {
	//alert(result);
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
function makePartThingy() {
	//alert('makePartThingy');
	var transaction_id = document.getElementById("transaction_id").value;
	//alert(transaction_id);
	$.getJSON("/component/functions.cfc",
		{
			method : "getLoanPartResults",
			transaction_id : transaction_id,
			returnformat : "json",
			queryformat : 'column'
		},
		success_makePartThingy
	);	
}
function success_makePartThingy(result){
	var lastID;
	for (i=0; i<result.ROWCOUNT; ++i) {
		var cid = 'partCell_' + result.DATA.collection_object_id[i];
		if (document.getElementById(cid)){
			var theCell = document.getElementById(cid);
			theCell.innerHTML='Fetching loan data....';
		if (lastID == result.DATA.collection_object_id[i]) {
			theTable += "<tr>";
		} else {
			var theTable = "<table border><tr>";
		}
		theTable += '<td nowrap="nowrap" class="specResultPartCell">';
		theTable += '<i>' + result.DATA.part_name[i];
		if (result.DATA.sampled_from_obj_id[i] > 0) {
			theTable += '&nbsp;sample';
		}
		theTable += "&nbsp;(" + result.DATA.coll_obj_disposition[i] + ")</i>";
		theTable += '&nbsp;Remark:&nbsp;<input type="text" name="item_remark" size="10" id="item_remark_' + result.DATA.partid[i] + '">';
		theTable += '&nbsp;Instr.:&nbsp;<input type="text" name="item_instructions" size="10" id="item_instructions_' + result.DATA.partid[i] + '">';
		theTable += '&nbsp;Subsample?:&nbsp;<input type="checkbox" name="subsample" id="subsample_' + result.DATA.partid[i] + '">';
		theTable += '&nbsp;&nbsp;<input type="button" id="theButton_' + result.DATA.partid[i] + '"';
		theTable += 'class="insBtn" onmouseover="this.className=';
		theTable += "'insBtn btnhov'";
		theTable += '" onmouseout="';
		theTable += "this.className='insBtn'";
		theTable += '"';
		if (result.DATA.transaction_id[i] > 0) {
			theTable += ' onclick="" value="In Loan">';
		} else {
			theTable += ' value="Add" onclick="addPartToLoan(';
			theTable += result.DATA.partid[i] + ');">';
		}
		if (result.DATA.encumbrance_action[i].length > 0) {
			theTable += '<br><i>Encumbrances:&nbsp;' + result.DATA.encumbrance_action[i] + '</i>';
		}
		theTable +="</td>";
		if (result[i+1] && result.DATA.collection_object_id[i+1] == result.DATA.collection_object_id[i]) {
			theTable += "</tr>";
		} else {
			theTable += "</tr></table>";
			theCell.innerHTML = theTable;
		}
		lastID = result.DATA.collection_object_id[i];
	} else {
		}
	}
}

function cordFormat(str) {
	var rStr = str;
	var rExp = /s/gi;
	var rStr = rStr.replace(rExp,"\'\'");
	var rExp = /d/gi;
	var rStr = rStr.replace(rExp,'<sup>o</sup>');
	var rExp = /m/gi;
	var rStr = rStr.replace(rExp,"\'");
	var rExp = / /gi;
	var rStr = rStr.replace(rExp,'&nbsp;');
	return rStr;
}

function spaceStripper(str) {
	var rExp = / /gi;
	var rStr = str.replace(rExp,'&nbsp;');
	return rStr;
}
function splitByComma(str) {
	var rExp = /, /gi;
	var rStr = str.replace(rExp,'<br>');
	var rExp = / /gi;
	var rStr = rStr.replace(rExp,'&nbsp;');
	return rStr;
}
function splitBySemicolon(str) {
	var rExp = /; /gi;
	var rStr = str.replace(rExp,'<br>');
	var rExp = / /gi;
	var rStr = rStr.replace(rExp,'&nbsp;');
	return rStr;
}

function dispDate(date){
	// accepts ColdFusion's crappy date string of the format
	// 1952-07-03 00:00:00.0
	// and returns a string of the format dd Mon yyyy
	
	var s=date.substring(0,10);
	var a = s.split('-');
	var mos=new Array(13)
	mos[0]=""
	mos[1]="Jan"
	mos[2]="Feb"
	mos[3]="Mar"
	mos[4]="Apr"
	mos[5]="May"
	mos[6]="Jun"
	mos[7]="Jul"
	mos[8]="Aug"
	mos[9]="Sep"
	mos[10]="Oct"
	mos[11]="Nov"
	mos[12]="Dec"
	var m = parseFloat(a[1]);
	//alert('a1:' + a[1] + 's:' + s + 'date:' + date + '==' + m + '==' + mos[m]);
var d = a[2] + '&nbsp;' + mos[m] + '&nbsp;' + a[0];
return d;
					//
					//var d = ds.getDate();
					//var m = ds.getDay();
					//var y = ds.getYear();
					//var newDate = d + ' ' + m + ' ' + y;	
}													
function checkAllById(list) {
	var a = list.split(',');
	for (i=0; i<a.length; ++i) {
		//alert(eid);
		if (document.getElementById(a[i])) {
			//alert(eid);
			document.getElementById(a[i]).checked=true;
			crcloo(a[i],'in');
		}
	}
}
function crcloo (ColumnList,in_or_out) {
	$.getJSON("/component/functions.cfc",
		{
			method : "clientResultColumnList",
			ColumnList : ColumnList,
			in_or_out : in_or_out,
			returnformat : "json",
			queryformat : 'column'
		},
		success_crcloo
	);
}
function success_crcloo (result) {
		//alert(result);
	}

function uncheckAllById(list) {
	crcloo(list,'out');
	var a = list.split(',');
	for (i=0; i<a.length; ++i) {
		//alert(eid);
		if (document.getElementById(a[i])) {
			//alert(eid);
			document.getElementById(a[i]).checked=false;
			//crcloo(a[i],'out');
		}
	}
}
function goPickParts (collection_object_id,transaction_id) {
	var url='/picks/internalAddLoanItemTwo.cfm?collection_object_id=' + collection_object_id +"&transaction_id=" + transaction_id;
	mywin=windowOpener(url,'myWin','height=300,width=800,resizable,location,menubar ,scrollbars ,status ,titlebar,toolbar');
}
function removeItems() {
	var theList = document.getElementById('killRowList').value;
	var currentLocn = document.getElementById('mapURL').value;
	document.location='SpecimenResults.cfm?' + currentLocn + '&exclCollObjId=' + theList;
}
function toggleKillrow(id,status) {
	//alert(id + ' ' + status);
	
	var theEl = document.getElementById('killRowList');
	if (status==true) {
		if (theEl.value.length > 0) {
			var theArray = theEl.value.split(',');
		} else {
			var theArray = new Array();
		}
		theArray.push(id);
		var theString = theArray.join(",");
		theEl.value = theString;
	} else {
		var theArray = theEl.value.split(',');
		for (i=0; i<theArray.length; ++i) {
			//alert(theArray[i]);
			if (theArray[i] === id) {
				theArray.splice(i,1);
			}
		}
		var theString = theArray.toString();
		//alert(tas);
		theEl.value=theString;
		//var re=eval('/' + id + '/gi');
		//alert(re);
		//alert(theElVal);
		//var rval = theEl.value.replace(re,'');
		//alert(rval);
		//theEl.value=rval;
	}
	var theButton = document.getElementById('removeChecked');
	if (theString.length > -1) {
		theButton.style.display='block';
	} else {
		theButton.style.display='none';
	}
	
}
function hidePageLoad() {
	document.getElementById('loading').style.display='none';
	}

function closePrefs () {
	alert('close');
}

function closePrefs () {
	alert('close');
}
function getSpecResultsData (startrow,numrecs,orderBy,orderOrder) {
	if (document.getElementById('resultsGoHere')) {
		var guts = '<div id="loading" style="position:relative;top:0px;left:0px;z-index:999;color:white;background-color:green;';
	 	guts += 'font-size:large;font-weight:bold;padding:15px;">Fetching data...</div>';
	 	var tgt = document.getElementById('resultsGoHere');
		tgt.innerHTML = guts;
	}
	if (isNaN(startrow) && startrow.indexOf(',') > 0) {
   		var ar = startrow.split(',');
   		startrow = ar[0];
   		numrecs = ar[1];
   	}
	if (orderBy == null) {
		// get info from dropdowns if it's available
		if (document.getElementById('orderBy1') && document.getElementById('orderBy1')) {
			var o1=document.getElementById('orderBy1').value; 
			var o2=document.getElementById('orderBy2').value;
			var orderBy = o1 + ',' + o2;
		} else {
			var orderBy = 'cat_num';
		}		
	}
	if (orderOrder == null) {
		var orderOrder = 'ASC';
	}
	if (orderBy.indexOf(',') > -1) {
		var oA=orderBy.split(',');
		if (oA[1]==oA[0]){
			orderBy=oA[0] + ' ' + orderOrder;
		} else {
			orderBy=oA[0] + ' ' + orderOrder + ',' + oA[1] + ' ' + orderOrder;
		}
	} else {
		orderBy += ' ' + orderOrder;
	}
	//alert("startrow:"+startrow+"; numrecs:"+numrecs + '; orderBy:' + orderBy + '; orderOrder:' + orderOrder + ":end:");
	$.getJSON("/component/functions.cfc",
		{
			method : "getSpecResultsData",
			startrow : startrow,
			numrecs : numrecs,
			orderBy : orderBy,
			returnformat : "json",
			queryformat : 'column'
		},
		success_getSpecResultsData
	);
}


function success_getSpecResultsData(result){
	console.log(result);
	
	var collection_object_id = result.DATA.COLLECTION_OBJECT_ID[0];
	//alert(collection_object_id);
	if (collection_object_id < 1) {
		var msg = result.DATA.message[0];
		alert(msg);
	} else {
		var clist = result.DATA.columnlist[0];
		//alert(clist);
		// set up an array of column names and display values in the order of appearance
		// 
		var tgt = document.getElementById('resultsGoHere');
		if (document.getElementById('killrow') && document.getElementById('killrow').value==1){
			var killrow = 1;
		} else {
			var killrow = 0;
		}
		if (document.getElementById('action') && document.getElementById('action').value.length>0){
			var action = document.getElementById('action').value;
		} else {
			var action='';
		}
		if (document.getElementById('transaction_id') && document.getElementById('transaction_id').value.length>0){
			var transaction_id = document.getElementById('transaction_id').value;
		} else {
			var transaction_id='';
		}
		if (document.getElementById('loan_request_coll_id') && document.getElementById('loan_request_coll_id').value.length>0){
			var loan_request_coll_id = document.getElementById('loan_request_coll_id').value;
		} else {
			var loan_request_coll_id='';
		}
		if (document.getElementById('mapURL') && document.getElementById('mapURL').value.length>0){
			var mapURL = document.getElementById('mapURL').value;
		} else {
			var mapURL='';
		}
		var theInnerHtml = '<table class="specResultTab"><tr>';
			if (killrow == 1){
				theInnerHtml += '<th>Remove</th>';
			}
			theInnerHtml += '<th>Cat&nbsp;Num</th>';
			if (loan_request_coll_id.length > 0){
				theInnerHtml +='<th>Request</th>';
			}
			if (action == 'dispCollObj'){
				theInnerHtml +='<th>Loan</th>';
			}
			if (result.DATA.COLUMNLIST[0].indexOf('CUSTOMID')> -1) {
				theInnerHtml += '<th>';
					theInnerHtml += result[0].MYCUSTOMIDTYPE;
				theInnerHtml += '</th>';
			}
			theInnerHtml += '<th>Identification</th>';
			if (result[0].COLUMNLIST.indexOf('SCI_NAME_WITH_AUTH')> -1) {
				theInnerHtml += '<th>Scientific&nbsp;Name</th>';
			}
			if (result[0].COLUMNLIST.indexOf('IDENTIFIED_BY')> -1) {
				theInnerHtml += '<th>Identified&nbsp;By</th>';
			}
			if (result[0].COLUMNLIST.indexOf('PHYLORDER')> -1) {
				theInnerHtml += '<th>Order</th>';
			}
			if (result[0].COLUMNLIST.indexOf('FAMILY')> -1) {
				theInnerHtml += '<th>Family</th>';
			}
			if (result[0].COLUMNLIST.indexOf('OTHERCATALOGNUMBERS')> -1) {
				theInnerHtml += '<th>Other&nbsp;Identifiers</th>';
			}
			if (result[0].COLUMNLIST.indexOf('ACCESSION')> -1) {
				theInnerHtml += '<th>Accession</th>';
			}
			if (result[0].COLUMNLIST.indexOf('COLLECTORS')> -1) {
				theInnerHtml += '<th>Collectors</th>';
			}
			if (result[0].COLUMNLIST.indexOf('VERBATIMLATITUDE')> -1) {
				theInnerHtml += '<th>Latitude</th>';
			}
			if (result[0].COLUMNLIST.indexOf('VERBATIMLONGITUDE')> -1) {
				theInnerHtml += '<th>Longitude</th>';
			}
			if (result[0].COLUMNLIST.indexOf('COORDINATEUNCERTAINTYINMETERS')> -1) {
				theInnerHtml += '<th>Max&nbsp;Error&nbsp;(m)</th>';
			}
			if (result[0].COLUMNLIST.indexOf('DATUM')> -1) {
				theInnerHtml += '<th>Datum</th>';
			}
			if (result[0].COLUMNLIST.indexOf('ORIG_LAT_LONG_UNITS')> -1) {
				theInnerHtml += '<th>Original&nbsp;Lat/Long&nbsp;Units</th>';
			}
			if (result[0].COLUMNLIST.indexOf('LAT_LONG_DETERMINER')> -1) {
				theInnerHtml += '<th>Georeferenced&nbsp;By</th>';
			}
			if (result[0].COLUMNLIST.indexOf('LAT_LONG_REF_SOURCE')> -1) {
				theInnerHtml += '<th>Lat/Long&nbsp;Reference</th>';
			}
			if (result[0].COLUMNLIST.indexOf('LAT_LONG_REMARKS')> -1) {
				theInnerHtml += '<th>Lat/Long&nbsp;Remarks</th>';
			}
			if (result[0].COLUMNLIST.indexOf('CONTINENT_OCEAN')> -1) {
				theInnerHtml += '<th>Continent</th>';
			}
			if (result[0].COLUMNLIST.indexOf('COUNTRY')> -1) {
				theInnerHtml += '<th>Country</th>';
			}
			if (result[0].COLUMNLIST.indexOf('STATE_PROV')> -1) {
				theInnerHtml += '<th>State</th>';
			}
			if (result[0].COLUMNLIST.indexOf('SEA')> -1) {
				theInnerHtml += '<th>Sea</th>';
			}
			if (result[0].COLUMNLIST.indexOf('QUAD')> -1) {
				theInnerHtml += '<th>Map&nbsp;Name</th>';
			}
			if (result[0].COLUMNLIST.indexOf('FEATURE')> -1) {
				theInnerHtml += '<th>Feature</th>';
			}
			if (result[0].COLUMNLIST.indexOf('COUNTY')> -1) {
				theInnerHtml += '<th>County</th>';
			}
			if (result[0].COLUMNLIST.indexOf('ISLAND_GROUP')> -1) {
				theInnerHtml += '<th>Island&nbsp;Group</th>';
			}
			if (result[0].COLUMNLIST.indexOf('ISLAND')> -1) {
				theInnerHtml += '<th>Island</th>';
			}
			if (result[0].COLUMNLIST.indexOf('ASSOCIATED_SPECIES')> -1) {
				theInnerHtml += '<th>Associated&nbsp;Species</th>';
			}
			if (result[0].COLUMNLIST.indexOf('HABITAT')> -1) {
				theInnerHtml += '<th>Microhabitat</th>';
			}
			if (result[0].COLUMNLIST.indexOf('MIN_ELEV_IN_M')> -1) {
				theInnerHtml += '<th>Min&nbsp;Elevation&nbsp;(m)</th>';
			}
			if (result[0].COLUMNLIST.indexOf('MAX_ELEV_IN_M')> -1) {
				theInnerHtml += '<th>Max&nbsp;Elevation&nbsp;(m)</th>';
			}
			if (result[0].COLUMNLIST.indexOf('MINIMUM_ELEVATION')> -1) {
				theInnerHtml += '<th>Min&nbsp;Elevation</th>';
			}
			if (result[0].COLUMNLIST.indexOf('MAXIMUM_ELEVATION')> -1) {
				theInnerHtml += '<th>Max&nbsp;Elevation</th>';
			}
			if (result[0].COLUMNLIST.indexOf('ORIG_ELEV_UNITS')> -1) {
				theInnerHtml += '<th>Elevation&nbsp;Units</th>';
			}
			if (result[0].COLUMNLIST.indexOf('SPEC_LOCALITY')> -1) {
				theInnerHtml += '<th>Specific&nbsp;Locality</th>';
			}
			
			if (result[0].COLUMNLIST.indexOf('GEOLOGY_ATTRIBUTES')> -1) {
				theInnerHtml += '<th>Geology&nbsp;Attributes</th>';
			}
			
			
			if (result[0].COLUMNLIST.indexOf('VERBATIM_DATE')> -1) {
				theInnerHtml += '<th>Verbatim&nbsp;Date</th>';
			}
			if (result[0].COLUMNLIST.indexOf('BEGAN_DATE')> -1) {
				theInnerHtml += '<th>Began&nbsp;Date</th>';
			}
			if (result[0].COLUMNLIST.indexOf('ENDED_DATE')> -1) {
				theInnerHtml += '<th>Ended&nbsp;Date</th>';
			}
			if (result[0].COLUMNLIST.indexOf('PARTS')> -1) {
				theInnerHtml += '<th>Parts</th>';
			}
			if (result[0].COLUMNLIST.indexOf('SEX')> -1) {
				theInnerHtml += '<th>Sex</th>';
			}
			if (result[0].COLUMNLIST.indexOf('REMARKS')> -1) {
				theInnerHtml += '<th>Specimen&nbsp;Remarks</th>';
			}
			if (result[0].COLUMNLIST.indexOf('COLL_OBJ_DISPOSITION')> -1) {
				theInnerHtml += '<th>Specimen&nbsp;Disposition</th>';
			}
			// attribtues
			if (result[0].COLUMNLIST.indexOf('SNV_RESULTS')> -1) {
				theInnerHtml += '<th>SNV&nbsp;Results</th>';
			}
			if (result[0].COLUMNLIST.indexOf('AGE') > -1) {
				theInnerHtml += '<th>Age</th>';
			} 
			if (result[0].COLUMNLIST.indexOf('AGE_CLASS')> -1) {
				theInnerHtml += '<th>Age&nbsp;Class</th>';
			}
			if (result[0].COLUMNLIST.indexOf('AXILLARY_GIRTH')> -1) {
				theInnerHtml += '<th>Axillary&nbsp;Girth</th>';
			}
			if (result[0].COLUMNLIST.indexOf('BODY_CONDITION')> -1) {
				theInnerHtml += '<th>Body&nbsp;Condition</th>';
			}
			if (result[0].COLUMNLIST.indexOf('BREADTH')> -1) {
				theInnerHtml += '<th>Breadth</th>';
			}
			if (result[0].COLUMNLIST.indexOf('BURSA')> -1) {
				theInnerHtml += '<th>Bursa</th>';
			}
			if (result[0].COLUMNLIST.indexOf('CASTE')> -1) {
				theInnerHtml += '<th>Caste</th>';
			}
			if (result[0].COLUMNLIST.indexOf('COLORS')> -1) {
				theInnerHtml += '<th>Colors</th>';
			}
			if (result[0].COLUMNLIST.indexOf('CROWN_RUMP_LENGTH')> -1) {
				theInnerHtml += '<th>Crown-Rump&nbsp;Length</th>';
			}
			if (result[0].COLUMNLIST.indexOf('CURVILINEAR_LENGTH')> -1) {
				theInnerHtml += '<th>Curvilinear&nbsp;Length</th>';
			}
			if (result[0].COLUMNLIST.indexOf('DIPLOID_NUMBER')> -1) {
				theInnerHtml += '<th>Diploid&nbsp;Number</th>';
			}
			if (result[0].COLUMNLIST.indexOf('EAR_FROM_CROWN')> -1) {
				theInnerHtml += '<th>Ear&nbsp;From&nbsp;Crown</th>';
			}
			if (result[0].COLUMNLIST.indexOf('EAR_FROM_NOTCH')> -1) {
				theInnerHtml += '<th>Ear&nbsp;From&nbsp;Notch</th>';
			}
			if (result[0].COLUMNLIST.indexOf('EGG_CONTENT_WEIGHT')> -1) {
				theInnerHtml += '<th>Egg&nbsp;Content&nbsp;Weight</th>';
			}
			if (result[0].COLUMNLIST.indexOf('EGGSHELL_THICKNESS')> -1) {
				theInnerHtml += '<th>Eggshell&nbsp;Thickness</th>';
			}
			if (result[0].COLUMNLIST.indexOf('EMBRYO_WEIGHT')> -1) {
				theInnerHtml += '<th>Embryo&nbsp;Weight</th>';
			}
			if (result[0].COLUMNLIST.indexOf('EXTENSION')> -1) {
				theInnerHtml += '<th>Extension</th>';
			}
			if (result[0].COLUMNLIST.indexOf('FAT_DEPOSITION')> -1) {
				theInnerHtml += '<th>Fat&nbsp;Deposition</th>';
			}
			if (result[0].COLUMNLIST.indexOf('FOREARM_LENGTH')> -1) {
				theInnerHtml += '<th>Forearm&nbsp;Length</th>';
			}
			if (result[0].COLUMNLIST.indexOf('GONAD')> -1) {
				theInnerHtml += '<th>Gonad</th>';
			}
			if (result[0].COLUMNLIST.indexOf('HIND_FOOT_WITH_CLAW')> -1) {
				theInnerHtml += '<th>Hind&nbsp;Foot&nbsp;With&nbsp;Claw</th>';
			}
			if (result[0].COLUMNLIST.indexOf('HIND_FOOT_WITHOUT_CLAW')> -1) {
				theInnerHtml += '<th>Hind&nbsp;Foot&nbsp;Without&nbsp;Claw</th>';
			}
			if (result[0].COLUMNLIST.indexOf('MOLT_CONDITION')> -1) {
				theInnerHtml += '<th>Molt&nbsp;Condition</th>';
			}
			if (result[0].COLUMNLIST.indexOf('ABUNDANCE')> -1) {
				theInnerHtml += '<th>Abundance</th>';
			}
			if (result[0].COLUMNLIST.indexOf('NUMBER_OF_LABELS')> -1) {
				theInnerHtml += '<th>Number&nbsp;Of&nbsp;Labels</th>';
			}
			if (result[0].COLUMNLIST.indexOf('NUMERIC_AGE')> -1) {
				theInnerHtml += '<th>Numeric&nbsp;Age</th>';
			}
			if (result[0].COLUMNLIST.indexOf('OVUM')> -1) {
				theInnerHtml += '<th>Ovum</th>';
			}
			if (result[0].COLUMNLIST.indexOf('REPRODUCTIVE_CONDITION')> -1) {
				theInnerHtml += '<th>Reproductive&nbsp;Condition</th>';
			}
			if (result[0].COLUMNLIST.indexOf('REPRODUCTIVE_DATA')> -1) {
				theInnerHtml += '<th>Reproductive&nbsp;Data</th>';
			}
			if (result[0].COLUMNLIST.indexOf('SKULL_OSSIFICATION')> -1) {
				theInnerHtml += '<th>Skull&nbsp;Ossification</th>';
			}
			if (result[0].COLUMNLIST.indexOf('SNOUT_VENT_LENGTH')> -1) {
				theInnerHtml += '<th>Snout-Vent&nbsp;Length</th>';
			}
			if (result[0].COLUMNLIST.indexOf('SOFT_PARTS')> -1) {
				theInnerHtml += '<th>Soft&nbsp;Parts</th>';
			}
			if (result[0].COLUMNLIST.indexOf('STOMACH_CONTENTS')> -1) {
				theInnerHtml += '<th>Stomach&nbsp;Contents</th>';
			}
			if (result[0].COLUMNLIST.indexOf('TAIL_LENGTH')> -1) {
				theInnerHtml += '<th>Tail&nbsp;Length</th>';
			}
			if (result[0].COLUMNLIST.indexOf('TOTAL_LENGTH')> -1) {
				theInnerHtml += '<th>Total&nbsp;Length</th>';
			}
			if (result[0].COLUMNLIST.indexOf('TRAGUS_LENGTH')> -1) {
				theInnerHtml += '<th>Tragus&nbsp;Length</th>';
			}
			if (result[0].COLUMNLIST.indexOf('UNFORMATTED_MEASUREMENTS')> -1) {
				theInnerHtml += '<th>Unformatted&nbsp;Measurements</th>';
			}
			if (result[0].COLUMNLIST.indexOf('VERBATIM_PRESERVATION_DATE')> -1) {
				theInnerHtml += '<th>Verbatim&nbsp;Preservatin&nbsp;Date</th>';
			}
			if (result[0].COLUMNLIST.indexOf('WEIGHT')> -1) {
				theInnerHtml += '<th>Weight</th>';
			}
			if (result[0].COLUMNLIST.indexOf('DEC_LAT')> -1) {
				theInnerHtml += '<th>Dec.&nbsp;Lat.</th>';
			}
			if (result[0].COLUMNLIST.indexOf('DEC_LONG')> -1) {
				theInnerHtml += '<th>Dec.&nbsp;Long.</th>';
			}
			if (result[0].COLUMNLIST.indexOf('GREF_COLLNUM') > -1) {
				theInnerHtml += '<th>Gref&nbsp;Link</th>';
			}
		theInnerHtml += '</tr>';
		// get an ordered list of collection_object_ids to pass on to 
		// SpecimenDetail for browsing
		var orderedCollObjIdArray = new Array();
		for (i=0; i<result.length; ++i) {
			orderedCollObjIdArray.push(result[i].COLLECTION_OBJECT_ID);
		}
		var orderedCollObjIdList='';
		if (orderedCollObjIdArray.length < 100) {
			var orderedCollObjIdList = orderedCollObjIdArray.join(",");
		}

		
		for (i=0; i<result.length; ++i) {
			orderedCollObjIdArray.push(result[i].COLLECTION_OBJECT_ID);
			theInnerHtml += '<tr>';
				if (killrow == 1){
					theInnerHtml += '<td align="center"><input type="checkbox" onchange="toggleKillrow(' + "'";
					theInnerHtml +=result[i].COLLECTION_OBJECT_ID + "'" + ',this.checked);"></td>';
				}
			
				theInnerHtml += '<td nowrap="nowrap" id="CatItem_'+result[i].COLLECTION_OBJECT_ID+'">';
					theInnerHtml += '<a href="SpecimenDetail.cfm?collection_object_id=';
					theInnerHtml += result[i].COLLECTION_OBJECT_ID;
					//if (mapURL.length > 0) {
					//	theInnerHtml += "&returnURL=" + escape(mapURL);
					//}
					//theInnerHtml += "&orderedCollObjIdList=" + orderedCollObjIdList;
					theInnerHtml += '">';
					//theInnerHtml += ' <div class="linkButton" onmouseover="this.className=\'linkButton btnhov\'"';
					//theInnerHtml += 'onmouseout="this.className=\'linkButton\'">';
			 		//theInnerHtml += '<img src="images/';
			 		//theInnerHtml +=  result[i].INSTITUTION_ACRONYM;
			 		//theInnerHtml += '_icon.gif" border="0" alt="" width="18" height="18">';
					theInnerHtml += '&nbsp;' + result[i].COLLECTION;
					theInnerHtml += '&nbsp;';
					theInnerHtml += result[i].CAT_NUM;
					//theInnerHtml += '</div></a>';
					theInnerHtml += '</a>';
				theInnerHtml += '</td>';
				if (loan_request_coll_id.length > 0) {
					if (loan_request_coll_id == result[i].COLLECTION_ID){
						theInnerHtml +='<td><span class="likeLink" onclick="addLoanItem(' + "'" 
						theInnerHtml += result[i].COLLECTION_OBJECT_ID ;
						theInnerHtml += "');" + '">Request</span></td>';
					} else {
						theInnerHtml +='<td>N/A</td>';
					}
				}
				/*
				if (action == 'dispCollObj'){
					theInnerHtml +='<td><span class="likeLink" onclick="goPickParts(' + "'" 
					theInnerHtml += result[i].COLLECTION_OBJECT_ID + "','";
					theInnerHtml += transaction_id + "');" + '">Pick&nbsp;Part</span></td>';
				}
				*/
				
				if (action == 'dispCollObj'){
					theInnerHtml +='<td id="partCell_' + result[i].COLLECTION_OBJECT_ID + '"></td>';
				}
				
				if (result[0].COLUMNLIST.indexOf('CUSTOMID')> -1) {
					theInnerHtml += '<td>';
						theInnerHtml += result[i].CUSTOMID + '&nbsp;';
					theInnerHtml += '</td>';
				}
				theInnerHtml += '<td>';
				theInnerHtml += '<span class="browseLink" type="scientific_name" dval="' + encodeURI(result[i].SCIENTIFIC_NAME) + '">' + spaceStripper(result[i].SCIENTIFIC_NAME);
				theInnerHtml += '</span>'; 					
				theInnerHtml += '</td>';
				if (result[0].COLUMNLIST.indexOf('SCI_NAME_WITH_AUTH')> -1) {
					theInnerHtml += '<td>';
						theInnerHtml += spaceStripper(result[i].SCI_NAME_WITH_AUTH);
					theInnerHtml += '</td>';
				}
				if (result[0].COLUMNLIST.indexOf('IDENTIFIED_BY')> -1) {
					theInnerHtml += '<td>' + splitBySemicolon(result[i].IDENTIFIED_BY) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('PHYLORDER')> -1) {
					theInnerHtml += '<td>' + result[i].PHYLORDER + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('FAMILY')> -1) {
					theInnerHtml += '<td>' + result[i].FAMILY + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('OTHERCATALOGNUMBERS')> -1) {
					theInnerHtml += '<td>' + splitBySemicolon(result[i].OTHERCATALOGNUMBERS) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('ACCESSION')> -1) {
					theInnerHtml += '<td>' + spaceStripper(result[i].ACCESSION) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('COLLECTORS')> -1) {
					theInnerHtml += '<td>' + splitByComma(result[i].COLLECTORS) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('VERBATIMLATITUDE')> -1) {
					theInnerHtml += '<td>' + cordFormat(result[i].VERBATIMLATITUDE) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('VERBATIMLONGITUDE')> -1) {
					theInnerHtml += '<td>' + cordFormat(result[i].VERBATIMLONGITUDE) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('COORDINATEUNCERTAINTYINMETERS')> -1) {
					theInnerHtml += '<td>' + result[i].COORDINATEUNCERTAINTYINMETERS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('DATUM')> -1) {
					theInnerHtml += '<td>' + spaceStripper(result[i].DATUM) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('ORIG_LAT_LONG_UNITS')> -1) {
					theInnerHtml += '<td>' + result[i].ORIG_LAT_LONG_UNITS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('LAT_LONG_DETERMINER')> -1) {
					theInnerHtml += '<td>' + splitBySemicolon(result[i].LAT_LONG_DETERMINER) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('LAT_LONG_REF_SOURCE')> -1) {
					theInnerHtml += '<td>' + result[i].LAT_LONG_REF_SOURCE + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('LAT_LONG_REMARKS')> -1) {
					theInnerHtml += '<td><div class="wrapLong">' + result[i].LAT_LONG_REMARKS + '</div></td>';
				}
				if (result[0].COLUMNLIST.indexOf('CONTINENT_OCEAN')> -1) {
					theInnerHtml += '<td>' + spaceStripper(result[i].CONTINENT_OCEAN) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('COUNTRY')> -1) {
					theInnerHtml += '<td>' + spaceStripper(result[i].COUNTRY) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('STATE_PROV')> -1) {
					theInnerHtml += '<td>' + spaceStripper(result[i].STATE_PROV) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('SEA')> -1) {
					theInnerHtml += '<td>' + result[i].SEA + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('QUAD')> -1) {
					theInnerHtml += '<td>' + spaceStripper(result[i].QUAD) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('FEATURE')> -1) {
					theInnerHtml += '<td>' + spaceStripper(result[i].FEATURE) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('COUNTY')> -1) {
					theInnerHtml += '<td>' + result[i].COUNTY + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('ISLAND_GROUP')> -1) {
					theInnerHtml += '<td>' + spaceStripper(result[i].ISLAND_GROUP) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('ISLAND')> -1) {
					theInnerHtml += '<td>' + spaceStripper(result[i].ISLAND) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('ASSOCIATED_SPECIES')> -1) {
					theInnerHtml += '<td><div class="wrapLong">' + result[i].ASSOCIATED_SPECIES + '</div></td>';
				}
				if (result[0].COLUMNLIST.indexOf('HABITAT')> -1) {
					theInnerHtml += '<td><div class="wrapLong">' + result[i].HABITAT + '</div></td>';
				}
				if (result[0].COLUMNLIST.indexOf('MIN_ELEV_IN_M')> -1) {
					theInnerHtml += '<td>' + result[i].MIN_ELEV_IN_M + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('MAX_ELEV_IN_M')> -1) {
					theInnerHtml += '<td>' + result[i].MAX_ELEV_IN_M + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('MINIMUM_ELEVATION')> -1) {
					theInnerHtml += '<td>' + result[i].MINIMUM_ELEVATION + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('MAXIMUM_ELEVATION')> -1) {
					theInnerHtml += '<td>' + result[i].MAXIMUM_ELEVATION + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('ORIG_ELEV_UNITS')> -1) {
					theInnerHtml += '<td>' + result[i].ORIG_ELEV_UNITS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('SPEC_LOCALITY')> -1) {
					theInnerHtml += '<td id="SpecLocality_'+result[i].COLLECTION_OBJECT_ID + '">';
					theInnerHtml += '<span class="browseLink" type="spec_locality" dval="' + encodeURI(result[i].SPEC_LOCALITY) + '"><div class="wrapLong">' + result[i].SPEC_LOCALITY + '</div>';
					theInnerHtml += '</span>'; 					
					theInnerHtml += '</td>';
				}
				
				if (result[0].COLUMNLIST.indexOf('GEOLOGY_ATTRIBUTES')> -1) {
					theInnerHtml += '<td>' + result[i].GEOLOGY_ATTRIBUTES + '&nbsp;</td>';
				}
				
			
				if (result[0].COLUMNLIST.indexOf('VERBATIM_DATE')> -1) {
					theInnerHtml += '<td>' + result[i].VERBATIM_DATE + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('BEGAN_DATE')> -1) {
					theInnerHtml += '<td>' + dispDate(result[i].BEGAN_DATE) + '</td>';
				}
				if (result[0].COLUMNLIST.indexOf('ENDED_DATE')> -1) {
					theInnerHtml += '<td>' + dispDate(result[i].ENDED_DATE) + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('PARTS')> -1) {
					theInnerHtml += '<td><div class="wrapLong">' + splitBySemicolon(result[i].PARTS) + '</div></td>';
				}
				if (result[0].COLUMNLIST.indexOf('SEX')> -1) {
					theInnerHtml += '<td>' + result[i].SEX + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('REMARKS')> -1) {
					theInnerHtml += '<td>' + result[i].REMARKS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('COLL_OBJ_DISPOSITION')> -1) {
					theInnerHtml += '<td>' + result[i].COLL_OBJ_DISPOSITION + '&nbsp;</td>';
				}
				// attributes
				if (result[0].COLUMNLIST.indexOf('SNV_RESULTS')> -1) {
					theInnerHtml += '<td>' + result[i].SNV_RESULTS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('AGE')> -1) {
					theInnerHtml += '<td>' + result[i].AGE + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('AGE_CLASS')> -1) {
					theInnerHtml += '<td>' + result[i].AGE_CLASS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('AXILLARY_GIRTH')> -1) {
					theInnerHtml += '<td>' + result[i].AXILLARY_GIRTH + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('BODY_CONDITION')> -1) {
					theInnerHtml += '<td>' + result[i].BODY_CONDITION + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('BREADTH')> -1) {
					theInnerHtml += '<td>' + result[i].BREADTH + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('BURSA')> -1) {
					theInnerHtml += '<td>' + result[i].BURSA + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('CASTE')> -1) {
					theInnerHtml += '<td>' + result[i].CASTE + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('COLORS')> -1) {
					theInnerHtml += '<td>' + result[i].COLORS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('CROWN_RUMP_LENGTH')> -1) {
					theInnerHtml += '<td>' + result[i].CROWN_RUMP_LENGTH + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('CURVILINEAR_LENGTH')> -1) {
					theInnerHtml += '<td>' + result[i].CURVILINEAR_LENGTH + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('DIPLOID_NUMBER')> -1) {
					theInnerHtml += '<td>' + result[i].DIPLOID_NUMBER + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('EAR_FROM_CROWN')> -1) {
					theInnerHtml += '<td>' + result[i].EAR_FROM_CROWN + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('EAR_FROM_NOTCH')> -1) {
					theInnerHtml += '<td>' + result[i].EAR_FROM_NOTCH + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('EGG_CONTENT_WEIGHT')> -1) {
					theInnerHtml += '<td>' + result[i].EGG_CONTENT_WEIGHT + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('EGGSHELL_THICKNESS')> -1) {
					theInnerHtml += '<td>' + result[i].EGGSHELL_THICKNESS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('EMBRYO_WEIGHT')> -1) {
					theInnerHtml += '<td>' + result[i].EMBRYO_WEIGHT + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('EXTENSION')> -1) {
					theInnerHtml += '<td>' + result[i].EXTENSION + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('FAT_DEPOSITION')> -1) {
					theInnerHtml += '<td>' + result[i].FAT_DEPOSITION + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('FOREARM_LENGTH')> -1) {
					theInnerHtml += '<td>' + result[i].FOREARM_LENGTH + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('GONAD')> -1) {
					theInnerHtml += '<td>' + result[i].GONAD + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('HIND_FOOT_WITH_CLAW')> -1) {
					theInnerHtml += '<td>' + result[i].HIND_FOOT_WITH_CLAW + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('HIND_FOOT_WITHOUT_CLAW')> -1) {
					theInnerHtml += '<td>' + result[i].HIND_FOOT_WITHOUT_CLAW + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('MOLT_CONDITION')> -1) {
					theInnerHtml += '<td>' + result[i].MOLT_CONDITION + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('ABUNDANCE')> -1) {
					theInnerHtml += '<td>' + result[i].ABUNDANCE + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('NUMBER_OF_LABELS')> -1) {
					theInnerHtml += '<td>' + result[i].NUMBER_OF_LABELS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('NUMERIC_AGE')> -1) {
					theInnerHtml += '<td>' + result[i].NUMERIC_AGE + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('OVUM')> -1) {
					theInnerHtml += '<td>' + result[i].OVUM + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('REPRODUCTIVE_CONDITION')> -1) {
					theInnerHtml += '<td>' + result[i].REPRODUCTIVE_CONDITION + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('REPRODUCTIVE_DATA')> -1) {
					theInnerHtml += '<td>' + result[i].REPRODUCTIVE_DATA + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('SKULL_OSSIFICATION')> -1) {
					theInnerHtml += '<td>' + result[i].SKULL_OSSIFICATION + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('SNOUT_VENT_LENGTH')> -1) {
					theInnerHtml += '<td>' + result[i].SNOUT_VENT_LENGTH + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('SOFT_PARTS')> -1) {
					theInnerHtml += '<td>' + result[i].SOFT_PARTS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('STOMACH_CONTENTS')> -1) {
					theInnerHtml += '<td>' + result[i].STOMACH_CONTENTS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('TAIL_LENGTH')> -1) {
					theInnerHtml += '<td>' + result[i].TAIL_LENGTH + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('TOTAL_LENGTH')> -1) {
					theInnerHtml += '<td>' + result[i].TOTAL_LENGTH + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('TRAGUS_LENGTH')> -1) {
					theInnerHtml += '<td>' + result[i].TRAGUS_LENGTH + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('UNFORMATTED_MEASUREMENTS')> -1) {
					theInnerHtml += '<td>' + result[i].UNFORMATTED_MEASUREMENTS + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('VERBATIM_PRESERVATION_DATE')> -1) {
					theInnerHtml += '<td>' + result[i].VERBATIM_PRESERVATION_DATE + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('WEIGHT')> -1) {
					theInnerHtml += '<td>' + result[i].WEIGHT + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('DEC_LAT')> -1) {
					theInnerHtml += '<td style="font-size:small">' + result[i].DEC_LAT + '&nbsp;</td>';
				}
				if (result[0].COLUMNLIST.indexOf('DEC_LONG')> -1) {
					theInnerHtml += '<td style="font-size:small">' + result[i].DEC_LONG + '&nbsp;</td>';
				}
			theInnerHtml += '</tr>';
		}
		theInnerHtml += '</table>';
		tgt.innerHTML = theInnerHtml;
		if (action == 'dispCollObj'){
			makePartThingy();
		}
		insertMedia(orderedCollObjIdList);
		insertTypes(orderedCollObjIdList);
	}
}
function ssvar (startrow,maxrows) {
	alert(startrow + ' ' + maxrows);
	var s_startrow = document.getElementById('s_startrow');
	var s_torow = document.getElementById('s_torow');
	s_startrow.innerHTML = startrow;
	s_torow.innerHTML = parseInt(startrow) + parseInt(maxrows) -1;
	$.getJSON("/component/functions.cfc",
		{
			method : "ssvar",
			startrow : startrow,
			maxrows : maxrows,
			returnformat : "json",
			queryformat : 'column'
		},
	success_ssvar
	);
}
function success_ssvar(result){
	alert(result);
	ahah('SpecimenResultsTable.cfm','resultsTable');
}
function jumpToPage (v) {
	var a = v.split(",");
	var p = a[0];
	var m=a[1];
	ssvar(p,m);
}
function openCustomize() {
		var theDiv = document.createElement('div');
		theDiv.id = 'customDiv';
		theDiv.name = 'customDiv';
		theDiv.className = 'customBox';
		theDiv.innerHTML='<br>content loading....';
		theDiv.src = "";
		document.body.appendChild(theDiv);
		var guts = "/info/SpecimenResultsPrefs.cfm";
		ahah(guts,'customDiv');
	}
function closeCustom() {
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
	window.location.reload();
}
function closeCustomNoRefresh() {
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
}