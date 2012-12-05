<cfinclude template="/includes/_header.cfm">
	<script src="/includes/jquery.gridster.min.js"></script>

	<link rel="stylesheet" href="/includes/jquery.gridster.min.css" type="text/css" />

	<script>


$(function(){ //DOM Ready

    $(".gridster ul").gridster({
        widget_margins: [10, 10],
        widget_base_dimensions: [140, 140]
    });

});




	</script>

	<div class="gridster">
	    <ul>
	        <li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
				bla bla bal some stuff
			</li>
	        <li data-row="2" data-col="1" data-sizex="1" data-sizey="1">

				yada ya stuff
			</li>
	        <li data-row="3" data-col="1" data-sizex="1" data-sizey="1"></li>

	        <li data-row="1" data-col="2" data-sizex="2" data-sizey="1"></li>
	        <li data-row="2" data-col="2" data-sizex="2" data-sizey="2"></li>

	        <li data-row="1" data-col="4" data-sizex="1" data-sizey="1"></li>
	        <li data-row="2" data-col="4" data-sizex="2" data-sizey="1"></li>
	        <li data-row="3" data-col="4" data-sizex="1" data-sizey="1"></li>

	        <li data-row="1" data-col="5" data-sizex="1" data-sizey="1"></li>
	        <li data-row="3" data-col="5" data-sizex="1" data-sizey="1"></li>

	        <li data-row="1" data-col="6" data-sizex="1" data-sizey="1"></li>
	        <li data-row="2" data-col="6" data-sizex="1" data-sizey="2"></li>
	    </ul>
	</div>

