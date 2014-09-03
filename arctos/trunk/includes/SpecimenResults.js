var map;
var bounds;
var markers = new Array();

function fetchSrchWgtVocab(key,scope){
	var h,i;
	$("#voccell_" + key).html('<img src="/images/indicator.gif">');
	jQuery.getJSON("/component/SpecimenResults.cfc",
		{
			method : "getVocabulary",
			key : key,
			scope : scope,
			returnformat : "json",
			queryformat : 'column'
		},
		function(r) {
			if (r.DATA.V.length===0){
				h='no suggestions found';				
			} else {
				h='<select id="svc_' + key + '" class="ssw_sngselect" onchange="$(\'#' + key + '\').val(this.value);">';
				h+='<option value=""></option>';
				for (i=0; i<r.ROWCOUNT; ++i) {
					h+='<option value="' + r.DATA.V[i];
					if (r.DATA.M[i] > 1) {
						h+='" class="usedValue"';
					}
					h+='">' + r.DATA.V[i] + '</option>';
				}
				h+='</select>';
			}
			$("#voccell_" + key).html(h);
		}
	);
}
function initializeMap() {
	// just nuke the old map
	$("#spresmapdiv").html('');
	var infowindow = new google.maps.InfoWindow();
	var mapOptions = {
		zoom: 3,
	    center: new google.maps.LatLng(55, -135),
	    mapTypeId: google.maps.MapTypeId.ROADMAP,
	    panControl: false,
	    scaleControl: true
	};
	map = new google.maps.Map(document.getElementById('spresmapdiv'),mapOptions);
	var cfgml=$("#cfgml").val();
	if (cfgml.length==0){
		return false;
	}
	var arrCP = cfgml.split( ";" );
	for (var i=0; i < arrCP.length; i++){
		createMarker(arrCP[i]);
	}
	var bounds = new google.maps.LatLngBounds();
	for (var i=0; i < markers.length; i++) {
	   bounds.extend(markers[i].getPosition());
	}
	// Don't zoom in too far on only one marker
    if (bounds.getNorthEast().equals(bounds.getSouthWest())) {
       var extendPoint1 = new google.maps.LatLng(bounds.getNorthEast().lat() + 0.05, bounds.getNorthEast().lng() + 0.05);
       var extendPoint2 = new google.maps.LatLng(bounds.getNorthEast().lat() - 0.05, bounds.getNorthEast().lng() - 0.05);
       bounds.extend(extendPoint1);
       bounds.extend(extendPoint2);
    }
	map.fitBounds(bounds);
}

function createMarker(p) {
	var cpa=p.split(",");
	var ns=cpa[0];
	var lat=cpa[1];
	var lon=cpa[2];
	var r=cpa[3];					
	var center=new google.maps.LatLng(lat, lon);
	var circleoptn = {
		strokeColor: '#FF0000',
		strokeOpacity: 0.8,
		strokeWeight: 2,
		fillColor: '#FF0000',
		fillOpacity: 0.15,
		map: map,
		center: center,
		radius: parseInt(r),
		zIndex:-99
	};
	var contentString= ns + ' specimens; Error(m)=' + r + '<br><span class="likeLink" onclick="addCoordinates(' + "'" + lat + ',' + lon + "'" + ');">add point to search</span>';
	crcl = new google.maps.Circle(circleoptn);
	var marker = new google.maps.Marker({
		position: center,
		map: map,
		title: ns + ' specimens; Error(m)=' + r,
		contentString: contentString,
		zIndex: 10
	});
	markers.push(marker);
    var infowindow = new google.maps.InfoWindow({
        content: contentString
    });
    google.maps.event.addListener(marker, 'click', function() {
        infowindow.open(map,marker);
    });  
}


function confirmAddAllDL(){
	var yesno=confirm('Are you sure you want to add all these specimens to the data loan?');
	if (yesno==true) {
		document.location='/Loan.cfm?action=addAllDataLoanItems&transaction_id=' + $("#transaction_id").val();  		
 	} else {
	  	return false;
  	}
}
function confirmAddAllPartLoan(){
	var part_name=$("#part_name").val();
	var msg='Are you sure you want to add all found ' + part_name + ' to the loan?';
	var yesno=confirm(msg);
	if (yesno==true) {
		document.location='/Loan.cfm?action=addAllSrchResultLoanItems&transaction_id=' + $("#transaction_id").val() + '&part_name=' + encodeURIComponent(part_name);  		
 	} else {
	  	return false;
  	}
}

$(document).ready(function () {
	jQuery("#cntr_refineSearchTerms").html("<img src='/images/indicator.gif'>");
	var ptl='/component/SpecimenResults.cfc?method=get_specSrchTermWidget&returnformat=plain';
	jQuery.get(ptl, function(data){
		jQuery("#cntr_refineSearchTerms").html(data);
	});
    initializeMap();
	$( "#srmapctrls-nomap" ).click(function() {
		//("#srmapctrls-nomap").hide();
		//$("#spresmapdiv").show();
		//$("#srmapctrls").show();
		resizeMap('smallmap');
	});
	$("#usertools").change(function() {
		if (this.value=='BerkeleyMapper'){
			window.open("/bnhmMaps/bnhmMapData.cfm?" + $("#mapURL").val(), "_blank");
		} else if (this.value=='BerkeleyMapperRM') {
			window.open("/bnhmMaps/bnhmMapData.cfm?showRangeMaps=true&" + $("#mapURL").val(), "_blank");
		} else if (this.value=='google') {
			window.open("/bnhmMaps/kml.cfm", "_blank");
		}
	});
});


function toggleSearchTerms(){
	if($("#refineSearchTerms").is(":visible")) {
		var v=0;
	} else {
		var v=1;
		}
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "setResultsBrowsePrefs",
			val : v,
			returnformat : "json",
			queryformat : 'column'
		},
		function() {
			if (v==1){
				jQuery("#cntr_refineSearchTerms").html("<img src='/images/indicator.gif'>");
				var ptl='/component/SpecimenResults.cfc?method=get_specSrchTermWidget&returnformat=plain';
				jQuery.get(ptl, function(data){
					jQuery("#cntr_refineSearchTerms").html(data);
				});
			} else {
				$('#refineSearchTerms').remove();
				$('#aboutSTWH').remove();
				$('#fbSWT').remove();
			}
		}
	);
	
}
function pickedTool(){
	var v;
	v=$("#usertools").val();
	if (v=='BerkeleyMapper'){
		window.open("/bnhmMaps/bnhmMapData.cfm?" + $("#mapURL").val(), "_blank");
	} else if (v=='BerkeleyMapperRM') {
		window.open("/bnhmMaps/bnhmMapData.cfm?showRangeMaps=true&" + $("#mapURL").val(), "_blank");
	} else if (v=='google') {
		window.open("/bnhmMaps/kml.cfm", "_blank");
	} else if (v=='customize') {
		openCustomize();
	} else if (v=='removeRows') {
		removeRows();
	} else if (v=='saveSearch') {
		t=
		saveSearch($("#ServerRootUrl").val() + '/SpecimenResults.cfm?' + $("#mapURL").val());
	} else if (v=='download') {
		window.open('/SpecimenResultsDownload.cfm?tableName=' + $("#SpecSrchTab").val(),'_blank');
	}
	$("#usertools").val('');
}

function openCustomize(){
	var guts = "/info/SpecimenResultsPrefs.cfm";
    $("<div class='popupDialog'><img src='/images/indicator.gif'></div>")
    .dialog({
        autoOpen: true,
        closeOnEscape: true,
        height: 'auto',
        modal: true,
        position: ['center', 'center'],
        title: 'Customize results and downloads. Excessive options adversely affect performance.',
        width: 'auto',
        buttons : {
            "Save and refresh" : function(){
            	closeCustom();
            }
        }
    }).load(guts, function() {
        $(this).dialog("option", "position", ['center', 'center'] );
    });
    $(window).resize(function() {
    	$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
    });
	
}
function resizeMap(s){
	if (s=='nomap') {
		$("#srmapctrls-nomap").show();
		$("#srmapctrls").hide();
		$("#spresmapdiv").hide();
	} else {
		$("#srmapctrls-nomap").hide();
		$("#srmapctrls").show();
		$("#spresmapdiv").show();
		$("#spresmapdiv").removeClass().addClass(s);
		initializeMap();
	}
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "changeUserPreference",
			pref : "srmapclass",
			val : s,
			returnformat : "json",
			queryformat : 'column'
		}
	);
}
$("#customizeButton").live('click', function(e){
	var guts = "/info/SpecimenResultsPrefs.cfm";
    $("<div class='popupDialog'><img src='/images/indicator.gif'></div>")
    .dialog({
        autoOpen: true,
        closeOnEscape: true,
        height: 'auto',
        modal: true,
        position: ['center', 'center'],
        title: 'Customize results and downloads. Excessive options adversely affect performance.',
        width: 'auto',
        buttons : {
            "Save and refresh" : function(){
            	closeCustom();
            }
        }
    }).load(guts, function() {
        $(this).dialog("option", "position", ['center', 'center'] );
    });
    $(window).resize(function() {
    	$(".ui-dialog-content").dialog("option", "position", ['center', 'center']);
    });
});
function closeCustom() {
	var murl='SpecimenResults.cfm?' + $("#mapURL").val();
	window.location=murl;
}
function getPostLoadJunk(){
	var coidlistAR=new Array();
	$("div[id^='CatItem_']").each(function() {
		var id = this.id.split('_')[1];
		coidlistAR.push(id);
	});
	var coidList = coidlistAR.toString();
	insertMedia(coidList);
	insertTypes(coidList);
	injectLoanPick();
	displayMedia();
}

function displayMedia(idList){
	$("div[id^='jsonmedia_']").each(function() {
		var r = $.parseJSON($("#" + this.id).html());
		if (r.ROWCOUNT>0){
			var theHTML='<div class="shortThumb"><div class="thumb_spcr">&nbsp;</div>';
			for (i=0; i<r.ROWCOUNT; ++i) {
				if (r.DATA.mimecat[i]=='audio' && r.DATA.media_uri[i].split('.').pop()=='mp3'){
					theHTML+='<div class="one_thumb">';
					theHTML+='<audio controls>';
					theHTML+='<source src="' + r.DATA.media_uri[i] + '" type="audio/mp3">';
					theHTML+='<a href="/exit.cfm?target=' + r.DATA.media_uri[i] + '" target="_blank">download</a>';
					theHTML+='</audio> ';
					theHTML+='<br><a target="_blank" href="/media/' + r.DATA.media_id[i] + '">Media Detail</a></p></div>';
				} else {
					var theURL='/component/functions.cfc?method=getMediaPreview&preview_uri=' + r.DATA.preview_uri[i] + '&media_type=' +  r.DATA.mimecat[i] + '&returnformat=json&queryformat=column';
					$.ajax({
						url: theURL,
						dataType: 'json',
						async: false,
						success: function(result) {
							theHTML+='<div class="one_thumb">';
							theHTML+='<a href="/exit.cfm?target=' + r.DATA.media_uri[i] + '" target="_blank">';
							theHTML+='<img src="' + result + '" class="theThumb"></a>';
							theHTML+='<p>' + r.DATA.mimecat[i] + ' (' + r.DATA.mime_type[i] + ')';
							theHTML+='<br><a target="_blank" href="/media/' + r.DATA.media_id[i] + '">Media Detail</a></p></div>';
						}
					});
				}
			}
			theHTML+='<div class="thumb_spcr">&nbsp;</div></div>';
			$("#" + this.id).html(theHTML);
		} else {
			$("#" + this.id).html('');
		}
	});
}
function insertMedia(idList) {
	var s=document.createElement('DIV');
	s.id='ajaxStatus';
	s.className='ajaxStatus';
	s.innerHTML='Checking for Media...';
	document.body.appendChild(s);
	jQuery.getJSON("/component/SpecimenResults.cfc",
		{
			method : "getMedia",
			idList : idList,
			returnformat : "json",
			queryformat : 'column'
		},
		function (result) {
			try{
				var sBox=document.getElementById('ajaxStatus');
				sBox.innerHTML='Processing Media....';
				for (i=0; i<result.ROWCOUNT; ++i) {
					var sel;
					var sid=result.DATA.COLLECTION_OBJECT_ID[i];
					var mid=result.DATA.MEDIA_ID[i];
					var rel=result.DATA.MEDIA_RELATIONSHIP[i];
					if (rel=='cataloged_item') {
						sel='CatItem_' + sid;
					} else if (rel=='collecting_event') {
						sel='SpecLocality_' + sid;
					}
					if (sel.length>0){
						var el=document.getElementById(sel);
						var ns='<a href="/MediaSearch.cfm?action=search&media_id='+mid+'" class="mediaLink" target="_blank" id="mediaSpan_'+sid+'">';
						ns+='Media';
						ns+='</a>';
						el.innerHTML+=ns;
					}
				}
				document.body.removeChild(sBox);
				}
			catch(e) {
				sBox=document.getElementById('ajaxStatus');
				document.body.removeChild(sBox);
			}
		}
	);
}
function insertTypes(idList) {
	var s=document.createElement('DIV');
	s.id='ajaxStatus';
	s.className='ajaxStatus';
	s.innerHTML='Checking for Types...';
	document.body.appendChild(s);
	jQuery.getJSON("/component/SpecimenResults.cfc",
		{
			method : "getTypes",
			idList : idList,
			returnformat : "json",
			queryformat : 'column'
		},
		function (result) {
			var sBox=document.getElementById('ajaxStatus');
			try{
				sBox.innerHTML='Processing Types....';
				for (i=0; i<result.ROWCOUNT; ++i) {
					var sid=result.DATA.COLLECTION_OBJECT_ID[i];
					var tl=result.DATA.TYPELIST[i];
					var sel='CatItem_' + sid;
					if (sel.length>0){
						var el=document.getElementById(sel);
						var ns='<div class="showType">' + tl + '</div>';
						el.innerHTML+=ns;
					}
				}
			}
			catch(e){}
			document.body.removeChild(sBox);
		}
	);
}

function injectLoanPick() {
	var transaction_id=$("#transaction_id").val();
	if (transaction_id) {
		$( "body" ).append('<div id="ajaxStatus" class="ajaxStatus">Feching Loan Pick...</div>')
		jQuery.getJSON("/component/SpecimenResults.cfc",
			{
				method : "getLoanPartResults",
				transaction_id : transaction_id,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				$("div[id^='CatItem_']").each(function(){ 
					var x=this.id.split(/_(.+)?/)[1];
					var gotsomething=false;					
					var theTable='<table border width="100%">';
					for (i=0; i<r.ROWCOUNT; ++i) {
						if (r.DATA.COLLECTION_OBJECT_ID[i]==x){
							gotsomething=true;
							theTable+='<tr><td nowrap="nowrap" class="specResultPartCell"><i>' + r.DATA.PART_NAME[i];
							if (r.DATA.SAMPLED_FROM_OBJ_ID[i] > 0) {
								theTable += '&nbsp;sample';
							}
							theTable += "&nbsp;(" + r.DATA.COLL_OBJ_DISPOSITION[i] + ")</i> [" + r.DATA.BARCODE[i] + "]";
							theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
							theTable += 'Remark:&nbsp;<input type="text" name="item_remark" size="10" id="item_remark_' + r.DATA.PARTID[i] + '">';
							theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
							theTable += 'Instr.:&nbsp;<input type="text" name="item_instructions" size="10" id="item_instructions_' + r.DATA.PARTID[i] + '">';
							theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
							theTable += 'Subsample?:&nbsp;<input type="checkbox" name="subsample" id="subsample_' + r.DATA.PARTID[i] + '">';
							theTable += '</td><td nowrap="nowrap" class="specResultPartCell">';
							theTable += '<input type="button" id="theButton_' + r.DATA.PARTID[i] + '"';
							theTable += ' class="insBtn"';
							if (r.DATA.TRANSACTION_ID[i] > 0) {
								theTable += ' onclick="" value="In Loan">';
							} else {
								theTable += ' value="Add" onclick="addPartToLoan(';
								theTable += r.DATA.PARTID[i] + ');">';
							}
							if (r.DATA.ENCUMBRANCE_ACTION[i]!==null) {
								theTable += '<br><i>Encumbrances:&nbsp;' + r.DATA.ENCUMBRANCE_ACTION[i] + '</i>';
							}
							theTable +="</td></tr>";
						}
					}
					if (gotsomething){
						theTable +='</table>';
						$("#CatItem_" + x).append(theTable);
					}
				});
				$("#ajaxStatus").remove();
			}
		);
	} // no transaction_id just abort
}
function addPartToLoan(partID) {
	var rs = "item_remark_" + partID;
	var is = "item_instructions_" + partID;
	var ss = "subsample_" + partID;
	var remark=document.getElementById(rs).value;
	var instructions=document.getElementById(is).value;
	var subsample=document.getElementById(ss).checked;
	if (subsample==true) {
		subsample=1;
	} else {
		subsample=0;
	}
	var transaction_id=document.getElementById('transaction_id').value;
	jQuery.getJSON("/component/functions.cfc",
		{
			method : "addPartToLoan",
			transaction_id : transaction_id,
			partID : partID,
			remark : remark,
			instructions : instructions,
			subsample : subsample,
			returnformat : "json",
			queryformat : 'column'
		},
		function (result) {
			var rar = result.split("|");
			var status=rar[0];
			if (status==1){
				var b = "theButton_" + rar[1];
				var theBtn = document.getElementById(b);
				theBtn.value="In Loan";
				theBtn.onclick="";	
			}else{
				var msg = rar[1];
				alert('An error occured!\n' + msg);
			}
		}
	);
}
function reporter(tablename) {
	var f=document.getElementById('goWhere').value;
	if (f.length==0) {
		alert ('Pick a tool, then click the button.');
		return false;
	}
	var t=tablename;
	//var o1=document.getElementById('orderBy1').value;
	//var o2=document.getElementById('orderBy2').value;
	//var s=o1 + ',' + o2;
	var s='guid';
	var u = f;
	var sep="?";
	if (f.indexOf('?') > 0) {
		sep='&';
	}
	u += sep;
	u += '&table_name=' + t;
	u += '&sort=' + s;
	

	$("#goWhere")[0].selectedIndex = 0;

	
	
	var reportWin=window.open(u);
}
function removeRows() {
	var $selectedRows = $('#specresults').jtable('selectedRows');
	if ($selectedRows.length > 0) {
		var ecoid=[];
         $selectedRows.each(function () {
             var record = $(this).data('record');
             ecoid.push(record.COLLECTION_OBJECT_ID);
         });
         var rurl='/SpecimenResults.cfm?' + $("#mapURL").val() + '&exclCollObjId=' + ecoid.join(',');
         document.location=rurl;
     } else {
    	 alert('select rows, then click');
     }
}

function addCoordinates(c){
	if($("#refineSearchTerms").is(":visible")) {
		if ($("#coordinates").length){
			$("#coordinates").val(c);
		} else {
			jQuery.getJSON("/component/SpecimenResults.cfc",
				{
					method : "specSrchTermWidget_addrow",
					term : "coordinates",
					returnformat : "json",
					queryformat : 'column'
				},
				function (result) {
					$('#stermwdgtbl tr:last').after(result);
					$("#newTerm option[value='coordinates']").remove();			
					$("#coordinates").val(c);
				}
			);
		}
	} else {
		alert('turn search terms on, then try that');
	}
}
function queryByViewport(){
	if (! $("#refineSearchTerms").is(":visible")) {
		alert('Turn on the refine widget, then try that click.');
		return false;
	}
		
	var theBounds=map.getBounds();
	var nelat=theBounds.getNorthEast().lat();		
	var nelong=theBounds.getNorthEast().lng();
	var swlat=theBounds.getSouthWest().lat();
	var swlong=theBounds.getSouthWest().lng();
	if ($("#nelat").length==0) {
		jQuery.getJSON("/component/SpecimenResults.cfc",
			{
				method : "specSrchTermWidget_addrow",
				term : "nelat",
				returnformat : "json",
				queryformat : 'column'
			},
			function (result) {
				$('#stermwdgtbl tr:last').after(result);
				$("#newTerm option[value='nelat']").remove();			
				$("#nelat").val(nelat);
			}
		);
	} else {
		$("#nelat").val(nelat);
	}
	if ($("#nelong").length==0) {
		jQuery.getJSON("/component/SpecimenResults.cfc",
			{
				method : "specSrchTermWidget_addrow",
				term : "nelong",
				returnformat : "json",
				queryformat : 'column'
			},
			function (result) {
				$('#stermwdgtbl tr:last').after(result);
				$("#newTerm option[value='nelong']").remove();			
				$("#nelong").val(nelong);
			}
		);
	} else {
		$("#nelong").val(nelong);
	}
	if ($("#swlat").length==0) {
		jQuery.getJSON("/component/SpecimenResults.cfc",
			{
				method : "specSrchTermWidget_addrow",
				term : "swlat",
				returnformat : "json",
				queryformat : 'column'
			},
			function (result) {
				$('#stermwdgtbl tr:last').after(result);
				$("#newTerm option[value='swlat']").remove();			
				$("#swlat").val(swlat);
			}
		);
	} else {
		$("#swlat").val(swlat);
	}
	if ($("#swlong").length==0) {
		jQuery.getJSON("/component/SpecimenResults.cfc",
			{
				method : "specSrchTermWidget_addrow",
				term : "swlong",
				returnformat : "json",
				queryformat : 'column'
			},
			function (result) {
				$('#stermwdgtbl tr:last').after(result);
				$("#newTerm option[value='swlong']").remove();			
				$("#swlong").val(swlong);
			}
		);
	} else {
		$("#swlong").val(swlong);
	}
}

function addARow(tv){
	jQuery.getJSON("/component/SpecimenResults.cfc",
		{
			method : "specSrchTermWidget_addrow",
			term : tv,
			returnformat : "json"
		},
		function (result) {
			$('#stermwdgtbl tr:last').after(result);
			$("#newTerm option[value='" + tv + "']").remove();
		}
	);
}
function removeTerm(key){
	$("#" + key).remove();
	$("#row_" + key).remove();
}
function clearAll(){
	$("##refineResults").find("input[type=text]").val("");
}



function checkMapBB(){
	if ($("#nelat").length>0 && $("#nelong").length>0 && $("#swlat").length>0 && $("#swlong").length>0) {
		var sw=new google.maps.LatLng($("#swlat").val(), $("#swlong").val());
		var ne=new google.maps.LatLng($("#nelat").val(), $("#nelong").val());
		var bounds = new google.maps.LatLngBounds(sw,ne);
		map.fitBounds(bounds);
	}
}