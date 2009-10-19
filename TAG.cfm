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
</style>


<script type="text/javascript"> 
	jQuery(document).ready(function () { 
		//jQuery('img#theImage').imgAreaSelect({ handles: true, onSelectEnd: imgCallback, instance: true }); 
	}); 
	
	function imgCallback(img, selection) {
		// just reformat and pass off 
		console.log('img.x1: ' + img.x1 + '; img.y1: ' + img.y1 + '; img.x2: ' + img.x2 + '; img.y2: ' + img.y2 + '; selection.x1: ' + selection.x1 + '; selection.y1: ' + selection.y1 + '; selection.x2: ' + selection.x2 + '; selection.y2: ' + selection.y2);
	}
	
	function a(){
		console.log('a');
		
	}
	
	function addArea(id,t,l,h,w) {
		var dv='<div id="' + id + '" class="old" style="position:absolute;width:' + w + 'px;height:' + h + 'px;top:' + t + 'px;left:' + l + 'px;"></div>';
		$("#theDiv").append(dv);
	}
	
	
	
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
		
		
		
		//console.log('p,t: ' + ui.position.top + 'p,b: ' + ui.position.left +'; s,h: ' + ui.size.height + '; s,w: ' + ui.size.width);	
	}
</script>


<span onclick="addArea('o1',10,20,30,40);">d</span>

<span onclick="addArea('n1',101,102,103,104);">d</span>


<span onclick="modArea('n1');">d</span>


id: <input id="id">

top: <input id="top">
left: <input id="left">
height: <input id="height">
width: <input id="width">
<hr>

<div id="theDiv" style="position:absolute;border:1px solid purple;">
	<img src="http://bscit.berkeley.edu/mvz/notebookjpegs/v1318_s2/v1318_s2_p001.jpg" id="theImage">
</div>

<hr>