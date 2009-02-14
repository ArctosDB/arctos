
	
var MONTH_NAMES=new Array('January','February','March','April','May','June','July','August','September','October','November','December','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
var DAY_NAMES=new Array('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sun','Mon','Tue','Wed','Thu','Fri','Sat');
function LZ(x) {return(x<0||x>9?"":"0")+x}


// -------------------------------------------------------------------
// compareDates(date1,date1format,date2,date2format)
//   Compare two date strings to see which is greater.
//   Returns:
//   1 if date1 is greater than date2
//   0 if date2 is greater than date1 of if they are the same
//  -1 if either of the dates is in an invalid format
// -------------------------------------------------------------------
function compareDates(date1,dateformat1,date2,dateformat2) {
	var d1=getDateFromFormat(date1,dateformat1);
	var d2=getDateFromFormat(date2,dateformat2);
	if (d1==0 || d2==0) {
		return -1;
		}
	else if (d1 > d2) {
		return 1;
		}
	return 0;
	}

// ------------------------------------------------------------------
// Utility functions for parsing in getDateFromFormat()
// ------------------------------------------------------------------
function _isInteger(val) {
	var digits="1234567890";
	for (var i=0; i < val.length; i++) {
		if (digits.indexOf(val.charAt(i))==-1) { return false; }
		}
	return true;
	}
function _getInt(str,i,minlength,maxlength) {
	for (var x=maxlength; x>=minlength; x--) {
		var token=str.substring(i,i+x);
		if (token.length < minlength) { return null; }
		if (_isInteger(token)) { return token; }
		}
	return null;
	}
	
// ------------------------------------------------------------------
// getDateFromFormat( date_string , format_string )
//
// This function takes a date string and a format string. It matches
// If the date string matches the format string, it returns the 
// getTime() of the date. If it does not match, it returns 0.
// ------------------------------------------------------------------
function getDateFromFormat(val,format) {
	val=val+"";
	format=format+"";
	var i_val=0;
	var i_format=0;
	var c="";
	var token="";
	var token2="";
	var x,y;
	var now=new Date();
	var year=now.getYear();
	var month=now.getMonth()+1;
	var date=1;
	var hh=now.getHours();
	var mm=now.getMinutes();
	var ss=now.getSeconds();
	var ampm="";
	
	while (i_format < format.length) {
		// Get next token from format string
		c=format.charAt(i_format);
		token="";
		while ((format.charAt(i_format)==c) && (i_format < format.length)) {
			token += format.charAt(i_format++);
			}
		// Extract contents of value based on format token
		if (token=="yyyy" || token=="yy" || token=="y") {
			if (token=="yyyy") { x=4;y=4; }
			if (token=="yy")   { x=2;y=2; }
			if (token=="y")    { x=2;y=4; }
			year=_getInt(val,i_val,x,y);
			if (year==null) { return 0; }
			i_val += year.length;
			if (year.length==2) {
				if (year > 70) { year=1900+(year-0); }
				else { year=2000+(year-0); }
				}
			}
		else if (token=="MMM"||token=="NNN"){
			month=0;
			for (var i=0; i<MONTH_NAMES.length; i++) {
				var month_name=MONTH_NAMES[i];
				if (val.substring(i_val,i_val+month_name.length).toLowerCase()==month_name.toLowerCase()) {
					if (token=="MMM"||(token=="NNN"&&i>11)) {
						month=i+1;
						if (month>12) { month -= 12; }
						i_val += month_name.length;
						break;
						}
					}
				}
			if ((month < 1)||(month>12)){return 0;}
			}
		else if (token=="EE"||token=="E"){
			for (var i=0; i<DAY_NAMES.length; i++) {
				var day_name=DAY_NAMES[i];
				if (val.substring(i_val,i_val+day_name.length).toLowerCase()==day_name.toLowerCase()) {
					i_val += day_name.length;
					break;
					}
				}
			}
		else if (token=="MM"||token=="M") {
			month=_getInt(val,i_val,token.length,2);
			if(month==null||(month<1)||(month>12)){return 0;}
			i_val+=month.length;}
		else if (token=="dd"||token=="d") {
			date=_getInt(val,i_val,token.length,2);
			if(date==null||(date<1)||(date>31)){return 0;}
			i_val+=date.length;}
		else if (token=="hh"||token=="h") {
			hh=_getInt(val,i_val,token.length,2);
			if(hh==null||(hh<1)||(hh>12)){return 0;}
			i_val+=hh.length;}
		else if (token=="HH"||token=="H") {
			hh=_getInt(val,i_val,token.length,2);
			if(hh==null||(hh<0)||(hh>23)){return 0;}
			i_val+=hh.length;}
		else if (token=="KK"||token=="K") {
			hh=_getInt(val,i_val,token.length,2);
			if(hh==null||(hh<0)||(hh>11)){return 0;}
			i_val+=hh.length;}
		else if (token=="kk"||token=="k") {
			hh=_getInt(val,i_val,token.length,2);
			if(hh==null||(hh<1)||(hh>24)){return 0;}
			i_val+=hh.length;hh--;}
		else if (token=="mm"||token=="m") {
			mm=_getInt(val,i_val,token.length,2);
			if(mm==null||(mm<0)||(mm>59)){return 0;}
			i_val+=mm.length;}
		else if (token=="ss"||token=="s") {
			ss=_getInt(val,i_val,token.length,2);
			if(ss==null||(ss<0)||(ss>59)){return 0;}
			i_val+=ss.length;}
		else if (token=="a") {
			if (val.substring(i_val,i_val+2).toLowerCase()=="am") {ampm="AM";}
			else if (val.substring(i_val,i_val+2).toLowerCase()=="pm") {ampm="PM";}
			else {return 0;}
			i_val+=2;}
		else {
			if (val.substring(i_val,i_val+token.length)!=token) {return 0;}
			else {i_val+=token.length;}
			}
		}
	// If there are any trailing characters left in the value, it doesn't match
	if (i_val != val.length) { return 0; }
	// Is date valid for month?
	if (month==2) {
		// Check for leap year
		if ( ( (year%4==0)&&(year%100 != 0) ) || (year%400==0) ) { // leap year
			if (date > 29){ return 0; }
			}
		else { if (date > 28) { return 0; } }
		}
	if ((month==4)||(month==6)||(month==9)||(month==11)) {
		if (date > 30) { return 0; }
		}
	// Correct hours value
	if (hh<12 && ampm=="PM") { hh=hh-0+12; }
	else if (hh>11 && ampm=="AM") { hh-=12; }
	var newdate=new Date(year,month-1,date,hh,mm,ss);
	return newdate.getTime();
	}

// ------------------------------------------------------------------
// parseDate( date_string [, prefer_euro_format] )
//
// This function takes a date string and tries to match it to a
// number of possible date formats to get the value. It will try to
// match against the following international formats, in this order:
// y-M-d   MMM d, y   MMM d,y   y-MMM-d   d-MMM-y  MMM d
// M/d/y   M-d-y      M.d.y     MMM-d     M/d      M-d
// d/M/y   d-M-y      d.M.y     d-MMM     d/M      d-M
// A second argument may be passed to instruct the method to search
// for formats like d/M/y (european format) before M/d/y (American).
// Returns a Date object or null if no patterns match.
// ------------------------------------------------------------------

		
function isValidDate(val) {
	//alert('parsy');
	//var spiffy = "not spiffy";
	var preferEuro=(arguments.length==2)?arguments[1]:false;
	generalFormats=new Array('y-M-d','MMM d, y','MMM d,y','y-MMM-d','d-MMM-y','d M y','d MMM y','d-M-Y','d-MMM-y');
	monthFirst=new Array('M/d/y','M-d-y','M.d.y','MMM-d','M/d','M-d');
	dateFirst =new Array('d/M/y','d-M-y','d.M.y');
	var checkList=new Array('generalFormats','dateFirst');
	//var checkList=new Array('generalFormats',preferEuro?'dateFirst':'monthFirst',preferEuro?'monthFirst':'dateFirst');
	var d=null;
	for (var i=0; i<checkList.length; i++) {
		var l=window[checkList[i]];
		for (var j=0; j<l.length; j++) {
			d=getDateFromFormat(val,l[j]);
			if (d!=0) { 
				//return new Date(d); 
				//spiffy = "spiffy";
					return true;
				} 
				
		}
		//alert('checked');
	//return null;
	return false;
	}
}


function MVZDefaults() {
	// default all dispositions to "in collection"
	document.getElementById('coll_obj_disposition').value='in collection';
	document.getElementById('part_disposition_1').value='in collection';
	document.getElementById('part_disposition_2').value='in collection';
	document.getElementById('part_disposition_3').value='in collection';
	document.getElementById('part_disposition_4').value='in collection';
	document.getElementById('part_disposition_5').value='in collection';
	document.getElementById('part_disposition_6').value='in collection';
	document.getElementById('part_disposition_7').value='in collection';
	document.getElementById('part_disposition_8').value='in collection';
	document.getElementById('part_disposition_9').value='in collection';
	document.getElementById('part_disposition_10').value='in collection';
	document.getElementById('part_disposition_11').value='in collection';
	document.getElementById('part_disposition_12').value='in collection';	
}

			
					
			



function MSBBirdDefault () {
//alert('birds');
	var cn = document.getElementById('other_id_num_type_1');
	var pn = document.getElementById('other_id_num_type_2');
	cnum = 'collector number';
	pnum = 'preparator number';
	 for(i=0; i<cn.length; i++){
		  if(cn[ i].value == cnum){
			 cn.selectedIndex = i;
			 break;
		  }
	 }
	 for(i=0; i<pn.length; i++){
		  if(pn[ i].value == pnum){
			 pn.selectedIndex = i;
			 break;
		  }
	 }
	
	//setSelectedIndex("other_id_num_type_1","collector number");
}

function clearAll () {
	var theForm = document.getElementById('dataEntry');
	//theForm.reset();
		for(i=0; i<theForm.elements.length; i++) {
			if (theForm.elements[i].type == "text") {
				//document.write(theForm.elements[i].name + " and its value is: " + theForm.elements[i].value + ".<br />");
				theForm.elements[i].value = '';
			}
		}	
}

function changeSex(sex) {
	// only run for birds
	var thisCC = document.getElementById('collection_cde').value;
	if (thisCC == 'Bird') {	
		var thisAtt = document.getElementById('attribute_value_7');
		var thisAttUnit = document.getElementById('attribute_units_7');
		thisAttUnit.className='readClr';
		thisAttUnit.readOnly=true;
		//alert(sex);
		// change attribute 7 to repro
		// default in some value
		// and make the units unwritable
		var a7 = document.getElementById('attribute_7');
		a7.value = 'reproductive data';
		if (sex.indexOf('female') > -1) {
			//alert('girl');
			thisAtt.value = 'OV:  mm';
		} else if (sex.indexOf('male') > -1) {
			thisAtt.value = 'TE:  mm';
		} else {
			//alert('other');
		}
	}
}
function getInstColl (inst_coll) {
	// split a string like 'UAM Mamm' out into 'UAM' and 'Mamm' and
	// insert it into proper hidden variables
	//alert(inst_coll);
	spacePos = inst_coll.indexOf(" ");
	//alert(spacePos);
	inst = inst_coll.slice(0,spacePos);
	//alert("'" + inst + "'");
	var strLen = inst_coll.length;
	coll = inst_coll.slice(spacePos + 1,strLen);
	//alert("'" + coll + "'");
}

function switchActive(OrigUnits) {
		var OrigUnits;
		// first, get ID for everything
		var a=document.getElementById('dms');
		var b=document.getElementById('ddm');
		var c=document.getElementById('dd');
		var u=document.getElementById('utm');
		var d=document.getElementById('lat_long_meta');
		var gg=document.getElementById('orig_lat_long_units');
		// then, switch em all off just to make sure
	 	a.className='noShow f12t';
		b.className='noShow f12t';
		c.className='noShow f12t';
		u.className='noShow f12t';
		d.className='noShow f12t';
		var isSomething = OrigUnits.length;
		if (isSomething > 0) {
			d.className='doShow f12t';
			// and make units required
			gg.className='reqdClr';
		}	else {
			// make units optional if nothing is given
			gg.className='';
			gg.value='';
		}
	if (OrigUnits == 'deg. min. sec.') {
			a.className='doShow';
		}
		else {
			if (OrigUnits == 'decimal degrees') {
				c.className='doShow';
			}
			else {
				if (OrigUnits == 'degrees dec. minutes') {
					b.className='doShow';
				}
				else {
					if (OrigUnits == 'UTM') {
						u.className='doShow';
					}
				}
			}
		}
		
		// this function runs on page load, so use it to set defaults as well
		// set part lot count defaults
		var partLotCount = new Array();
		partLotCount.push('part_lot_count_1');
		partLotCount.push('part_lot_count_2');
		partLotCount.push('part_lot_count_3');
		partLotCount.push('part_lot_count_4');
		partLotCount.push('part_lot_count_5');
		partLotCount.push('part_lot_count_6');
		partLotCount.push('part_lot_count_7');
		partLotCount.push('part_lot_count_8');
		partLotCount.push('part_lot_count_9');
		partLotCount.push('part_lot_count_10');
		partLotCount.push('part_lot_count_11');
		partLotCount.push('part_lot_count_12');
		for (i=0;i<partLotCount.length;i++) {
			var thStr = partLotCount[i];
			var thisFld = document.getElementById(thStr);
			var thisVal = thisFld.value;
			//alert(thisFld + ':' + thisFld.length);
			//set it to 1, the default
			thisFld.value='1';
		}
		// end part lot counts
		// default in a missing catalog number
	}
	
	function saveNewRecord () {
		if (cleanup()) {
			var de = document.getElementById('dataEntry');
			var tehAction = document.getElementById('action');
			tehAction.value='saveEntry';
			de.submit();
			//alert('spiffy');
		}
	}
	
	function saveEditedRecord () {
		if (cleanup()) {
			var de = document.getElementById('dataEntry');
			var tehAction = document.getElementById('action');
			tehAction.value='saveEditRecord';
			de.submit();
			//alert('spiffy');
		}
	}
	
		function deleteThisRec () {
		yesDelete = window.confirm('Are you sure you want to delete this record?');
		if (yesDelete == true) {
			var de = document.getElementById('dataEntry');
			var tehAction = document.getElementById('action');
			tehAction.value='deleteThisRec';
			de.submit();
		}
	}
	
		function goEditMode () {
		// abandon whatever they've done to the record, give em a warning, 
		// then dump em on the last available collection_object_id
		var thisUser = '#client.username#';
		alert(thisUser);
	}

function setPartLabel (thisID) {
	var thePartNum = thisID.replace('part_barcode_','');
	var theOIDType = document.getElementById('other_id_num_type_5').value;
	//alert(theOIDType);
	if (theOIDType == 'AF') {
		var theLabelStr = 'part_container_label_' + thePartNum;
		var theLabel = document.getElementById(theLabelStr);
		var theLabelVal = theLabel.value;
		var isLbl = theLabelVal.length;
		if ( isLbl == 0) {
			var theAf = document.getElementById('other_id_num_5').value;
			var isAf = theAf.length;
			if (isAf > 0) {
				theLabel.value = 'AF' + theAf;
			}
		}
	}
}
function doAttributeDefaults () {
	//alert('doAttributeDefaults');
	var theDef = document.getElementById('attribute_determiner_1').value;	
	var isDef = theDef.length;
	if (isDef > 0) {
		var atts = new Array();
		atts.push('attribute_determiner_2');
		atts.push('attribute_determiner_3');
		atts.push('attribute_determiner_4');
		atts.push('attribute_determiner_5');
		atts.push('attribute_determiner_6');
		atts.push('attribute_determiner_7');
		atts.push('attribute_determiner_8');
		atts.push('attribute_determiner_9');
		atts.push('attribute_determiner_10');
		
		for (i=0;i<atts.length;i++) {
			try {
				var thisFld = document.getElementById(atts[i]);
				var isThere = thisFld.length;
				if (isThere == 0) {
					thisFld.value=theDef;
					alert('doing something');
				}
			}
			catch ( err ){// nothing, just ignore 
			}
		
		}	
	}
	
}
function click_changeMode (mode,collobjid) {
	// only way to get here is by clicking the button
	yesChange = window.confirm('You will lose any unsaved changes. Continue?');
	if (yesChange == true) {
		if (mode == 'edit') {
				//alert('go edit');
				document.location='DataEntry.cfm?collection_object_id=' + collobjid + '&pMode=edit&action=editEnterData';
		} else {
		changeMode(mode,collobjid);
		}
	}	
}
function changeMode (mode,collobjid) {
	var tDiv = document.getElementById('pageTitle');
	var tTab = document.getElementById('theTable');
	var tSav = document.getElementById('theSaveButton');
	var tNew = document.getElementById('theNewButton');
	var eBtn = document.getElementById('enterMode');
	var sBtn = document.getElementById('editMode');
	var tBS = document.getElementById('selectbrowse');
	var Bty = document.getElementById('browseThingy');
	var pgClr = document.getElementById('theTable');
	var lmdc = document.getElementById('loadedMsgDiv').innerHTML;
	var tlmdc = lmdc.replace(/^\s+/g, '').replace(/\s+$/g, '');
	var isGoodSave = tlmdc.length;
	var clrDefBtn = document.getElementById('clearDefault');	
	
	if (mode == 'edit') {
		// don't let them edit the templates
		if (collobjid < 20) {
			alert('You cannot enter edit mode until you\'ve entered a record! Select \'start where you left off\' from the initial menu if you have entered records previously and wish to edit them.');
			return false;
		}
		tNew.style.display='none';
		tSav.style.display='';
		eBtn.style.display='none';
		sBtn.style.display='';
		tBS.value=collobjid;
		Bty.style.display='';
		clrDefBtn.style.display='none';// allow clearing of data in entry mode ONLY (not here!)
		if (isGoodSave > 0) {
			// bad save, loadedmsg contains something besides spaces
			pgClr.style.backgroundColor = '#FF6EC7';
		} else {
			// good save
			pgClr.style.backgroundColor = '#00CCCC';
			tDiv.style.display='none';
		}
		
	} else { // entry mode
		//alert(mode);
		//tDiv.innerHTML='enter mode';
		
		tTab.style.border='';
		tNew.style.display='';
		tSav.style.display='none';
		eBtn.style.display='';
		sBtn.style.display='none';
		var theNumOptions=tBS.length;
		var tNewOptNum = theNumOptions;
		tBS.options[tNewOptNum] = new Option('NEW','');
		tBS.value='';
		Bty.style.display='none';
		clrDefBtn.style.display=''; // allow clearing of data in entry mode 
		// get rid of the title
		if (isGoodSave > 0) {
			// bad save, loadedmsg contains something besides spaces
			pgClr.style.backgroundColor = '#669999';
			// clear defaults
		} else {
			// good save
			pgClr.style.backgroundColor = '#bed88f';
			tDiv.style.display='none';
			//alert('clearing defaults...');
			setNewRecDefaults();
			/*
			var cc = document.getElementById('collection_cde').value;
			var ia = document.getElementById('institution_acronym').value;
			if(cc == 'Mamm' && ia == 'UAM') {
					catNumGap();
			} else if(cc == 'Bird' && ia == 'MSB') {
				MSBBirdDefault();	
			}
			*/
		}
	}
	var splashPg = document.getElementById('splash');
	splashPg.style.display='none';
	pgClr.style.display='';	
}

function setNewRecDefaults () {
	var defBlank = new Array();
	defBlank.push('attribute_value_1');
	defBlank.push('attribute_value_2');
	defBlank.push('attribute_value_3');
	defBlank.push('attribute_value_4');
	defBlank.push('attribute_value_5');
	defBlank.push('attribute_value_6');
	defBlank.push('attribute_value_7');
	defBlank.push('attribute_value_8');
	defBlank.push('attribute_value_9');
	defBlank.push('attribute_value_10');
	defBlank.push('other_id_num_type_1');
	defBlank.push('other_id_num_1');
	defBlank.push('other_id_num_type_2');
	defBlank.push('other_id_num_2');
	defBlank.push('other_id_num_type_3');
	defBlank.push('other_id_num_type_4');
	defBlank.push('other_id_num_3');
	defBlank.push('other_id_num_4');
	defBlank.push('other_id_num_5'); //AF
	defBlank.push('part_barcode_1');
	defBlank.push('part_barcode_2');
	defBlank.push('part_barcode_3');
	defBlank.push('part_barcode_4');
	defBlank.push('part_barcode_5');
	defBlank.push('part_barcode_6');
	defBlank.push('part_barcode_7');
	defBlank.push('part_barcode_8');
	defBlank.push('part_barcode_9');
	defBlank.push('part_barcode_10');
	defBlank.push('part_barcode_11');
	defBlank.push('part_barcode_12');
	defBlank.push('part_container_label_1');
	defBlank.push('part_container_label_2');
	defBlank.push('part_container_label_3');
	defBlank.push('part_container_label_4');
	defBlank.push('part_container_label_5');
	defBlank.push('part_container_label_6');
	defBlank.push('part_container_label_7');
	defBlank.push('part_container_label_8');
	defBlank.push('part_container_label_9');
	defBlank.push('part_container_label_10');
	defBlank.push('part_container_label_11');
	defBlank.push('part_container_label_12');
	defBlank.push('relationship');
	defBlank.push('related_to_num_type');
	defBlank.push('related_to_number');
	defBlank.push('cat_num');
	
	
	
	for (i=0;i<defBlank.length;i++) {
			try {
				var thisFld = document.getElementById(defBlank[i]);
				thisFld.value='';
			}
			catch ( err ){// nothing, just ignore 
			}
		
		}	
	// object condition
	var thisFld = document.getElementById('condition');
	thisFld.value='unchecked';
	// reset code tables etc for attributes
	var attribute_7 = document.getElementById('attribute_7').value;
	var attribute_8 = document.getElementById('attribute_8').value;
	var attribute_9 = document.getElementById('attribute_9').value;
	var attribute_10 = document.getElementById('attribute_10').value;
	//alert('attribute switch');
	getAttributeStuff(attribute_7,'attribute_7');
	getAttributeStuff(attribute_8,'attribute_8');
	getAttributeStuff(attribute_9,'attribute_9');
	getAttributeStuff(attribute_10,'attribute_10');
	
	// collection-specific stuff
	var cc = document.getElementById('collection_cde').value;
	var ia = document.getElementById('institution_acronym').value;
	if(cc == 'Mamm' && ia == 'UAM') {
		catNumGap();
	} else if(cc == 'Bird' && ia == 'MSB') {
		MSBBirdDefault();
	} else if(cc == 'Fish' && ia == 'UAM') {
		UAMFishDefault();	
	} else if(ia == 'MVZ') {
		MVZDefaults();
	}	
}

function UAMFishDefault() {
		var i=1;
		for (i=1;i<=12;i++){
			var thisPartConditionString='part_condition_' + i;
			console.log(i);
			console.log(thisPartConditionString);
			if (document.getElementById(thisPartConditionString)) {
				var thisPartCondition=document.getElementById(thisPartConditionString);
				var thisPartConditionValue=thisPartCondition.value;
				if (thisPartConditionValue==''){
					thisPartCondition.value='unchecked';
				}
			}
		}
}		
function copyAllDates(theID) {
	//alert(':' + theID + ':');
	var theDate = document.getElementById(theID).value;
	if (theDate.length > 0) {
		var date_array = new Array();
		date_array.push('ended_date');
		date_array.push('began_date');
		date_array.push('determined_date');
		date_array.push('made_date');
		date_array.push('attribute_date_1');
		date_array.push('attribute_date_2');
		date_array.push('attribute_date_3');
		date_array.push('attribute_date_4');
		date_array.push('attribute_date_5');
		date_array.push('attribute_date_6');
		date_array.push('attribute_date_7');
		date_array.push('attribute_date_8');
		date_array.push('attribute_date_9');
		date_array.push('attribute_date_10');
		for (i=0;i<date_array.length;i++) {
			try {
				var thisFld = document.getElementById(date_array[i]);
				var theValue = thisFld.value;
				/* KBH - just move em mod
				if (theValue.length == 0) {
					thisFld.value=theDate;
				}
				*/
				thisFld.value=theDate;
			}
			catch ( err ){// nothing, just ignore 
			}
		
		}	
	}
}


function copyAttributeDates(theID) {
	//alert(':' + theID + ':');
	var theDate = document.getElementById(theID).value;
	if (theDate.length > 0) {
		var date_array = new Array();
		date_array.push('attribute_date_1');
		date_array.push('attribute_date_2');
		date_array.push('attribute_date_3');
		date_array.push('attribute_date_4');
		date_array.push('attribute_date_5');
		date_array.push('attribute_date_6');
		date_array.push('attribute_date_7');
		date_array.push('attribute_date_8');
		date_array.push('attribute_date_9');
		date_array.push('attribute_date_10');
		for (i=0;i<date_array.length;i++) {
			try {
				var thisFld = document.getElementById(date_array[i]);
				var theValue = thisFld.value;
				/* KBH - just move em mod
				if (theValue.length == 0) {
					thisFld.value=theDate;
				}
				*/
				thisFld.value=theDate;
			}
			catch ( err ){// nothing, just ignore 
			}
		
		}	
	}
}



function copyAttributeDetr(theID) {
	var theAgent = document.getElementById(theID).value;
	if (theAgent.length > 0) {
		var agnt_array = new Array();
		agnt_array.push('attribute_determiner_1');
		agnt_array.push('attribute_determiner_2');
		agnt_array.push('attribute_determiner_3');
		agnt_array.push('attribute_determiner_4');
		agnt_array.push('attribute_determiner_5');
		agnt_array.push('attribute_determiner_6');
		agnt_array.push('attribute_determiner_7');
		agnt_array.push('attribute_determiner_8');
		agnt_array.push('attribute_determiner_9');
		agnt_array.push('attribute_determiner_10');
		for (i=0;i<agnt_array.length;i++) {
			try {
				var thisFld = document.getElementById(agnt_array[i]);
				var theValue = thisFld.value;
				//if (theValue.length == 0) {
					thisFld.value=theAgent;
				//}
			}
			catch ( err ){// nothing, just ignore 
			}
		
		}	
	}
}

function copyAllAgents(theID) {
	var theAgent = document.getElementById(theID).value;
	if (theAgent.length > 0) {
		var agnt_array = new Array();
		agnt_array.push('determined_by_agent');
		agnt_array.push('id_made_by_agent');
		agnt_array.push('attribute_determiner_1');
		agnt_array.push('attribute_determiner_2');
		agnt_array.push('attribute_determiner_3');
		agnt_array.push('attribute_determiner_4');
		agnt_array.push('attribute_determiner_5');
		agnt_array.push('attribute_determiner_6');
		agnt_array.push('attribute_determiner_7');
		agnt_array.push('attribute_determiner_8');
		agnt_array.push('attribute_determiner_9');
		agnt_array.push('attribute_determiner_10');
		for (i=0;i<agnt_array.length;i++) {
			try {
				var thisFld = document.getElementById(agnt_array[i]);
				var theValue = thisFld.value;
				//if (theValue.length == 0) {
					thisFld.value=theAgent;
				//}
			}
			catch ( err ){// nothing, just ignore 
			}
		
		}	
	}
}

function highlightErrors (loadedMsg) {
	//alert(loadedMsg);
	var prob_array = loadedMsg.split("::");

	for (var loop=0; loop < prob_array.length; loop++)
	{
		var thisSlice = prob_array[loop];
		//alert('split: ' + thisSlice);
		var hasSpace = thisSlice.indexOf(" ");
		//alert(hasSpace);
		if (hasSpace == -1) {
			// no spaces, this is probably a field name
			// try to change it's className
			//alert('field: ' + thisSlice);
			try {
				var theField = document.getElementById(thisSlice);
				theField.className = 'hasProbs';
			}
			catch ( err ){// nothing, just ignore 
			}
			//alert('field: ' + thisSlice);
		}
		//document.writeln(friend_array[loop] + " is my friend.<br>");
	}
	
	//
}

function cleanup () {
var thisCC = document.getElementById('collection_cde').value;
	if (thisCC == 'Mamm') {	
	//alert('Mamm');
	/******************************** Mammal Routine ************************************************/
		var Att2UnitVal = document.getElementById('attribute_units_2').value; //total length & "standard"
			//alert('Att2UnitVal: ' + Att2UnitVal);	
		var Att3UnitVal = document.getElementById('attribute_units_3'); //tail length
		var Att4UnitVal = document.getElementById('attribute_units_4'); //HF length
		var Att5UnitVal = document.getElementById('attribute_units_5'); //EFN length

		
		
			Att3UnitVal.value = Att2UnitVal;
			Att4UnitVal.value = Att2UnitVal;
			Att5UnitVal.value = Att2UnitVal;
		var Det2UnitVal = document.getElementById('attribute_determiner_2').value; //total length
			var Det3UnitVal = document.getElementById('attribute_determiner_3'); //tail length
			var Det4UnitVal = document.getElementById('attribute_determiner_4'); //HF length
			var Det5UnitVal = document.getElementById('attribute_determiner_5'); //EFN length
			var Det6UnitVal = document.getElementById('attribute_determiner_6'); //weight
			Det3UnitVal.value = Det2UnitVal;
			Det4UnitVal.value = Det2UnitVal;
			Det5UnitVal.value = Det2UnitVal;
			Det6UnitVal.value = Det2UnitVal;
		var Date2UnitVal = document.getElementById('attribute_date_2').value; //total length
			var Date3UnitVal = document.getElementById('attribute_date_3'); //tail length
			var Date4UnitVal = document.getElementById('attribute_date_4'); //HF length
			var Date5UnitVal = document.getElementById('attribute_date_5'); //EFN length
			var Date6UnitVal = document.getElementById('attribute_date_6'); //weight
			Date3UnitVal.value = Date2UnitVal;
			Date4UnitVal.value = Date2UnitVal;
			Date5UnitVal.value = Date2UnitVal;
			Date6UnitVal.value = Date2UnitVal;	
	
	} else if (thisCC == 'Bird') {
		/************************************************** Bird Routine **************************************************/
		//var Att2UnitVal = document.getElementById('attribute_units_2').value; //total length & "standard"
		//var Att3UnitVal = document.getElementById('attribute_units_3'); //tail length
		//var Att4UnitVal = document.getElementById('attribute_units_4'); //HF length
		//var Att5UnitVal = document.getElementById('attribute_units_5'); //EFN length
		//	Att3UnitVal.value = Att2UnitVal;
		//	Att4UnitVal.value = Att2UnitVal;
		//	Att5UnitVal.value = Att2UnitVal;
		var Det2UnitVal = document.getElementById('attribute_determiner_2').value; //age & standard
			var Det3UnitVal = document.getElementById('attribute_determiner_3'); //fat
			var Det4UnitVal = document.getElementById('attribute_determiner_4'); //molt
			var Det5UnitVal = document.getElementById('attribute_determiner_5'); //skull
			var Det6UnitVal = document.getElementById('attribute_determiner_6'); //weight
			Det3UnitVal.value = Det2UnitVal;
			Det4UnitVal.value = Det2UnitVal;
			Det5UnitVal.value = Det2UnitVal;
			Det6UnitVal.value = Det2UnitVal;
		var Date2UnitVal = document.getElementById('attribute_date_2').value; //age & standard
			var Date3UnitVal = document.getElementById('attribute_date_3'); //fat
			var Date4UnitVal = document.getElementById('attribute_date_4'); //molt
			var Date5UnitVal = document.getElementById('attribute_date_5'); //skull
			var Date6UnitVal = document.getElementById('attribute_date_6'); //weight
			Date3UnitVal.value = Date2UnitVal;
			Date4UnitVal.value = Date2UnitVal;
			Date5UnitVal.value = Date2UnitVal;
			Date6UnitVal.value = Date2UnitVal;
		// ask if they want to NOT enter a coll number and prep number, which is what oid 1 and 2 are defaulted to
		var oid1 = document.getElementById('other_id_num_type_1');
		var oid2 = document.getElementById('other_id_num_type_2');
		var theMsg = "";
		if (oid1.value == 'collector number') {
			// it's still default
			var oidv1 = document.getElementById('other_id_num_1').value;
			if (oidv1.length == 0) {
				theMsg = "You did not enter a collector number";
			}			
		}
		if (oid2.value == 'preparator number') {
			// it's still default
			var oidv2 = document.getElementById('other_id_num_2').value;
			if (oidv2.length == 0) {
				theMsg += "\nYou did not enter a preparator number";
			}			
		}
		if (theMsg.length > 0) {
			theMsg +="\nContinue?";
			whatever = window.confirm(theMsg);
			if (whatever == false) {
				return false;
			} else {
				return true;
			}
		}
}// end collection specific thingy
/******************************************************************** Any Collection ***************************************/
// make an array of required values and loop through the array checking them
	// this must always happen at the bottom of function cleanup - some of these things
	// may be populated by this function

		var reqdFlds = new Array();
		var missingData = "";
		// these fields are always required
		reqdFlds.push('accn');
		reqdFlds.push('collector_agent_1');
		reqdFlds.push('higher_geog');
		reqdFlds.push('spec_locality');
		reqdFlds.push('verbatim_locality');
		reqdFlds.push('verbatim_date');
		reqdFlds.push('began_date');
		reqdFlds.push('ended_date');
		reqdFlds.push('taxon_name');
		reqdFlds.push('condition');
		reqdFlds.push('coll_obj_disposition');
		reqdFlds.push('id_made_by_agent');
		reqdFlds.push('nature_of_id');
		if (thisCC != 'Crus' && thisCC != 'Herb' && thisCC != 'ES' && thisCC != 'Fish' && thisCC != 'Para') {
			// require sex stuff UNLESS Crus or Herb or paleo
			reqdFlds.push('attribute_value_1');
			reqdFlds.push('attribute_determiner_1');
		}
		reqdFlds.push('part_condition_1');
		// now, handle conditionally-required stuff
		var llUnit=document.getElementById('orig_lat_long_units').value;
		if (llUnit.length > 0) {
			// got a lat_long units, check fields required for all LL entries first
			//reqdFlds.push('max_error_distance');
			//reqdFlds.push('max_error_units');
			reqdFlds.push('datum');
			reqdFlds.push('determined_by_agent');
			reqdFlds.push('determined_date');
			reqdFlds.push('lat_long_ref_source');
			reqdFlds.push('georefmethod');
			reqdFlds.push('verificationstatus');
			// now, add specific fields based on the units
			if (llUnit == 'deg. min. sec.') {
				reqdFlds.push('latdeg');
				reqdFlds.push('latmin');
				reqdFlds.push('latsec');
				reqdFlds.push('latdir');
				reqdFlds.push('longdeg');
				reqdFlds.push('longmin');
				reqdFlds.push('longsec');
				reqdFlds.push('longdir');
			}
			if (llUnit == 'decimal degrees') {
				reqdFlds.push('dec_lat');
				reqdFlds.push('dec_long');
			}
			if (llUnit == 'degrees dec. minutes') {
				reqdFlds.push('decLAT_DEG');
				reqdFlds.push('dec_lat_min');
				reqdFlds.push('decLAT_DIR');
				reqdFlds.push('decLONGDEG');
				reqdFlds.push('DEC_LONG_MIN');
				reqdFlds.push('decLONGDIR');
			}
			if (llUnit == 'UTM') {
				reqdFlds.push('utm_zone');
				reqdFlds.push('utm_ns');
				reqdFlds.push('utm_ew');
			}
		}
		// now loop through the array and make sure these fields exist
		for (i=0;i<reqdFlds.length;i++) {
			try {
					var thisFld = document.getElementById(reqdFlds[i]).value;
					if (thisFld.length == 0) {
						//alert(reqdFlds[i]);
						var thisFldName = document.getElementById(reqdFlds[i]).name;
						missingData = missingData + "\n" + thisFldName;
						//alert(thisFldName + ' is required');
						//abort();
					}
				}
				catch ( err ){// nothing, just ignore 
				}
			
		}
		// if anything is missing show an alert and abort
		if (missingData.length > 0) {
			alert('You must enter data in required fields: ' + missingData + "\n Aborting Save!");
			return false;
		}
		var dateFields = new Array();
		var badDates = "";
		dateFields.push('made_date');
		dateFields.push('began_date');
		dateFields.push('ended_date');
		dateFields.push('determined_date');
		dateFields.push('attribute_date_1');
		dateFields.push('attribute_date_2');
		dateFields.push('attribute_date_3');
		dateFields.push('attribute_date_4');
		dateFields.push('attribute_date_5');
		dateFields.push('attribute_date_6');
		dateFields.push('attribute_date_7');
		dateFields.push('attribute_date_8');
		dateFields.push('attribute_date_9');
		dateFields.push('attribute_date_10');
		for (i=0;i<dateFields.length;i++) {
			var thisFld = document.getElementById(dateFields[i]).value;
				//alert(thisFld);
				if (thisFld.length > 0 && isValidDate(thisFld) == false) {
					badDates += ' ' + thisFld + '\n';
				}
				
		}
		if (badDates.length > 0) {
			alert('The following dates are not in a recognized format, or are not valid dates: \n' + badDates);
			return false;
		}
		
		// make sure no elements are marked invalid
		/*
		var probs = "";
		for(i=0; i<document.dataEntry.elements.length; i++)
			{
				var elem = document.dataEntry.elements[i];
				if (elem.className.indexOf('hasProbs') > -1) {
					probs += '\n' + elem.id;
				}
			}
		if (probs.length > 0) {
			alert('The folowing elements have problems and must be fixed before saving: ' + probs);
			return false;
		}
		*/
		return true;

	
		
		
// end function cleanup	
}		


	//  handle tab into began date and verbatim locality
	
	function SpecToVerb (verbLoc) {
		var verbLoc;
		var isVerb=verbLoc.length;
		/* Kyndall cahnge request - just copy the damn thing!
		if (isVerb == 0) {
			// there is no verbatim locality; put specific locality in as a default
			dataEntry.verbatim_locality.value=dataEntry.spec_locality.value;
			//verbLoc.value=specLoc;
		}
		*/
		var a = document.getElementById('verbatim_locality');
		var b = document.getElementById('spec_locality').value;
		a.value=b;
	}
	function VerbToBegan (begDate) {
		var begDate;
		var isBegDate=begDate.length;
		var VerbDate = document.getElementById('verbatim_date').value;
		
		/* KBH kill em all 
		if (isBegDate == 0) {
			if (isDate(VerbDate)) {
				dataEntry.began_date.value=dataEntry.verbatim_date.value;
			}
		}
		*/
		if (isDate(VerbDate)) {
				var bd = document.getElementById('began_date');
				bd = VerbDate;
			}
	}
	function VerbToEnd (endDate) {
		var endDate;
		var isEndDate=endDate.length;
		//dataEntry.ended_date.value=dataEntry..value;
		var bd = document.getElementById('began_date');
		bd = endDate;
		/*
		if (isEndDate == 0) {
			dataEntry.ended_date.value=dataEntry.began_date.value;
		}
		*/
	}
function showNext(idName) {
		var idName;
		var thisElement=document.getElementById(idName);
		thisElement.className='doShow f12t';
	}