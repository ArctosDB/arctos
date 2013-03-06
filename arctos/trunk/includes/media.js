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
window.onload = function() {
    var cookie = readCookie('mediaPref');
    if (cookie) {
        var pref = cookie.split(",");
        toggle_visibility(pref[0], pref[1]);
    }
} 
function removeUpload() {
	if(document.getElementById('uploadDiv')){
		jQuery('#uploadDiv').remove();
	}
	removeBgDiv();
}

/*
function closeUpload(media_uri,preview_uri) {
	document.getElementById('media_uri').value=media_uri;
	document.getElementById('preview_uri').value=preview_uri;
    var uext = media_uri.substr(1 + media_uri.lastIndexOf("/")).split('?')[0]).substr(media_uri.lastIndexOf("."))
	removeUpload();
}
*/
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
	nSel.value='';
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

function toggle_visibility(id1, id2) {
   var e = document.getElementById(id1);
   var k = document.getElementById(id2);

   e.style.display = 'block';
   k.style.display = 'none';
   
   createCookie('mediaPref', id1+','+id2, 7);
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

function eraseCookie(name) {
	createCookie(name,"",-1);
}