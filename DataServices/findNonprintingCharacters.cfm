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
				$("#replaced_with_nothing").val(r.DATA.REPLACED_WITH_NOTHING);
				$("#replaced_with_x").val(r.DATA.REPLACED_WITH_X);
			}
		);
	}

</script>
<label for="orig">paste your text here</label>
<textarea id="orig" rows="20" cols="80"></textarea>

<br><input type="button" onclick="replaceNoprint()" value="replace nonprinting">


<label for="replaced_with_x">nonprinting replaced with [X]</label>
<textarea id="replaced_with_x" rows="20" cols="80"></textarea>

<label for="replaced_with_nothing">nonprinting replaced with nothing</label>
<textarea id="replaced_with_nothing" rows="20" cols="80"></textarea>
<cfinclude template="/includes/_footer.cfm">