
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

<script type='text/javascript' src="/includes/jquery/jquery.nestedsortablewidget.js"></script>
<style type="text/css">
			.redFont {color:red;}
			div.wrap {
				border:1px solid #BBBBBB;
				padding: 1em 1em 1em 1em;
			}
			
			.page-list {
				list-style: none;
				margin: 0;
				padding: 0;
				display: block;
			}
			
			.clear-element {
				clear: both;
			}
			
			.page-item1 > div,
			.page-item2 > div,
			.page-item3 > div,
			.page-item4 > div {
				background: #f8f8f8;
				margin: 0.25em 0 0 0;
			}

			.left {
				text-align: left;
			}
			
			.right {
				text-align: right;
			}

			.sort-handle {
				cursor:move;
			}
			
			.helper {
			border:2px dashed #777777;
			}
			
			.current-nesting {
				background-color: yellow;
			}
			
			.bold {
				color: red;
				font-weight: bold;
			}
			
		</style>
		
<!----
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
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
<cfquery name="ctgeology_attribute"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select geology_attribute from ctgeology_attribute  order by geology_attribute
</cfquery>
<cfquery name="cData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	 SELECT  
	 	level,
	 	geology_attribute_hierarchy_id,
	 	parent_id,
		attribute
	FROM
		geology_attribute_hierarchy
	start with parent_id is null
	CONNECT BY PRIOR 
		geology_attribute_hierarchy_id = parent_id
</cfquery>
	<div id='spans-divs-ser' class="wrap">what the??</div>
<br>Current Data (values in red are NOT code table values but may still be used in searches):
<cfset levelList = "">
<cfoutput>
	
	
	<hr>
	
	<div id="ajax-response1"></div>
	
	
	<hr>
		<div class="wrap">
            <span id="spans-divs" class="page-list">
  
	<cfloop query="cData">
		
   <!--- Is the last value in the list this level? --->
   <cfif listLast(levelList,",") IS NOT cData.level>
      <!--- Is this level in the levelList?
          If so, we need to close previous level down to this one now. --->
      <cfset levelListIndex = listFind(levelList,cData.level,",")>
      <cfif levelListIndex IS NOT 0>
         <cfset numberOfLevelsToRemove = listLen(levelList,",") - levelListIndex>
         <cfloop from="1" to="#numberOfLevelsToRemove#" index="i">
            <!--- Shorten the list to the appropriate level --->
            <cfset levelList = listDeleteAt(levelList,listLen(levelList,","))>
         </cfloop>
         #repeatString("</span>",numberOfLevelsToRemove)#
      <cfelse>
         <!--- Not in list, so start a new list level --->
         <cfset levelList = listAppend(levelList,cData.level)>
         <span class="page-list" style="padding-left: 20px; padding-right: 0pt;">
      </cfif>
   </cfif>


	<cfif not listfindnocase(valuelist(ctgeology_attribute.geology_attribute),attribute)>
		  <cfset aClass=" redFont">
	<cfelse>
		<cfset aClass="">
	</cfif>
	<div id="d_#geology_attribute_hierarchy_id#" class="clear-element page-item3 sort-handle left"><div>#attribute# (#level#)</div></div>

   <!--- If this is the last row, then we need to close all unordered lists --->
   <cfif cData.currentRow IS cData.recordCount>
      #repeatString("</span>",listLen(levelList,","))#
   </cfif>


		<!---
		<div id="d_#geology_attribute_hierarchy_id#" class="clear-element page-item3 sort-handle left">
			#attribute# (#level#)
		</div>
		---->
		
		
		
	</cfloop>
	 </span>
        </div>
		


	
	<!---
		<cfdump var="#cData#">
	<div class="wrap">
            <span id="spans-divs" class="page-list">
               
				
				<div  id="one" class="clear-element page-item3 sort-handle left">

                    <div>Element 1</div>
                </div>
                <div  id="two" class="clear-element page-item3 sort-handle left">
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
		--->
	       <!---
	        <div class="wrap">
<cfloop query="cData">
	

   <!--- Is the last value in the list this level? --->
   <cfif listLast(levelList,",") IS NOT cData.level>
      <!--- Is this level in the levelList?
          If so, we need to close previous level down to this one now. --->
      <cfset levelListIndex = listFind(levelList,cData.level,",")>
      <cfif levelListIndex IS NOT 0>
         <cfset numberOfLevelsToRemove = listLen(levelList,",") - levelListIndex>
         <cfloop from="1" to="#numberOfLevelsToRemove#" index="i">
            <!--- Shorten the list to the appropriate level --->
            <cfset levelList = listDeleteAt(levelList,listLen(levelList,","))>
         </cfloop>
         #repeatString("</ul>",numberOfLevelsToRemove)#
      <cfelse>
         <!--- Not in list, so start a new list level --->
         <cfset levelList = listAppend(levelList,cData.level)>
         <ul  id="left-to-right" class="page-list">
      </cfif>
   </cfif>

  <li  id="thingy_#geology_attribute_hierarchy_id#" class="clear-element page-item1 left no-nesting"><div class='sort-handle'
	<cfif not listfindnocase(valuelist(ctgeology_attribute.geology_attribute),attribute)>
		  style="color:red"
	</cfif>
	>#attribute#</div></li>

   <!--- If this is the last row, then we need to close all unordered lists --->
   <cfif cData.currentRow IS cData.recordCount>
      #repeatString("</ul>",listLen(levelList,","))#
   </cfif>


	
	
	
	
	
	
	

</cfloop>
</div>
--->
</cfoutput>

<!---------
<div class="wrap">
            <span id="spans-divs" class="page-list">
                <div  id="one" class="clear-element page-item3 sort-handle left">

                    <div>Element 1</div>
                </div>
                <div  id="two" class="clear-element page-item3 sort-handle left">
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
	<div id='spans-divs-ser' class="wrap">what the??</div>
	
	--->
<script type="text/javascript">
jQuery( function($) {


$('#ajax-response1').NestedSortableWidget({
	loadUrl: "/fix/json_load.cfm"
});



$('#spans-divs').NestedSortable(
	{
	accept: 'page-item3',
	opacity: 0.8,
	helperclass: 'helper',
	nestingPxSpace: 20,
	currentNestingClass: 'current-nesting',
	fx:400,
	onChange: function(serialized) {
			$('#spans-divs-ser')
			.html("This can be passed as parameter to a GET or POST request: <br/>" + serialized[0].hash);
		},
	revert: true,
	autoScroll: false
	}
);
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