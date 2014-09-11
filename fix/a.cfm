<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
<script>

/*
    jQuery("form#addFav").submit(function(event) {
        event.preventDefault();
        alert("hello");
    });
*/

jQuery(document).ready(function() {
			$( "#addFav" ).submit(function( event ) {
				//var linkOrderData=$("#sortable").sortable('toArray').join(',');
				//$( "#roworder" ).val(linkOrderData);
				//return true;
 alert("hello");
			});
		});


</script>
<form action="" id="addFav">
     <input type="datetime" name="name" class="thin-d"/>
     <input type="submit" value="Send"/>
</form>