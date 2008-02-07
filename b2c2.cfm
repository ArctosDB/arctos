<body bgcolor="#FFFBF0" text="midnightblue" link="blue" vlink="midnightblue">
<!--- no security --->

<cfif not (
	isdefined("label") 
	OR isdefined("description")
	OR isdefined("barcode")
	OR isdefined("container_remarks")
	OR isdefined("container_type"))>
	Perform a search to open a container location tree in this window.
	<cfabort>
	</cfif>

<cfoutput>
<cfset sel = "
SELECT 
	 container.container_id,
	 container.parent_container_id,
	 container_type,
	 label">
<cfset frm = "
	 FROM
	 container,fluid_container_history">
<cfset whr = "
	WHERE container.container_id = fluid_container_history.container_id (+)">
	
 <cfif len(#label#) gt 0>
 	<cfset whr = "#whr# AND container.label='#label#'">
 </cfif>
 <cfif len(#description#) gt 0>
 	<cfset whr = "#whr# AND description='#description#'">
 </cfif>
 <cfif len(#barcode#) gt 0>
 	<cfset whr = "#whr# AND barcode='#barcode#'">
 </cfif>
 <cfif len(#container_remarks#) gt 0>
 <cfset whr = "#whr# AND container_remarks like '%#ucase(container_remarks)#%'">
 </cfif>
 <cfif len(#container_type#) gt 0>
 <cfset whr = "#whr# AND container_type = '#container_type#'">
 </cfif>
 
 <cfset sql = "#sel# #frm# #whr# ORDER BY container.container_id">
 <cfquery name="allRecords" datasource="#Application.web_user#">
 	#preservesinglequotes(sql)#
 </cfquery>
</cfoutput>
<cfif #allRecords.recordcount# is 0>
	Your search returned no records.
	<cfabort>
</cfif>
Select a container from the tree.
 <cfform name="TissTree" enablecab="yes">
	<cftree name="tt" height="300" width="400" border="yes" hscroll="yes" vscroll="yes" highlighthref="yes">
	<cftreeitem value="0" expand="yes" display="Location">
	<!--- set up a list to keep track of the container_ids that we've put in the tree --->
	<cfset placedContainers = "">
 <cfloop query="allRecords">
 	<cfquery name="thisRecord" datasource="#Application.web_user#">
	select 
	CONTAINER_ID,
	PARENT_CONTAINER_ID,
	CONTAINER_TYPE,
	DESCRIPTION,
	PARENT_INSTALL_DATE,
	CONTAINER_REMARKS,
	label
	 from container
	start with container_id=#container_id#
	connect by prior parent_container_id = container_id 
	</cfquery>
		<cfoutput>
		
			<cfloop query="thisRecord">
				<cfif not listfind(placedContainers,#thisRecord.container_id#)>
					<cfif #thisRecord.container_type# is "collection object">
						<cftreeitem 
							value="#thisRecord.container_id#" 
							display="#thisRecord.label#"
							parent="#thisRecord.parent_container_id#" 
							expand="yes" 
							>
					
					<cfelse>
					<cftreeitem value="#thisRecord.container_id#" display="#thisRecord.label#" parent="#thisRecord.parent_container_id#"  expand="yes" href="b2c3.cfm?container_id=#thisRecord.container_id#" target="_detail">
					</cfif>
				
				<cfset placedContainers = listappend(placedContainers,#thisRecord.container_id#)> 
				</cfif>
				
			</cfloop>
		</cfoutput>
 </cfloop>

 </cftree>

 </cfform>
