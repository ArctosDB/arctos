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
		DWREngine._execute(_cfscriptLocation, null, 'saveSpecSrchPref', id, onOff,nada);
	}
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