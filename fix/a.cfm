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
	
	
	$('form').each(function(){
		var fid=this.id;
		console.log(fid);
		console.log('els...');
		$('$(this) .reqdClr').each(function(e) {
			var id=this.id;
			console.log(id);
		});
		
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


<form name="f1" id="f1">
	<input id="f1_1" class="reqdClr">
	<input id="f1_2" class="reqdClr">
	<input id="f1_3" class="reqdClr">
</form>

<form name="f2" id="f2">
	<input id="f2_1" class="reqdClr">
	<input id="f2_2" class="reqdClr">
	<input id="f2_3" class="reqdClr">
</form>