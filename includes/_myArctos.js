function changedisplayRows (tgt) {
	$.getJSON("/component/functions.cfc",
		{
			method : "changedisplayRows",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		success_changeshowObservations
	);
}
function success_changedisplayRows (result) {
	if (result == 'success') {
		document.getElementById('displayRows').className='';
	} else {
		alert('An error occured: ' + result);
	}
}

function changekillRows () {
	if (document.getElementById('killRows').checked){
		var tgt=1;
	} else {
		var tgt=0;
	}
	$.getJSON("/component/functions.cfc",
		{
			method : "changekillRows",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		success_changeshowObservations
	);
}
function success_changekillRows(result){
	if (result != 'success') {
		alert('An error occured: ' + result);
	}
}
function changeresultSort (tgt) {
	$.getJSON("/component/functions.cfc",
		{
			method : "changeresultSort",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		success_changeshowObservations
	);
}
function success_changeresultSort (result) {
	if (result == 'success') {
		var e = document.getElementById('result_sort').className='';
	} else {
		alert('An error occured: ' + result);
	}
}