$("#customizeButton").live('click', function(e){
		var bgDiv = document.createElement('div');
			bgDiv.id = 'bgDiv';
			bgDiv.className = 'bgDiv';
			bgDiv.setAttribute('onclick','closeCustomNoRefresh()');
			document.body.appendChild(bgDiv);
			var type=this.type;
			var type=$(this).attr('type');
			var dval=$(this).attr('dval');
			var theDiv = document.createElement('div');
			theDiv.id = 'customDiv';
			theDiv.className = 'customBox';
			document.body.appendChild(theDiv);
			var guts = "/info/SpecimenResultsPrefs_exp.cfm";
			$('#customDiv').load(guts,{},function(){
				viewport.init("#customDiv");
			});
		});