<!---- this is an internal use page and needs a security wrapper --->
 <cfinclude template="includes/_frameHeader.cfm">
 <!--- no security --->
 
 <cfset title = "Container Locations">
 
<body bgcolor="#FFFBF0" text="midnightblue" link="blue" vlink="midnightblue">
<!---------------- start search by container ---------------->
<cfif #action# is "nothing">
<cfif not isdefined ("srch")>
	waiting...
	<cfabort>
</cfif>
<cfset sel = "
SELECT 
	 container.container_id,
	 container.parent_container_id,
	 container_type,
	 label">
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
 	<cfset frm = "#frm#,identification">
 	<cfset whr = "#whr# AND cataloged_item.collection_object_id = identification.collection_object_id
					AND identification.accepted_id_fg = 1 
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
 	<cfset whr = "#whr# AND cataloged_item.collection_object_id IN (#collection_object_id#)">
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
  <cfif isdefined("container_id")>
 	<cfset whr = "#whr# AND container.container_id=#container_id#">
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

 <cfform name="TissTree" enablecab="yes">
	<cftree name="tt" height="600" width="400" border="yes" hscroll="yes" vscroll="yes" highlighthref="yes">
	<cftreeitem value="0" expand="yes" display="Location">
	<!--- set up a list to keep track of the container_ids that we've put in the tree --->
	<cfset placedContainers = "">



 <cfloop query="allRecords">
 
	<cfquery name="thisRecord" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
	CONTAINER_ID,
	PARENT_CONTAINER_ID,
	CONTAINER_TYPE,
	DESCRIPTION,
	PARENT_INSTALL_DATE,
	CONTAINER_REMARKS,
	label
	 from container
	start with container_id=<cfoutput>#allRecords.container_id#</cfoutput>
	connect by prior parent_container_id = container_id 
	</cfquery>
		<cfoutput>
			<cfloop query="thisRecord">
				<cfif not listfind(placedContainers,#thisRecord.container_id#)>
					<cfif #thisRecord.container_type# is "collection object">
					<!--- get the collection_object-id --->
					<!---<cfquery name="collobjid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select 
							a.derived_from_biol_indiv,
							c.derived_from_biol_indv
						from 
							tissue_sample a, 
							coll_obj_cont_hist b,
							specimen_part c
						where 
							a.collection_object_id = b.collection_object_id (+) AND
							a.collection_object_id = c.collection_object_id (+) AND
							container_id=#thisRecord.container_id#
					</cfquery>--->
					<!--- 
						just plaster the derived_from_biol_indiv and derived_from_biol_indv 
						numbers together in the URL because we'll only ever return one of them 
					--->
					
							
						<cftreeitem 
							value="#thisRecord.container_id#--ContDet.cfm?container_id=#thisRecord.container_id#&objType=CollObj" 
							display="#thisRecord.label#"
							parent="#thisRecord.parent_container_id#" 
							expand="yes" 
							href="ContDet.cfm?container_id=#thisRecord.container_id#"
							target="_detail">
					
					<cfelse>
					<cftreeitem value="#thisRecord.container_id#" display="#thisRecord.label#" parent="#thisRecord.parent_container_id#" href="ContDet.cfm?container_id=#thisRecord.container_id#" target="_detail" expand="yes">
					</cfif>
				
				<cfset placedContainers = listappend(placedContainers,#thisRecord.container_id#)> 
				</cfif>
				
			</cfloop>
		</cfoutput>
 </cfloop>

 </cftree>
 </cfform>
 <cfif isdefined("sql") and len(#sql#) gt 0>
	 <form method="post" action="locDownload.cfm" target="_blank">
		<cfoutput>
			<input type="hidden" name="sql" value="#preservesinglequotes(sql)#">
			<input type="submit" value="download summary">
		</cfoutput>
	 </form>
 </cfif>
 <cfinclude template="includes/_footer.cfm">