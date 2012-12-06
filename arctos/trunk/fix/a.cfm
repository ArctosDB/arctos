
<cfinclude template="/includes/_header.cfm">

	<script>

	jQuery(document).ready(function() {


$.datepicker.setDefaults({ dateFormat: 'yy-mm-dd' });
	$("#made_date").datepicker();

//"option", "dateFormat", "yy-mm-dd"

});
	</script>

	<input type="text" id="made_date">