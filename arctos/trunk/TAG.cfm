<cfinclude template = "/includes/_header.cfm">
<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">

<script type="text/javascript"> 
	jQuery(document).ready(function () { 
		jQuery('img#theImage').imgAreaSelect({ handles: true, onSelectEnd: imgCallback }); 
	}); 
	
	function imgCallback(img, selection) {
		console.log('img.x1: ' + img.x1 + '; img.y1: ' + img.y1 + '; img.x2: ' + img.x2 + '; img.y2: ' + img.y2 + '; selection.x1: ' + selection.x1 + '; selection.y1: ' + selection.y1 + '; selection.x2: ' + selection.x2 + '; selection.y2: ' + selection.y2);
	}
</script>


<div id="theDiv">
	<img src="http://bscit.berkeley.edu/mvz/notebookjpegs/v1318_s2/v1318_s2_p001.jpg" id="theImage">
</div>