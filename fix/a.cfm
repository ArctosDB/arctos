<!----
<cfinclude template="/includes/_header.cfm">

---->



<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'></script>

	<script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>

<input type="text" id="georeference_source">

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

