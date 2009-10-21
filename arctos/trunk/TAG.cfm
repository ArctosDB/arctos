<!----

drop table tag;
drop sequence sq_tag_id;


create table tag (
	tag_id number not null,
	media_id number not null,
	collection_object_id number,
	collecting_event_id number,
	remark varchar2(4000),
	reftop number,
	refleft number,
	refh number,
	refw number,
	imgh number,
	imgw number
);

create public synonym sq_tag_id for sq_tag_id;
grant select on sq_tag_id to public;

create or replace public synonym tag for tag;

grant select on tag to public;

grant all on tag to manage_media;

create sequence sq_tag_id;

CREATE OR REPLACE TRIGGER tag_seq before insert ON tag for each row
   begin     
       IF :new.tag_id IS NULL THEN
           select sq_tag_id.nextval into :new.tag_id from dual;
       END IF;
   end;                                                                                            
/
sho err

ALTER TABLE tag
    add CONSTRAINT pk_tag
    PRIMARY  KEY (tag_id);

ALTER TABLE tag
    add CONSTRAINT fk_tag_media
    FOREIGN KEY (media_id)
    REFERENCES media(media_id);
	
ALTER TABLE tag
    add CONSTRAINT fk_tag_specimen
    FOREIGN KEY (collection_object_id)
    REFERENCES cataloged_item(collection_object_id);
	
ALTER TABLE tag
    add CONSTRAINT fk_tag_event
    FOREIGN KEY (collecting_event_id)
    REFERENCES collecting_event(collecting_event_id);
	
CREATE OR REPLACE FUNCTION getTagRelations" (tid  in number id out number val out string )
return varchar2
as
type rc is ref cursor;
l_str    varchar2(4000);
l_sep    varchar2(3);
l_val    varchar2(4000);
l_cur    rc;
begin
open l_cur for 'select agent_name
from preferred_agent_name,collector
where
collector_role=''c'' AND
collector.agent_id=preferred_agent_name.agent_id AND
collection_object_id = :x
order by coll_order'
using p_key_val;
loop
fetch l_cur into l_val;
exit when l_cur%notfound;
l_str := l_str || l_sep || l_val;
l_sep := ', ';
end loop;
close l_cur;

       return l_str;
  end;
---->

<cfinclude template = "/includes/_header.cfm">
<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/ui-lightness/jquery-ui-1.7.2.custom.css">
<script language="JavaScript" src="/includes/jquery/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>
<style>
	.editing {
		border:1px solid yellow;
	}
	.refDiv{
		border:1px solid blue;
	}
	#imgDiv{
		position:absolute;
		border:8px solid purple;
		float: left;
	}
	#navDiv {
		float:right;
		border:2px solid green;
		width:300px;
	}
	
	.refpane_cataloged_item {
		border:2px solid orange;
		margin:2px;
	}
	.refPane_collecting_event {
		border:2px solid yellow;
		margin:2px;
	}
	.refPane_comment {
		border:2px solid purple;
		margin:2px;
	}
	.hovering {
		border:3px solid green;
	}
	
	#newRef {
		border:1px solid red;
	}
</style>

<script type="text/javascript"> 
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
						addArea(
							r.DATA.TAG_ID[i],
							r.DATA.REFTOP[i],
							r.DATA.REFLEFT[i],
							r.DATA.REFH[i],
							r.DATA.REFW[i]);
						addRefPane(
							r.DATA.TAG_ID[i],
							r.DATA.REFTYPE[i],
							r.DATA.REFSTRING[i],								
							r.DATA.REFID[i],							
							r.DATA.REMARK[i],
							r.DATA.REFTOP[i],
							r.DATA.REFLEFT[i],
							r.DATA.REFH[i],
							r.DATA.REFW[i]);
					}
				} else {
					alert(r);
				}
			}
		);
		jQuery("div .refDiv").live('click', function(e){
			$("div .editing").draggable("destroy");
			$("div .editing").resizable("destroy");
			
			$(".hovering").removeClass('hovering');
			
			$("div .editing").removeClass("editing").addClass("refDiv");
			
			var tagID=this.id.replace('refDiv_','');
			var oid=this.id.replace('refDiv','refPane');
			$("#" + this.id).addClass("hovering");
			$("#" + oid).addClass('hovering');
			
			//modArea(tagID);
		});
		$("span[id^='editRefClk_']").live('click', function(e){
			console.log('editRefClk_');
			var tagID=this.id.replace('editRefClk_','');
			modArea(tagID);
		});
		
		
		jQuery("div[class^='refPane_']").live('mouseover', function(e){
			var oid=this.id.replace('refPane','refDiv');
			console.log('mouseover ' + this.className + ' ' + this.id + '; oid: ' + oid);
			$("#" + this.id).addClass('hovering');
			$("#" + oid).addClass('hovering');
		});
		
		jQuery("div[class^='refPane_']").live('mouseout', function(e){
			var oid=this.id.replace('refPane','refDiv');
			console.log('mouseout ' + this.className + ' ' + this.id + '; oid: ' + oid);
			$("#" + this.id).removeClass('hovering');
			$("#" + oid).removeClass('hovering');
		});
		
	
		$("#newRefBtn").click(function(e){
			console.log($("#newRefId").val().length);
			console.log($("#newRemark").val().length);
			if ($("#t_new").val().length==0 || $("#l_new").val().length==0 || $("#h_new").val().length==0 || $("#w_new").val().length==0) {
				alert('You must have a graphical reference.');
				return false;
			}			
			if ($("#newRefId").val().length==0 && $("#newRemark").val().length==0) {
				alert('Pick a reference and/or enter a comment.');
				return false;
			} else {
				jQuery.getJSON("/component/tag.cfc",
					{
						method : "newRef",
						media_id : $("#media_id").val(),
						reftype: $("#newRefType").val(),
						refid : $("#newRefId").val(),
						remark: $("#newRemark").val(),
						reftop: $("#t_new").val(),
						refleft: $("#l_new").val(),
						refh: $("#h_new").val(),
						refw: $("#w_new").val(),
						imgh: $('#theImage').height(),
						imgw: $('#theImage').width(),
						returnformat : "json",
						queryformat : 'column'
					},
					function (r) {
						if (r.ROWCOUNT && r.ROWCOUNT==1){
							removeNewRef();
							addArea(
								r.DATA.TAG_ID[0],
								r.DATA.REFTOP[0],
								r.DATA.REFLEFT[0],
								r.DATA.REFH[0],
								r.DATA.REFW[0]);
							addRefPane(
								r.DATA.TAG_ID[0],
								r.DATA.REFTYPE[0],
								r.DATA.REFSTRING[0],								
								r.DATA.REFID[0],								
								r.DATA.REMARK[0],
								r.DATA.REFTOP[0],
								r.DATA.REFLEFT[0],
								r.DATA.REFH[0],
								r.DATA.REFW[0]);
								 
						} else {
							alert(r);
						}
					}
				);
			}
		});
		function addRefPane(id,reftype,refStr,refId,remark,t,l,h,w) {
			var d='<div id="refPane_' + id + '" class="refPane_' + reftype + '">';
			d+='<span class="likeLink" id="editRefClk_' + id + '">Edit Reference</span';
			d+='<select id="RefType_' + id + '" name="RefType_' + id + '" onchange="f_RefType(this.id,this.value);">';
			d+='<option';
			if (reftype=='comment'){
				d+=' selected="selected"';
			}
			d+=' value="comment">Comment Only</option>';
			d+='<option';
			if (reftype=='cataloged_item'){
				d+=' selected="selected"';
			}
			d+=' value="cataloged_item">Cataloged Item</option>';
			d+='<option';
			if (reftype=='collecting_event'){
				d+=' selected="selected"';
			}
			d+=' value="collecting_event">Collecting Event</option>';
			d+='</select>';
			d+='<label for="RefStr_' + id + '">Reference</label>';
			d+='<input type="text" id="RefStr_' + id + '" name="RefStr_' + id + '" value="' + refStr + '">';
			d=='<input type="hidden" id="RefId_' + id + '" name="RefId_' + id + '" value="' + refId + '">';
			d=='<label for="Remark_' + id + '">Remark</label>';
			d+='<input type="text" id="Remark_' + id + '" name="Remark_' + id + '" value="' + remark + '">';
			d+='<input type="text" id="t_' + id + '" name="t_' + id + '" value="' + t + '">';
			d+='<input type="text" id="l_' + id + '" name="l_' + id + '" value="' + l + '">';
			d+='<input type="text" id="h_' + id + '" name="h_' + id + '" value="' + h + '">';
			d+='<input type="text" id="w_' + id + '" name="w_' + id + '" value="' + w + '">';
			
			d+='</div>';
			$("#editRefDiv").append(d);
		}
	}); 
	function newArea() {
		var ih = $('#theImage').height();
		var iw = $('#theImage').width();
		var t = ih/4;
		var l= iw/4;
		var h=ih/2;
		var w=iw/2;
		addArea('new',t,l,h,w);
		setTimeout("modArea('new')",500);
		$("#info").text('Drag/resize the red box on the image, pick a reference and/or enter a comment, then click done.');
		$("#newRefType").show();
		$("#newRefClick").hide();
	}
	function removeNewRef() {
		$("#newRefType").val('');
		$("#newRefId").val('');
		$("#newRefStr").val('');
		$("#newRemark").val('');
		$("#newRefType").hide();
		$("#newRefStr").hide();
		$("#newRefBtn").hide();
		$("#newRemark").hide();			
		$("#c_newRemark").hide();
		$("#newRefClick").show();
		$("#new").remove();
	}
	
	function f_newRefType(v){
		if (v=='cancel' || v.length==0) {
			removeNewRef();			
		} else {
			$("#newRefStr").show();
			$("#newRemark").show();
			$("#newRefBtn").show();
			$("#c_newRemark").show();
			if (v=='cataloged_item') {
				findCatalogedItem('newRefId','newRefStr','f');
			} else if (v=='collecting_event') {
				findCollEvent('newRefId','f','newRefStr');
			} else if (v=='comment') {
				$("#newRefStr").hide();
			} else {
				alert('Dude... I have no idea what you are trying to do. Srsly. Stoppit.');
			}
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
		
	function modArea(id) {
		console.log('modarea got id ' + id);
		var elemID='refDiv_' + id;
		console.log(elemID);
		
		$("#" + elemID).draggable({
			containment: 'parent',
			stop: function(event,ui){showDim(id,event, ui);}
		});
		$("#" + elemID).resizable({
			containment: 'parent',
			stop: function(event,ui){showDim(id,event, ui);}
		});
		$("#h_" + id).val($('#' + elemID).height());
		$("#w_" + id).val($('#' + elemID).width());
		$("#t_" + id).val($("#" + elemID).position().top);
		$("#l_" + id).val($("#" + elemID).position().left);
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
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from media where media_id=#media_id#
	</cfquery>
	<cfif c.media_type is not "image" or c.mime_type does not contain 'image/'>
		FAIL@images only.
		<cfabort>
	</cfif>
	<div id="imgDiv">
		<img src="#c.media_uri#" id="theImage" style="max-width:600px;max-height:800px;">
	</div>
	<div id="navDiv">
		<div id="info"></div>
		<span class="likeLink" id="newRefClick" onclick="newArea();">Create Reference</span>
		<form name="f">
			<input typ="hidden" id="media_id" value="#c.media_id#">
			<select id="newRefType" name="newRefType" onchange="f_newRefType(this.value);" style="display:none">
				<option value=""></option>
				<option value="cancel">Nevermind...</option>
				<option value="comment">Comment Only</option>
				<option value="cataloged_item">Cataloged Item</option>
				<option value="collecting_event">Collecting Event</option>
			</select>
			<input type="text" id="newRefStr" name="newRefStr" style="display:none">
			<input type="hidden" id="newRefId" name="newRefId">
			<label for="newRemark" id="c_newRemark" style="display:none">Remark</label>
			<input type="text" id="newRemark" name="newRemark" style="display:none">
			<input id="t_new">
			<input id="l_new">
			<input id="h_new">
			<input id="w_new">
			<input type="button" id="newRefBtn" value="save reference" style="display:none">
		</form>
		<hr>
		<div id="editRefDiv"></div>
	</div>
</cfoutput>

<hr>