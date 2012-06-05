<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' language="javascript" src='/development/jQuery.jPlayer.2.1.0/jquery.jplayer.min.js'></script>

http://web.corral.tacc.utexas.edu/MVZ/audio/mp3/D6229_Cicero_26Jun2006_Pmaculatus1_CC3215.mp3

<script>
	
	
	//<![CDATA[
$(document).ready(function(){

	$("#jquery_jplayer_1").jPlayer({
		ready: function (event) {
			$(this).jPlayer("setMedia", {
				m4a:"http://www.jplayer.org/audio/m4a/TSP-01-Cro_magnon_man.m4a",
				oga:"http://www.jplayer.org/audio/ogg/TSP-01-Cro_magnon_man.ogg"
			});
		},
		swfPath: "../js",
		supplied: "m4a, oga",
		wmode: "window"
	});
});
//]]>



</script>


<div id="jquery_jplayer_1">im here</div>
<cfinclude template="/includes/_footer.cfm">
