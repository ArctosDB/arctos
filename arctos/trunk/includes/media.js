
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
	var relatedTableAry=relationship.split(" ");
	var relatedTable=relatedTableAry[relatedTableAry.length-1];
	// clean up old craps
	var theSpanName = id + 'Span';
	if (document.getElementById(theSpanName)){
		var theDivName = id + 'Div';
		var theDiv=document.getElementById(theDivName);
		var s=document.getElementById(theSpanName);
		theDiv.removeChild(s);
	}
	if (relatedTable=='') {
		// do nothing, cleanup already happened
	} else if (relatedTable=='agent'){
		addAgentRelation(id);
	} else if (relatedTable=='locality'){
		addLocalityRelation(id);
	} else {
		alert('Something is broken. I have no idea what to do with a relationship to ' + relatedTable);
	}
}
function addAgentRelation (id){
	var theDivName = id + 'Div';
	var theDiv=document.getElementById(theDivName);
	var theSpanName = id + 'Span';
	nSpan = document.createElement("span");
	var theHtml='<input type="hidden" name="agent_id_1"><input type="text" name="agent_name_1">';
	nSpan.innerHTML=theHtml;
	nSpan.id=theSpanName;
	theDiv.appendChild(nSpan);
	getAgent('agent_id_1','agent_name_1','newMedia','');
}
function addLocalityRelation (id){
	var theDivName = id + 'Div';
	var theDiv=document.getElementById(theDivName);
	var theSpanName = id + 'Span';
	nSpan = document.createElement("span");
	var theHtml='<input type="hidden" name="locality_id_1"><input type="text" name="spec_locality_1">';
	nSpan.innerHTML=theHtml;
	nSpan.id=theSpanName;
	theDiv.appendChild(nSpan);
	LocalityPick('locality_id_1','spec_locality_1','newMedia'); 
}