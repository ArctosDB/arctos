
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
	alert(id);
	var relationship=document.getElementById(id).value;
	var relatedTableAry=relationship.split(" ");
	var relatedTable=relatedTableAry[relatedTableAry.length-1];
	alert('Table: ' + relatedTable);
	if (relatedTable=='agent'){
		addAgentRelation(id);
	} else if (relatedTable=='locality'){
		addLocalityRelation(id);
	} else {
		alert('Something is broken. I have no idea what to do with a relationship to ' + relatedTable);
	}
}
function addAgentRelation (id){
	alert('addAgentRelation');
}
function addLocalityRelation (id){
	alert('addLocalityRelation');
}