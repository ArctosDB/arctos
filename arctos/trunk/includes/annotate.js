function saveThisAnnotation() {
	var collection_object_id = document.getElementById("collection_object_id").value;
	var scientific_name = document.getElementById("scientific_name").value;
	var higher_geography = document.getElementById("higher_geography").value;
	var specific_locality = document.getElementById("specific_locality").value;
	var annotation_remarks = document.getElementById("annotation_remarks").value;

	//annotation_remarks=annotation_remarks.replace('"','""');
	//specific_locality=specific_locality.replace('"','&quot;');
	//higher_geography=higher_geography.replace('"','&quot;');
	annotation_remarks=escape(annotation_remarks);
		higher_geography=escape(higher_geography);
			specific_locality=escape(specific_locality);
	DWREngine._execute(_annotateFunction, null, 'addAnnotation', 
		collection_object_id,
		scientific_name,
		higher_geography,
		specific_locality,
		annotation_remarks,
		success_saveThisAnnotation);
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
	//alert(tid);
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
	//alert(tid);
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
	var theDiv = document.getElementById('annotateDiv');
	document.body.removeChild(theDiv);
}

	function openAnnotation(id) {
		var theDiv = document.createElement('div');
		theDiv.id = 'annotateDiv';
		theDiv.className = 'annotateBox';
		theDiv.innerHTML='<br>hi I am a div.';
		
		theDiv.src = "";
		
		document.body.appendChild(theDiv);
		
		var guts = "/info/annotateSpecimen.cfm?collection_object_id=" + id;
		ahah(guts,'annotateDiv');
	}


function ahah(url, target, delay) {
  var req;
  document.getElementById(target).innerHTML = 'waiting...';
  if (window.XMLHttpRequest) {
    req = new XMLHttpRequest();
  } else if (window.ActiveXObject) {
    req = new ActiveXObject("Microsoft.XMLHTTP");
  }
  if (req != undefined) {
    req.onreadystatechange = function() {ahahDone(req, url, target, delay);};
    req.open("GET", url, true);
    req.send("");
  }
}  

function ahahDone(req, url, target, delay) {
  if (req.readyState == 4) { // only if req is "loaded"
    if (req.status == 200) { // only if "OK"
      document.getElementById(target).innerHTML = req.responseText;
    } else {
      document.getElementById(target).innerHTML="ahah error:\n"+req.statusText;
    }
    if (delay != undefined) {
       setTimeout("ahah(url,target,delay)", delay); // resubmit after delay
	    //server should ALSO delay before responding
    }
  }
}
