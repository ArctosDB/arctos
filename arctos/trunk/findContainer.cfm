<div id="_header">
<cfinclude template="/includes/_header.cfm">
</div>
<cfset title='Find Containers'>
<script type='text/javascript' src='/includes/dhtmlxtree.js'><!-- --></script>
<script type="text/javascript" src="/includes/dhtmlxcommon.js"></script>
<link rel="STYLESHEET" type="text/css" href="/includes/dhtmlxtree.css">



<script type='text/javascript' src='/includes/_treeAjax.js'></script>

<cfquery name="contType" datasource="#Application.web_user#">
	select container_type from ctContainer_Type order by container_type
</cfquery>
 <cfquery name="PartName" datasource="#Application.web_user#">
	select distinct part_name from specimen_part ORDER BY part_name
</cfquery>
<cfquery name="collections" datasource="#Application.web_user#">
	select collection_id, institution_acronym || ' ' || collection_cde coll from collection
</cfquery>
<cfquery name="ctcoll_other_id_type" datasource="#Application.web_user#">
	select OTHER_ID_TYPE from
	ctcoll_other_id_type
	group by OTHER_ID_TYPE
	order by OTHER_ID_TYPE
</cfquery>
<cfoutput>

<table border width="100%">
	<tr>
		<td valign="top"><!--------------------------- search pane ----------------------------->
			<div id="partSearchPane">
				<form onSubmit="loadTree();return false;">
				<label for="cat_num">Cat Num (comma-list OK)</label>
				<input type="text" name="cat_num" id="cat_num"  />
				<label for="barcode">Barcode (comma-list OK)</label>
				<input type="text" name="barcode" id="barcode"  />
				<label for="container_label">Label (% for wildcard)</label>
				<input type="text" name="container_label" id="container_label"  />
				<label for="collection_id">Collection</label>
				<select name="collection_id" id="collection_id" size="1">
					<option value=""></option>
						<cfloop query="collections"> 
							<option value="#collection_id#">#coll#</option>
				  		</cfloop>
				</select>
				<label for="description">Description</label>
				<input type="text" name="description" id="description"  />
				<label for="part_name">Part</label>
				<select name="part_name" id="part_name" size="1">
					<option value=""></option>
						  <cfloop query="partName"> 
							<option value="#partName.part_name#">#partName.part_name#</option>
						  </cfloop>
				</select>
				<label for="container_type">Container Type</label>
				<select name="container_type" id="container_type" size="1">
					<option value=""></option>
					  <cfloop query="contType"> 
						<option value="#contType.container_type#">#contType.container_type#</option>
					  </cfloop>
				</select>
				<label for="other_id_type">OID Type</label>
				<select name="other_id_type" id="other_id_type" size="1" style="width:120px;">
					<option value=""></option>
					<cfloop query="ctcoll_other_id_type"> 
						<option value="#ctcoll_other_id_type.other_id_type#">#ctcoll_other_id_type.other_id_type#</option>
					</cfloop>
				</select>	
				<label for="other_id_value">OID Value (% for wildcard)</label>
				<input type="text" name="other_id_value" id="other_id_value" />
				<br>
				<input type="submit" value="Search"
					class="schBtn">
				&nbsp;&nbsp;&nbsp;
				<input class="clrBtn"
					type="reset" value="Clear"/>				
				</form>
			</div>
				
				
		</td><!--------------------------------- end search pane ------------------------------------->
		<td><!------------------------------------- tree pane --------------------------------------------->
			<div id="treePane" style="height:600px;"></div>
		</td><!------------------------------------- end tree pane --------------------------------------------->
		
		<td valign="top">
			<div id="detailPane"></div>
		</td>
	</tr>
</table>
<cfif isdefined("url.collection_object_id") and len(#url.collection_object_id#) gt 0>
	<script language="javascript" type="text/javascript">
		showSpecTreeOnly('#url.collection_object_id#');
	</script>
<cfelse>
	<cfset autoSubmit=false>
	<cfloop list="#StructKeyList(url)#" index="key">
	<cfif len(#url[key]#) gt 0>
	<cfset autoSubmit=true>
	<script language="javascript" type="text/javascript">
		if (document.getElementById('#lcase(key)#')) {
			document.getElementById('#lcase(key)#').value='#url[key]#';
		}
	</script>
	</cfif>
	</cfloop>
	<cfif autoSubmit is true>
	<script language="javascript" type="text/javascript">
		loadTree();
	</script>
	</cfif>
</cfif> 
</cfoutput>
<div id="_footer">
	<cfinclude template="/includes/_footer.cfm">
</div>