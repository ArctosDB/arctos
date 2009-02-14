<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Cat Item Pick">
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select distinct(collection) from collection order by collection
</cfquery>
<cfquery name="ctOtherIdType" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
    select distinct(other_id_type) FROM ctColl_Other_Id_Type ORDER BY other_Id_Type
</cfquery>
<!----------------------------------------------------------->
	Search for Cataloged Items:
	<cfoutput>
	<form name="findCatItem" method="post" action="CatalogedItemPick.cfm">
        <input type="hidden" name="Action" value="findItems">
        <input type="hidden" name="collIdFld" value="#collIdFld#">
        <input type="hidden" name="catNumFld" value="#catNumFld#">
        <input type="hidden" name="formName" value="#formName#">
        <input type="hidden" name="sciNameFld" value="#sciNameFld#">	  
		<label for="cat_num">Catalog Number</label>
        <input type="text" name="cat_num" id="cat_num">
		<label for="collection">Collection</label>
        <select name="collection" id="collection" size="1">
		    <option value="">Any</option>
			<cfloop query="ctcollection">
				<option value="#ctcollection.collection#">#ctcollection.collection#</option>
			</cfloop>
		</select>
		<label for="other_id_type">Other ID Type</label>
        <select name="other_id_type" id="other_id_type" size="1">
			<option value=""></option>
			<cfloop query="ctOtherIdType">
				<option value="#ctOtherIdType.other_id_type#">#ctOtherIdType.other_id_type#</option>
			</cfloop>
		</select>
		<label for="other_id_num">Other ID Num</label>
        <input type="text" name="other_id_num" id="other_id_num">
        <br>
		<input type="submit" value="Search" class="schBtn">
	</form>
	</cfoutput>
<!------------------------------------------------------------->
<cfif #Action# is "findItems">
    <cfset sql = "SELECT
				    cat_num, 
					collection,
					cataloged_item.collection_object_id,
					scientific_name
				FROM 
					cataloged_item,
					identification,
                    collection">
	<cfif len(#other_id_type#) gt 0 OR len(#other_id_num#) gt 0>
		<cfset sql = "#sql#,coll_obj_other_id_num">
	</cfif>
	<cfset sql = "#sql#  WHERE 
					  cataloged_item.collection_object_id = identification.collection_object_id AND
                      cataloged_item.collection_id=collection.collection_id and
					  identification.accepted_id_fg = 1">
	<cfif len(#other_id_type#) gt 0 OR len(#other_id_num#) gt 0>
		<cfset sql = "#sql#
			AND cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id">
	</cfif>
	<cfif len(#other_id_type#) gt 0>
		<cfset sql = "#sql#
			AND other_id_type = '#other_id_type#'">
	</cfif>
	<cfif len(#other_id_num#) gt 0>
		<cfset sql = "#sql#
			AND upper(other_id_num) = '%#ucase(other_id_num)#%'">
	</cfif>
	<cfif len(#cat_num#) gt 0>
		<cfset sql = "#sql#
			AND cat_num=#cat_num#">
	</cfif>
	<cfif len(#collection#) gt 0>
		<cfset sql = "#sql# AND collection='#collection#'">
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
			<br><a href="javascript: opener.document.#formName#.#collIdFld#.value='#collection_object_id#';opener.document.#formName#.#catNumFld#.value='#cat_num_val#';opener.document.#formName#.#sciNameFld#.value='#scientific_name_val#';self.close();">#collection# #cat_num# #scientific_name#</a>
		</cfloop>
    </cfoutput>

</cfif>
<cfinclude template="../includes/_pickFooter.cfm">