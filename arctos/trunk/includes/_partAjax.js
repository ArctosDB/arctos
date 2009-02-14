if(window.Event && document.captureEvents)
document.captureEvents(Event.MOUSEMOVE);
document.onmousemove = getMousePos;


function getMousePos(e){
// need the following code in the page outside any functions:
/*
if(window.Event && document.captureEvents)
document.captureEvents(Event.MOUSEMOVE);
document.onmousemove = getMousePos;
*/
	//alert('mouspos');
	var mouseX, mouseY;

if (!e)
var e = window.event||window.Event;

if('undefined'!=typeof e.pageX)
{
mouseX = e.pageX;
mouseY = e.pageY;
}
else
{
mouseX = e.clientX + document.body.scrollLeft;
mouseY = e.clientY + document.body.scrollTop;
}

//document.getElementById('n_cat_num').value=mouseX + "; " + mouseY;
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
				
				
				
				//SET_DHTML("containerDetails"+NO_DRAG);
		}
//		alert(isVis);
		
		//document.getElementById('x_mouse').value=mouseX;
		//document.getElementById('y_mouse').value=mouseY;
	}
}


IE=(document.all)?1:0;
NS=(document.layers)?1:0;
if (!IE && !NS) {
/*
    Dummy event var for v3 browsers. 
   I use eval because IE will not allow 
   event to be assigned directly even within the if!
*/
   eval('event = ""'); 
}

function onDragPart (id,pid) {
	//alert('ho there');
	/*
	yesDelete = window.confirm("Do you want to move node " + id + " to node " + pid + "....");
	if (yesDelete == true) {
		//alert('ok');
		
		return true;
	} else {
		return false;
	}
	*/
	DWREngine._execute(_cfscriptLocation, null,'movePartInTree',id,pid,  movePartInTree_success);
	return true;
}
function movePartInTree_success (result) {
	if (result == 'failure') {
		alert('Something bad happened. Reload this page while holding SHIFT.');
	}
	//alert(result);
}
function onDoubleClick (id){
	alert(id);
	if (id <= 0) {
		var pn = document.getElementById('part_name');
		var pd = document.getElementById('description');
		var pv = document.getElementById('valid_for_items');
		var pi = document.getElementById('part_id');
		var pb = document.getElementById('theButton');
		var pc = document.getElementById('collection_cde');
		pi.value='';
		pn.value='';
		pd.value='';
		pv.value='';
		pc.value='';
		pb.style.display='';
		pb.value='Save New';
		pb.setAttribute("onclick","savenewpart()");
	} else {
		DWREngine._execute(_cfscriptLocation, null,'getPartRecDet',id, getPartRecDet_success);
		//alert('edit');
	}
}
function getPartRecDet_success (result) {
	var part_name=result[0].PART_NAME;
	var part_id=result[0].PART_ID;
	var valid_for_items=result[0].VALID_FOR_ITEMS;
	var description=result[0].DESCRIPTION;
	var collection_cde=result[0].COLLECTION_CDE;
	//alert(collection_cde);
	var pn = document.getElementById('part_name');
	var pd = document.getElementById('description');
	var pv = document.getElementById('valid_for_items');
	var pi = document.getElementById('part_id');
	var pb = document.getElementById('theButton');
	var pc = document.getElementById('collection_cde');
	pi.value=part_id;
	pn.value=part_name;
	pd.value=description;
	pv.value=valid_for_items;
	pc.value=collection_cde;
	pb.style.display='';
	pb.value='Save Edits';
	pb.setAttribute("onclick","savepartedit()");
}
function savepartedit () {
	alert('savey thingy');
	var pn = document.getElementById('part_name').value;
	var pd = document.getElementById('description').value;
	var pv = document.getElementById('valid_for_items').value;
	var pi = document.getElementById('part_id').value;
	var pc = document.getElementById('collection_cde').value;
	DWREngine._execute(_cfscriptLocation, null,'saveEditPart',id, saveEditPart_success);
}

function saveEditPart_success (result) {
	alert(result);
}
function savenewpart () {
	alert('savenewpart');
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
	//tree.setXMLAutoLoading("t.xml"); 
	tree.loadXML("temp/leftContainer_3723816230877.xml");//load root level from xml
}

function loadTree (formName) {
	if (formName == 'loadLeftTreeForm') {
		var thePrefix = "l_";
	} else if (formName == 'loadRightTreeForm') {
		var thePrefix = 'r_';
	} else if (formName == 'loadFindTreeForm') {
		var thePrefix = 'n_';
	} else {
		alert('Bad Form!');
		return false;
	}
	//alert(thePrefix);
	
	thisVar = thePrefix + 'treeID';
	//alert(thisVar);
	var treeID = document.getElementById(thisVar).value;
	// clear out whatever's in there now
	var theTreeDiv = document.getElementById(treeID);
	theTreeDiv.innerHTML = '';
	thisVar = thePrefix + 'srch';
	var srch = document.getElementById(thisVar).value;
	
	thisVar = thePrefix + 'cat_num';
	var cat_num = document.getElementById(thisVar).value;
	
	thisVar = thePrefix + 'barcode';
	var barcode = document.getElementById(thisVar).value;
	
	thisVar = thePrefix + 'container_label';
	var container_label = document.getElementById(thisVar).value;
	
	thisVar = thePrefix + 'description';
	var description = document.getElementById(thisVar).value;
	thisVar = thePrefix + 'container_type';
	var container_type = document.getElementById(thisVar).value;
	thisVar = thePrefix + 'part_name';
	var part_name = document.getElementById(thisVar).value;
	
	thisVar = thePrefix + 'collection_id';
	var collection_id = document.getElementById(thisVar).value;
	
	DWREngine._execute(_containerTree_func, null,'get_containerTree',treeID,srch,cat_num,barcode,container_label,description, container_type,part_name,collection_id,"-1",  loadTree_success);
	
}

function loadTree_success(result) {
	//alert(result);
	var treeID = result[0].TREEID;
	//alert(treeID);
	if (treeID == '-1') {
		// error
		var error = result[0].CONTAINER_ID;
		alert('An error occured: \n ' + error);
	} else{
		// happy
		 var theTreeName = "tree_" + treeID;
			eval(theTreeName + '=new dhtmlXTreeObject("' + treeID + '","100%","100%;",0)');
			eval(theTreeName + '.insertNewItem("0","container0","Parentless Void",0,0,0,0,"SELECT")');
			eval(theTreeName + '.enableDragAndDrop(1)');
			eval(theTreeName + '.enableCheckBoxes(1)');
			if (treeID == 'leftTreeBox') {
				eval(theTreeName + '.setDragHandler(l_tondrag)');
				eval(theTreeName + '.setOnDblClickHandler(l_expandNode)');
				eval(theTreeName + '.setOnCheckHandler(l_toncheck)');
			} else if (treeID == 'rightTreeBox') {
				eval(theTreeName + '.setDragHandler(r_tondrag)');
				eval(theTreeName + '.setOnDblClickHandler(r_expandNode)');
				eval(theTreeName + '.setOnCheckHandler(r_toncheck)');		
			}	else if (treeID == 'findTreeBox') {
				//alert('yeppers');
				eval(theTreeName + '.enableDragAndDrop(0)');
				eval(theTreeName + '.setOnDblClickHandler(n_expandNode)');
				eval(theTreeName + '.setOnCheckHandler(n_toncheck)');	
			} else {
				alert('tree div not recognized! File a bug report...');
			}
			
		 for (i = 0; i < result.length; i++) { 
		 	var CONTAINER_ID = result[i].CONTAINER_ID;
			var PARENT_CONTAINER_ID = result[i].PARENT_CONTAINER_ID;
			var CONTAINER_TYPE = result[i].CONTAINER_TYPE;
			var LABEL = result[i].LABEL;
			//alert(CONTAINER_TYPE);
			var thisIns = theTreeName + '.insertNewChild("' + PARENT_CONTAINER_ID + '","' + CONTAINER_ID + '","' + LABEL + ' (' + CONTAINER_TYPE + ')",0,0,0,0,"",1)';
			//alert(thisIns);
			eval(thisIns);
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
	
					
	cat_num_d.style.display='none';
	barcode_d.style.display='none';
	container_label_d.style.display='none';
	part_name_d.style.display='none';
	description_d.style.display='none';
	collection_id_d.style.display='none';
	container_type_d.style.display='none';
	partSrchBtn.style.display='none';
	contSrchBtn.style.display='none';
	
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
		srch.value='part';
	} else {
		barcode_d.style.display='';
		container_label_d.style.display='';
		description_d.style.display='';
		container_type_d.style.display='';
		partSrchBtn.style.display='';
		srch.value='container';
	}
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

function expandNode (id,treeID) {
	//alert ('expandNode:' + id + ' ' + treeID);
	
	DWREngine._execute(_containerTree_func, null,'get_containerContents',treeID,id,  expandNode_success);
}

function expandNode_success (result) {
	//alert(result);
	var treeID = result[0].TREEID;
	//alert(treeID);
	if (treeID == '-1') {
		// error
		var error = result[0].CONTAINER_ID;
		alert('An error occured: \n ' + error);
	} else{
		// happy
		 for (i = 0; i < result.length; i++) { 
		 	var CONTAINER_ID = result[i].CONTAINER_ID;
			var PARENT_CONTAINER_ID = result[i].PARENT_CONTAINER_ID;
			var CONTAINER_TYPE = result[i].CONTAINER_TYPE;
			var DESCRIPTION = result[i].DESCRIPTION;
			var PARENT_INSTALL_DATE = result[i].PARENT_INSTALL_DATE;
			var CONTAINER_REMARKS = result[i].CONTAINER_REMARKS;
			var LABEL = result[i].LABEL;
			//alert(CONTAINER_ID);
			var thisIns = "tree_" + treeID + '.insertNewChild("' + PARENT_CONTAINER_ID + '","' + CONTAINER_ID + '","' + LABEL + ' (' + CONTAINER_TYPE + ')",0,0,0,0,"",1)';
			eval(thisIns);
		 }
	}
}	


function l_tondrag (id, pid) {
	yesDelete = window.confirm("Do you want to move node " + id + " to node " + pid + "....");
	if (yesDelete == true) {
		//alert('ok');
		var treeID = "leftTreeBox";
		DWREngine._execute(_containerTree_func, null,'moveContainer',treeID,id,pid,  moveContainer_success);
		return true;
	} else {
		return false;
	}
}	
function r_tondrag (id, pid) {
	//alert ('r_tondrag');
	/*
	yesDelete = window.confirm("Do you want to move node " + id + " to node " + pid + "....");
	if (yesDelete == true) {
		//alert('ok');
		var treeID = "rightTreeBox";
		DWREngine._execute(_containerTree_func, null,'moveContainer',treeID,id,pid,  moveContainer_success);
		return true;
	} else {
		return false;
	}
	*/
	DWREngine._execute(_containerTree_func, null,'moveContainer',treeID,id,pid,  moveContainer_success);
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
				var nmn = document.getElementById('noMoveNow');
				nmn.value='0';
				var treeID = "findTreeBox";
				getContDetails(id,state,treeID);
			};			
			
function getContDetails(id,state,treeID){
	//alert(id + " " + treeID);
	DWREngine._execute(_containerTree_func, null,'getContDetails',treeID,id,  getContDetails_success);			
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