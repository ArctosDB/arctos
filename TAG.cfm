<cfinclude template = "/includes/_header.cfm">
<script language="JavaScript" src="/includes/jquery/jquery.imgareaselect.pack.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="/includes/jquery/css/imgareaselect-default.css">

<script type="text/javascript"> 
	jQuery(document).ready(function () { 
		jQuery('img#theImage').imgAreaSelect({ handles: true, onSelectEnd: someFunction }); 
	}); 
</script>


<div id="theDiv">
	<img src="http://bscit.berkeley.edu/mvz/notebookjpegs/v1318_s2/v1318_s2_p001.jpg" id="theImage">
</div>