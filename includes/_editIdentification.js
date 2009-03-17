function flippedAccepted(c) {
	var cvs='accepted_id_fg_'+c;
	var cv=document.getElementById(cvs).value;
	var ts='mainTable_'+c;
	var t=document.getElementById(ts);
	if (cv=='DELETE') {
		t.className='red';
	} else {
		t.className='';
	}
}

function saveIdentifierChange (idId) {
	//alert(idId);
	elAry = idId.split("_");
	var identification_id = elAry[1];
	var agent_id = elAry[2];
	var idS = "IdById_" + identification_id + "_" + agent_id;
	var newAgentId = document.getElementById(idS).value;
	//alert(newAgentId);
	//alert(identification_id);
	//alert(agent_id);
	DWREngine._execute(_cfscriptLocation, null, 'saveIdentifierChange',idId,newAgentId,identification_id,agent_id, success_saveIdentifierChange);
}
function success_saveIdentifierChange (result){
	//alert(result);
	var statAry=result.split('|');
	var status=statAry[0];
	var msg=statAry[1];
	if (status == 'success') {
		//var identification_id = msg;
	//	var t = "mainTable_" + identification_id;
		//document.getElementById(t).style.display='none';
		var elem = document.getElementById(msg);
		elAry = msg.split("_");
		var identification_id = elAry[1];
		var agent_id = elAry[2];
		var sb = "saveButton" + identification_id + "_" + agent_id;
		var sbTn = document.getElementById(sb);
		sbTn.style.display='none';
		elem.className='reqdClr';
	} else {	
		alert(msg);
	}
}


function addNewIdBy(n) {
	var idS = "addNewIdBy_" + n;
	var theES = document.getElementById(idS).style.display='';
	var vS='newIdBy_' + n;
	var iS='newIdBy_' + n + '_id';
	var v=document.getElementById(vS);
	var i=document.getElementById(iS)
	v.className='reqdClr';
	i.className='reqdClr';		
}
function clearNewIdBy (n) {
	var idS = "idBy_" + n;
	var idN = "newIdById_" + n;
	var vS='idBy_' + n;
	var iS='newIdById_' + n;
	var idS = "addNewIdBy_" + n;
	var v=document.getElementById(vS);
	var i=document.getElementById(iS)
	var theES = document.getElementById(idS);
	v.className='';
	i.className='';
	v.value='';
	i.value='';
	theES.style.display='none';
}

function newIdFormula (f) {
	//alert(f);
	var bTr = document.getElementById('taxon_b_row');
	var b_val = document.getElementById('taxa_b');
	var b_id = document.getElementById('TaxonBID');
			
	if (f == 'A or B' || f == 'A x B' || f == 'A / B intergrade' || f == 'A and B') {
		// a and b
		bTr.style.display='';
		b_val.className='reqdClr';
		b_val.value='what the....';
		b_id.className='reqdClr';
	} else if (f == 'A' || f == 'A ?' || f == 'A cf.' || f == 'A sp.' || f == 'A aff.' || f == 'A ssp.') {
		bTr.style.display='none';
		b_val.style.value='';
		b_val.className='';
		b_id.style.value='';
		b_id.className='';
		
	} else {
		alert("You selected an invalid formula. Please submit a bug report.");
	}
}
function saveIdRemarks(identification_id, remark) {
	var affElemS = "identification_remarks_" + identification_id;
	var affElem = document.getElementById(affElemS);
	affElem.className='red';
	DWREngine._execute(_cfscriptLocation, null, 'saveIdRemarks', identification_id,remark, success_saveIdRemarks);
}
function success_saveIdRemarks (result) {
	//alert(result);
	var statAry=result.split('|');
	var status=statAry[0];
	var msg=statAry[1];
	if (status == 'success') {
		var identification_id = msg;
		var eS = "identification_remarks_" + identification_id;
		var elem = document.getElementById(eS);
		elem.className='';
	} else {	
		alert(msg);
	}
}

function saveIdDateChange(identification_id, idDate) {
	var affElemS = "made_date_" + identification_id;
	var affElem = document.getElementById(affElemS);
	affElem.className='red';
	DWREngine._execute(_cfscriptLocation, null, 'saveIdDateChange', identification_id,idDate, success_saveIdDateChange);
}
function success_saveIdDateChange (result) {
	//alert(result);
	var statAry=result.split('|');
	var status=statAry[0];
	var msg=statAry[1];
	if (status == 'success') {
		var flds = msg.split('::');
		var identification_id = flds[0];
		var tdate = flds[1];
		var eS = "made_date_" + identification_id;
		var elem = document.getElementById(eS);
		elem.className='';
		elem.value=tdate;
	} else {	
		alert(msg);
	}
}
function saveNatureOfId(identification_id, nature_of_id) {
	var affElemS = "nature_of_id_" + identification_id;
	var affElem = document.getElementById(affElemS);
	affElem.className='red';
	DWREngine._execute(_cfscriptLocation, null, 'saveNatureOfId', identification_id,nature_of_id, success_saveNatureOfId);
}
function success_saveNatureOfId (result) {
	//alert(result);
	var statAry=result.split('|');
	var status=statAry[0];
	var msg=statAry[1];
	if (status == 'success') {
		var flds = msg.split('::');
		var identification_id = flds[0];
		var tNature = flds[1];
		var eS = "nature_of_id_" + identification_id;
		var elem = document.getElementById(eS);
		elem.className='reqdClr';
		elem.value=tNature;
	} else {	
		alert(msg);
	}
}


function removeIdentifier ( identification_id,num  ) {
	//alert('bye bye');

	var tabCellS = "IdTr_" + identification_id + "_" + num;
	var tabCell = document.getElementById(tabCellS);
	tabCell.style.display='none';
	var affElemS = "IdBy_" + identification_id + "_" + num;
	var affElem = document.getElementById(affElemS);
	var affElemIdS = "IdBy_" + identification_id + "_" + num + "_id";
	var affElemId = document.getElementById(affElemIdS);
	affElemId.value='DELETE'
	affElemId.className='';
	affElem.className='';
	affElem.value='';											
}



function addIdentifier(identification_id,num) {
	var tns = 'identifierTableBody_' + identification_id;
	var theTable = document.getElementById(tns);
	
	var counterS='number_of_identifiers_' + identification_id;
	var counter = document.getElementById(counterS);
	counter.value=parseInt(counter.value) + 1;
	
	var nn=parseInt(num)+1;
	var controlS="addIdentifier_" + identification_id;
	var control=document.getElementById(controlS);
	var cAtt="addIdentifier('" + identification_id + "','" +  nn + "')";
	control.setAttribute("onclick",cAtt);
	
	var nI = document.createElement('input');
	nI.setAttribute('type','text');
	idStr = 'IdBy_' + identification_id + "_" + num;
	nI.id = idStr;
	nI.setAttribute('name',idStr);
	nI.setAttribute('size','50');
	nI.className='reqdClr';
	var onchgStr = "getAgent('IdBy_"  + identification_id + "_" + num + '_id' + "','IdBy_" + identification_id + "_" + num + "','editIdentification',this.value); return false;";
	nI.setAttribute('onchange',onchgStr);
	nI.setAttribute('onKeyPress',"return noenter(event);");
	
	var nid = document.createElement('input');
	
	nid.setAttribute('type','text');
	
	nid.setAttribute('class','reqdClr');
	
	ididStr = 'IdBy_' + identification_id + "_" + num + '_id';
	nid.id = ididStr;
	nid.setAttribute('name',ididStr);
	
	nid.value=ididStr;
	
	r = document.createElement('tr');
	r.id="IdTr_" + identification_id + "_" + num;
	t1 = document.createElement('td');
	t2 = document.createElement('td');
	t3 = document.createTextNode("Identified By:");
	var d = document.createElement('img');
	d.src='/images/del.gif';
	d.className="likeLink";
	var cStrg = "removeIdentifier('" + identification_id + "','" + num + "')";
	d.setAttribute('onclick',cStrg);
	theTable.appendChild(r);
	r.appendChild(t1);
	r.appendChild(t2);
	t1.appendChild(t3);
	t2.appendChild(nI);
	t2.appendChild(nid);
	t2.appendChild(d);
		
			
			
}
function success_addIdentifier(result) {
	//alert(result);
	var stAry=result.split('|');
	var status = stAry[0];
	var msg = stAry[1];
	if (status == 'success') {
		//alert(status);
		var elAry=msg.split('::');
		var theElementName = elAry[0];
		var identification_id = elAry[1];
		var agent_name = elAry[2];
		var identifier_order = elAry[3];
		var agent_id = elAry[4];
		var tns = 'identifierTableBody_' + identification_id;
		var theTable = document.getElementById(tns);

		var nI = document.createElement('input');
		nI.setAttribute('type','text');
		idStr = 'IdBy_' + identification_id + "_" + agent_id;
		nI.id = idStr;
		nI.setAttribute('name',idStr);
		nI.value=agent_name;
		nI.setAttribute('size','50');
		nI.className='reqdClr';
		var onchgStr = "getAgent('IdById_"  + identification_id + "_" + agent_id + "','IdBy_" + agent_id + "','id" + identification_id +  agent_id +"',this.value); return false;";
		nI.setAttribute('onchange',onchgStr);
		nI.setAttribute('onKeyPress',"return noenter(event);");
		
		var nid = document.createElement('input');
		nid.setAttribute('type','hidden');
		
		ididStr = 'IdById_' + identification_id + "_" + agent_id;
		nid.id = ididStr;
		nid.setAttribute('name',ididStr);
		nid.value=agent_id;
		<!--- new row --->
		r = document.createElement('tr');
		r.id="IdTr_" + identification_id + "_" + agent_id;
		t1 = document.createElement('td');
		t2 = document.createElement('td');
		t3 = document.createTextNode("Identified By:");
		var d = document.createElement('img');
		d.src='/images/del.gif';
		d.className="likeLink";
		var cStrg = "removeIdentifier('" + identification_id + "','" + agent_id + "')";
		d.setAttribute('onclick',cStrg);
		theTable.appendChild(r);
		r.appendChild(t1);
		r.appendChild(t2);
		t1.appendChild(t3);
		t2.appendChild(nI);
		t2.appendChild(nid);
		t2.appendChild(d);
		
		var thisElement = document.getElementById(theElementName);
		thisElement.value='';
		thisElement.className='';
	} else {
		alert(msg);
	}
}