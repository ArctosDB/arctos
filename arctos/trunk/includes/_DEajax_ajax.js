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
		theNewText.name = theSelectName;
		theNewText.id = theSelectName;	
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