<cfinclude template="/includes/_frameHeader.cfm">
<script type='text/javascript' language="javascript" src='https://cdn.rawgit.com/showdownjs/showdown/1.5.0/dist/showdown.min.js'></script>

<script>
	jQuery(document).ready(function() {
		function goHTML(){
			var converter = new showdown.Converter();
			showdown.setFlavor('github');
			converter.setOption('strikethrough', 'true');
			converter.setOption('simplifiedAutoLink', 'true');
			var mdtext = $("#md").val();
			console.log('got ' + mdtext);
			var htmlc = converter.makeHtml(mdtext);
			console.log('made ' + htmlc);
			$("#htm").html(htmlc);
		}




		var eid=$("#eid").val();
		var mdtext = parent.$("#" + eid).html();
		console.log(mdtext);
		$("#md").val(mdtext);

		goHTML();




	});


</script>
<style>
	#htm {
		border:1px solid green;
		padding:1em;
		margin:1em;
	}
	#md {
		width: 99%;
		height: 30em;
	}
</style>
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
	<br><input type="button" value="preview HTML below" onclick="goHTML()">


	<label for="htm">Rendering</label>
	<div id="htm"></div>



</cfoutput>
i am mdeditor.cfm