jQuery( function($) {
	$(".helpLink").click(function(e){
		var id=this.id;
		removeHelpDiv();
		var theDiv = document.createElement('div');
		theDiv.id = 'helpDiv';
		theDiv.className = 'helpBox';
		theDiv.innerHTML='<br>Loading...';
		document.body.appendChild(theDiv);
		$("#helpDiv").css({position:"absolute", top: e.pageY, left: e.pageX});
		$(theDiv).load("/service/get_doc_rest.cfm",{fld: id, addCtl: 1});
		var $tgt = $(e.target);
	});
});