<cfinclude template="/includes/_header.cfm">
<script language="javascript" type="text/javascript">
	function addPartToContainer () {
		var collection_id=document.getElementById('collection_id').value;
		var other_id_type=document.getElementById('other_id_type').value;
		var oidnum=document.getElementById('oidnum').value;
		var part_name=document.getElementById('part_name').value;
		var part_name_2=document.getElementById('part_name_2').value;
		var parent_barcode=document.getElementById('parent_barcode').value;
		var new_container_type=document.getElementById('new_container_type').value;
		alert('here we gonow....');
		DWREngine._execute(_cfscriptLocation, null, 'addPartToContainer',collection_id,other_id_type,oidnum,part_name,part_name_2,parent_barcode,new_container_type,success_addPartToContainer);
		
		//
	}
	function success_addPartToContainer(result) {
		alert(result);
		statAry=result.split("|");
		var status=statAry[0];
		var msg=statAry[1];
		alert(status);
		alert(msg);
	}
</script>
<!--------------------------------------------------------------------------->
<cfif #action# is "validate">
<!--- they can do several things here
	1) If they supplied a cat_num, a part, and a parent barcode:
		a) create a new part for that specimen and put it in the parent, or
		b) put existing part in new parent
	2) If they supplied a barcode and a parent barcode:
		a) move the part to the new parent
---->		
	<cfoutput>
		<cfset back = '<a href="aps.cfm?lastPart=#part_name#&lastColl=#collection_id#
			&lastParent=#parent_barcode#
			&lastCat=#oidnum#&lastType=#other_id_type#&lastNewType=#new_container_type#">Go Back</a>'>
			<!--- find the collection object ---->
		<cfif #other_id_type# is "catalog_number">
			<cfquery name="coll_obj" datasource="#Application.web_user#">
				select specimen_part.collection_object_id FROM
					cataloged_item,
					specimen_part
				WHERE
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
					collection_id=#collection_id# AND
					cat_num=#oidnum# AND
					part_name='#part_name#'
			</cfquery>
		<cfelse>
			<cfquery name="coll_obj" datasource="#Application.web_user#">
				select specimen_part.collection_object_id FROM
					cataloged_item,
					specimen_part,
					coll_obj_other_id_num
				WHERE
					cataloged_item.collection_object_id = specimen_part.derived_from_cat_item AND
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id AND
					collection_id=#collection_id# AND
					other_id_type='#other_id_type#' AND
					other_id_num= '#oidnum#' AND
					part_name='#part_name#'
			</cfquery>
		</cfif>
		<cfif #coll_obj.recordcount# is 1>
			<!--- see if they gave a valid parent container ---->
			<cfquery name="isGoodParent" datasource="#Application.web_user#">
				select container_id from container where container_type <> 'collection object'
				and barcode='#parent_barcode#'
			</cfquery>
			<cfif #isGoodParent.recordcount# is 1>
				<!---- Find coll obj container ---->
				<cfquery name="cont" datasource="#Application.web_user#">
					select container_id FROM coll_obj_cont_hist where
					collection_object_id=#coll_obj.collection_object_id#
				</cfquery>
				<cfif #cont.recordcount# is 1>
					
					<!-----
					disable for testing
					
					---->
					<cfquery name="newparent" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,cfid)#">
						UPDATE container SET container_type = '#new_container_type#' WHERE
						container_id=#isGoodParent.container_id#
					</cfquery>
					<cfquery name="moveIt" datasource="user_login" username="#session.username#" password="#decrypt(session.epw,cfid)#">
						UPDATE container SET parent_container_id = #isGoodParent.container_id# WHERE
						container_id=#cont.container_id#
					</cfquery>
					
					<cfquery name="catcollobj" datasource="#Application.web_user#">
							select distinct(derived_from_cat_item) FROM
								specimen_part
							WHERE
								collection_object_id=#coll_obj.collection_object_id#
				  </cfquery>
					
					You just put 
					<a href="/SpecimenDetail.cfm?collection_object_id=#catcollobj.derived_from_cat_item#">
					#other_id_type# #oidnum#</a>'s #part_name# 
					into container 
					<a href="/Container.cfm?barcode=#parent_barcode#&srch=container">#parent_barcode#</a>
					
				<cfelse>
					The part you tried to move doesn't exist as a container. That probably isn't your fault!
					Email <a href="mailto:fndlm@uaf.edu">dusty</a>. Now!
				</cfif>
				
			<cfelse>
				The parent barcode you entered doesn't resolve to a valid barcode, or it's a collection object.
				Barcoded containers must exist before you put things in them, and you can't put collection 
				objects into other collection objects.
			</cfif>
			
		<cfelseif #coll_obj.recordcount# is 0>
			The part you entered doesn't exist!
		<cfelse>#coll_obj.recordcount#
				The part you entered exists #coll_obj.recordcount# times. That may be good data, but this form can't
				handle it!
		</cfif>
	</cfoutput>
</cfif>
<!------------------------------------------------------------------->
<cfif #action# is "nothing">
	<cfoutput>
	<cfquery name="ctCollection" datasource="#Application.web_user#">
		select collection, collection_id FROM collection order by collection
	</cfquery>
	<cfquery name="ctPartName" datasource="#Application.web_user#">
		select distinct(part_name) FROM ctspecimen_part_name order by part_name
	</cfquery>
	<cfquery name="ctOtherIdType" datasource="#Application.web_user#">
		select distinct(other_id_type) FROM ctcoll_other_id_type order by other_id_type
	</cfquery>	
	<cfquery name="ctContType" datasource="#Application.web_user#">
		select container_type from ctcontainer_type
		order by container_type
	</cfquery>
	
	<p style="font-size:.8em;">
		This application puts collection objects into containers.
		Enter enough information to uniquely identify a collection object 
		(ie, original field number=1 probably won't work) and the barcode of the 
		container you'd like to put the object into.
	</p>
	<table border id="pTable">
	<form name="scans" method="post" action="aps.cfm" id="scans">
		<input type="hidden" name="action" value="validate">
		<tr>
			<td>
				<label for="collection_id">Collection</label>
				<select name="collection_id" id="collection_id" size="1">
					<cfloop query="ctCollection">
						<option value="#collection_id#">#collection#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<label for="other_id_type">ID Type</label>
				<select name="other_id_type" id="other_id_type" size="1" style="width:120px;">
					<option value="catalog_number">Catalog Number</option>
					<cfloop query="ctOtherIdType">
						<option value="#other_id_type#">#other_id_type#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<label for="oidnum">ID Number</label>
				<input type="text" name="oidnum" class="reqdClr" id="oidnum">
			</td>
			<td>
				<label for="part_name">Part Name</label>
				<select name="part_name" id="part_name" size="1" style="width:120px;">
					<cfloop query="ctPartName">
						<option value="#part_name#">#part_name#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<label for="part_name_2">Part Name 2</label>
				<select name="part_name_2" id="part_name_2" size="1" style="width:120px;">
					<option value=""></option>
					<cfloop query="ctPartName">
						<option value="#part_name#">#part_name#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<label for="parent_barcode">Parent Barcode</label>
				<input type="text" name="parent_barcode" id="parent_barcode">
			</td>
			<td>
				<label for="new_container_type">Parent Cont Type</label>
				<select name = "new_container_type" id="new_container_type" size="1" class="reqdClr">
					<cfloop query="ctContType">
						<option value="#container_type#">#container_type#</option>
					</cfloop>
				</select>
		
			</td>
	  		<td>
				<input type="button" value="Move it" class="savBtn" onclick="addPartToContainer()">
			</td>
		</tr>
	</form>
	</table>
	<div id="msgs"></div>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm"/>