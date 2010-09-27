function msg(m,s){
	$("#msg").removeClass().addClass(s).html(m);
}
function saveNewRecord () {
	if (cleanup()) {
		msg('saving....','bad');
		$.getJSON("/component/Bulkloader.cfc",
			{
				method : "saveNewRecord",
				q : $("#dataEntry").serialize(),
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				var rA=r.split("::");
				var status=rA[0];
				if (status=='spiffy'){
					$("#collection_object_id").val(rA[1]);
					msg('inserted ' + rA[1],'good');
				} else {
					msg(r,'bad');
				}
			}
		);
	}
}
function loadRecord (collection_object_id) {
	msg('fetching data....','bad');
	$.getJSON("/component/Bulkloader.cfc",
		{
			method : "loadRecord",
			collection_object_id : collection_object_id,
			returnformat : "json",
			queryformat : 'column'
		},
		function(r) {
			alert(r);
			alert(r.COLUMNS);
			var cAry=r.COLUMNS.split(',');
			for (i=0;i<cAry.length;i++) {
				console.log('column=' + cAry[i]);
			}
			
			//if (toString(r.DATA.COLLECTION_OBJECT_ID[0]).indexOf('Error:')>-1) {
		}
	);
}


function copyVerbatim(str){
	$.getJSON("/component/functions.cfc",
		{
			method : "strToIso8601",
			str : str,
			returnformat : "json",
			queryformat : 'column'
		},
		function(r) {
			if(r.DATA.B[0].length==0 || r.DATA.E[0].length==0){
				$("#dateConvertStatus").addClass('err').text(r.DATA.I[0] + ' could not be converted.');
			} else {
				$("#dateConvertStatus").removeClass().text('');
				$("#began_date").val(r.DATA.B[0]);
				$("#ended_date").val(r.DATA.E[0]);
			}
		}
	);
}
	
	
	jQuery(document).ready(function() {
		jQuery(function() {
			jQuery("#made_date").datepicker();
			jQuery("#began_date").datepicker();
			jQuery("#ended_date").datepicker();	
			jQuery("#determined_date").datepicker();
			for (i=1;i<=12;i++){
				jQuery("#geo_att_determined_date_" + i).datepicker();
				jQuery("#attribute_date_" + i).datepicker();
			}
		});
		jQuery("input[type=text]").focus(function(){
		    //this.select();
		});
		$("select[id^='geology_attribute_']").each(function(e){
			var gid='geology_attribute_' + String(e+1);
			populateGeology(gid);			
		});		
	});

	function populateGeology(id) {
		var idNum=id.replace('geology_attribute_','');
		var thisValue=$("#geology_attribute_" + idNum).val();;
		var dataValue=$("#geo_att_value_" + idNum).val();
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getGeologyValues",
				attribute : thisValue,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				var s='';
				for (i=0; i<r.ROWCOUNT; ++i) {
					s+='<option value="' + r.DATA.ATTRIBUTE_VALUE[i] + '"';
					if (r.DATA.ATTRIBUTE_VALUE[i]==dataValue) {
						s+=' selected="selected"';
					}
					s+='>' + r.DATA.ATTRIBUTE_VALUE[i] + '</option>';
				}
				$("select#geo_att_value_" + idNum).html(s);				
			}
		);
	}
	
var MONTH_NAMES=new Array('January','February','March','April','May','June','July','August','September','October','November','December','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
var DAY_NAMES=new Array('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sun','Mon','Tue','Wed','Thu','Fri','Sat');
function LZ(x) {return(x<0||x>9?"":"0")+x}
function changeCollection(v){
	var yesno = confirm("Are you sure you want to move this record to " + v + "? \nDoing so may cause attribute verification failure.")
	if (yesno){
		var ary=v.split(':');
		document.getElementById('institution_acronym').value=ary[0];
		document.getElementById('collection_cde').value=ary[1];
	} else {
		var i=document.getElementById('institution_acronym').value;
		var c=document.getElementById('collection_cde').value;
		var s=document.getElementById('colln');
		s.value=i + ':' + c;
	}
}
/* recheck */
function requirePartAtts(i,v){
	var pn=document.getElementById('part_name_' + i);
	var pc=document.getElementById('part_condition_' + i);
	var pl=document.getElementById('part_lot_count_' + i);
	var pd=document.getElementById('part_disposition_' + i);
	if (v.length > 0) {
		pn.className='reqdClr';
		pc.className='reqdClr';
		pl.className='reqdClr';
		pd.className='reqdClr';
	} else {
		pn.className='';
		pc.className='';
		pl.className='';
		pd.className='';
	}
}
function _isInteger(val){var digits="1234567890";for(var i=0;i < val.length;i++){if(digits.indexOf(val.charAt(i))==-1){return false;}}return true;}

function _getInt(str,i,minlength,maxlength) {
	for (var x=maxlength; x>=minlength; x--) {
		var token=str.substring(i,i+x);
		if (token.length < minlength) { return null; }
		if (_isInteger(token)) { return token; }
	}
	return null;
}
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
		c=format.charAt(i_format);
		token="";
		while ((format.charAt(i_format)==c) && (i_format < format.length)) {
			token += format.charAt(i_format++);
		}
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
function isValidDate(val) {
	var preferEuro=(arguments.length==2)?arguments[1]:false;
	generalFormats=new Array('y-M-d','MMM d, y','MMM d,y','y-MMM-d','d-MMM-y','d M y','d MMM y','d-M-Y','d-MMM-y');
	monthFirst=new Array('M/d/y','M-d-y','M.d.y','MMM-d','M/d','M-d');
	dateFirst =new Array('d/M/y','d-M-y','d.M.y');
	var checkList=new Array('generalFormats','dateFirst');
	var d=null;
	for (var i=0; i<checkList.length; i++) {
		var l=window[checkList[i]];
		for (var j=0; j<l.length; j++) {
			d=getDateFromFormat(val,l[j]);
			if (d!=0) { 
				return true;
			} 	
		}
	return false;
	}
}

function MVZDefaults() {
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
	if(document.getElementById('attribute_units_2')){
		document.getElementById('attribute_units_2').value='mm';
	}
}

function MSBBirdDefault () {
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
}
function clearAll () {
	var theForm = document.getElementById('dataEntry');
	for(i=0; i<theForm.elements.length; i++) {
		if (theForm.elements[i].type == "text") {
			theForm.elements[i].value = '';
		}
	}	
}
function changeSex(sex) {
	var thisCC = document.getElementById('collection_cde').value;
	if (thisCC == 'Bird') {	
		var thisAtt = document.getElementById('attribute_value_7');
		var thisAttUnit = document.getElementById('attribute_units_7');
		thisAttUnit.className='readClr';
		thisAttUnit.readOnly=true;
		var a7 = document.getElementById('attribute_7');
		a7.value = 'reproductive data';
		if (sex.indexOf('female') > -1) {
			thisAtt.value = 'OV:  mm';
		} else if (sex.indexOf('male') > -1) {
			thisAtt.value = 'TE:  mm';
		} else {
		}
	}
}
function switchActive(OrigUnits) {
	var OrigUnits;
	var a=document.getElementById('dms');
	var b=document.getElementById('ddm');
	var c=document.getElementById('dd');
	var u=document.getElementById('utm');
	var d=document.getElementById('lat_long_meta');
	var gg=document.getElementById('orig_lat_long_units');
 	a.className='noShow';
	b.className='noShow';
	c.className='noShow';
	u.className='noShow';
	d.className='noShow';
	var isSomething = OrigUnits.length;
	if (isSomething > 0) {
		d.className='doShow';
		gg.className='reqdClr';
	}	else {
		gg.className='';
		gg.value='';
	}
	if (OrigUnits == 'deg. min. sec.') {
		a.className='doShow';
	} else if (OrigUnits == 'decimal degrees') {
		c.className='doShow';
	} else if (OrigUnits == 'degrees dec. minutes') {
		b.className='doShow';
	} else if (OrigUnits == 'UTM') {
		u.className='doShow';
	}
}

function saveEditedRecord () {
	if (cleanup()) {
		var de = document.getElementById('dataEntry');
		var tehAction = document.getElementById('action');
		tehAction.value='saveEditRecord';
		de.submit();
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
function setPartLabel (thisID) {
	var thePartNum = thisID.replace('part_barcode_','');
	var theOIDType = document.getElementById('other_id_num_type_5').value;
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
	yesChange = window.confirm('You will lose any unsaved changes. Continue?');
	if (yesChange == true) {
		if (mode == 'edit') {
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
			pgClr.style.backgroundColor = '#FF6EC7';
		} else {
			pgClr.style.backgroundColor = '#00CCCC';
			tDiv.style.display='none';
		}
	} else { // entry mode
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
		if (isGoodSave > 0) {
			pgClr.style.backgroundColor = '#669999';
		} else {
			pgClr.style.backgroundColor = '#bed88f';
			tDiv.style.display='none';
			setNewRecDefaults();
		}
	}
	var splashPg = document.getElementById('splash');
	splashPg.style.display='none';
	pgClr.style.display='';	
}
function setNewRecDefaults () {
	try{
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
	var thisFld = document.getElementById('condition');
	thisFld.value='unchecked';
	var attribute_7 = document.getElementById('attribute_7').value;
	var attribute_8 = document.getElementById('attribute_8').value;
	var attribute_9 = document.getElementById('attribute_9').value;
	var attribute_10 = document.getElementById('attribute_10').value;
	getAttributeStuff(attribute_7,'attribute_7');
	getAttributeStuff(attribute_8,'attribute_8');
	getAttributeStuff(attribute_9,'attribute_9');
	getAttributeStuff(attribute_10,'attribute_10');
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
		thisFld.value='1';
	}	
	var cc = document.getElementById('collection_cde').value;
	var ia = document.getElementById('institution_acronym').value;
	if(cc == 'Mamm' && ia == 'UAM') {
		//catNumGap();
	} else if(cc == 'Bird' && ia == 'MSB') {
		MSBBirdDefault();
	} else if(cc == 'Fish' && ia == 'UAM') {
		UAMFishDefault();	
	} else if(ia == 'UAM' && cc=='Art') {
		UAMArtDefaults();
	} else if(ia == 'MVZ') {
		MVZDefaults();
	}
	} 
	catch(err){
		//null
	}
}
function UAMArtDefaults() {
	var i=1;
	for (i=1;i<=12;i++){
		var thisPartConditionString='part_condition_' + i;
		if (document.getElementById(thisPartConditionString)) {
			var thisPartCondition=document.getElementById(thisPartConditionString);
			var thisPartConditionValue=thisPartCondition.value;
			if (thisPartConditionValue==''){
				thisPartCondition.value='unchecked';
			}
		}
	}
}
function UAMFishDefault() {
	var i=1;
	for (i=1;i<=12;i++){
		var thisPartConditionString='part_condition_' + i;
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
				thisFld.value=theDate;
			}
			catch ( err ){// nothing, just ignore 
			}
		
		}	
	}
}
function copyAttributeDates(theID) {
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
				thisFld.value=theAgent;
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
				thisFld.value=theAgent;
			}
			catch ( err ){// nothing, just ignore 
			}
		
		}	
	}
}
function highlightErrors (loadedMsg) {
	var prob_array = loadedMsg.split(" ");
	for (var loop=0; loop < prob_array.length; loop++) {
		var thisSlice = prob_array[loop];
		var hasSpace = thisSlice.indexOf(" ");
		if (hasSpace == -1) {
			try {
				var theField = document.getElementById(thisSlice.toLowerCase());
				theField.className = 'hasProbs';
			}
			catch ( err ){// nothing, just ignore 
			}
		}
	}
}

function cleanup () {
	var thisCC = document.getElementById('collection_cde').value;
	if (thisCC == 'Mamm') {	
		/******************************** Mammal Routine ************************************************/
		try {
			var Att2UnitVal = document.getElementById('attribute_units_2').value; //total length & "standard"
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
		} catch(e){
			// whatever
		}
	} else if (thisCC == 'Bird') {
		/************************************************** Bird Routine **************************************************/
		try {
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
			var oid1 = document.getElementById('other_id_num_type_1');
			var oid2 = document.getElementById('other_id_num_type_2');
			var theMsg = "";
			if (oid1.value == 'collector number') {
				var oidv1 = document.getElementById('other_id_num_1').value;
				if (oidv1.length == 0) {
					theMsg = "You did not enter a collector number";
				}			
			}
			if (oid2.value == 'preparator number') {
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
		} catch(e){
			// whatever
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
	if (thisCC != 'Crus' && thisCC != 'Herb' && thisCC != 'ES' && thisCC != 'Fish' && thisCC != 'Para' && thisCC != 'Art') {
		reqdFlds.push('attribute_value_1');
		reqdFlds.push('attribute_determiner_1');
	}
	reqdFlds.push('part_condition_1');
	var llUnit=document.getElementById('orig_lat_long_units').value;
	if (llUnit.length > 0) {
		reqdFlds.push('datum');
		reqdFlds.push('determined_by_agent');
		reqdFlds.push('determined_date');
		reqdFlds.push('lat_long_ref_source');
		reqdFlds.push('georefmethod');
		reqdFlds.push('verificationstatus');
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
	for (i=0;i<reqdFlds.length;i++) {
		try {
			var thisFld = document.getElementById(reqdFlds[i]).value;
			if (thisFld.length == 0) {
				var thisFldName = document.getElementById(reqdFlds[i]).name;
				missingData = missingData + "\n" + thisFldName;					}
			}
		catch ( err ){// nothing, just ignore 
		}
	}
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
		if (thisFld.length > 0 && isValidDate(thisFld) == false) {
			badDates += ' ' + thisFld + '\n';
		}
	}
	if (badDates.length > 0) {
		alert('The following dates are not in a recognized format, or are not valid dates: \n' + badDates);
		return false;
	}
	return true;
}
setInterval ( "checkPicked()", 5000 );
setInterval ( "checkPickedEvnt()", 5000 );
function checkPicked(){
	if(document.getElementById('locality_id')){
		var locality_id=document.getElementById('locality_id');
		if (locality_id.value.length>0){
			pickedLocality();
		}
	}
}
function checkPickedEvnt(){
	if(document.getElementById('collecting_event_id')){
		var collecting_event_id=document.getElementById('collecting_event_id');
		if (collecting_event_id.value.length>0){
			document.getElementById('locality_id').value='';
			pickedEvent();
		}
	}
}			
function rememberLastOtherId (yesno) {
	jQuery.getJSON("/component/DataEntry.cfc",
		{
			method : "rememberLastOtherId",
			yesno : yesno,
			returnformat : "json",
			queryformat : 'column'
		},
		function(yesno){
			var theSpan = document.getElementById('rememberLastId');
			if (yesno==0){
				theSpan.innerHTML='<span class="infoLink" onclick="rememberLastOtherId(1)">Increment This</span>';
			} else if (yesno == 1) {
				theSpan.innerHTML='<span class="infoLink" onclick="rememberLastOtherId(0)">Nevermind</span>';
			} else {
				alert('Something goofy happened. Remembering your next Other ID may not have worked.');
			}
		}
	);
}
function isGoodAccn () {
	var accn = document.getElementById('accn').value;
	var institution_acronym = document.getElementById('institution_acronym').value;
	jQuery.getJSON("/component/DataEntry.cfc",
		{
			method : "is_good_accn",
			accn : accn,
			institution_acronym : institution_acronym,
			returnformat : "json",
			queryformat : 'column'
		},
		function (result) {
			var accn = document.getElementById('accn');
			if (result == 1) {
				accn.className = 'reqdClr';
			} else if (result == 0) {
				alert('You must enter a valid, pre-existing accn.');
				accn.className = 'hasProbs';
			} else {
				alert('An error occured while validating accn. \nYou must enter a valid, pre-existing accn.\n' + result );
				accn.className = 'hasProbs';
			}
		}
	);
	return null;
}
function turnSaveOn () {
	document.getElementById('localityPicker').style.display='none';
	document.getElementById('localityUnPicker').style.display='none';
}
function unpickEvent() {
	document.getElementById('collecting_event_id').value='';
	document.getElementById('locality_id').value='';
	document.getElementById('began_date').className='reqdClr';
	document.getElementById('began_date').removeAttribute('readonly');	
	document.getElementById('ended_date').className='reqdClr';
	document.getElementById('ended_date').removeAttribute('readonly');	
	document.getElementById('verbatim_date').className='reqdClr';
	document.getElementById('verbatim_date').removeAttribute('readonly');
	document.getElementById('verbatim_locality').className='reqdClr';
	document.getElementById('verbatim_locality').removeAttribute('readonly');
	document.getElementById('coll_event_remarks').className='';
	document.getElementById('coll_event_remarks').removeAttribute('readonly');
	document.getElementById('collecting_source').className='reqdClr';
	document.getElementById('collecting_source').removeAttribute('readonly');
	document.getElementById('collecting_method').className='';
	document.getElementById('collecting_method').removeAttribute('readonly');
	document.getElementById('habitat_desc').className='';
	document.getElementById('habitat_desc').removeAttribute('readonly');
	document.getElementById('eventUnPicker').style.display='none';
	document.getElementById('eventPicker').style.display='';
	unpickLocality();
}						
function unpickLocality () {
	var u = document.getElementById('orig_lat_long_units').value;
	switchActive(u);
	document.getElementById('higher_geog').className='reqdClr';
	document.getElementById('higher_geog').removeAttribute('readonly');
	document.getElementById('maximum_elevation').className='';
	document.getElementById('maximum_elevation').removeAttribute('readonly');
	document.getElementById('minimum_elevation').className='';
	document.getElementById('minimum_elevation').removeAttribute('readonly');
	document.getElementById('orig_elev_units').className='';
	document.getElementById('orig_elev_units').removeAttribute('readonly');
	document.getElementById('spec_locality').className='reqdClr';
	document.getElementById('spec_locality').removeAttribute('readonly');
	document.getElementById('locality_remarks').className='';
	document.getElementById('locality_remarks').removeAttribute('readonly');
	document.getElementById('latdeg').className='reqdClr';
	document.getElementById('latdeg').removeAttribute('readonly');
	document.getElementById('decLAT_DEG').className='reqdClr';
	document.getElementById('decLAT_DEG').removeAttribute('readonly');
	document.getElementById('latmin').className='reqdClr';
	document.getElementById('latmin').removeAttribute('readonly');
	document.getElementById('latsec').className='reqdClr';
	document.getElementById('latsec').removeAttribute('readonly');
	document.getElementById('latdir').className='reqdClr';
	document.getElementById('latdir').removeAttribute('readonly');
	document.getElementById('longdeg').className='reqdClr';
	document.getElementById('longdeg').removeAttribute('readonly');
	document.getElementById('longmin').className='reqdClr';
	document.getElementById('longmin').removeAttribute('readonly');
	document.getElementById('longsec').className='reqdClr';
	document.getElementById('longsec').removeAttribute('readonly');
	document.getElementById('longdir').className='reqdClr';
	document.getElementById('longdir').removeAttribute('readonly');
	document.getElementById('dec_lat_min').className='reqdClr';
	document.getElementById('dec_lat_min').removeAttribute('readonly');
	document.getElementById('decLAT_DIR').className='reqdClr';
	document.getElementById('decLAT_DIR').removeAttribute('readonly');
	document.getElementById('decLONGDEG').className='reqdClr';
	document.getElementById('decLONGDEG').removeAttribute('readonly');
	document.getElementById('dec_long_min').className='reqdClr';
	document.getElementById('dec_long_min').removeAttribute('readonly');
	document.getElementById('decLONGDIR').className='reqdClr';
	document.getElementById('decLONGDIR').removeAttribute('readonly');
	document.getElementById('dec_lat').className='reqdClr';
	document.getElementById('dec_lat').removeAttribute('readonly');
	document.getElementById('dec_long').className='reqdClr';
	document.getElementById('dec_long').removeAttribute('readonly');
	document.getElementById('max_error_distance').className='';
	document.getElementById('max_error_distance').removeAttribute('readonly');
	document.getElementById('max_error_units').className='';
	document.getElementById('max_error_units').removeAttribute('readonly');
	document.getElementById('extent').className='';
	document.getElementById('extent').removeAttribute('readonly');
	document.getElementById('gpsaccuracy').className='';
	document.getElementById('gpsaccuracy').removeAttribute('readonly');
	document.getElementById('datum').className='reqdClr';
	document.getElementById('datum').removeAttribute('readonly');
	document.getElementById('determined_by_agent').className='reqdClr';
	document.getElementById('determined_by_agent').removeAttribute('readonly');
	document.getElementById('determined_date').className='reqdClr';
	document.getElementById('determined_date').removeAttribute('readonly');
	document.getElementById('lat_long_ref_source').className='reqdClr';
	document.getElementById('lat_long_ref_source').removeAttribute('readonly');
	document.getElementById('georefmethod').className='reqdClr';
	document.getElementById('georefmethod').removeAttribute('readonly');
	document.getElementById('verificationstatus').className='reqdClr';
	document.getElementById('verificationstatus').removeAttribute('readonly');
	document.getElementById('lat_long_remarks').className='';
	document.getElementById('lat_long_remarks').removeAttribute('readonly');
	document.getElementById('orig_lat_long_units').className='';
	document.getElementById('orig_lat_long_units').removeAttribute('readonly');
	document.getElementById('locality_id').value='';
	document.getElementById('fetched_locid').value='';
	document.getElementById('fetched_eventid').value='';
	document.getElementById('localityUnPicker').style.display='none';
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
			document.getElementById(aID).className='reqdClr';
			document.getElementById(aID).removeAttribute('readonly');
			document.getElementById(vID).className='reqdClr';
			document.getElementById(vID).removeAttribute('readonly');
			document.getElementById(dID).className='';
			document.getElementById(dID).removeAttribute('readonly');
			document.getElementById(ddID).className='';
			document.getElementById(ddID).removeAttribute('readonly');
			document.getElementById(mID).className='';
			document.getElementById(mID).removeAttribute('readonly');
			document.getElementById(rID).className='';
			document.getElementById(rID).removeAttribute('readonly');
		}
	} catch(err) {
		// whatever
	}
}
function pickedEvent () {
	var collecting_event_id = document.getElementById('collecting_event_id').value;
	var peid = document.getElementById('fetched_eventid').value;
	if (collecting_event_id==peid){
		return false;
	}
	if (collecting_event_id.length > 0) {
		document.getElementById('locality_id').value='';
		jQuery.getJSON("/component/DataEntry.cfc",
			{
				method : "get_picked_event",
				collecting_event_id : collecting_event_id,
				returnformat : "json",
				queryformat : 'column'
			},
			success_pickedEvent
		);
	}
}
function success_pickedEvent(r){
	var result=r.DATA;
	var collecting_event_id=result.COLLECTING_EVENT_ID;
	if (collecting_event_id < 0) {
		alert('Oops! Something bad happend with the collecting_event pick. ' + result.MSG);
	} else {
		document.getElementById('locality_id').value='';
		document.getElementById('fetched_eventid').value=collecting_event_id;
		var BEGAN_DATE = result.BEGAN_DATE;
		var ENDED_DATE = result.ENDED_DATE;
		var VERBATIM_DATE = result.VERBATIM_DATE;
		var VERBATIM_LOCALITY = result.VERBATIM_LOCALITY;
		var COLL_EVENT_REMARKS = result.COLL_EVENT_REMARKS;
		var COLLECTING_SOURCE = result.COLLECTING_SOURCE;
		var COLLECTING_METHOD = result.COLLECTING_METHOD;
		var HABITAT_DESC = result.HABITAT_DESC;
		document.getElementById('began_date').value = BEGAN_DATE;
		document.getElementById('began_date').className='readClr';
		document.getElementById('began_date').setAttribute('readonly','readonly');
		document.getElementById('ended_date').value = ENDED_DATE;
		document.getElementById('ended_date').className='readClr';
		document.getElementById('ended_date').setAttribute('readonly','readonly');
		document.getElementById('verbatim_locality').value = VERBATIM_LOCALITY;
		document.getElementById('verbatim_locality').className='readClr';
		document.getElementById('verbatim_locality').setAttribute('readonly','readonly');
		document.getElementById('verbatim_date').value = VERBATIM_DATE;
		document.getElementById('verbatim_date').className='readClr';
		document.getElementById('verbatim_date').setAttribute('readonly','readonly');
		document.getElementById('coll_event_remarks').value = COLL_EVENT_REMARKS;
		document.getElementById('coll_event_remarks').className='readClr';
		document.getElementById('coll_event_remarks').setAttribute('readonly','readonly');
		document.getElementById('collecting_source').value = COLLECTING_SOURCE;
		document.getElementById('collecting_source').className='readClr';
		document.getElementById('collecting_source').setAttribute('readonly','readonly');
		document.getElementById('collecting_method').value = COLLECTING_METHOD;
		document.getElementById('collecting_method').className='readClr';
		document.getElementById('collecting_method').setAttribute('readonly','readonly');
		document.getElementById('habitat_desc').value = HABITAT_DESC;
		document.getElementById('habitat_desc').className='readClr';
		document.getElementById('habitat_desc').setAttribute('readonly','readonly');
		document.getElementById('eventPicker').style.display='none';
		document.getElementById('eventUnPicker').style.display='';
		success_pickedLocality(r);
	}
}
function pickedLocality () {
	var locality_id = document.getElementById('locality_id').value;
	var pid = document.getElementById('fetched_locid').value;
	var collecting_event_id = document.getElementById('collecting_event_id').value;
	if (collecting_event_id.length>0){
		locality_id.value='';
		return false;
	}
	if (locality_id==pid){
		return false;
	}
	if (locality_id.length > 0) {
		jQuery.getJSON("/component/DataEntry.cfc",
			{
				method : "get_picked_locality",
				locality_id : locality_id,
				returnformat : "json",
				queryformat : 'column'
			},
			success_pickedLocality
		);
	}
}
function success_pickedLocality (r) {
	result=r.DATA;
	var locality_id=result.LOCALITY_ID[0];
	if (locality_id < 0) {
		alert('Oops! Something bad happend with the locality pick. ' + result.MSG[0]);
	} else {
		var HIGHER_GEOG = result.HIGHER_GEOG[0];
		var MAXIMUM_ELEVATION = result.MAXIMUM_ELEVATION[0];
		var MINIMUM_ELEVATION = result.MINIMUM_ELEVATION[0];
		var ORIG_ELEV_UNITS = result.ORIG_ELEV_UNITS[0];
		var SPEC_LOCALITY = result.SPEC_LOCALITY[0];
		var LOCALITY_REMARKS = result.LOCALITY_REMARKS[0];
		var LAT_DEG = result.LAT_DEG[0];
		var DEC_LAT_MIN = result.DEC_LAT_MIN[0];
		var LAT_MIN = result.LAT_MIN[0];
		var LAT_SEC = result.LAT_SEC[0];
		var LAT_DIR = result.LAT_DIR[0];
		var LONG_DEG = result.LONG_DEG[0];
		var DEC_LONG_MIN = result.DEC_LONG_MIN[0];
		var LONG_MIN = result.LONG_MIN[0];
		var LONG_SEC = result.LONG_SEC[0];
		var LONG_DIR = result.LONG_DIR[0];
		var DEC_LAT = result.DEC_LAT[0];
		var DEC_LONG = result.DEC_LONG[0];		
		var DATUM = result.DATUM[0];
		var ORIG_LAT_LONG_UNITS = result.ORIG_LAT_LONG_UNITS[0];
		var DETERMINED_BY = result.DETERMINED_BY[0];
		var DETERMINED_DATE = result.DETERMINED_DATE[0];
		var LAT_LONG_REF_SOURCE = result.LAT_LONG_REF_SOURCE[0];
		var LAT_LONG_REMARKS = result.LAT_LONG_REMARKS[0];
		var MAX_ERROR_DISTANCE = result.MAX_ERROR_DISTANCE[0];
		var MAX_ERROR_UNITS = result.MAX_ERROR_UNITS[0];
		var EXTENT = result.EXTENT[0];
		var GPSACCURACY = result.GPSACCURACY[0];
		var GEOREFMETHOD = result.GEOREFMETHOD[0];
		var VERIFICATIONSTATUS = result.VERIFICATIONSTATUS[0];
		document.getElementById('fetched_locid').value=locality_id;
		document.getElementById('higher_geog').value = HIGHER_GEOG;
		document.getElementById('higher_geog').className='readClr';
		document.getElementById('higher_geog').setAttribute('readonly','readonly');
		document.getElementById('maximum_elevation').value = MAXIMUM_ELEVATION;
		document.getElementById('maximum_elevation').className='readClr';
		document.getElementById('maximum_elevation').setAttribute('readonly','readonly');
		document.getElementById('minimum_elevation').value = MINIMUM_ELEVATION;
		document.getElementById('minimum_elevation').className='readClr';
		document.getElementById('minimum_elevation').setAttribute('readonly','readonly');
		document.getElementById('orig_elev_units').value = ORIG_ELEV_UNITS;
		document.getElementById('orig_elev_units').className='readClr';
		document.getElementById('orig_elev_units').setAttribute('readonly','readonly');
		document.getElementById('spec_locality').value = SPEC_LOCALITY;
		document.getElementById('spec_locality').className='readClr';
		document.getElementById('spec_locality').setAttribute('readonly','readonly');
		document.getElementById('locality_remarks').value = LOCALITY_REMARKS;
		document.getElementById('locality_remarks').className='readClr';
		document.getElementById('locality_remarks').setAttribute('readonly','readonly');
		document.getElementById('latdeg').value = LAT_DEG;
		document.getElementById('latdeg').className='readClr';
		document.getElementById('latdeg').setAttribute('readonly','readonly');
		document.getElementById('decLAT_DEG').value = LAT_DEG;
		document.getElementById('decLAT_DEG').className='readClr';
		document.getElementById('decLAT_DEG').setAttribute('readonly','readonly');
		document.getElementById('latmin').value = LAT_MIN;
		document.getElementById('latmin').className='readClr';
		document.getElementById('latmin').setAttribute('readonly','readonly');
		document.getElementById('latsec').value = LAT_SEC;
		document.getElementById('latsec').className='readClr';
		document.getElementById('latsec').setAttribute('readonly','readonly');
		document.getElementById('latdir').value = LAT_DIR;
		document.getElementById('latdir').className='readClr';
		document.getElementById('latdir').setAttribute('readonly','readonly');
		document.getElementById('longdeg').value = LONG_DEG;
		document.getElementById('longdeg').className='readClr';
		document.getElementById('longdeg').setAttribute('readonly','readonly');
		document.getElementById('longmin').value = LONG_MIN;
		document.getElementById('longmin').className='readClr';
		document.getElementById('longmin').setAttribute('readonly','readonly');
		document.getElementById('longsec').value = LONG_SEC;
		document.getElementById('longsec').className='readClr';
		document.getElementById('longsec').setAttribute('readonly','readonly');
		document.getElementById('longdir').value = LONG_DIR;
		document.getElementById('longdir').className='readClr';
		document.getElementById('longdir').setAttribute('readonly','readonly');
		document.getElementById('dec_lat_min').value = DEC_LAT_MIN;
		document.getElementById('dec_lat_min').className='readClr';
		document.getElementById('dec_lat_min').setAttribute('readonly','readonly');
		document.getElementById('decLAT_DIR').value = LAT_DIR;
		document.getElementById('decLAT_DIR').className='readClr';
		document.getElementById('decLAT_DIR').setAttribute('readonly','readonly');
		document.getElementById('decLONGDEG').value = LONG_DEG;
		document.getElementById('decLONGDEG').className='readClr';
		document.getElementById('decLONGDEG').setAttribute('readonly','readonly');
		document.getElementById('dec_long_min').value = DEC_LONG_MIN;
		document.getElementById('dec_long_min').className='readClr';
		document.getElementById('dec_long_min').setAttribute('readonly','readonly');
		document.getElementById('decLONGDIR').value = LONG_DIR;
		document.getElementById('decLONGDIR').className='readClr';
		document.getElementById('decLONGDIR').setAttribute('readonly','readonly');
		document.getElementById('dec_lat').value = DEC_LAT;
		document.getElementById('dec_lat').className='readClr';
		document.getElementById('dec_lat').setAttribute('readonly','readonly');
		document.getElementById('dec_long').value = DEC_LONG;
		document.getElementById('dec_long').className='readClr';
		document.getElementById('dec_long').setAttribute('readonly','readonly');
		document.getElementById('max_error_distance').value = MAX_ERROR_DISTANCE;
		document.getElementById('max_error_distance').className='readClr';
		document.getElementById('max_error_distance').setAttribute('readonly','readonly');		
		document.getElementById('max_error_units').value = MAX_ERROR_UNITS;
		document.getElementById('max_error_units').className='readClr';
		document.getElementById('max_error_units').setAttribute('readonly','readonly');	
		document.getElementById('extent').value = EXTENT;
		document.getElementById('extent').className='readClr';
		document.getElementById('extent').setAttribute('readonly','readonly');
		document.getElementById('gpsaccuracy').value = GPSACCURACY;
		document.getElementById('gpsaccuracy').className='readClr';
		document.getElementById('gpsaccuracy').setAttribute('readonly','readonly');
		document.getElementById('datum').value = DATUM;
		document.getElementById('datum').className='readClr';
		document.getElementById('datum').setAttribute('readonly','readonly');
		document.getElementById('determined_by_agent').value = DETERMINED_BY;
		document.getElementById('determined_by_agent').className='readClr';
		document.getElementById('determined_by_agent').setAttribute('readonly','readonly');		
		document.getElementById('determined_date').value = DETERMINED_DATE;
		document.getElementById('determined_date').className='readClr';
		document.getElementById('determined_date').setAttribute('readonly','readonly');	
		document.getElementById('lat_long_ref_source').value = LAT_LONG_REF_SOURCE;
		document.getElementById('lat_long_ref_source').className='readClr';
		document.getElementById('lat_long_ref_source').setAttribute('readonly','readonly');
		document.getElementById('georefmethod').value = GEOREFMETHOD;
		document.getElementById('georefmethod').className='readClr';
		document.getElementById('georefmethod').setAttribute('readonly','readonly');
		document.getElementById('verificationstatus').value = VERIFICATIONSTATUS;
		document.getElementById('verificationstatus').className='readClr';
		document.getElementById('verificationstatus').setAttribute('readonly','readonly');
		document.getElementById('lat_long_remarks').value = LAT_LONG_REMARKS;
		document.getElementById('lat_long_remarks').className='readClr';
		document.getElementById('lat_long_remarks').setAttribute('readonly','readonly');
		switchActive(ORIG_LAT_LONG_UNITS);
		document.getElementById('orig_lat_long_units').value = ORIG_LAT_LONG_UNITS;
		document.getElementById('orig_lat_long_units').className='readClr';
		document.getElementById('orig_lat_long_units').setAttribute('readonly','readonly');
		document.getElementById('localityPicker').style.display='none';
		document.getElementById('localityUnPicker').style.display='';
		if (result.length > 6) {
			alert('Whoa! That is a lot of geology attribtues. They will not all be displayed here, but the locality will still have them.');
		}
		try {
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
				document.getElementById(aID).className='readClr';
				document.getElementById(aID).setAttribute('readonly','readonly');
				document.getElementById(vID).className='readClr';
				document.getElementById(vID).setAttribute('readonly','readonly');
				document.getElementById(dID).className='readClr';
				document.getElementById(dID).setAttribute('readonly','readonly');
				document.getElementById(ddID).className='readClr';
				document.getElementById(ddID).setAttribute('readonly','readonly');
				document.getElementById(mID).className='readClr';
				document.getElementById(mID).setAttribute('readonly','readonly');
				document.getElementById(rID).className='readClr';
				document.getElementById(rID).setAttribute('readonly','readonly');
			}
			for (i=0;i<result.length;i++) {
				if (i<5) {
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
}
function catNumSeq () {
	var catnum = document.getElementById('cat_num').value;
	var isCatNum = catnum.length;
	if (isCatNum == 0) { // only get the number if there's not already one in place
		var inst = document.getElementById('institution_acronym').value;
		var coll = document.getElementById('collection_cde').value;			
		var coll_id = inst + " " + coll;
		jQuery.getJSON("/component/DataEntry.cfc",
			{
				method : "getcatNumSeq",
				coll : coll_id,
				returnformat : "json",
				queryformat : 'column'
			},
			function(result){
				var catnum = document.getElementById('cat_num');
				catnum.value=result;
			}
		);
	}
}
function getAttributeStuff (attribute,element) {
	var isSomething = attribute.length;
	if (isSomething > 0) {
		var optn = document.getElementById(element);
		optn.style.backgroundColor='red';
		var thisCC = document.getElementById('collection_cde').value;
		jQuery.getJSON("/component/DataEntry.cfc",
			{
				method : "getAttCodeTbl",
				attribute : attribute,
				collection_cde : thisCC,
				element : element,
				returnformat : "json",
				queryformat : 'column'
			},
			success_getAttributeStuff
		);
	}
}
function success_getAttributeStuff (r) {
	var result=r.DATA;
	var resType=result.V[0];
	var theEl=result.V[1];
	var optn = document.getElementById(theEl);
	optn.style.backgroundColor='';
	var n=result.V.length;
	var theNumber = theEl.replace("attribute_","");
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
		var theDivName = "attribute_value_cell_" + theNumber;
		var theTextDivName = "attribute_units_cell_" + theNumber;
		theSelectName = "attribute_value_" + theNumber;
		theTextName = "attribute_units_" + theNumber;
	}
	var theDiv = document.getElementById(theDivName);
	var theText = document.getElementById(theTextDivName);
	if (resType == 'value' || resType == 'units') {
		theDiv.innerHTML = ''; // clear it out
		theText.innerHTML = '';
		if (n > 2) {
			var theNewSelect = document.createElement('SELECT');
			theNewSelect.name = theSelectName;
			theNewSelect.id = theSelectName;
			if (resType == 'units') {
				var sWid = '60px;';
			} else {
				var sWid = '90px;';
			}
			theNewSelect.style.width=sWid;
			theNewSelect.className = "";
			var a = document.createElement("option");
			a.text = '';
    		a.value = '';
			theNewSelect.appendChild(a);// add blank
			for (i=2;i<result.V.length;i++) {
				var theStr = result.V[i];
				var a = document.createElement("option");
				a.text = theStr;
				a.value = theStr;
				theNewSelect.appendChild(a);
			}
			theDiv.appendChild(theNewSelect);
			if (resType == 'units') {
				var theNewText = document.createElement('INPUT');
				theNewText.name = theTextName;
				theNewText.id = theTextName;	
				theNewText.type="text";
				theNewText.style.width='95px';
				theNewText.className = "";
				theText.appendChild(theNewText);
			}
		}
	} else if (resType == 'NONE') {
		theDiv.innerHTML = '';
		theText.innerHTML = '';
		var theNewText = document.createElement('INPUT');
		theNewText.name = theSelectName;
		theNewText.id = theSelectName;	
		theNewText.type="text";
		theNewText.style.width='95px';
		theNewText.className = "";
		theDiv.appendChild(theNewText);
	} else {
		alert('Something bad happened! Try selecting nothing, then re-selecting an attribute or reloading this page');
	}
}