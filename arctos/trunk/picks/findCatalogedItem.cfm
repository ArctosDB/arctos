<cfinclude template="../includes/_pickHeader.cfm">
<script language="javascript" type="text/javascript">
	function setFormVals (onoff) {

		$.getJSON("/component/functions.cfc",
				{
					method : "setSessionVar",
					onoff : onoff,
					returnformat : "json",
					queryformat : 'column'
				},
				function(r) {
					if (r == 'success') {
						$('#browseArctos').html('Suggest Browser disabled. You may turn this feature back on under My Stuff.');
					} else {
						alert('An error occured! \n ' + r);
					}
				}
			);
	}
</script>

<cfif not isdefined("agent_name")>
	<cfset agent_name=''>
</cfif>
<cfif oidNum is "undefined">
	<cfset oidNum=''>
</cfif>
<cfset title = "Cat Item Pick">
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select guid_prefix from collection order by guid_prefix
</cfquery>
<cfquery name="ctOtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
    select distinct(other_id_type) FROM ctColl_Other_Id_Type ORDER BY other_Id_Type
</cfquery>
<cfquery name="ctcollector_role" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" cachedwithin="#createtimespan(0,0,60,0)#">
	select collector_role from ctcollector_role order by collector_role
</cfquery>
<cfoutput>
	<form name="findCatItem" method="post" action="findCatalogedItem.cfm">
        <input type="hidden" name="collIdFld" value="#collIdFld#">
        <input type="hidden" name="CatNumStrFld" value="#CatNumStrFld#">
        <input type="hidden" name="formName" value="#formName#">
		<label for="collID">Collection</label>
        <select name="collID" id="collID" size="1">
		    <option value="">Any</option>
			<cfloop query="ctcollection">
				<option <cfif collID is guid_prefix> selected="selected" </cfif>value="#guid_prefix#">#guid_prefix#</option>
			</cfloop>
		</select>
		<label for="oidType">Other ID Type</label>
        <select name="oidType" id="oidType" size="1">
			<option <cfif #oidType# is "catalog_number"> selected </cfif>value="catalog_number">Catalog Number</option>
			<cfloop query="ctOtherIdType">
				<option <cfif #oidType# is #other_id_type#> selected </cfif>value="#other_id_type#">#other_id_type#</option>
			</cfloop>
		</select>
		<label for="oidNum">Other ID Num</label>
        <input type="text" name="oidNum" id="oidNum" value="#oidNum#">
		<table>
			<tr>
				<td>
					<label for="collector_role">CollectorRole</label>
					<select name="collector_role" id="collector_role">
						<cfloop query="ctcollector_role">
							<option value="#ctcollector_role.collector_role#">#ctcollector_role.collector_role#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<label for="agent_name">Agent</label>
					<input type="text" id="agent_name" name="agent_name">
				</td>
			</tr>
		</table>
        <br>
		<!---
		<br><span onclick="setFormVals(1)">[remember current form values]</span>
		<span onclick="setFormVals(0)">[forget default values]</span>
		--->
		<input type="submit" value="Search" class="schBtn">
	</form>
	<cfif len(oidNum) is 0 and len(agent_name) is 0>
		<cfabort>
	</cfif>
	<cfset sql = "SELECT
			cat_num,
			guid_prefix,
			cataloged_item.collection_object_id,
			scientific_name
		 FROM
			cataloged_item,
			identification,
	        collection">
	<cfif isdefined("agent_name") and len(agent_name) gt 0>
		<cfset sql=sql & ",collector,agent_name">
	</cfif>
	<cfif oidType is not "catalog_number">
		<cfset sql = "#sql#	,coll_obj_other_id_num">
	</cfif>
	<cfset sql = "#sql#  WHERE
		cataloged_item.collection_object_id = identification.collection_object_id AND
		cataloged_item.collection_id=collection.collection_id and
		identification.accepted_id_fg = 1">
	<cfif isdefined("agent_name") and len(agent_name) gt 0>
		<cfset sql=sql & " and cataloged_item.collection_object_id=collector.collection_object_id and
			collector.agent_id=agent_name.agent_id and
			upper(agent_name) like '%#ucase(escapequotes(agent_name))#%'">
	</cfif>
	<cfset oidNumList=ListQualify(oidNum, "'")>
	<cfif oidType is "catalog_number" and len(oidNum) gt 0>
		<cfset sql = "#sql#	AND cat_num IN ( #oidNumList# )">
	<cfelseif len(oidNum) gt 0>
		<cfset sql = "#sql#
			AND cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id
			AND other_id_type = '#oidType#'
			AND display_value IN ( #oidNumList# )">
	</cfif>
	<cfif len(collID) gt 0>
        <cfset sql = "#sql# AND guid_prefix='#collID#'">
    </cfif>
	<cfset sql=sql & " group by cat_num,
		guid_prefix,
		cataloged_item.collection_object_id,
		scientific_name
		order by guid_prefix,cat_num">
	<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		#preservesinglequotes(sql)#
	</cfquery>
     <cfif getItems.recordcount is 0>
		-foundNothing-
	<cfelseif getItems.recordcount is 1>
		<cfset dnamestr=replace(getItems.scientific_name,"'","`","all")>
		<script>
			opener.document.#formName#.#collIdFld#.value='#getItems.collection_object_id#';
			opener.document.#formName#.#CatNumStrFld#.value='#getItems.guid_prefix# #getItems.cat_num# (#dnamestr#)';
			self.close();
		</script>
	<cfelse>
		<p>
			<br><a href="javascript: opener.document.#formName#.#collIdFld#.value='#valuelist(getItems.collection_object_id)#';
			opener.document.#formName#.#CatNumStrFld#.value='MULTIPLE';self.close();">Select All</a>
		</p>
		<cfloop query="getItems">
			<cfset dnamestr=replace(getItems.scientific_name,"'","`","all")>
			<br><a href="javascript: opener.document.#formName#.#collIdFld#.value='#collection_object_id#';
			opener.document.#formName#.#CatNumStrFld#.value='#guid_prefix# #cat_num# (#dnamestr#)';self.close();">#guid_prefix# #cat_num# #scientific_name#</a>
		</cfloop>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_pickFooter.cfm">