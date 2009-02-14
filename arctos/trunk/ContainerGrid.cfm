<!---- this is an internal use page and needs a security wrapper --->
 <!--- no security --->
 <cfif not isdefined("srch")>
 	<cfset srch="part">
 </cfif>
<!---------------- start search by container ---------------->
<cfif #action# is "nothing">
<cfset sel = "
SELECT 
	 container.container_id,
	 container.parent_container_id,
	 container_type,
	 label,
	 description,
	 parent_install_date,
	 container_remarks,
	 barcode">
<cfset frm = "
	 FROM
	 container">
<cfset whr = "
	WHERE 
		">
	
 

	 <cfif #srch# is "Part">
	 <cfset frm = "#frm#,coll_obj_cont_hist,specimen_part,cataloged_item">
	 <cfset whr = "#whr# container.container_id = coll_obj_cont_hist.container_id 
	 				AND coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id
					AND specimen_part.derived_from_cat_item = cataloged_item.collection_object_id">
	 </cfif>
	 <cfif #srch# is "Container">
		 <cfset frm = "#frm#,fluid_container_history">	
		<cfset whr = "#whr# container.container_id = fluid_container_history.container_id (+)">
	 	<!--- don't need to add anything --->
	 </cfif>

	
	 
<cfif isdefined("af_num")>
	<cfset aflist = "">
	<cfloop list="#af_num#" index="i">
					<cfif len(#aflist#) is 0>
						<cfset aflist = "'#i#'">
					<cfelse>
						<cfset aflist = "#aflist#,'#i#'">
					</cfif>
				</cfloop>
	<cfset frm = "#frm#,af_num">
	<cfset whr = "#whr# AND cataloged_item.collection_object_id = af_num.collection_object_id
		and af_num.af_num IN (#aflist#)">
</cfif>
 <cfif isdefined("cat_num")>
 	<cfset whr = "#whr# AND cataloged_item.cat_num IN (#cat_num#)">
 </cfif>
 <cfif isdefined("collection_cde")>
 	<cfset whr = "#whr# AND cataloged_item.collection_cde='#collection_cde#'">
 </cfif>

 
 <cfif isdefined("Tissue_Type")>
 	<cfset whr = "#whr# AND Tissue_Type='#Tissue_Type#'">
 </cfif>
 <cfif isdefined("Part_Name")>
 	<cfset whr = "#whr# AND part_Name='#part_Name#'">
 </cfif>
 <cfif isdefined("Scientific_Name")>
 	<cfset frm = "#frm#,identification,taxonomy">
 	<cfset whr = "#whr# AND cataloged_item.collection_object_id = identification.collection_object_id
					AND identification.accepted_id_fg = 1 
					AND identification.taxon_name_id = taxonomy.taxon_name_id
					AND upper(Scientific_Name) like '%#ucase(Scientific_Name)#%'">
 </cfif>
 <cfif isdefined("container_label")>
 	<cfif isdefined("wildLbl") and #wildLbl# is 1>
			<cfset whr = "#whr# AND upper(label) LIKE '%#ucase(container_label)#%'">
		<cfelse>
			<cfset whr = "#whr# AND label = '#container_label#'">
	</cfif>
 
 </cfif>
 <cfif isdefined("description")>
 	<cfif isdefined("wildLbl") and #wildLbl# is 1>
			<cfset whr = "#whr# AND upper(description) LIKE '%#ucase(description)#%'">
		<cfelse>
			<cfset whr = "#whr# AND description='#description#'">
	</cfif>
	
	
 </cfif>
 <cfif isdefined("collection_object_id")>
 	<cfset whr = "#whr# AND cataloged_item.collection_object_id=#collection_object_id#">
 </cfif>
 <cfif isdefined("barcode")>
 <cfset bclist = "">
	<cfloop list="#barcode#" index="i">
					<cfif len(#bclist#) is 0>
						<cfset bclist = "'#i#'">
					<cfelse>
						<cfset bclist = "#bclist#,'#i#'">
					</cfif>
				</cfloop>
 	<cfset whr = "#whr# AND barcode IN (#bclist#)">
 </cfif>
 <cfif isdefined("container_type")>
 	<cfset whr = "#whr# AND container_type='#container_type#'">
 </cfif>
 <cfif isdefined("container_remarks")>
 <cfset whr = "#whr# AND container_remarks like '%#ucase(container_remarks)#%'">
 </cfif>
 
 <cfset sql = "#sel# #frm# #whr# ORDER BY container.container_id">

<cfoutput>
	#preservesinglequotes(sql)#
</cfoutput>


 <cfquery name="allRecords" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 	#preservesinglequotes(sql)#
 </cfquery>
</cfif>
<!---------------- end search by container ---------------->
<!---------------- search by container_id (ie, for all the containers in a container
	from a previous search ---------------------------------->
<cfif #action# is "contentsSearch">
<cfset sql = "SELECT container_id 
	FROM
	container
	WHERE
	parent_container_id=#container_id#">
<cfquery name="allRecords" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 	#preservesinglequotes(sql)#
 </cfquery>
</cfif>
<!-------------------------- end contents search ----------------------->

<cfif #allRecords.recordcount# is 0>
	Your search returned no records. Use your browser's back button to try again.
	<cfabort>
</cfif>
<table border>
<cfoutput>
 <cfloop query="allRecords">
		<tr>
			<td>
				<a href="/location_tree.cfm?action=contentsSearch&container_id=#container_id#" target="_detail">Contents</a>
				<a href="/location_tree.cfm?srch=Container&container_id=#container_id#" target="_detail">Location</a>
				</td>
			<td>#parent_container_id#</td>
			<td>#container_type#</td>
			<td>#label#</td>
			<td>#description#</td>
			<td>#parent_install_date#</td>
			<td>#container_remarks#</td>
			<td>#barcode#</td>
		</tr>
	 </cfloop>
 </cfoutput>
</table>
	