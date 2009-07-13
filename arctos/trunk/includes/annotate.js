function saveThisAnnotation() {
	var collection_object_id = document.getElementById("collection_object_id").value;
	var scientific_name = document.getElementById("scientific_name").value;
	var higher_geography = document.getElementById("higher_geography").value;
	var specific_locality = document.getElementById("specific_locality").value;
	var annotation_remarks = document.getElementById("annotation_remarks").value;
	annotation_remarks=escape(annotation_remarks);
	higher_geography=escape(higher_geography);
	specific_locality=escape(specific_locality);	
	$.getJSON("/component/functions.cfc",
		{
			method : "addAnnotation",
			collection_object_id : collection_object_id,
			scientific_name : scientific_name,
			higher_geography : higher_geography,
			specific_locality : specific_locality,
			annotation_remarks : annotation_remarks,
			returnformat : "json",
			queryformat : 'column'
		},
		success_saveThisAnnotation
	);
}
function showPrevious(eid) {
	var tid = eid.substring(5,eid.length);
	pElems = 'p_' + tid;
	var tglon = 'hide_' + tid;
	var pElems = document.getElementById(pElems);
	var tglon = document.getElementById(tglon);
	var eid = document.getElementById(eid);
	pElems.className='doShow prevAnnList';
	tglon.className='doShow infoLink';
	eid.className='noShow';
}
function hidePrevious(eid) {
	var tid = eid.substring(5,eid.length);
	pElems = 'p_' + tid;
	var tglon = 'show_' + tid;
	var pElems = document.getElementById(pElems);
	var tglon = document.getElementById(tglon);
	var eid = document.getElementById(eid);
	pElems.className='noShow';
	tglon.className='doShow infoLink';
	eid.className='noShow';
}
function success_saveThisAnnotation (result) {
	if (result == 'success') {
		closeAnnotation();
		alert("Your annotations have been saved, and the appropriate curator will be alerted. \n Thank you for helping improve Arctos!");
	} else {
		alert('An error occured! \n ' + result);
	}
}
function closeAnnotation() {
	var theDiv = document.getElementById('bgDiv');
	document.body.removeChild(theDiv);
	var theDiv = document.getElementById('annotateDiv');
	document.body.removeChild(theDiv);
}
function openAnnotation(id) {
	var bgDiv = document.createElement('div');
	bgDiv.id = 'bgDiv';
	bgDiv.className = 'bgDiv';
	bgDiv.setAttribute('onclick','closeAnnotation()');
	document.body.appendChild(bgDiv);
	
	var theDiv = document.createElement('div');
	theDiv.id = 'annotateDiv';
	theDiv.className = 'annotateBox';
	theDiv.innerHTML='<br>Loading....';
	theDiv.src = "";
	document.body.appendChild(theDiv);
	var guts = "/info/annotateSpecimen.cfm?collection_object_id=" + id;
	jQuery('#annotateDiv').load(guts,{},function(){
		viewport.init("#annotateDiv");
		viewport.init("#bgDiv");
	});
}