<div id="theHead">
	<cfinclude template="/includes/_header.cfm">
</div>
<script type='text/javascript' src='/includes/_editIdentification.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery.form.js'></script>
<script >
jQuery( function($) {
	setInterval(checkRequired,500);
});

function checkRequired(){	
	// loop over all the forms...
	$('form').each(function(){
		var fid=this.id;
		// and all the className=reqdClr elements
		var hasIssues;
		$('#' + fid + ' > :input.reqdClr').each(function(e) {
			var id=this.id;
			// see if they have something
			if (document.getElementById(id).value.length == 0) {
				hasIssues=1;
			}
		});
		if (hasIssues == 1) {
			// form is NOT ready for submission
			document.getElementById(fid).setAttribute('onsubmit',"return false");
			$("#" + fid + " > :input[@type='submit']").val("Not ready...");			
		} else {
			document.getElementById(fid).removeAttribute('onsubmit');
			$("#" + fid + " > :input[@type='submit']").val("spiffy!");
		}
	});
}

function checkRequired2(){	
	// loop over all the forms...
	$('form').each(function(){
		var fid=this.id;
		console.log('FORM: ' + fid);
		$('#' + fid + ' > :input.reqdClr').each(function(e) {
			var id=this.id;
			// see if they have something
			console.log('...' + id);
		});
	});
}
</script>

	
<!--------------------------------------------------------------------------------------------------->

<input type="button" onclick="checkRequired2()" value="checkRequired">


<form name="f1" id="f1" action="a.cfm" onsubmit="return false">
	<input id="f1_1" class="reqdClr">
	<input id="f1_2" class="reqdClr">
	<input id="f1_3" class="reqdClr">
		<input id="f1_4" class="booger">
				<input type="submit" value="missing elements">
</form>

<form name="f2" id="f2"  action="a.cfm" onsubmit="return false">
	<input id="f2_1" class="reqdClr">
	<input id="f2_2" class="reqdClr">
	<input id="f2_3" class="reqdClr">
		<input id="f2_4" class="boog">
		<input type="submit"  id="submit_f2" class="submit booger" value="missing elements">
</form>