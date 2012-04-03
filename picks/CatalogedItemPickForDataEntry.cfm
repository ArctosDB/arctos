<cfinclude template="/includes/_pickHeader.cfm">
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection,collection_id from collection order by collection
</cfquery>
<cfquery name="ctOtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
    select distinct(other_id_type) FROM ctColl_Other_Id_Type ORDER BY other_Id_Type
</cfquery>
<cfparam name="other_id_num">
<cfparam name="other_id_type">

<!----------------------------------------------------------->
	Search for Cataloged Items:
	<cfoutput>
	<form name="findCatItem" method="post" action="CatalogedItemPickForDataEntry.cfm">
		<label for="collection_id">Collection</label>
        <select name="collection_id" id="collection_id" size="1">
		    <option value="">Any</option>
			<cfloop query="ctcollection">
				<option value="#ctcollection.collection_id#">#ctcollection.collection#</option>
			</cfloop>
		</select>
		<label for="other_id_type">Other ID Type</label>
        <select name="other_id_type" id="other_id_type" size="1">
			<option value=""></option>
			<option <cfif other_id_type is "guid"> selected="selected" </cfif>value="guid">GUID</option>
			<cfloop query="ctOtherIdType">
				<option  <cfif url.other_id_type is ctOtherIdType.other_id_type> selected="selected" </cfif>value="#ctOtherIdType.other_id_type#">#ctOtherIdType.other_id_type#</option>
			</cfloop>
		</select>
		<label for="other_id_num">Other ID Num</label>
        <input type="text" name="other_id_num" id="other_id_num" value="#other_id_num#">
        <br>
		<input type="submit" value="Search" class="schBtn">
	</form>
	</cfoutput>
<!------------------------------------------------------------->
    <cfset sql = "SELECT
				    cat_num, 
					collection,
					cataloged_item.collection_object_id,
					scientific_name
				FROM 
					flat,coll_obj_other_id_num
				WHERE 
					cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id (+)">
	
	<cfif len(other_id_num) is 0>
		other_id_num - abort<cfabort>
	</cfif>
	<cfif len(other_id_type) gt 0>
		<cfif other_id_type is "catalog number">
			<cfset sql=sql & " and flat.cat_num='#other_id_num#'">
		<cfelseif other_id_type is "guid">
			<cfset sql=sql & " and upper(flat.guid='#ucase(other_id_num)#'">
		<cfelse>
			<cfset sql=sql & " and upper(coll_obj_other_id_num.display_value like '%#ucase(other_id_num)#%'">
		</cfif>
	</cfif>	
	<cfif len(#collection#) gt 0>
		<cfset sql = "#sql# AND collection_id=#collection_id#">
	</cfif>	
	<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfoutput>
		<cfif #sciNameFld# is #catNumFld#>
            <cfset cat_num_val="">
            scientific_name_val
        <cfelse>
        
        </cfif>
        <cfloop query="getItems">
			<br>#cat_nuM#
		</cfloop>
    </cfoutput>

<cfinclude template="../includes/_pickFooter.cfm">