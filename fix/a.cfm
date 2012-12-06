<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'></script>

	<script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>


	<script>

	jQuery(document).ready(function() {



	$("#made_date").datepicker();

	 $( "#format" ).change(function() {
        $( "#datepicker" ).datepicker( "option", "dateFormat", "yyyy-mm-dd" );
    });

});
	</script>

	<input type="text" id="made_date">