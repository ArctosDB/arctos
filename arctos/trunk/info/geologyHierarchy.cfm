 <!--- no security --->
<!---

--->
<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<script type="text/javascript" src="/includes/jquery/isortables.js"></script>

<script type='text/javascript' src="/includes/jquery/selector.js"></script>
<script type='text/javascript' src="/includes/jquery/event.js"></script>
<script type='text/javascript' src="/includes/jquery/fx.js"></script>
<script type='text/javascript' src="/includes/jquery/idrag.js"></script>
<script type='text/javascript' src="/includes/jquery/idrop.js"></script>
<script type='text/javascript' src="/includes/jquery/interface.js"></script>

<script type='text/javascript' src="/includes/jquery/inestedsortable.js"></script>
<!----
<cfquery name="data" datasource="#application.web_user#">
	 SELECT  
	 	level,
	 	geology_attribute_hierarchy_id,
	 	parent_id,
		attribute
	FROM
		geology_attribute_hierarchy
	CONNECT BY PRIOR 
		geology_attribute_hierarchy_id = parent_id
</cfquery>
---->

<pre>
//Code:
$('#left-to-right').NestedSortable(
	{
		accept: 'page-item1',
		noNestingClass: "no-nesting",
		opacity: .8,
		helperclass: 'helper',
		onChange: function(serialized) {
			$('#left-to-right-ser')
			.html("This can be passed as parameter 
				to a GET or POST request: " 
				+ serialized[0].hash);
		},
		autoScroll: true,
		handle: '.sort-handle'
	}
);
</pre>

        <div class="wrap">
            <ul id="left-to-right" class="page-list">

                <li id="ele-1" class="clear-element page-item1 left no-nesting">
                    <div class='sort-handle'><img src="file.gif" align="left"/>File 1</div>
                </li>
                <li id="ele-2" class="clear-element page-item1 left no-nesting">
                    <div class='sort-handle'><img src="file.gif" align="left"/>File 2</div>
                </li>
                <li id="ele-3" class="clear-element page-item1 left">
                    <div class='sort-handle'><img src="folder.gif" align="left"/>Folder 1</div>

                </li>
                 <li id="ele-4" class="clear-element page-item1 left">
                    <div class='sort-handle'><img src="folder.gif" align="left"/>Folder 2</div>
					<ul class="page-list">
		                <li id="ele-5" class="clear-element page-item1 left">
		                 	<div class='sort-handle'><img src="folder.gif" align="left"/>Folder 3</div>
							<ul  class="page-list" >
				                <li id="ele-6" class="clear-element page-item1 left no-nesting">

	                            	<div class='sort-handle'><img src="file.gif" align="left"/>File 3</div>
				                </li>
							</ul>
						</li>
					</ul>
                </li>
            </ul>
        </div>

		<br/>
		<div id='left-to-right-ser' class="wrap">
			Change the order of the above NestedSortable and the serialized output will be shown here.
		</div>
		
        <h3>Right to Left nesting.</h3>

<pre>
//Code:
$('#right-to-left').NestedSortable(
	{
	accept: 'page-item2',
	opacity: .8,
	helperclass: 'helper',
	rightToLeft: true,
	nestingPxSpace: '60', 
	currentNestingClass: 'current-nesting'
	}
);
</pre>

        <div class="wrap">

            <ul id="right-to-left" class="page-list">
                <li class="clear-element page-item2 sort-handle right">
                    <div>Element 1</div>
                </li>
                <li class="clear-element page-item2 sort-handle right">
                    <div>Element 2</div>
                </li>
                <li class="clear-element page-item2 sort-handle right">

                    <div>Element 3</div>
                </li>
                 <li class="clear-element page-item2 sort-handle right">
                    <div>Element 4</div>
					<ul class="page-list">
		                <li class="clear-element page-item2 sort-handle right">
		                 	<div>Element 5</div>

		           
							<ul  class="page-list" >
				                <li class="clear-element page-item2 sort-handle right">
	                            	<div>Element 6</div>
				                </li>
							</ul>
						</li>
					</ul>
                </li>

            </ul>
        </div>
		
        <h3>Spans and Divs</h3>

<pre>
//Code:
$('#spans-divs').NestedSortable(
	{
	accept: 'page-item3',
	opacity: 0.8,
	helperclass: 'helper',
	nestingPxSpace: 20,
	currentNestingClass: 'current-nesting',
	fx:400,
	revert: true,
	autoScroll: false
	}
);
</pre>
		
        <div class="wrap">
            <span id="spans-divs" class="page-list">
                <div class="clear-element page-item3 sort-handle left">

                    <div>Element 1</div>
                </div>
                <div class="clear-element page-item3 sort-handle left">
                    <div>Element 2</div>
                </div>
                <div class="clear-element page-item3 sort-handle left">
                    <div>Element 3</div>

                </div>
                <div class="clear-element page-item3 sort-handle left">
                    <div>Element 4</div>
					<span class="page-list">
		                <div class="clear-element page-item3 sort-handle left">
		                    <div>Element 5</div>
							<span class="page-list">
				                <div class="clear-element page-item3 sort-handle left">

				                    <div>Element 6</div>
				                </div>
							</span>
						</div>
					</span>
                </div>
            </span>
        </div>

		
        <h3>Regular Sortable</h3>

<pre>
//Code:
$('#spans-divs-regular').Sortable(
	{
	accept: 'page-item4',
	opacity: .8,
	helperclass: 'helper'
	}
);
</pre>
		
        <div class="wrap">
            <span id="spans-divs-regular" class="page-list">
                <div class="clear-element page-item4 sort-handle left">
                    <div>Element 1</div>
                </div>

                <div class="clear-element page-item4 sort-handle left">
                    <div>Element 2</div>
                </div>
                <div class="clear-element page-item4 sort-handle left">
                    <div>Element 3</div>
                </div>
                <div class="clear-element page-item4 sort-handle left">
                	<div>Element 4</div>

				</div>
                <div class="clear-element page-item4 sort-handle left">
                    <div>Element 5</div>
                </div>
                <div class="clear-element page-item4 sort-handle left">
                    <div>Element 6</div>
                </div>
            </span>

        </div>
		
<script type="text/javascript">
jQuery( function($) {

$('#left-to-right').NestedSortable(
	{
		accept: 'page-item1',
		noNestingClass: "no-nesting",
		opacity: 0.8,
		helperclass: 'helper',
		onChange: function(serialized) {
			$('#left-to-right-ser')
			.html("This can be passed as parameter to a GET or POST request: <br/>" + serialized[0].hash);
		},
		autoScroll: true,
		handle: '.sort-handle'
	}
);

$('#right-to-left').NestedSortable(
	{
	accept: 'page-item2',
	opacity: 0.8,
	helperclass: 'helper',
	rightToLeft: true,
	nestingPxSpace: '60', 
	currentNestingClass: 'current-nesting'
	}
);

$('#spans-divs').NestedSortable(
	{
	accept: 'page-item3',
	opacity: 0.8,
	helperclass: 'helper',
	nestingPxSpace: 20,
	currentNestingClass: 'current-nesting',
	fx:400,
	revert: true,
	autoScroll: false
	}
);

$('#spans-divs-regular').Sortable(
	{
	accept: 'page-item4',
	opacity: 0.8,
	helperclass: 'helper'
	}
);
	
});
</script>