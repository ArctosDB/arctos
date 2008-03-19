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
<script>
$('#spans-divs-regular').Sortable(
	{
	accept: 'page-item4',
	opacity: .8,
	helperclass: 'helper'
	}
);
</script>
No styles defined

Click on tag to toggle stickyness
<div class="wrap">
<span class="page-list" id="spans-divs-regular">
<div class="clear-element page-item4 sort-handle left" style="-moz-user-select: none;">
<div>

Element 1

</div>
</div>
<div class="clear-element page-item4 sort-handle left" style="-moz-user-select: none;">
<div>

Element 2

</div>
</div>
<div class="clear-element page-item4 sort-handle left" style="-moz-user-select: none;">
<div>

Element 3

</div>
</div>
<div class="clear-element page-item4 sort-handle left" style="-moz-user-select: none;">
<div>

Element 4

</div>
</div>
<div class="clear-element page-item4 sort-handle left" style="-moz-user-select: none;">
<div>

Element 5

</div>
</div>
<div class="clear-element page-item4 sort-handle left" style="-moz-user-select: none;">
<div>

Element 6

</div>
</div>
</span>
</div>
 