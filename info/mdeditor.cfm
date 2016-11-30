<cfinclude template="/includes/_frameHeader.cfm">
<script>
	jQuery(document).ready(function() {
		var eid=$("#eid").val();
		var mdtext = parent.$("#" + eid).html();
		console.log(mdtext);

	});
</script>
<cfoutput>
	<!-----
	// users can disable this by using <nomd> tags
			if (mdtext.trim().substring(0,6) != '<nomd>'){
				// convert to markdown
				var converter = new showdown.Converter();
				// people are used to github, so....
				showdown.setFlavor('github');
				converter.setOption('strikethrough', 'true');
				converter.setOption('simplifiedAutoLink', 'true');
				// make some HTML
				var htmlc = converter.makeHtml(mdtext);
				// add the HTML to the appropriate div
				$("##ht_desc").html(htmlc);
				// hide the original
				$("##ht_desc_orig").hide();
			}
			----->

	<cfif not isdefined("eid")>
		did not get element ID; aborting<cfabort>
	</cfif>
	<input type="hidden" id="eid" value="#eid#">
	pulling #eid#....

	<label for="md">Markdown</label>
	<textarea name="md" id="md" cols="120" rows="20"></textarea>


	<label for="htm">Rendering</label>
	<div id="htm"></div>



</cfoutput>
i am mdeditor.cfm