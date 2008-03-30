function setSrchVal (id, val) {
	//alert(id);
	//alert(val);
	if (val == true) {
		val = 1;
	}else{
		val = 0;
	}
	//alert(val);
	DWREngine._execute(_cfscriptLocation, null, 'setSrchVal',id,val, success_setSrchVal);
}
function success_setSrchVal (result) {
	//alert(result);
	if (result == 'success') {
		//var e = document.getElementById('customOtherIdentifier').className='';
	} else {
		alert('An error occured: ' + result);
	}
}
function changedetail_level (tgt) {
	DWREngine._execute(_cfscriptLocation, null, 'changedetail_level',tgt, success_changedetail_level);
}
function success_changedetail_level (result) {
	if (result == 'success') {
		//var e = document.getElementById('customOtherIdentifier').className='';
	} else {
		alert('An error occured: ' + result);
	}
}
function changecustomOtherIdentifier (tgt) {
	DWREngine._execute(_cfscriptLocation, null, 'changecustomOtherIdentifier',tgt, success_changecustomOtherIdentifier);
}
function success_changecustomOtherIdentifier (result) {
	if (result == 'success') {
		var e = document.getElementById('customOtherIdentifier').className='';
	} else {
		alert('An error occured: ' + result);
	}
}

function changeshowObservations (tgt) {
	DWREngine._execute(_cfscriptLocation, null, 'changeshowObservations',tgt, success_changeshowObservations);
}
function success_changeshowObservations (result) {
	if (result == 'success') {
		//var e = document.getElementById('exclusive_collection_id').className='';
	} else {
		alert('An error occured: ' + result);
	}
}
function changeexclusive_collection_id (tgt) {
	DWREngine._execute(_cfscriptLocation, null, 'changeexclusive_collection_id',tgt, success_changeexclusive_collection_id);
}
function success_changeexclusive_collection_id (result) {
	if (result == 'success') {
		var e = document.getElementById('exclusive_collection_id').className='';
	} else {
		alert('An error occured: ' + result);
	}
}
function changeTarget (tgt) {
	DWREngine._execute(_cfscriptLocation, null, 'changeTarget',tgt, success_changeTarget);
}
function success_changeTarget (result) {
	if (result == 'success') {
		var e = document.getElementById('target').className='';
	} else {
		alert('An error occured: ' + result);
	}
}
function changedisplayRows (tgt) {
	DWREngine._execute(_cfscriptLocation, null, 'changedisplayRows',tgt, success_changedisplayRows);
}
function success_changedisplayRows (result) {
	if (result == 'success') {
		var e = document.getElementById('displayRows').className='';
	} else {
		alert('An error occured: ' + result);
	}
}