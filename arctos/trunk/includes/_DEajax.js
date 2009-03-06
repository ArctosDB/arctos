setInterval ( "checkPicked()", 5000 );
setInterval ( "checkPickedEvnt()", 5000 );
function checkPicked(){
	var locality_id=document.getElementById('locality_id');
	if (locality_id.value.length>0){
		pickedLocality();
	}	
}
function checkPickedEvnt(){
	var collecting_event_id=document.getElementById('collecting_event_id');
	if (collecting_event_id.value.length>0){
		pickedEvent();
	}	
}			
function rememberLastOtherId (yesno) {
	DWREngine._execute(_data_entry_func, null, 'rememberLastOtherId', yesno,success_rememberLastOtherId);
}
function success_rememberLastOtherId (yesno) {
	var theSpan = document.getElementById('rememberLastId');
	if (yesno==0){
		theSpan.innerHTML='<span class="infoLink" onclick="rememberLastOtherId(1)">Increment This</span>';
	} else if (yesno == 1) {
		theSpan.innerHTML='<span class="infoLink" onclick="rememberLastOtherId(0)">Nevermind</span>';
	} else {
		alert('Something goofy happened. Remembering your next Other ID may not have worked.');
	}	
}

function isGoodAccn () {
	var accn = document.getElementById('accn').value;
	var institution_acronym = document.getElementById('institution_acronym').value;
	//alert('accn: ' + accn + 'ia: ' + institution_acronym);
	DWREngine._execute(_data_entry_func, null, 'is_good_accn', accn, institution_acronym,success_isGoodAccn);
	return null;
}
function success_isGoodAccn (result) {
	var accn = document.getElementById('accn');
	//alert(result);
	if (result == 1) {
		//alert('spiffy');
		accn.className = 'd11a reqdClr';
	} else if (result == 0) {
		alert('You must enter a valid, pre-existing accn.');
		accn.className = 'hasProbs';
	} else {
		alert('An error occured while validating accn. \nYou must enter a valid, pre-existing accn.\n' + result );
		accn.className = 'hasProbs';
	}
}


function turnSaveOn () {
	//alert('tso');
	document.getElementById('localityPicker').style.display='none';
	document.getElementById('localityUnPicker').style.display='none';
	//document.getElementById('pickedSomething').style.display='block';
}
function unpickEvent() {
	document.getElementById('collecting_event_id').value='';
	document.getElementById('locality_id').value='';
	document.getElementById('began_date').className='d11a reqdClr';
	document.getElementById('began_date').removeAttribute('readonly');
	
	document.getElementById('ended_date').className='d11a reqdClr';
	document.getElementById('ended_date').removeAttribute('readonly');
	
	document.getElementById('verbatim_date').className='d11a reqdClr';
	document.getElementById('verbatim_date').removeAttribute('readonly');
	
	document.getElementById('coll_event_remarks').className='d11a';
	document.getElementById('coll_event_remarks').removeAttribute('readonly');
	
	document.getElementById('collecting_source').className='d11a reqdClr';
	document.getElementById('collecting_source').removeAttribute('readonly');
	
	document.getElementById('collecting_method').className='d11a';
	document.getElementById('collecting_method').removeAttribute('readonly');
	
	document.getElementById('habitat_desc').className='d11a';
	document.getElementById('habitat_desc').removeAttribute('readonly');
	
	document.getElementById('eventUnPicker').style.display='none';
	document.getElementById('eventPicker').style.display='';
	
	unpickLocality();
}						
function unpickLocality () {
	var u = document.getElementById('orig_lat_long_units').value;
	switchActive(u);
	document.getElementById('higher_geog').className='d11a reqdClr';
	document.getElementById('higher_geog').removeAttribute('readonly');
	document.getElementById('maximum_elevation').className='d11a';
	document.getElementById('maximum_elevation').removeAttribute('readonly');
	document.getElementById('minimum_elevation').className='d11a';
	document.getElementById('minimum_elevation').removeAttribute('readonly');
	document.getElementById('orig_elev_units').className='d11a';
	document.getElementById('orig_elev_units').removeAttribute('readonly');
	document.getElementById('spec_locality').className='d11a reqdClr';
	document.getElementById('spec_locality').removeAttribute('readonly');
	document.getElementById('locality_remarks').className='d11a';
	document.getElementById('locality_remarks').removeAttribute('readonly');
	document.getElementById('latdeg').className='d11a reqdClr';
	document.getElementById('latdeg').removeAttribute('readonly');
	document.getElementById('decLAT_DEG').className='d11a reqdClr';
	document.getElementById('decLAT_DEG').removeAttribute('readonly');
	document.getElementById('latmin').className='d11a reqdClr';
	document.getElementById('latmin').removeAttribute('readonly');
	document.getElementById('latsec').className='d11a reqdClr';
	document.getElementById('latsec').removeAttribute('readonly');
	document.getElementById('latdir').className='d11a reqdClr';
	document.getElementById('latdir').removeAttribute('readonly');
	document.getElementById('longdeg').className='d11a reqdClr';
	document.getElementById('longdeg').removeAttribute('readonly');
	document.getElementById('longmin').className='d11a reqdClr';
	document.getElementById('longmin').removeAttribute('readonly');
	document.getElementById('longsec').className='d11a reqdClr';
	document.getElementById('longsec').removeAttribute('readonly');
	document.getElementById('longdir').className='d11a reqdClr';
	document.getElementById('longdir').removeAttribute('readonly');
	document.getElementById('dec_lat_min').className='d11a reqdClr';
	document.getElementById('dec_lat_min').removeAttribute('readonly');
	document.getElementById('decLAT_DIR').className='d11a reqdClr';
	document.getElementById('decLAT_DIR').removeAttribute('readonly');
	document.getElementById('decLONGDEG').className='d11a reqdClr';
	document.getElementById('decLONGDEG').removeAttribute('readonly');
	document.getElementById('dec_long_min').className='d11a reqdClr';
	document.getElementById('dec_long_min').removeAttribute('readonly');
	document.getElementById('decLONGDIR').className='d11a reqdClr';
	document.getElementById('decLONGDIR').removeAttribute('readonly');
	document.getElementById('dec_lat').className='d11a reqdClr';
	document.getElementById('dec_lat').removeAttribute('readonly');
	document.getElementById('dec_long').className='d11a reqdClr';
	document.getElementById('dec_long').removeAttribute('readonly');
	document.getElementById('max_error_distance').className='d11a';
	document.getElementById('max_error_distance').removeAttribute('readonly');
	document.getElementById('max_error_units').className='d11a';
	document.getElementById('max_error_units').removeAttribute('readonly');
	document.getElementById('extent').className='d11a';
	document.getElementById('extent').removeAttribute('readonly');
	document.getElementById('gpsaccuracy').className='d11a';
	document.getElementById('gpsaccuracy').removeAttribute('readonly');
	document.getElementById('datum').className='d11a reqdClr';
	document.getElementById('datum').removeAttribute('readonly');
	document.getElementById('determined_by_agent').className='d11a reqdClr';
	document.getElementById('determined_by_agent').removeAttribute('readonly');
	document.getElementById('determined_date').className='d11a reqdClr';
	document.getElementById('determined_date').removeAttribute('readonly');
	document.getElementById('lat_long_ref_source').className='d11a reqdClr';
	document.getElementById('lat_long_ref_source').removeAttribute('readonly');
	document.getElementById('georefmethod').className='d11a reqdClr';
	document.getElementById('georefmethod').removeAttribute('readonly');
	document.getElementById('verificationstatus').className='d11a reqdClr';
	document.getElementById('verificationstatus').removeAttribute('readonly');
	document.getElementById('lat_long_remarks').className='d11a';
	document.getElementById('lat_long_remarks').removeAttribute('readonly');
	document.getElementById('orig_lat_long_units').className='d11a';
	document.getElementById('orig_lat_long_units').removeAttribute('readonly');

	document.getElementById('locality_id').value='';
	
	document.getElementById('localityUnPicker').style.display='none';
	//document.getElementById('pickedSomething').style.display='none';	
	document.getElementById('localityPicker').style.display='';
	try {
		for (i=0;i<6;i++) {
			var eNum=parseInt(i+1);
			var aID='geology_attribute_' + eNum;
			var vID='geo_att_value_' + eNum;
			var dID='geo_att_determiner_' + eNum;
			var ddID='geo_att_determined_date_' + eNum;
			var mID='geo_att_determined_method_' + eNum;
			var rID='geo_att_remark_' + eNum;
			document.getElementById(aID).className='d11a reqdClr';
			document.getElementById(aID).removeAttribute('readonly');
			document.getElementById(vID).className='d11a reqdClr';
			document.getElementById(vID).removeAttribute('readonly');
			document.getElementById(dID).className='d11a';
			document.getElementById(dID).removeAttribute('readonly');
			document.getElementById(ddID).className='d11a';
			document.getElementById(ddID).removeAttribute('readonly');
			document.getElementById(mID).className='d11a';
			document.getElementById(mID).removeAttribute('readonly');
			document.getElementById(rID).className='d11a';
			document.getElementById(rID).removeAttribute('readonly');
		}
	} catch(err) {
		// whatever
	}

}
function pickedEvent () {
	var collecting_event_id = document.getElementById('collecting_event_id').value;
	if (collecting_event_id.length > 0) {
		document.getElementById('locality_id').value='';
		DWREngine._execute(_data_entry_func, null, 'get_picked_event', collecting_event_id, success_pickedEvent);
	}
}
function success_pickedEvent(result){
	if (result[0]) {
		var collecting_event_id=result[0].COLLECTING_EVENT_ID;
		if (collecting_event_id < 0) {
			alert('Oops! Something bad happend with the collecting_event pick. ' + result[0].MSG);
		} else {
			document.getElementById('locality_id').value='';
			var BEGAN_DATE = result[0].BEGAN_DATE;
			var ENDED_DATE = result[0].ENDED_DATE;
			var VERBATIM_DATE = result[0].VERBATIM_DATE;
			var VERBATIM_LOCALITY = result[0].VERBATIM_LOCALITY;
			var COLL_EVENT_REMARKS = result[0].COLL_EVENT_REMARKS;
			var COLLECTING_SOURCE = result[0].COLLECTING_SOURCE;
			var COLLECTING_METHOD = result[0].COLLECTING_METHOD;
			var HABITAT_DESC = result[0].HABITAT_DESC;
			
			document.getElementById('began_date').value = BEGAN_DATE;
			document.getElementById('began_date').className='d11a readClr';
			document.getElementById('began_date').setAttribute('readonly','readonly');
			
			document.getElementById('ended_date').value = ENDED_DATE;
			document.getElementById('ended_date').className='d11a readClr';
			document.getElementById('ended_date').setAttribute('readonly','readonly');
			
			document.getElementById('verbatim_date').value = VERBATIM_DATE;
			document.getElementById('verbatim_date').className='d11a readClr';
			document.getElementById('verbatim_date').setAttribute('readonly','readonly');
			
			document.getElementById('coll_event_remarks').value = COLL_EVENT_REMARKS;
			document.getElementById('coll_event_remarks').className='d11a readClr';
			document.getElementById('coll_event_remarks').setAttribute('readonly','readonly');
			
			document.getElementById('collecting_source').value = COLLECTING_SOURCE;
			document.getElementById('collecting_source').className='d11a readClr';
			document.getElementById('collecting_source').setAttribute('readonly','readonly');
			
			document.getElementById('collecting_method').value = COLLECTING_METHOD;
			document.getElementById('collecting_method').className='d11a readClr';
			document.getElementById('collecting_method').setAttribute('readonly','readonly');
			
			document.getElementById('habitat_desc').value = HABITAT_DESC;
			document.getElementById('habitat_desc').className='d11a readClr';
			document.getElementById('habitat_desc').setAttribute('readonly','readonly');
			
			document.getElementById('eventPicker').style.display='none';
			document.getElementById('eventUnPicker').style.display='';
			
			success_pickedLocality(result);
		}
	} else {
		var collecting_event_id = document.getElementById('collecting_event_id');
		alert(collecting_event_id.value + ' is not a valid collecting_event_id');
		collecting_event_id.value='';		
	}
}
function pickedLocality () {
	//alert('this is data entry pickedLocality');	
	var locality_id = document.getElementById('locality_id').value;
	var collecting_event_id = document.getElementById('collecting_event_id').value;
	if (collecting_event_id.length>0){
		alert('You cannot pick a locality and an event.');
		return false;
	}
	//alert(locality_id);
	if (locality_id.length > 0) {
		DWREngine._execute(_data_entry_func, null, 'get_picked_locality', locality_id, success_pickedLocality);
	}
}


function success_pickedLocality (result) {
	//alert('at success_pickedLocality: ' + result);
	if (result[0]) {
		var locality_id=result[0].LOCALITY_ID;
		if (locality_id < 0) {
			alert('Oops! Something bad happend with the locality pick. ' + result[0].MSG);
		} else {
			//alert('good');
			// "one" stuff will be in result[0]; need to loop for geology stuff
			var HIGHER_GEOG = result[0].HIGHER_GEOG;
			var MAXIMUM_ELEVATION = result[0].MAXIMUM_ELEVATION;
			var MINIMUM_ELEVATION = result[0].MINIMUM_ELEVATION;
			var ORIG_ELEV_UNITS = result[0].ORIG_ELEV_UNITS;
			var SPEC_LOCALITY = result[0].SPEC_LOCALITY;
			var LOCALITY_REMARKS = result[0].LOCALITY_REMARKS;
			var LAT_DEG = result[0].LAT_DEG;
			var DEC_LAT_MIN = result[0].DEC_LAT_MIN;
			var LAT_MIN = result[0].LAT_MIN;
			var LAT_SEC = result[0].LAT_SEC;
			var LAT_DIR = result[0].LAT_DIR;
			var LONG_DEG = result[0].LONG_DEG;
			var DEC_LONG_MIN = result[0].DEC_LONG_MIN;
			var LONG_MIN = result[0].LONG_MIN;
			var LONG_SEC = result[0].LONG_SEC;
			var LONG_DIR = result[0].LONG_DIR;
			var DEC_LAT = result[0].DEC_LAT;
			var DEC_LONG = result[0].DEC_LONG;		
			var DATUM = result[0].DATUM;
			var ORIG_LAT_LONG_UNITS = result[0].ORIG_LAT_LONG_UNITS;
			var DETERMINED_BY = result[0].DETERMINED_BY;
			var DETERMINED_DATE = result[0].DETERMINED_DATE;
			var LAT_LONG_REF_SOURCE = result[0].LAT_LONG_REF_SOURCE;
			var LAT_LONG_REMARKS = result[0].LAT_LONG_REMARKS;
			var MAX_ERROR_DISTANCE = result[0].MAX_ERROR_DISTANCE;
			var MAX_ERROR_UNITS = result[0].MAX_ERROR_UNITS;
			var EXTENT = result[0].EXTENT;
			var GPSACCURACY = result[0].GPSACCURACY;
			var GEOREFMETHOD = result[0].GEOREFMETHOD;
			var VERIFICATIONSTATUS = result[0].VERIFICATIONSTATUS;
			
			
			document.getElementById('higher_geog').value = HIGHER_GEOG;
			document.getElementById('higher_geog').className='d11a readClr';
			document.getElementById('higher_geog').setAttribute('readonly','readonly');
			
			document.getElementById('maximum_elevation').value = MAXIMUM_ELEVATION;
			document.getElementById('maximum_elevation').className='d11a readClr';
			document.getElementById('maximum_elevation').setAttribute('readonly','readonly');
			
			document.getElementById('minimum_elevation').value = MINIMUM_ELEVATION;
			document.getElementById('minimum_elevation').className='d11a readClr';
			document.getElementById('minimum_elevation').setAttribute('readonly','readonly');
			
			document.getElementById('orig_elev_units').value = ORIG_ELEV_UNITS;
			document.getElementById('orig_elev_units').className='d11a readClr';
			document.getElementById('orig_elev_units').setAttribute('readonly','readonly');
			
			document.getElementById('spec_locality').value = SPEC_LOCALITY;
			document.getElementById('spec_locality').className='d11a readClr';
			document.getElementById('spec_locality').setAttribute('readonly','readonly');
			
			document.getElementById('locality_remarks').value = LOCALITY_REMARKS;
			document.getElementById('locality_remarks').className='d11a readClr';
			document.getElementById('locality_remarks').setAttribute('readonly','readonly');
			
			document.getElementById('latdeg').value = LAT_DEG;
			document.getElementById('latdeg').className='d11a readClr';
			document.getElementById('latdeg').setAttribute('readonly','readonly');
			
			document.getElementById('decLAT_DEG').value = LAT_DEG;
			document.getElementById('decLAT_DEG').className='d11a readClr';
			document.getElementById('decLAT_DEG').setAttribute('readonly','readonly');
			
			document.getElementById('latmin').value = LAT_MIN;
			document.getElementById('latmin').className='d11a readClr';
			document.getElementById('latmin').setAttribute('readonly','readonly');
			
			document.getElementById('latsec').value = LAT_SEC;
			document.getElementById('latsec').className='d11a readClr';
			document.getElementById('latsec').setAttribute('readonly','readonly');
			
			document.getElementById('latdir').value = LAT_DIR;
			document.getElementById('latdir').className='d11a readClr';
			document.getElementById('latdir').setAttribute('readonly','readonly');
			
			document.getElementById('longdeg').value = LONG_DEG;
			document.getElementById('longdeg').className='d11a readClr';
			document.getElementById('longdeg').setAttribute('readonly','readonly');
			
			document.getElementById('longmin').value = LONG_MIN;
			document.getElementById('longmin').className='d11a readClr';
			document.getElementById('longmin').setAttribute('readonly','readonly');
			
			document.getElementById('longsec').value = LONG_SEC;
			document.getElementById('longsec').className='d11a readClr';
			document.getElementById('longsec').setAttribute('readonly','readonly');
			
			document.getElementById('longdir').value = LONG_DIR;
			document.getElementById('longdir').className='d11a readClr';
			document.getElementById('longdir').setAttribute('readonly','readonly');
			
			document.getElementById('dec_lat_min').value = DEC_LAT_MIN;
			document.getElementById('dec_lat_min').className='d11a readClr';
			document.getElementById('dec_lat_min').setAttribute('readonly','readonly');
			
			document.getElementById('decLAT_DIR').value = LAT_DIR;
			document.getElementById('decLAT_DIR').className='d11a readClr';
			document.getElementById('decLAT_DIR').setAttribute('readonly','readonly');
			
			document.getElementById('decLONGDEG').value = LONG_DEG;
			document.getElementById('decLONGDEG').className='d11a readClr';
			document.getElementById('decLONGDEG').setAttribute('readonly','readonly');
			
			document.getElementById('dec_long_min').value = DEC_LONG_MIN;
			document.getElementById('dec_long_min').className='d11a readClr';
			document.getElementById('dec_long_min').setAttribute('readonly','readonly');
			
			document.getElementById('decLONGDIR').value = LONG_DIR;
			document.getElementById('decLONGDIR').className='d11a readClr';
			document.getElementById('decLONGDIR').setAttribute('readonly','readonly');
			
			document.getElementById('dec_lat').value = DEC_LAT;
			document.getElementById('dec_lat').className='d11a readClr';
			document.getElementById('dec_lat').setAttribute('readonly','readonly');
			
			document.getElementById('dec_long').value = DEC_LONG;
			document.getElementById('dec_long').className='d11a readClr';
			document.getElementById('dec_long').setAttribute('readonly','readonly');
			
			document.getElementById('max_error_distance').value = MAX_ERROR_DISTANCE;
			document.getElementById('max_error_distance').className='d11a readClr';
			document.getElementById('max_error_distance').setAttribute('readonly','readonly');		
			
			document.getElementById('max_error_units').value = MAX_ERROR_UNITS;
			document.getElementById('max_error_units').className='d11a readClr';
			document.getElementById('max_error_units').setAttribute('readonly','readonly');	
			
			document.getElementById('extent').value = EXTENT;
			document.getElementById('extent').className='d11a readClr';
			document.getElementById('extent').setAttribute('readonly','readonly');
			
			document.getElementById('gpsaccuracy').value = GPSACCURACY;
			document.getElementById('gpsaccuracy').className='d11a readClr';
			document.getElementById('gpsaccuracy').setAttribute('readonly','readonly');
			
			document.getElementById('datum').value = DATUM;
			document.getElementById('datum').className='d11a readClr';
			document.getElementById('datum').setAttribute('readonly','readonly');
			
			document.getElementById('determined_by_agent').value = DETERMINED_BY;
			document.getElementById('determined_by_agent').className='d11a readClr';
			document.getElementById('determined_by_agent').setAttribute('readonly','readonly');		
			
			document.getElementById('determined_date').value = DETERMINED_DATE;
			document.getElementById('determined_date').className='d11a readClr';
			document.getElementById('determined_date').setAttribute('readonly','readonly');	
			
			document.getElementById('lat_long_ref_source').value = LAT_LONG_REF_SOURCE;
			document.getElementById('lat_long_ref_source').className='d11a readClr';
			document.getElementById('lat_long_ref_source').setAttribute('readonly','readonly');
			
			document.getElementById('georefmethod').value = GEOREFMETHOD;
			document.getElementById('georefmethod').className='d11a readClr';
			document.getElementById('georefmethod').setAttribute('readonly','readonly');
			
			document.getElementById('verificationstatus').value = VERIFICATIONSTATUS;
			document.getElementById('verificationstatus').className='d11a readClr';
			document.getElementById('verificationstatus').setAttribute('readonly','readonly');
			
			document.getElementById('lat_long_remarks').value = LAT_LONG_REMARKS;
			document.getElementById('lat_long_remarks').className='d11a readClr';
			document.getElementById('lat_long_remarks').setAttribute('readonly','readonly');
			switchActive(ORIG_LAT_LONG_UNITS);
			document.getElementById('orig_lat_long_units').value = ORIG_LAT_LONG_UNITS;
			document.getElementById('orig_lat_long_units').className='d11a readClr';
			document.getElementById('orig_lat_long_units').setAttribute('readonly','readonly');
			
			document.getElementById('localityPicker').style.display='none';
			//document.getElementById('pickedSomething').style.display='none';
			document.getElementById('localityUnPicker').style.display='';
			
			// now geology loop
			if (result.length > 6) {
				alert('Whoa! That is a lot of geology attribtues. They will not all be displayed here, but the locality will still have them.');
			}
			// this stuff will all fail most of the time, for those collections that don't use geology
			try {
				// clean up and lock everything
				for (i=0;i<6;i++) {
					var eNum=parseInt(i+1);
					var aID='geology_attribute_' + eNum;
					var vID='geo_att_value_' + eNum;
					var dID='geo_att_determiner_' + eNum;
					var ddID='geo_att_determined_date_' + eNum;
					var mID='geo_att_determined_method_' + eNum;
					var rID='geo_att_remark_' + eNum;
					document.getElementById(aID).value = '';
					document.getElementById(vID).value = '';
					document.getElementById(dID).value = '';
					document.getElementById(ddID).value = '';
					document.getElementById(mID).value = '';
					document.getElementById(rID).value = '';
					document.getElementById(aID).className='d11a readClr';
					document.getElementById(aID).setAttribute('readonly','readonly');
					document.getElementById(vID).className='d11a readClr';
					document.getElementById(vID).setAttribute('readonly','readonly');
					document.getElementById(dID).className='d11a readClr';
					document.getElementById(dID).setAttribute('readonly','readonly');
					document.getElementById(ddID).className='d11a readClr';
					document.getElementById(ddID).setAttribute('readonly','readonly');
					document.getElementById(mID).className='d11a readClr';
					document.getElementById(mID).setAttribute('readonly','readonly');
					document.getElementById(rID).className='d11a readClr';
					document.getElementById(rID).setAttribute('readonly','readonly');
				}
				for (i=0;i<result.length;i++) {
					if (i<5) {
						// don't try to create stuff when we have no room for it
						var eNum=parseInt(i+1);
						var aID='geology_attribute_' + eNum;
						var vID='geo_att_value_' + eNum;
						var dID='geo_att_determiner_' + eNum;
						var ddID='geo_att_determined_date_' + eNum;
						var mID='geo_att_determined_method_' + eNum;
						var rID='geo_att_remark_' + eNum;
						var aV=result[i].GEOLOGY_ATTRIBUTE;
						var vV=result[i].GEO_ATT_VALUE;
						var dV=result[i].GEO_ATT_DETERMINER;
						var ddV=result[i].GEO_ATT_DETERMINED_DATE;
						var mV=result[i].GEO_ATT_DETERMINED_METHOD;
						var rV=result[i].GEO_ATT_REMARK;
						document.getElementById(aID).value = aV;
						document.getElementById(vID).value = vV;
						document.getElementById(dID).value = dV;
						document.getElementById(ddID).value = ddV;
						document.getElementById(mID).value = mV;
						document.getElementById(rID).value = rV;
					}
				}
				
			} catch(err) {
				// whatever
			}		
		}
	} else {
		var locality_id = document.getElementById('locality_id');
		alert(locality_id.value + ' is not a valid locality id');
		locality_id.value='';		
	}
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