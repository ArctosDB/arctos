<cfinclude template = "/includes/_header.cfm">
<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">
<script language="JavaScript" src="/includes/jquery/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>



<script type="text/javascript"> 
	jQuery(document).ready(function () { 
		jQuery('img#theImage').imgAreaSelect({ handles: true, onSelectEnd: imgCallback, instance: true }); 
	
		
	}); 
	
	function imgCallback(img, selection) {
		console.log('img.x1: ' + img.x1 + '; img.y1: ' + img.y1 + '; img.x2: ' + img.x2 + '; img.y2: ' + img.y2 + '; selection.x1: ' + selection.x1 + '; selection.y1: ' + selection.y1 + '; selection.x2: ' + selection.x2 + '; selection.y2: ' + selection.y2);
	}
	
	function a(){
		console.log('a');
		var d='<div id="d1" style="position:absolute;width:100px;height:75px;top:25px;left:25px;border:1px solid red">hello world</div>';
		$("#theDiv").append(d);
	}
	
	function d() {
		$("#d1").draggable();
	}
</script>


<span onclick="a();">a</span>

<span onclick="d();">d</span>

<hr>

<div id="theDiv" style="position:absolute;border:1px solid purple;">
	<img src="http://bscit.berkeley.edu/mvz/notebookjpegs/v1318_s2/v1318_s2_p001.jpg" id="theImage">
</div>

<hr>