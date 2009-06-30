function changedisplayRows (tgt) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changedisplayRows",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		success_changedisplayRows
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
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changekillRows",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		success_changekillRows
	);
}
function success_changekillRows(result){
	if (result != 'success') {
		alert('An error occured: ' + result);
	}
}
function changeresultSort (tgt) {
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changeresultSort",
			tgt : tgt,
			returnformat : "json",
			queryformat : 'column'
		},
		success_changeresultSort
	);
}
function success_changeresultSort (result) {
	if (result == 'success') {
		var e = document.getElementById('result_sort').className='';
	} else {
		alert('An error occured: ' + result);
	}
}