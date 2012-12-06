<cfif not isdefined("action")><cfset action="nothing"></cfif>
<cfinclude template="/includes/functionLib.cfm">
<!--- need to host this locally as setting datepicker format is retarded. Need autocomplete, sortable, datepicker. Change dateformat, min, save



<link rel="stylesheet" href="/includes/jquery-ui-1.9.2.custom.css" />
<link rel="stylesheet" type="text/css" href="/includes/style.css">


<script type='text/javascript' language="javascript" src='/includes/jquery-custom.js'></script>
<script language="JavaScript" src="/includes/jquery/jquery.ui.datepicker.min.js" type="text/javascript"></script>

---->
<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'></script>

	<script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>


<script type='text/javascript' language="javascript" src='/includes/ajax.min.js'></script>


<script type="text/javascript">
    var YWPParams =
    {
        termDetection: "on" ,
        theme: "silver"
    };
    $.datepicker.setDefaults({ dateFormat: 'yy-mm-dd',changeMonth: true, changeYear: true });
</script>
<script type="text/javascript" src="http://webplayer.yahooapis.com/player.js"></script>