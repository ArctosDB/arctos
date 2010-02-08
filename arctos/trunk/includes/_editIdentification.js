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
function addNewIdBy(n) {
	var idS = "addNewIdBy_" + n;
	var theES = document.getElementById(idS).style.display='';
	var vS='newIdBy_' + n;
	var iS='newIdBy_' + n + '_id';
	var v=document.getElementById(vS);
	var i=document.getElementById(iS)
	v.className='reqdClr agntpick';
	v.setAttribute("onfocus", "attachAgentPick(this)");
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
	var bTr = document.getElementById('taxon_b_row');
	var b_val = document.getElementById('taxonb');
	var b_id = document.getElementById('taxonb_id');
			
	if (f == 'A or B' || f == 'A x B' || f == 'A / B intergrade' || f == 'A and B') {
		// a and b
		bTr.style.display='';
		b_val.className='reqdClr';
		b_val.value='';
		b_id.className='reqdClr';
	} else if (f == 'A' || f == 'A ?' || f == 'A cf.' || f == 'A sp.' || f == 'A aff.' || f == 'A ssp.' || f=='A \{string\}') {
		bTr.style.display='none';
		b_val.style.value='';
		b_val.className='';
		b_id.style.value='';
		b_id.className='';
	} else {
		alert("You selected an invalid formula (" + f + "). Please submit a bug report.");
	}
	if(f=='A {string}') {
		document.getElementById('userID').style.display='';
		document.getElementById('user_id').className='reqdClr';
	} else {
		document.getElementById('userID').style.display='none';
		document.getElementById('user_id').className='';
	}
}
function removeIdentifier ( identification_id,num  ) {
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
	
	//nI.setAttribute("onfocus", "attachAgentPick(this)");
	var nid = document.createElement('input');
	nid.setAttribute('type','hidden');
	nid.setAttribute('class','reqdClr');
	ididStr = 'IdBy_' + identification_id + "_" + num + '_id';
	nid.id = ididStr;
	nid.setAttribute('name',ididStr);
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