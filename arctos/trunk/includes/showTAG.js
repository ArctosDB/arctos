$.fn.getImg2Tag = function(src, f){
	return this.each(function(){
		var i = new Image();
		i.src = src;
		i.onload = f;
		i.id='theImage';
		$("#imgDiv").html('');
		console.log('getImg2Tag' + src);
		this.appendChild(i);
	});
}
	
function loadTAG(mid,muri){
	console.log('loading');
	$("imgDiv").html('Loading image and tags.....');
	var d='<div id="navDiv"><div id="info"></div>';
	d+='<a href="/media/' + mid + '">Back to Media</a>';	
	d+='</div>';
	$('body').append(d);
	

	$('#imgDiv').getImg2Tag($("#imgURL").val(),function() {
		$("#imgH").val($('#theImage').height());
		$("#imgW").val($('#theImage').width());
		loadInitial();	
	});
	
	console.log('going to loadInitial');
}
function loadInitial(){
	
	console.log('at to loadInitial');

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
}

jQuery(document).ready(function () { 
		jQuery("div .refDiv").live('mouseover', function(e){
			var tagID=this.id.replace('refDiv_','');
			modArea(tagID);
		});
		jQuery("div .refDiv, .editing").live('click', function(e){
			var tagID='refPane_' + this.id.replace('refDiv_','');
			$('#navDiv').scrollTo( $('#' + tagID), 800 );
		});
		
			
		jQuery("div[class^='refPane_']").live('mouseover', function(e){
			var tagID=this.id.replace('refPane_','');
			modArea(tagID);
		});
		
		jQuery("div[class^='refPane_']").live('click', function(e){
			var tagID='refDiv_' + this.id.replace('refPane_','');
			$(document).scrollTo( $('#' + tagID), 800 );
		});
	});

	function addArea(id,t,l,h,w) {
		var dv='<div id="refDiv_' + id + '" class=refDiv style="position:absolute;width:' + w + 'px;height:' + h + 'px;top:' + t + 'px;left:' + l + 'px;"></div>';
		$("#imgDiv").append(dv);
	}		
	function modArea(id) {
		var divID='refDiv_' + id;
		var paneID='refPane_' + id;
		$("div .editing").removeClass("editing").addClass("refDiv");
		$("div .refPane_editing").removeClass("refPane_editing");
		// add editing classes to our 2 objects		
		$("#" + divID).removeClass("refDiv").addClass("editing");
		$("#" + paneID).addClass('refPane_editing');
	}
	function addRefPane(id,reftype,refStr,refId,remark,reflink,t,l,h,w) {
		if (refStr==null){refStr='';}
		if (remark==null){remark='';}
		var d='<div id="refPane_' + id + '" class="refPane_' + reftype + '">';
		d+='TAG Type: ' + reftype;
		if(refStr){
			d+='<br>Reference: ' + refStr;
		}	
		if(reflink){
			d+='&nbsp;&nbsp;&nbsp;<a href="' + reflink + '" class="infoLink" target="_blank">[ Click for details ]</a>';
		}	
		if(remark){
			d+='<br>Remark: ' + remark;
		}
		$("#editRefDiv").append(d);
	}
