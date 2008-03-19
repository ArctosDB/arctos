 <!--- no security --->
<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' src='/includes/jquery.js'></script>
<script  src="/includes/inestedsortable.js"></script>
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

<script>
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
</script>

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

<cfdump var=#data#>
<cfoutput>
	<!----
<div id="containerDetails" name="containerDetails" style="display:none; position:absolute; left:30px; top:30px; border:2px solid ##666666; background-color:##CCCCCC; padding:20px;">
	<div id="k" name="k" style="position:absolute; right:0; top:0; width:20px; height:20px; clear:both;">
		<img src="/images/del.gif" class="likeLink" onclick="closeDetails();" />
	</div >
	<input type="hidden" name="noMoveNow" id="noMoveNow" value="0" />
	<table>
		<tr>
			<td align="right">Container Type</td>
			<td><div id="dis_container_type"></div></td>
		</tr>
		<tr>
			<td align="right">Description</td>
			<td><div id="dis_description"></div></td>
		</tr>
		<tr>
			<td align="right">Install Data</td>
			<td><div id="dis_parent_install_date"></div></td>
		</tr>
		<tr>
			<td align="right">Remarks</td>
			<td><div id="dis_container_remarks"></div></td>
		</tr>
		<tr>
			<td align="right">Label</td>
			<td><div id="dis_label"></div></td>
		</tr>
		<tr>
			<td align="right" valign="top">Admin:</td>
			<td><div id="dis_admin"></div></td>
		</tr>
	</table>
</div>
<table width="100%" border="1">
<tr>
	<td>
		<cfset thisPre = "l_">
		<form name="loadLeftTreeForm" onsubmit="return noEnter();">
		<input type="hidden" name="#thisPre#treeID" id="#thisPre#treeID" value="leftTreeBox" />
			<input type="hidden" name="#thisPre#srch" id="#thisPre#srch" value="part" />
		<table cellspacing="0" cellpadding="0" width="100%">
			<tr>
				<td>
					<div id="#thisPre#cat_num_d" style="display:none;">
						<label for="#thisPre#cat_num">Cat Num</label>
						<input type="text" name="#thisPre#cat_num" id="#thisPre#cat_num"  />
					</div>
					<div id="#thisPre#barcode_d" style="display:none;">
						<label for="#thisPre#barcode">Barcode</label>
						<input type="text" name="#thisPre#barcode" id="#thisPre#barcode"  />
					</div>					
				</td>
				<td>
					<div id="#thisPre#description_d" style="display:none;">
						<label for="#thisPre#description">Description</label>
						<input type="text" name="#thisPre#description" id="#thisPre#description"  />
					</div>					
					<div id="#thisPre#collection_id_d" style="display:none;">
						<label for="#thisPre#collection_id">Collection</label>
						<select name="#thisPre#collection_id" id="#thisPre#collection_id" size="1">
						  <option value=""></option>
						  <cfloop query="collections"> 
							<option value="#collection_id#">#coll#</option>
						  </cfloop>
						</select>
					</div>		
				</td>
				<td>
					<div id="#thisPre#container_label_d" style="display:none;">
						<label for="#thisPre#container_label">Label</label>
						<input type="text" name="#thisPre#container_label" id="#thisPre#container_label"  />
					</div>	
					<div id="#thisPre#part_name_d" style="display:none;">
						<label for="#thisPre#part_name">Part</label>
						<select name="#thisPre#part_name" id="#thisPre#part_name" size="1">
						  <option value=""></option>
						  <cfloop query="partName"> 
							<option value="#partName.part_name#">#partName.part_name#</option>
						  </cfloop>
						</select>		
					</div>
				</td>
			</tr>
			<tr>
				<td>
								
				</td>
				<td>
					<div id="#thisPre#container_type_d" style="display:none;">
						<label for="#thisPre#container_type">Container Type</label>
						<select name="#thisPre#container_type" id="#thisPre#container_type" size="1">
							<option value=""></option>
							  <cfloop query="contType"> 
								<option value="#contType.container_type#">#contType.container_type#</option>
							  </cfloop>
						</select>
					</div>
				</td>
				<td>
					
				</td>
			</tr>
			
			<tr>
				<td colspan="3" align="center">
					<input type="button" value="Search" onclick="loadTree('loadLeftTreeForm');" />
					<input type="reset" value="Clear Form" />
					<div id="#thisPre#partSrchBtn">
						<input type="button" value="Part Search" onclick="doPartSearch('l_','part');" />
					</div>
					<div id="#thisPre#contSrchBtn">
						<input type="button" value="Container Search" onclick="doPartSearch('l_','container');" />
					</div>
				</td>
			</tr>
		</table>
		</form>
	</td>
	<td>
	 	<cfset thisPre = "r_">
		
		<form name="loadRightTreeForm" onsubmit="return noEnter();">
		<input type="hidden" name="#thisPre#treeID" id="#thisPre#treeID" value="rightTreeBox" />
			<input type="hidden" name="#thisPre#srch" id="#thisPre#srch" value="part" />
		<table cellspacing="0" cellpadding="0" width="100%">
			<tr>
				<td align="right">
					<div id="#thisPre#cat_num_d" style="display:none;">
						<label for="#thisPre#cat_num">Cat Num</label>
						<input type="text" name="#thisPre#cat_num" id="#thisPre#cat_num"  />
					</div>
					<div id="#thisPre#barcode_d" style="display:none;">
						<label for="#thisPre#barcode">Barcode</label>
						<input type="text" name="#thisPre#barcode" id="#thisPre#barcode"  />
					</div>					
				</td>
				<td>
					<div id="#thisPre#description_d" style="display:none;">
						<label for="#thisPre#description">Description</label>
						<input type="text" name="#thisPre#description" id="#thisPre#description"  />
					</div>					
					<div id="#thisPre#collection_id_d" style="display:none;">
						<label for="#thisPre#collection_id">Collection</label>
						<select name="#thisPre#collection_id" id="#thisPre#collection_id" size="1">
						  <option value=""></option>
						  <cfloop query="collections"> 
							<option value="#collection_id#">#coll#</option>
						  </cfloop>
						</select>
					</div>		
				</td>
				<td>
					<div id="#thisPre#container_label_d" style="display:none;">
						<label for="#thisPre#container_label">Label</label>
						<input type="text" name="#thisPre#container_label" id="#thisPre#container_label"  />
					</div>	
					<div id="#thisPre#part_name_d" style="display:none;">
						<label for="#thisPre#part_name">Part</label>
						<select name="#thisPre#part_name" id="#thisPre#part_name" size="1">
						  <option value=""></option>
						  <cfloop query="partName"> 
							<option value="#partName.part_name#">#partName.part_name#</option>
						  </cfloop>
						</select>		
					</div>
				</td>
			</tr>
			<tr>
				<td>
								
				</td>
				<td>
					<div id="#thisPre#container_type_d" style="display:none;">
						<label for="#thisPre#container_type">Container Type</label>
						<select name="#thisPre#container_type" id="#thisPre#container_type" size="1">
							<option value=""></option>
							  <cfloop query="contType"> 
								<option value="#contType.container_type#">#contType.container_type#</option>
							  </cfloop>
						</select>
					</div>
				</td>
				<td>
					
				</td>
			</tr>
			
			<tr>
				<td colspan="3" align="center">
					<input type="button" value="Search" onclick="loadTree('loadRightTreeForm');" />
					<input type="reset" value="Clear Form" />
					<div id="#thisPre#partSrchBtn">
						<input type="button" value="Part Search" onclick="doPartSearch('r_','part');" />
					</div>
					<div id="#thisPre#contSrchBtn">
						<input type="button" value="Container Search" onclick="doPartSearch('r_','container');" />
					</div>
				</td>
			</tr>
		</table>
		</form>
	</td>
</tr>
<tr>
	<td width="50%" valign="top">
		<div id="leftTreeBox" style="border:2px solid blue; width:500px; height:500px;" ></div> 


</td>
<td width="50%" valign="top">
	<div id="rightTreeBox" style="border:2px solid blue; width:500px; height:500px;"></div> 
</td>
</tr>
</table>
<script>
	doPartSearch('l_','part');
	doPartSearch('r_','part');
	SET_DHTML("containerDetails");
	dd.elements.containerDetails.resizeTo(300,200);
</script>
---->
</cfoutput>