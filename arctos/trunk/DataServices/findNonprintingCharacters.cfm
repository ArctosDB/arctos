<cfinclude template="/includes/_header.cfm">
<cfset title="nonprinting characters come here to die">
<script>
	function replaceNoprint(){
		$.getJSON("/component/functions.cfc",
			{
				method : "removeNonprinting",
				orig : $("#orig").val(),
				userString : $("#replaced_with_userstring").val(),
				returnformat : "json",
				queryformat : 'column'
			},
			function(r) {
				$("#replaced_with_nothing").val(r.DATA.REPLACED_WITH_NOTHING);
				$("#replaced_with_x").val(r.DATA.REPLACED_WITH_X);
				$("#replaced_with_space").val(r.DATA.REPLACED_WITH_SPACE);
				$("#replaced_with_userstring").val(r.DATA.REPLACED_WITH_USERSTRING);
			}
		);
	}
</script>
<br>
Many Arctos fields will not accept nonprinting characters 
(<a href="http://en.wikipedia.org/wiki/Regular_expression#POSIX_character_classes" target="_blank" class="external">posix class PRINT</a>).

<p>This form will accept text which may return nonprinting characters, and return three strings:
<ol>
	<li>
		Nonprinting characters replaced with [X]. This is primarily for visual reference, but may also be used for further processing. For example, 
		you could paste this into your favorite word processor (one which does not add nonprinting characters, please!), search for [X], and replace
		all found values with "\n" ("newline" in javascript) to format your text for javascript display.
	</li>
	<li>
		Nonprinting characters replaced with a user-specified string. Just type something into the "Enter a replacement string here" box. The default is the HTML linebreak, 
		"&lt;br&gt;".
	</li>
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

<label for="userString">Enter a replacement string here</label>
<input type="text" id="userString" value="<br>">
<br><input type="button" onclick="replaceNoprint()" value="replace nonprinting">

<label for="replaced_with_x">nonprinting replaced with [X]</label>
<textarea id="replaced_with_x" rows="20" cols="80"></textarea>

<label for="replaced_with_nothing">nonprinting replaced with whatever you typed in the "userstring" box</label>
<textarea id="replaced_with_userstring" rows="20" cols="80"></textarea>

<label for="replaced_with_nothing">nonprinting replaced with nothing</label>
<textarea id="replaced_with_nothing" rows="20" cols="80"></textarea>

<label for="replaced_with_space">nonprinting replaced with space</label>
<textarea id="replaced_with_space" rows="20" cols="80"></textarea>

<cfinclude template="/includes/_footer.cfm">