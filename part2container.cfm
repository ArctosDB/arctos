<cfinclude template="/includes/_header.cfm">
<script type='text/javascript' src='/includes/ajax.js'></script>
<style>
	.messageDiv {
		background-color:lightgray;
		text-align:center;
		font-size:.8em;
		margin:0em .5em 0em .5em;
	}
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
	<cfquery name="ctCollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select guid_prefix, collection_id FROM collection order by guid_prefix
	</cfquery>
	<cfquery name="ctOtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select other_id_type FROM ctcoll_other_id_type order by sort_order,other_id_type
	</cfquery>
	<cfquery name="ctContType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select container_type from ctcontainer_type
		order by container_type
	</cfquery>

	<div style="font-size:.8em;">
		This application puts collection objects into containers.
		Parts are listed in three ways:
		<ul>
			<li><strong>Part Name</strong> = just a part</li>
			<li><strong>Part Name SAMPLE</strong> = a subsample of another part</li>
			<li><strong>Part Name [barcode]</strong> = a part which is in a barcoded container</li>
		</ul>
		Things occasionally get stuck - click Refresh to unstick them.
	</div>
	<p style="font-size:.8em;">
		<span style="border:1px solid blue; padding:5px;margin:5px;">
			Submit form with Parent Barcode change? <input type="checkbox" name="submitOnChange" id="submitOnChange">
		</span>
		<span style="border:1px solid blue; padding:5px;margin:5px;">
			Filter for un-barcoded parts? <input type="checkbox" name="noBarcode" id="noBarcode"  onchange="getParts()">
		</span>
		<span style="border:1px solid blue; padding:5px;margin:5px;">
			Exclude subsamples? <input type="checkbox" name="noSubsample" id="noSubsample"  onchange="getParts()">
		</span>
		<span style="border:1px solid blue; padding:5px;margin:5px;">
			<span class="likeLink"  onclick="getParts()">Refresh Parts List</span>
		</span>
	</p>
	<table border id="pTable">
	<form name="scans" method="post" id="scans">
		<input type="hidden" name="action" value="validate">
		<input type="hidden" name="collection_object_id" id="collection_object_id">
		<tr>
			<td>
				<label for="collection_id">Collection</label>
				<select name="collection_id" id="collection_id" size="1" onchange="getParts()">
					<cfloop query="ctCollection">
						<option value="#collection_id#">#guid_prefix#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<label for="other_id_type">ID Type</label>
				<select name="other_id_type" id="other_id_type" size="1" style="width:120px;" onchange="getParts()">
					<option value="catalog_number">Catalog Number</option>
					<cfloop query="ctOtherIdType">
						<option value="#other_id_type#">#other_id_type#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<label for="oidnum">ID Number</label>
				<input type="text" name="oidnum" class="reqdClr" id="oidnum" onchange="getParts()">
			</td>
			<td>
				<label for="part_name">Part Name</label>
				<select name="part_name" id="part_name" size="1" style="width:160px;">
				</select>
			</td>
			<td>
				<label for="part_name_2">Part Name 2</label>
				<select name="part_name_2" id="part_name_2" size="1" style="width:160px;">
					<option value=""></option>
				</select>
			</td>
			<td>
				<label for="new_container_type">Parent Cont Type</label>
				<select name = "new_container_type" id="new_container_type" size="1" class="reqdClr">
					<option value=""></option>
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
			<td>
				<input type="button" value="New Part" class="insBtn" onclick="clonePart()">
			</td>
		</tr>
	</table>
	</form>
	<div id="thisSpecimen" style="border:1px solid green;font-size:smaller;"></div>
	<div id="msgs"></div>
	<div id="msgs_hist" class="messageDiv"></div>
	<script>
		document.getElementById('oidnum').focus();
		document.getElementById('oidnum').select();
	</script>
</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm"/>