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
	
	function d(c,id,t,l,h,w) {
		var dv='<div id="' + id + '" class="' + c + " style="position:absolute;width:' + w + 'px;height:' + h + 'px;top:' + t + 'px;left:' + l + 'px;"></div>';
		
		$("#theDiv").append(dv);
		
		$("#" + id).draggable({
			containment: 'parent',
			stop: function(event,ui){showDim(event, ui);}
		});
		$("#" + id).resizable({
			containment: 'parent',
			stop: function(event,ui){showDim(event, ui);}
		});
		
		$("#top").val(t);
		$("#left").val(l);
		$("#height").val(h);
		$("#width").val(w);
		
	}
	
	function showDim(event,ui){
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


<span onclick="d('old',o1,200,200,100,100);">d</span>

<span onclick="d('new',n1,100,100,100,100);">d</span>
top: <input id="top">
left: <input id="left">
height: <input id="height">
width: <input id="width">
<hr>

<div id="theDiv" style="position:absolute;border:1px solid purple;">
	<img src="http://bscit.berkeley.edu/mvz/notebookjpegs/v1318_s2/v1318_s2_p001.jpg" id="theImage">
</div>

<hr>