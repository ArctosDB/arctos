<cfinclude template = "/includes/_header.cfm">
<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">

jquery-ui-1.7.2.custom.min.js

<script type="text/javascript"> 
	jQuery(document).ready(function () { 
		var ias=jQuery('img#theImage').imgAreaSelect({ handles: true, onSelectEnd: imgCallback, instance: true }); 
	
		ias.setSelection(50, 50, 150, 200, true); 
		ias.setOptions({ show: true }); 
		ias.update();
		
	}); 
	
	function imgCallback(img, selection) {
		console.log('img.x1: ' + img.x1 + '; img.y1: ' + img.y1 + '; img.x2: ' + img.x2 + '; img.y2: ' + img.y2 + '; selection.x1: ' + selection.x1 + '; selection.y1: ' + selection.y1 + '; selection.x2: ' + selection.x2 + '; selection.y2: ' + selection.y2);
	}
	
	function a(){
		$("#theDiv").append('<div style="position:absolute;width:100px;height:75px;top:25px;left:25px;border:1px solid red'>hello world</div>")
		}
</script>


<div id="theDiv" style="position:absolute;border:1px solid purple;">
	<img src="http://bscit.berkeley.edu/mvz/notebookjpegs/v1318_s2/v1318_s2_p001.jpg" id="theImage">
</div>

<span onclick="a">a</span>