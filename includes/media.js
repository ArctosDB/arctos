
function closeUpload(media_uri) {
	var theDiv = document.getElementById('uploadDiv');
	document.body.removeChild(theDiv);
	document.getElementById('media_uri').value=media_uri;
}
function clickUpload(){
	var theDiv = document.createElement('iFrame');
	theDiv.id = 'uploadDiv';
	theDiv.name = 'uploadDiv';
	theDiv.className = 'uploadMediaDiv';
	document.body.appendChild(theDiv);
	var guts = "/info/upMedia.cfm";
	theDiv.src=guts;
}

function pickedRelationship (id){
	var relationship=document.getElementById(id).value;
	var ddPos = id.lastIndexOf('__');
	var elementNumber=id.substring(ddPos+2,id.length);
	var relatedTableAry=relationship.split(" ");
	var relatedTable=relatedTableAry[relatedTableAry.length-1];
	// clean up old craps
	var theSpanName = 'relationshipSpan__' + elementNumber;
	if (document.getElementById(theSpanName)){
		var theDivName = 'relationshipDiv__' + elementNumber;
		var theDiv=document.getElementById(theDivName);
		var s=document.getElementById(theSpanName);
		theDiv.removeChild(s);
	}
	if (relatedTable=='') {
		// do nothing, cleanup already happened
	} else if (relatedTable=='agent'){
		addAgentRelation(elementNumber);
	} else if (relatedTable=='locality'){
		addLocalityRelation(elementNumber);
	} else {
		alert('Something is broken. I have no idea what to do with a relationship to ' + relatedTable);
	}
}
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
	nDiv.appendChild(nSel);
	var mS = document.getElementById('addRelationship');
	pDiv.removeChild(mS);
	var np1=n+1;
	var oc="addRelation(" + np1 + ")";
	mS.setAttribute("onclick",oc);
	pDiv.appendChild(mS);
}
function addLabels (n) {
	var pDiv=document.getElementById('labels');
	var nDiv = document.createElement('div');
	nDiv.id='labelsDiv__' + n;
	pDiv.appendChild(nDiv);
	var n1=n-1;
	var selName='label__' + n1;
	var nSel = document.getElementById(selName).cloneNode(true);
	nSel.name="label__" + n;
	nSel.id="label__" + n;
	nDiv.appendChild(nSel);
	
	var inpName='label_value__' + n1;
	var nInp = document.getElementById(selName).cloneNode(true);
	nSel.name="label_value__" + n;
	nSel.id="label_value__" + n;
	nDiv.appendChild(nInp);
	
	var mS = document.getElementById('addLabel');
	pDiv.removeChild(mS);
	var np1=n+1;
	var oc="addLabel(" + np1 + ")";
	mS.setAttribute("onclick",oc);
	pDiv.appendChild(mS);
}