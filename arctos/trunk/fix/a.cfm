<!----


<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js'></script>

	<link rel="stylesheet" href="/includes/jquery-ui-1.9.2.custom.css" />


	<cfif not isdefined("action")><cfset action="nothing"></cfif>

<cfinclude template="/includes/_header.cfm">


	<link rel="stylesheet" type="text/css" href="/includes/style.css">
---->

	<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'></script>

	<script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>

	<script type='text/javascript' language="javascript" src='/includes/ajax.min.js'></script>

	<link rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />






	<script type="text/javascript">
	    var YWPParams =
	    {
	        termDetection: "on" ,
	        theme: "silver"
	    };
	    $.datepicker.setDefaults({ dateFormat: 'yy-mm-dd',changeMonth: true, changeYear: true });
	</script>
	<script type="text/javascript" src="http://webplayer.yahooapis.com/player.js"></script>




<style>
.ui-autocomplete {
       max-height: 100px;
       overflow-y: auto;
       /* prevent horizontal scrollbar */
       overflow-x: hidden;
       font-size:x-small;
       max-width:200px;
   }



.ui-datepicker {
    padding: 0.1em 0.1em 0;
    width: 11em;
}

.ui-widget {
    font-family: Helvetica,Arial,sans-serif;
    font-size: 14px;
}

.ui-datepicker th {
    border: 0 none;
    font-weight: normal;
    padding: 0.2em 0.1em;
    text-align: center;
}

.ui-datepicker th span {
    font-size: 11px;
}

.ui-datepicker td span, .ui-datepicker td a {
    padding: 0.1em;
}

.ui-datepicker td {
    padding: 0.9px;
}

.ui-datepicker .ui-state-highlight {
    height: 12px;
    margin-bottom: 0;
}

.ui-state-default, .ui-widget-content .ui-state-default,
.ui-widget-header .ui-state-default {
    font-size: 10px;
    font-weight: normal;
    text-align: center;
}

.ui-datepicker .ui-datepicker-title {
    line-height: 13px;
}

.ui-datepicker .ui-datepicker-title span {
    font-size: 11px;
}

.ui-datepicker .ui-datepicker-prev span,
.ui-datepicker .ui-datepicker-next span {
    margin-left: -8px;
    margin-top: -8px;
}

.ui-datepicker .ui-datepicker-prev,
.ui-datepicker .ui-datepicker-next {
    height: 15px;
    top: 1px;
    width: 15px;
}

.ui-datepicker-next-hover .ui-icon {
    height: 16px;
    width: 16px;
}


</style>
	<script>

	jQuery(document).ready(function() {

 $(function() {
        var availableTags = ["Census 2000 TIGER/Line Data; MaNIS Georeferencing Calculator","Google Earth"," MaNIS Georeferencing Calculator","MaNIS Georeferencing Calculator","MaNIS Georeferencing Calculator"," BioGeomancer","MaNIS Georeferencing Calculator; Terrain Navigator 3.02 USGS 1:24000","specimen label 	Coordinate Remarks: located point at coordinates given in another identical locality description; MaNIS Det. Ref.: locality description; Calculated from original degrees minutes seconds"];
        $( "#georeference_source" ).autocomplete({
            source: '/component/functions.cfc?method=ac_georeference_source',
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

	$("#made_date").datepicker();

    /*
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

*/
});
	</script>

<input type="text" id="georeference_source">
	<input type="text" id="made_date">


