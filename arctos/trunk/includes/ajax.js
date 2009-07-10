var viewport = {
  	o: function() {
      	if (self.innerHeight) {
		this.pageYOffset = self.pageYOffset;
		this.pageXOffset = self.pageXOffset;
		this.innerHeight = self.innerHeight;
		this.innerWidth = self.innerWidth;
	} else if (document.documentElement && document.documentElement.clientHeight) {
		this.pageYOffset = document.documentElement.scrollTop;
		this.pageXOffset = document.documentElement.scrollLeft;
		this.innerHeight = document.documentElement.clientHeight;
		this.innerWidth = document.documentElement.clientWidth;
	} else if (document.body) {
		this.pageYOffset = document.body.scrollTop;
		this.pageXOffset = document.body.scrollLeft;
		this.innerHeight = document.body.clientHeight;
		this.innerWidth = document.body.clientWidth;
	}
	return this;
   },
   init: function(el) {
       jQuery(el).css("left",Math.round(viewport.o().innerWidth/2) + viewport.o().pageXOffset - Math.round(jQuery(el).width()/2));
       jQuery(el).css("top",Math.round(viewport.o().innerHeight/2) + viewport.o().pageYOffset - Math.round(jQuery(el).height()/2));
       }
   };
function saveSearch(returnURL){
	var sName=prompt("Name this search", "my search");
	if (sName!==null){
		var sn=encodeURIComponent(sName);
		var ru=encodeURI(returnURL);
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "saveSearch",
				returnURL : ru,
				srchName : sn,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				if(r!='success'){
					alert(r);
				}
			}
		);
	}
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
	);
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
				sBox=document.getElementById('ajaxStatus');
				document.body.removeChild(sBox);
			}
		}
	);
}
function success_addPartToLoan(result) {
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
		success_addPartToLoan
	);
}
function success_makePartThingy(r){
	result=r.DATA;
	var lastID;
	var theTable;
	for (i=0; i<r.ROWCOUNT; ++i) {
		var cid = 'partCell_' + result.COLLECTION_OBJECT_ID[i];
		if (document.getElementById(cid)){
			var theCell = document.getElementById(cid);
			theCell.innerHTML='Fetching loan data....';
		if (lastID == result.COLLECTION_OBJECT_ID[i]) {
			theTable += "<tr>";
		} else {
			theTable = '<table border width="100%"><tr>';
		}
		theTable += '<td nowrap="nowrap" class="specResultPartCell">';
		theTable += '<i>' + result.PART_NAME[i];
		if (result.SAMPLED_FROM_OBJ_ID[i] > 0) {
			theTable += '&nbsp;sample';
		}
		theTable += result.COLLECTION_OBJECT_ID[i] + "&nbsp;(" + result.COLL_OBJ_DISPOSITION[i] + ")</i>";
		theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
		theTable += 'Remark:&nbsp;<input type="text" name="item_remark" size="10" id="item_remark_' + result.PARTID[i] + '">';
		theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
		theTable += 'Instr.:&nbsp;<input type="text" name="item_instructions" size="10" id="item_instructions_' + result.PARTID[i] + '">';
		theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
		theTable += 'Subsample?:&nbsp;<input type="checkbox" name="subsample" id="subsample_' + result.PARTID[i] + '">';
		theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
		theTable += '<input type="button" id="theButton_' + result.PARTID[i] + '"';
		theTable += ' class="insBtn"';
		if (result.TRANSACTION_ID[i] > 0) {
			theTable += ' onclick="" value="In Loan">';
		} else {
			theTable += ' value="Add" onclick="addPartToLoan(';
			theTable += result.PARTID[i] + ');">';
		}
		if (result.ENCUMBRANCE_ACTION[i]!==null) {
			theTable += '<br><i>Encumbrances:&nbsp;' + result.ENCUMBRANCE_ACTION[i] + '</i>';
		}
		theTable +="</td>";
		if (result.COLLECTION_OBJECT_ID[i+1] && result.COLLECTION_OBJECT_ID[i+1] == result.COLLECTION_OBJECT_ID[i]) {
			theTable += "</tr>";
		} else {
			theTable += "</tr></table>";
			theCell.innerHTML = theTable;
		}
		lastID = result.COLLECTION_OBJECT_ID[i];
	} else {
		}
	}
}
function makePartThingy() {
	var transaction_id = document.getElementById("transaction_id").value;
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "getLoanPartResults",
			transaction_id : transaction_id,
			returnformat : "json",
			queryformat : 'column'
		},
		success_makePartThingy
	);	
}
function cordFormat(str) {
	var rStr;
	if (str==null) {
		rStr='';
	} else {
		rStr = str;
		var rExp = /s/gi;
		rStr = rStr.replace(rExp,"\'\'");
		rExp = /d/gi;
		rStr = rStr.replace(rExp,'<sup>o</sup>');
		rExp = /m/gi;
		rStr = rStr.replace(rExp,"\'");
		rExp = / /gi;
		rStr = rStr.replace(rExp,'&nbsp;');
	}
	return rStr;
}

function spaceStripper(str) {
	str=String(str);
	var rStr;
	if (str==null) {
		rStr='';
	} else {
		rStr = str.replace(/ /gi,'&nbsp;');
	}
	return rStr;
}
function splitByComma(str) {
	var rStr;
	if (str==null) {
		rStr='';
	} else {
		var rExp = /, /gi;
		rStr = str.replace(rExp,'<br>');
		rExp = / /gi;
		rStr = rStr.replace(rExp,'&nbsp;');
	}
	return rStr;
}
function splitBySemicolon(str) {
	var rStr;
	if (str==null) {
		rStr='';
	} else {
		var rExp = /; /gi;
		rStr = str.replace(rExp,'<br>');
		rExp = / /gi;
		rStr = rStr.replace(rExp,'&nbsp;');
	}
	return rStr;
}

var dateFormat = function () {
	var	token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
		timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
		timezoneClip = /[^-+\dA-Z]/g,
		pad = function (val, len) {
			val = String(val);
			len = len || 2;
			while (val.length < len) val = "0" + val;
			return val;
		};

	// Regexes and supporting functions are cached through closure
	return function (date, mask, utc) {
		var dF = dateFormat;

		// You can't provide utc if you skip other args (use the "UTC:" mask prefix)
		if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
			mask = date;
			date = undefined;
		}

		// Passing date through Date applies Date.parse, if necessary
		date = date ? new Date(date) : new Date;
		if (isNaN(date)) throw SyntaxError("invalid date");

		mask = String(dF.masks[mask] || mask || dF.masks["default"]);

		// Allow setting the utc argument via the mask
		if (mask.slice(0, 4) == "UTC:") {
			mask = mask.slice(4);
			utc = true;
		}

		var	_ = utc ? "getUTC" : "get",
			d = date[_ + "Date"](),
			D = date[_ + "Day"](),
			m = date[_ + "Month"](),
			y = date[_ + "FullYear"](),
			H = date[_ + "Hours"](),
			M = date[_ + "Minutes"](),
			s = date[_ + "Seconds"](),
			L = date[_ + "Milliseconds"](),
			o = utc ? 0 : date.getTimezoneOffset(),
			flags = {
				d:    d,
				dd:   pad(d),
				ddd:  dF.i18n.dayNames[D],
				dddd: dF.i18n.dayNames[D + 7],
				m:    m + 1,
				mm:   pad(m + 1),
				mmm:  dF.i18n.monthNames[m],
				mmmm: dF.i18n.monthNames[m + 12],
				yy:   String(y).slice(2),
				yyyy: y,
				h:    H % 12 || 12,
				hh:   pad(H % 12 || 12),
				H:    H,
				HH:   pad(H),
				M:    M,
				MM:   pad(M),
				s:    s,
				ss:   pad(s),
				l:    pad(L, 3),
				L:    pad(L > 99 ? Math.round(L / 10) : L),
				t:    H < 12 ? "a"  : "p",
				tt:   H < 12 ? "am" : "pm",
				T:    H < 12 ? "A"  : "P",
				TT:   H < 12 ? "AM" : "PM",
				Z:    utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
				o:    (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
				S:    ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
			};

		return mask.replace(token, function ($0) {
			return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
		});
	};
}();

dateFormat.masks = {
	"default":      "ddd mmm dd yyyy HH:MM:ss",
	shortDate:      "m/d/yy",
	mediumDate:     "mmm d, yyyy",
	longDate:       "mmmm d, yyyy",
	fullDate:       "dddd, mmmm d, yyyy",
	shortTime:      "h:MM TT",
	mediumTime:     "h:MM:ss TT",
	longTime:       "h:MM:ss TT Z",
	isoDate:        "yyyy-mm-dd",
	isoTime:        "HH:MM:ss",
	isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss",
	isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
};

//Internationalization strings
dateFormat.i18n = {
	dayNames: [
		"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
		"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
	],
	monthNames: [
		"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
		"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
	]
};

//For convenience...
Date.prototype.format = function (mask, utc) {
	return dateFormat(this, mask, utc);
};


function success_crcloo (result) {
	return false;
}												
function crcloo (ColumnList,in_or_out) {
	jQuery.getJSON("/component/functions.cfc",
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
function checkAllById(list) {
	var a = list.split(',');
	for (i=0; i<a.length; ++i) {
		if (document.getElementById(a[i])) {
			document.getElementById(a[i]).checked=true;
			crcloo(a[i],'in');
		}
	}
}

function uncheckAllById(list) {
	crcloo(list,'out');
	var a = list.split(',');
	for (i=0; i<a.length; ++i) {
		if (document.getElementById(a[i])) {
			document.getElementById(a[i]).checked=false;
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
		var theArray = [];
		if (theEl.value.length > 0) {
			theArray = theEl.value.split(',');
		}
		theArray.push(id);
		var theString = theArray.join(",");
		theEl.value = theString;
	} else {
		var theArray = theEl.value.split(',');
		for (i=0; i<theArray.length; ++i) {
			//alert(theArray[i]);
			if (theArray[i] == id) {
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
	if (orderBy==null) {
		if (document.getElementById('orderBy1') && document.getElementById('orderBy1')) {
			var o1=document.getElementById('orderBy1').value; 
			var o2=document.getElementById('orderBy2').value;
			var orderBy = o1 + ',' + o2;
		} else {
			var orderBy = 'cat_num';
		}		
	}
	if (orderOrder==null) {
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
	//console.log("startrow:"+startrow+"; numrecs:"+numrecs + '; orderBy:' + orderBy + '; orderOrder:' + orderOrder + ":end:");
	jQuery.getJSON("/component/functions.cfc",
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
	var data = result.DATA;
	var collection_object_id = data.COLLECTION_OBJECT_ID[0];
	if (collection_object_id < 1) {
		var msg = data.message[0];
		alert(msg);
	} else {
		var clist = data.COLUMNLIST[0];
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
			if (data.COLUMNLIST[0].indexOf('CUSTOMID')> -1) {
				theInnerHtml += '<th>';
					theInnerHtml += data.MYCUSTOMIDTYPE[0];
				theInnerHtml += '</th>';
			}
			theInnerHtml += '<th>Identification</th>';
			if (data.COLUMNLIST[0].indexOf('SCI_NAME_WITH_AUTH')> -1) {
				theInnerHtml += '<th>Scientific&nbsp;Name</th>';
			}
			if (data.COLUMNLIST[0].indexOf('IDENTIFIED_BY')> -1) {
				theInnerHtml += '<th>Identified&nbsp;By</th>';
			}
			if (data.COLUMNLIST[0].indexOf('PHYLORDER')> -1) {
				theInnerHtml += '<th>Order</th>';
			}
			if (data.COLUMNLIST[0].indexOf('FAMILY')> -1) {
				theInnerHtml += '<th>Family</th>';
			}
			if (data.COLUMNLIST[0].indexOf('OTHERCATALOGNUMBERS')> -1) {
				theInnerHtml += '<th>Other&nbsp;Identifiers</th>';
			}
			if (data.COLUMNLIST[0].indexOf('ACCESSION')> -1) {
				theInnerHtml += '<th>Accession</th>';
			}
			if (data.COLUMNLIST[0].indexOf('COLLECTORS')> -1) {
				theInnerHtml += '<th>Collectors</th>';
			}
			if (data.COLUMNLIST[0].indexOf('VERBATIMLATITUDE')> -1) {
				theInnerHtml += '<th>Latitude</th>';
			}
			if (data.COLUMNLIST[0].indexOf('VERBATIMLONGITUDE')> -1) {
				theInnerHtml += '<th>Longitude</th>';
			}
			if (data.COLUMNLIST[0].indexOf('COORDINATEUNCERTAINTYINMETERS')> -1) {
				theInnerHtml += '<th>Max&nbsp;Error&nbsp;(m)</th>';
			}
			if (data.COLUMNLIST[0].indexOf('DATUM')> -1) {
				theInnerHtml += '<th>Datum</th>';
			}
			if (data.COLUMNLIST[0].indexOf('ORIG_LAT_LONG_UNITS')> -1) {
				theInnerHtml += '<th>Original&nbsp;Lat/Long&nbsp;Units</th>';
			}
			if (data.COLUMNLIST[0].indexOf('LAT_LONG_DETERMINER')> -1) {
				theInnerHtml += '<th>Georeferenced&nbsp;By</th>';
			}
			if (data.COLUMNLIST[0].indexOf('LAT_LONG_REF_SOURCE')> -1) {
				theInnerHtml += '<th>Lat/Long&nbsp;Reference</th>';
			}
			if (data.COLUMNLIST[0].indexOf('LAT_LONG_REMARKS')> -1) {
				theInnerHtml += '<th>Lat/Long&nbsp;Remarks</th>';
			}
			if (data.COLUMNLIST[0].indexOf('CONTINENT_OCEAN')> -1) {
				theInnerHtml += '<th>Continent</th>';
			}
			if (data.COLUMNLIST[0].indexOf('COUNTRY')> -1) {
				theInnerHtml += '<th>Country</th>';
			}
			if (data.COLUMNLIST[0].indexOf('STATE_PROV')> -1) {
				theInnerHtml += '<th>State</th>';
			}
			if (data.COLUMNLIST[0].indexOf('SEA')> -1) {
				theInnerHtml += '<th>Sea</th>';
			}
			if (data.COLUMNLIST[0].indexOf('QUAD')> -1) {
				theInnerHtml += '<th>Map&nbsp;Name</th>';
			}
			if (data.COLUMNLIST[0].indexOf('FEATURE')> -1) {
				theInnerHtml += '<th>Feature</th>';
			}
			if (data.COLUMNLIST[0].indexOf('COUNTY')> -1) {
				theInnerHtml += '<th>County</th>';
			}
			if (data.COLUMNLIST[0].indexOf('ISLAND_GROUP')> -1) {
				theInnerHtml += '<th>Island&nbsp;Group</th>';
			}
			if (data.COLUMNLIST[0].indexOf('ISLAND')> -1) {
				theInnerHtml += '<th>Island</th>';
			}
			if (data.COLUMNLIST[0].indexOf('ASSOCIATED_SPECIES')> -1) {
				theInnerHtml += '<th>Associated&nbsp;Species</th>';
			}
			if (data.COLUMNLIST[0].indexOf('HABITAT')> -1) {
				theInnerHtml += '<th>Microhabitat</th>';
			}
			if (data.COLUMNLIST[0].indexOf('MIN_ELEV_IN_M')> -1) {
				theInnerHtml += '<th>Min&nbsp;Elevation&nbsp;(m)</th>';
			}
			if (data.COLUMNLIST[0].indexOf('MAX_ELEV_IN_M')> -1) {
				theInnerHtml += '<th>Max&nbsp;Elevation&nbsp;(m)</th>';
			}
			if (data.COLUMNLIST[0].indexOf('MINIMUM_ELEVATION')> -1) {
				theInnerHtml += '<th>Min&nbsp;Elevation</th>';
			}
			if (data.COLUMNLIST[0].indexOf('MAXIMUM_ELEVATION')> -1) {
				theInnerHtml += '<th>Max&nbsp;Elevation</th>';
			}
			if (data.COLUMNLIST[0].indexOf('ORIG_ELEV_UNITS')> -1) {
				theInnerHtml += '<th>Elevation&nbsp;Units</th>';
			}
			if (data.COLUMNLIST[0].indexOf('SPEC_LOCALITY')> -1) {
				theInnerHtml += '<th>Specific&nbsp;Locality</th>';
			}			
			if (data.COLUMNLIST[0].indexOf('GEOLOGY_ATTRIBUTES')> -1) {
				theInnerHtml += '<th>Geology&nbsp;Attributes</th>';
			}
			
			if (data.COLUMNLIST[0].indexOf('VERBATIM_DATE')> -1) {
				theInnerHtml += '<th>Verbatim&nbsp;Date</th>';
			}
			if (data.COLUMNLIST[0].indexOf('BEGAN_DATE')> -1) {
				theInnerHtml += '<th>Began&nbsp;Date</th>';
			}
			if (data.COLUMNLIST[0].indexOf('ENDED_DATE')> -1) {
				theInnerHtml += '<th>Ended&nbsp;Date</th>';
			}
			if (data.COLUMNLIST[0].indexOf('PARTS')> -1) {
				theInnerHtml += '<th>Parts</th>';
			}
			if (data.COLUMNLIST[0].indexOf('SEX')> -1) {
				theInnerHtml += '<th>Sex</th>';
			}
			if (data.COLUMNLIST[0].indexOf('REMARKS')> -1) {
				theInnerHtml += '<th>Specimen&nbsp;Remarks</th>';
			}
			if (data.COLUMNLIST[0].indexOf('COLL_OBJ_DISPOSITION')> -1) {
				theInnerHtml += '<th>Specimen&nbsp;Disposition</th>';
			}
			// attribtues
			if (data.COLUMNLIST[0].indexOf('SNV_RESULTS')> -1) {
				theInnerHtml += '<th>SNV&nbsp;Results</th>';
			}
			if (data.COLUMNLIST[0].indexOf('AGE') > -1) {
				theInnerHtml += '<th>Age</th>';
			} 
			if (data.COLUMNLIST[0].indexOf('AGE_CLASS')> -1) {
				theInnerHtml += '<th>Age&nbsp;Class</th>';
			}
			if (data.COLUMNLIST[0].indexOf('AXILLARY_GIRTH')> -1) {
				theInnerHtml += '<th>Axillary&nbsp;Girth</th>';
			}
			if (data.COLUMNLIST[0].indexOf('BODY_CONDITION')> -1) {
				theInnerHtml += '<th>Body&nbsp;Condition</th>';
			}
			if (data.COLUMNLIST[0].indexOf('BREADTH')> -1) {
				theInnerHtml += '<th>Breadth</th>';
			}
			if (data.COLUMNLIST[0].indexOf('BURSA')> -1) {
				theInnerHtml += '<th>Bursa</th>';
			}
			if (data.COLUMNLIST[0].indexOf('CASTE')> -1) {
				theInnerHtml += '<th>Caste</th>';
			}
			if (data.COLUMNLIST[0].indexOf('COLORS')> -1) {
				theInnerHtml += '<th>Colors</th>';
			}
			if (data.COLUMNLIST[0].indexOf('CROWN_RUMP_LENGTH')> -1) {
				theInnerHtml += '<th>Crown-Rump&nbsp;Length</th>';
			}
			if (data.COLUMNLIST[0].indexOf('CURVILINEAR_LENGTH')> -1) {
				theInnerHtml += '<th>Curvilinear&nbsp;Length</th>';
			}
			if (data.COLUMNLIST[0].indexOf('DIPLOID_NUMBER')> -1) {
				theInnerHtml += '<th>Diploid&nbsp;Number</th>';
			}
			if (data.COLUMNLIST[0].indexOf('EAR_FROM_CROWN')> -1) {
				theInnerHtml += '<th>Ear&nbsp;From&nbsp;Crown</th>';
			}
			if (data.COLUMNLIST[0].indexOf('EAR_FROM_NOTCH')> -1) {
				theInnerHtml += '<th>Ear&nbsp;From&nbsp;Notch</th>';
			}
			if (data.COLUMNLIST[0].indexOf('EGG_CONTENT_WEIGHT')> -1) {
				theInnerHtml += '<th>Egg&nbsp;Content&nbsp;Weight</th>';
			}
			if (data.COLUMNLIST[0].indexOf('EGGSHELL_THICKNESS')> -1) {
				theInnerHtml += '<th>Eggshell&nbsp;Thickness</th>';
			}
			if (data.COLUMNLIST[0].indexOf('EMBRYO_WEIGHT')> -1) {
				theInnerHtml += '<th>Embryo&nbsp;Weight</th>';
			}
			if (data.COLUMNLIST[0].indexOf('EXTENSION')> -1) {
				theInnerHtml += '<th>Extension</th>';
			}
			if (data.COLUMNLIST[0].indexOf('FAT_DEPOSITION')> -1) {
				theInnerHtml += '<th>Fat&nbsp;Deposition</th>';
			}
			if (data.COLUMNLIST[0].indexOf('FOREARM_LENGTH')> -1) {
				theInnerHtml += '<th>Forearm&nbsp;Length</th>';
			}
			if (data.COLUMNLIST[0].indexOf('GONAD')> -1) {
				theInnerHtml += '<th>Gonad</th>';
			}
			if (data.COLUMNLIST[0].indexOf('HIND_FOOT_WITH_CLAW')> -1) {
				theInnerHtml += '<th>Hind&nbsp;Foot&nbsp;With&nbsp;Claw</th>';
			}
			if (data.COLUMNLIST[0].indexOf('HIND_FOOT_WITHOUT_CLAW')> -1) {
				theInnerHtml += '<th>Hind&nbsp;Foot&nbsp;Without&nbsp;Claw</th>';
			}
			if (data.COLUMNLIST[0].indexOf('MOLT_CONDITION')> -1) {
				theInnerHtml += '<th>Molt&nbsp;Condition</th>';
			}
			if (data.COLUMNLIST[0].indexOf('ABUNDANCE')> -1) {
				theInnerHtml += '<th>Abundance</th>';
			}
			if (data.COLUMNLIST[0].indexOf('NUMBER_OF_LABELS')> -1) {
				theInnerHtml += '<th>Number&nbsp;Of&nbsp;Labels</th>';
			}
			if (data.COLUMNLIST[0].indexOf('NUMERIC_AGE')> -1) {
				theInnerHtml += '<th>Numeric&nbsp;Age</th>';
			}
			if (data.COLUMNLIST[0].indexOf('OVUM')> -1) {
				theInnerHtml += '<th>Ovum</th>';
			}
			if (data.COLUMNLIST[0].indexOf('REPRODUCTIVE_CONDITION')> -1) {
				theInnerHtml += '<th>Reproductive&nbsp;Condition</th>';
			}
			if (data.COLUMNLIST[0].indexOf('REPRODUCTIVE_DATA')> -1) {
				theInnerHtml += '<th>Reproductive&nbsp;Data</th>';
			}
			if (data.COLUMNLIST[0].indexOf('SKULL_OSSIFICATION')> -1) {
				theInnerHtml += '<th>Skull&nbsp;Ossification</th>';
			}
			if (data.COLUMNLIST[0].indexOf('SNOUT_VENT_LENGTH')> -1) {
				theInnerHtml += '<th>Snout-Vent&nbsp;Length</th>';
			}
			if (data.COLUMNLIST[0].indexOf('SOFT_PARTS')> -1) {
				theInnerHtml += '<th>Soft&nbsp;Parts</th>';
			}
			if (data.COLUMNLIST[0].indexOf('STOMACH_CONTENTS')> -1) {
				theInnerHtml += '<th>Stomach&nbsp;Contents</th>';
			}
			if (data.COLUMNLIST[0].indexOf('TAIL_LENGTH')> -1) {
				theInnerHtml += '<th>Tail&nbsp;Length</th>';
			}
			if (data.COLUMNLIST[0].indexOf('TOTAL_LENGTH')> -1) {
				theInnerHtml += '<th>Total&nbsp;Length</th>';
			}
			if (data.COLUMNLIST[0].indexOf('TRAGUS_LENGTH')> -1) {
				theInnerHtml += '<th>Tragus&nbsp;Length</th>';
			}
			if (data.COLUMNLIST[0].indexOf('UNFORMATTED_MEASUREMENTS')> -1) {
				theInnerHtml += '<th>Unformatted&nbsp;Measurements</th>';
			}
			if (data.COLUMNLIST[0].indexOf('VERBATIM_PRESERVATION_DATE')> -1) {
				theInnerHtml += '<th>Verbatim&nbsp;Preservatin&nbsp;Date</th>';
			}
			if (data.COLUMNLIST[0].indexOf('WEIGHT')> -1) {
				theInnerHtml += '<th>Weight</th>';
			}
			if (data.COLUMNLIST[0].indexOf('DEC_LAT')> -1) {
				theInnerHtml += '<th>Dec.&nbsp;Lat.</th>';
			}
			if (data.COLUMNLIST[0].indexOf('DEC_LONG')> -1) {
				theInnerHtml += '<th>Dec.&nbsp;Long.</th>';
			}
			if (data.COLUMNLIST[0].indexOf('GREF_COLLNUM') > -1) {
				theInnerHtml += '<th>Gref&nbsp;Link</th>';
			}
		theInnerHtml += '</tr>';
		// get an ordered list of collection_object_ids to pass on to 
		// SpecimenDetail for browsing
		var orderedCollObjIdArray = new Array();		
		for (i=0; i<result.ROWCOUNT; ++i) {
			orderedCollObjIdArray.push(data.COLLECTION_OBJECT_ID[i]);
		}
		var orderedCollObjIdList='';
		if (orderedCollObjIdArray.length < 100) {
			var orderedCollObjIdList = orderedCollObjIdArray.join(",");
		}
		for (i=0; i<result.ROWCOUNT; ++i) {
			orderedCollObjIdArray.push(data.COLLECTION_OBJECT_ID[i]);
			theInnerHtml += '<tr>';
				if (killrow == 1){
					theInnerHtml += '<td align="center"><input type="checkbox" onchange="toggleKillrow(' + "'";
					theInnerHtml +=data.COLLECTION_OBJECT_ID[i] + "'" + ',this.checked);"></td>';
				}
				theInnerHtml += '<td nowrap="nowrap" id="CatItem_'+data.COLLECTION_OBJECT_ID[i]+'">';
					theInnerHtml += '<a href="SpecimenDetail.cfm?collection_object_id=';
					theInnerHtml += data.COLLECTION_OBJECT_ID[i];
					theInnerHtml += '">';
					theInnerHtml += data.COLLECTION[i];
					theInnerHtml += '&nbsp;';
					theInnerHtml += data.CAT_NUM[i];
					theInnerHtml += '</a>';
				theInnerHtml += '</td>';
				if (loan_request_coll_id.length > 0) {
					if (loan_request_coll_id == data.COLLECTION_ID[i]){
						theInnerHtml +='<td><span class="likeLink" onclick="addLoanItem(' + "'";
						theInnerHtml += data.COLLECTION_OBJECT_ID;
						theInnerHtml += "');" + '">Request</span></td>';
					} else {
						theInnerHtml +='<td>N/A</td>';
					}
				}
				if (action == 'dispCollObj'){
					theInnerHtml +='<td id="partCell_' + data.COLLECTION_OBJECT_ID[i] + '"></td>';
				}				
				if (data.COLUMNLIST[0].indexOf('CUSTOMID')> -1) {
					theInnerHtml += '<td>';
						theInnerHtml += data.CUSTOMID[i] + '&nbsp;';
					theInnerHtml += '</td>';
				}
				theInnerHtml += '<td>';
				theInnerHtml += '<span class="browseLink" type="scientific_name" dval="' + encodeURI(data.SCIENTIFIC_NAME[i]) + '">' + spaceStripper(data.SCIENTIFIC_NAME[i]);
				theInnerHtml += '</span>'; 					
				theInnerHtml += '</td>';
				if (data.COLUMNLIST[0].indexOf('SCI_NAME_WITH_AUTH')> -1) {
					theInnerHtml += '<td>';
						theInnerHtml += spaceStripper(data.SCI_NAME_WITH_AUTH[i]);
					theInnerHtml += '</td>';
				}
				if (data.COLUMNLIST[0].indexOf('IDENTIFIED_BY')> -1) {
					theInnerHtml += '<td>' + splitBySemicolon(data.IDENTIFIED_BY[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('PHYLORDER')> -1) {
					theInnerHtml += '<td>' + data.PHYLORDER[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('FAMILY')> -1) {
					theInnerHtml += '<td>' + data.FAMILY[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('OTHERCATALOGNUMBERS')> -1) {
					theInnerHtml += '<td>' + splitBySemicolon(data.OTHERCATALOGNUMBERS[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('ACCESSION')> -1) {
					theInnerHtml += '<td>' + spaceStripper(data.ACCESSION[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('COLLECTORS')> -1) {
					theInnerHtml += '<td>' + splitByComma(data.COLLECTORS[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('VERBATIMLATITUDE')> -1) {
					theInnerHtml += '<td>' + cordFormat(data.VERBATIMLATITUDE[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('VERBATIMLONGITUDE')> -1) {
					theInnerHtml += '<td>' + cordFormat(data.VERBATIMLONGITUDE[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('COORDINATEUNCERTAINTYINMETERS')> -1) {
					theInnerHtml += '<td>' + data.COORDINATEUNCERTAINTYINMETERS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('DATUM')> -1) {
					theInnerHtml += '<td>' + spaceStripper(data.DATUM[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('ORIG_LAT_LONG_UNITS')> -1) {
					theInnerHtml += '<td>' + data.ORIG_LAT_LONG_UNITS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('LAT_LONG_DETERMINER')> -1) {
					theInnerHtml += '<td>' + splitBySemicolon(data.LAT_LONG_DETERMINER[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('LAT_LONG_REF_SOURCE')> -1) {
					theInnerHtml += '<td>' + data.LAT_LONG_REF_SOURCE[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('LAT_LONG_REMARKS')> -1) {
					theInnerHtml += '<td><div class="wrapLong">' + data.LAT_LONG_REMARKS[i] + '</div></td>';
				}
				if (data.COLUMNLIST[0].indexOf('CONTINENT_OCEAN')> -1) {
					theInnerHtml += '<td>' + spaceStripper(data.CONTINENT_OCEAN[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('COUNTRY')> -1) {
					theInnerHtml += '<td>' + spaceStripper(data.COUNTRY[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('STATE_PROV')> -1) {
					theInnerHtml += '<td>' + spaceStripper(data.STATE_PROV[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('SEA')> -1) {
					theInnerHtml += '<td>' + data.SEA[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('QUAD')> -1) {
					theInnerHtml += '<td>' + spaceStripper(data.QUAD[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('FEATURE')> -1) {
					theInnerHtml += '<td>' + spaceStripper(data.FEATURE[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('COUNTY')> -1) {
					theInnerHtml += '<td>' + data.COUNTY[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('ISLAND_GROUP')> -1) {
					theInnerHtml += '<td>' + spaceStripper(data.ISLAND_GROUP[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('ISLAND')> -1) {
					theInnerHtml += '<td>' + spaceStripper(data.ISLAND[i]) + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('ASSOCIATED_SPECIES')> -1) {
					theInnerHtml += '<td><div class="wrapLong">' + data.ASSOCIATED_SPECIES[i] + '</div></td>';
				}
				if (data.COLUMNLIST[0].indexOf('HABITAT')> -1) {
					theInnerHtml += '<td><div class="wrapLong">' + data.HABITAT[i] + '</div></td>';
				}
				if (data.COLUMNLIST[0].indexOf('MIN_ELEV_IN_M')> -1) {
					theInnerHtml += '<td>' + data.MIN_ELEV_IN_M[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('MAX_ELEV_IN_M')> -1) {
					theInnerHtml += '<td>' + data.MAX_ELEV_IN_M[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('MINIMUM_ELEVATION')> -1) {
					theInnerHtml += '<td>' + data.MINIMUM_ELEVATION[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('MAXIMUM_ELEVATION')> -1) {
					theInnerHtml += '<td>' + data.MAXIMUM_ELEVATION[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('ORIG_ELEV_UNITS')> -1) {
					theInnerHtml += '<td>' + data.ORIG_ELEV_UNITS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('SPEC_LOCALITY')> -1) {
					theInnerHtml += '<td id="SpecLocality_'+data.COLLECTION_OBJECT_ID[i] + '">';
					theInnerHtml += '<span class="browseLink" type="spec_locality" dval="' + encodeURI(data.SPEC_LOCALITY[i]) + '"><div class="wrapLong">' + data.SPEC_LOCALITY[i] + '</div>';
					theInnerHtml += '</span>'; 					
					theInnerHtml += '</td>';
				}
				
				if (data.COLUMNLIST[0].indexOf('GEOLOGY_ATTRIBUTES')> -1) {
					theInnerHtml += '<td>' + data.GEOLOGY_ATTRIBUTES[i] + '&nbsp;</td>';
				}
				
			
				if (data.COLUMNLIST[0].indexOf('VERBATIM_DATE')> -1) {
					theInnerHtml += '<td>' + data.VERBATIM_DATE[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('BEGAN_DATE')> -1) {
					theInnerHtml += '<td>' + dateFormat(data.BEGAN_DATE[i],"d mmm yyyy") + '</td>';
				}
				if (data.COLUMNLIST[0].indexOf('ENDED_DATE')> -1) {
					theInnerHtml += '<td>' + dateFormat(data.ENDED_DATE[i],"d mmm yyyy") + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('PARTS')> -1) {
					theInnerHtml += '<td><div class="wrapLong">' + splitBySemicolon(data.PARTS[i]) + '</div></td>';
				}
				if (data.COLUMNLIST[0].indexOf('SEX')> -1) {
					theInnerHtml += '<td>' + data.SEX[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('REMARKS')> -1) {
					theInnerHtml += '<td>' + data.REMARKS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('COLL_OBJ_DISPOSITION')> -1) {
					theInnerHtml += '<td>' + data.COLL_OBJ_DISPOSITION[i] + '&nbsp;</td>';
				}
				// attributes
				if (data.COLUMNLIST[0].indexOf('SNV_RESULTS')> -1) {
					theInnerHtml += '<td>' + data.SNV_RESULTS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('AGE')> -1) {
					theInnerHtml += '<td>' + data.AGE[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('AGE_CLASS')> -1) {
					theInnerHtml += '<td>' + data.AGE_CLASS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('AXILLARY_GIRTH')> -1) {
					theInnerHtml += '<td>' + data.AXILLARY_GIRTH[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('BODY_CONDITION')> -1) {
					theInnerHtml += '<td>' + data.BODY_CONDITION[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('BREADTH')> -1) {
					theInnerHtml += '<td>' + data.BREADTH[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('BURSA')> -1) {
					theInnerHtml += '<td>' + data.BURSA[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('CASTE')> -1) {
					theInnerHtml += '<td>' + data.CASTE[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('COLORS')> -1) {
					theInnerHtml += '<td>' + data.COLORS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('CROWN_RUMP_LENGTH')> -1) {
					theInnerHtml += '<td>' + data.CROWN_RUMP_LENGTH[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('CURVILINEAR_LENGTH')> -1) {
					theInnerHtml += '<td>' + data.CURVILINEAR_LENGTH[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('DIPLOID_NUMBER')> -1) {
					theInnerHtml += '<td>' + data.DIPLOID_NUMBER[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('EAR_FROM_CROWN')> -1) {
					theInnerHtml += '<td>' + data.EAR_FROM_CROWN[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('EAR_FROM_NOTCH')> -1) {
					theInnerHtml += '<td>' + data.EAR_FROM_NOTCH[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('EGG_CONTENT_WEIGHT')> -1) {
					theInnerHtml += '<td>' + data.EGG_CONTENT_WEIGHT[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('EGGSHELL_THICKNESS')> -1) {
					theInnerHtml += '<td>' + data.EGGSHELL_THICKNESS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('EMBRYO_WEIGHT')> -1) {
					theInnerHtml += '<td>' + data.EMBRYO_WEIGHT[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('EXTENSION')> -1) {
					theInnerHtml += '<td>' + data.EXTENSION[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('FAT_DEPOSITION')> -1) {
					theInnerHtml += '<td>' + data.FAT_DEPOSITION[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('FOREARM_LENGTH')> -1) {
					theInnerHtml += '<td>' + data.FOREARM_LENGTH[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('GONAD')> -1) {
					theInnerHtml += '<td>' + data.GONAD[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('HIND_FOOT_WITH_CLAW')> -1) {
					theInnerHtml += '<td>' + data.HIND_FOOT_WITH_CLAW[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('HIND_FOOT_WITHOUT_CLAW')> -1) {
					theInnerHtml += '<td>' + data.HIND_FOOT_WITHOUT_CLAW[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('MOLT_CONDITION')> -1) {
					theInnerHtml += '<td>' + data.MOLT_CONDITION[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('ABUNDANCE')> -1) {
					theInnerHtml += '<td>' + data.ABUNDANCE[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('NUMBER_OF_LABELS')> -1) {
					theInnerHtml += '<td>' + data.NUMBER_OF_LABELS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('NUMERIC_AGE')> -1) {
					theInnerHtml += '<td>' + data.NUMERIC_AGE[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('OVUM')> -1) {
					theInnerHtml += '<td>' + data.OVUM[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('REPRODUCTIVE_CONDITION')> -1) {
					theInnerHtml += '<td>' + data.REPRODUCTIVE_CONDITION[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('REPRODUCTIVE_DATA')> -1) {
					theInnerHtml += '<td>' + data.REPRODUCTIVE_DATA[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('SKULL_OSSIFICATION')> -1) {
					theInnerHtml += '<td>' + data.SKULL_OSSIFICATION[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('SNOUT_VENT_LENGTH')> -1) {
					theInnerHtml += '<td>' + data.SNOUT_VENT_LENGTH[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('SOFT_PARTS')> -1) {
					theInnerHtml += '<td>' + data.SOFT_PARTS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('STOMACH_CONTENTS')> -1) {
					theInnerHtml += '<td>' + data.STOMACH_CONTENTS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('TAIL_LENGTH')> -1) {
					theInnerHtml += '<td>' + data.TAIL_LENGTH[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('TOTAL_LENGTH')> -1) {
					theInnerHtml += '<td>' + data.TOTAL_LENGTH[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('TRAGUS_LENGTH')> -1) {
					theInnerHtml += '<td>' + data.TRAGUS_LENGTH[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('UNFORMATTED_MEASUREMENTS')> -1) {
					theInnerHtml += '<td>' + data.UNFORMATTED_MEASUREMENTS[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('VERBATIM_PRESERVATION_DATE')> -1) {
					theInnerHtml += '<td>' + data.VERBATIM_PRESERVATION_DATE[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('WEIGHT')> -1) {
					theInnerHtml += '<td>' + data.WEIGHT[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('DEC_LAT')> -1) {
					theInnerHtml += '<td style="font-size:small">' + data.DEC_LAT[i] + '&nbsp;</td>';
				}
				if (data.COLUMNLIST[0].indexOf('DEC_LONG')> -1) {
					theInnerHtml += '<td style="font-size:small">' + data.DEC_LONG[i] + '&nbsp;</td>';
				}
			theInnerHtml += '</tr>';
		}
		theInnerHtml += '</table>';		
	    theInnerHtml = theInnerHtml.replace(/null/g,""); 
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
	jQuery.getJSON("/component/functions.cfc",
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
function jumpToPage (v) {
	var a = v.split(",");
	var p = a[0];
	var m=a[1];
	ssvar(p,m);
}
function closeCustom() {
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
	var murl='/SpecimenResults.cfm?' + document.getElementById('mapURL').value;
	window.location=murl;
}
function closeCustomNoRefresh() {
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);	
	var theDiv = document.getElementById('bgDiv');
	document.body.removeChild(theDiv);
}
function findAccession () {
	var collection_id=document.getElementById('collection_id').value;
	var accn_number=document.getElementById('accn_number').value;
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "findAccession",
			collection_id : collection_id,
			accn_number : accn_number,
			returnformat : "json",
			queryformat : 'column'
		},
		success_findAccession
	);
}
function success_findAccession(result) {
	if(result>0) {
		document.getElementById('g_num').className='doShow';
		document.getElementById('b_num').className='noShow';
	} else {
		document.getElementById('g_num').className='noShow';
		document.getElementById('b_num').className='doShow';
	}
}
function logIt(msg,status) {
	var mDiv=document.getElementById('msgs');
	var mhDiv=document.getElementById('msgs_hist');
	var mh=mDiv.innerHTML + '<hr>' + mhDiv.innerHTML;
	mhDiv.innerHTML=mh;
	mDiv.innerHTML=msg;
	if (status==0){
		mDiv.className='error';
	} else {
		mDiv.className='successDiv';
		document.getElementById('oidnum').focus();
		document.getElementById('oidnum').select();
	}
}
function addPartToContainer () {
	document.getElementById('pTable').className='red';
	var cid=document.getElementById('collection_object_id').value;
	var pid1=document.getElementById('part_name').value;
	var pid2=document.getElementById('part_name_2').value;
	var parent_barcode=document.getElementById('parent_barcode').value;
	var new_container_type=document.getElementById('new_container_type').value;
	if(cid.length==0 || pid1.length==0 || parent_barcode.length==0) {
		alert('Something is null');
		return false;
	}
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "addPartToContainer",
			collection_object_id : cid,
			part_id : pid1,
			part_id2 : pid2,
			parent_barcode : parent_barcode,
			new_container_type : new_container_type,
			returnformat : "json",
			queryformat : 'column'
		},
		success_addPartToContainer
	);
}
function success_addPartToContainer(result) {
	statAry=result.split("|");
	var status=statAry[0];
	var msg=statAry[1];
	document.getElementById('pTable').className='';
	var mDiv=document.getElementById('msgs');
	var mhDiv=document.getElementById('msgs_hist');
	var mh=mDiv.innerHTML + '<hr>' + mhDiv.innerHTML;
	mhDiv.innerHTML=mh;
	mDiv.innerHTML=msg;
	if (status==0){
		mDiv.className='error';
	} else {
		mDiv.className='successDiv';
		document.getElementById('oidnum').focus();
		document.getElementById('oidnum').select();
		getParts();
	}
}
function clonePart() {
	var collection_id=document.getElementById('collection_id').value;
	var other_id_type=document.getElementById('other_id_type').value;
	var oidnum=document.getElementById('oidnum').value;
	if (collection_id.length>0 && other_id_type.length>0 && oidnum.length>0) {
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getSpecimen",
				collection_id : collection_id,
				other_id_type : other_id_type,
				oidnum : oidnum,
				returnformat : "json",
				queryformat : 'column'
			},
			success_getSpecimen
		);
	} else {
		alert('Error: cannot resolve ID to specimen.');
	}
}
function success_getSpecimen(r){
	if (toString(r.DATA.COLLECTION_OBJECT_ID[0]).indexOf('Error:')>-1) {
		alert(r.DATA.COLLECTION_OBJECT_ID[0]);	
	} else {
		newPart (r.DATA.COLLECTION_OBJECT_ID[0]);
	}
}
function checkSubmit() {
	var c=document.getElementById('submitOnChange').checked;
	if (c==true) {
		addPartToContainer();
	}
}	
function newPart (collection_object_id) {
	var collection_id=document.getElementById('collection_id').value;
	var part=document.getElementById('part_name').value;
	var url="/form/newPart.cfm";
	url +="?collection_id=" + collection_id;
	url +="&collection_object_id=" + collection_object_id;
	url +="&part=" + part;
	divpop(url);
}
 function getParts() {
	var collection_id=document.getElementById('collection_id').value;
	var other_id_type=document.getElementById('other_id_type').value;
	var oidnum=document.getElementById('oidnum').value;
	if (collection_id.length>0 && other_id_type.length>0 && oidnum.length>0) {
		var s=document.createElement('DIV');
	    s.id='ajaxStatus';
	    s.className='ajaxStatus';
	    s.innerHTML='Fetching parts...';
	    document.body.appendChild(s);
	    var noBarcode=document.getElementById('noBarcode').checked;
	    var noSubsample=document.getElementById('noSubsample').checked;
	    jQuery.getJSON("/component/functions.cfc",
			{
				method : "getParts",
				collection_id : collection_id,
				other_id_type : other_id_type,
				oidnum : oidnum,
				noBarcode : noBarcode,
				noSubsample : noSubsample,
				returnformat : "json",
				queryformat : 'column'
			},
			success_getParts
		);
	}
 }

function success_getParts(r) {
	var	result=r.DATA;	
	var s=document.getElementById('ajaxStatus');
	document.body.removeChild(s);
	var sDiv=document.getElementById('thisSpecimen');
	var ocoln=document.getElementById('collection_id');
	var specid=document.getElementById('collection_object_id');
	var p1=document.getElementById('part_name');
	var p2=document.getElementById('part_name_2');
	var op1=p1.value;
	var op2=p2.value;
	p1.options.length=0;
	p2.options.length=0;
	var selIndex = ocoln.selectedIndex;
	var coln = ocoln.options[selIndex].text;		
	var idt=document.getElementById('other_id_type').value;
	var idn=document.getElementById('oidnum').value;
	var ss=coln + ' ' + idt + ' ' + idn;
	if (result.PART_NAME[0].indexOf('Error:')>-1) {
		sDiv.className='error';
		ss+=' = ' + result.PART_NAME[0];
		specid.value='';
		document.getElementById('pTable').className='red';
	} else {
		document.getElementById('pTable').className='';
		sDiv.className='';
		specid.value=result.COLLECTION_OBJECT_ID[0];
		var option = document.createElement('option');
		option.setAttribute('value','');
		option.appendChild(document.createTextNode(''));
		p2.appendChild(option);
		
		for (i=0;i<r.ROWCOUNT;i++) {
			var option = document.createElement('option');
			var option2 = document.createElement('option');
			option.setAttribute('value',result.PARTID[i]);
			option2.setAttribute('value',result.PARTID[i]);
			var pStr=result.PART_NAME[i];
			if (result.BARCODE[i]!==null){
				pStr+=' [' + result.BARCODE[i] + ']';
			}
			option.appendChild(document.createTextNode(pStr));
			option2.appendChild(document.createTextNode(pStr));
			p1.appendChild(option);
			p2.appendChild(option2);
		}
		p1.value=op1;
		p2.value=op2;	
		ss+=' = ' + result.COLLECTION[0] + ' ' + result.CAT_NUM[0] + ' (' + result.CUSTOMIDTYPE[0] + ' ' + result.CUSTOMID[0] + ')';
	}
	sDiv.innerHTML=ss;
}
function divpop (url) {
	var req;
 	var bgDiv=document.createElement('div');
	bgDiv.id='bgDiv';
	bgDiv.className='bgDiv';
	document.body.appendChild(bgDiv);
	var theDiv = document.createElement('div');
	theDiv.id = 'ppDiv';
	theDiv.className = 'pickBox';
	theDiv.innerHTML='Loading....';
	theDiv.src = "";
	document.body.appendChild(theDiv);	
	if (window.XMLHttpRequest) {
	  req = new XMLHttpRequest();
	} else if (window.ActiveXObject) {
	  req = new ActiveXObject("Microsoft.XMLHTTP");
	}
	if (req != undefined) {
	  req.onreadystatechange = function() {divpopDone(req);};
	  req.open("GET", url, true);
	  req.send("");
	}
}
function divpopDone(req) {
	if (req.readyState == 4) { // only if req is "loaded"
		if (req.status == 200) { // only if "OK"
		  document.getElementById('ppDiv').innerHTML = req.responseText;
		} else {
		  document.getElementById('ppDiv').innerHTML="ahah error:\n"+req.statusText;
		}
		var p = document.getElementById('ppDiv');
		var cSpan=document.createElement('span');
		cSpan.className='popDivControl';
		cSpan.setAttribute('onclick','divpopClose();');
		cSpan.innerHTML='X';
		p.appendChild(cSpan);
	}
}
function divpopClose(){
	var p = document.getElementById('ppDiv');
	document.body.removeChild(p);
	var b = document.getElementById('bgDiv');
	document.body.removeChild(b);
}
function makePart(){
	var collection_object_id=document.getElementById('collection_object_id').value;
	var part_name=document.getElementById('npart_name').value;
	var part_modifier=document.getElementById('part_modifier').value;
	var lot_count=document.getElementById('lot_count').value;
	var is_tissue=document.getElementById('is_tissue').value;
	var preserve_method=document.getElementById('preserve_method').value;
	var coll_obj_disposition=document.getElementById('coll_obj_disposition').value;
	var condition=document.getElementById('condition').value;
	var coll_object_remarks=document.getElementById('coll_object_remarks').value;
	var barcode=document.getElementById('barcode').value;
	var new_container_type=document.getElementById('new_container_type').value;
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "makePart",
			collection_object_id : collection_object_id,
			part_name : part_name,
			part_modifier : part_modifier,
			lot_count : lot_count,
			is_tissue : is_tissue,
			preserve_method : preserve_method,
			coll_obj_disposition : coll_obj_disposition,
			condition : condition,
			coll_object_remarks : coll_object_remarks,
			barcode : barcode,
			new_container_type : new_container_type,
			returnformat : "json",
			queryformat : 'column'
		},
		function (r){
			var result=r.DATA;
			var status=result.STATUS[0];
			if (status=='error') {
				var msg=result.MSG[0];
				alert(msg);
			} else {
				var msg="Created part: ";
				if (result.PART_MODIFIER[0]!==null) {
					msg +=result.PART_MODIFIER[0] + " ";
				}
				msg += result.PART_NAME[0] + " ";
				if (result.PRESERVE_METHOD[0]!==null) {
					msg += "(" + result.PRESERVE_METHOD[0] + ") ";
				}
				if (result.IS_TISSUE[0]== 1) {
					msg += "(tissue) ";
				}
				if (result.BARCODE[0]!==null) {
					msg += "barcode " + result.BARCODE[0];
					if (result.NEW_CONTAINER_TYPE[0]!==null) {
						msg += "( " + result.NEW_CONTAINER_TYPE[0] + ")";
					}
				}
				logIt(msg);
				var p = document.getElementById('ppDiv');
				document.body.removeChild(p);
				var b = document.getElementById('bgDiv');
				document.body.removeChild(b);
				getParts();
			}
		}
	);
}

function changedisplayRows (tgt) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changedisplayRows",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		function (result) {
			if (result == 'success') {
				document.getElementById('displayRows').className='';
			} else {
				alert('An error occured: ' + result);
			}
		}
	);
}


function changekillRows () {
	if (document.getElementById('killRows').checked){
		var tgt=1;
	} else {
		var tgt=0;
	}
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changekillRows",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		function (result){
			if (result != 'success') {
				alert('An error occured: ' + result);
			}
		}
	);
}
function changeresultSort (tgt) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changeresultSort",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		function (result) {
			if (result == 'success') {
				var e = document.getElementById('result_sort').className='';
			} else {
				alert('An error occured: ' + result);
			}
		}
	);
}
jQuery( function($) {
	jQuery(".helpLink").live('click', function(e){
		var id=this.id;
		removeHelpDiv();
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','removeHelpDiv()');
		document.body.appendChild(bgDiv);
		var theDiv = document.createElement('div');
		theDiv.id = 'helpDiv';
		theDiv.className = 'helpBox';
		theDiv.innerHTML='<br>Loading...';
		document.body.appendChild(theDiv);
		jQuery("#helpDiv").css({position:"absolute", top: e.pageY, left: e.pageX});
		jQuery(theDiv).load("/service/get_doc_rest.cfm",{fld: id, addCtl: 1});
	});
	jQuery("#c_collection_cust").click(function(e){
		console.log('c_collection_cust');
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeAndRefresh()');
		document.body.appendChild(bgDiv);
		var cDiv = document.createElement('div');
		cDiv.id = 'customDiv';
		cDiv.className = 'sscustomBox';
		cDiv.innerHTML='<br>boogity! Loading...';
		document.body.appendChild(cDiv);
		var ptl="/includes/SpecSearch/changeCollection.cfm";
		jQuery(cDiv).load(ptl,{},function(){
			viewport.init("#customDiv");
			viewport.init("#bgDiv");
		});
	});
	jQuery("#c_identifiers_cust").click(function(e){
		console.log('woot');
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeAndRefresh()');
		document.body.appendChild(bgDiv);
		var cDiv = document.createElement('div');
		cDiv.id = 'customDiv';
		cDiv.className = 'sscustomBox';
		cDiv.innerHTML='<br>Loading...';
		document.body.appendChild(cDiv);
		var ptl="/includes/SpecSearch/customIDs.cfm";
		jQuery(cDiv).load(ptl,{},function(){
			viewport.init("#customDiv");
			viewport.init("#bgDiv");
		});
	});
});
function removeHelpDiv() {
	if(document.getElementById('bgDiv')){
		jQuery('#bgDiv').remove();
	}
	if (document.getElementById('helpDiv')) {
		jQuery('#helpDiv').remove();
	}
}
function changeshowObservations (tgt) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changeshowObservations",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		function (r) {
			if (r != 'success') {
				alert('An error occured: ' + r);
			}
		}
	);
}

function showHide(id,onOff) {
	var t='e_' + id;
	var z='c_' + id;	
	if (document.getElementById(t) && document.getElementById(z)) {	
		var tab=document.getElementById(t);
		var ctl=document.getElementById(z);
		if (onOff==1) {
			var ptl="/includes/SpecSearch/" + id + ".cfm";
			jQuery.get(ptl, function(data){
				jQuery(tab).html(data);
			});
			ctl.setAttribute("onclick","showHide('" + id + "',0)");
			ctl.innerHTML='Show Fewer Options';	
		} else {
			tab.innerHTML='';
			ctl.setAttribute("onclick","showHide('" + id + "',1)");
			ctl.innerHTML='Show More Options';
		}
		jQuery.getJSON("/component/functions.cfc",
  			{
 				method : "saveSpecSrchPref",
 				id : id,
  				onOff : onOff,
 				returnformat : "json",
 				queryformat : 'column'
 			},
  			saveComplete
 		);
	}
}
function closeAndRefresh(){
	document.location=location.href;
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
}
function setPrevSearch_result(schParam){
	 	var sp='#session.schParam#';
	 	var pAry=schParam.split("|");
	 	for (var i=0; i<pAry.length; i++) {
	 		var eAry=pAry[i].split("::");
	 		var eName=eAry[0];
	 		var eVl=eAry[1];
	 		if (document.getElementById(eName)){
				document.getElementById(eName).value=eVl;
			}
	 	}
 } 
 function setPrevSearch(){
	var schParam=get_cookie ('schParams');
	var pAry=schParam.split("|");
 	for (var i=0; i<pAry.length; i++) {
 		var eAry=pAry[i].split("::");
 		var eName=eAry[0];
 		var eVl=eAry[1];
 		if (document.getElementById(eName)){
			document.getElementById(eName).value=eVl;
		}
 	}
}
function getFormValues() {
 	var theForm=document.getElementById('SpecData');
 	var nval=theForm.length;
 	var spAry = new Array();
 	for (var i=0; i<nval; i++) {
		var theElement = theForm.elements[i];
		var element_name = theElement.name;
		var element_value = theElement.value;
		if (element_name.length>0 && element_value.length>0) {
			var thisPair=element_name + '::' + element_value;
			if (spAry.indexOf(thisPair)==-1) {
				spAry.push(thisPair);
			}
		}
	}
	var str=spAry.join("|");
	document.cookie = 'schParams=' + str;
 }
function changeTarget(id,tvalue) {
	if(tvalue.length == 0) {
		tvalue='SpecimenResults.cfm';
	}
	if (id =='tgtForm1') {
		var otherForm = document.getElementById('tgtForm');
	} else {
		var otherForm = document.getElementById('tgtForm1');
	}
	otherForm.value=tvalue;
	if (tvalue == 'SpecimenResultsSummary.cfm') {
		document.getElementById('groupByDiv').style.display='';
		document.getElementById('groupByDiv1').style.display='';
	} else {
		document.getElementById('groupByDiv').style.display='none';
		document.getElementById('groupByDiv1').style.display='none';
	}
	document.SpecData.action = tvalue;
}
function changeGrp(tid) {
	if (tid == 'groupBy') {
		var oid = 'groupBy1';
	} else {
		var oid = 'groupBy';
	}
	var mList = document.getElementById(tid);
	var sList = document.getElementById(oid);
	var len = mList.length;
	for (i = 0; i < len; i++) {
		sList.options[i].selected = false;
	}
	for (i = 0; i < len; i++) {
		if (mList.options[i].selected) {
			sList.options[i].selected = true;
		}
	}
}
function nada(){
	return false;
}
function saveComplete(savedStr){
	var savedArray = savedStr.split(",");
	var result = savedArray[0];
	var id = savedArray[1];
	var onOff = savedArray[2];
	if (result == "cookie") {
		var cookieArray = new Array();
		var cCookie = readCookie("specsrchprefs");
		var idFound = -1;
		if (cCookie!==null)	{
			cookieArray = cCookie.split(",");
			for (i = 0; i<cookieArray.length; i++) {
				if (cookieArray[i] == id) {
					idFound = i;
				}
			}
		}
		if (onOff==1) { //showHide On			
			if (idFound == -1) { // no current id in cookie
				cookieArray.push(id);
			}
		}
		else {
			if (idFound != -1)
				cookieArray.splice(idFound,1);
		}
		var nCookie = cookieArray.join();
		createCookie("specsrchprefs", nCookie, 0);
	}
}
function createCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}
function readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}
function changeexclusive_collection_id (tgt) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changeexclusive_collection_id",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		function (r) {
			if (r == 'success') {
				var e = document.getElementById('exclusive_collection_id').className='';
			} else {
				alert('An error occured: ' + r);
			}
		}
	);
}
function IsNumeric(sText) {
   var ValidChars = "0123456789.";
   var IsNumber=true;
   var Char;
   for (i = 0; i < sText.length && IsNumber == true; i++) { 
      Char = sText.charAt(i); 
      if (ValidChars.indexOf(Char) == -1) {
         IsNumber = false;
      }
   }
   return IsNumber;
}
 function get_cookie ( cookie_name ) {
  var results = document.cookie.match ( '(^|;) ?' + cookie_name + '=([^;]*)(;|$)' );
  if ( results )
    return ( unescape ( results[2] ) );
  else
    return null;
}
function orapwCheck(p,u) {
	var regExp = /^[A-Za-z0-9!$%&_?(\-)<>=/:;*\.]$/;
	var minLen=6;
	var msg='Password is acceptable';
	if (p.indexOf(u) > -1) {
		msg='Password may not contain your username.';
	}
	if (p.length<minLen || p.length>30) {
		msg='Password must be between ' + minLen + ' and 30 characters.';
	}
	if (!p.match(/[a-zA-Z]/)) {
		msg='Password must contain at least one letter.'
	}
	if (!p.match(/\d+/)) {
		msg='Password must contain at least one number.'
	}
	if (!p.match(/[!,$,%,&,*,?,_,-,(,),<,>,=,/,:,;,.]/) ) {
		msg='Password must contain at least one of: !,$,%,&,*,?,_,-,(,),<,>,=,/,:,;.';
	}
	for(var i = 0; i < p.length; i++) {
		if (!p.charAt(i).match(regExp)) {
			msg='Password may contain only A-Z, a-z, 0-9, and !$%&()`*+,-/:;<=>?_.';
		}
	}
	return msg;
}
function getCtDoc(table,field) {
	var table;
	var field;
	var fullURL = "/info/ctDocumentation.cfm?table=" + table + "&field=" + field;
	ctDocWin=windowOpener(fullURL,"ctDocWin","width=700,height=400, resizable,scrollbars");
}
function windowOpener(url, name, args) {
	console.log('i open windows');
	popupWins = [];
	if ( typeof( popupWins[name] ) != "object" ){
			popupWins[name] = window.open(url,name,args);
	} else {
		if (!popupWins[name].closed){
			popupWins[name].location.href = url;
		} else {
			popupWins[name] = window.open(url, name,args);
		}
	}
	popupWins[name].focus();
}
function getDocs(url,anc) {
	var url;
	var anc;
	var baseUrl = "http://g-arctos.appspot.com/arctosdoc/";
	var extension = ".html";
	var fullURL = baseUrl + url + extension;
		if (anc != null) {
			fullURL += "#" + anc;
		}
	siteHelpWin=windowOpener(fullURL,"HelpWin","width=700,height=400, resizable,scrollbars,location,toolbar");
}		
function noenter (e) {
	var key;
	var keychar;
	var reg;
	if(window.event) {
		key = e.keyCode; 
	} else if(e.which) {
		key = e.which; 
	}
	if (key == 13) {
		return false;
	}
}
function gotAgentId (id) {
	var id;
	var len = id.length;
	if (len == 0) {
	   	alert('Oops! A select box malfunctioned! Try changing the value and leaving with TAB. The background should change to green when you\'ve successfullly run the check routine.');
		return false;
	}
}
function chgCondition(collection_object_id) {
	var collection_object_id;
	helpWin=windowOpener("/picks/condition.cfm?collection_object_id="+collection_object_id,"conditionWin","width=800,height=338, resizable,scrollbars");
}
function getAgent(agentIdFld,agentNameFld,formName,agentNameString,allowCreation){
	var url="/picks/findAgent.cfm";
	var agentIdFld;
	var agentNameFld;
	var formName;
	var agentNameString;
	var allowCreation;
	var oawin=url+"?agentIdFld="+agentIdFld+"&agentNameFld="+agentNameFld+"&formName="+formName+"&agent_name="+agentNameString+"&allowCreation="+allowCreation;
	agentpickwin=window.open(oawin,"","width=400,height=338, resizable,scrollbars");
}
function getProject(projIdFld,projNameFld,formName,projNameString){
	var url="/picks/findProject.cfm";
	var projIdFld;
	var projNameFld;
	var formName;
	var projNameString;
	var prwin=url+"?projIdFld="+projIdFld+"&projNameFld="+projNameFld+"&formName="+formName+"&project_name="+projNameString;
	projpickwin=window.open(prwin,"","width=400,height=338, resizable,scrollbars");
}
function findCatalogedItem(collIdFld,CatNumStrFld,formName,oidType,oidNum,collID){
	var url="/picks/findCatalogedItem.cfm";
	var collIdFld;
	var CatCollFld;
	var formName;
	var oidType;
	var oidNum;
	var collCde;
	var ciWin=url+"?collIdFld="+collIdFld+"&CatNumStrFld="+CatNumStrFld+"&formName="+formName+"&oidType="+oidType+"&oidNum="+oidNum+"&collID="+collID;
	catItemWin=window.open(ciWin,"","width=400,height=338, resizable,scrollbars");
}
function findCollEvent(collIdFld,formName,dispField){
	var url="/picks/findCollEvent.cfm";
	var collIdFld;
	var dispField;
	var formName;
	var covwin=url+"?collIdFld="+collIdFld+"&dispField="+dispField+"&formName="+formName;
	ColPickwin=window.open(covwin,"","width=800,height=600, resizable,scrollbars");
}
function pickCollEvent(collIdFld,formName,collObjId){
	var url="/picks/pickCollEvent.cfm";
	var collIdFld;
	var collObjId;
	var formName;
	var covwin=url+"?collIdFld="+collIdFld+"&collection_object_id="+collObjId+"&formName="+formName;
	ColPickwin=window.open(covwin,"","width=800,height=600, resizable,scrollbars");
}
function getGeog(geogIdFld,geogStringFld,formName,geogString){
	var url="/picks/findHigherGeog.cfm";
	var geogIdFld;
	var geogStringFld;
	var formName;
	var geogString;
	var geogwin=url+"?geogIdFld="+geogIdFld+"&geogStringFld="+geogStringFld+"&formName="+formName+"&geogString="+geogString;
	geogpickwin=window.open(geogwin,"","width=400,height=338, resizable,scrollbars");
}
function getHelp(help) {
	var help;
	helpWin=windowOpener("/info/help.cfm?content="+help,"helpWin","width=400,height=338, resizable,scrollbars");
}
function confirmDelete(formName,msg) {
	var formName;
	var msg = msg || "this record";
	confirmWin=windowOpener("/includes/abort.cfm?formName="+formName+"&msg="+msg,"confirmWin","width=200,height=150,resizable");
}
function getHistory(contID) {
	var idcontID;
	historyWin=windowOpener("/info/ContHistory.cfm?container_id="+contID,"historyWin","width=800,height=338, resizable,scrollbars");
}
function getQuadHelp() {
	helpWin=windowOpener("/info/quad.cfm","quadHelpWin","width=800,height=600, resizable,scrollbars,status");
}
function getLegal(blurb) {
	var blurb;
	helpWin=windowOpener("/info/legal.cfm?content="+blurb,"legalWin","width=400,height=338, resizable,scrollbars");
}	
function getInfo(subject,id) {
	var subject;
	var id;
	infoWin=windowOpener("/info/SpecInfo.cfm?subject=" + subject + "&thisId="+id,"infoWin","width=800,height=500, resizable,scrollbars");
}	
function addLoanItem(coll_obj_id) {
	var coll_obj_id;
	loanItemWin=windowOpener("/user/loanItem.cfm?collection_object_id="+coll_obj_id,"loanItemWin","width=800,height=500, resizable,scrollbars,toolbar,menubar");
}
function taxaPick(taxonIdFld,taxonNameFld,formName,scientificName){
var url="/picks/TaxaPick.cfm";
var taxonIdFld;
var taxonNameFld;
var formName;
var scientificName;
var popurl=url+"?taxonIdFld="+taxonIdFld+"&taxonNameFld="+taxonNameFld+"&formName="+formName+"&scientific_name="+scientificName;
taxapick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}
function CatItemPick(collIdFld,catNumFld,formName,sciNameFld){
	var url="/picks/CatalogedItemPick.cfm";
	var collIdFld;
	var catNumFld;
	var formName;
	var sciNameFld;
	var popurl=url+"?collIdFld="+collIdFld+"&catNumFld="+catNumFld+"&formName="+formName+"&sciNameFld="+sciNameFld;
	CatItemPick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}
function findAgentName(agentIdFld,agentNameFld,formName,agentNameString){
	var url="/picks/findAgentName.cfm";
	var agentIdFld;
	var agentNameFld;
	var formName;
	var agentNameString;
	var popurl=url+"?agentIdFld="+agentIdFld+"&agentNameFld="+agentNameFld+"&formName="+formName+"&agentName="+agentNameString;
	agentpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}
function addrPick(addrIdFld,addrFld,formName){
	var url="/picks/AddrPick.cfm";
	var addrIdFld;
	var addrFld;
	var formName;
	var popurl=url+"?addrIdFld="+addrIdFld+"&addrFld="+addrFld+"&formName="+formName;
	addrpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}
function GeogPick(geogIdFld,highGeogFld,formName){
	var url="/picks/GeogPick.cfm";
	var geogIdFld;
	var highGeogFld;
	var formName;
	var popurl=url+"?geogIdFld="+geogIdFld+"&highGeogFld="+highGeogFld+"&formName="+formName;
	geogpick=window.open(popurl,"","width=600,height=600, toolbar,resizable,scrollbars,");
}
function LocalityPick(localityIdFld,speclocFld,formName,fireEvent){
	var url="/picks/LocalityPick.cfm";
	var localityIdFld;
	var speclocFld;
	var formName;
	var fireEvent;
	var popurl=url+"?localityIdFld="+localityIdFld+"&speclocFld="+speclocFld+"&formName="+formName+"&fireEvent="+fireEvent;
	localitypick=window.open(popurl,"","width=800,height=600,resizable,scrollbars,");
}
function findJournal(journalIdFld,journalNameFld,formName,journalNameString){
	var url="/picks/findJournal.cfm";
	var journalIdFld;
	var journalNameFld;
	var formName;
	var journalNameString;
	var popurl=url+"?journalIdFld="+journalIdFld+"&journalNameFld="+journalNameFld+"&formName="+formName+"&journalName="+journalNameString;;
	journalpick=window.open(popurl,"","width=400,height=338, toolbar,location,status,menubar,resizable,scrollbars,");
}
function deleteEncumbrance(encumbranceId,collectionObjectId){
	var url="/picks/DeleteEncumbrance.cfm";
	var encumbranceId;
	var collectionObjectId;
	var popurl=url+"?encumbrance_id="+encumbranceId+"&collection_object_id="+collectionObjectId;
	deleteEncumbrance=window.open(popurl,"","width=400,height=338, toolbar,location,status,menubar,resizable,scrollbars,");
}
function getAllSheets() {
	if( !window.ScriptEngine && navigator.__ice_version ) {
		return document.styleSheets; }
	if( document.getElementsByTagName ) {
		var Lt = document.getElementsByTagName('LINK');
	    var St = document.getElementsByTagName('STYLE');
	  } else if( document.styleSheets && document.all ) {
	    var Lt = document.all.tags('LINK'), St = document.all.tags('STYLE');
	  } else { return []; }
	  for( var x = 0, os = []; Lt[x]; x++ ) {
	    if( Lt[x].rel ) { var rel = Lt[x].rel;
	    } else if( Lt[x].getAttribute ) { var rel = Lt[x].getAttribute('rel');
	    } else { var rel = ''; }
	    if( typeof( rel ) == 'string' &&
	        rel.toLowerCase().indexOf('style') + 1 ) {
	      os[os.length] = Lt[x];
	    }
	  }
	  for( var x = 0; St[x]; x++ ) { os[os.length] = St[x]; } return os;
}
function changeStyle() {
	for( var x = 0, ss = getAllSheets(); ss[x]; x++ ) {
		if( ss[x].title ) {
			ss[x].disabled = true;
		}
		for( var y = 0; y < arguments.length; y++ ) {
			if( ss[x].title == arguments[y] ) {
				ss[x].disabled = false;
			}
		}
	}
	if( !ss.length ) { alert( 'Your browser cannot change stylesheets' ); }
}
if (self != top) {
	if (parent.frames[0].thisStyle) {
		changeStyle(parent.frames[0].thisStyle);
	}
}