
<cfinclude template="/includes/_header.cfm">

	<script>

	jQuery(document).ready(function() {


jQuery("#georeference_source").autocomplete("/ajax/autocomplete.cfm?term=georeference_source", {
		width: 320,
		max: 50,
		autofill: false,
		multiple: false,
		scroll: true,
		scrollHeight: 300,
		matchContains: true,
		minChars: 1,
		selectFirst:false
	});


});
	</script>

	<input type="text" id="georeference_source">