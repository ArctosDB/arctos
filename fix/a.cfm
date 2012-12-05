<cfinclude template="/includes/_header.cfm">
	<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>

	<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/themes/base/jquery-ui.css" type="text/css" />


<!----
 <script src="http://code.jquery.com/jquery-1.8.3.js"></script>
---->
    <style>
    #sortable { list-style-type: none; margin: 0; padding: 0; width: 450px; }
    #sortable li { margin: 3px 3px 3px 0; padding: 1px; float: left; width: 200px; height: 90px; font-size: 4em; text-align: center; }
	#sortable li.dubbl { margin: 3px 3px 3px 0; padding: 1px; float: left; width: 400px; height: 90px; font-size: 4em; text-align: center; }
    </style>
    <script>
    $(function() {
        $( "#sortable" ).sortable();
        $( "#sortable" ).disableSelection();
    });
    </script>


<ul id="sortable">
    <li class="ui-state-default">1</li>
    <li class="ui-state-default">2</li>
    <li class="ui-state-default">3</li>
    <li class="ui-state-default">4</li>
    <li class="ui-state-default">5</li>
    <li class="ui-state-default">6</li>
    <li class="ui-state-default">7</li>
    <li class="ui-state-default">8</li>
    <li class="ui-state-default">9</li>
    <li class="ui-state-default">10</li>
    <li class="ui-state-default">11</li>
    <li class="ui-state-default dubbl">12 si wide</li>
</ul>

