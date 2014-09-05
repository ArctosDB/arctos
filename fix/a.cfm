<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
<script>
    jQuery("form#addFav").submit(function(event) {
        event.preventDefault();
        alert("hello");
    });
</script>
<form action="" id="addFav">
     <input type="text" name="name" class="thin-d"/>
     <input type="submit" value="Send"/>
</form>