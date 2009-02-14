function findAccession () {
	var collection_id=document.getElementById('collection_id').value;
	var accn_number=document.getElementById('accn_number').value;
	DWREngine._execute(_cfscriptLocation, null, 'findAccession',collection_id,accn_number,success_findAccession);	
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
	var collection_id=document.getElementById('collection_id').value;
	var other_id_type=document.getElementById('other_id_type').value;
	var oidnum=document.getElementById('oidnum').value;
	var part_name=document.getElementById('part_name').value;
	var part_name_2=document.getElementById('part_name_2').value;
	var parent_barcode=document.getElementById('parent_barcode').value;
	var new_container_type=document.getElementById('new_container_type').value;
	DWREngine._execute(_cfscriptLocation, null, 'addPartToContainer',collection_id,other_id_type,oidnum,part_name,part_name_2,parent_barcode,new_container_type,success_addPartToContainer);
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
	}
}
function clonePart() {
	var collection_id=document.getElementById('collection_id').value;
	var other_id_type=document.getElementById('other_id_type').value;
	var oidnum=document.getElementById('oidnum').value;
	if (collection_id.length>0 && other_id_type.length>0 && oidnum.length>0) {
		DWREngine._execute(_cfscriptLocation, null, 'getSpecimen',collection_id,other_id_type,oidnum,success_getSpecimen);
	} else {
		alert('Error: cannot resolve ID to specimen.');
	}
}
function success_getSpecimen(result){
	if (result[0].COLLECTION_OBJECT_ID.indexOf('Error:')>-1) {
		alert(result[0].COLLECTION_OBJECT_ID);	
	} else {
		newPart (result[0].COLLECTION_OBJECT_ID);
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
	        DWREngine._execute(_cfscriptLocation, null, 'getParts',collection_id,other_id_type,oidnum,noBarcode,noSubsample,success_getParts);
	}
 }

	function success_getParts(result) {
		var s=document.getElementById('ajaxStatus');
		document.body.removeChild(s);
		var sDiv=document.getElementById('thisSpecimen');
		var ocoln=document.getElementById('collection_id');
		var selIndex = ocoln.selectedIndex;
		var coln = ocoln.options[selIndex].text;		
		var idt=document.getElementById('other_id_type').value;
		var idn=document.getElementById('oidnum').value;
		var ss=coln + ' ' + idt + ' ' + idn;
		if (result[0].PART_NAME.indexOf('Error:')>-1) {
			alert(result[0].PART_NAME);
			ss+=' does not resolve to a specimen';
		} else {
			var p1=document.getElementById('part_name');
			var p2=document.getElementById('part_name_2');
			var op1=p1.value;
			var op2=p2.value;
			p1.options.length=0;
			p2.options.length=0;
			var option = document.createElement('option');
			option.setAttribute('value','');
			option.appendChild(document.createTextNode(''));
			p2.appendChild(option);	
			for (i=0;i<result.length;i++) {
				var option = document.createElement('option');
				option.setAttribute('value',result[i].PART_NAME);
				option.appendChild(document.createTextNode(result[i].PART_NAME));
				p1.appendChild(option);
			}
			for (i=0;i<result.length;i++) {
				var option = document.createElement('option');
				option.setAttribute('value',result[i].PART_NAME);
				option.appendChild(document.createTextNode(result[i].PART_NAME));
				p2.appendChild(option);
			}
			p1.value=op1;
			p2.value=op2;
				
			ss+=' = ' + result[0].COLLECTION + ' ' + result[0].CAT_NUM + ' (' + result[0].CUSTOMIDTYPE + ' ' + result[0].CUSTOMID + ')';
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
		DWREngine._execute(_cfscriptLocation, null, 'makePart',collection_object_id,part_name,part_modifier,lot_count,is_tissue,preserve_method,coll_obj_disposition,condition,coll_object_remarks,barcode,new_container_type,success_makePart);
	}
function success_makePart(result){
	var status=result[0].STATUS;
	if (status=='error') {
		var msg=result[0].MSG;
		alert(msg);
	} else {
		var msg="Created part: ";
		if (result[0].PART_MODIFIER.length > 0) {
			msg +=result[0].PART_MODIFIER + " ";
		}
		msg += result[0].PART_NAME + " ";
		if (result[0].PRESERVE_METHOD.length > 0) {
			msg += "(" + result[0].PRESERVE_METHOD + ") ";
		}
		if (result[0].IS_TISSUE== 1) {
			msg += "(tissue) ";
		}
		if (result[0].BARCODE.length>0) {
			msg += "barcode " + result[0].BARCODE;
			if (result[0].NEW_CONTAINER_TYPE.length>0) {
				msg += "( " + result[0].NEW_CONTAINER_TYPE + ")";
			}
		}
		logIt(msg);
		divpopClose();
		getParts();
	}
}
