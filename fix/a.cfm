<cfinclude template="/includes/alwaysInclude.cfm">


	<script>
		


		$("#formEdit").submit(function(event){
			event.preventDefault();
alert('hi');
			var i;

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
<form name="ids" id="formEdit" method="post" action="editIdentifiers.cfm">

	<input type="submit" name="not_submit" value="Save Changes" class="savBtn">
</form>


