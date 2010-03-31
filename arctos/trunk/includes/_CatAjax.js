function addIdOn () {
	var addIdentification = document.getElementById('addIdentification');
	var toggleNewIdOn = document.getElementById('toggleNewIdOn');
	var toggleNewIdOff = document.getElementById('toggleNewIdOff');
	addIdentification.style.display='';
	toggleNewIdOn.style.display='none';
	toggleNewIdOff.style.display='';
}
function addIdOff () {
	var addIdentification = document.getElementById('addIdentification');
	var toggleNewIdOn = document.getElementById('toggleNewIdOn');
	var toggleNewIdOff = document.getElementById('toggleNewIdOff');
	addIdentification.style.display='none';
	toggleNewIdOn.style.display='';
	toggleNewIdOff.style.display='none';
}
function updateattribute_determiner(i) {
	console.log('updateattribute_determiner');
	var s = "document.getElementById('attribute_id_" + i + "').value";
	var attribute_id = eval(s);
	var v = "document.getElementById('attribute_determiner_" + i + "').value";
	var attribute_determiner = eval(v);	
	if (attribute_determiner.length > 0) {
		var aidStr = "document.getElementById('watch_attribute_determiner_" + i + "')";
		var agent_idFld = eval(aidStr);
		var agent_id = agent_idFld.value;
		if (agent_id.length == 0) {
			//DWREngine._execute(_catalog_func, null, 'changeAttDetr', attribute_id,i,attribute_determiner,success_updateattribute_determiner);
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "changeAttDetr",
					attribute_id : attribute_id,
					i : i,
					attribute_determiner : attribute_determiner,
					returnformat : "json",
					queryformat : 'column'
				},
				success_updateattribute_determiner
			);
		} else {
			jQuery.getJSON("/component/functions.cfc",
				{
					method : "changeAttDetrId",
					attribute_id : attribute_id,
					i : i,
					agent_id : agent_id,
					returnformat : "json",
					queryformat : 'column'
				},
				success_updateattribute_determiner
			);
			//DWREngine._execute(_catalog_func, null, 'changeAttDetrId', attribute_id,i,agent_id, success_updateattribute_determiner);
			agent_idFld.value='';
		}		
	} else {
		alert("Determiner is required.");
	}
}


function success_updateattribute_determiner (result) {
	//alert(result);
	if (result == 'Nothing matched.') {
		alert(result);
	} else if (result == 'A database error occured!') {
		alert(result);
	} else {
		//alert('m');
		//alert(result);
		var resAry = result.split("::");
		var attNumr = resAry[0];
		var agntList = resAry[1];
		var agntAry = agntList.split("|");
		var numResults = agntAry.length;
		if (numResults == 1) {
				//alert('one result');
				var s = "document.getElementById('attribute_determiner_" + attNumr + "')";
				var se = eval(s);
				var sID = "document.getElementById('watch_attribute_determiner_" + attNumr + "')";
				var seID = eval(sID);
				seID.value = '';
				se.value = agntAry[0];
				se.className = 'd11a';
		}else{
			//alert('multiple results');
			var atdrs = "attribute_determiner_" + attNumr;
			var atdrsId = "watch_attribute_determiner_" + attNumr;
			var vS = "document.getElementById('" + atdrs + "').value";
			var v = eval(vS);
			//alert(v);
			getAgent(atdrsId,atdrs,'catalog',v);
		}
		
		/*
		
		
		
		
		*/
	}
}





function updateid_by () {
	//alert('fired updateid_by');
	//var theElement = 'id_by';
	var name = document.getElementById('id_by').value;
	//var id_by_id = document.getElementById('id_by_id').value;
	// neeed to use ID value instead of name if there's one - otherwise, parts (UAM) 
	// never manage to save (comes bask with UAM, UAM Herbarium, etc.)
	var collection_object_id = document.getElementById('collection_object_id').value;
	var agent_idFld = document.getElementById('watch_id_by');
	var agent_id = agent_idFld.value;
	if (agent_id.length == 0) {
		//alert(name);
		//alert('no ID');
		DWREngine._execute(_catalog_func, null, 'updateid_by', collection_object_id,name, success_updateid_by);
		//alert('gone');
	} else {
		//	alert('got ID');
		DWREngine._execute(_catalog_func, null, 'updateid_by_id', collection_object_id,agent_id, success_updateid_by);
		agent_idFld.value='';
	}
}


function success_updateid_by (result) {
	//alert(result);
	//if (result == 'spiffy') {
	//	var e = document.getElementById('id_by');
	//	e.className = 'd11a';
	//} else 
	if (result == 'Nothing matched.') {
		alert(result);
	} else if (result == 'A database error occured! Identifier has not been saved.') {
		alert(result);
	} else {
		// check for multiple matches
		nameArray = result.split('|');
		if (nameArray.length == 1) {
			var e = document.getElementById('id_by');
			var eID = document.getElementById('watch_id_by');
			eID.value='';
			e.value = result;
			//alert(result);
			e.className = 'd11a';
		} else{
			
			//alert('popup time');
			var e = document.getElementById('id_by').value;
			var eID = document.getElementById('watch_id_by');
			eID.value='';			
			getAgent('watch_id_by','id_by','catalog',e);
		}
	}
}


function upDispn (dispn) {
	//alert(remark);
	var collection_object_id = document.getElementById('collection_object_id').value;
	DWREngine._execute(_catalog_func, null, 'upDispn', collection_object_id,dispn, success_upDispn);	
	//alert('gone');
}
function success_upDispn(result){
	//alert(result);
	if (result == 'success') {
		var s = document.getElementById('coll_obj_disposition');
		//var se = eval(s);
		s.className = 'd11a';
	} else {
		alert(result);
	}
}
function upRemarks (remark) {
	//alert(remark);
	var collection_object_id = document.getElementById('collection_object_id').value;
	//var remark = document.getElementById('coll_object_remarks').value;
	//var remark='asaglkjash';
	remark = remark.replace(/#/g,"##");
	//alert(collection_object_id + ' ' + remark + 'new');
	DWREngine._execute(_catalog_func, null, 'upRemarks', collection_object_id,remark, success_upRemarks);	
	//alert('gone');
}
function success_upRemarks(result){
	//alert(result);
	if (result == 'success') {
		var s = document.getElementById('coll_object_remarks');
		//var se = eval(s);
		s.className = 'd11a';
	} else {
		alert(result);
	}
}
function saveNewAtt(){
	//alert('new');
	var collection_object_id = document.getElementById('collection_object_id').value;
	var attribute_type = document.getElementById('attribute_type_n').value;
	var attribute_value = document.getElementById('attribute_value_n').value;
	if (document.getElementById('attribute_units_n')) {
		var attribute_units = document.getElementById('attribute_units_n').value;
	} else {
		var attribute_units = '';
	}
	var attribute_date = document.getElementById('attribute_date_n').value;
	var attribute_determiner = document.getElementById('attribute_determiner_n').value;
	var attribute_determiner_id = document.getElementById('attribute_determiner_id_n').value;
	
	var attribute_det_meth = document.getElementById('attribute_det_meth_n').value;
	var attribute_remarks = document.getElementById('attribute_remarks_n').value;
	//alert('new');
	DWREngine._execute(_catalog_func, null, 'saveNewAtt', collection_object_id,attribute_type,attribute_value,attribute_units,attribute_date,attribute_determiner,attribute_determiner_id,attribute_det_meth,attribute_remarks, success_saveNewAtt);			
}




function success_saveNewAtt (result){
	//var result="12345678|Dusty L. McDonald|2072|ear from notch|12|m||1 jan 2005|finger";
	var numberOfAttributes = document.getElementById('numberOfAttributes').value;
	pArray = result.split("|");
	var attributeID = pArray[0];
	var att_determiner = pArray[1];
	var att_det_id = pArray[2];
	var att_type = pArray[3];
	var att_value = pArray[4];
	var att_units = pArray[5];
	var att_remark = pArray[6];
	var att_date = pArray[7];
	var att_det_meth = pArray[8];
	
	var theTable = document.getElementById('attrTbod');
	var nRow = document.createElement("TR");
	var attCell = document.createElement("TD");
	var attValCell = document.createElement("TD");
	var attUnitCell = document.createElement("TD");
	var attRemCell = document.createElement("TD");
	var attDateCell = document.createElement("TD");
	var attMethCell = document.createElement("TD");
	var attDetrCell = document.createElement("TD");
	var atDelCell = document.createElement("TD");
		
	theTable.appendChild(nRow);
		nRow.appendChild(attCell);
		nRow.appendChild(attValCell);
		nRow.appendChild(attUnitCell);
		nRow.appendChild(attRemCell);
		nRow.appendChild(attDateCell);
		nRow.appendChild(attMethCell);
		nRow.appendChild(attDetrCell);
		nRow.appendChild(atDelCell);
	
	var pid = "attribute_id_" + numberOfAttributes;
	var attIDInp = document.createElement("input");
	attIDInp.setAttribute("name",pid);
	attIDInp.setAttribute("id",pid);
	attIDInp.setAttribute("type","hidden");
	attIDInp.value = attributeID;
	attCell.appendChild(attIDInp);
	
	var thisElement = document.createElement("input");
	var thisName = "attribute_type_" + numberOfAttributes;
	thisElement.setAttribute("name",thisName);
	thisElement.setAttribute("id",thisName);
	thisElement.setAttribute("readonly","readonly");
	thisElement.value = att_type;
	thisElement.className="d11a readClr" ;
	attCell.appendChild(thisElement);
	
	var thisElement = document.createElement("input");
	var thisName = "attribute_value_" + numberOfAttributes;
	thisElement.setAttribute("name",thisName);
	thisElement.setAttribute("id",thisName);
	thisElement.value = att_value;
	thisElement.className="d11a reqdClr" ;
	attValCell.appendChild(thisElement);
	
	var thisElement = document.createElement("input");
	var thisName = "attribute_units_" + numberOfAttributes;
	thisElement.setAttribute("name",thisName);
	thisElement.setAttribute("id",thisName);
	thisElement.value = att_units;
	thisElement.className="d11a reqdClr" ;
	attUnitCell.appendChild(thisElement);
	
	var thisElement = document.createElement("input");
	var thisName = "attribute_remark_" + numberOfAttributes;
	thisElement.setAttribute("name",thisName);
	thisElement.setAttribute("id",thisName);
	thisElement.value = att_remark;
	thisElement.className="d11a" ;
	attRemCell.appendChild(thisElement);
	
	var thisElement = document.createElement("input");
	var thisName = "att_det_date_" + numberOfAttributes;
	thisElement.setAttribute("name",thisName);
	thisElement.setAttribute("id",thisName);
	thisElement.value = att_date;
	thisElement.className="d11a" ;
	attDateCell.appendChild(thisElement);
	
	var thisElement = document.createElement("input");
	var thisName = "determination_method_" + numberOfAttributes;
	thisElement.setAttribute("name",thisName);
	thisElement.setAttribute("id",thisName);
	thisElement.value = att_det_meth;
	thisElement.className="d11a" ;
	attMethCell.appendChild(thisElement);
	
	var thisElement = document.createElement("input");
	var thisName = "attribute_determiner_" + numberOfAttributes;
	thisElement.setAttribute("name",thisName);
	thisElement.setAttribute("id",thisName);
	thisElement.value = att_determiner;
	thisElement.className="d11a reqdClr" ;
	attDetrCell.appendChild(thisElement);
	
	var oc = "delAtt(" + numberOfAttributes + ")";
	var thisElement = document.createElement("img");
	thisElement.setAttribute("src","/images/del.gif");
	thisElement.setAttribute("onclick",oc);
	
	thisElement.className="likeLink" ;
	atDelCell.appendChild(thisElement);
	
	var na = document.getElementById('numberOfAttributes');
	na.value = numberOfAttributes + 1;
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
	//alert('resType:' + resType);
	// second line is the element we changed
	var theEl=result[1].V;
	//alert('theEl '+ theEl);
	// get rid of the funky BG
	var optn = document.getElementById(theEl);
	optn.style.backgroundColor='';
	var n=result.length;
	
	var theNumber = "n";
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
	} else if (resType == 'NONE') {
		// either no control attribute or we got an error
		var theDivName = "attribute_value_cell_" + theNumber;
		var theTextDivName = "attribute_units_cell_" + theNumber;
		theSelectName = "attribute_value_" + theNumber;
		theTextName = "attribute_units_" + theNumber;
	} else {
	//oops
	alert('Something bad happened! Try selecting nothing, then re-selecting an attribute or reloading this page');
	}
	var theDiv = document.getElementById(theDivName);
	var theText = document.getElementById(theTextDivName);
	theDiv.innerHTML = ''; // clear it out
	theText.innerHTML = '';
	
	if (resType == 'value' || resType == 'units') {
		
	//alert('resType: ' + resType);
		
	
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
		//alert('no control');
		var theNewText = document.createElement('INPUT');
				theNewText.name = theSelectName;
				theNewText.id = theSelectName;	
				theNewText.type="text";
				theNewText.style.width='95px';
				theNewText.className = "d11a";
				theDiv.appendChild(theNewText);
	}
	
	
	
	/*
	//alert(theDivName);
	// clear the div out IF we got a value or units result set
	//alert(resType);
	var theDiv = document.getElementById(theDivName);
	var theText = document.getElementById(theTextDivName);
	
	
	
	document
		
		
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
		*/

	// focus cursor 
	//alert(nf);
	//var nf = document.getElementById("attribute_value_n");
	//
	//nf.focus();
}


function saveNewId() {
	var collection_object_id = document.getElementById('collection_object_id').value;
	var taxon_id = document.getElementById('newTaxonNameId').value;
	var identifier_id = document.getElementById('newIdById').value;
	var id_date = document.getElementById('newIDDate').value;
	var nature = document.getElementById('newNature').value;
	var remark = document.getElementById('newIdRemark').value;
	var sciname = document.getElementById('newID').value;
	var identifier = document.getElementById('newIDBy').value;
	DWREngine._execute(_catalog_func, null, 'saveNewId', collection_object_id,taxon_id,identifier_id,id_date,nature,remark, sciname,identifier,success_saveNewId);
					
						
}
function success_saveNewId(result){
	//alert(result);
	resArray = result.split("|");
	var taxon_name_id = resArray[0];
	//alert(taxon_name_id);
	if (taxon_name_id>0) {
		// success
		var scientific_name = document.getElementById('scientific_name');
		var id_by = document.getElementById('id_by');
		var made_date = document.getElementById('made_date');
		var nature_of_id = document.getElementById('nature_of_id');
		var identification_remarks = document.getElementById('identification_remarks');
			
		var id_date = resArray[1];
		var nature = resArray[2];
		var remark = resArray[3];
		var sciname = resArray[4];
		var identifier = resArray[5];
		
		scientific_name.value = sciname;
		id_by.value = identifier;
		made_date.value = id_date;
		nature_of_id.value = nature;
		identification_remarks.value = remark;
			
		var ftaxon_id = document.getElementById('newTaxonNameId');
		var fidentifier_id = document.getElementById('newIdById');
		var fid_date = document.getElementById('newIDDate');
		var fnature = document.getElementById('newNature');
		var fremark = document.getElementById('newIdRemark');
		var fsciname = document.getElementById('newID');
		var fidentifier = document.getElementById('newIDBy');
		
		ftaxon_id.value = '';
		fidentifier_id.value = '';
		fid_date.value = '';
		fnature.value = '';
		fremark.value = '';
		fsciname.value = '';
		fidentifier.value = '';
		
	} else{
		alert(result);
	}
	/*
	<cfset result = "#taxon_id#|#identifier_id#|#id_date#|##|##|##|##">
	
	*/
}


function IsNumeric(sText)

{
   var ValidChars = "0123456789.";
   var IsNumber=true;
   var Char;

 
   for (i = 0; i < sText.length && IsNumber == true; i++) 
      { 
      Char = sText.charAt(i); 
      if (ValidChars.indexOf(Char) == -1) 
         {
         IsNumber = false;
         }
      }
   return IsNumber;
   
   }
  function removeChildrenFromNode(node)
{
   if(node !== undefined &&
        node !== null)
   {
      return;
   }
   
   var len = node.childNodes.length;
   
	while (node.hasChildNodes())
	{
	  node.removeChild(node.firstChild);
	}
}




function upPartLabel(i) {
	//	alert(i);
	var s = "document.getElementById('partID_" + i + "').value";
	var partID = eval(s);
	var b = "document.getElementById('label_" + i + "').value";
	var label = eval(b);
	//alert(attribute_id);
	//alert(attribute_remark);
	//alert(barcode);
	if (label.length > 0) {
		//alert(barcode);
		DWREngine._execute(_catalog_func, null, 'upPartLabel', partID,i,label, success_upPartLabel);
	} else {
		alert('Use barcode 0 to remove this part from it\'s current container.');
	}
}
function success_upPartLabel(result) {
	//alert(result);
	if (result == 'Container not found.' || result == 'A database error occured!'){
		alert(result);
	} else if (result.indexOf('|') > 0){
		
		rAry = result.split("|");
		var rowid = rAry[0];
		var label = rAry[1];
		var barcode = rAry[2];
		var ls = "document.getElementById('label_" + rowid + "')";
		var l = eval(ls);
		l.value = label;
		var bc = "document.getElementById('barcode_" + rowid + "')";
		var b = eval(bc);
		b.value = barcode;
		l.className = 'd11a';
	} else{
		alert("An unknow error occured: " + result);		
	}
	/*
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('print_fg_" + result + "')";
		var se = eval(s);
		se.className = 'd11a';
	} else {
		alert(result);
	}
	*/
}
function upPrintFg(i) {
	//	alert(i);
	var s = "document.getElementById('partID_" + i + "').value";
	var partID = eval(s);
	var v = "document.getElementById('print_fg_" + i + "').value";
	var print_fg = eval(v);
	var b = "document.getElementById('barcode_" + i + "').value";
	var barcode = eval(b);
	//alert(attribute_id);
	//alert(attribute_remark);
	//alert(barcode);
	if (barcode.length > 0) {
		//alert(barcode);
		DWREngine._execute(_catalog_func, null, 'upPrintFg', partID,i,print_fg,barcode, success_upPrintFg);
	} else {
		alert('You must put the part in a container before you flag it for printing.');
	}
}
function success_upPrintFg(result) {
	//alert(result);
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('print_fg_" + result + "')";
		var se = eval(s);
		se.className = 'd11a';
	} else {
		alert(result);
	}
}
function upPartRemk(i) {
	//	alert(i);
	var s = "document.getElementById('partID_" + i + "').value";
	var partID = eval(s);
	var v = "document.getElementById('part_remark_" + i + "').value";
	var part_remark = eval(v);
	//alert(attribute_id);
	//alert(attribute_remark);
	DWREngine._execute(_catalog_func, null, 'upPartRemk', partID,i,part_remark, success_upPartRemk);
}
function success_upPartRemk(result) {
	//alert(result);
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('part_remark_" + result + "')";
		var se = eval(s);
		se.className = 'd11a';
	} else {
		alert(result);
	}
}
function upPartCount(i) {
	//	alert(i);
	var s = "document.getElementById('partID_" + i + "').value";
	var partID = eval(s);
	var v = "document.getElementById('part_count_" + i + "').value";
	var part_count = eval(v);
	//alert(attribute_id);
	//alert(attribute_remark);
	DWREngine._execute(_catalog_func, null, 'upPartCount', partID,i,part_count, success_upPartCount);
}
function success_upPartCount(result) {
	//alert(result);
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('part_count_" + result + "')";
		var se = eval(s);
		se.className = 'd11a';
	} else {
		alert(result);
	}
}
function upPartCond(i) {
	//	alert(i);
	var s = "document.getElementById('partID_" + i + "').value";
	var partID = eval(s);
	var v = "document.getElementById('part_condition_" + i + "').value";
	var part_condition = eval(v);
	//alert(attribute_id);
	//alert(attribute_remark);
	DWREngine._execute(_catalog_func, null, 'upPartCond', partID,i,part_condition, success_upPartCond);
}
function success_upPartCond(result) {
	//alert(result);
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('part_condition_" + result + "')";
		var se = eval(s);
		se.className = 'd11a';
	} else {
		alert(result);
	}
}
function upPartDisp(i) {
	//	alert(i);
	var s = "document.getElementById('partID_" + i + "').value";
	var partID = eval(s);
	var v = "document.getElementById('part_disposition_" + i + "').value";
	var part_disposition = eval(v);
	//alert(attribute_id);
	//alert(attribute_remark);
	DWREngine._execute(_catalog_func, null, 'upPartDisp', partID,i,part_disposition, success_upPartDisp);
}
function success_upPartDisp(result) {
	//alert(result);
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('part_disposition_" + result + "')";
		var se = eval(s);
		se.className = 'd11a';
	} else {
		alert(result);
	}
}



function upPartName(i) {
	//	alert(i);
	var s = "document.getElementById('partID_" + i + "').value";
	var partID = eval(s);
	var v = "document.getElementById('part_name_" + i + "').value";
	var part_name = eval(v);
	//alert(attribute_id);
	//alert(attribute_remark);
	DWREngine._execute(_catalog_func, null, 'upPartName', partID,i,part_name, success_upPartName);
}
function success_upPartName(result) {
	//alert(result);
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('part_name_" + result + "')";
		var se = eval(s);
		se.className = 'd11a';
	} else {
		alert(result);
	}
}




function updateAf(af) {
	var theElement = 'af_num';
	var e = document.getElementById(theElement);
	var collection_object_id = document.getElementById('collection_object_id').value;
	e.className = 'saving';
	if (!IsNumeric(af)) {
			alert('AF must be numeric!')
			abort();
	}
	//alert(af);
	DWREngine._execute(_catalog_func, null, 'updateAf', collection_object_id,af, success_updateAf);
}
function success_updateAf (result) {
	//alert(result);
	if (result < 999999999) {
		// spiffy
		var theElement = 'af_num';
		var e = document.getElementById(theElement);
		e.className = 'd11a';
	} else {
		alert('AF Save was not successful!');
	}
}
function updateSciName() {
	var theElement = 'scientific_name';
	var e = document.getElementById(theElement).value;
	var collection_object_id = document.getElementById('collection_object_id').value;
	//alert(e);
	DWREngine._execute(_catalog_func, null, 'updateSciName', collection_object_id,e, success_updateSciName);
}
function success_updateSciName (result) {
	if (result == 'success') {
		var e = document.getElementById('scientific_name');
		e.className = 'd11a';
	} else {
		alert(result);
	}
}


function updateimade_date(name) {
	//alert(name);
	var collection_object_id = document.getElementById('collection_object_id').value;
	//alert(e);
	DWREngine._execute(_catalog_func, null, 'updateimade_date', collection_object_id,name, success_updateimade_date);
}
function success_updateimade_date(result) {
	if (result == 'success') {
		document.getElementById('made_date').className = 'd11a';
	} else {
		alert(result);
	}	
}

function updateNature(nature) {
	//alert(name);
	var collection_object_id = document.getElementById('collection_object_id').value;
	//alert(e);
	DWREngine._execute(_catalog_func, null, 'updateNature', collection_object_id,nature, success_updateNature);
	//alert(name);
}
function success_updateNature(result) {
	if (result == 'success') {
		document.getElementById('nature_of_id').className = 'd11a';
	} else {
		alert(result);
	}	
}
function updateidremk(remark) {
		//alert(name);
	var collection_object_id = document.getElementById('collection_object_id').value;
	//alert(e);
	DWREngine._execute(_catalog_func, null, 'updateidremk', collection_object_id,remark, success_updateidremk);
}
function success_updateidremk(result) {
	if (result == 'success') {
		document.getElementById('identification_remarks').className = 'd11a';
	} else {
		alert(result);
	}	
}


function changeAttValue(i) {
		//alert(name);
	var s = "document.getElementById('attribute_id_" + i + "').value";
	var attribute_id = eval(s);
	var v = "document.getElementById('attribute_value_" + i + "').value";
	var attribute_value = eval(v);
	//alert(attribute_id);
	//alert(attribute_value);
	//alert(e);
	DWREngine._execute(_catalog_func, null, 'changeAttValue', attribute_id,i,attribute_value, success_changeAttValue);
}
function success_changeAttValue(result) {
	//alert(result);
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('attribute_value_" + result + "')";
		var se = eval(s);
		se.className = 'reqdClr d11a';
	} else {
		alert(result);
	}
}


function changeAttUnit(i) {
		//alert(name);
	var s = "document.getElementById('attribute_id_" + i + "').value";
	var attribute_id = eval(s);
	var v = "document.getElementById('attribute_units_" + i + "').value";
	var attribute_units = eval(v);
	//alert(attribute_id);
	//alert(attribute_value);
	//alert(e);
	DWREngine._execute(_catalog_func, null, 'changeAttUnit', attribute_id,i,attribute_units, success_changeAttUnit);
}
function success_changeAttUnit(result) {
	//alert(result);
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('attribute_units_" + result + "')";
		var se = eval(s);
		se.className = 'reqdClr d11a';
	} else {
		alert(result);
	}
}
function changeAttRemk(i) {
	//	alert(i);
	var s = "document.getElementById('attribute_id_" + i + "').value";
	var attribute_id = eval(s);
	var v = "document.getElementById('attribute_remark_" + i + "').value";
	var attribute_remark = eval(v);
	//alert(attribute_id);
	//alert(attribute_remark);
	DWREngine._execute(_catalog_func, null, 'changeAttRemk', attribute_id,i,attribute_remark, success_changeAttRemk);
}
function success_changeAttRemk(result) {
	//alert(result);
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('attribute_remark_" + result + "')";
		var se = eval(s);
		se.className = 'reqdClr d11a';
	} else {
		alert(result);
	}
}

function changeAttDate(i) {
	//	alert(i);
	var s = "document.getElementById('attribute_id_" + i + "').value";
	var attribute_id = eval(s);
	var v = "document.getElementById('att_det_date_" + i + "').value";
	var attribute_date = eval(v);
	//alert(attribute_id);
	//alert(attribute_remark);
	DWREngine._execute(_catalog_func, null, 'changeAttDate', attribute_id,i,attribute_date, success_changeAttDate);
}
function success_changeAttDate(result) {
	//alert(result);
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('att_det_date_" + result + "')";
		var se = eval(s);
		se.className = 'd11a';
	} else {
		alert(result);
	}
}

function changeAttDetMeth(i) {
	//	alert(i);
	var s = "document.getElementById('attribute_id_" + i + "').value";
	var attribute_id = eval(s);
	var v = "document.getElementById('determination_method_" + i + "').value";
	var attribute_detmeth = eval(v);
	//alert(attribute_id);
	//alert(attribute_remark);
	DWREngine._execute(_catalog_func, null, 'changeAttDetMeth', attribute_id,i,attribute_detmeth, success_changeAttDetMeth);
}
function success_changeAttDetMeth(result) {
	//alert(result);
	if (IsNumeric(result)) {
		// got a rownumber back
		var s = "document.getElementById('determination_method_" + result + "')";
		var se = eval(s);
		se.className = 'd11a';
	} else {
		alert(result);
	}
}



function delAtt(i) {
	//	alert(i);
	var s = "document.getElementById('attribute_id_" + i + "').value";
	var attribute_id = eval(s);
	var v = "document.getElementById('attribute_type_" + i + "').value";
	var attribute = eval(v);
	//alert(attribute_id);
	//alert(attribute_remark);
	var d = confirm("Delete attribute " + attribute + "?");
	if (d == true){
		DWREngine._execute(_catalog_func, null, 'delAtt', attribute_id,i, success_delAtt);
	} 
	//
}
function success_delAtt(result) {
	//alert(result);
	if (IsNumeric(result)) {
		//alert('cleanup');
		// got a rownumber back
		var s = "document.getElementById('attribute_type_" + result + "')";
		var se = eval(s);
		se.className = 'saving';
		se.value = '---deleted---';
	} else {
		alert(result);
	}
}

function delPart(i) {
	//	alert(i);
	var s = "document.getElementById('partID_" + i + "').value";
	var partID = eval(s);
	var v = "document.getElementById('part_name_" + i + "').value";
	var part = eval(v);
	//alert(attribute_id);
	//alert(attribute_remark);
	var d = confirm("Delete part " + part + "?");
	if (d == true){
		DWREngine._execute(_catalog_func, null, 'delPart', partID,i, success_delPart);
	} 
	//
}
function success_delPart(result) {
	//alert(result);
	if (IsNumeric(result)) {
		//alert('cleanup');
		// got a rownumber back
		var s = "document.getElementById('part_name_" + result + "')";
		var se = eval(s);
		se.options.length=0;
		se.options[0]=new Option("--DELETED--", "")
		se.className = 'saving';
	} else {
		alert(result);
	}
}
function newpart() {
	//alert('makin a new part');
	var part_name = document.getElementById('part_name_n').value;
	var part_disposition = document.getElementById('part_disposition_n').value;
	var part_condition = document.getElementById('part_condition_n').value;
	var part_count = document.getElementById('part_count_n').value;
	var label = document.getElementById('label_n').value;
	var print_fg = document.getElementById('print_fg_n').value;
	var part_remark = document.getElementById('part_remark_n').value;
	var collection_object_id = document.getElementById('collection_object_id').value;

	if (part_name.length < 1 || part_condition.length < 1 || part_count.length < 1) {
		alert('Part Name, Condition and Count are required.');
	} else {
		DWREngine._execute(_catalog_func, null, 'newpart', collection_object_id,part_name,part_disposition,part_condition,part_count,label,print_fg,part_remark, success_newpart);
		//alert('somethin should happen bout now.....');
	}
}

function success_newpart(result) {
	//alert('something happened');
	var numberOfParts = document.getElementById('numberOfParts').value;
	pArray = result.split("|");
	var partID = pArray[0];
	var part_name = pArray[1];
	if (partID < 0) {
		alert(part_name);
	} else {
	
	var disposition = pArray[2];
	var condition = pArray[3];
	var lcount = pArray[4];
	var label = pArray[5];
	var barcode = pArray[6];
	var pfg = pArray[7];
	var remk = pArray[8];
	var theTable = document.getElementById('partTable');
	var nRow = document.createElement("TR");
	var pNameCell = document.createElement("TD");
	var pDispCell = document.createElement("TD");
	var pCondCell = document.createElement("TD");
	var pCountCell = document.createElement("TD");
	var pLabelCell = document.createElement("TD");
	var pFlagCell = document.createElement("TD");
	var pRemarkCell = document.createElement("TD");
	var delBtnCell = document.createElement("TD");
		
	theTable.appendChild(nRow);
		nRow.appendChild(pNameCell);
		nRow.appendChild(pDispCell);
		nRow.appendChild(pCondCell);
		nRow.appendChild(pCountCell);
		nRow.appendChild(pLabelCell);
		nRow.appendChild(pFlagCell);
		nRow.appendChild(pRemarkCell);
		nRow.appendChild(delBtnCell);
	
	var pid = "partID_" + numberOfParts;
	var partIdInput = document.createElement("input");
	partIdInput.setAttribute("name",pid);
	partIdInput.setAttribute("id",pid);
	partIdInput.setAttribute("type","hidden");
	partIdInput.value = partID;
	pNameCell.appendChild(partIdInput);
	
	var partnameSelect = document.createElement("select");
	var psn = "part_name_" + numberOfParts;
	partnameSelect.setAttribute("name",psn);
	partnameSelect.setAttribute("id",psn);
	var pnvs = document.getElementById('part_name_list').value;
	var pnArray = pnvs.split("|");
	for (i=0;i<pnArray.length;i++) {
			//alert(pnArray[i]);
			partnameSelect.options[i] = new Option(pnArray[i],pnArray[i]);
	}
	partnameSelect.options[0] = null;
	partnameSelect.value = part_name;
	partnameSelect.className="d11a reqdClr" ;
	ocstr = "this.className='saving';upPartName(" + numberOfParts + ")";
	partnameSelect.setAttribute("onchange",ocstr);
	pNameCell.appendChild(partnameSelect);
	

	var dispSelect = document.createElement("select");
	var dsn = "part_disposition_" + numberOfParts;
	dispSelect.setAttribute("name",dsn);
	dispSelect.setAttribute("id",dsn);
	var pnvs = document.getElementById('disp_list').value;
	var pnArray = pnvs.split("|");
	for (i=0;i<pnArray.length;i++) {
			//alert(pnArray[i]);
			dispSelect.options[i] = new Option(pnArray[i],pnArray[i]);
	}	
	dispSelect.options[0] = null;
	dispSelect.value = disposition;
	dispSelect.className="d11a reqdClr" ;	
	ocstr = "this.className='saving';upPartDisp(" + numberOfParts + ")";
	dispSelect.setAttribute("onchange",ocstr);
	pDispCell.appendChild(dispSelect);
	
	var condInp = document.createElement("input");
	var cdn = "part_condition_" + numberOfParts;
	condInp.setAttribute("name",cdn);
	condInp.setAttribute("id",cdn);
	condInp.value = condition;
	condInp.className="d11a reqdClr" ;
	condInp.setAttribute("type","text");
	ocstr = "this.className='saving';upPartCond(" + numberOfParts + ")";
	condInp.setAttribute("onchange",ocstr);
	pCondCell.appendChild(condInp);
	
	var lcInp = document.createElement("input");
	var lcn = "part_count_" + numberOfParts;
	lcInp.setAttribute("name",lcn);
	lcInp.setAttribute("id",lcn);
	lcInp.setAttribute("size","1");
	lcInp.value = lcount;
	lcInp.className="d11a reqdClr" ;
	lcInp.setAttribute("type","text");
	ocstr = "this.className='saving';upPartCount(" + numberOfParts + ")";
	lcInp.setAttribute("onchange",ocstr);
	pCountCell.appendChild(lcInp);
	
	var barInp = document.createElement("input");
	var bcn = "barcode_" + numberOfParts;
	barInp.setAttribute("name",bcn);
	barInp.setAttribute("id",bcn);
	barInp.value = barcode;
	barInp.setAttribute("type","hidden");
	pLabelCell.appendChild(barInp);
	
	var lblInp = document.createElement("input");
	var lbn = "label_" + numberOfParts;
	lblInp.setAttribute("name",lbn);
	lblInp.setAttribute("id",lbn);
	lblInp.value = label;
	lblInp.className="d11a" ;
	lblInp.setAttribute("type","text");
	ocstr = "this.className='saving';upPartLabel(" + numberOfParts + ")";
	lblInp.setAttribute("onchange",ocstr);
	pLabelCell.appendChild(lblInp);
	
	var pfInp = document.createElement("select");
	var pfn = "print_fg_" + numberOfParts;
	pfInp.setAttribute("name",pfn);
	pfInp.setAttribute("id",pfn);
	pfInp.options[0] = new Option("","");
	pfInp.options[1] = new Option("Box","1");
	pfInp.options[2] = new Option("Vial","2");
	pfInp.value = pfg;
	pfInp.className="d11a" ;	
	ocstr = "this.className='saving';upPrintFg(" + numberOfParts + ")";
	pfInp.setAttribute("onchange",ocstr);
	pFlagCell.appendChild(pfInp);
	
	var rmkInp = document.createElement("input");
	var rmn = "part_remark_" + numberOfParts;
	rmkInp.setAttribute("name",rmn);
	rmkInp.setAttribute("id",rmn);
	rmkInp.value = remk;
	rmkInp.className="d11a" ;
	rmkInp.setAttribute("type","text");	
	ocstr = "this.className='saving';upPartRemk(" + numberOfParts + ")";
	rmkInp.setAttribute("onchange",ocstr);
	pRemarkCell.appendChild(rmkInp);
	
	var delImg = document.createElement("img");
	delImg.setAttribute("src","/images/del.gif");
	delImg.className="likeLink" ;
	ocstr = "delPart(" + numberOfParts + ")";
	delImg.setAttribute("onclick",ocstr);
	delBtnCell.appendChild(delImg);
	
	// update the parts count
	var pc = document.getElementById('numberOfParts');
	pc.value = numberOfParts + 1;
	} // end else for got good partID
}






