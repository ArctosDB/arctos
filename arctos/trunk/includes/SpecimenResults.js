$("#customizeButton").live('click', function(e){
	var bgDiv = document.createElement('div');
	bgDiv.id = 'bgDiv';
	bgDiv.className = 'bgDiv';
	bgDiv.setAttribute('onclick','closeCustomNoRefresh()');
	document.body.appendChild(bgDiv);
	var type=this.type;
	var type=$(this).attr('type');
	var dval=$(this).attr('dval');
	var theDiv = document.createElement('div');
	theDiv.id = 'customDiv';
	theDiv.className = 'customBox';
	document.body.appendChild(theDiv);
	var guts = "/info/SpecimenResultsPrefs.cfm";
	$('#customDiv').load(guts,{},function(){
		viewport.init("#customDiv");
	});
});
function closeCustom() {
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);
	var murl='SpecimenResults.cfm?' + document.getElementById('mapURL').value;
	window.location=murl;
}
function closeCustomNoRefresh() {
	var theDiv = document.getElementById('customDiv');
	document.body.removeChild(theDiv);	
	var theDiv = document.getElementById('bgDiv');
	document.body.removeChild(theDiv);
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
				var theURL='/component/functions.cfc?method=getMediaPreview&preview_uri=' + r.DATA.preview_uri[i] + '&media_type=' +  r.DATA.media_type[i] + '&returnformat=json&queryformat=column';
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
		var lastID;
		var s=document.createElement('DIV');
		s.id='ajaxStatus';
		s.className='ajaxStatus';
		s.innerHTML='Feching Loan Pick...';
		document.body.appendChild(s);	
		jQuery.getJSON("/component/SpecimenResults.cfc",
			{
				method : "getLoanPartResults",
				transaction_id : transaction_id,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				for (i=0; i<r.ROWCOUNT; ++i) {
					var cid = 'CatItem_' + r.DATA.COLLECTION_OBJECT_ID[i];
					if (document.getElementById(cid)){
						var theCell = document.getElementById(cid);
						if (lastID == r.DATA.COLLECTION_OBJECT_ID[i]) {
							theTable += "<tr>";
						} else {
							theTable = '<table border width="100%"><tr>';
						}
						theTable += '<td nowrap="nowrap" class="specResultPartCell">';
						theTable += '<i>' + r.DATA.PART_NAME[i];
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
						theTable +="</td>";
						if (r.DATA.COLLECTION_OBJECT_ID[i+1] && r.DATA.COLLECTION_OBJECT_ID[i+1] == r.DATA.COLLECTION_OBJECT_ID[i]) {
							theTable += "</tr>";
						} else {
							theTable += "</tr></table>";
						}
						lastID = r.DATA.COLLECTION_OBJECT_ID[i];
						$("#" + cid).append(theTable);
					} // if item isn't in viewport, do nothing
				} // loopity
			} // end return fn
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
         console.log(ecoid);
         var rurl='/SpecimenResults.cfm?' + $("#mapURL").val() + '&exclCollObjId=' + ecoid.join(',');
         document.location=rurl;
     } else {
    	 alert('select rows, then click');
     }
}







// google maps experiment




var map;
var bounds;
var rectangle;
function initialize() {
	var mapOptions = {
		zoom: 3,
	    center: new google.maps.LatLng(55, -135),
	    mapTypeId: google.maps.MapTypeId.ROADMAP,
	    panControl: true,
	    scaleControl: true
	};
	map = new google.maps.Map(document.getElementById('map_canvas'),mapOptions);
	

	var mcd = document.createElement('div');
	mcd.id='mcd';
	mcd.style.cursor="pointer";
	var cImg=document.createElement("img");
	cImg.src='/images/selector.png';
	mcd.appendChild(cImg);
	map.controls[google.maps.ControlPosition.TOP_CENTER].push(mcd);
	google.maps.event.addDomListener(mcd, 'click', function() {
	  selectControlClicked();
	});
	
	
	
}



