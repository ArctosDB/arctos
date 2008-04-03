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
		var theDiv = document.createElement('div');
		theDiv.id = 'customDiv';
		theDiv.className = 'customBox';
		theDiv.innerHTML='<br>Loading...';
		theDiv.src = "";
		document.body.appendChild(theDiv);
		var ptl="/includes/SpecSearch/customIDs.cfm";
			$.get(ptl, function(data){
			 $(theDiv).html(data);
			})
		$(theDiv).css({position:"absolute", top: e.pageY, left: 5%});
	});

	
});