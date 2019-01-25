<cfinclude template="/includes/alwaysInclude.cfm">
<script>
	function listerize(){
		var str=$("#in").val();
		//str = str.replace(/ *chr(13) */g, ',');
		str = str.replace(/\n/g, " ");
	}
</script>
<cfoutput>
	<label for="in">Paste most anything</label>
	<textarea name="in" id="in" class="hugetextarea"></textarea>
	<br><input type="button" onclick="listerize()" value="Listerize!">
	<textarea name="out" id="out" class="hugetextarea"></textarea>

</cfoutput>