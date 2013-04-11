<cfif not isdefined("action")><cfset action="nothing"></cfif>
<cfinclude template="/includes/functionLib.cfm">
<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
<script type='text/javascript' language="javascript" src='/includes/ajax.min.js'></script>
<link rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />
<link rel="stylesheet" href="/includes/style.css" />
<script type="text/javascript">
    // set up Y-player stuff; include the JS only where necessary
	var YWPParams={termDetection:"on",theme:"silver"};
    $.datepicker.setDefaults({ dateFormat: 'yy-mm-dd',changeMonth: true, changeYear: true, constrainInput: false });
</script>