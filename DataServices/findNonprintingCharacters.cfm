<cfinclude template="/includes/_header.cfm">
<script>
	function replaceNoprint(){
		$.getJSON("/component/functions.cfc",
			{
				method : "removeNonprinting",
				orig : $("#orig").val(),
				returnformat : "json"
			},
			function(r) {
				$("#replaced_with_nothing").val(r);
			}
		);
removeNonprinting
	}
</script>
<label for="orig">paste your text here</label>
<textarea id="orig" rows="20" cols="80"></textarea>
<input type="button" onclick="replaceNoprint()" value="replace nonprinting">
<label for="replaced_with_nothing">nonprinting removed here</label>
<textarea id="replaced_with_nothing" rows="20" cols="80"></textarea>
<cfinclude template="/includes/_footer.cfm">