//$.datepicker.setDefaults({ dateFormat: 'yy-mm-dd',changeMonth: true, changeYear: true, constrainInput: false });

$(document).ready(function() {
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
			// viewport.init("#customDiv");
		});
	});
	if (self != top && parent != null) {
		if (parent.frames[0].thisStyle) {
			changeStyle(parent.frames[0].thisStyle);
		}
	}
	$("input[type='date'], input[type='datetime']" ).datepicker();
});

/* agent editing forms */
function loadEditAgent(aid){
	$("#agntEditCell").html('<img src="/images/indicator.gif">');
	var ptl="/editAllAgent.cfm?agent_id=" + aid;
	$("#agntEditCell").load(ptl,{},function(){
		history.pushState('data', '', '/agents.cfm?agent_id=' + aid);
	});
}

function loadAgentSearch(q){
	var h;
	$("#agntRslCell").html('<img src="/images/indicator.gif">');
	$.ajax({
		url: "/component/agent.cfc?queryformat=column&method=findAgents&returnformat=json",
		type: "GET",
		dataType: "json",
		data:  q,
		success: function(r) {
			if (r.substring && r.substring(0,5)=='error'){
				$("#agntRslCell").html('<span class="importantNotification">' + r + '</span>');
				alert(r);
				return false;
			}
			if (r.ROWCOUNT===0){
				$("#agntRslCell").html('<span class="importantNotification">Nothing Matched.</span>');
				return false;
			}
			h='<div style="height:30em; overflow:auto;">';
			for (i=0;i<r.ROWCOUNT;i++) {
				h+='<div><span class="likeLink" onclick="loadEditAgent(' + r.DATA.AGENT_ID[i] + ');">';
				h+= r.DATA.PREFERRED_AGENT_NAME[i] + '</span><font size="-1"> (';
				h+=r.DATA.AGENT_TYPE[i] + ': ' + r.DATA.AGENT_ID[i] + ')';
				// no longer needed with history push
				h+=' <a target="_blank" href="/agents.cfm?agent_id=' +r.DATA.AGENT_ID[i]+'">[new window]</a></font></div>';
			}
			h+='</div>';
			$("#agntRslCell").html(h);
			//console.log(h);
			
		},
		error: function (xhr, textStatus, errorThrown){
		    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
		}
	});
}
function addGroupMember(){
	var i=parseInt($("#nnga").val()) + parseInt(1);

	var h='<div><input type="hidden" name="member_agent_id_new'+i+'" id="member_agent_id_new'+i+'">';
	h+='<input type="text" name="group_member_new'+i+'" id="group_member_new'+i+'"';
	h+=' onchange="pickAgentTest(\'member_agent_id_new'+i+'\',this.id,this.value); return false;"';
	h+=' onKeyPress="return noenter(event);" placeholder="new group member" class="minput"></div>';
	$('#newGroupMembers').append(h);
	$("#nnga").val(i);
}


function addAgentName(){
	var i=parseInt($("#nnan").val()) + parseInt(1);

	var h='<div id="agentnamedv'+i+'"><select name="agent_name_type_new'+i+'" id="agent_name_type_new'+i+'"></select>';
	h+='<input type="text" name="agent_name_new'+i+'" id="agent_name_new'+i+'" size="40" placeholder="new agent name" class="minput"></div>';
	$('#agentnamedv' + $("#nnan").val()).after(h);
	$('#agent_name_type_new1').find('option').clone().appendTo('#agent_name_type_new' + i);
	$("#nnan").val(i);
}
function addAgentStatus(){
	var i=parseInt($("#nnas").val()) + parseInt(1);
	var h='<div id="nas'+i+'" style="display: table-row;"><div style="display:table-cell">';
	h+='<select name="agent_status_new'+i+'" id="agent_status_new'+i+'" size="1"></select>';
	h+='</div><div style="display:table-cell"><input type="datetime" class="sinput" placeholder="status date" name="status_date_new'+i+'" id="status_date_new'+i+'"></div>';
	h+='<div style="display:table-cell"><textarea class="mediumtextarea" name="status_remark_new'+i+'" id="status_remark_new'+i+'" placeholder="status remark"></textarea></div></div>';
	$('#nas' + $("#nnas").val()).after(h);
	$('#agent_status_new1').find('option').clone().appendTo('#agent_status_new' + i);
	$('#status_date_new'+i ).datepicker();
	$("#nnas").val(i);
}




function addAgentRelationship(){
	var i=parseInt($("#nnar").val()) + parseInt(1);
	var h='<tr id="nar'+i+'" class="newRec"><td>';
	h+='<select name="agent_relationship_new'+i+'" id="agent_relationship_new'+i+'" size="1"></select> ';
	h+='</td><td><input type="hidden" name="related_agent_id_new'+i+'" id="related_agent_id_new'+i+'">';
	h+='<input type="text" name="related_agent_new'+i+'" id="related_agent_new'+i+'"';
		h+='onchange="pickAgentTest(\'related_agent_id_new'+i+'\',this.id,this.value); return false;"';
		h+='onKeyPress="return noenter(event);" placeholder="pick related agent" class="minput">';
	
	
	
	
	
	//h+='<input type="text" name="related_agent_new'+i+'" id="related_agent_new'+i+'" ';
	//h+='onchange="getAgent(\'related_agent_idnew'+i+'\',this.id,\'fEditAgent\',this.value); return false;"';
	//h+='onKeyPress="return noenter(event);" class="minput" placeholder="pick related agent">';
	h+='</td></tr>';
	$('#nar' + $("#nnar").val()).after(h);
	$('#agent_relationship_new1').find('option').clone().appendTo('#agent_relationship_new' + i);
	$("#nnar").val(i);

}
function addAddress(){
	var i=parseInt($("#nnea").val()) + parseInt(1);
	var h='<div id="eaddiv'+i+'" class="newRec">';
	h+='<select name="address_type_new'+i+'" id="address_type_new'+i+'" size="1"></select>';
	h+='<input type="text" class="minput" name="address_new'+i+'" id="address_new'+i+'" placeholder="add address">';
	

	h+='<select name="valid_addr_fg_new'+i+'" id="valid_addr_fg_new'+i+'"></select>';
	
	h+='<textarea class="smalltextarea" placeholder="remark" name="address_remark_new'+i+'" id="address_remark_new'+i+'"></textarea>';
	h+='</div>';
	$('#eaddiv' + $("#nnea").val()).after(h);
	$('#address_type_new1').find('option').clone().appendTo('#address_type_new' + i);
	$('#valid_addr_fg_new1').find('option').clone().appendTo('#valid_addr_fg_new' + i);
	$("#nnea").val(i);

}

/*
function addAgentAddr(aid){
	var guts = "includes/forms/editAgentAddr.cfm?action=newAddress&agent_id=" + aid;
	$("<div id='dialog' class='popupDialog'><img src='/images/indicator.gif'></div>").dialog({
		autoOpen: true,
		closeOnEscape: true,
		height: 'auto',
		modal: true,
		position: ['center', 'center'],
		title: 'Add Address',
		width: 'auto',
		close: function() {
			$( this ).remove();
		}
	}).load(guts, function() {
		$(this).dialog("option", "position", ['center', 'center'] );
	});
	$(window).resize(function() {
		$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
	});
	$(".ui-widget-overlay").click(function(){
	    $(".ui-dialog-titlebar-close").trigger('click');
	});
}			
	
*/
function rankAgent(agent_id) {
	var ptl="/includes/forms/agentrank.cfm?agent_id="+agent_id;			
	$("<div id='dialog' class='popupDialog'><img src='/images/indicator.gif'></div>").dialog({
		autoOpen: true,
		closeOnEscape: true,
		height: 'auto',
		modal: true,
		position: ['center', 'center'],
		title: 'Rank Agent',
		width: 'auto',
		close: function() {
			$( this ).remove();
		}
	}).load(ptl, function() {
		$(this).dialog("option", "position", ['center', 'center'] );
	});
	$(window).resize(function() {
		$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
	});
	$(".ui-widget-overlay").click(function(){
	    $(".ui-dialog-titlebar-close").trigger('click');
	});
}
function editAgentAddress (aid){
		var guts = "includes/forms/editAgentAddr.cfm?action=editAddress&addr_id=" + aid;
		$("<div id='dialog' class='popupDialog'><img src='/images/indicator.gif'></div>").dialog({
			autoOpen: true,
			closeOnEscape: true,
			height: 'auto',
			modal: true,
			position: ['center', 'center'],
			title: 'Edit Address',
			width: 'auto',
			close: function() {
				$( this ).remove();
			}
		}).load(guts, function() {
			$(this).dialog("option", "position", ['center', 'center'] );
		});
		$(window).resize(function() {
			$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
		});
		$(".ui-widget-overlay").click(function(){
		    $(".ui-dialog-titlebar-close").trigger('click');
		});
	}


/* END agent editing forms */


/* test for URL parameters in */
function getUrlParameter(sParam) {
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++) {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam) {
            return sParameterName[1];
        }
    }
}

function checkReplaceNoPrint(event,elem){
	// stops form submission if the passed-in element contains nonprinting characters
	
	if ($("#" + elem).val().length === 0) {
       return;
    };
	var msg;
	if ($("#" + elem).val().indexOf("[NOPRINT]") >= 0){
		alert('remove [NOPRINT] from ' + elem);
		event.preventDefault();
	}
	$.ajax({
		url: "/component/functions.cfc?queryformat=column",
		type: "GET",
		dataType: "json",
		async: false,
		data: {
			method:  "removeNonprinting",
			orig : $("#" + elem).val(),
			userString :'[NOPRINT]',
			returnformat : "json"
		},
		success: function(r) {
			if (r.DATA.REPLACED_WITH_USERSTRING[0] != $("#" + elem).val()){
				$("#" + elem).val(r.DATA.REPLACED_WITH_USERSTRING[0]);
				msg='The form cannot be submitted: There are nonprinting characters in ' + elem + '.\n\n';
				msg+='Nonprinting characters have been replaced with [NOPRINT]. Remove that to continue.\n\n';
				msg+='You may use HTML markup for print control: <br> is linebreak';
				alert(msg);
				event.preventDefault();
			}
		},
		error: function (xhr, textStatus, errorThrown){
		    alert(errorThrown + ': ' + textStatus + ': ' + xhr);
		}
	});
}

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


function jqueryspecialescape(v){
	// escapes special characters - used in jQuery.find
	var val = v.replace(/[ !"#$%&'()*+,.\/:;<=>?@^`{|}~]/g, "\\$&");
	return val;
}
function setPrevSearch(){
	var schParam=get_cookie ('schParams');
	var pAry=schParam.split("|");
 	for (var i=0; i<pAry.length; i++) {
 		var eAry=pAry[i].split("::");
 		var eName=eAry[0];
 		var eVl=eAry[1]; 		
 		if (document.getElementById(eName)){
 			
 			
				//console.log( 'eName=' + eName + '; eVl=' + eVl);

 			// extra handling required for multiselect
 			if (eName=='collection_id'){
 				var selectedOptions = eVl.split(",");
 				for (x = 0; x < selectedOptions.length; x++) {
 	 			    var optionVal = selectedOptions[x];
 	 			    $("#collection_id").find("option[value="+optionVal+"]").prop("selected", "selected");
 	 			}
 	 			$("#collection_id").multiselect('refresh');
 			} else if (eName=='OIDType'){
 				var selectedOptions = eVl.split(",");
 				for (x = 0; x < selectedOptions.length; x++) {
 	 			    var optionVal = jqueryspecialescape(selectedOptions[x]);
 	 			    $("#OIDType").find("option[value="+optionVal+"]").prop("selected", "selected");
 	 			}
 	 			$("#OIDType").multiselect('refresh');
 			} else if (eName=='groupBy'){
 				var selectedOptions = eVl.split(",");
 				for (x = 0; x < selectedOptions.length; x++) {
 	 			    var optionVal = jqueryspecialescape(selectedOptions[x]);
 	 			    $("#groupBy").find("option[value="+optionVal+"]").prop("selected", "selected");
 	 			}
 	 			$("#groupBy").multiselect('refresh');
 	 			
 			} else if (eName=='tgtForm') {
 				changeTarget(eName,eVl);
 				
 			//	console.log('going changeTarget: eName=' + eName + '; eVl=' + eVl);
 			} else {
 				$("#" + eName).val(eVl);
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
	$("#tgtForm").val(tvalue);
	if (tvalue == 'SpecimenResultsSummary.cfm') {
		$("#groupByDiv").show();
		//$("#groupByDiv1").show();
		$("#kmlDiv").hide();
		//$("#kmlDiv1").hide();
	} else if (tvalue=='/bnhmMaps/kml.cfm?action=newReq') {
		$("#groupByDiv").hide();
		//$("#groupByDiv1").hide();
		$("#kmlDiv").show();
		//$("#kmlDiv1").show();
	} else {
		$("#groupByDiv").hide();
		//$("#groupByDiv1").hide();
		$("#kmlDiv").hide();
		//$("#kmlDiv1").hide();
		
	}	
	$("#SpecData").attr("action", tvalue);
}

/*
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
*/
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

/*
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
*/
/* specimen search */




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
				alert('The CAPTCHA text you entered does not match the image.');
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
		// viewport.init("#annotateDiv");
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

function saveSearch(returnURL,errm){
	var uniqid,sName,sn,ru,p;
	uniqid = Date.now();
	if ( typeof errm !== 'undefined' && errm.length > 0 ) {
		p="ERROR: " + errm + "\n\n";
	}
	p="Saving search for URL:\n\n" + returnURL + " \n\nName your saved search (or copy and ";
	p+="paste the link above).\n\nManage or email saved searches from your profile, or go to /saved/{name of saved search}. Note ";
	p+="that saved searches, except those sepecifying only GUIDs, are dynamic; results change as data changes.\n\nName of saved search (must be unique):\n";
	sName=prompt(p, uniqid);
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
					if (r=='You must create an account or log in to save searches.'){
						
						return false;	
					} else {
						saveSearch(returnURL,r);
					}
				} else {
					
					pathArray = window.location.href.split( '/' );
					protocol = pathArray[0];
					host = pathArray[2];
					url = protocol + '//' + host;
					
					
					alert('Saved search \n' + url + '/saved/' + sn + '\n Find it in the My Stuff tab.');
				}
			}
		);
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

function hidePageLoad() {
	$('#loading').hide();
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
	// used by clonePart, which is used by part2container.cfm
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
	// used by newPart
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
	// used by divpop
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
	//used by divpop
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

function scrollToAnchor(aid){
	// handy shortcut
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
function saveSpecSrchPref(id,onOff){
	// this function should be (but isn't) used for all search preferences from clicks and functions and whatever
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
	// specimensearch pane toggle
	var offText,onText,ptl;
	if ( $("#c_" + id).length && $("#e_" + id).length){
		if (id=='spatial_query'){
			onText='<span class="secControl" style="font-size:.9em;" id="c_' + id + '" onclick="showHide(\'' + id + '\',0)">Hide Google Map</span>';
			offText='<span class="secControl" style="font-size:.9em;" id="c_' + id + '" onclick="showHide(\'' + id + '\',1)">Select on Google Map</span>';
		} else {
			onText='<span class="secControl" id="c_' + id + '" onclick="showHide(\'' + id + '\',0)">Show Fewer Options</span>';
			offText='<span class="secControl" id="c_' + id + '" onclick="showHide(\'' + id + '\',1)">Show More Options</span>';
		}
		if (onOff==1) {
			ptl="/includes/SpecSearch/" + id + ".cfm";
			$("#c_" + id).html('<img src="/images/indicator.gif">');
			$.get(ptl, function(data){
				$("#e_" + id).html(data);				
				$( "#c_" + id ).replaceWith( onText );
				saveSpecSrchPref(id,onOff);
			});
		} else {
			$( "#e_" + id ).html('');
			$( "#c_" + id ).replaceWith( offText );
			saveSpecSrchPref(id,onOff);
		}		
	}
}
function closeAndRefresh(){
	// used for customizing identifier search prefs - probably could be redone with modal
	var theDiv;
	document.location=location.href;
	theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
}
function getFormValues() {
	spAry = [];
	$('#SpecData *').filter(':input').each(function(){
		if(!!$(this).val()){
			var thisPair=(this.name + '::' + String($(this).val()));
			if (spAry.indexOf(thisPair)==-1) {
				spAry.push(thisPair);
				
			//	console.log('saving ' + thisPair);
			}
		}
	});
	str=spAry.join("|");
	document.cookie = 'schParams=' + str;
	

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
		while (c.charAt(0)==' ') {
			c = c.substring(1,c.length);
		}
		if (c.indexOf(nameEQ) === 0) {
			return c.substring(nameEQ.length,c.length);
		}
	}
	return null;
}
function get_cookie ( cookie_name ) {
	var results = document.cookie.match ( '(^|;) ?' + cookie_name + '=([^;]*)(;|$)' );
	if ( results ) {
		return ( unescape ( results[2] ) );
	} else {
		return null;
	}
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
	var u,w;
	u = "/info/ctDocumentation.cfm?table=" + table + "&field=" + field;
	w=windowOpener(u,"ctDocWin","width=700,height=400, resizable,scrollbars");
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
function chgCondition(collection_object_id) {
	helpWin=windowOpener("/picks/condition.cfm?collection_object_id="+collection_object_id,"conditionWin","width=800,height=338, resizable,scrollbars");
}
function getLoan(LoanIDFld,LoanNumberFld,loanNumber,collectionID){
	var url,oawin;
	url="/picks/getLoan.cfm";
	oawin=url+"?LoanIDFld="+LoanIDFld+"&LoanNumberFld="+LoanNumberFld+"&loanNumber="+loanNumber+"&agent_name="+collectionID;
	loanpickwin=window.open(oawin,"","width=400,height=338, resizable,scrollbars");
}

function pickAgentTest(agentIdFld,agentNameFld,name){
	// semi-experimental jquery modal agent pick
	// initiated 20140916
	// if no complaints, replace all picks with this approach
	name=encodeURIComponent(name);
	$("#" + agentNameFld).addClass('badPick');
	var an;
	if ( typeof name != 'undefined') {
		an=name;	
	}else {
		an='';
	}
	var guts = "/picks/findAgentModal.cfm?agentIdFld=" + agentIdFld + '&agentNameFld=' + agentNameFld + '&name=' + an;
	$("<iframe src='" + guts + "' id='dialog' class='popupDialog' style='width:600px;height:600px;'></iframe>").dialog({
		autoOpen: true,
		closeOnEscape: true,
		height: 'auto',
		modal: true,
		position: ['center', 'center'],
		title: 'Pick Agent',
			width:800,
 			height:600,
		close: function() {
			$( this ).remove();
		}
	}).width(800-10).height(600-10);
	$(window).resize(function() {
		$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
	});
	$(".ui-widget-overlay").click(function(){
	    $(".ui-dialog-titlebar-close").trigger('click');
	});
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


  

/*************************************** BEGIN code formerly of internalAjax *************************************************/



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
				dv='<textarea name="' + valElem + '" id="' + valElem + '" class="smalltextarea"></textarea>';

				//<input type="text" name="' + valElem + '" id="' + valElem + '">';
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
	// viewport.init("#partsAttDiv");
}

function closePartAtts() {
	$('#bgDiv').remove();
	$('#partsAttDiv').remove();
	$('#bgDiv', window.parent.document).remove();
	$('#partsAttDiv', window.parent.document).remove();
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
	//// viewport.init("#uploadDiv");
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
	var cc;
	$.getJSON("/component/functions.cfc",
		{
			method : "genMD5",
			uri : $("#media_uri").val(),
			returnformat : "json",
			queryformat : 'column'
		},
		function (r){
			cc=parseInt($("#number_of_labels").val()) + parseInt(1);
			addLabel(cc);
			$("#label__" + cc).val('MD5 checksum');
			$("#label_value__" + cc).val(r);
		}
	);
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
/****
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
*/
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
				//console.log(d);
				
				//agntRankTbl
				var h ='<tr id="tablr' + d + '"><td>' + $("#agent_rank").val() + '</td>';
				h+='<td>' + $("#transaction_type").val() + '</td>';
				h+='<td>- just now - </td>';
				h+='<td>- you - <span class="infoLink" onclick="revokeAgentRank(\'' + d + '\');">revoke</span></td>';
				h+='<td>' + $("#remark").val() + '</td></tr>';
				$("#agntRankTbl").append(h);
				
			
			
			
				/*
				
				
					
				<tr id="tablr#agent_rank_id#">
				<td>#agent_rank#</td>
				<td>#transaction_type#</td>
				<td nowrap="nowrap">#dateformat(rank_date,"yyyy-mm-dd")#</td>
				<td nowrap="nowrap">
					#replace(ranker," ", "&nbsp;","all")#
					<cfif ranked_by_agent_id is session.myAgentId>
						<span class="infoLink" onclick="revokeAgentRank('#agent_rank_id#');">revoke</span>
					</cfif>
				</td>
				<td>#remark#</td>
			</tr>					 
			
			
			
				<td>#agent_rank#
				<td>#transaction_type#</td>
				<td nowrap="nowrap">#dateformat(rank_date,"yyyy-mm-dd")#</td>
				<td nowrap="nowrap">
					#replace(ranker," ", "&nbsp;","all")#
					<cfif ranked_by_agent_id is session.myAgentId>
						<span class="infoLink" onclick="revokeAgentRank('#agent_rank_id#');">revoke</span>
					</cfif>
				</td>
				<td>#remark#</td>
			</tr>				
			
				var ih = 'Thank you for adding an agent rank.';
				ih+='<p><span class="likeLink" onclick="removePick();rankAgent(' + d + ')">Refresh</span></p>';
				ih+='<p><span class="likeLink" onclick="removePick();">Done</span></p>';				
				document.getElementById('pickDiv').innerHTML=ih;
				
				*/	 
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
	//	viewport.init("#pickDiv");
	//document.body.appendChild(theDiv);
	//$('#annotateDiv').append('<iframe id="commentiframe" width="100%" height="100%">');
	//$('#commentiframe').attr('src', guts);
}

/*
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
		// viewport.init("#pickDiv");
	});
}

*/
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
function deleteAgent(r){
	// publications
	$('#author_name' + r).addClass('red').val("deleted");
	$('#authortr' + r + ' td:nth-child(1)').addClass('red');
	$('#authortr' + r + ' td:nth-child(3)').addClass('red');						
}


/*************************************** END code formerly of internalAjax *************************************************/


/*************************************** BEGIN header menu thingeemajobber *************************************************/


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



/*************************************** END header menu thingeemajobber *************************************************/

/*************************************** BEGIN probably delete-worthy, but keep for now *************************************************/


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
/*************************************** END probably delete-worthy, but keep for now *************************************************/
