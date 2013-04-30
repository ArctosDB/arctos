<cfinclude template="/includes/_header.cfm">
<script>
	function replaceNoprint(){
		$.getJSON("/component/functions.cfc",
			{
				method : "removeNonprinting",
				orig : $("#orig").val(),
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				$("#replaced_with_nothing").val(r.DATA.REPLACED_WITH_NOTHING);
				$("#replaced_with_x").val(r.DATA.REPLACED_WITH_X);
				$("#replaced_with_space").val(r.DATA.REPLACED_WITH_SPACE);
			}
		);
	}

</script>

<br>
Many Arctos fields will not accept nonprinting characters 
(<a href="http://en.wikipedia.org/wiki/Regular_expression#POSIX_character_classes" target="_blank" class="external">posix class PRINT</a>).

<p>This form will accept text which may return nonprinting characters, and return three strings:
<ol>
	<li>Nonprinting characters replaced with [X]. This is for visual reference only. You may need it to clean up your data.</li>
	<li>
		Nonprinting characters replaced with nothing. You may be able to replace your original value with this if it contains control characters that
		do not affect layout.
	</li>
	<li>
		Nonprinting characters replaced with a space. You may be able to replace your original value with this if it contains control characters that
		do affect layout.
	</li>
</ol>
</p>

<label for="orig">paste your text here</label>
<textarea id="orig" rows="20" cols="80"></textarea>

<br><input type="button" onclick="replaceNoprint()" value="replace nonprinting">


<label for="replaced_with_x">nonprinting replaced with [X]</label>
<textarea id="replaced_with_x" rows="20" cols="80"></textarea>

<label for="replaced_with_nothing">nonprinting replaced with nothing</label>
<textarea id="replaced_with_nothing" rows="20" cols="80"></textarea>


<label for="replaced_with_space">nonprinting replaced with space</label>
<textarea id="replaced_with_space" rows="20" cols="80"></textarea>


<cfinclude template="/includes/_footer.cfm">