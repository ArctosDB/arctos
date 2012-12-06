<!----
rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />


<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js'></script>

	<script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>
---->

<link <cfinclude template="/includes/_header.cfm">


<style>

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


