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
        background-color:#A7B3BC;
        padding:3px;
        border:1px solid black;
    }
    .refPane_collecting_event {
        background-color:#A0C4DF;
        padding:3px;
        border:1px solid black;
    }
    .refPane_comment {
        background-color:#76A5D4;
        padding:3px;
        border:1px solid black;
    }
	.refPane_editing {
		border:3px solid red;
	}
	#theImage{
		max-width:600px;
		max-height:800px;
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
						console.log('------------------------');
						console.log('------------------------');
						console.log('REFTOP: ' + r.DATA.REFTOP[i]);
						console.log('REFLEFT: ' + r.DATA.REFLEFT[i]);
						console.log('REFH: ' + r.DATA.REFH[i]);
						console.log('REFW: ' + r.DATA.REFW[i]);
						console.log('IMGH: ' + r.DATA.IMGH[i]);
						console.log('IMGW: ' + r.DATA.IMGW[i]);
						console.log('currW: ' + $('#theImage').width());
						console.log('currH: ' + $('#theImage').height());
						var newTop=r.DATA.REFTOP[i] * $('#theImage').height() / r.DATA.IMGH[i];
						console.log('newTop: ' + newTop);
						var newLeft=r.DATA.REFLEFT[i] * $('#theImage').width() / r.DATA.IMGW[i];
						console.log('newLeft: ' + newLeft);
						
						
						var newH=r.DATA.REFH[i] * $('#theImage').height() / r.DATA.IMGH[i];
						console.log('newH: ' + newH);
						var newW=r.DATA.REFW[i] * $('#theImage').width() / r.DATA.IMGW[i];
						console.log('newW: ' + newW);
						
						addArea(
							r.DATA.TAG_ID[i],
							newTop,
							newLeft,
							newH,
							newW);
							
						addRefPane(
							r.DATA.TAG_ID[i],
							r.DATA.REFTYPE[i],
							r.DATA.REFSTRING[i],								
							r.DATA.REFID[i],							
							r.DATA.REMARK[i],						
							r.DATA.REFLINK[i],
							newTop,
							newLeft,
							newH,
							newW);
							
						/*
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
							*/
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
		
		jQuery("div[class^='refPane_']").live('mouseover', function(e){
			var tagID=this.id.replace('refPane_','');
			modArea(tagID);
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
	
</script>
<cfoutput>
	<input type="hidden" id="media_id" value="#media_id#">
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
		<a href="MediaSearch.cfm?action=search&media_id=#media_id#">Back to Media</a>
		<cfif isdefined("session.roles") and listcontainsnocase(session.roles,"manage_media")>
			<br><a href="media.cfm?action=edit&media_id=#media_id#">Edit Media</a>
			<br><a href="TAG.cfm?media_id=#media_id#">Edit TAGs</a>
		</cfif>
		<div id="editRefDiv"></div>
	</div>
</cfoutput>
<cfset title="View Media TAGs">
<cfinclude template="/includes/_footer.cfm">