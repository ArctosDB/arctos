<cfinclude template="/includes/_header.cfm">
<script language="javascript" type="text/javascript">
	function checkSubmit() {
		var c=document.getElementById('submitOnChange').checked;
		if (c==true) {
			addPartToContainer();
		}
	}
	function addPartToContainer () {
		document.getElementById('pTable').className='red';
		var collection_id=document.getElementById('collection_id').value;
		var other_id_type=document.getElementById('other_id_type').value;
		var oidnum=document.getElementById('oidnum').value;
		var part_name=document.getElementById('part_name').value;
		var part_name_2=document.getElementById('part_name_2').value;
		var parent_barcode=document.getElementById('parent_barcode').value;
		var new_container_type=document.getElementById('new_container_type').value;
		//alert('here we gonow....');
		DWREngine._execute(_cfscriptLocation, null, 'addPartToContainer',collection_id,other_id_type,oidnum,part_name,part_name_2,parent_barcode,new_container_type,success_addPartToContainer);
		
		//
	}
	function success_addPartToContainer(result) {
		//alert(result);
		statAry=result.split("|");
		var status=statAry[0];
		var msg=statAry[1];
		document.getElementById('pTable').className='';
		var mDiv=document.getElementById('msgs');
		var mhDiv=document.getElementById('msgs_hist');
		var mh=mDiv.innerHTML + '<hr>' + mhDiv.innerHTML;
		mhDiv.innerHTML=mh;
		mDiv.innerHTML=msg;
		if (status==0){
			mDiv.className='error';
		} else {
			mDiv.className='successDiv';
			document.getElementById('oidnum').focus();
		}
		//alert(status);
		//alert(msg);
	}
</script>
<style>
		.messageDiv {
			background-color:lightgray;
			text-align:center;
			font-size:.8em;
			margin:0em .5em 0em .5em;}
		.successDiv {
			color:green;
			border:1px solid;
			padding:.5em;
			margin:.5em;
			text-align:center;
			}	
			
</style>
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
	<p style="font-size:.8em;">
		Submit form with Parent Barcode change? <input type="checkbox" name="submitOnChange" id="submitOnChange">
	</p>
	<table border id="pTable">
	<form name="scans" method="post" id="scans">
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
				<label for="new_container_type">Parent Cont Type</label>
				<select name = "new_container_type" id="new_container_type" size="1" class="reqdClr">
					<cfloop query="ctContType">
						<option value="#container_type#">#container_type#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<label for="parent_barcode">Parent Barcode</label>
				<input type="text" name="parent_barcode" id="parent_barcode" onchange="checkSubmit()">
			</td>
	  		<td>
				<input type="button" value="Move it" class="savBtn" onclick="addPartToContainer()">
			</td>
		</tr>
	</table>
	</form>
	<div id="msgs"></div>
	<div id="msgs_hist" class="messageDiv"></div>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm"/>