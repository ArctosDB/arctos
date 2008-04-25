jQuery( function($) {
	$("#tpart_name").suggest("/ajax/suggestCT.cfm",{minchars:1,ctName:"ctspecimen_part_name",ctField:"part_name"});
	$(".helpLink").click(function(e){
		var id=this.id;
		removeHelpDiv();
		var theDiv = document.createElement('div');
		theDiv.id = 'helpDiv';
		theDiv.className = 'helpBox';
		theDiv.innerHTML='<br>Loading...';
		document.body.appendChild(theDiv);
		$("#helpDiv").css({position:"absolute", top: e.pageY, left: e.pageX});
		$(theDiv).load("/service/get_doc_rest.cfm",{fld: id, addCtl: 1});
	});
	
	$("#c_identifiers_cust").click(function(e){
		var cDiv = document.createElement('div');
		cDiv.id = 'customDiv';
		cDiv.className = 'sscustomBox';
		cDiv.innerHTML='<br>Loading...';
		document.body.appendChild(cDiv);
		var ptl="/includes/SpecSearch/customIDs.cfm";
		$(cDiv).load(ptl);
		$(cDiv).css({position:"absolute", top: e.pageY-50, left: "5%"});
	});
});

function removeHelpDiv() {
	if (document.getElementById('helpDiv')) {
		$('#helpDiv').remove();
	}
}

function changeTarget(id,tvalue) {
	//alert('id:' + id);
	//alert('tvalue: ' + tvalue);
	//alert('len: ' +tvalue.length);
	if(tvalue.length == 0) {
		tvalue='SpecimenResults.cfm';
		//alert('tvalue manually set:' + tvalue);
	}
	if (id =='tgtForm1') {
		var otherForm = document.getElementById('tgtForm');
	} else {
		var otherForm = document.getElementById('tgtForm1');
	}
	otherForm.value =  tvalue;
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
	// uncheck everything in the other box
	for (i = 0; i < len; i++) {
		sList.options[i].selected = false;
	}
	// make em match
	for (i = 0; i < len; i++) {
		if (mList.options[i].selected) {
			sList.options[i].selected = true;
		}
	}
}
function nada(){var a=1;}

function showHide(id,onOff) {
	var t='e_' + id;
	var z='c_' + id;	
	if (document.getElementById(t) && document.getElementById(z)) {	
		var tab=document.getElementById(t);
		var ctl=document.getElementById(z);
		if (onOff==1) {
			var ptl="/includes/SpecSearch/" + id + ".cfm";
			$.get(ptl, function(data){
			 $(tab).html(data);
			})
			ctl.setAttribute("onclick","showHide('" + id + "',0)");
			ctl.innerHTML='Show Fewer Options';
			// flipping retarded, but try this here
			
	
		} else {
			tab.innerHTML='';
			ctl.setAttribute("onclick","showHide('" + id + "',1)");
			ctl.innerHTML='Show More Options';
		} 
		// see if we can save it to their preferences
		DWREngine._execute(_cfscriptLocation, null, 'saveSpecSrchPref', id, onOff, saveComplete);
	}
}

function saveComplete(savedStr){
	var savedArray = savedStr.split(",");
	var result = savedArray[0];
	var id = savedArray[1];
	var onOff = savedArray[2];
	
	if (result == "cookie") { //need to add id to cookie
		var cCookie = readCookie("specsrchprefs");
		var idFound = -1;
		if (cCookie != null) // cookie for specsrchprefs exists already
		{
			var cookieArray = cCookie.split(","); // turn cookie string to array
			for (i = 0; i<cookieArray.length; i++) { // see if id already exists
				if (cookieArray[i] == id) {
					idFound = i;
				}
			}
		}
		else
			var cookieArray = new Array();
			
		if (onOff) { //showHide On			
			if (idFound == -1) { // no current id in cookie
				cookieArray = cookieArray.push(id);
			}
			// else nothing needs to be done
		}
		else { //showHide Off
			if (idFound != -1) // id exists in cookie
				cookieArray = cookieArray.splice(idFound,1);
			// else nothing needs to be done
		}
	
		var nCookie = cookieArray.join(",");	
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


function multi (id){
	alert('mult');
	var id=document.getElementById(id);
	id.setAttribute("multiple","true");
	id.setAttribute("size","5");
}
function singl (id){
	alert('sing');
	var id=document.getElementById(id);
	id.removeAttribute("multiple");
	id.setAttribute("size","1");
}
function customizeIdentifiers() {
	var theDiv = document.createElement('div');
		theDiv.id = 'customDiv';
		theDiv.className = 'customBox';
		theDiv.innerHTML='<br>Loading...';
		theDiv.src = "";
		document.body.appendChild(theDiv);
		var ptl="/includes/SpecSearch/customIDs.cfm";
			$.get(ptl, function(data){
			 $(theDiv).html(data);
			})
		$(theDiv).css({position:"absolute", top: data.pageY, left: data.pageX});
}