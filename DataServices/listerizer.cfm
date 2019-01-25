<cfinclude template="/includes/alwaysInclude.cfm">
<style>
	.enormoustextarea {
	    height: 20em;
    	margin: .3em;
    	width: 100em;
	}
	.copyalert{
	background-color: #555;
	  color: white;
	  text-decoration: none;
	  padding: 15px 26px;
	  position: relative;
	  display: inline-block;
	  border-radius: 2px;
	}

}
</style>
<script>
	function listerize(){
		var str=$("#in").val();
		console.log(str);
		//str = str.replace(/ *chr(13) */g, ',');
		// newline
		str = str.replace(/\n/g, ",");
		console.log(str);
		// tab
		str = str.replace(/\t/g, ",");
		console.log(str);
		//multiple
		str = str.replace(/[, ]+/g, ",").trim();
		console.log(str);
		// lead/trail
		str = str.replace(/(^,)|(,$)/g, "");
		console.log(str);

		$("#out").val(str);
	}

	function cptc() {
  		var str=$("#out");
		str.select();
		document.execCommand("copy");
		$('<div class="copyalert">Copied to clipboard</div>').insertBefore('#btncpy').delay(3000).fadeOut();
	}

</script>
<cfoutput>
	<label for="in">Paste most anything</label>
	<textarea name="in" id="in" class="enormoustextarea"></textarea>
	<br><input type="button" onclick="listerize()" value="Listerize!">
	<br>
	<label for="out">comma-list</label>
	<textarea name="out" id="out" class="enormoustextarea"></textarea>
	<br><input type="button" onclick="cptc()" id="btncpy" value="Copy to clipboard">

</cfoutput>