<cfinclude template="/includes/_frameHeader.cfm">
<script type='text/javascript' language="javascript" src='https://cdn.rawgit.com/showdownjs/showdown/1.5.0/dist/showdown.min.js'></script>
<script>
	jQuery(document).ready(function() {
		var eid=$("#eid").val();
		var mdtext = parent.$("#" + eid).html();
		$("#md").val(mdtext);
		goHTML();
	});
	function goHTML(){
		var converter = new showdown.Converter();
		showdown.setFlavor('github');
		converter.setOption('strikethrough', 'true');
		converter.setOption('simplifiedAutoLink', 'true');
		var mdtext = $("#md").val();
		var htmlc = converter.makeHtml(mdtext);
		$("#htm").html(htmlc);
	}
	function pushBack(){
		var eid=$("#eid").val();
		parent.$("#" + eid).val($("#md").val());
		parent.$(".ui-dialog-titlebar-close").trigger('click');
	}
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
<div>
	<a href="https://guides.github.com/features/mastering-markdown/" target="_blank" class="external">
		Github-flavored Markdown
	</a>
	is supported through the
	<a href="https://github.com/showdownjs/showdown" target="_blank" class="external">
		Showdown Library
	</a>
	; an instructive
	<a href="http://showdownjs.github.io/demo/" target="_blank" class="external">
		demo/editor
	</a>
	is available.
</div>
<cfoutput>
	<cfif not isdefined("eid")>
		did not get element ID; aborting<cfabort>
	</cfif>
	<input type="hidden" id="eid" value="#eid#">
	<label for="md">Markdown</label>
	<textarea name="md" id="md" cols="120" rows="20"></textarea>
	<br><input type="button" value="preview HTML below" onclick="goHTML()">
	<br><input type="button" value="save to form" onclick="pushBack()">
	<label for="htm">Rendering</label>
	<div id="htm"></div>
</cfoutput>