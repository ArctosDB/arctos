<cfinclude template="/includes/_header.cfm">
<script>
jQuery("#partname").autocomplete("/ajax/part_name.cfm", {
		width: 320,
		max: 20,
		autofill: true,
		highlight: false,
		multiple: true,
		multipleSeparator: "|",
		scroll: true,
		scrollHeight: 300
	});
	
</script>

<input type="text" id="partname">