<cfinclude template="/includes/_header.cfm">
 
<script type='text/javascript' src='/includes/dhtmlxtree.js'><!-- --></script>
<script type="text/javascript" src="/includes/dhtmlxcommon.js"></script>
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<link rel="STYLESHEET" type="text/css" href="/includes/dhtmlxtree.css">

<script type='text/javascript' src='/includes/wz_dragdrop.js'></script>

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
<table border>
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
				<select name="other_id_type" id="other_id_type" size="1">
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
<cfset autoSubmit=false>
<cfloop list="#StructKeyList(url)#" index="key">
<cfif len(#url[key]#) gt 0>
	<cfset autoSubmit=true>
	<script language="javascript" type="text/javascript">
		if (document.getElementById(lower('#key#''))) {
			document.getElementById(lower('#key#''))).value='#url[key]#';
		}
	</script>
	 #key#=#url[key]#<br>
</cfif>
</cfloop>
		

<div id="containerDetails" name="containerDetails" style="display:none; position:absolute; border:2px solid ##666666; background-color:##CCCCCC; padding:20px;">
	<div id="k" name="k" style="position:absolute; right:0; top:0; width:20px; height:20px; clear:both;">
		<img src="/images/del.gif" class="likeLink" onclick="closeDetails();" />
	</div >
	<input type="hidden" name="noMoveNow" id="noMoveNow" value="0" />
	<table>
		<tr>
			<td align="right" nowrap="nowrap">Container Type:</td>
			<td><div id="dis_container_type"></div></td>
		</tr>
		<tr>
			<td align="right">Description:</td>
			<td><div id="dis_description"></div></td>
		</tr>
		<tr>
			<td align="right">Install Date:</td>
			<td><div id="dis_parent_install_date"></div></td>
		</tr>
		<tr>
			<td align="right">Remarks:</td>
			<td><div id="dis_container_remarks"></div></td>
		</tr>
		<tr>
			<td align="right">Label:</td>
			<td><div id="dis_label"></div></td>
		</tr>
		<tr>
			<td align="right" valign="top">Admin:</td>
			<td><div id="dis_admin"></div></td>
		</tr>
	</table>
</div>
<!---
<table width="100%" border="1">
<tr>
	<td>
		<cfset thisPre = "n_">
		<form name="loadFindTreeForm" method="post" action="/oh/crap/it/submitted" onsubmit="loadTree('loadFindTreeForm');return false;">
		<!--- holders for mouse positions --->
		
		<input type="hidden" name="#thisPre#treeID" id="#thisPre#treeID" value="findTreeBox" />
			<input type="hidden" name="#thisPre#srch" id="#thisPre#srch" value="part" />
		<table cellspacing="0" cellpadding="0" width="100%" border="0">
			<tr>
				<td colspan="3" align="right" nowrap="nowrap">
					<!---
					<cfinclude template="container_nav.cfm"><a href="javascript:void(0);" onClick="getDocs('container')"><img src="/images/info.gif" border="0"></a>
					--->

				</td>
			</tr>
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
					<div id="#thisPre#container_label_d" style="display:none;">
						<label for="#thisPre#container_label">Label</label>
						<input type="text" name="#thisPre#container_label" id="#thisPre#container_label"  />
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
					<div id="#thisPre#description_d" style="display:none;">
						<label for="#thisPre#description">Description</label>
						<input type="text" name="#thisPre#description" id="#thisPre#description"  />
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
				
				<td colspan="3" align="center">
					<div id="#thisPre#container_type_d" style="display:none;">
						<label for="#thisPre#container_type">Container Type</label>
						<select name="#thisPre#container_type" id="#thisPre#container_type" size="1">
							<option value=""></option>
							  <cfloop query="contType"> 
								<option value="#contType.container_type#">#contType.container_type#</option>
							  </cfloop>
						</select>
					</div>
					<div id="#thisPre#other_id_d" style="display:none;">
						<table cellpadding="0" cellspacing="0" width="100%">
							<tr>
								<td>
									<label for="#thisPre#other_id_type">OID Type</label>
						<select name="#thisPre#other_id_type" id="#thisPre#other_id_type" size="1">
						  <option value=""></option>
						  <cfloop query="ctcoll_other_id_type"> 
							<option value="#ctcoll_other_id_type.other_id_type#">#ctcoll_other_id_type.other_id_type#</option>
						  </cfloop>
						</select>	
								</td>
								<td>&nbsp;</td>
								<td>
									<label for="#thisPre#other_id_value">OID Value</label>
						<input type="text" name="#thisPre#other_id_value" id="#thisPre#other_id_value" />
								</td>
							</tr>
						</table>
						
						
						
					</div>
				</td>
			</tr>
			
			<tr>
				<td align="left">
					<div id="#thisPre#partSrchBtn">
						<input type="button" value="Goto Part Search" class="lnkBtn" onmouseover="this.className='lnkBtn btnhov'"
				onmouseout="this.className='lnkBtn'" onclick="doPartSearch('n_','part');" />
					</div>
					<div id="#thisPre#contSrchBtn">
						<input type="button"  class="lnkBtn" onmouseover="this.className='lnkBtn btnhov'"
				onmouseout="this.className='lnkBtn'" value="Goto Container Search" onclick="doPartSearch('n_','container');" />
					</div>
				</td>
				<td align="center">
				<input class="clrBtn" onmouseover="this.className='clrBtn btnhov'"
				onmouseout="this.className='clrBtn'"
				type="button" value="Clear"
				onclick="loadFindTreeForm.reset();focusDefault();" />
				</td>
				<td colspan="2" align="right" nowrap="nowrap">					
					<input type="submit" value="Search"
					class="schBtn" onmouseover="this.className='schBtn btnhov'"
				onmouseout="this.className='schBtn'"
				onclick="loadTree('loadFindTreeForm');" />
				</td>
				
			</tr>
		</table>
		</form>
	</td>
</tr>
<tr>
	<td width="50%" valign="top" align="left">
		<div id="findTreeBox" style="border:2px solid blue;" ></div> 


</td>
</tr>
</table>
<cfif isdefined("URL.RunOnLoad") and len(#URL.RunOnLoad#) gt 0>
	<!--- this takes a |-delimited array of arguments and
	parses them out into the appropriate fields, then runs the 
	search
	First argument must be SearchType={IN part,container}
	EG:RunOnLoad=SearchType:part|cat_num:12|part_name:skull
	---->
	<cfset ROL = #URL.RunOnLoad#>
	<cfset SearchType = listgetat(ROL,1,"|")>
	<cfset SearchType=replace(SearchType,"SearchType:","")>
	<cfif not (#SearchType# is "part" OR #SearchType# is "container")>
		<div style="background-color:##FF0000">
		An error occured while loading URL-passed search. Search type must be part or container
		</div>
	</cfif>
	<cfset ROL=listdeleteat(ROL,1,"|")>
	<script>
		doPartSearch('n_','#SearchType#');
		// split the remainder of the passed string - now term:value pairs split by | - into an array
		var rawRol = '#rol#';
		//alert(rawRol);
		var rawRol = unescape(rawRol);
		//alert(rawRol);
		var broken_rol = rawRol.split("|");
		for (i = 0; i < broken_rol.length; i++) { 
		 	var thisPair = broken_rol[i];
			//alert(thisPair);
			var thisPairArray = thisPair.split(":");
			var thisField = thisPairArray[0];
			var thisValue = thisPairArray[1];
			//alert(thisField);
			//alert(thisValue);
			//	make sure the element we want exists
			var elemName = "n_" + thisField;
			if (document.getElementById(elemName)) {
					var elemDef = document.getElementById(elemName);
					elemDef.value=thisValue;
					//alert('skippy');
				} else {
					alert('An invalid field name was passed in. Whatever you see is probably not what you wanted to see.');
				}
			}
			loadTree('loadFindTreeForm');
		
	</script>
<cfelse>
	<script>
		doPartSearch('n_','part');
	</script>
	
</cfif>

<script>
	SET_DHTML("containerDetails");
	dd.elements.containerDetails.resizeTo(300,200);
	focusDefault();
</script>
<script type='text/javascript' src='/includes/wz_tooltip.js'></script>
---------->
</cfoutput>