
function updateLoanItemRemarks ( partID ) {
	var s = "document.getElementById('loan_Item_Remarks" + partID + "').value";
	var loan_Item_Remarks = eval(s);
	var transaction_id = document.getElementById('transaction_id').value;
	//alert(item_instructions);
	DWREngine._execute(_cfscriptLocation, null, 'updateLoanItemRemarks', partID,transaction_id,loan_Item_Remarks, success_updateLoanItemRemarks);
}
function success_updateLoanItemRemarks (result) {
	var partID = result[0].PART_ID;
	var message = result[0].MESSAGE;
	//alert(partID);
	//alert(message);
	if (message == 'success') {
		var ins = "document.getElementById('loan_Item_Remarks" + partID + "')";
		var loan_Item_Remarks = eval(ins);
		loan_Item_Remarks.className = '';
	} else {
		alert('An error occured: \n' + message);
	}
}

function updateInstructions ( partID ) {
	var s = "document.getElementById('item_instructions" + partID + "').value";
	var item_instructions = eval(s);
	var transaction_id = document.getElementById('transaction_id').value;
	//alert(item_instructions);
	DWREngine._execute(_cfscriptLocation, null, 'updateInstructions', partID,transaction_id,item_instructions, success_updateInstructions);
}
function success_updateInstructions (result) {
	var partID = result[0].PART_ID;
	var message = result[0].MESSAGE;
	//alert(partID);
	//alert(message);
	if (message == 'success') {
		var ins = "document.getElementById('item_instructions" + partID + "')";
		var item_instructions = eval(ins);
		item_instructions.className = '';
	} else {
		alert('An error occured: \n' + message);
	}
}
function remPartFromLoan( partID ) {
	var s = "document.getElementById('coll_obj_disposition" + partID + "')";
	//alert(s);
	var dispnFld = eval(s);
	//dispnFld.className='';
	var thisDispn = dispnFld.value;
	var isS = "document.getElementById('isSubsample" + partID + "')";
	var isSslFld = eval(isS);
	varisSslVal = isSslFld.value;
	var transaction_id = document.getElementById('transaction_id').value;
	if (varisSslVal > 0) {
		var m = "Would you like to DELETE this subsample? \n OK: permanently remove from database \n Cancel: remove from loan";
		var answer = confirm (m);
		if (answer) {
			DWREngine._execute(_cfscriptLocation, null, 'del_remPartFromLoan', partID,transaction_id, success_remPartFromLoan);
		} else {
			if (thisDispn == 'on loan') {
				alert('The part cannot be removed because the disposition is "on loan".');
			} else {
				DWREngine._execute(_cfscriptLocation, null, 'remPartFromLoan', partID,transaction_id, success_remPartFromLoan);
			}
		}
		//alert('remove subsample');
	} else if (thisDispn == 'on loan') {
		alert('That part cannot be removed because the disposition is "on loan".');
	} else {
		DWREngine._execute(_cfscriptLocation, null, 'remPartFromLoan', partID,transaction_id, success_remPartFromLoan);
		//alert('spiffy, go away....');
	}
	//alert(thisDispn);
	//DWREngine._execute(_cfscriptLocation, null, 'updatePartDisposition', partID,thisDispn, success_updateDispn);
}
function success_remPartFromLoan (result) {
	var partID = result[0].PART_ID;
	var message = result[0].MESSAGE;
	//alert(partID);
	//alert(message);
	if (message == 'success') {
		var tr = "document.getElementById('rowNum" + partID + "')";
		var theRow = eval(tr);
		theRow.style.display='none';
	} else {
		alert('An error occured: \n' + message);
	}
}
function updateDispn( partID ) {
	var s = "document.getElementById('coll_obj_disposition" + partID + "')";
	//alert(s);
	var dispnFld = eval(s);
	//dispnFld.className='';
	var thisDispn = dispnFld.value;
	//alert(thisDispn);
	DWREngine._execute(_cfscriptLocation, null, 'updatePartDisposition', partID,thisDispn, success_updateDispn);
}
function success_updateDispn (result) {
	//alert(result);
	var partID = result[0].PART_ID;
	var status = result[0].STATUS;
	var disposition = result[0].DISPOSITION;
	if (status == 'success') {
		var s = "document.getElementById('coll_obj_disposition" + partID + "')";
		var dispnFld = eval(s);
		dispnFld.className='';
	} else {
		alert('An error occured:\n' + disposition);
	}
	//alert(partID);
	//alert(status);
	//alert(disposition);
}
	
function catNumSeq () {
		//alert('getting cat number...');
		var catnum = document.getElementById('cat_num').value;
		var isCatNum = catnum.length;
		//alert(isCatNum);
		if (isCatNum == 0) { // only get the number if there's not already one in place
			var inst = document.getElementById('institution_acronym').value;
			var coll = document.getElementById('collection_cde').value;			
			var coll_id = inst + " " + coll;
			//alert(coll_id);
			DWREngine._execute(_data_entry_func, null, 'getcatNumSeq', coll_id, success_catNumSeq);
			//alert('gone');
		}
		//alert('gone to server');
	}
	function success_catNumSeq (result) {
		
		var catnum = document.getElementById('cat_num');
		catnum.value=result;
	}
function getAttributeStuff (attribute,element) {
	//alert(attribute + '-' + element);	
	var isSomething = attribute.length;
	if (isSomething > 0) {
		// collection
		// make it look like we're doing something
		var optn = document.getElementById(element);
		optn.style.backgroundColor='red';
		var thisCC = document.getElementById('collection_cde').value;
		DWREngine._execute(_data_entry_func, null, 'getAttCodeTbl', attribute,thisCC,element, success_getAttributeStuff);
	}
}
function success_getAttributeStuff (result) {
	//alert('back');
	//alert(result);
	// first line of returned query will always be the type of result
	var resType=result[0].V;
	//alert(resType);
	// second line is the element we changed
	var theEl=result[1].V;
	//alert(theEl);
	// get rid of the funky BG
	var optn = document.getElementById(theEl);
	optn.style.backgroundColor='';
	var n=result.length;
	//alert(n);
	// get the ID of the cell containing the element we want to replace
	var theNumber = theEl.replace("attribute_","");
	//alert(theNumber);
	if (resType == 'value') {
		var theDivName = "attribute_value_cell_" + theNumber;
		theTextDivName = "attribute_units_cell_" + theNumber;
		theSelectName = "attribute_value_" + theNumber;
		theTextName = "attribute_units_" + theNumber;
	} else if (resType == 'units') {
		var theDivName = "attribute_units_cell_" + theNumber;
		theSelectName = "attribute_units_" + theNumber;
		theTextDivName = "attribute_value_cell_" + theNumber;
		theTextName = "attribute_value_" + theNumber;
	} else {
		// either no control attribute or we got an error
		var theDivName = "attribute_value_cell_" + theNumber;
		var theTextDivName = "attribute_units_cell_" + theNumber;
		theSelectName = "attribute_value_" + theNumber;
		theTextName = "attribute_units_" + theNumber;
	}
	// clear the div out IF we got a value or units result set
	var theDiv = document.getElementById(theDivName);
	var theText = document.getElementById(theTextDivName);
	if (resType == 'value' || resType == 'units') {
		theDiv.innerHTML = ''; // clear it out
		theText.innerHTML = '';
	
		if (n > 2) {
			// got something, loop over the array to populate the fields
			// create a select
			var theNewSelect = document.createElement('SELECT');
			theNewSelect.name = theSelectName;
			theNewSelect.id = theSelectName;
			if (resType == 'units') {
				var sWid = '60px;';
			} else {
				var sWid = '90px;';
			}
			theNewSelect.style.width=sWid;
			theNewSelect.className = "d11a";
			var a = document.createElement("option");
			a.text = '';
    		a.value = '';
			theNewSelect.appendChild(a);// add blank
			for (i=2;i<result.length;i++) {
				var theStr = result[i].V;
				//alert(theStr);
				var a = document.createElement("option");
				a.text = theStr;
				a.value = theStr;
				theNewSelect.appendChild(a);
			}
			theDiv.appendChild(theNewSelect);
			// and switch the other (value or units) back to original
			// IF we're selecting a units attribute. otherwise, leave it blank
			if (resType == 'units') {
				var theNewText = document.createElement('INPUT');
				theNewText.name = theTextName;
				theNewText.id = theTextName;	
				theNewText.type="text";
				theNewText.style.width='95px';
				theNewText.className = "d11a";
				theText.appendChild(theNewText);
			}
		}
	} else if (resType == 'NONE') {
		// text value, no units
		theDiv.innerHTML = '';
		theText.innerHTML = '';
		//alert(resType);
		var theNewText = document.createElement('INPUT');
		theNewText.name = theTextName;
		theNewText.id = theTextName;	
		theNewText.type="text";
		theNewText.style.width='95px';
		theNewText.className = "d11a";
		theDiv.appendChild(theNewText);
	} else {
	//oops
	alert('Something bad happened! Try selecting nothing, then re-selecting an attribute or reloading this page');
	}
	//end got valid results
} 
	function catNumGap () {
		//alert('getting cat number...');
		//var catnum = document.getElementById('cat_num').value;
		//var isCatNum = catnum.length;
		//alert(isCatNum);
		//if (isCatNum == 0) { // only get the number if there's not already one in place
		//	var inst = document.getElementById('institution_acronym').value;
		//	var coll = document.getElementById('collection_cde').value;			
		//	var coll_id = inst + " " + coll;
			//alert(coll_id);
		//	DWREngine._execute(_cfscriptLocation, null, 'getBlankCatNum', coll_id, success_catNumGap);
	//	}
		//alert('gone to server');
	}
	function success_catNumGap (result) {
		//alert(result);
	//	var catnum = document.getElementById('cat_num');
	//	catnum.value=result;
	}