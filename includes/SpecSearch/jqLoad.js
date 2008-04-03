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
	
	$("#c_identifiers_cust").click(function(e){
		var cDiv = document.createElement('div');
		cDiv.id = 'customDiv';
		cDiv.className = 'sscustomBox';
		cDiv.innerHTML='<br>Loading...';
		document.body.appendChild(cDiv);
		var ptl="/includes/SpecSearch/customIDs.cfm";
		$(cDiv).load(ptl);
		$(cDiv).css({position:"absolute", top: e.pageY-50, left: "5%"});
	});

	
});