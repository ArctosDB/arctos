<cfinclude template = "/includes/_header.cfm">
<cfif action is "nothing">
<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/ui-lightness/jquery-ui-1.7.2.custom.css">
<script language="JavaScript" src="/includes/jquery/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>
<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
<script type="text/javascript" language="javascript">
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
	$(document).ready(function () {		
		$('#imgDiv').getImg2Tag($("#imgURL").val(),function() {
			$("#imgH").val($('#theImage').height());
			$("#imgW").val($('#theImage').width());
			loadInitial();	
		});
		$("span[id^='scrollToTag_']").live('click', function(e){
			var tagID='refDiv_' + this.id.replace('scrollToTag_','');
			$(document).scrollTo( $('#' + tagID), 800 );
		});
		jQuery("div .refDiv").live('click', function(e){
			var tagID=this.id.replace('refDiv_','');
			modArea(tagID);
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
			modArea(tagID);
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
		d+='</div>';
		$("#editRefDiv").append(d);
		if (reftype=='comment'){
			$("#RefStr_" + id).hide();
		} else {
			$("#RefStr_" + id).show();
		}
	}
	function newArea() {
		var ih = $("#imgH").val();
		var iw = $("#imgW").val();
		/*
		var t = 10;
		var l= 	10;
		var h=50;
		var w=100;
		
		*/
		var scrollTop = $(window).scrollTop() + 30;
		var winH=$(window).height();
		
		var h=ih/2;
		console.log('winH: ' + winH);
		
		console.log('h: ' + h);
		if (h>winH){
			h=winH-50;
		}
		
		var t = ih/4;
		if (t>scrollTop){
			t=scrollTop + 50;
		}
		var l= iw/4;
		
		var w=iw/2;
		addArea('new',t,l,h,w);	
		$("#t_new").val(t);
		$("#l_new").val(l);
		$("#h_new").val(h);
		$("#w_new").val(w);
		setTimeout("modArea('new')",500);
		//viewport.init("#new");
		//$("#info").text('Drag/resize the new red box on the image, pick a TAG and/or enter a comment, then click "create TAG."');
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
</script>
<cfoutput>
	<cfset title="TAG Images">
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from media where media_id=#media_id#
	</cfquery>
	<cfif (c.media_type is not "image" and c.media_type is not "multi-page document") or c.mime_type does not contain 'image/'>
		FAIL@images only.
		<cfabort>
	</cfif>
	<input type="hidden" id="imgURL" value="#c.media_uri#">
	<div id="imgDiv">
		Loading image and tags.....
	</div>
	<div id="navDiv">
		<div id="info"></div>
		<form name="f">
			<label for="RefType_new">Create TAG type....</label>
			<div id="newRefCell" class="newRec">
			<select id="RefType_new" name="RefType_new" onchange="pickRefType(this.id,this.value);">
				<option value=""></option>
				<option value="comment">Comment Only</option>
				<option value="cataloged_item">Cataloged Item</option>
				<option value="collecting_event">Collecting Event</option>
				<option value="locality">Locality</option>
				<option value="agent">Agent</option>
			</select>
			<span id="newRefHidden" style="display:none">
				<label for="RefStr_new">Reference</label>
				<input type="text" id="RefStr_new" name="RefStr_new" size="50">
				<input type="hidden" id="RefId_new" name="RefId_new">
				<label for="Remark_new">Remark</label>
				<input type="text" id="Remark_new" name="Remark_new" size="50">
				<input type="hidden" id="t_new">
				<input type="hidden" id="l_new">
				<input type="hidden" id="h_new">
				<input type="hidden" id="w_new">
				<br>
				<input type="button" id="newRefBtn" value="create TAG">
			</span>
			</div>
		</form>
		<hr>
		<form name="ef" method="post" action="TAG.cfm">
		<input type="submit" value="save all">
		<input type="hidden" name="imgH" id="imgH">
		<input type="hidden" name="imgW" id="imgW">
		<div id="editRefDiv"></div>
		<input type="hidden" id="media_id" name="media_id" value="#c.media_id#">
		<input type="hidden" name="action" value="fd">
		<input type="submit" value="save all">
		</form>
	</div>
</cfoutput>
<div style="clear:both;">&nbsp;</div>
<cfinclude template="/includes/_footer.cfm">
</cfif>
<cfif action is "fd">
	<cfoutput>
		<cfset tagids="">
		<cfloop list="#form.fieldnames#" index="e">
			<cfif e contains "REFTYPE">
				<cfset tid=replace(e,"REFTYPE_","")>
				<cfset tagids=listappend(tagids,tid)>
			</cfif>
		</cfloop>
		<cftransaction>
			<cfloop list="#tagids#" index="i">
				<cfset TAG_ID =  #i#>
				<cfset REMARK = evaluate("REMARK_" & i)>
				<cfset REFH = evaluate("H_" & i)>
				<cfset REFTOP = evaluate("T_" & i)>
				<cfset REFLEFT = evaluate("L_" & i)>
				<cfset REFW = evaluate("W_" & i)>
				<cfset reftype = evaluate("REFTYPE_" & i)>
				<cfset refid = evaluate("REFID_" & i)>
				<cfif REFH lt 0 or
					REFTOP lt 0 or
					REFLEFT lt 0 or
					REFW lt 0 or
					(REFTOP + REFH) gt imgH or
					(REFLEFT + REFW gt imgW)>
					bad juju. 
					<cfdump var="#form#">
					<cfabort>
				</cfif>
				<cfset s="update tag set
					REMARK='#escapeQuotes(REMARK)#',
					REFH=#REFH#,
					REFTOP=#REFTOP#,
					REFLEFT=#REFLEFT#,
					REFW=#REFW#,
					imgH=#imgH#,
					imgW=#imgW#">
				<cfif reftype is "collecting_event">
					<cfset s=s & ",COLLECTION_OBJECT_ID=null
					,COLLECTING_EVENT_ID=#refid#">
				<cfelseif reftype is "cataloged_item">
					<cfset s=s & ",COLLECTING_EVENT_ID=null
					,COLLECTION_OBJECT_ID=#refid#">
				<cfelse>
					<cfset s=s & ",COLLECTION_OBJECT_ID=null
					,COLLECTING_EVENT_ID=null">
				</cfif>
				<cfset s=s & " where tag_id=#tag_id#">
				<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					#preservesinglequotes(s)#
				</cfquery>
			</cfloop>
		</cftransaction>
		<cflocation url="TAG.cfm?media_id=#media_id#" addtoken="false">
	</cfoutput>
</cfif>