 <!--- no security --->

<script type='text/javascript' src='/includes/dhtmlXTree.js'></script>
<script  src="/includes/dhtmlXCommon.js"></script>
<script type='text/javascript' src='/ajax/core/util.js'></script>
	<script type='text/javascript' src='/ajax/core/engine.js'></script>

	<script type='text/javascript' src='/ajax/core/settings.js'></script>
	<cfinclude template="/ajax/core/cfajax.cfm">
<script type='text/javascript' src='/includes/_partAjax.js'></script>

<cfoutput>

<cfset collection_cde='Mamm'>



<cfquery name="partTree" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	SELECT 
		part_id,
		parent_part_id,
		part_name,
		valid_for_items
	FROM
		part_hierarchy
	where 
		collection_cde='#collection_cde#'
		start with parent_part_id=0
	connect by prior part_id = parent_part_id
</cfquery>
<cfset treeName = "partTree#cfid##cftoken#.xml">
<cfset thisFileName = "#Application.webDirectory#/temp/#treeName#">



<table width="100%" border="1">

<tr>
	<td width="70%" valign="top">
		<div id="treeBox" >
			
		</div> 

	</td>
	<td valign="top">
		<ul>
			<li>Drag items to other items to build hierarchy</li>
			<li>Drag items to Never Never Land to remove them from the hierarchy</li>
			<li><span style="color:red;">Red items</span> are search terms, but NOT valid part names</li>
			<li>Doubleclick an item to edit</li>
			<li>Doubliclick Never Never Land to add a part</li>
		</ul>
		<div id="editStuff" style="display:block">
			<form name="editThis" id="editThis">
				<input type="hidden" name="part_id" id="part_id" />
				<label for="part_name">Part Name</label>
				<input type="text" name="part_name" id="part_name" size="50" />
				<label for="description">Description</label>
				<textarea name="description" id="description" rows="3" cols="35"></textarea>
				<label for="valid_for_items">Valid Item Name?</label>
				<select name="valid_for_items" id="valid_for_items" size="1">
					<option value="1">yes</option>
					<option value="0">no</option>
				</select>
				<label for="collection_cde">Collection</label>
				<input type="text" name="collection_cde" id="collection_cde" readonly="yes" class="readClr" />
				<br />
				<input type="button" id="theButton" value="" style='display:none;'/>
			</form>
		</div>
		</td>
</tr>
</table>

<script>
	 theTree=new dhtmlXTreeObject("treeBox","100%","100%;",-1);
	theTree.setDragHandler(onDragPart);
	theTree.enableDragAndDrop(1);
	theTree.setOnDblClickHandler(onDoubleClick);//set function object to call on node select
	theTree.insertNewItem(-1,0,"Never Never Land",0,0,0,0,"SELECT");
	//theTree.insertNewItem(0,1,"big thing",0,0,0,0,"SELECT");
	//theTree.insertNewItem(1,2,"smaller thing",0,0,0,0,"SELECT");
</script>
<cfloop query="partTree">
	<cfif #valid_for_items# is 0>
		<script>
			theTree.insertNewItem(#parent_part_id#,#part_id#,"<span style='color:red;'>#part_name#</span>",0,0,0,0,"SELECT");
		</script>
	<cfelse>
		<script>
			theTree.insertNewItem(#parent_part_id#,#part_id#,"#part_name#(#parent_part_id#,#part_id#)",0,0,0,0,"SELECT");
		</script>
	</cfif>
	
<!---#part_name# - #part_id# #parent_part_id#<br />--->
</cfloop>
</cfoutput>