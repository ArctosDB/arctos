var self;
var viewport={
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
       $(el).css("left",Math.round(viewport.o().innerWidth/2) + viewport.o().pageXOffset - Math.round($(el).width()/2));
       $(el).css("top",Math.round(viewport.o().innerHeight/2) + viewport.o().pageYOffset - Math.round($(el).height()/2));
       }
   };

/* specimen search */
function setSessionCustomID(v) {
	$.getJSON("/component/functions.cfc",
		{
			method : "setSessionCustomID",
			val : v,
			returnformat : "json",
			queryformat : 'column'
		},
		function (getResult) {}
	);
}
function setPrevSearch(){
	var schParam=get_cookie ('schParams');
	var pAry=schParam.split("|");
 	for (var i=0; i<pAry.length; i++) {
 		var eAry=pAry[i].split("::");
 		var eName=eAry[0];
 		var eVl=eAry[1];
		console.log(eName + '::' + eVl);
 		if (document.getElementById(eName)){
			document.getElementById(eName).value=eVl;
			if (eName=='tgtForm' && (eVl=='/bnhmMaps/kml.cfm?action=newReq' || eVl=='SpecimenResultsSummary.cfm')) {
				changeTarget(eName,eVl);
				console.log(eName + '::' + eVl);
			}
		}
 	}
 	try {
		setPreviousMap();
	} catch(e){}
}
function changeTarget(id,tvalue) {
	var otherForm;
	if(tvalue.length === 0) {
		tvalue='SpecimenResults.cfm';
	}
	if (id =='tgtForm1') {
		otherForm = document.getElementById('tgtForm');
	} else {
		 otherForm = document.getElementById('tgtForm1');
	}
	otherForm.value=tvalue;
	document.getElementById('groupByDiv').style.display='none';
	document.getElementById('groupByDiv1').style.display='none';
	document.getElementById('kmlDiv').style.display='none';
	document.getElementById('kmlDiv1').style.display='none';
	if (tvalue == 'SpecimenResultsSummary.cfm') {
		document.getElementById('groupByDiv').style.display='';
		document.getElementById('groupByDiv1').style.display='';
	} else if (tvalue=='/bnhmMaps/kml.cfm?action=newReq') {
		document.getElementById('kmlDiv').style.display='';
		document.getElementById('kmlDiv1').style.display='';
	}
	document.SpecData.action = tvalue;
}
function changeGrp(tid) {
	var oid,mList,sList,len,i;
	if (tid == 'groupBy') {
		oid = 'groupBy1';
	} else {
		 oid = 'groupBy';
	}
	mList = document.getElementById(tid);
	sList = document.getElementById(oid);
	len = mList.length;
	for (i = 0; i < len; i++) {
		sList.options[i].selected = false;
	}
	for (i = 0; i < len; i++) {
		if (mList.options[i].selected) {
			sList.options[i].selected = true;
		}
	}
}
function resetSSForm(){
	document.getElementById('SpecData').reset();
	try {
		initialize();
	} catch(e){}
}
function r_getSpecSrchPref (result){
	var j;
	j=result.split(',');
	for (var i = 0; i < j.length; i++) {
		if (j[i].length>0){
			showHide(j[i],1);
		}
	}
}
function kmlSync(tid,tval) {
	var rMostChar;
	rMostChar=tid.substr(tid.length -1,1);
	if (rMostChar=='1'){
		theOtherField=tid.substr(0,tid.length -1);
	} else {
		theOtherField=tid + '1';
	}
	document.getElementById(theOtherField).value=tval;
}
/* specimen search */


function op_getAgent(agentIdID,agentNameID,agent_name){
	var url;
	$("#" + agentNameID).removeClass('goodPick');
	url="/picks/op_findAgent.cfm";
	url+="?agentIdID="+agentIdID+"&agentNameID="+agentNameID+"&agent_name="+agent_name;
	//console.log(url);
	$.colorbox({width:"80%",height:"80%", href:url});   
}


function checkCSV(obj) {
    var filePath,ext;
    
    filePath = obj.value;
    ext = filePath.substring(filePath.lastIndexOf('.') + 1).toLowerCase();
    if(ext != 'csv') {
        alert('Only files with the file extension CSV are allowed');
        $("input[type=submit]").hide();
    } else {
        $("input[type=submit]").show();
    }
}
function getMedia(typ,q,tgt,rpp,pg){
	var ptl;
	$('#imgBrowserCtlDiv').append('<img src="/images/indicator.gif">');
	
	ptl="/form/inclMedia.cfm?typ=" + typ + "&q=" + q + "&tgt=" +tgt+ "&rpp=" +rpp+ "&pg="+pg;
	
	$.get(ptl, function(data){
		 $('#' + tgt).html(data);
	});
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
	$.getJSON("/component/functions.cfc",
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
	var url,popurl;
	
	url="/picks/findPart.cfm";
	part_name=part_name.replace('%','_');
	popurl=url+"?part_name="+part_name+"&collCde="+collCde+"&partFld="+partFld;
	partpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}
function isValidEmailAddress(emailAddress) {
    var pattern;
    pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
    return pattern.test(emailAddress);
}
function saveThisAnnotation() {
	var idType,idvalue,annotation,captchaHash,captcha;
	
	idType = document.getElementById("idtype").value;
	idvalue = document.getElementById("idvalue").value;
	annotation = document.getElementById("annotation").value;
	captchaHash=$("#captchaHash").val();
	captcha=$("#captcha").val().toUpperCase();
	if (annotation.length <= 20){
		alert('You must enter an annotation of at least 20 characters to save.');
		return false;
	}
	if (!isValidEmailAddress($("#email").val())){
		alert('Enter a valid email address.');
		return false;		
	}
	$.getJSON("/component/functions.cfc",
		{
			method : "hashString",
			string : captcha,
			returnformat : "json"
		},
		function(r) {
			if (r != captchaHash){
				alert('bad captcha');
				return false;
			} else {
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
						return true;
					}
				);
			}
		}
	);
}
function openAnnotation(q) {
	var bgDiv,theDiv,guts;
	bgDiv = document.createElement('div');
	bgDiv.id = 'bgDiv';
	bgDiv.className = 'bgDiv';
	bgDiv.setAttribute('onclick','closeAnnotation()');
	document.body.appendChild(bgDiv);
	theDiv = document.createElement('div');
	theDiv.id = 'annotateDiv';
	theDiv.className = 'annotateBox';
	theDiv.innerHTML='';
	theDiv.src = "";
	document.body.appendChild(theDiv);
	guts = "/info/annotate.cfm?q=" + q;
	$('#annotateDiv').load(guts,{},function(){
		viewport.init("#annotateDiv");
	});
}
function npPage(offset,rpp,tnid){
	var stm = "/includes/taxonomy/specTaxMedia.cfm";
	var v="?Result_Per_Page=" + rpp + "&offset=" + offset + "&taxon_name_id=" + tnid;
	stm+=v;
	$('#imgBrowserCtlDiv').append('<img src="/images/indicator.gif">');
	$.get(stm, function(data){
		$('#specTaxMedia').html(data);
	});
}
function closeAnnotation() {
	var theDiv;
	theDiv= document.getElementById('bgDiv');
	document.body.removeChild(theDiv);
	theDiv = document.getElementById('annotateDiv');
	document.body.removeChild(theDiv);
}

/*
window.alert = function(message){
    $(document.createElement('div'))
        .attr({title: 'Alert', 'class': 'alert'})
        .html(message)
        .dialog({
            buttons: {OK: function(){$(this).dialog('close');}},
            close: function(){$(this).remove();},
            draggable: true,
            modal: true,
            resizable: false,
            width: 'auto'
        });
};


function jqalert(output_msg, title_msg)
{
    if (!title_msg)
        title_msg = 'Alert';

    if (!output_msg)
        output_msg = 'No Message to Display.';

    $("<div></div>").html(output_msg).dialog({
        title: title_msg,
        resizable: false,
        modal: true,
        buttons: {
            "Ok": function() 
            {
                $( this ).dialog( "close" );
            }
        }
    });
}


*/



function saveSearch(returnURL){
	var uniqid,sName,sn,ru;
	uniqid = Date.now();
	sName=prompt("Saving search for URL:\n\n" + returnURL + " \n\nName your saved search (or copy and paste the link above).\n\nManage or email saved searches from your profile, or go to /saved/{name of saved search}. Note that saved searches, except those sepecifying only GUIDs, are dynamic; results change as data changes.\n\nName of saved search (must be unique):\n", uniqid);
	if (sName!==null){
		sn=encodeURIComponent(sName);
		ru=encodeURI(returnURL);
		$.getJSON("/component/functions.cfc",
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

/*
var dateFormat = function () {
	var	token;
	token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
		timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
		timezoneClip = /[^-+\dA-Z]/g,
		pad = function (val, len) {
			val = String(val);
			len = len || 2;
			while (val.length < len) val = "0" + val;
			return val;
		};
	return function (date, mask, utc) {
		var dF,_;
		dF= dateFormat;
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
		_ = utc ? "getUTC" : "get",
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


*/
function crcloo (ColumnList,in_or_out) {
	$.getJSON("/component/functions.cfc",
		{
			method : "clientResultColumnList",
			ColumnList : ColumnList,
			in_or_out : in_or_out,
			returnformat : "json",
			queryformat : 'column'
		}
	);
}

function checkAllById(list) {
	var a;
	a = list.split(',');
	//console.log(list);
	$.each( a, function( i, val ) {
		$( "#" + val).prop('checked', true);
	//	console.log(val);

	});
	crcloo(list,'in');
}

function uncheckAllById(list) {
	var a;
	a = list.split(',');
//	console.log(list);

	$.each( a, function( i, val ) {
		$( "#" + val).prop('checked', false);
	//	console.log(val);
	});
	crcloo(list,'out');

}

function goPickParts (collection_object_id,transaction_id) {
	var url;
	url='/picks/internalAddLoanItemTwo.cfm?collection_object_id=' + collection_object_id +"&transaction_id=" + transaction_id;
	mywin=windowOpener(url,'myWin','height=300,width=800,resizable,location,menubar ,scrollbars ,status ,titlebar,toolbar');
}
function hidePageLoad() {
	$('#loading').hide();
}
function findAccession () {
	var collection_id,accn_number;
	collection_id=document.getElementById('collection_id').value;
	accn_number=document.getElementById('accn_number').value;
	$.getJSON("/component/functions.cfc",
		{
			method : "findAccession",
			collection_id : collection_id,
			accn_number : accn_number,
			returnformat : "json",
			queryformat : 'column'
		},
		function (result) {
			if(result>0) {
				document.getElementById('g_num').className='doShow';
				document.getElementById('b_num').className='noShow';
			} else {
				document.getElementById('g_num').className='noShow';
				document.getElementById('b_num').className='doShow';
			}
		}
	);
}


function addPartToContainer () {
	var cid,pid1,pid2,parent_barcode,new_container_type;
	document.getElementById('pTable').className='red';
	cid=document.getElementById('collection_object_id').value;
	pid1=document.getElementById('part_name').value;
	pid2=document.getElementById('part_name_2').value;
	parent_barcode=document.getElementById('parent_barcode').value;
	new_container_type=document.getElementById('new_container_type').value;
	if(cid.length===0 || pid1.length===0 || parent_barcode.length===0) {
		alert('Something is null');
		return false;
	}
	$.getJSON("/component/functions.cfc",
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
		function (result) {
			statAry=result.split("|");
			var status=statAry[0];
			var msg=statAry[1];
			document.getElementById('pTable').className='';
			var mDiv=document.getElementById('msgs');
			var mhDiv=document.getElementById('msgs_hist');
			var mh=mDiv.innerHTML + '<hr>' + mhDiv.innerHTML;
			mhDiv.innerHTML=mh;
			mDiv.innerHTML=msg;
			if (status===0){
				mDiv.className='error';
			} else {
				mDiv.className='successDiv';
				document.getElementById('oidnum').focus();
				document.getElementById('oidnum').select();
				getParts();
			}
		}
	);
}

function clonePart() {
	var collection_id=document.getElementById('collection_id').value;
	var other_id_type=document.getElementById('other_id_type').value;
	var oidnum=document.getElementById('oidnum').value;
	if (collection_id.length>0 && other_id_type.length>0 && oidnum.length>0) {
		$.getJSON("/component/functions.cfc",
			{
				method : "getSpecimen",
				collection_id : collection_id,
				other_id_type : other_id_type,
				oidnum : oidnum,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				if (toString(r.DATA.COLLECTION_OBJECT_ID[0]).indexOf('Error:')>-1) {
					alert(r.DATA.COLLECTION_OBJECT_ID[0]);	
				} else {
					newPart (r.DATA.COLLECTION_OBJECT_ID[0]);
				}
			}
		);
	} else {
		alert('Error: cannot resolve ID to specimen.');
	}
}

function checkSubmit() {
	var c;
	c=document.getElementById('submitOnChange').checked;
	if (c===true) {
		addPartToContainer();
	}
}	
function newPart (collection_object_id) {
	var part,url;
	collection_id=document.getElementById('collection_id').value;
	part=document.getElementById('part_name').value;
	url="/form/newPart.cfm";
	url +="?collection_id=" + collection_id;
	url +="&collection_object_id=" + collection_object_id;
	url +="&part=" + part;
	divpop(url);
}
 function getParts() {
	var collection_id,other_id_type,oidnum,s,noBarcode,noSubsample,result,sDiv,ocoln,specid,p1,p2,op1,op2,selIndex,coln,idt,idn,ss,option;
	
	collection_id=document.getElementById('collection_id').value;
	other_id_type=document.getElementById('other_id_type').value;
	oidnum=document.getElementById('oidnum').value;
	if (collection_id.length>0 && other_id_type.length>0 && oidnum.length>0) {
		s=document.createElement('DIV');
	    s.id='ajaxStatus';
	    s.className='ajaxStatus';
	    s.innerHTML='Fetching parts...';
	    document.body.appendChild(s);
	    noBarcode=document.getElementById('noBarcode').checked;
	    noSubsample=document.getElementById('noSubsample').checked;
	    $.getJSON("/component/functions.cfc",
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
			function (r) {
				result=r.DATA;	
				s=document.getElementById('ajaxStatus');
				document.body.removeChild(s);
				sDiv=document.getElementById('thisSpecimen');
				ocoln=document.getElementById('collection_id');
				specid=document.getElementById('collection_object_id');
				p1=document.getElementById('part_name');
				p2=document.getElementById('part_name_2');
				op1=p1.value;
				op2=p2.value;
				p1.options.length=0;
				p2.options.length=0;
				selIndex = ocoln.selectedIndex;
				coln = ocoln.options[selIndex].text;		
				idt=document.getElementById('other_id_type').value;
				idn=document.getElementById('oidnum').value;
				ss=coln + ' ' + idt + ' ' + idn;
				if (result.PART_NAME[0].indexOf('Error:')>-1) {
					sDiv.className='error';
					ss+=' = ' + result.PART_NAME[0];
					specid.value='';
					document.getElementById('pTable').className='red';
				} else {
					document.getElementById('pTable').className='';
					sDiv.className='';
					specid.value=result.COLLECTION_OBJECT_ID[0];
					option = document.createElement('option');
					option.setAttribute('value','');
					option.appendChild(document.createTextNode(''));
					p2.appendChild(option);
					
					for (i=0;i<r.ROWCOUNT;i++) {
						option = document.createElement('option');
						option2 = document.createElement('option');
						option.setAttribute('value',result.PARTID[i]);
						option2.setAttribute('value',result.PARTID[i]);
						pStr=result.PART_NAME[i];
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
		);
	}
 }

function divpop (url) {
	var req,bgDiv,theDiv;
 	bgDiv=document.createElement('div');
	bgDiv.id='bgDiv';
	bgDiv.className='bgDiv';
	document.body.appendChild(bgDiv);
	theDiv = document.createElement('div');
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
	if (req !== undefined) {
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
	var collection_object_id,part_name,lot_count,coll_obj_disposition,condition,coll_object_remarks,barcode,new_container_type,result,status,msg,p,b;
	collection_object_id=document.getElementById('collection_object_id').value;
	part_name=document.getElementById('npart_name').value;
	lot_count=document.getElementById('lot_count').value;
	coll_obj_disposition=document.getElementById('coll_obj_disposition').value;
	condition=document.getElementById('condition').value;
	coll_object_remarks=document.getElementById('coll_object_remarks').value;
	barcode=document.getElementById('barcode').value;
	new_container_type=document.getElementById('new_container_type').value;
	$.getJSON("/component/functions.cfc",
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
			result=r.DATA;
			status=result.STATUS[0];
			if (status=='error') {
				msg=result.MSG[0];
				alert(msg);
			} else {
				msg="Created part: ";
				msg += result.PART_NAME[0] + " ";
				if (result.BARCODE[0]!==null) {
					msg += "barcode " + result.BARCODE[0];
					if (result.NEW_CONTAINER_TYPE[0]!==null) {
						msg += "( " + result.NEW_CONTAINER_TYPE[0] + ")";
					}
				}
				p = document.getElementById('ppDiv');
				document.body.removeChild(p);
				b = document.getElementById('bgDiv');
				document.body.removeChild(b);
				getParts();
			}
		}
	);
}
function changeresultSort (tgt) {
	$.getJSON("/component/functions.cfc",
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
	$.getJSON("/component/functions.cfc",
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


function getAgentInfo(agent_id) {
	removeHelpDiv();
	var bgDiv = document.createElement('div');
	bgDiv.id = 'bgDiv';
	bgDiv.className = 'bgDiv';
	bgDiv.setAttribute('onclick','removeHelpDiv()');
	document.body.appendChild(bgDiv);
	var theDiv = document.createElement('div');
	theDiv.id = 'helpDiv';
	theDiv.className = 'helpBox centered';
	theDiv.innerHTML='<img src="/images/indicator.gif" style="margin:5em;">';
	document.body.appendChild(theDiv);
	//$("#helpDiv").css({position:"absolute", top: e.pageY, left: e.pageX});
	$(theDiv).load("/ajax/agentInfo.cfm",{agent_id: agent_id, addCtl: 1});
}

$(document).ready(function() {
	
	
	//colorbox = $.colorbox;
	
	
	$(".helpLink").live('click', function(e){
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
		$("#helpDiv").css({position:"absolute", top: e.pageY, left: e.pageX});
		$(theDiv).load("/doc/get_short_doc.cfm",{fld: id, addCtl: 1});
	});
	$("#c_collection_cust").click(function(e){
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
		$(cDiv).load(ptl,{},function(){
			viewport.init("#customDiv");
		});
	});
	$("#c_identifiers_cust").click(function(e){
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
		$(cDiv).load(ptl,{},function(){
			viewport.init("#customDiv");
		});
	});
});
function scrollToAnchor(aid){
    var aTag = $("a[name='"+ aid +"']");
    $('html,body').animate({scrollTop: aTag.offset().top},'slow');
}
function changefancyCOID (tgt) {
	$.getJSON("/component/functions.cfc",
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
function changeBigSearch (tgt) {
	$.getJSON("/component/functions.cfc",
		{
			method : "changeBigSearch",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		function (result) {
			if (result == 'success') {
				var e = document.getElementById('changeBigSearch').className='';
			} else {
				alert('An error occured: ' + result);
			}
		}
	);
}
function changecustomOtherIdentifier (tgt) {
	$.getJSON("/component/functions.cfc",
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
	$('#bgDiv').remove();
	$('#helpDiv').remove();
}
function changeshowObservations (tgt) {
	$.getJSON("/component/functions.cfc",
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

function saveSpecSrchPref(id,onOff){
	var savedArray,result,cookieArray,cCookie,idFound;

	$.getJSON("/component/functions.cfc",
		{
			method : "saveSpecSrchPref",
			id : id,
			onOff : onOff,
			returnformat : "json",
			queryformat : 'column'
		},
		function (savedStr) {
			savedArray = savedStr.split(",");
			result = savedArray[0];
			id = savedArray[1];
			onOff = savedArray[2];
			if (result == "cookie") {
				cookieArray=[];
				//cookieArray = new Array();
				cCookie = readCookie("specsrchprefs");
				idFound = -1;
				if (cCookie!==null)	{
					cookieArray = cCookie.split(",");
					for (i = 0; i<cookieArray.length; i++) {
						if (cookieArray[i] == id) {
							idFound = i;
						}
					}
				}
				if (onOff==1) {		
					if (idFound == -1) {
						cookieArray.push(id);
					}
				}
				else {
					if (idFound != -1) {
						cookieArray.splice(idFound,1);
					}
				}
				var nCookie = cookieArray.join();
				createCookie("specsrchprefs", nCookie, 0);
			}
		}
	);
}
function showHide(id,onOff) {
	var t,ztab,ctl,offText,onText,ptl;
	t='e_' + id;
	z='c_' + id;
	if (document.getElementById(t) && document.getElementById(z)) {	
		tab=document.getElementById(t);
		ctl=document.getElementById(z);
		if (t=='e_spatial_query'){
			offText='Select on Google Map';
			onText='Hide Google Map';
		} else {
			onText='Show Fewer Options';
			offText='Show More Options';
		}
		if (onOff==1) {
			ptl="/includes/SpecSearch/" + id + ".cfm";
			ctl.innerHTML='<img src="/images/indicator.gif">';
			$.get(ptl, function(data){
				$(tab).html(data);
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
	var theDiv;
	document.location=location.href;
	theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
}
function getFormValues() {
 	var theForm,nval,spAry,i,theElement,element_name,element_value,str;
 	theForm=document.getElementById('SpecData');
 	nval=theForm.length;
 	spAry = [];
 	for (i=0; i<nval; i++) {
		theElement = theForm.elements[i];
		element_name = theElement.name;
		element_value = theElement.value;
		if (element_name.length>0 && element_value.length>0 && element_name !='selectedCoords') {
			var thisPair=element_name + '::' + String(element_value);
			if (spAry.indexOf(thisPair)==-1) {
				spAry.push(thisPair);
			}
		}
	} 	
	str=spAry.join("|");
	document.cookie = 'schParams=' + str;
 }
function nada(){
	return false;
}
function createCookie(name,value,days) {
	var expires,date;
	if (days) {
		date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		expires = "; expires="+date.toGMTString();
	} else {
		expires = "";
	}
	document.cookie = name+"="+value+expires+"; path=/";
}
function readCookie(name) {
	var nameEQ,ca,i,c;
	nameEQ = name + "=";
	ca = document.cookie.split(';');
	for(i=0;i < ca.length;i++) {
		c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}
function changeexclusive_collection_id (tgt) {
	$.getJSON("/component/functions.cfc",
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
   for (i = 0; i < sText.length && IsNumber === true; i++) { 
      Char = sText.charAt(i); 
      if (ValidChars.indexOf(Char) == -1) {
         IsNumber = false;
      }
   }
   return IsNumber;
}
 function get_cookie ( cookie_name ) {
  var results = document.cookie.match ( '(^|;) ?' + cookie_name + '=([^;]*)(;|$)' );
  if ( results ) {
    return ( unescape ( results[2] ) );
  } else {
    return null;
  }
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
		msg='Password must contain at least one letter.';
	}
	if (!p.match(/\d+/)) {
		msg='Password must contain at least one number.';
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
	var fullURL;
	fullURL = "/info/ctDocumentation.cfm?table=" + table + "&field=" + field;
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
	$.getJSON("/component/functions.cfc",
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
	var len;
	len = id.length;
	if (len === 0) {
	   	alert('Oops! A select box malfunctioned! Try changing the value and leaving with TAB. The background should change to green when you\'ve successfullly run the check routine.');
		return false;
	}
}
function chgCondition(collection_object_id) {
	helpWin=windowOpener("/picks/condition.cfm?collection_object_id="+collection_object_id,"conditionWin","width=800,height=338, resizable,scrollbars");
}
function getLoan(LoanIDFld,LoanNumberFld,loanNumber,collectionID){
	var url,oawin;
	url="/picks/getLoan.cfm";
	oawin=url+"?LoanIDFld="+LoanIDFld+"&LoanNumberFld="+LoanNumberFld+"&loanNumber="+loanNumber+"&agent_name="+collectionID;
	loanpickwin=window.open(oawin,"","width=400,height=338, resizable,scrollbars");
}
function getAgent(agentIdFld,agentNameFld,formName,agentNameString,allowCreation){
	var url,oawin;
	url="/picks/findAgent.cfm";
	oawin=url+"?agentIdFld="+agentIdFld+"&agentNameFld="+agentNameFld+"&formName="+formName+"&agent_name="+agentNameString+"&allowCreation="+allowCreation;
	agentpickwin=window.open(oawin,"","width=400,height=338, resizable,scrollbars");
}
function getProject(projIdFld,projNameFld,formName,projNameString){
	var url,prwin;
	url="/picks/findProject.cfm";
	prwin=url+"?projIdFld="+projIdFld+"&projNameFld="+projNameFld+"&formName="+formName+"&project_name="+projNameString;
	projpickwin=window.open(prwin,"","width=400,height=338, resizable,scrollbars");
}
function findCatalogedItem(collIdFld,CatNumStrFld,formName,oidType,oidNum,collID){
	var url,CatCollFld,ciWin;
	url="/picks/findCatalogedItem.cfm";
	
	ciWin=url+"?collIdFld="+collIdFld+"&CatNumStrFld="+CatNumStrFld+"&formName="+formName+"&oidType="+oidType+"&oidNum="+oidNum+"&collID="+collID;
	catItemWin=window.open(ciWin,"","width=400,height=338, resizable,scrollbars");
}
function findCollEvent(collIdFld,formName,dispField,eventName){
	var url,covwin;
	url="/picks/findCollEvent.cfm";
	covwin=url+"?collIdFld="+collIdFld+"&dispField="+dispField+"&formName="+formName+"&collecting_event_name="+eventName;
	ColPickwin=window.open(covwin,"","width=800,height=600, resizable,scrollbars");
}
function getPublication(pubStringFld,pubIdFld,publication_title,formName){
	var url,pubwin;
	url="/picks/findPublication.cfm";
	pubwin=url+"?pubStringFld="+pubStringFld+"&pubIdFld="+pubIdFld+"&publication_title="+publication_title+"&formName="+formName;
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

function getAccnMedia(idOfTxtFld,idOfPKeyFld){
	//accnNumber=value submitted by user, optional
	//collection_id
	var url,pickwin;
	url="/picks/getAccnMedia.cfm";
	pickwin=url+"?idOfTxtFld="+idOfTxtFld+"&idOfPKeyFld="+idOfPKeyFld;
	pickwin=window.open(pickwin,"","width=400,height=338, resizable,scrollbars");
}
function getAccn2(accnNumber,colID){
	//accnNumber=value submitted by user, optional
	//collection_id
	var url,pickwin;
	url="/picks/getAccn.cfm";
	pickwin=url+"?accnNumber="+accnNumber+"&collectionID="+colID;
	pickwin=window.open(pickwin,"","width=400,height=338, resizable,scrollbars");
}
function getGeog(geogIdFld,geogStringFld,formName,geogString){
	var url,geogwin;
	url="/picks/findHigherGeog.cfm";
	geogwin=url+"?geogIdFld="+geogIdFld+"&geogStringFld="+geogStringFld+"&formName="+formName+"&geogString="+geogString;
	geogpickwin=window.open(geogwin,"","width=400,height=338, resizable,scrollbars");
}
function confirmDelete(formName,msg) {
	var yesno,txtstrng;
	msg = msg || "this record";
	yesno=confirm('Are you sure you want to delete ' + msg + '?');
	//confirmWin=windowOpener("/includes/abort.cfm?formName="+formName+"&msg="+msg,"confirmWin","width=200,height=150,resizable");
	if (yesno===true) {
  		document[formName].submit();
 	} else {
	  	return false;
  	}
}
function getHistory(contID) {
	var idcontID;
	historyWin=windowOpener("/info/ContHistory.cfm?container_id="+contID,"historyWin","width=800,height=600, resizable,scrollbars");
}
function getQuadHelp() {
	helpWin=windowOpener("/info/quad.cfm","quadHelpWin","width=800,height=600, resizable,scrollbars,status");
}
function getLegal(blurb) {
	helpWin=windowOpener("/info/legal.cfm?content="+blurb,"legalWin","width=400,height=338, resizable,scrollbars");
}	
function getInfo(subject,id) {
	infoWin=windowOpener("/info/SpecInfo.cfm?subject=" + subject + "&thisId="+id,"infoWin","width=800,height=500, resizable,scrollbars");
}	
function addLoanItem(coll_obj_id) {
	loanItemWin=windowOpener("/user/loanItem.cfm?collection_object_id="+coll_obj_id,"loanItemWin","width=800,height=500, resizable,scrollbars,toolbar,menubar");
}
function findMedia(mediaStringFld,mediaIdFld,media_uri){
	var url,popurl;
	url="/picks/findMedia.cfm";
	popurl=url+"?mediaIdFld="+mediaIdFld+"&mediaStringFld="+mediaStringFld+"&media_uri="+media_uri;
	mediapick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}
function taxaPick(taxonIdFld,taxonNameFld,formName,scientificName){
	var url,popurl;
	url="/picks/TaxaPick.cfm";
	popurl=url+"?taxonIdFld="+taxonIdFld+"&taxonNameFld="+taxonNameFld+"&formName="+formName+"&scientific_name="+scientificName;
	taxapick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}
function taxaPickIdentification(taxonIdFld,taxonNameFld,formName,scientificName){
	var url,popurl;
	url="/picks/TaxaPickIdentification.cfm";
	popurl=url+"?taxonIdFld="+taxonIdFld+"&taxonNameFld="+taxonNameFld+"&formName="+formName+"&scientific_name="+scientificName;
	taxapick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
	}
function CatItemPick(collIdFld,catNumFld,formName,sciNameFld){
	var url,popurl,w;
	url="/picks/CatalogedItemPick.cfm";
	popurl=url+"?collIdFld="+collIdFld+"&catNumFld="+catNumFld+"&formName="+formName+"&sciNameFld="+sciNameFld;
	w=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}
function findAgentName(agentIdFld,agentNameFld,agentNameString){
	var url,popurl;
	url="/picks/findAgentName.cfm";
	popurl=url+"?agentIdFld="+agentIdFld+"&agentNameFld="+agentNameFld+"&agentName="+agentNameString;
	agentpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}
function addrPick(addrIdFld,addrFld,formName){
	var url,popurl;
	url="/picks/AddrPick.cfm";
	popurl=url+"?addrIdFld="+addrIdFld+"&addrFld="+addrFld+"&formName="+formName;
	addrpick=window.open(popurl,"","width=400,height=338, resizable,scrollbars");
}
function GeogPick(geogIdFld,highGeogFld,formName){
	var url,popurl;
	url="/picks/GeogPick2.cfm";
	popurl=url+"?geogIdFld="+geogIdFld+"&highGeogFld="+highGeogFld+"&formName="+formName;
	geogpick=window.open(popurl,"","width=600,height=600, toolbar,resizable,scrollbars,");
}
function LocalityPick(localityIdFld,speclocFld,formName,localityNameString){
	var url,popurl,fireEvent;
	url="/picks/LocalityPick.cfm";
	popurl=url+"?localityIdFld="+localityIdFld+"&speclocFld="+speclocFld+"&formName="+formName+"&locality_name="+localityNameString;
	localitypick=window.open(popurl,"","width=800,height=600,resizable,scrollbars,");
}
function findJournal(journalIdFld,journalNameFld,formName,journalNameString){
	var url,popurl,w;
	url="/picks/findJournal.cfm";
	popurl=url+"?journalIdFld="+journalIdFld+"&journalNameFld="+journalNameFld+"&formName="+formName+"&journalName="+journalNameString;
	w=window.open(popurl,"","width=400,height=338, toolbar,location,status,menubar,resizable,scrollbars,");
}
function deleteEncumbrance(encumbranceId,collectionObjectId){
	var url,popurl,w;
	url="/picks/DeleteEncumbrance.cfm";
	popurl=url+"?encumbrance_id="+encumbranceId+"&collection_object_id="+collectionObjectId;
	w=window.open(popurl,"","width=400,height=338, toolbar,location,status,menubar,resizable,scrollbars,");
}
function getAllSheets() {
	var Lt,St,rel,x;
	if( !window.ScriptEngine && navigator.__ice_version ) {
		return document.styleSheets; }
	if( document.getElementsByTagName ) {
		Lt = document.getElementsByTagName('LINK');
	    St = document.getElementsByTagName('STYLE');
	  } else if( document.styleSheets && document.all ) {
	    Lt = document.all.tags('LINK');
	    St = document.all.tags('STYLE');
	  } else { return []; }
	  for( x = 0, os = []; Lt[x]; x++ ) {
	    if( Lt[x].rel ) { rel = Lt[x].rel;
	    } else if( Lt[x].getAttribute ) { rel = Lt[x].getAttribute('rel');
	    } else { rel = ''; }
	    if( typeof( rel ) == 'string' &&
	        rel.toLowerCase().indexOf('style') + 1 ) {
	      os[os.length] = Lt[x];
	    }
	  }
	  for( x = 0; St[x]; x++ ) { os[os.length] = St[x]; } return os;
}
function changeStyle() {
	var x,y;
	for( x = 0, ss = getAllSheets(); ss[x]; x++ ) {
		if( ss[x].title ) {
			ss[x].disabled = true;
		}
		for( y = 0; y < arguments.length; y++ ) {
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
		if ($.browser.msie && $.browser.version > 6 && o.dropShadows && o.animation.opacity!==undefined)
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

})($);
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
	
})($); // plugin code ends
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
			var ev = $.extend({},e);
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
	
})($);


// from internalAjax


function toProperCase(e) {
	var textarea = document.getElementById(e);
	var len = textarea.value.length;
	var start = textarea.selectionStart;
	var end = textarea.selectionEnd;
	var s = textarea.value.substring(start, end);
	var d=s.toLowerCase().replace(/^(.)|\s(.)/g, 
	function($1) { return $1.toUpperCase(); });	
	var before = textarea.value.substring(0,start);
	var after = textarea.value.substring(end, textarea.value.length);
	var result=before + d + after;
	textarea.value = result;	
}

function italicize(e){
	var textarea = document.getElementById(e);
	var len = textarea.value.length;
	var start = textarea.selectionStart;
	var end = textarea.selectionEnd;
	var sel = textarea.value.substring(start, end);
	if (sel.length>0){
		var replace = '<i>' + sel + '</i>';
		textarea.value =  textarea.value.substring(0,start) + replace + textarea.value.substring(end,len);
	} 
}
function bold(e){
	var textarea = document.getElementById(e);
	var len = textarea.value.length;
	var start = textarea.selectionStart;
	var end = textarea.selectionEnd;
	var sel = textarea.value.substring(start, end);
	if (sel.length>0){
		var replace = '<b>' + sel + '</b>';
		textarea.value =  textarea.value.substring(0,start) + replace + textarea.value.substring(end,len);
	} 
}
function superscript(e){
	var textarea = document.getElementById(e);
	var len = textarea.value.length;
	var start = textarea.selectionStart;
	var end = textarea.selectionEnd;
	var sel = textarea.value.substring(start, end);
	if (sel.length>0){
		var replace = '<sup>' + sel + '</sup>';
		textarea.value =  textarea.value.substring(0,start) + replace + textarea.value.substring(end,len);
	} 
}
function subscript(e){
	var textarea = document.getElementById(e);
	var len = textarea.value.length;
	var start = textarea.selectionStart;
	var end = textarea.selectionEnd;
	var sel = textarea.value.substring(start, end);
	if (sel.length>0){
		var replace = '<sub>' + sel + '</sub>';
		textarea.value =  textarea.value.substring(0,start) + replace + textarea.value.substring(end,len);
	} 
}
function saveNewPartAtt () {
	$.getJSON("/component/functions.cfc",
	{
		method : "saveNewPartAtt",
		returnformat : "json",
		attribute_type: $('#attribute_type_new').val(),
		attribute_value: $('#attribute_value_new').val(),
		attribute_units: $('#attribute_units_new').val(),
		determined_date: $('#determined_date_new').val(),
		determined_by_agent_id: $('#determined_id_new').val(),
		attribute_remark: $('#attribute_remark_new').val(),
		partID: $('#partID').val(),
		determined_agent: $('#determined_agent_new').val()
	},
		function (data) {
			console.log(data);
		}
	);
}
function setPartAttOptions(id,patype) {
	var cType,valElem,d,unitElem,theVals,dv;
	$.getJSON("/component/functions.cfc",
		{
			method : "getPartAttOptions",
			returnformat : "json",
			patype      : patype
		},
		function (data) {
			cType=data.TYPE;
			valElem='attribute_value_' + id;
			unitElem='attribute_units_' + id;
			if (data.TYPE=='unit') {
				d='<input type="text" name="' + valElem + '" id="' + valElem + '">';
				$('#v_' + id).html(d);
				theVals=data.VALUES.split('|');
				d='<select name="' + unitElem + '" id="' + unitElem + '">';
	  			for (a=0; a<theVals.length; ++a) {
					d+='<option value="' + theVals[a] + '">'+ theVals[a] +'</option>';
				}
	  			d+="</select>";
	  			$('#u_' + id).html(d);
			} else if (data.TYPE=='value') {
				theVals=data.VALUES.split('|');
				d='<select name="' + valElem + '" id="' + valElem + '">';
	  			for (a=0; a<theVals.length; ++a) {
					d+='<option value="' + theVals[a] + '">'+ theVals[a] +'</option>';
				}
	  			d+="</select>";
	  			$('#v_' + id).html(d);
				$('#u_' + id).html('');
			} else {
				dv='<input type="text" name="' + valElem + '" id="' + valElem + '">';
				$('#v_' + id).html(dv);
				$('#u_' + id).html('');
			}
		}
	);
}
function mgPartAtts(partID) {
	addBGDiv('closePartAtts()');
	var theDiv = document.createElement('iFrame');
	theDiv.id = 'partsAttDiv';
	theDiv.className = 'annotateBox';
	theDiv.innerHTML='<br>Loading...';
	document.body.appendChild(theDiv);
	var ptl="/form/partAtts.cfm?partID=" + partID;
	theDiv.src=ptl;
	viewport.init("#partsAttDiv");
}

function closePartAtts() {
	/*
	 * 
	 * var theDiv = document.getElementById('bgDiv');
	document.body.removeChild(theDiv);
	var theDiv = document.getElementById('partsAttDiv');
	document.body.removeChild(theDiv);
	
		var theDiv = parent.document.getElementById('bgDiv');
	parent.document.body.removeChild(theDiv);
	var theDiv = parent.document.getElementById('partsAttDiv');
	parent.document.body.removeChild(theDiv);
	
	
	*/
	$('#bgDiv').remove();
	$('#partsAttDiv').remove();
	$('#bgDiv', window.parent.document).remove();
	$('#partsAttDiv', window.parent.document).remove();

	
}
function cloneTransAgent(i){
	var id=$('#agent_id_' + i).val();
	var name=$('#trans_agent_' + i).val();
	var role=$('#cloneTransAgent_' + i).val();
	$('#cloneTransAgent_' + i).val('');
	addTransAgent (id,name,role);
}
function addTransAgent (id,name,role) {
	if (typeof id == "undefined") {
		id = "";
	 }
	if (typeof name == "undefined") {
		name = "";
	 }
	if (typeof role == "undefined") {
		role = "";
	 }
	$.getJSON("/component/functions.cfc",
		{
			method : "getTrans_agent_role",
			returnformat : "json",
			queryformat : 'column'
		},
		function (data) {
			var i=parseInt(document.getElementById('numAgents').value)+1;
			var d='<tr><td>';
			d+='<input type="hidden" name="trans_agent_id_' + i + '" id="trans_agent_id_' + i + '" value="new">';
			d+='<input type="text" id="trans_agent_' + i + '" name="trans_agent_' + i + '" class="reqdClr" size="30" value="' + name + '"';
  			d+=' onchange="getAgent(\'agent_id_' + i + '\',\'trans_agent_' + i + '\',\'editloan\',this.value);"';
  			d+=' return false;"	onKeyPress="return noenter(event);">';
  			d+='<input type="hidden" id="agent_id_' + i + '" name="agent_id_' + i + '" value="' + id + '">';
  			d+='</td><td>';
  			d+='<select name="trans_agent_role_' + i + '" id="trans_agent_role_' + i + '">';
  			for (a=0; a<data.ROWCOUNT; ++a) {
				d+='<option ';
				if(role==data.DATA.TRANS_AGENT_ROLE[a]){
					d+=' selected="selected"';
				}
				d+=' value="' + data.DATA.TRANS_AGENT_ROLE[a] + '">'+ data.DATA.TRANS_AGENT_ROLE[a] +'</option>';
			}
  			d+='</td><td>';
  			d+='<input type="checkbox" name="del_agnt_' + i + '" name="del_agnt_' + i + '" value="1">';
  			d+='</td><td>';
  			d+='<select id="cloneTransAgent_' + i + '" onchange="cloneTransAgent(' + i + ')" style="width:8em">';
  			d+='<option value=""></option>';
  			for (a=0; a<data.ROWCOUNT; ++a) {
				d+='<option value="' + data.DATA.TRANS_AGENT_ROLE[a] + '">'+ data.DATA.TRANS_AGENT_ROLE[a] +'</option>';
			}
			d+='</select>';		
  			d+='</td><td>-</td></tr>';
  			document.getElementById('numAgents').value=i;
  			$('#loanAgents tr:last').after(d);
		}
	);
}


$("#uploadMedia").live('click', function(e){
	addBGDiv('removeUpload()');
	var theDiv = document.createElement('iFrame');
	theDiv.id = 'uploadDiv';
	theDiv.className = 'uploadMediaDiv';
	theDiv.innerHTML='<br>Loading...';
	document.body.appendChild(theDiv);
	var ptl="/info/upMedia.cfm";
	theDiv.src=ptl;
	viewport.init("#uploadDiv");
});
function removeUpload() {
	if(document.getElementById('uploadDiv')){
		$('#uploadDiv').remove();
	}
	removeBgDiv();
}
function closeUpload(media_uri,preview_uri) {
	document.getElementById('media_uri').value=media_uri;
	document.getElementById('preview_uri').value=preview_uri;
	var uext = media_uri.split('.').pop();
	if (uext=='jpg' || uext=='jpeg'){
		 $("#mime_type").val('image/jpeg');
		 $("#media_type").val('image');
	 } else if (uext=='pdf'){
		 $("#mime_type").val('application/pdf');
		 $("#media_type").val('text');
	 } else if (uext=='mp3'){
		 $("#mime_type").val('audio/mpeg3');
		 $("#media_type").val('audio');
	} else if (uext=='wav'){
		 $("#mime_type").val('audio/x-wav');
		 $("#media_type").val('audio');
	} else if (uext=='dng'){
		 $("#mime_type").val('image/dng');
		 $("#media_type").val('image');
	} else if (uext=='png'){
		 $("#mime_type").val('image/png');
		 $("#media_type").val('image');
	} else if (uext=='tif' || uext=='tiff'){
		 $("#mime_type").val('image/tiff');
		 $("#media_type").val('image');
	} else if (uext=='htm' || uext=='html'){
		 $("#mime_type").val('text/html');
		 $("#media_type").val('');
	} else if (uext=='txt'){
		 $("#mime_type").val('text/plain');
		 $("#media_type").val('text');
	} else if (uext=='mp4'){
		 $("#mime_type").val('video/mp4');
		 $("#media_type").val('video');
	}
	removeUpload();
}
function generateMD5() {
	var theImageFile=document.getElementById('media_uri').value;
	$.getJSON("/component/functions.cfc",
		{
			method : "genMD5",
			uri : theImageFile,
			returnformat : "json",
			queryformat : 'column'
		},
		success_generateMD5
	);
}
function success_generateMD5(result){
	var cc=document.getElementById('number_of_labels').value;
	cc=parseInt(cc)+parseInt(1);
	addLabel(cc);
	var lid='label__' + cc;
	var lvid='label_value__' + cc;
	var nl=document.getElementById(lid);
	var nlv=document.getElementById(lvid);
	nl.value='MD5 checksum';
	nlv.value=result;
}
function closePreviewUpload(preview_uri) {
	var theDiv = document.getElementById('uploadDiv');
	document.body.removeChild(theDiv);
	document.getElementById('preview_uri').value=preview_uri;
}

function clickUploadPreview(){
	var theDiv = document.createElement('iFrame');
	theDiv.id = 'uploadDiv';
	theDiv.name = 'uploadDiv';
	theDiv.className = 'uploadMediaDiv';
	document.body.appendChild(theDiv);
	var guts = "/info/upMediaPreview.cfm";
	theDiv.src=guts;
}
function pickedRelationship (id){
	var relationship=document.getElementById(id).value;
	var ddPos = id.lastIndexOf('__');
	var elementNumber=id.substring(ddPos+2,id.length);
	var relatedTableAry=relationship.split(" ");
	var relatedTable=relatedTableAry[relatedTableAry.length-1];
	var idInputName = 'related_id__' + elementNumber;
	var dispInputName = 'related_value__' + elementNumber;
	var hid=document.getElementById(idInputName);
	hid.value='';
	var inp=document.getElementById(dispInputName);
	inp.value='';
	if (relatedTable==='') {
		// do nothing, cleanup already happened
	} else if (relatedTable=='agent'){
		//addAgentRelation(elementNumber);
		getAgent(idInputName,dispInputName,'newMedia','');		
	} else if (relatedTable=='locality'){
		LocalityPick(idInputName,dispInputName,'newMedia'); 
	} else if (relatedTable=='collecting_event'){
		findCollEvent(idInputName,'newMedia',dispInputName);
	} else if (relatedTable=='cataloged_item'){
		findCatalogedItem(idInputName,dispInputName,'newMedia');
	} else if (relatedTable=='project'){
		getProject(idInputName,dispInputName,'newMedia');
	} else if (relatedTable=='taxonomy'){
		taxaPick(idInputName,dispInputName,'newMedia');
	} else if (relatedTable=='publication'){
		getPublication(dispInputName,idInputName,'','newMedia');
	} else if (relatedTable=='accn'){
		// accnNumber, colID
		getAccnMedia(dispInputName,idInputName);
	} else if (relatedTable=='media'){
		findMedia(dispInputName,idInputName);
	} else if (relatedTable=='loan'){
		getLoan(idInputName,dispInputName);
	} else if (relatedTable=='delete'){
		document.getElementById(dispInputName).value='Marked for deletion.....';
	} else {
		alert('Something is broken. I have no idea what to do with a relationship to ' + relatedTable);
	}
}

/*
function addAgentRelation (elementNumber){
	var theDivName = 'relationshipDiv__' + elementNumber;
	var theDiv=document.getElementById(theDivName);
	var theSpanName = 'relationshipSpan__' + elementNumber;
	nSpan = document.createElement("span");
	var idInputName = 'agent_id_' + elementNumber;
	var dispInputName = 'agent_name_' + elementNumber;
	var theHtml='<input type="hidden" name="' + idInputName + '">';
	theHtml+='<input type="text" name="' + dispInputName + '" size="80">';
	nSpan.innerHTML=theHtml;
	nSpan.id=theSpanName;
	theDiv.appendChild(nSpan);
	getAgent(idInputName,dispInputName,'newMedia','');
}
function addLocalityRelation (elementNumber){
	var theDivName = 'relationshipDiv__' + elementNumber;
	var theDiv=document.getElementById(theDivName);
	var theSpanName = 'relationshipSpan__' + elementNumber;
	nSpan = document.createElement("span");
	var idInputName = 'locality_id_' + elementNumber;
	var dispInputName = 'spec_locality_' + elementNumber;
	var theHtml='<input type="hidden" name="' + idInputName + '">';
	theHtml+='<input type="text" name="' + dispInputName + '" size="80">';
	nSpan.innerHTML=theHtml;
	nSpan.id=theSpanName;
	theDiv.appendChild(nSpan);
	LocalityPick(idInputName,dispInputName,'newMedia'); 
}
*/
function addRelation (n) {
	var pDiv,nDiv,n1,selName,nSel,inpName,nInp,hName,nHid,mS,np1,oc,cc;
	pDiv=document.getElementById('relationships');
	nDiv = document.createElement('div');
	nDiv.id='relationshipDiv__' + n;
	pDiv.appendChild(nDiv);
	n1=n-1;
	selName='relationship__' + n1;
	nSel = document.getElementById(selName).cloneNode(true);
	nSel.name="relationship__" + n;
	nSel.id="relationship__" + n;
	nSel.value='delete';
	nDiv.appendChild(nSel);	
	c = document.createElement("textNode");
	c.innerHTML=":&nbsp;";
	nDiv.appendChild(c);
	n1=n-1;
	inpName='related_value__' + n1;
	nInp = document.getElementById(inpName).cloneNode(true);
	nInp.name="related_value__" + n;
	nInp.id="related_value__" + n;
	nInp.value='';
	nDiv.appendChild(nInp);
	hName='related_id__' + n1;
	nHid = document.getElementById(hName).cloneNode(true);
	nHid.name="related_id__" + n;
	nHid.id="related_id__" + n;
	nDiv.appendChild(nHid);
	mS = document.getElementById('addRelationship');
	pDiv.removeChild(mS);
	np1=n+1;
	oc="addRelation(" + np1 + ")";
	mS.setAttribute("onclick",oc);
	pDiv.appendChild(mS);
	
	cc=document.getElementById('number_of_relations');
	cc.value=parseInt(cc.value)+1;
}

function addLabel (n) {
	var pDiv,nDiv,n1,selName,nSel,inpName,nInp,mS,np1,oc,cc;
	
	
	pDiv=document.getElementById('labels');
	nDiv = document.createElement('div');
	nDiv.id='labelsDiv__' + n;
	pDiv.appendChild(nDiv);
	n1=n-1;
	selName='label__' + n1;
	nSel = document.getElementById(selName).cloneNode(true);
	nSel.name="label__" + n;
	nSel.id="label__" + n;
	nSel.value='';
	nDiv.appendChild(nSel);
	
	c = document.createElement("textNode");
	c.innerHTML=":&nbsp;";
	nDiv.appendChild(c);
	
	inpName='label_value__' + n1;
	nInp = document.getElementById(inpName).cloneNode(true);
	nInp.name="label_value__" + n;
	nInp.id="label_value__" + n;
	nInp.value='';
	nDiv.appendChild(nInp);

	mS = document.getElementById('addLabel');
	pDiv.removeChild(mS);
	np1=n+1;
	oc="addLabel(" + np1 + ")";
	mS.setAttribute("onclick",oc);
	pDiv.appendChild(mS);
	
	cc=document.getElementById('number_of_labels');
	cc.value=parseInt(cc.value)+1;
}
function tog_AgentRankDetail(o){
	if(o==1){
		document.getElementById('agentRankDetails').style.display='block';
		$('#t_agentRankDetails').text('Hide Details').removeAttr('onclick').bind("click", function() {
			tog_AgentRankDetail(0);
		});
	} else {
		document.getElementById('agentRankDetails').style.display='none';
		$('#t_agentRankDetails').text('Show Details').removeAttr('onclick').bind("click", function() {
			tog_AgentRankDetail(1);
		}); 
	}
}
function saveAgentRank(){		
	$.getJSON("/component/functions.cfc",
		{
			method : "saveAgentRank",
			agent_id : $('#agent_id').val(),
			agent_rank : $('#agent_rank').val(),
			remark : $('#remark').val(),
			transaction_type : $('#transaction_type').val(),
			returnformat : "json",
			queryformat : 'column'
		},
		function (d) {
			if(d.length>0 && d.substring(0,4)=='fail'){
				alert(d);
			} else {
				var ih = 'Thank you for adding an agent rank.';
				ih+='<p><span class="likeLink" onclick="removePick();rankAgent(' + d + ')">Refresh</span></p>';
				ih+='<p><span class="likeLink" onclick="removePick();">Done</span></p>';				
				document.getElementById('pickDiv').innerHTML=ih;
			}
		}
	); 		
}
function revokeAgentRank(agent_rank_id){
	$.getJSON("/component/functions.cfc",
		{
			method : "revokeAgentRank",
			agent_rank_id : agent_rank_id,
			returnformat : "json",
			queryformat : 'column'
		},
		function (d) {
			if(d.length>0 && d.substring(0,4)=='fail'){
				alert(d);
			} else {
				$('#tablr' + agent_rank_id).remove();
			}
		}
	); 	
	
}

function removeMediaMultiCatItem(){
	
	$('#bgDiv').remove();
	$('#pickFrame').remove();
}
function manyCatItemToMedia(mid){
	//addBGDiv('removePick()');
	var bgDiv = document.createElement('div');
	bgDiv.id = 'bgDiv';
	bgDiv.className = 'bgDiv';
	
	bgDiv.setAttribute('onclick',"removeMediaMultiCatItem()");
	document.body.appendChild(bgDiv);
	
	
//	var bgDiv = document.createElement('div');
//	bgDiv.id = 'bgDiv';
//	bgDiv.className = 'bgDiv';
//	bgDiv.setAttribute('onclick','closeManyMedia()');
//	document.body.appendChild(bgDiv);
	var ptl = "/includes/forms/manyCatItemToMedia.cfm?media_id=" + mid;
	$('<iframe id="pickFrame" name="pickFrame" class="pickDiv" src="' + ptl + '">').appendTo('body');
	//$('<iframe />').attr('src', ptl); 
	

	//document.body.appendChild(theiFrame);
	//jQuery.get(ptl,function(data){
	//	document.getElementById('theiFrame').innerHTML=data;
		viewport.init("#pickDiv");
	//document.body.appendChild(theDiv);
	//$('#annotateDiv').append('<iframe id="commentiframe" width="100%" height="100%">');
	//$('#commentiframe').attr('src', guts);
}
function rankAgent(agent_id) {
	addBGDiv('removePick()');
	var theDiv = document.createElement('div');
	theDiv.id = 'pickDiv';
	theDiv.className = 'pickDiv';
	theDiv.innerHTML='<br>Loading...';
	document.body.appendChild(theDiv);
	var ptl="/includes/forms/agentrank.cfm";			
	$.get(ptl,{agent_id: agent_id},function(data){
		document.getElementById('pickDiv').innerHTML=data;
		viewport.init("#pickDiv");
	});
}
function pickThis (fld,idfld,display,aid) {
	document.getElementById(fld).value=display;
	document.getElementById(idfld).value=aid;
	document.getElementById(fld).className='goodPick';
	removePick();
}
function removePick() {
	if(document.getElementById('pickDiv')){
		$('#pickDiv').remove();
	}
	removeBgDiv();
}
function addBGDiv(f){
	var bgDiv = document.createElement('div');
	bgDiv.id = 'bgDiv';
	bgDiv.className = 'bgDiv';
	if(f===null || f.length===0){
		f="removeBgDiv()";
	}
	bgDiv.setAttribute('onclick',f);
	document.body.appendChild(bgDiv);
}
function removeBgDiv () {
	if(document.getElementById('bgDiv')){
		$('#bgDiv').remove();
	}
}
function get_AgentName(name,fld,idfld){
	addBGDiv('removePick()');
	var theDiv = document.createElement('div');
	theDiv.id = 'pickDiv';
	theDiv.className = 'pickDiv';
	theDiv.innerHTML='<br>Loading...';
	document.body.appendChild(theDiv);
	var ptl="/picks/getAgentName.cfm";			
	$.get(ptl,{agentname: name, fld: fld, idfld: idfld},function(data){
		document.getElementById('pickDiv').innerHTML=data;
		viewport.init("#pickDiv");
	});
}
function addLink (n) {
	var lid = $('#linkTab tr:last').attr("id");
	var lastID=lid.replace('linkRow','');
	if (lastID.length===0){
		lastID=0;
	}
	var thisID=parseInt(lastID) + 1;	
	var newRow='<tr id="linkRow' + thisID + '">';
	newRow+='<td>';
	newRow+='<input type="text"  size="60" name="link' + thisID + '" id="link' + thisID + '">';
	newRow+='</td>';
	newRow+='<td>';
	newRow+='<input type="text"  size="10" name="description' + thisID + '" id="description' + thisID + '">';
	newRow+='</td>';
	newRow+='</tr>';		
	$('#linkTab tr:last').after(newRow);
	document.getElementById('numberLinks').value=thisID;
}

function addAgent (n) {
	var lid = $('#authTab tr:last').attr("id");
	var lastID=lid.replace('authortr','');
	if(lastID===''){
		lastID=0;
	}
	var thisID=parseInt(lastID) + 1;
	var newRow='<tr id="authortr' + thisID + '">';
	newRow+='<td>';
	newRow+='<select name="author_role_' + thisID + '" id="author_role_' + thisID + '1">';
	newRow+='<option value="author">author</option>';
	newRow+='<option value="editor">editor</option>';
	newRow+='</select>';
	newRow+='</td>';
	newRow+='<td>';
	newRow+='<input type="hidden" name="agent_id' + thisID + '" id="agent_id' + thisID + '">';
	newRow+='<input type="hidden" name="publication_agent_id' + thisID + '" id="publication_agent_id' + thisID + '">';
	newRow+='<input type="text" name="author_name_' + thisID + '" id="author_name_' + thisID + '" class="reqdClr"  size="50" ';
	newRow+='onchange="getAgent(\'agent_id' + thisID + '\',this.name,\'editPub\',this.value);"';		
	newRow+='onKeyPress="return noenter(event);">';		
	newRow+='</td>';
	newRow+='</tr>';		
	$('#authTab tr:last').after(newRow);
	document.getElementById('numberAuthors').value=thisID;
}
function removeAgent() {
	var lid = $('#authTab tr:last').attr("id");
	var lastID=lid.replace('authortr','');
	var thisID=parseInt(lastID) - 1;
	document.getElementById('numberAuthors').value=thisID;
	if(thisID>=1){
		$('#authTab tr:last').remove();
	} else {
		alert('You must have at least one author');
	}
}
function removeLastAttribute() {
	var lid = $('#attTab tr:last').attr("id");
	if (lid.length===0) {
		alert('nothing to remove');
		return false;
	}
	var lastID=lid.replace('attRow','');
	var thisID=parseInt(lastID) - 1;
	document.getElementById('numberAttributes').value=thisID;
	$('#attTab tr:last').remove();
}
function addAttribute(v){
	$.getJSON("/component/functions.cfc",
		{
			method : "getPubAttributes",
			attribute : v,
			returnformat : "json",
			queryformat : 'column'
		},
		function (d) {
			var lid=$('#attTab tr:last').attr("id");
			if(lid.length===0){
				lid='attRow0';
			}
			var lastID=lid.replace('attRow','');
			var thisID=parseInt(lastID) + 1;
			var newRow='<tr id="attRow' + thisID + '"><td>' + v;
			newRow+='<input type="hidden" name="attribute_type' + thisID + '"';
			newRow+=' id="attribute_type' + thisID + '" class="reqdClr" value="' + v + '"></td><td>';
			if(d.length>0 && d.substring(0,4)=='fail'){
				alert(d);
				return false;
			} else if(d=='nocontrol'){
				newRow+='<input type="text" name="attribute' + thisID + '" id="attribute' + thisID + '" size="50" class="reqdClr">';
			} else {
				newRow+='<select name="attribute' + thisID + '" id="attribute' + thisID + '" class="reqdClr">';
				for (i=0; i<d.ROWCOUNT; ++i) {
					newRow+='<option value="' + d.DATA.v[i] + '">'+ d.DATA.v[i] +'</option>';
				}
				newRow+='</select>';
			}
			newRow+="</td></tr>";
			$('#attTab tr:last').after(newRow);
			document.getElementById('numberAttributes').value=thisID;
		}
	); 		
}
function setDefaultPub(t){
	if(t=='journal article'){
    	addAttribute('journal name');
    	// crude but try to get this stuff in order if we can...
    	setTimeout( "addAttribute('begin page')", 1000);
    	setTimeout( "addAttribute('end page');", 1500);
    	setTimeout( "addAttribute('volume');", 2000);
    	setTimeout( "addAttribute('issue');", 2500);			
	} else if (t=='book'){
		addAttribute('volume');
    	setTimeout( "addAttribute('page total')", 1000);
    	setTimeout( "addAttribute('publisher')", 1500);
	} else if (t=='book section'){
    	addAttribute('publisher');
    	setTimeout( "addAttribute('volume')", 1000);
    	setTimeout( "addAttribute('page total')", 1500);
    	setTimeout( "addAttribute('section type')", 2000);
    	setTimeout( "addAttribute('section order')", 2500);
    	setTimeout( "addAttribute('begin page')", 3000);
    	setTimeout( "addAttribute('end page')", 3500);
	}
}
function deleteAgent(r){
	$('#author_name' + r).addClass('red').val("deleted");
	$('#authortr' + r + ' td:nth-child(1)').addClass('red');
	$('#authortr' + r + ' td:nth-child(3)').addClass('red');						
}
function deletePubAtt(r){
	var newElem='<input type="hidden" name="attribute' + r + '" id="attribute' + r + '" value="deleted">';
	$('#attRow' + r + ' td:nth-child(1)').addClass('red').text($('#attribute_type' + r).val());
	$('#attRow' + r + ' td:nth-child(2)').addClass('red').text($('#attribute' + r).val()).append(newElem);
	$('#attRow' + r + ' td:nth-child(3)').addClass('red').text('deleted');
}
function deleteLink(r){
	var newElem='<input type="hidden" name="link' + r + '" id="link' + r + '" value="deleted">';
	$('#linkRow' + r + ' td:nth-child(1)').addClass('red').text('deleted').append(newElem);
	$('#linkRow' + r + ' td:nth-child(2)').addClass('red').text('');
}