<cfinclude template = "/includes/_header.cfm">
<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/ui-lightness/jquery-ui-1.7.2.custom.css">
<script language="JavaScript" src="/includes/jquery/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>
<style>
	.editing {
		border:1px solid red;
	}
	.refDiv{
		border:1px solid blue;
	}
	#imgDiv{
		position:absolute;
		border:2px solid black;
		float: left;
	}
	#navDiv {
		float:right;
		border:1px solid green;
		width:400px;
		height:600px;
		overflow:scroll;
		margin:5px;
		padding:5px;
	}
	.refPane_cataloged_item {
		background-color:#AFC7C7;
		padding:3px;
		border:1px solid black;
	}
	.refPane_collecting_event {
		background-color:#669999;
		padding:3px;
		border:1px solid black;
	}
	.refPane_comment {
		background-color:#6699CC;
		padding:3px;
		border:1px solid black;
	}
	.refPane_editing {
		border:3px solid red;
	}
	#theImage{
		max-width:800px;
		max-height:1200px;
	}
</style>
<script type="text/javascript" language="javascript"> 
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
							r.DATA.REFLINK[i],
							r.DATA.REFTOP[i],
							r.DATA.REFLEFT[i],
							r.DATA.REFH[i],
							r.DATA.REFW[i]);
					}
				} else {
					alert('An error occurred. Try reloading or file a detailed bug report.');
				}
			}
		);
		jQuery("div .refDiv").live('click', function(e){
			var tagID=this.id.replace('refDiv_','');
			modArea(tagID);
		});
		
		jQuery("div[class^='refPane_']").live('click', function(e){
			var tagID=this.id.replace('refPane_','');
			modArea(tagID);
		});
		

	function addRefPane(id,reftype,refStr,refId,remark,reflink,t,l,h,w) {
		if (refStr==null){refStr='';}
		if (remark==null){remark='';}
		var d='<div id="refPane_' + id + '" class="refPane_' + reftype + '">';
		d+='TAG Type: ' + reftype;
		d+='<br>Reference: ' + refStr;
		if(reflink){
			d+='&nbsp;&nbsp;&nbsp;<a href="' + reflink + '" class="infoLink" target="_blank">[ Click for details ]</a>';
		}	
		if(remark){
			d+='Remark: ' + remark;
		}
		$("#editRefDiv").append(d);
	}
	
</script>
<cfoutput>
	<cfquery name="c" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from media where media_id=#media_id#
	</cfquery>
	<cfif (c.media_type is not "image" and c.media_type is not "multi-page document") or c.mime_type does not contain 'image/'>
		FAIL@images only.
		<cfabort>
	</cfif>
	<div id="imgDiv">
		<img src="#c.media_uri#" id="theImage">
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
		<div id="editRefDiv"></div>
		<input type="hidden" id="media_id" name="media_id" value="#c.media_id#">
		<input type="hidden" name="action" value="fd">
		<input type="submit" value="save all">
		</form>
	</div>
</cfoutput>