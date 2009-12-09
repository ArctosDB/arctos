function loadTAG(mid,muri){
	$("imgDiv").text('Loading image and tags.....');
	var d='<div id="navDiv"><div id="info"></div>';
	d+='<a href="/media/' + mid + '">Back to Media</a>';	
	d+='</div>';
	$('body').append(d);
	
	
	var d='<form name="f">';
	d+='<label for="RefType_new">Create TAG type....</label>';
	d+='<div id="newRefCell" class="newRec">';
	d+='<select id="RefType_new" name="RefType_new" onchange="pickRefType(this.id,this.value);">';
	d+='<option value=""></option>';
	d+='<option value="comment">Comment Only</option>';
	d+='<option value="cataloged_item">Cataloged Item</option>';
	d+='<option value="collecting_event">Collecting Event</option>';
	d+='<option value="locality">Locality</option>';
	d+='<option value="agent">Agent</option>';
	d+='</select>';
	d+='<span id="newRefHidden" style="display:none">';
	d+='<label for="RefStr_new">Reference</label>';
	d+='<input type="text" id="RefStr_new" name="RefStr_new" size="50">';
	d+='<input type="hidden" id="RefId_new" name="RefId_new">';
	d+='<label for="Remark_new">Remark</label>';
	d+='<input type="text" id="Remark_new" name="Remark_new" size="50">';
	d+='<input type="hidden" id="t_new">';
	d+='<input type="hidden" id="l_new">';
	d+='<input type="hidden" id="h_new">';
	d+='<input type="hidden" id="w_new">';
	d+='<br>';
	d+='<input type="button" id="newRefBtn" value="create TAG">';
	d+='</span>';
	d+='<input type="hidden" id="imgURL" value="' + muri + '">';
	d+='<input type="hidden" id="media_id" name="media_id" value="' + mid + '">';
	d+='<input type="hidden" name="imgH" id="imgH">';
	d+='<input type="hidden" name="imgW" id="imgW">';
	d+='<div id="editRefDiv"></div>';
	d+='</form>';	
	$("#navDiv").append(d);
	
	

	$('#imgDiv').getImg2Tag($("#imgURL").val(),function() {
		$("#imgH").val($('#theImage').height());
		$("#imgW").val($('#theImage').width());
		loadInitial();	
	});
}

jQuery(document).ready(function () { 
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