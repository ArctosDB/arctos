<div id="theHead">
	<cfinclude template="/includes/_header.cfm">
</div>
<script type='text/javascript' src='/includes/_editIdentification.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery.form.js'></script>
<script >
jQuery( function($) {
	//setInterval(checkRequired,500);


});

function checkRequired(){
	console.log('checking...');
	console.log('forms...');
	
	// loop over all the forms...
	$('form').each(function(){
		var fid=this.id;
		console.log(fid);
		console.log('els...');
		// and all the className=reqdClr elements
		var hasIssues;
		$('#' + fid + ' > :input.reqdClr').each(function(e) {
			var id=this.id;
			console.log(id);
			// see if they have something
			if (document.getElementById(id).value.length == 0) {
				hasIssues=1;
			}
		});
		if (hasIssues == 1) {
			// form is NOT ready for submission
			//alert(fid + 'is missing required elements and cannot be submitted.');
			document.getElementById(fid).setAttribute('onsubmit',"return false");
			//var sEl="submit_" + fid;
			//document.getElementById(sEl).value="not ready....";
			$("#" + fid + " > :input.submit").val="not ready....";
			
			
		} else {
			alert('here ya go....')
			document.getElementById(fid).removeAttribute('onsubmit');
			$("#" + fid + " > :input.submit").val="spiffy!";
			
		}
	})	;
		
	
	/*
	$('form').each(function(e) {
		var fid=this.id;
		console.log(fid);
		console.log('requireds in this form....');
		$('#fid > .reqdClr').each(function(e) {
			var id=this.id;
			console.log(id);
		});
		console.log('nex form....');
	});	
	console.log('requireds...');
		$('.reqdClr').each(function(e) {
			var id=this.id;
		
			console.log(id);
		});
		
		*/
}
</script>

	
<!--------------------------------------------------------------------------------------------------->

<input type="button" onclick="checkRequired()" value="checkRequired">


<form name="f1" id="f1" action="a.cfm" onsubmit="return false">
	<input id="f1_1" class="reqdClr">
	<input id="f1_2" class="reqdClr">
	<input id="f1_3" class="reqdClr">
		<input id="f1_4" class="booger">
				<input type="submit" class="submit" id="submit_f1" value="missing elements">
</form>

<form name="f2" id="f2"  action="a.cfm" onsubmit="return false">
	<input id="f2_1" class="reqdClr">
	<input id="f2_2" class="reqdClr">
	<input id="f2_3" class="reqdClr">
		<input id="f2_4" class="boog">
		<input type="submit"  id="submit_f2" class="submit booger" value="missing elements">
</form>