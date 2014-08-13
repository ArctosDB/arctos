<cfif not isdefined("action")><cfset action="nothing"></cfif>
<cfinclude template="/includes/functionLib.cfm">
<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js'></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
<script type='text/javascript' language="javascript" src='/includes/ajax.js'></script>



<!----
<link rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />

Themes Compressed: , , , , , , , , , , , , ,, , , , , , , , , ui-lightness, and .

---->
<link rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />



<link rel="alternate stylesheet" title="ui-lightness" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/themes/ui-lightness/jquery-ui.css" />
<link rel="alternate stylesheet" title="ui-lightness" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/ui-lightness/jquery-ui.css" />
<link rel="alternate stylesheet" title="black-tie" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/black-tie/jquery-ui.css" />
<link rel="alternate stylesheet" title="blitzer" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/blitzer/jquery-ui.css" />
<link rel="alternate stylesheet" title="cupertino" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/cupertino/jquery-ui.css" />
<link rel="alternate stylesheet" title="dark-hive" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/dark-hive/jquery-ui.css" />
<link rel="alternate stylesheet" title="dot-luv" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/dot-luv/jquery-ui.css" />
<link rel="alternate stylesheet" title="eggplant" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/eggplant/jquery-ui.css" />
<link rel="alternate stylesheet" title="excite-bike" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/excite-bike/jquery-ui.css" />
<link rel="alternate stylesheet" title="flick" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/flick/jquery-ui.css" />
<link rel="alternate stylesheet" title="hot-sneaks" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/hot-sneaks/jquery-ui.css" />
<link rel="alternate stylesheet" title="humanity" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/humanity/jquery-ui.css" />
<link rel="alternate stylesheet" title="le-frog" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/le-frog/jquery-ui.css" />
<link rel="alternate stylesheet" title="mint-choc" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/mint-choc/jquery-ui.css" />
<link rel="alternate stylesheet" title="overcast" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/overcast/jquery-ui.css" />
<link rel="alternate stylesheet" title="pepper-grinder" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/pepper-grinder/jquery-ui.css" />
<link rel="alternate stylesheet" title="redmond" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/redmond/jquery-ui.css" />
<link rel="alternate stylesheet" title="smoothness" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/smoothness/jquery-ui.css" />
<link rel="alternate stylesheet" title="south-street" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/south-street/jquery-ui.css" />
<link rel="alternate stylesheet" title="start" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/start/jquery-ui.css" />
<link rel="alternate stylesheet" title="sunny" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/sunny/jquery-ui.css" />
<link rel="alternate stylesheet" title="swanky-purse" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/swanky-purse/jquery-ui.css" />
<link rel="alternate stylesheet" title="trontastic" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/trontastic/jquery-ui.css" />
<link rel="alternate stylesheet" title="ui-darkness" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/ui-darkness/jquery-ui.css" />
<link rel="alternate stylesheet" title="vader" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/vader/jquery-ui.css" />


<link rel="stylesheet" href="/includes/style.min.css" />
<script type="text/javascript">
    $.datepicker.setDefaults({ dateFormat: 'yy-mm-dd',changeMonth: true, changeYear: true, constrainInput: false });
</script>