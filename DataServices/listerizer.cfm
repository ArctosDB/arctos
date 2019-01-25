<cfinclude template="/includes/alwaysInclude.cfm">
<style>
	.enormoustextarea {
	    height: 20em;
    	margin: .3em;
    	width: 100em;
	}
	.copyalert {
		background-color: #555;
		color: white;
		text-decoration: none;
		padding: 15px 26px;
		position: relative;
		display: inline-block;
		border-radius: 2px;
	}
</style>
<script>
	function listerize(){
		var str=$("#in").val();
		str = str.replace(/\n/g, ",");
		str = str.replace(/\t/g, ",");
		str = str.replace(/[, ]+/g, ",").trim();
		str = str.replace(/(^,)|(,$)/g, "");
		$("#out").val(str);
	}
	function cptc() {
  		var str=$("#out");
		str.select();
		document.execCommand("copy");
		$('<div class="copyalert">Copied to clipboard</div>').insertAfter('#btncpy').delay(3000).fadeOut();
	}
	function clrin() {
  		$("#in").val('');
	}
</script>
<cfoutput>
	<label for="in">Paste most anything (eg, column from Excel)</label>
	<input type="button" onclick="clrin()" value="Clear Input">
	<br>
	<textarea name="in" id="in" class="enormoustextarea"></textarea>
	<br><input type="button" onclick="listerize()" value="Listerize">
	<br>
	<label for="out">comma-list</label>
	<textarea name="out" id="out" class="enormoustextarea"></textarea>
	<br><input type="button" onclick="cptc()" id="btncpy" value="Copy to clipboard">

</cfoutput>