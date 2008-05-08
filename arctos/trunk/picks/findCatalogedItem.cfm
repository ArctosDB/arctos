<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Cat Item Pick">
<cfquery name="ctcollection" datasource="#Application.web_user#">
	select distinct(collection) from collection order by collection
</cfquery>
<cfquery name="ctOtherIdType" datasource="#Application.web_user#">
    select distinct(other_id_type) FROM ctColl_Other_Id_Type ORDER BY other_Id_Type
</cfquery>
<cfoutput>
	<form name="findCatItem" method="post" action="">
        <input type="hidden" name="collIdFld" value="#collIdFld#">
        <input type="hidden" name="CatNumStrFld" value="#CatNumStrFld#">
        <input type="hidden" name="formName" value="#formName#">
		<label for="collID">Collection</label>
        <select name="collID" id="collID" size="1">
		    <option value="">Any</option>
			<cfloop query="ctcollection">
				<option <cfif #collID# is #collection#> selected="selected" </cfif>value="#collection#">#collection#</option>
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
        <br>
		<input type="submit" value="Search" class="schBtn">
	</form>
 
 <Cfset oidNumList = "">
 <cfloop list="#oidNum#" index="v" delimiters=",">
	<cfif len(#oidNumList#) is 0>
		<cfset oidNumList = "'#v#'">
	<cfelse>
		<cfset oidNumList = "#oidNumList#,'#v#'">
	</cfif>	
</cfloop>
	<cfset sql = "SELECT
						cat_num, 
						collection,
						cataloged_item.collection_object_id,
						scientific_name
					 FROM 
						cataloged_item,
						identification,
                        collection">
	
	<cfif #oidType# is not "catalog_number">
		<cfset sql = "#sql#	,coll_obj_other_id_num">
	</cfif>
	<cfset sql = "#sql#  WHERE 
					  cataloged_item.collection_object_id = identification.collection_object_id AND
                      cataloged_item.collection_id=collection.collection_id and
					  identification.accepted_id_fg = 1">
	<cfif #oidType# is "catalog_number">
		<cfset sql = "#sql#	AND cat_num IN ( #replace(oidNumList,"'","","all")# )">
	<cfelse>
		<cfset sql = "#sql#
			AND cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id
			AND other_id_type = '#oidType#'
			AND other_id_num IN ( #oidNumList# )">
	</cfif>
	<cfif len(#collID#) gt 0>
        <cfset sql = "#sql# AND collection='#collID#'">
    </cfif>
					
	
	<cfquery name="getItems" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>
    <hr>
    #preservesinglequotes(sql)#
	<hr>	
        <cfif #getItems.recordcount# is 0>
			-foundNothing-
		<cfelseif #getItems.recordcount# is 1>
			<script>
				opener.document.#formName#.#collIdFld#.value='#getItems.collection_object_id#';
				opener.document.#formName#.#CatNumStrFld#.value='#getItems.collection# #getItems.cat_num# (#getItems.scientific_name#)'
				;self.close();
			</script>
		<cfelse>
			<cfset thisCollObjId = "">
			<cfloop query="getItems">
				<cfif len(#thisCollObjId#) is 0>
					<cfset thisCollObjId = #collection_object_id#>
				<cfelse>
					<cfset thisCollObjId = "#thisCollObjId#,#collection_object_id#">
				</cfif>
				
			</cfloop>
			<p>
				<br><a href="javascript: opener.document.#formName#.#collIdFld#.value='#thisCollObjId#';
				opener.document.#formName#.#CatNumStrFld#.value='MULTIPLE';self.close();">Select All</a>
			
			</p>
			<cfloop query="getItems">
				<br><a href="javascript: opener.document.#formName#.#collIdFld#.value='#collection_object_id#';
				opener.document.#formName#.#CatNumStrFld#.value='#collection# #cat_num# (#scientific_name#)';self.close();">#collection# #cat_num# #scientific_name#</a>
			</cfloop>
			
			
		</cfif>
</cfoutput>

<cfinclude template="../includes/_pickFooter.cfm">