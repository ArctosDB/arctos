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


jQuery("span[id^='editRefClk_']").live('click', function(e){
	console.log('clicked ' + this.id);
	
	$.each($("span[id^='editRefClk_']"), function() {
	      $("#" + this).hide();
    });

	editRefClk_41
	var tagID=this.id.replace('editRefClk_','');
	// get values out of hiddens that we'll change later
	var RefType=$('#RefType_' + tagID).val();
	var RefStr=$('#RefStr_' + tagID).val();
	var RefId=$('#RefId_' + tagID).val();
	var RefLink=$('#RefLink_' + tagID).val();
	var Remark=$('#Remark_' + tagID).val();
	// remove hiddens
	$('#RefType_' + tagID).remove();
	$('#RefStr_' + tagID).remove();
	$('#RefId_' + tagID).remove();
	$('#RefLink_' + tagID).remove();
	$('#Remark_' + tagID).remove();
	
	
	var d='<label for="RefType_' + tagID + '">TAG Type</label>';
	d+='<select id="RefType_' + tagID + '" name="RefType_' + tagID + '" onchange="pickRefType(this.id,this.value);">';
	d+='<option';
	if (RefType=='comment'){
		d+=' selected="selected"';
	}
	d+=' value="comment">Comment Only</option>';
	d+='<option';
	if (RefType=='cataloged_item'){
		d+=' selected="selected"';
	}
	d+=' value="cataloged_item">Cataloged Item</option>';
	d+='<option';
	if (RefType=='collecting_event'){
		d+=' selected="selected"';
	}
	d+=' value="collecting_event">Collecting Event</option>';
	d+='<option';
	if (RefType=='locality'){
		d+=' selected="selected"';
	}
	d+=' value="locality">Locality</option>';
	d+='<option';
	if (RefType=='agent'){
		d+=' selected="selected"';
	}
	d+=' value="agent">Agent</option>';
	d+='</select>';
	d+='<label for="RefStr_' + tagID + '">Reference';
	if(RefLink){
		d+='&nbsp;&nbsp;&nbsp;<a href="' + RefLink + '" target="_blank">[ Click for details ]</a>';
	}
	d+='</label>';
	d+='<input type="text" id="RefStr_' + tagID + '" name="RefStr_' + tagID + '" value="' + RefStr + '" size="50">';
	d+='<input type="hidden" id="RefId_' + tagID + '" name="RefId_' + tagID + '" value="' + RefId + '">';
	d+='<label for="Remark_' + tagID + '">Remark</label>';
	d+='<input type="text" id="Remark_' + tagID + '" name="Remark_' + tagID + '" value="' + Remark + '" size="50">';
	
	$('#tagDetails_' + tagID).html(d);
	
	console.log('editing reftype ' + RefType);
	
	
	/*
	 * 
	 * 	d+='<input type="hidden" id="RefType_' + id + '" name="RefType_' + id + '" value="' + reftype + '">';
		d+='<input type="hidden" id="RefStr_' + id + '" name="RefStr_' + id + '" value="' + refStr + '">';
		d+='<input type="hidden" id="RefId_' + id + '" name="RefId_' + id + '" value="' + refId + '">';
		d+='<input type="hidden" id="RefLink_' + id + '" name="RefLink_' + id + '" value="' + reflink + '">';
		d+='<input type="hidden" id="Remark_' + id + '" name="Remark_' + id + '" value="' + remark + '">';
		d+='<input type="hidden" id="t_' + id + '" name="t_' + id + '" value="' + t + '">';
		d+='<input type="hidden" id="l_' + id + '" name="l_' + id + '" value="' + l + '">';
		d+='<input type="hidden" id="h_' + id + '" name="h_' + id + '" value="' + h + '">';
		d+='<input type="hidden" id="w_' + id + '" name="w_' + id + '" value="' + w + '">';
		
		
	 * 
	 * 
	 * 
	 * 
	
	
	 * 
	 * 
	 * 
	 * 
	 * 
	 * d+='<div id="tagDetails_' + id + '">';
		d+='TAG Type: ' + reftype;
		d+='<br>Reference: ';
		if(reflink){
			d+='<a href="' + reflink + '" target="_blank">' + refStr + '</a>';
		} else {
			d+=reflink;
		}
		if(remark){
			d+='<br>Remark: ' + remark;
		}
		
		d+='</div>';
		
		
		d+='<label for="RefType_' + id + '">TAG Type</label>';
		d+='<select id="RefType_' + id + '" name="RefType_' + id + '" onchange="pickRefType(this.id,this.value);">';
		d+='<option';
		if (reftype=='comment'){d+=' selected="selected"';}
		d+=' value="comment">Comment Only</option>';
		d+='<option';
		if (reftype=='cataloged_item'){d+=' selected="selected"';}
		d+=' value="cataloged_item">Cataloged Item</option>';
		d+='<option';if (reftype=='collecting_event'){d+=' selected="selected"';}
		d+=' value="collecting_event">Collecting Event</option>';
		d+='<option';if (reftype=='locality'){d+=' selected="selected"';}
		d+=' value="locality">Locality</option>';
		d+='<option';if (reftype=='agent'){d+=' selected="selected"';}
		d+=' value="agent">Agent</option>';
		d+='</select>';
		d+='<label for="RefStr_' + id + '">Reference';
		if(reflink){d+='&nbsp;&nbsp;&nbsp;<a href="' + reflink + '" target="_blank">[ Click for details ]</a>';}
		d+='</label>';
		d+='<input type="text" id="RefStr_' + id + '" name="RefStr_' + id + '" value="' + refStr + '" size="50">';
		d+='<input type="hidden" id="RefId_' + id + '" name="RefId_' + id + '" value="' + refId + '">';
		d+='<label for="Remark_' + id + '">Remark</label>';
		d+='<input type="text" id="Remark_' + id + '" name="Remark_' + id + '" value="' + remark + '" size="50">';
		d+='<input type="hidden" id="t_' + id + '" name="t_' + id + '" value="' + t + '">';
		d+='<input type="hidden" id="l_' + id + '" name="l_' + id + '" value="' + l + '">';
		d+='<input type="hidden" id="h_' + id + '" name="h_' + id + '" value="' + h + '">';
		d+='<input type="hidden" id="w_' + id + '" name="w_' + id + '" value="' + w + '">';
	
	
	*/
	//showScroll(tagID);
	//modArea(tagID);
});




$(document).ready(function () {		
	$('#imgDiv').getImg2Tag($("#imgURL").val(),function() {
		$("#imgH").val($('#theImage').height());
		$("#imgW").val($('#theImage').width());
		loadInitial();	
	});
	$("span[id^='scrollToTag_']").live('click', function(e){
		var tagID=this.id.replace('scrollToTag_','');
		console.log('id: ' + this.id + ' scrollong to ' + tagID);
		scrollToTag(tagID);
		//
	});
	
	
	
	jQuery("div .refDiv").live('click', function(e){
		var tagID=this.id.replace('refDiv_','');
		scrollToLabel(tagID);
	});
	
	
	
	
	
	
	$("span[id^='killRefClk_']").live('click', function(e){
		var tagID=this.id.replace('killRefClk_','');
		var str = confirm("Are you sure you want to delete this TAG?");
		if (str) {
			jQuery.getJSON("/component/tag.cfc",
				{
					method : "deleteTag",
					tag_id : tagID,
					returnformat : "json",
					queryformat : 'column'
				},
				function (r) {
					if (r=='success') {
						$("#refDiv_" + tagID).remove();
						$("#refPane_" + tagID).remove();
					} else {
						alert('Error deleting TAG: ' + r);
					}
				}
			);
		}
	});
	jQuery("div[class^='refPane_']").live('click', function(e){
		var tagID=this.id.replace('refPane_','');

		//showScroll(tagID);
		//modArea(tagID);
	});
	
	
	
	
	
	
		$("#newRefBtn").click(function(e){
			if ($("#t_new").val().length==0 || $("#l_new").val().length==0 || $("#h_new").val().length==0 || $("#w_new").val().length==0) {
				alert('You must have a TAG.');
				return false;
			}
			if ($("#RefId_new").val().length==0 && $("#Remark_new").val().length==0) {
				alert('Pick a TAG type and/or enter a comment.');
				return false;
			} else {
				$("#info").text('');
				jQuery.getJSON("/component/tag.cfc",
					{
						method : "newRef",
						media_id : $("#media_id").val(),
						reftype: $("#RefType_new").val(),
						refid : $("#RefId_new").val(),
						remark: $("#Remark_new").val(),
						reftop: $("#t_new").val(),
						refleft: $("#l_new").val(),
						refh: $("#h_new").val(),
						refw: $("#w_new").val(),
						imgh: $("#imgH").val(),
						imgw: $("#imgW").val(),
						returnformat : "json",
						queryformat : 'column'
					},
					function (r) {
						if (r.ROWCOUNT && r.ROWCOUNT==1){
							$("#refDiv_new").remove();
							$("#newRefHidden").hide();
							$("#RefType_new").val('');
							$("#Remark_new").val('');
							$("#RefStr_new").val('');
							$("#RefId_new").val('');
							var scaledTop=r.DATA.REFTOP[0] * $("#imgH").val() / r.DATA.IMGH[0];
							var scaledLeft=r.DATA.REFLEFT[0] *  $("#imgW").val() / r.DATA.IMGW[0];
							var scaledH=r.DATA.REFH[0] * $('#theImage').height() / r.DATA.IMGH[0];
							var scaledW=r.DATA.REFW[0] *  $("#imgW").val() / r.DATA.IMGW[0];
							addArea(
								r.DATA.TAG_ID[0],
								scaledTop,
								scaledLeft,
								scaledH,
								scaledW);
							addRefPane(
								r.DATA.TAG_ID[0],
								r.DATA.REFTYPE[0],
								r.DATA.REFSTRING[0],								
								r.DATA.REFID[0],								
								r.DATA.REMARK[0],						
								r.DATA.REFLINK[0],								
								scaledTop,
								scaledLeft,
								scaledH,
								scaledW);
								 
						} else {
							alert(r);
						}
					}
				);
			}
		});
	});		
	function loadInitial() {
		$.getJSON("/component/tag.cfc",
			{
				method : "getTags",
				media_id : $("#media_id").val(),
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				if (r.ROWCOUNT){
 					var imgh=$("#imgH").val();
 					var imgw=$("#imgW").val();
 					for (i=0; i<r.ROWCOUNT; ++i) {
						var scaledTop=r.DATA.REFTOP[i] * $("#imgH").val() / r.DATA.IMGH[i];
						var scaledLeft=r.DATA.REFLEFT[i] * $("#imgW").val() / r.DATA.IMGW[i];
						var scaledH=r.DATA.REFH[i] * $("#imgH").val() / r.DATA.IMGH[i];
						var scaledW=r.DATA.REFW[i] * $("#imgW").val() / r.DATA.IMGW[i];
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
						addArea(
							r.DATA.TAG_ID[i],
							scaledTop,
							scaledLeft,
							scaledH,
							scaledW);
					}
				} else {
					alert('error: ' + r);
				}
			}
		);
	}
	
	function scrollToLabel(id) {
		var divID='refDiv_' + id;
		var paneID='refPane_' + id;
		// add editing classes to our 2 objects		

		$("div .highlight").removeClass("highlight").addClass("refDiv");
		$("div .refPane_highlight").removeClass("refPane_highlight");
		
		$("#" + divID).removeClass("refDiv").addClass("highlight");
		$("#" + paneID).addClass('refPane_highlight');
		$('#navDiv').scrollTo( $('#' + paneID), 800 );
	}
	
	function scrollToTag(id) {
		var divID='refDiv_' + id;
		var paneID='refPane_' + id;
		console.log('divID=' + divID + ';paneID='+paneID);
		// add editing classes to our 2 objects		

		$("div .highlight").removeClass("highlight").addClass("refDiv");
		$("div .refPane_highlight").removeClass("refPane_highlight");
		
		$("#" + divID).removeClass("refDiv").addClass("highlight");
		$("#" + paneID).addClass('refPane_highlight');
		
		$(document).scrollTo( $('#' + divID), 800 );	}
	
	
	function modArea(id) {
		var divID='refDiv_' + id;
		var paneID='refPane_' + id;
		// remove all draggables
		$("div .editing").draggable("destroy");
		$("div .editing").resizable("destroy");
		// remove all editing and refPane_editing classes
		$("div .editing").removeClass("editing").addClass("refDiv");
		$("div .refPane_editing").removeClass("refPane_editing");
		// add editing classes to our 2 objects		
		$("#" + divID).removeClass("refDiv").addClass("editing");
		$("#" + paneID).addClass('refPane_editing');
		// draggable
		$("#" + divID).draggable({
			containment: 'parent',
			stop: function(event,ui){showDim(id,event, ui);}
		});
		// resizeable
		$("#" + divID).resizable({
			containment: 'parent',
			stop: function(event,ui){showDim(id,event, ui);}
		});
		
		$('#navDiv').scrollTo( $('#' + paneID), 800 );
	}
	function addRefPane(id,reftype,refStr,refId,remark,reflink,t,l,h,w) {
		if (refStr==null){refStr='';}
		if (remark==null){remark='';}
		var d='<div id="refPane_' + id + '" class="refPane_' + reftype + '">';
		d+='<span class="likeLink" id="editRefClk_' + id + '">Edit TAG</span>';
		d+=' ~ <span class="likeLink" id="killRefClk_' + id + '">Delete TAG</span>';
		d+=' ~ <span class="likeLink" id="scrollToTag_' + id + '">Scroll to TAG</span>';
		
		d+='<div id="tagDetails_' + id + '">';
		d+='TAG Type: ' + reftype;
		d+='<br>Reference: ';
		if(reflink){
			d+='<a href="' + reflink + '" target="_blank">' + refStr + '</a>';
		} else {
			d+=reflink;
		}
		if(remark){
			d+='<br>Remark: ' + remark;
		}
		d+='</div>';
		d+='<input type="hidden" id="RefType_' + id + '" name="RefType_' + id + '" value="' + reftype + '">';
		d+='<input type="hidden" id="RefStr_' + id + '" name="RefStr_' + id + '" value="' + refStr + '">';
		d+='<input type="hidden" id="RefId_' + id + '" name="RefId_' + id + '" value="' + refId + '">';
		d+='<input type="hidden" id="RefLink_' + id + '" name="RefLink_' + id + '" value="' + reflink + '">';
		d+='<input type="hidden" id="Remark_' + id + '" name="Remark_' + id + '" value="' + remark + '">';
		d+='<input type="hidden" id="t_' + id + '" name="t_' + id + '" value="' + t + '">';
		d+='<input type="hidden" id="l_' + id + '" name="l_' + id + '" value="' + l + '">';
		d+='<input type="hidden" id="h_' + id + '" name="h_' + id + '" value="' + h + '">';
		d+='<input type="hidden" id="w_' + id + '" name="w_' + id + '" value="' + w + '">';
		
		
		
		
		
		
		/*
		d+='<label for="RefType_' + id + '">TAG Type</label>';
		d+='<select id="RefType_' + id + '" name="RefType_' + id + '" onchange="pickRefType(this.id,this.value);">';
		d+='<option';
		if (reftype=='comment'){d+=' selected="selected"';}
		d+=' value="comment">Comment Only</option>';
		d+='<option';
		if (reftype=='cataloged_item'){d+=' selected="selected"';}
		d+=' value="cataloged_item">Cataloged Item</option>';
		d+='<option';if (reftype=='collecting_event'){d+=' selected="selected"';}
		d+=' value="collecting_event">Collecting Event</option>';
		d+='<option';if (reftype=='locality'){d+=' selected="selected"';}
		d+=' value="locality">Locality</option>';
		d+='<option';if (reftype=='agent'){d+=' selected="selected"';}
		d+=' value="agent">Agent</option>';
		d+='</select>';
		d+='<label for="RefStr_' + id + '">Reference';
		if(reflink){d+='&nbsp;&nbsp;&nbsp;<a href="' + reflink + '" target="_blank">[ Click for details ]</a>';}
		d+='</label>';
		d+='<input type="text" id="RefStr_' + id + '" name="RefStr_' + id + '" value="' + refStr + '" size="50">';
		d+='<input type="hidden" id="RefId_' + id + '" name="RefId_' + id + '" value="' + refId + '">';
		d+='<label for="Remark_' + id + '">Remark</label>';
		d+='<input type="text" id="Remark_' + id + '" name="Remark_' + id + '" value="' + remark + '" size="50">';
		d+='<input type="hidden" id="t_' + id + '" name="t_' + id + '" value="' + t + '">';
		d+='<input type="hidden" id="l_' + id + '" name="l_' + id + '" value="' + l + '">';
		d+='<input type="hidden" id="h_' + id + '" name="h_' + id + '" value="' + h + '">';
		d+='<input type="hidden" id="w_' + id + '" name="w_' + id + '" value="' + w + '">';
		*/
		d+='</div>';
		$("#editRefDiv").append(d);
		if (reftype=='comment'){
			$("#RefStr_" + id).hide();
		} else {
			$("#RefStr_" + id).show();
		}
	}
	function nevermindNew(){
		$('#refDiv_new').remove();
		pickRefType('RefType_new','');
		$("#info").text('');
	}	
	function newArea() {
		if($('#refDiv_new').length > 0){
			alert('There is already a new TAG.');
			return false;
		}
		var ih = $("#imgH").val();
		var iw = $("#imgW").val();
		var l= iw/4;
		var w=iw/2;
		var portTop = $(window).scrollTop();
		var winH=$(window).height();
		var portBot=portTop+winH;
		var portH=portBot-portTop;
		var h = portH/2;
		var t = portTop + 50;
		if (h > ih/2){h=ih/2;}
		if (t+h > ih){h=(ih-t)-60;}		
		addArea('new',t,l,h,w);	
		$("#t_new").val(t);
		$("#l_new").val(l);
		$("#h_new").val(h);
		$("#w_new").val(w);
		setTimeout("modArea('new')",500);
		$("#info").html('Drag/resize the new red box on the image, pick a TAG and/or enter a comment, then click "create TAG" - or <span class="likeLink" onclick="nevermindNew()">cancel</span>');
	}
	function pickRefType(id,v){
		var tagID=id.replace('RefType_','');
		var fname='ef';
		if (id=='RefType_new'){
			var fname='f';
			if(v=='comment'){
				$("#RefStr_new").hide();
			} else {
				$("#RefStr_new").show();
			}
			if (v.length==0) {
				$("#newRefHidden").hide();
				return false;			
			} else {
				$("#newRefHidden").show();
				newArea();
			}			
		}
		if (v=='cataloged_item') {
			findCatalogedItem('RefId_' + tagID,'RefStr_' + tagID,fname);
		} else if (v=='collecting_event') {
			findCollEvent('RefId_' + tagID,fname,'RefStr_' + tagID);
		} else if (v=='comment') {
			$("#RefStr_" + tagID).hide();
		} else if (v=='locality') {
			LocalityPick('RefId_' + tagID,'RefStr_' + tagID,fname);
		} else if (v=='agent') {
			getAgent('RefId_' + tagID,'RefStr_' + tagID,fname);
		} else {
			alert('I have no idea what you are trying to do. Stoppit, Srsly.');
		}
	}	
	function addArea(id,t,l,h,w) {
		if(id=='new'){
			c='editing';
		}else{
			c='refDiv';
		}
		var dv='<div id="refDiv_' + id + '" class="' + c + '" style="position:absolute;width:' + w + 'px;height:' + h + 'px;top:' + t + 'px;left:' + l + 'px;"></div>';
		$("#imgDiv").append(dv);
	}			
	function showDim(tagID,event,ui){
		try{
			$("#t_" + tagID).val(ui.position.top);
		} catch(e){}
		try{
			$("#l_" + tagID).val(ui.position.left);
		} catch(e){}
		try{
			$("#h_" + tagID).val(ui.size.height);
		} catch(e){}
		try{
			$("#w_" + tagID).val(ui.size.width);
		} catch(e){}
	}