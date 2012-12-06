<cfif not isdefined("action")><cfset action="nothing"></cfif>
<cfinclude template="/includes/functionLib.cfm">
<link rel="stylesheet" type="text/css" href="/includes/style.css">
<link rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />

<!--- need to host this locally as setting datepicker format is retarded. Need autocomplete, sortable, datepicker. Change dateformat, min, save
<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'></script>
<script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>

---->
<script type='text/javascript' language="javascript" src='/includes/jquery-custom.js'></script>

<script type='text/javascript' language="javascript" src='/includes/ajax.min.js'></script>
<script language="JavaScript" src="/includes/jquery/jquery.ui.datepicker.min.js" type="text/javascript"></script>
<script type="text/javascript">
    var YWPParams =
    {
        termDetection: "on" ,
        theme: "silver"
    };
</script>
<script type="text/javascript" src="http://webplayer.yahooapis.com/player.js"></script>