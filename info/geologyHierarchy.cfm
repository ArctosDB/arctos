
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

});
</script>