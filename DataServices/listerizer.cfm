<cfinclude template="/includes/alwaysInclude.cfm">
<style>
	.enormoustextarea {
	    height: 20em;
    	margin: .3em;
    	width: 100em;
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
</script>
<cfoutput>
	<label for="in">Paste most anything</label>
	<textarea name="in" id="in" class="enormoustextarea"></textarea>
	<br><input type="button" onclick="listerize()" value="Listerize!">
	<textarea name="out" id="out" class="enormoustextarea"></textarea>

</cfoutput>