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
function checkCSV(obj) {
    var filePath = obj.value;
    var ext = filePath.substring(filePath.lastIndexOf('.') + 1).toLowerCase();
    if(ext != 'csv') {
        alert('Only files with the file extension CSV are allowed');
        $("input[type=submit]").hide();
    } else {
        $("input[type=submit]").show();
    }
}
function getMedia(typ,q,tgt,rpp,pg){
	$('#imgBrowserCtlDiv').append('<img src="/images/indicator.gif">');
	var typ;
	var q;
	var tgt;
	var rpp;
	var pg;
	var ptl="/form/inclMedia.cfm?typ=" + typ + "&q=" + q + "&tgt=" +tgt+ "&rpp=" +rpp+ "&pg="+pg;
	
	jQuery.get(ptl, function(data){
		 jQuery('#' + tgt).html(data);
	})
}
function blockSuggest (onoff) {
	$.getJSON("/component/functions.cfc",
			{
				method : "changeBlockSuggest",
				onoff : onoff,
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				if (r == 'success') {
					$('#browseArctos').html('Suggest Browser disabled. You may turn this feature back on under My Stuff.');
				} else {
					alert('An error occured! \n ' + r);
				}	
			}
		);
}
function changekillRows (onoff) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changekillRows",
			tgt : onoff,
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
function findPart(partFld,part_name,collCde){
	var url="/picks/findPart.cfm";
	var part_name=part_name.replace('%','_');
	var popurl=url+"?part_name="+part_name+"&collCde="+collCde+"&partFld="+partFld;
	partpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}
function saveThisAnnotation() {
	var idType = document.getElementById("idtype").value;
	var idvalue = document.getElementById("idvalue").value;
	var annotation = document.getElementById("annotation").value;
	if (annotation.length==0){
		alert('You must enter an annotation to save.');
		return false;
	}
	$.getJSON("/component/functions.cfc",
		{
			method : "addAnnotation",
			idType : idType,
			idvalue : idvalue,
			annotation : annotation,
			returnformat : "json",
			queryformat : 'column'
		},
		function(r) {
			if (r == 'success') {
				closeAnnotation();
				alert("Your annotations have been saved, and the appropriate curator will be alerted. \n Thank you for helping improve Arctos!");
			} else {
				alert('An error occured! \n ' + r);
			}	
		}
	);
}
function openAnnotation(q) {
	var bgDiv = document.createElement('div');
	bgDiv.id = 'bgDiv';
	bgDiv.className = 'bgDiv';
	bgDiv.setAttribute('onclick','closeAnnotation()');
	document.body.appendChild(bgDiv);
	
	var theDiv = document.createElement('div');
	theDiv.id = 'annotateDiv';
	theDiv.className = 'annotateBox';
	theDiv.innerHTML='';
	theDiv.src = "";
	document.body.appendChild(theDiv);
	var guts = "/info/annotate.cfm?q=" + q;
	jQuery('#annotateDiv').load(guts,{},function(){
		viewport.init("#annotateDiv");
	});
}
function npPage(offset,rpp,tnid){
	var stm = "/includes/taxonomy/specTaxMedia.cfm";
	var v="?Result_Per_Page=" + rpp + "&offset=" + offset + "&taxon_name_id=" + tnid;
	stm+=v;
	$('#imgBrowserCtlDiv').append('<img src="/images/indicator.gif">');
	jQuery.get(stm, function(data){
		jQuery('#specTaxMedia').html(data);
	})
}
function closeAnnotation() {
	var theDiv = document.getElementById('bgDiv');
	document.body.removeChild(theDiv);
	var theDiv = document.getElementById('annotateDiv');
	document.body.removeChild(theDiv);
}
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
	return function (date, mask, utc) {
		var dF = dateFormat;
		if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
			mask = date;
			date = undefined;
		}
		date = date ? new Date(date) : new Date;
		if (isNaN(date)) throw SyntaxError("invalid date");
		mask = String(dF.masks[mask] || mask || dF.masks["default"]);
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
Date.prototype.format = function (mask, utc) {
	return dateFormat(this, mask, utc);
};
function success_crcloo(){
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
function hidePageLoad() {
	$('#loading').hide();
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
	var lot_count=document.getElementById('lot_count').value;
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
			lot_count : lot_count,
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
				msg += result.PART_NAME[0] + " ";
				if (result.BARCODE[0]!==null) {
					msg += "barcode " + result.BARCODE[0];
					if (result.NEW_CONTAINER_TYPE[0]!==null) {
						msg += "( " + result.NEW_CONTAINER_TYPE[0] + ")";
					}
				}
				var p = document.getElementById('ppDiv');
				document.body.removeChild(p);
				var b = document.getElementById('bgDiv');
				document.body.removeChild(b);
				getParts();
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
jQuery(document).ready(function() {
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
		jQuery(theDiv).load("/doc/get_short_doc.cfm",{fld: id, addCtl: 1});
	});
	jQuery("#c_collection_cust").click(function(e){
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
		var ptl="/includes/SpecSearch/changeCollection.cfm";
		jQuery(cDiv).load(ptl,{},function(){
			viewport.init("#customDiv");
		});
	});
	jQuery("#c_identifiers_cust").click(function(e){
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
		});
	});
});
function changefancyCOID (tgt) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changefancyCOID",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		function (result) {
			if (result == 'success') {
				var e = document.getElementById('fancyCOID').className='';
			} else {
				alert('An error occured: ' + result);
			}
		}
	);
}
function changecustomOtherIdentifier (tgt) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changecustomOtherIdentifier",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		function (r) {
			if (r == 'success') {
				document.getElementById('customOtherIdentifier').className='';
			} else {
				alert('An error occured: ' + r);
			}
		}
	);
}
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
function saveSpecSrchPref(id,onOff){
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
function showHide(id,onOff) {
	var t='e_' + id;
	var z='c_' + id;
	if (document.getElementById(t) && document.getElementById(z)) {	
		var tab=document.getElementById(t);
		var ctl=document.getElementById(z);
		if (t=='e_spatial_query'){
			var offText='Select on Google Map';
			var onText='Hide Google Map';
		} else {
			var onText='Show Fewer Options';
			var offText='Show More Options';
		}
		if (onOff==1) {
			var ptl="/includes/SpecSearch/" + id + ".cfm";
			ctl.innerHTML='<img src="/images/indicator.gif">';
			jQuery.get(ptl, function(data){
				jQuery(tab).html(data);
				ctl.innerHTML=onText;
				ctl.setAttribute("onclick","showHide('" + id + "',0)");
				saveSpecSrchPref(id,onOff);
			});
		} else {
			tab.innerHTML='';
			ctl.setAttribute("onclick","showHide('" + id + "',1)");
			ctl.innerHTML=offText;
			saveSpecSrchPref(id,onOff);
		}
	}
}
function closeAndRefresh(){
	document.location=location.href;
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
}
function getFormValues() {
 	var theForm=document.getElementById('SpecData');
 	var nval=theForm.length;
 	var spAry = new Array();
 	//var thisPair='NELat::-177.78515625';
 	//spAry.push(thisPair);
 	for (var i=0; i<nval; i++) {
		var theElement = theForm.elements[i];
		var element_name = theElement.name;
		var element_value = theElement.value;
		if (element_name.length>0 && element_value.length>0 && element_name !='selectedCoords') {
			console.log(' setting ' + element_name + ' to ' + String(element_value));
			
			var thisPair=element_name + '::' + String(element_value);
			console.log(thisPair);
			if (spAry.indexOf(thisPair)==-1) {
				spAry.push(thisPair);
				console.log('pushed to cookie');
			} else {
				console.log('already got on');
			}
		}
	}
 	
 	
 	//var thisPair='isnotanumber::boogity';
 	//spAry.push(thisPair);
 	
 	//var thisPair='NELat::-177.78515625';
 	//spAry.push(thisPair);
 	
 	
	var str=spAry.join("|");


	console.log('writing to cookie: ' + str);
	
	
	document.cookie = 'schParams=' + str;
	
	
	var schParam=get_cookie ('schParams');
	
	console.log('cookie: ' + schParam)
	return false;
	
	
 }
function nada(){
	return false;
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
	//var baseUrl = "http://g-arctos.appspot.com/arctosdoc/";
	//var extension = ".html";
	//var fullURL = baseUrl + url + extension;
	//	if (anc != null) {
	//		fullURL += "#" + anc;
	//	}
		
		
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "get_docs",
			uri : url,
			anchor : anc,
			returnformat : "json"
		},
		function (r) {
			if (r == '404') {
				alert('help not found.');
			} else {
				siteHelpWin=windowOpener(r,"HelpWin","width=800,height=600, resizable,scrollbars,location,toolbar");
			}
		}
	);
}		
function noenter(e) {
	var key;

    if(window.event)
         key = window.event.keyCode;     //IE
    else
         key = e.which;     //firefox

    if(key == 13)
         return false;
    else
         return true;
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
function findCollEvent(collIdFld,formName,dispField,eventName){
	var url="/picks/findCollEvent.cfm";
	var covwin=url+"?collIdFld="+collIdFld+"&dispField="+dispField+"&formName="+formName+"&collecting_event_name="+eventName;
	ColPickwin=window.open(covwin,"","width=800,height=600, resizable,scrollbars");
}
function getPublication(pubStringFld,pubIdFld,publication_title,formName){
	var url="/picks/findPublication.cfm";
	var pubwin=url+"?pubStringFld="+pubStringFld+"&pubIdFld="+pubIdFld+"&publication_title="+publication_title+"&formName="+formName;
	pubwin=window.open(pubwin,"","width=400,height=338, resizable,scrollbars");
}
function getAccn(accnNumber,rtnFldID,InstAcrColnCde){
	//accnNumber=value submitted by user, optional
	//rtnFldID=ID of field to write back to
	//InstAcrColnCde=Inst:Coln (UAM:Mamm)
	var url="/picks/findAccn.cfm";
	var pickwin=url+"?r_accnNumber="+accnNumber+"&rtnFldID="+rtnFldID+"&r_InstAcrColnCde="+InstAcrColnCde;
	pickwin=window.open(pickwin,"","width=400,height=338, resizable,scrollbars");
}

function getAccn2(accnNumber,colID){
	//accnNumber=value submitted by user, optional
	//collection_id
	var url="/picks/getAccn.cfm";
	var pickwin=url+"?accnNumber="+accnNumber+"&collectionID="+colID;
	pickwin=window.open(pickwin,"","width=400,height=338, resizable,scrollbars");
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
function confirmDelete(formName,msg) {
	var formName;
	var msg = msg || "this record";
	var yesno=confirm('Are you sure you want to delete ' + msg + '?');
	//confirmWin=windowOpener("/includes/abort.cfm?formName="+formName+"&msg="+msg,"confirmWin","width=200,height=150,resizable");
	if (yesno==true) {
  		var txtstrng='document.' + formName + '.submit();';
		eval(txtstrng);
 	} else {
	  	return false;
  	}
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
function findMedia(mediaStringFld,mediaIdFld,media_uri){
	var url="/picks/findMedia.cfm";
	var mediaIdFld;
	var mediaStringFld;
	var media_uri;
	var popurl=url+"?mediaIdFld="+mediaIdFld+"&mediaStringFld="+mediaStringFld+"&media_uri="+media_uri;
	mediapick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
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
function findAgentName(agentIdFld,agentNameFld,agentNameString){
	var url="/picks/findAgentName.cfm";
	var agentIdFld;
	var agentNameFld;
	var agentNameString;
	var popurl=url+"?agentIdFld="+agentIdFld+"&agentNameFld="+agentNameFld+"&agentName="+agentNameString;
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
function LocalityPick(localityIdFld,speclocFld,formName,localityNameString){
	var url="/picks/LocalityPick.cfm";
	var localityIdFld;
	var speclocFld;
	var formName;
	var fireEvent;
	var popurl=url+"?localityIdFld="+localityIdFld+"&speclocFld="+speclocFld+"&formName="+formName+"&locality_name="+localityNameString;
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
/******************************************* superfish jQuery plugin ******************************************/
/*
 * Superfish v1.4.8 - jQuery menu widget
 * Copyright (c) 2008 Joel Birch
 *
 * Dual licensed under the MIT and GPL licenses:
 * 	http://www.opensource.org/licenses/mit-license.php
 * 	http://www.gnu.org/licenses/gpl.html
 *
 * CHANGELOG: http://users.tpg.com.au/j_birch/plugins/superfish/changelog.txt
 */

;(function($){
	$.fn.superfish = function(op){

		var sf = $.fn.superfish,
			c = sf.c,
			$arrow = $(['<span class="',c.arrowClass,'"> &#187;</span>'].join('')),
			over = function(){
				var $$ = $(this), menu = getMenu($$);
				clearTimeout(menu.sfTimer);
				$$.showSuperfishUl().siblings().hideSuperfishUl();
			},
			out = function(){
				var $$ = $(this), menu = getMenu($$), o = sf.op;
				clearTimeout(menu.sfTimer);
				menu.sfTimer=setTimeout(function(){
					o.retainPath=($.inArray($$[0],o.$path)>-1);
					$$.hideSuperfishUl();
					if (o.$path.length && $$.parents(['li.',o.hoverClass].join('')).length<1){over.call(o.$path);}
				},o.delay);	
			},
			getMenu = function($menu){
				var menu = $menu.parents(['ul.',c.menuClass,':first'].join(''))[0];
				sf.op = sf.o[menu.serial];
				return menu;
			},
			addArrow = function($a){ $a.addClass(c.anchorClass).append($arrow.clone()); };
			
		return this.each(function() {
			var s = this.serial = sf.o.length;
			var o = $.extend({},sf.defaults,op);
			o.$path = $('li.'+o.pathClass,this).slice(0,o.pathLevels).each(function(){
				$(this).addClass([o.hoverClass,c.bcClass].join(' '))
					.filter('li:has(ul)').removeClass(o.pathClass);
			});
			sf.o[s] = sf.op = o;
			
			$('li:has(ul)',this)[($.fn.hoverIntent && !o.disableHI) ? 'hoverIntent' : 'hover'](over,out).each(function() {
				if (o.autoArrows) addArrow( $('>a:first-child',this) );
			})
			.not('.'+c.bcClass)
				.hideSuperfishUl();
			
			var $a = $('a',this);
			$a.each(function(i){
				var $li = $a.eq(i).parents('li');
				$a.eq(i).focus(function(){over.call($li);}).blur(function(){out.call($li);});
			});
			o.onInit.call(this);
			
		}).each(function() {
			var menuClasses = [c.menuClass];
			if (sf.op.dropShadows  && !($.browser.msie && $.browser.version < 7)) menuClasses.push(c.shadowClass);
			$(this).addClass(menuClasses.join(' '));
		});
	};

	var sf = $.fn.superfish;
	sf.o = [];
	sf.op = {};
	sf.IE7fix = function(){
		var o = sf.op;
		if ($.browser.msie && $.browser.version > 6 && o.dropShadows && o.animation.opacity!=undefined)
			this.toggleClass(sf.c.shadowClass+'-off');
		};
	sf.c = {
		bcClass     : 'sf-breadcrumb',
		menuClass   : 'sf-js-enabled',
		anchorClass : 'sf-with-ul',
		arrowClass  : 'sf-sub-indicator',
		shadowClass : 'sf-shadow'
	};
	sf.defaults = {
		hoverClass	: 'sfHover',
		pathClass	: 'overideThisToUse',
		pathLevels	: 1,
		delay		: 800,
		animation	: {opacity:'show'},
		speed		: 'normal',
		autoArrows	: true,
		dropShadows : true,
		disableHI	: false,		// true disables hoverIntent detection
		onInit		: function(){}, // callback functions
		onBeforeShow: function(){},
		onShow		: function(){},
		onHide		: function(){}
	};
	$.fn.extend({
		hideSuperfishUl : function(){
			var o = sf.op,
				not = (o.retainPath===true) ? o.$path : '';
			o.retainPath = false;
			var $ul = $(['li.',o.hoverClass].join(''),this).add(this).not(not).removeClass(o.hoverClass)
					.find('>ul').hide().css('visibility','hidden');
			o.onHide.call($ul);
			return this;
		},
		showSuperfishUl : function(){
			var o = sf.op,
				sh = sf.c.shadowClass+'-off',
				$ul = this.addClass(o.hoverClass)
					.find('>ul:hidden').css('visibility','visible');
			sf.IE7fix.call($ul);
			o.onBeforeShow.call($ul);
			$ul.animate(o.animation,o.speed,function(){ sf.IE7fix.call($ul); o.onShow.call($ul); });
			return this;
		}
	});

})(jQuery);
/******************************************* supersubs (superfish extension) jQuery plugin *********************/

/*
 * Supersubs v0.2b - jQuery plugin
 * Copyright (c) 2008 Joel Birch
 *
 * Dual licensed under the MIT and GPL licenses:
 * 	http://www.opensource.org/licenses/mit-license.php
 * 	http://www.gnu.org/licenses/gpl.html
 *
 *
 * This plugin automatically adjusts submenu widths of suckerfish-style menus to that of
 * their longest list item children. If you use this, please expect bugs and report them
 * to the jQuery Google Group with the word 'Superfish' in the subject line.
 *
 */

;(function($){ // $ will refer to jQuery within this closure

	$.fn.supersubs = function(options){
		var opts = $.extend({}, $.fn.supersubs.defaults, options);
		// return original object to support chaining
		return this.each(function() {
			// cache selections
			var $$ = $(this);
			// support metadata
			var o = $.meta ? $.extend({}, opts, $$.data()) : opts;
			// get the font size of menu.
			// .css('fontSize') returns various results cross-browser, so measure an em dash instead
			var fontsize = $('<li id="menu-fontsize">&#8212;</li>').css({
				'padding' : 0,
				'position' : 'absolute',
				'top' : '-999em',
				'width' : 'auto'
			}).appendTo($$).width(); //clientWidth is faster, but was incorrect here
			// remove em dash
			$('#menu-fontsize').remove();
			// cache all ul elements
			$ULs = $$.find('ul');
			// loop through each ul in menu
			$ULs.each(function(i) {	
				// cache this ul
				var $ul = $ULs.eq(i);
				// get all (li) children of this ul
				var $LIs = $ul.children();
				// get all anchor grand-children
				var $As = $LIs.children('a');
				// force content to one line and save current float property
				var liFloat = $LIs.css('white-space','nowrap').css('float');
				// remove width restrictions and floats so elements remain vertically stacked
				var emWidth = $ul.add($LIs).add($As).css({
					'float' : 'none',
					'width'	: 'auto'
				})
				// this ul will now be shrink-wrapped to longest li due to position:absolute
				// so save its width as ems. Clientwidth is 2 times faster than .width() - thanks Dan Switzer
				.end().end()[0].clientWidth / fontsize;
				// add more width to ensure lines don't turn over at certain sizes in various browsers
				emWidth += o.extraWidth;
				// restrict to at least minWidth and at most maxWidth
				if (emWidth > o.maxWidth)		{ emWidth = o.maxWidth; }
				else if (emWidth < o.minWidth)	{ emWidth = o.minWidth; }
				emWidth += 'em';
				// set ul to width in ems
				$ul.css('width',emWidth);
				// restore li floats to avoid IE bugs
				// set li width to full width of this ul
				// revert white-space to normal
				$LIs.css({
					'float' : liFloat,
					'width' : '100%',
					'white-space' : 'normal'
				})
				// update offset position of descendant ul to reflect new width of parent
				.each(function(){
					var $childUl = $('>ul',this);
					var offsetDirection = $childUl.css('left')!==undefined ? 'left' : 'right';
					$childUl.css(offsetDirection,emWidth);
				});
			});
			
		});
	};
	// expose defaults
	$.fn.supersubs.defaults = {
		minWidth		: 9,		// requires em unit.
		maxWidth		: 25,		// requires em unit.
		extraWidth		: 0			// extra width can ensure lines don't sometimes turn over due to slight browser differences in how they round-off values
	};
	
})(jQuery); // plugin code ends
/******************************************* hoverIntent jQuery plugin ******************************************/
(function($){
	/* hoverIntent by Brian Cherne */
	$.fn.hoverIntent = function(f,g) {
		// default configuration options
		var cfg = {
			sensitivity: 7,
			interval: 100,
			timeout: 0
		};
		// override configuration options with user supplied object
		cfg = $.extend(cfg, g ? { over: f, out: g } : f );

		// instantiate variables
		// cX, cY = current X and Y position of mouse, updated by mousemove event
		// pX, pY = previous X and Y position of mouse, set by mouseover and polling interval
		var cX, cY, pX, pY;

		// A private function for getting mouse position
		var track = function(ev) {
			cX = ev.pageX;
			cY = ev.pageY;
		};

		// A private function for comparing current and previous mouse position
		var compare = function(ev,ob) {
			ob.hoverIntent_t = clearTimeout(ob.hoverIntent_t);
			// compare mouse positions to see if they've crossed the threshold
			if ( ( Math.abs(pX-cX) + Math.abs(pY-cY) ) < cfg.sensitivity ) {
				$(ob).unbind("mousemove",track);
				// set hoverIntent state to true (so mouseOut can be called)
				ob.hoverIntent_s = 1;
				return cfg.over.apply(ob,[ev]);
			} else {
				// set previous coordinates for next time
				pX = cX; pY = cY;
				// use self-calling timeout, guarantees intervals are spaced out properly (avoids JavaScript timer bugs)
				ob.hoverIntent_t = setTimeout( function(){compare(ev, ob);} , cfg.interval );
			}
		};

		// A private function for delaying the mouseOut function
		var delay = function(ev,ob) {
			ob.hoverIntent_t = clearTimeout(ob.hoverIntent_t);
			ob.hoverIntent_s = 0;
			return cfg.out.apply(ob,[ev]);
		};

		// A private function for handling mouse 'hovering'
		var handleHover = function(e) {
			// next three lines copied from jQuery.hover, ignore children onMouseOver/onMouseOut
			var p = (e.type == "mouseover" ? e.fromElement : e.toElement) || e.relatedTarget;
			while ( p && p != this ) { try { p = p.parentNode; } catch(e) { p = this; } }
			if ( p == this ) { return false; }

			// copy objects to be passed into t (required for event object to be passed in IE)
			var ev = jQuery.extend({},e);
			var ob = this;

			// cancel hoverIntent timer if it exists
			if (ob.hoverIntent_t) { ob.hoverIntent_t = clearTimeout(ob.hoverIntent_t); }

			// else e.type == "onmouseover"
			if (e.type == "mouseover") {
				// set "previous" X and Y position based on initial entry point
				pX = ev.pageX; pY = ev.pageY;
				// update "current" X and Y position based on mousemove
				$(ob).bind("mousemove",track);
				// start polling interval (self-calling timeout) to compare mouse coordinates over time
				if (ob.hoverIntent_s != 1) { ob.hoverIntent_t = setTimeout( function(){compare(ev,ob);} , cfg.interval );}

			// else e.type == "onmouseout"
			} else {
				// unbind expensive mousemove event
				$(ob).unbind("mousemove",track);
				// if hoverIntent state is true, then call the mouseOut function after the specified delay
				if (ob.hoverIntent_s == 1) { ob.hoverIntent_t = setTimeout( function(){delay(ev,ob);} , cfg.timeout );}
			}
		};

		// bind the function to the two event listeners
		return this.mouseover(handleHover).mouseout(handleHover);
	};
	
})(jQuery);