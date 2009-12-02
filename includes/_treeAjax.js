function post(onOff,msg) {
	document.body.style.cursor = "";
	var m = document.getElementById('ajaxMsg');
	if (onOff==1) {
		if (typeof msg == 'undefined') {
			var msg="Working...";
			document.body.style.cursor = "wait";
		} else {
			// got a message passed in, make it ugly...
			var sev="ajaxError";
			if (msg.length > 50) {
				var fullMsg=msg;
				fullMsg=fullMsg.replace(/'/g,"`");
				fullMsg =fullMsg.replace(/[\r\n]+/g, " ");
				msg=msg.substring(0,30) + '...' ;
				//alert(fullMsg);
				var alrt='<span class="infoLink" onclick="alert(' + "'" + fullMsg + "'" + ')">View Full Error</span>';
				msg +=alrt;
			}
		}
		m.innerHTML=msg;
		m.className='ajaxWorking ' + sev;
	} else {
		m.className='ajaxDone';
		var msg="";
	}
}
function loadTree () {
	post(1);
	var theTreeDiv = document.getElementById('treePane');	
	var flds="cat_num,barcode,container_label,description,container_type,part_name,collection_id,other_id_type,other_id_value,collection_object_id,loan_trans_id,table_name,in_container_type";
	var arrFld = flds.split( "," );
	var q="";
	for (f in arrFld) {
		if (document.getElementById(arrFld[f])){
			//alert(arrFld[f]);
			var v = document.getElementById(arrFld[f]).value;
			//alert('v'+v)
			if (v.length > 0) {
				var n = arrFld[f] + '=' + v;
				if (q.length==0) {
					q=n;
				} else {
					q += "&" + n
				}
			}
		}
	}
	jQuery.getJSON("/component/container.cfc",
		{
			method : "get_containerTree",
			q : q,
			returnformat : "json",
			queryformat : 'column'
		},
		loadTree_success
	);
}
function showSpecTreeOnly (colobjid) {
	post(1);
	var theTreeDiv = document.getElementById('treePane');
	theTreeDiv.className="";
	document.getElementById('thisfooter').style.display='none';
	document.getElementById('header_color').style.display='none';
	document.getElementById('searchPane').style.display='none';
	var q="collection_object_id=" + colobjid;
	jQuery.getJSON("/component/container.cfc",
		{
			method : "get_containerTree",
			q : q,
			returnformat : "json",
			queryformat : 'column'
		},
		loadTree_success
	);
}
function loadTree_success(r) {
	//alert(result);
	var result=r.DATA;
	var theTreeDiv = document.getElementById('treePane');
	var oops = result.CONTAINER_ID[0];
	if (oops==-1) {
		//alert('got oops');
		var errr = result.MSG[0];
		post(1,errr);
	} else{
		theTreeDiv.className="cTreePane";
		theTreeDiv.innerHTML = '';
		newTree=new dhtmlXTreeObject("treePane","100%","100%;",0);
		newTree.setImagePath("/images/dhtmlxTree/");
		newTree.insertNewItem("0","container0","The Universe",0,0,0,0,"SELECT");
		newTree.enableCheckBoxes(1);
		newTree.enableDragAndDrop("temporary_disabled");
		newTree.attachEvent("onDblClick","expandNode")
		newTree.attachEvent("onCheck","checkHandler")
		for (i = 0; i < r.ROWCOUNT; i++) { 
		 	var CONTAINER_ID = result.CONTAINER_ID[i];
			var PARENT_CONTAINER_ID = result.PARENT_CONTAINER_ID[i];
			var CONTAINER_TYPE = result.CONTAINER_TYPE[i];
			var LABEL = result.LABEL[i];
			var thisIns = 'newTree.insertNewChild("' + PARENT_CONTAINER_ID + '","' + CONTAINER_ID + '","' + LABEL + ' (' + CONTAINER_TYPE + ')",0,0,0,0,"",1)';
			eval(thisIns);
		}
		post();
	}
}
function expandNode (id) {
	post(1);
	jQuery.getJSON("/component/container.cfc",
		{
			method : "get_containerContents",
			contr_id : id,
			returnformat : "json",
			queryformat : 'column'
		},
		expandNode_success
	);
}
function expandNode_success (r) {
	var result=r.DATA;
	var ok = result.CONTAINER_ID[0];
	if (ok == '-1') {
		var error = result.MSG[0];
		post(1,error);
	} else{
		var didSomething = "";
		for (i = 0; i < r.ROWCOUNT; i++) { 
		 	var CONTAINER_ID = result.CONTAINER_ID[i];
			var n = "newTree.getLevel('" + CONTAINER_ID + "')";
			var nE = eval(n);
			if (nE == 0) {
				var PARENT_CONTAINER_ID = result.PARENT_CONTAINER_ID[i];
				var CONTAINER_TYPE = result.CONTAINER_TYPE[i];
				var DESCRIPTION = result.DESCRIPTION[i];
				var PARENT_INSTALL_DATE = result.PARENT_INSTALL_DATE[i];
				var CONTAINER_REMARKS = result.CONTAINER_REMARKS[i];
				var LABEL = result.LABEL[i];
				var thisIns = 'newTree.insertNewChild("' + PARENT_CONTAINER_ID + '","' + CONTAINER_ID + '","' + LABEL + ' (' + CONTAINER_TYPE + ')",0,0,0,0,"",1)';
				eval(thisIns);
				didSomething = 'yep';
			}						
		 }
		if (didSomething == '') {
			post(1,'This container is already expanded.');
		}
		post();
	}
}
function checkHandler (id){
	post(1);
	try {
		jQuery('#detailPane').load("/ContDet.cfm",{container_id: id});
		var fatAr = newTree.getAllFatItems().split(",")
		var leafAr = newTree.getAllLeafs().split(",")
		var rootsAr = fatAr.concat(leafAr);
		for(var i=0;i<rootsAr.length;i++){ 
			newTree.setItemColor(rootsAr[i],'black','black');
			newTree.setCheck(rootsAr[i],0) 
		}
		newTree.setItemColor(id,'red','red');
		newTree.setCheck(id,1);
		post();
	} catch(err){
		post(1,err);
	}
}

function downloadTree () {
	post(1);
	try {
		var fatAr = newTree.getAllFatItems().split(",")
		var leafAr = newTree.getAllLeafs().split(",")
		var rootsAr = fatAr.concat(leafAr);
		var cidAr= new Array;
		for(var i=0;i<rootsAr.length;i++){ 
			cidAr.push(rootsAr[i]); 
		}
		var cutAr=cidAr.slice(1);
		var cid=cutAr.join(",");
		post();
		window.open('loanFreezerLocn.cfm?container_id=' + cid);
	} catch(err){
		post(1,'Error: No tree?');
	}
}

function printLabels () {
	post(1);
	try {
		var fatAr = newTree.getAllFatItems().split(",")
		var leafAr = newTree.getAllLeafs().split(",")
		var rootsAr = fatAr.concat(leafAr);
		var cidAr= new Array;
		for(var i=0;i<rootsAr.length;i++){ 
			cidAr.push(rootsAr[i]); 
		}
		var cutAr=cidAr.slice(1);
		var cid=cutAr.join(",");
		post();
		window.open('Reports/report_printer.cfm?container_id=' + cid);
	} catch(err){
		post(1,'Error: No tree?');
	}
}
function showTreeOnly(){
	try {
		var theTreeDiv = document.getElementById('treePane');
		theTreeDiv.className='';
		newTree.enableDragAndDrop("true");
		document.getElementById('thisfooter').style.display='none';
		document.getElementById('header_color').style.display='none';
		document.getElementById('searchPane').style.display='none';	
		document.getElementById('detailPane').style.display='none';
		alert('reload to get your stuff back. Drag things around if you want.');
	} catch(err){
		post(1,'Error: No tree?');
	}
}

if(window.Event && document.captureEvents)
document.captureEvents(Event.MOUSEMOVE);
document.onmousemove = getMousePos;

function getMousePos(e){
	var mouseX, mouseY;
	if (!e)
		var e = window.event||window.Event;
	if('undefined'!=typeof e.pageX) {
		mouseX = e.pageX;
		mouseY = e.pageY;
	} else {
		mouseX = e.clientX + document.body.scrollLeft;
		mouseY = e.clientY + document.body.scrollTop;
	}
	if(document.getElementById('containerDetails')) {
		var theDetDiv = document.getElementById('containerDetails');
		var isVis = theDetDiv.style.display;
		if (isVis == ''){
			if(document.getElementById('noMoveNow')) {
				var nmn = document.getElementById('noMoveNow');
				noMoveNow = nmn.value;
				if (noMoveNow == 0) {
					dd.elements.containerDetails.moveTo(mouseX,mouseY);
					nmn.value='1';
				}
			}
		}
	}
}
IE=(document.all)?1:0;
NS=(document.layers)?1:0;
if (!IE && !NS) {
   eval('event = ""'); 
}
function closeDetails(){
	var theDetDiv = document.getElementById('containerDetails');
	var nmn = document.getElementById('noMoveNow');
	nmn.value='0';
	theDetDiv.style.display='none';
}
function tonclick(id){
	alert("Item "+tree.getItemText(id)+" was selected");
};
function tondblclick(id){
	alert("Item "+tree.getItemText(id)+" was doubleclicked");
};			
function tondrag(id,id2){
	return confirm("Do you want to move node ( " + id + ") "+tree.getItemText(id)+" to item ( " + id2 + ")"+tree.getItemText(id2)+"?");
};
function tonopen(id,mode){
	return confirm("Do you want to "+(mode>0?"close":"open")+" node "+tree.getItemText(id)+"?");
};
function toncheck(id,state){
	alert("Item "+tree.getItemText(id)+" was " +((state)?"checked":"unchecked"));
};	
function onCheck(id){
	alert("Check id "+id);
}
function onClick(id){
	alert("Click id "+id);
}
function onDrag(id,id2){
	alert("Drag id "+id+","+id2);
	return true;
}		
function lxml () {
	var tb = document.getElementById('treeBox');
	tb.innerHTML = '';
	tree=new dhtmlXTreeObject('treeBox',"400","800",0); 
	tree.loadXML("temp/leftContainer_3723816230877.xml");//load root level from xml
}

function focusDefault() {
	//alert('focusy thingy');
	if (document.getElementById('n_barcode')) {
		var isThere = document.getElementById('n_barcode_d').style.display;
		if (isThere=='') {
			document.getElementById('n_barcode').focus();
			//alert('barcode');
		}
		
	}
	
	if (document.getElementById('n_cat_num')) {
		var isThere = document.getElementById('n_cat_num_d').style.display;
		if (isThere=='') {
				document.getElementById('n_cat_num').focus();
				//alert('catnum');
		}
		
	}
}
function doPartSearch(side,srchType) {
	// turn everything off
	//alert(side + ' ' + srchType);
	thisVar = side + 'cat_num_d';
	var cat_num_d = document.getElementById(thisVar);
	thisVar = side + 'barcode_d';
	var barcode_d = document.getElementById(thisVar);
	thisVar = side + 'container_label_d';
	var container_label_d = document.getElementById(thisVar);
	thisVar = side + 'part_name_d';
	var part_name_d = document.getElementById(thisVar);
	thisVar = side + 'description_d';
	var description_d = document.getElementById(thisVar);
	thisVar = side + 'collection_id_d';
	var collection_id_d = document.getElementById(thisVar);
	thisVar = side + 'container_type_d';
	var container_type_d = document.getElementById(thisVar);
	thisVar = side + 'partSrchBtn';
	var partSrchBtn = document.getElementById(thisVar);
	thisVar = side + 'contSrchBtn';
	var contSrchBtn = document.getElementById(thisVar);
	thisVar = side + 'srch';
	var srch = document.getElementById(thisVar);
	
	thisVar = side + 'other_id_d';
	var other_id_d = document.getElementById(thisVar);
	
					
	cat_num_d.style.display='none';
	barcode_d.style.display='none';
	container_label_d.style.display='none';
	part_name_d.style.display='none';
	description_d.style.display='none';
	collection_id_d.style.display='none';
	container_type_d.style.display='none';
	partSrchBtn.style.display='none';
	contSrchBtn.style.display='none';
	other_id_d.style.display='none';
	// reset the form's values 
	if (side == 'r_') {
		//alert('reset r');
		document.loadRightTreeForm.reset();
	} else if (side == 'l_') {
		document.loadLeftTreeForm.reset();
	}  else if (side == 'n_') {
		document.loadFindTreeForm.reset();
	}
	
	if (srchType == 'part') {
		cat_num_d.style.display='';
		part_name_d.style.display='';	
		collection_id_d.style.display='';
		contSrchBtn.style.display='';
		other_id_d.style.display='';
		srch.value='part';
	} else {
		barcode_d.style.display='';
		container_label_d.style.display='';
		description_d.style.display='';
		container_type_d.style.display='';
		partSrchBtn.style.display='';
		srch.value='container';
	}
	focusDefault();
}	
function l_expandNode (id) {
	// came from left, redirect
	var treeID = "leftTreeBox";
	expandNode(id,treeID);
}
function r_expandNode (id) {
	// came from left, redirect
	var treeID = "rightTreeBox";
	expandNode(id,treeID);
}
function n_expandNode (id) {
	// came from left, redirect
	var treeID = "findTreeBox";
	expandNode(id,treeID);
}
function r_tondrag (id, pid) {
	//alert ('r_tondrag');
	yesDelete = window.confirm("Do you want to move node " + id + " to node " + pid + "....");
	if (yesDelete == true) {
		//alert('ok');
		var treeID = "rightTreeBox";
		alert('fail');
		//DWREngine._execute(_containerTree_func, null,'moveContainer',treeID,id,pid,  moveContainer_success);
		return true;
	} else {
		return false;
	}
}	

function moveContainer_success(result) {
	alert(result);
	var rAry = result.split('||');
	var treeID = rAry[0];
	var theMsg = rAry[1];
	if (theMsg == 'success') {
		alert('spiffy: ' + theMsg)
	} else {
		alert('An error has occured. The form will reload.\n' + theMsg);
		loadTree('loadLeftTreeForm');
		loadTree('loadRightTreeForm');
		return false;
	}
}

function l_toncheck(id,state){
				
				var treeID = "leftTreeBox";
				getContDetails(id,state,treeID);
			};
function r_toncheck(id,state){
				var treeID = "rightTreeBox";
				getContDetails(id,state,treeID);
			};			
function n_toncheck(id,state){
				// uncheck everything
				
				
				var a = tree_findTreeBox.getAllChecked();
				var arrElems = a.split( "," );
				//alert(a);
				for (i=0;i<arrElems.length;i++) {
					var thisID = arrElems[i];
					//alert(thisID);
					tree_findTreeBox.setCheck(thisID,0);
				}
				// check active back
				tree_findTreeBox.setCheck(id,1);
				//alert(a.length);

				var nmn = document.getElementById('noMoveNow');
				nmn.value='0';
				var treeID = "findTreeBox";
				getContDetails(id,state,treeID);
			};			
			
function getContDetails(id,state,treeID){
	jQuery.getJSON("/component/container.cfc",
		{
			method : "getContDetails",
			treeID : treeID,
			contr_id : id,
			returnformat : "json",
			queryformat : 'column'
		},
		getContDetails_success
	);
}
function getContDetails_success (result) {
	//alert (result);
	var resArray = result.split("||");
	var treeID = resArray[0];
	var container_id = resArray[1];
	var parent_container_id = resArray[2];
	var container_type = resArray[3];
	var description = resArray[4];
	var parent_install_date = resArray[5];
	var container_remarks = resArray[6];
	var label = resArray[7];
	
	var ctypH = document.getElementById('dis_container_type');
	var desH = document.getElementById('dis_description');
	var idateH = document.getElementById('dis_parent_install_date');
	var remH = document.getElementById('dis_container_remarks');
	var lblH = document.getElementById('dis_label');
	var admH = document.getElementById('dis_admin');
	
	ctypH.innerHTML = container_type;
	desH.innerHTML = description;
	idateH.innerHTML = parent_install_date;
	remH.innerHTML = container_remarks;
	lblH.innerHTML = label;
	admH.innerHTML = '<a href="/EditContainer.cfm?container_id=' + container_id + '" target="_detail" onclick="closeDetails()">Edit</a>';
	admH.innerHTML += '<br><a href="/info/ContHistory.cfm?container_id=' + container_id + '" target="_detail" onclick="closeDetails()">History</a>';
	admH.innerHTML += '<br><a href="/containerPositions.cfm?container_id=' + container_id + '" target="_blank" onclick="closeDetails()">Positions</a>';
	admH.innerHTML += '<br><a href="/allContainerLeafNodes.cfm?container_id=' + container_id + '" target="_detail" onclick="closeDetails()">Leaf Nodes</a>';
	
	
	
	var td = document.getElementById('containerDetails');
	td.style.display='';
	
}	
function yescheck() {
	alert('yescheck');
	var a = tree_findTreeBox.getAllChecked();
	alert(a);
}
function nocheck() {
	tree_findTreeBox.enableCheckBoxes( false);
	alert('nocheck');	
	/*
	alert('findNode');
	//var n = tree_findTreeBox.findItem('notThere');
	//var i = tree_findTreeBox.findItem('2252084');
	//alert(n);
	//alert(i);
	//tree_findTreeBox.insertNewChild("' + PARENT_CONTAINER_ID + '","' + CONTAINER_ID + '","' + LABEL + ' (' + CONTAINER_TYPE + ')",0,0,0,0,"",1)';
	//		eval(thisIns);
	
	var i = tree_findTreeBox.closeItem('476089');
	var e = tree_findTreeBox.closeItem('afgaer');
	var ea = tree_findTreeBox.closeItem('2252084');
	alert(i);
	alert(e);
	alert(ea);
	
	var a = tree_findTreeBox.getLevel('2252084');
	var b = tree_findTreeBox.getLevel('asdawre');
	var c = tree_findTreeBox.getLevel('41205');
	alert(a);
	alert(b);
	alert(c);
	*/
	}