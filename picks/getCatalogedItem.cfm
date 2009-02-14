<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Cat Item Pick">
 
 
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
			AND collection_cde='#collCde#'">
	
					
	
	<cfquery name="getItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfoutput>
		<cfif #getItems.recordcount# is 0>
			Nothing matched
		<cfelseif #getItems.recordcount# is 1>
			<script>
				opener.document.#formName#.#collIdFld#.value='#getItems.collection_object_id#';
				opener.document.#formName#.#CatCollFld#.value='#getItems.collection_cde# #getItems.cat_num# (#getItems.scientific_name#)'
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
				opener.document.#formName#.#CatCollFld#.value='MULTIPLE';self.close();">Select All</a>
			
			</p>
			<cfloop query="getItems">
				<br><a href="javascript: opener.document.#formName#.#collIdFld#.value='#collection_object_id#';
				opener.document.#formName#.#CatCollFld#.value='#collection_cde# #cat_num# (#scientific_name#)';self.close();">#collection_cde# #cat_num# #scientific_name#</a>
			</cfloop>
			
			
		</cfif>
</cfoutput>

<cfinclude template="../includes/_pickFooter.cfm">