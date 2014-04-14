jQuery(document).ready(function() {
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
	jQuery("#partname").autocomplete("/ajax/part_name.cfm", {
		width: 320,
		max: 20,
		autofill: true,
		highlight: false,
		multiple: true,
		multipleSeparator: "|",
		scroll: true,
		scrollHeight: 300
	});	
	jQuery("#c_collection_cust").click(function(e){
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeCustom()');
		document.body.appendChild(bgDiv);
		
		var cDiv = document.createElement('div');
		cDiv.id = 'customDiv';
		cDiv.className = 'sscustomBox';
		cDiv.innerHTML='<br>Loading...';
		document.body.appendChild(cDiv);
		var ptl="/includes/SpecSearch/changeCollection.cfm";
		jQuery(cDiv).load(ptl);
		jQuery(cDiv).css({position:"absolute", top: e.pageY-50, left: "5%"});
	});
	
	jQuery("#c_identifiers_cust").click(function(e){
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeCustom()');
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
	function customizeIdentifiers() {
		var theDiv = document.createElement('div');
			theDiv.id = 'customDiv';
			theDiv.className = 'customBox';
			theDiv.innerHTML='<br>Loading...';
			theDiv.src = "";
			document.body.appendChild(theDiv);
			var ptl="/includes/SpecSearch/customIDs.cfm";
				jQuery.get(ptl, function(data){
				 jQuery(theDiv).html(data);
				})
			jQuery(theDiv).css({position:"absolute", top: data.pageY, left: data.pageX});
	}
});
function removeHelpDiv() {
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
		success_changeshowObservations
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
			})
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
function closeCustom(){
	document.location=location.href;
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
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
function nada(){
 //console.log('nada');
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
		if (cCookie != null)
		{
			cookieArray = cCookie.split(","); // turn cookie string to array
			for (i = 0; i<cookieArray.length; i++) { // see if id already exists
				if (cookieArray[i] == id) {
					idFound = i;
				}
			}
		}
		if (onOff==1) { //showHide On			
			if (idFound == -1) { // no current id in cookie
				cookieArray.push(id);
			}
			// else nothing needs to be done
		}
		else { //showHide Off
			if (idFound != -1) // id exists in cookie
				cookieArray.splice(idFound,1);
			// else nothing needs to be done
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


function success_changeshowObservations (result) {
	if (result != 'success') {
		alert('An error occured: ' + result);
	}
}
function changeexclusive_collection_id (tgt) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changeexclusive_collection_id",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		success_changeexclusive_collection_id
	);
}
function success_changeexclusive_collection_id (result) {
	if (result == 'success') {
		var e = document.getElementById('exclusive_collection_id').className='';
	} else {
		alert('An error occured: ' + result);
	}
}