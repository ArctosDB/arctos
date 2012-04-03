<cfinclude template="/includes/_pickHeader.cfm">
<script>
	function updateMySettings(el,v){
		jQuery.getJSON("/component/Bulkloader.cfc",
			{
				method : "updateMySettings",
				element : el,
				value : v,
				returnformat : "json"
			},
			function (r) {
				console.log(r);
			}
		);
	}
	function copyToDataEntry(id){
		jQuery.getJSON("/component/Bulkloader.cfc",
			{
				method : "getExistingCatItemData",
				collection_object_id : id,
				returnformat : "json"
			},
			function (r) {
				console.log(r);
				var eventID=r.DATA.COLLECTING_EVENT_ID;
				console.log(eventID);
				
			}
		);
	}

</script>
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection,collection_id cid from collection order by collection
</cfquery>
<cfquery name="ctOtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
    select distinct(other_id_type) oidt FROM ctColl_Other_Id_Type ORDER BY other_Id_Type
</cfquery>
<cfparam name="other_id_num" default=''>
<cfparam name="other_id_type" default=''>
<cfparam name="collection_id" default=''>
<!----------------------------------------------------------->
	Search for Cataloged Items:
	<cfoutput>
	<form name="findCatItem" method="post" action="CatalogedItemPickForDataEntry.cfm">
		<label for="collection_id">Collection</label>
        <select name="collection_id" id="collection_id" size="1">
		    <option value="">Any</option>
			<cfloop query="ctcollection">
				<option <cfif collection_id is ctcollection.cid> selected="selected" </cfif>value="#ctcollection.cid#">#ctcollection.collection#</option>
			</cfloop>
		</select>
		<label for="other_id_type">Other ID Type</label>
        <select name="other_id_type" id="other_id_type" size="1">
			<option value=""></option>
			<option <cfif other_id_type is "guid"> selected="selected" </cfif>value="guid">GUID</option>
			<cfloop query="ctOtherIdType">
				<option  <cfif other_id_type is ctOtherIdType.oidt> selected="selected" </cfif>value="#ctOtherIdType.oidt#">#ctOtherIdType.oidt#</option>
			</cfloop>
		</select>
		<label for="other_id_num">Other ID Num</label>
        <input type="text" name="other_id_num" id="other_id_num" value="#other_id_num#">
        <br>
		<input type="submit" value="Search" class="schBtn">
	</form>
<!------------------------------------------------------------->
    <cfset sql = "SELECT
				    flat.collection_object_id,
				    guid, 
					scientific_name,
					collectors,
					collecting_event_id
				FROM 
					flat,coll_obj_other_id_num
				WHERE 
					flat.collection_object_id = coll_obj_other_id_num.collection_object_id (+)">
	
	<cfif len(other_id_num) is 0>
		other_id_num - abort<cfabort>
	</cfif>
	<cfif len(other_id_type) gt 0>
		<cfif other_id_type is "catalog number">
			<cfset sql=sql & " and flat.cat_num='#other_id_num#'">
		<cfelseif other_id_type is "guid">
			<cfset sql=sql & " and upper(flat.guid)='#ucase(other_id_num)#'">
		<cfelse>
			<cfset sql=sql & " and upper(coll_obj_other_id_num.display_value) like '%#ucase(other_id_num)#%'">
		</cfif>
	</cfif>	
	<cfif len(collection_id) gt 0>
		<cfset sql = "#sql# AND collection_id=#collection_id#">
	</cfif>
	
	<cfset sql = "#sql# group by
	 flat.collection_object_id,
				    guid, 
					scientific_name,
					collectors,
					collecting_event_id">
	<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfquery name="mySettings" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select pickuse_eventid,pickuse_collectors from cf_dataentry_settings where username='#session.username#'
	</cfquery>
	<table border>
		<tr>
			<th>Item (click to use)</th>
			<th>
				Collectors
				<input type="checkbox" name="pickuse_collectors" id="pickuse_collectors" value="#mySettings.pickuse_collectors#"
					<cfif mySettings.pickuse_collectors is 1>checked="checked"</cfif>
					onchange="updateMySettings('pickuse_collectors',this.checked)">
					
						
			</th>
			<th>EventID
				<input type="checkbox" name="pickuse_eventid" id="pickuse_eventid" value="#mySettings.pickuse_eventid#"
					<cfif mySettings.pickuse_eventid is 1>checked="checked"</cfif>
					onchange="updateMySettings('pickuse_eventid',this.checked)">
			</th>
		</tr>
		 <cfloop query="getItems">
			<tr>
				<td>
					<span class="likeLink" onclick="copyToDataEntry('#collection_object_id#');")>
						#guid#: #scientific_name#
					</span>
				</td>
				<td>#collectors#</td>
				<td>#collecting_event_id#</td>
			</tr>
		</cfloop>
	</table>
       
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">