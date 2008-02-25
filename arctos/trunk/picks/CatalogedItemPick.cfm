<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Cat Item Pick">
<body bgcolor="#FFFBF0" text="midnightblue" link="blue" vlink="midnightblue">
 
<cfif #Action# is "nothing">
	Search for Cataloged Items:
	<cfoutput>
	<form name="findCatItem" method="post" action="CatalogedItemPick.cfm">
		 <input type="hidden" name="Action" value="findItems">
      <input type="hidden" name="collIdFld" value="#collIdFld#">
      <input type="hidden" name="catNumFld" value="#catNumFld#">
      <input type="hidden" name="formName" value="#formName#">
	  <input type="hidden" name="sciNameFld" value="#sciNameFld#">
	  
	  
		
		<br>Cat Num: <input type="text" name="cat_num">
		<cfquery name="ctColl" datasource="#Application.web_user#">
			select distinct(collection_cde) from ctcollection_cde
		</cfquery>
		<br>Collection: <select name="collection_cde" size="1">
			<option value=""></option>
			<cfloop query="ctColl">
				<option value="#ctColl.collection_cde#">#ctColl.collection_cde#</option>
			</cfloop>
		</select>
		<cfquery name="ctOtherIdType" datasource="#Application.web_user#">
			select distinct(other_id_type) FROM ctColl_Other_Id_Type ORDER BY other_Id_Type
		</cfquery>
		<br>Other ID Type: <select name="other_id_type" size="1">
			<option value=""></option>
			<cfloop query="ctOtherIdType">
				<option value="#ctOtherIdType.other_id_type#">#ctOtherIdType.other_id_type#</option>
			</cfloop>
		</select>
		<br>Other ID Num:<input type="text" name="other_id_num">
		<input type="submit" value="Search">
	</form>
	</cfoutput>
</cfif>

<cfif #Action# is "findItems">
	<cfset sql = "SELECT
						cat_num, 
						collection_cde,
						cataloged_item.collection_object_id,
						scientific_name
					 FROM 
						cataloged_item,
						identification">
	<cfif len(#other_id_type#) gt 0 OR len(#other_id_num#) gt 0>
		<cfset sql = "#sql#
			,coll_obj_other_id_num">
	</cfif>
	<cfset sql = "#sql#  WHERE 
					  cataloged_item.collection_object_id = identification.collection_object_id AND
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
			AND other_id_num = '#other_id_num#'">
	</cfif>
	<cfif len(#cat_num#) gt 0>
		<cfset sql = "#sql#
			AND cat_num=#cat_num#">
	</cfif>
	<cfif len(#collection_cde#) gt 0>
		<cfset sql = "#sql#
			AND collection_cde='#collection_cde#'">
	</cfif>
					
	
	<cfquery name="getItems" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfoutput>
		<cfloop query="getItems">
			<br><a href="javascript: opener.document.#formName#.#collIdFld#.value='#collection_object_id#';opener.document.#formName#.#catNumFld#.value='#cat_num#';opener.document.#formName#.#sciNameFld#.value='#scientific_name#';self.close();">#collection_cde# #cat_num# #scientific_name#</a>
	
		</cfloop>
</cfoutput>

</cfif>
<cfinclude template="../includes/_pickFooter.cfm">