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
	jQuery.getJSON("/component/functions.cfc",
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
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "getPartAttOptions",
			returnformat : "json",
			patype      : patype
		},
		function (data) {
			var cType=data.TYPE;
			var valElem='attribute_value_' + id;
			var unitElem='attribute_units_' + id;
			if (data.TYPE=='unit') {
				var d='<input type="text" name="' + valElem + '" id="' + valElem + '">';
				$('#v_' + id).html(d);
				var theVals=data.VALUES.split('|');
				var d='<select name="' + unitElem + '" id="' + unitElem + '">';
	  			for (a=0; a<theVals.length; ++a) {
					d+='<option value="' + theVals[a] + '">'+ theVals[a] +'</option>';
				}
	  			d+="</select>";
	  			$('#u_' + id).html(d);
			} else if (data.TYPE=='value') {
				var theVals=data.VALUES.split('|');
				var d='<select name="' + valElem + '" id="' + valElem + '">';
	  			for (a=0; a<theVals.length; ++a) {
					d+='<option value="' + theVals[a] + '">'+ theVals[a] +'</option>';
				}
	  			d+="</select>";
	  			$('#v_' + id).html(d);
				$('#u_' + id).html('');
			} else {
				var dv='<input type="text" name="' + valElem + '" id="' + valElem + '">';
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
	var id=jQuery('#agent_id_' + i).val();
	var name=jQuery('#trans_agent_' + i).val();
	var role=jQuery('#cloneTransAgent_' + i).val();
	jQuery('#cloneTransAgent_' + i).val('');
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
	jQuery.getJSON("/component/functions.cfc",
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
  			jQuery('#loanAgents tr:last').after(d);
		}
	);
}
jQuery("#uploadMedia").live('click', function(e){
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
		jQuery('#uploadDiv').remove();
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
	jQuery.getJSON("/component/functions.cfc",
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
	if (relatedTable=='') {
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
	var pDiv=document.getElementById('relationships');
	var nDiv = document.createElement('div');
	nDiv.id='relationshipDiv__' + n;
	pDiv.appendChild(nDiv);
	var n1=n-1;
	var selName='relationship__' + n1;
	var nSel = document.getElementById(selName).cloneNode(true);
	nSel.name="relationship__" + n;
	nSel.id="relationship__" + n;
	nSel.value='delete';
	nDiv.appendChild(nSel);	
	c = document.createElement("textNode");
	c.innerHTML=":&nbsp;";
	nDiv.appendChild(c);
	
	var n1=n-1;
	var inpName='related_value__' + n1;
	var nInp = document.getElementById(inpName).cloneNode(true);
	nInp.name="related_value__" + n;
	nInp.id="related_value__" + n;
	nInp.value='';
	nDiv.appendChild(nInp);
	
	var hName='related_id__' + n1;
	var nHid = document.getElementById(hName).cloneNode(true);
	nHid.name="related_id__" + n;
	nHid.id="related_id__" + n;
	nDiv.appendChild(nHid);
	
	var mS = document.getElementById('addRelationship');
	pDiv.removeChild(mS);
	var np1=n+1;
	var oc="addRelation(" + np1 + ")";
	mS.setAttribute("onclick",oc);
	pDiv.appendChild(mS);
	
	var cc=document.getElementById('number_of_relations');
	cc.value=parseInt(cc.value)+1;
}

function addLabel (n) {
	var pDiv=document.getElementById('labels');
	var nDiv = document.createElement('div');
	nDiv.id='labelsDiv__' + n;
	pDiv.appendChild(nDiv);
	var n1=n-1;
	var selName='label__' + n1;
	var nSel = document.getElementById(selName).cloneNode(true);
	nSel.name="label__" + n;
	nSel.id="label__" + n;
	nSel.value='';
	nDiv.appendChild(nSel);
	
	c = document.createElement("textNode");
	c.innerHTML=":&nbsp;";
	nDiv.appendChild(c);
	
	var inpName='label_value__' + n1;
	var nInp = document.getElementById(inpName).cloneNode(true);
	nInp.name="label_value__" + n;
	nInp.id="label_value__" + n;
	nInp.value='';
	nDiv.appendChild(nInp);

	var mS = document.getElementById('addLabel');
	pDiv.removeChild(mS);
	var np1=n+1;
	var oc="addLabel(" + np1 + ")";
	mS.setAttribute("onclick",oc);
	pDiv.appendChild(mS);
	
	var cc=document.getElementById('number_of_labels');
	cc.value=parseInt(cc.value)+1;
}
function tog_AgentRankDetail(o){
	if(o==1){
		document.getElementById('agentRankDetails').style.display='block';
		jQuery('#t_agentRankDetails').text('Hide Details').removeAttr('onclick').bind("click", function() {
			tog_AgentRankDetail(0);
		});
	} else {
		document.getElementById('agentRankDetails').style.display='none';
		jQuery('#t_agentRankDetails').text('Show Details').removeAttr('onclick').bind("click", function() {
			tog_AgentRankDetail(1);
		}); 
	}
}
function saveAgentRank(){		
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "saveAgentRank",
			agent_id : jQuery('#agent_id').val(),
			agent_rank : jQuery('#agent_rank').val(),
			remark : jQuery('#remark').val(),
			transaction_type : jQuery('#transaction_type').val(),
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
	jQuery.getJSON("/component/functions.cfc",
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
	$('#pickFrame').remove()
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
	jQuery.get(ptl,{agent_id: agent_id},function(data){
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
		jQuery('#pickDiv').remove();
	}
	removeBgDiv();
}
function addBGDiv(f){
	var bgDiv = document.createElement('div');
	bgDiv.id = 'bgDiv';
	bgDiv.className = 'bgDiv';
	if(f==null || f.length==0){
		f="removeBgDiv()";
	}
	bgDiv.setAttribute('onclick',f);
	document.body.appendChild(bgDiv);
}
function removeBgDiv () {
	if(document.getElementById('bgDiv')){
		jQuery('#bgDiv').remove();
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
	jQuery.get(ptl,{agentname: name, fld: fld, idfld: idfld},function(data){
		document.getElementById('pickDiv').innerHTML=data;
		viewport.init("#pickDiv");
	});
}
function addLink (n) {
	var lid = jQuery('#linkTab tr:last').attr("id");
	var lastID=lid.replace('linkRow','');
	if (lastID.length==0){
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
	jQuery('#linkTab tr:last').after(newRow);
	document.getElementById('numberLinks').value=thisID;
}

function addAgent (n) {
	var lid = jQuery('#authTab tr:last').attr("id");
	var lastID=lid.replace('authortr','');
	if(lastID==''){
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
	jQuery('#authTab tr:last').after(newRow);
	document.getElementById('numberAuthors').value=thisID;
}
function removeAgent() {
	var lid = jQuery('#authTab tr:last').attr("id");
	var lastID=lid.replace('authortr','');
	var thisID=parseInt(lastID) - 1;
	document.getElementById('numberAuthors').value=thisID;
	if(thisID>=1){
		jQuery('#authTab tr:last').remove();
	} else {
		alert('You must have at least one author');
	}
}
function removeLastAttribute() {
	var lid = jQuery('#attTab tr:last').attr("id");
	if (lid.length==0) {
		alert('nothing to remove');
		return false;
	}
	var lastID=lid.replace('attRow','');
	var thisID=parseInt(lastID) - 1;
	document.getElementById('numberAttributes').value=thisID;
	jQuery('#attTab tr:last').remove();
}
function addAttribute(v){
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "getPubAttributes",
			attribute : v,
			returnformat : "json",
			queryformat : 'column'
		},
		function (d) {
			var lid=jQuery('#attTab tr:last').attr("id");
			if(lid.length==0){
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
			jQuery('#attTab tr:last').after(newRow);
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
	jQuery('#author_name' + r).addClass('red').val("deleted");
	jQuery('#authortr' + r + ' td:nth-child(1)').addClass('red');
	jQuery('#authortr' + r + ' td:nth-child(3)').addClass('red');						
}
function deletePubAtt(r){
	var newElem='<input type="hidden" name="attribute' + r + '" id="attribute' + r + '" value="deleted">';
	jQuery('#attRow' + r + ' td:nth-child(1)').addClass('red').text(jQuery('#attribute_type' + r).val());
	jQuery('#attRow' + r + ' td:nth-child(2)').addClass('red').text(jQuery('#attribute' + r).val()).append(newElem);
	jQuery('#attRow' + r + ' td:nth-child(3)').addClass('red').text('deleted');
}
function deleteLink(r){
	var newElem='<input type="hidden" name="link' + r + '" id="link' + r + '" value="deleted">';
	jQuery('#linkRow' + r + ' td:nth-child(1)').addClass('red').text('deleted').append(newElem);
	jQuery('#linkRow' + r + ' td:nth-child(2)').addClass('red').text('');
}