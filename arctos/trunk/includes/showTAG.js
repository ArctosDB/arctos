$.fn.getImg2Tag = function(src, f){
	return this.each(function(){
		var i = new Image();
		i.src = src;
		i.onload = f;
		i.id='theImage';
		$("#imgDiv").html('');
		this.appendChild(i);
	});
}
function scrollToLabel(id) {
	try{
		var divID='refDiv_' + id;
		var paneID='refPane_' + id;
		$("div .highlight").removeClass("highlight").addClass("refDiv");
		$("div .refPane_highlight").removeClass("refPane_highlight");
		$("#" + divID).removeClass("refDiv").addClass("highlight");
		$("#" + paneID).addClass('refPane_highlight');
		$('#navDiv').scrollTo( $('#' + paneID), 800 );
	}catch(e){}
}
function scrollToTag(id) {
	try{
		var divID='refDiv_' + id;
		var paneID='refPane_' + id;
		$("div .highlight").removeClass("highlight").addClass("refDiv");
		$("div .refPane_highlight").removeClass("refPane_highlight");
		$("#" + divID).removeClass("refDiv").addClass("highlight");
		$("#" + paneID).addClass('refPane_highlight');
		document.location.hash = id;
		$(document).scrollTo( $('#' + divID), 800 );
	}catch(e){}
}
function loadTAG(mid,muri){
	$("imgDiv").html('Loading image and tags.....');
	var d='<div id="navDiv"><div id="info"></div>';
	d+='<a href="/media/' + mid + '">Back to Media</a>';
	d+='<form name="f"><input type="hidden" id="imgURL" value="' + muri + '">';
	d+='<input type="hidden" id="media_id" name="media_id" value="' + mid + '"></form>';
	d+='<div id="editRefDiv"></div>';
	d+='</div>';
	$('body').append(d);
	$('#imgDiv').getImg2Tag($("#imgURL").val(),function() {
		$("#imgH").val($('#theImage').height());
		$("#imgW").val($('#theImage').width());
		loadInitial();	
	});
}
function loadInitial(){
	jQuery.getJSON("/component/tag.cfc",
		{
			method : "getTags",
			media_id : $("#media_id").val(),
			returnformat : "json",
			queryformat : 'column'
		},
		function (r) {
			if (r.ROWCOUNT){
				for (i=0; i<r.ROWCOUNT; ++i) {
					var scaledTop=r.DATA.REFTOP[i] * $('#theImage').height() / r.DATA.IMGH[i];
					var scaledLeft=r.DATA.REFLEFT[i] * $('#theImage').width() / r.DATA.IMGW[i];
					var scaledH=r.DATA.REFH[i] * $('#theImage').height() / r.DATA.IMGH[i];
					var scaledW=r.DATA.REFW[i] * $('#theImage').width() / r.DATA.IMGW[i];
					addArea(
						r.DATA.TAG_ID[i],
						scaledTop,
						scaledLeft,
						scaledH,
						scaledW);
					addRefPane(
						r.DATA.TAG_ID[i],
						r.DATA.REFTYPE[i],
						r.DATA.REFSTRING[i],								
						r.DATA.REFID[i],							
						r.DATA.REMARK[i],						
						r.DATA.REFLINK[i],
						scaledTop,
						scaledLeft,
						scaledH,
						scaledW);
				}
			} else {
				alert('An error occurred. Try reloading or file a detailed bug report.');
				}
			}
		);
	if (document.location.hash) {
		var hash=document.location.hash.substring(1);
		setTimeout(function() {scrollToTag(hash);},1000);
		setTimeout(function() {scrollToLabel(hash);},1000);
	}
}

jQuery(document).ready(function () { 
	jQuery("div .refDiv").live('mouseover', function(e){
		var tagID=this.id.replace('refDiv_','');
		modArea(tagID);
	});
	jQuery("div .refDiv, .highlight").live('click', function(e){
		var numID=this.id.replace('refDiv_','');
		scrollToTag(numID);
		scrollToLabel(numID);
	});
	jQuery("div[class^='refPane_']").live('mouseover', function(e){
		var tagID=this.id.replace('refPane_','');
		modArea(tagID);
	});
	jQuery("div[class^='refPane_']").live('click', function(e){
		var numID=this.id.replace('refPane_','');
		scrollToTag(numID);
		scrollToLabel(numID);
	});
});

function addArea(id,t,l,h,w) {
	var dv='<div id="refDiv_' + id + '" class=refDiv style="position:absolute;width:' + w + 'px;height:' + h + 'px;top:' + t + 'px;left:' + l + 'px;"></div>';
	$("#imgDiv").append(dv);
}		
function modArea(id) {
	var divID='refDiv_' + id;
	var paneID='refPane_' + id;
	$("div .highlight").removeClass("highlight").addClass("refDiv");
	$("div .refPane_highlight").removeClass("refPane_highlight");
	// add editing classes to our 2 objects		
	$("#" + divID).removeClass("refDiv").addClass("highlight");
	$("#" + paneID).addClass('refPane_highlight');
}
function addRefPane(id,reftype,refStr,refId,remark,reflink,t,l,h,w) {
	if (refStr==null){refStr='';}
	if (remark==null){remark='';}
	var d='<div id="refPane_' + id + '" class="refPane_' + reftype + '">';
	d+='TAG Type: ' + reftype;
	if(reflink && refStr){
		if (reftype!='agent'){
			d+='<br>Reference: <a href="' + reflink + '" target="_blank">' + refStr + '</a>';
		} else {
			d+='<br>Reference: ' + refStr;
		}
	}	
	if(remark){
		var newremark=remark.replace(/\[\[(.+?)\]\]/g, "<a href='/guid/$1'>$1</a>");
		d+='<br>Remark: ' + newremark;
	}
	$("#editRefDiv").append(d);
}