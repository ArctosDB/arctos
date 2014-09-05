<cfinclude template="/includes/functionLib.cfm">
<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
<script type='text/javascript' language="javascript" src='/includes/ajax.min.js'></script>
<link rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />
<link rel="stylesheet" href="/includes/style.min.css" />
<script type="text/javascript">
    $.datepicker.setDefaults({ dateFormat: 'yy-mm-dd',changeMonth: true, changeYear: true, constrainInput: false });
</script>
<!--------
	<script>
	


		function t(){alert('t');}


		$("form#formEdit").submit(function(event){
			event.preventDefault();
alert('hi');

/*
			for ( i = 1; i < $("#numberOfIDs").val(); i++ ) {
				// Logs "try 0", "try 1", ..., "try 4".
				console.log( "try " + i );
			}
*/


			console.log('good to go');
			return false;
		});




	</script>
<form  id="formEdit">

	<input type="submit" name="not_submit" value="Save Changes" class="savBtn">
</form>



	<input type="button" name="t" value="t" class="savBtn" onclick="t()">
	
	
	------------->
	
	
	<script>
	(function($) {
    $("form#addFav").submit(function(event) {
        event.preventDefault();
        alert("hello");
    });
})(jQuery);

</script>



<form action="" id="addFav">
     <input type="text" name="name" class="thin-d"/>
     <input type="submit" value="Send"/>
</form>