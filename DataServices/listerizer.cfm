<cfinclude template="/includes/alwaysInclude.cfm">
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
		res = str.replace(/[, ]+/g, ",").trim();
		console.log(str);

		$("#out").val(str);
	}
</script>
<cfoutput>
	<label for="in">Paste most anything</label>
	<textarea name="in" id="in" class="hugetextarea"></textarea>
	<br><input type="button" onclick="listerize()" value="Listerize!">
	<textarea name="out" id="out" class="hugetextarea"></textarea>

</cfoutput>