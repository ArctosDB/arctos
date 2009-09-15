
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
	
}

