<!----

create table tag (
	tag_id number not null,
	media_id number not null,
	collection_object_id number,
	collecting_event_id number,
	remark varchar2(4000)
);

alter table tag add x number;
alter table tag add y number;
alter table tag add h number;
alter table tag add w number;


alter table tag add img_h number;
alter table tag add img_w number;


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
	
---->

<cfinclude template = "/includes/_header.cfm">
<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/ui-lightness/jquery-ui-1.7.2.custom.css">
<script language="JavaScript" src="/includes/jquery/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>
<style>
	.new {
		border:1px solid green;
	}
	.old{
		border:1px solid red;
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
				//alert(r);
			}
		);
		//addArea('o1',10,20,30,40);
		//addArea('o2',110,120,130,140);
		//jQuery('img#theImage').imgAreaSelect({ handles: true, onSelectEnd: imgCallback, instance: true }); 
	}); 
	function newArea() {
		var ih = $('#theImage').height();
		var iw = $('#theImage').width();
		var t = ih/4;
		var l= iw/4;
		var h=ih/2;
		var w=iw/2;
		addArea('newRef',t,l,h,w);
		setTimeout("modArea('newRef')",500);
		$("#info").text('Drag/resize the red box on the image, then click done.');
		$("#newRefType").show();
		$("#newRefClick").hide();
	}
	function imgCallback(img, selection) {
		// just reformat and pass off 
		console.log('img.x1: ' + img.x1 + '; img.y1: ' + img.y1 + '; img.x2: ' + img.x2 + '; img.y2: ' + img.y2 + '; selection.x1: ' + selection.x1 + '; selection.y1: ' + selection.y1 + '; selection.x2: ' + selection.x2 + '; selection.y2: ' + selection.y2);
	}
	
	function f_newRefType(v){
		if (v=='cancel' || v.length==0) {
			$("#newRefType").val('');
			$("#newRefType").hide();
			$("#newRefStr").hide();
			
			$("#newRefClick").show();
			$("#newRef").remove();
			$("#c_newRefComment").hide();
			
		} else {
			$("#newRefStr").show();
			$("#newRefComment").show();
			$("#newRefBtn").show();
			$("#c_newRefComment").show();
			if (v=='cataloged_item') {
				findCatalogedItem('newRefId','newRefStr','f');
			} else if (v=='collecting_event') {
				findCollEvent('newRefId','f','newRefStr');
			} else {
				alert('Dude... I have no idea what you are trying to do. Srsly. Stoppit.');
			}
		}
	}
	
	
	
	function addArea(id,t,l,h,w) {
		var dv='<div id="' + id + '" class="old" style="position:absolute;width:' + w + 'px;height:' + h + 'px;top:' + t + 'px;left:' + l + 'px;"></div>';
		$("#imgDiv").append(dv);
	}
	
	/*
	
	
		
	*/
	
	
	function modArea(id) {
		$("#" + id).draggable({
			containment: 'parent',
			stop: function(event,ui){showDim(id,event, ui);}
		});
		$("#" + id).resizable({
			containment: 'parent',
			stop: function(event,ui){showDim(id,event, ui);}
		});
		$("#height").val($('#' + id).height());
		$("#width").val($('#' + id).width());
		$("#top").val($("#" + id).position().top);
		$("#left").val($("#" + id).position().left);
		$("#id").val(id);	
		
		console.log('imgH: ' + $('#theImage').height());
		console.log('imgW: ' + $('#theImage').width());
	}
	function showDim(id,event,ui){
		try{
			$("#id").val(id);
		} catch(e){}
		try{
			$("#top").val(ui.position.top);
		} catch(e){}
		try{
			$("#left").val(ui.position.left);
		} catch(e){}
		try{
			$("#height").val(ui.size.height);
		} catch(e){}
		try{
			$("#width").val(ui.size.width);
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
	<input id="media_id" value="#c.media_id#">

<hr>

<div id="imgDiv">
	<img src="#c.media_uri#" id="theImage" style="max-width:600px;max-height:800px;">
</div>

<div id="navDiv">
	<div id="info"></div>
	<span class="likeLink" id="newRefClick" onclick="newArea();">Create Reference</span>
	<form name="f">
		<select id="newRefType" name="newRefType" onchange="f_newRefType(this.value);">
			<option value="">Pick Something...</option>
			<option value="cancel">Nevermind...</option>
			<option value="cataloged_item">Cataloged Item</option>
			<option value="collecting_event">Collecting Event</option>
		</select>
		<input type="text" id="newRefStr" name="newRefStr" style="display:none">
		<input type="hidden" id="newRefId" name="newRefId">
		<label for="newRefComment" id="c_newRefComment" style="display:none">Comment</label>
		<input type="text" id="newRefComment" style="display:none">
		<input type="button" id="newRefBtn" value="save reference" style="display:none">
	</form>
	<hr>
<span onclick="addArea('o1',10,20,30,40);">d</span>

<span onclick="addArea('n1',101,102,103,104);">d</span>


<span onclick="modArea('o1');">modArea - o1</span>


id: <input id="id">

top: <input id="top">
left: <input id="left">
height: <input id="height">
width: <input id="width">
</div>
</cfoutput>

<hr>