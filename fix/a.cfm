<cfoutput>
	<cfif not isdefined("url.v")>
		change the URL to a v parameter.
		<br>Example: <a href="a.cfm?v=at54h">a.cfm?v=at54h</a>
	</cfif>
	<cfset result=FormatBaseN(url.v,36)>
	The base36 value of #url.v# is #result#.
</cfoutput>



	 <cfthrow type="ThrownError" message="This error was thrown from the bugTest action page.">

	 <cfabort>
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

	<link rel="stylesheet" href="/includes/style.css" />





	<script type="text/javascript">
	    var YWPParams =
	    {
	        termDetection: "on" ,
	        theme: "silver"
	    };
	    $.datepicker.setDefaults({ dateFormat: 'yy-mm-dd',changeMonth: true, changeYear: true });
	</script>
	<script type="text/javascript" src="http://webplayer.yahooapis.com/player.js"></script>

<!----


<style>
.ui-autocomplete {
       max-height: 100px;
       overflow-y: auto;
       /* prevent horizontal scrollbar */
       overflow-x: hidden;
       font-size:x-small;
       max-width:200px;
   }

.ui-widget { font-size: 1em; }

</style>

---->
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


