<!----
<cfinclude template="/includes/_header.cfm">

---->

<link rel="stylesheet" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" />


<script type='text/javascript' language="javascript" src='https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js'></script>

	<script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>


	<script>

	jQuery(document).ready(function() {

 $(function() {
        var availableTags = [
            "ActionScript",
            "AppleScript",
            "Asp",
            "BASIC",
            "C",
            "C++",
            "Clojure",
            "COBOL",
            "ColdFusion",
            "Erlang",
            "Fortran",
            "Groovy",
            "Haskell",
            "Java",
            "JavaScript",
            "Lisp",
            "Perl",
            "PHP",
            "Python",
            "Ruby",
            "Scala",
            "Scheme"
        ];
        $( "#georeference_source" ).autocomplete({
            source: '/ajax/autocomplete.cfm?type=georeference_source'
        });
    });


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
