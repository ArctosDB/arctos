<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Cat Item Pick">
<cfquery name="ctcollection" datasource="#Application.web_user#">
	select distinct(collection) from collection order by collection
</cfquery>
<cfquery name="ctOtherIdType" datasource="#Application.web_user#">
    select distinct(other_id_type) FROM ctColl_Other_Id_Type ORDER BY other_Id_Type
</cfquery>
<cfoutput>
	<form name="findCatItem" method="post" action="CatalogedItemPick.cfm">
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
						collection_cde,
						cataloged_item.collection_object_id,
						scientific_name
					 FROM 
						cataloged_item,
						identification">
	
	<cfif #oidType# is "catalog_number">
		<!--- nothing ---->
	<cfelse>
		<cfset sql = "#sql#
			,coll_obj_other_id_num">
	</cfif>
	<cfset sql = "#sql#  WHERE 
					  cataloged_item.collection_object_id = identification.collection_object_id AND
					  identification.accepted_id_fg = 1">
	<cfif #oidType# is "catalog_number">
		<!--- nothing ---->
		<cfset sql = "#sql#
			AND cat_num IN ( #replace(oidNumList,"'","","all")# )">
	<cfelse>
		
		<cfset sql = "#sql#
			AND cataloged_item.collection_object_id = coll_obj_other_id_num.collection_object_id
			AND other_id_type = '#oidType#'
			AND other_id_num IN ( #oidNumList# )">
	</cfif>
	
		<cfset sql = "#sql#
			AND collection_id='#collID#'">
	
					
	
	<cfquery name="getItems" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfoutput>
		<cfif #getItems.recordcount# is 0>
			Nothing matched
		<cfelseif #getItems.recordcount# is 1>
			<script>
				opener.document.#formName#.#collIdFld#.value='#getItems.collection_object_id#';
				opener.document.#formName#.#CatNumStrFld#.value='#getItems.collection_cde# #getItems.cat_num# (#getItems.scientific_name#)'
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
				opener.document.#formName#.#CatNumStrFld#.value='#collection_cde# #cat_num# (#scientific_name#)';self.close();">#collection_cde# #cat_num# #scientific_name#</a>
			</cfloop>
			
			
		</cfif>
</cfoutput>

<cfinclude template="../includes/_pickFooter.cfm">