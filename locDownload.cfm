


 <cfquery name="allRecords" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 	select * from container where container_id in (#container_id#)
 </cfquery>

<!---------------- end search by container ---------------->


<cfif #allRecords.recordcount# is 0>
	Your search returned no records. Use your browser's back button to try again.
	<cfabort>
</cfif>
<cfoutput>
<!----
<table border>
	<tr>
		<td>Container Type</td>
		<td>Label</td>
		<td>Description</td>
		<td>Barcode</td>
		<td>Install Date</td>
		<td>1st level location</td>
		<td>2nd level location</td>
		<td>3rd level location</td>
		<td>4th level location</td>
	</tr>
	---->
<cfset dlPath = "#application.webDirectory#/temp/">
<cfset dlFile = "containerDownload.txt">
<cfset dlHeader="
ContainerType#chr(9)#Label#chr(9)#Description#chr(9)#Barcode#chr(9)#InstallDate#chr(9)#1_parent#chr(9)#2_parent#chr(9)#3_parent#chr(9)#4_parent#chr(9)#5_parent#chr(9)#6_parent">
<cfset dlHeader = trim(#dlHeader#)><!--- strip the damn extra line breaks off -- grrrrrrr --->
<cfset dlHeader = "#dlHeader##chr(10)#"><!--- add one and only one line break back onto the end --->
<cffile action="write" file="#dlPath##dlFile#" addnewline="no" output="#dlHeader#">
<!--- loop through the records and append a line for each one --->

 <cfloop query="allRecords">
 	<cfset oneLine = ""><!--- kill anything that's hanging on from the last loop --->
 	<cfquery name="thisRecord" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select 
		CONTAINER_ID,
		PARENT_CONTAINER_ID,
		CONTAINER_TYPE,
		DESCRIPTION,
		PARENT_INSTALL_DATE,
		CONTAINER_REMARKS,
		label,
		barcode
		 from container
		where
		container_id = #container_id#
	</cfquery>
		<cfloop query="thisRecord">
			<cfset p1id = "">
			<cfset p2id = "">
			<cfset p3id = "">
			<cfset p4id = "">
			<cfset p5id = "">
			<cfset p6id = "">
			<cfset thisDate = #dateformat(PARENT_INSTALL_DATE,"dd-mmm-yyyy")#>
			<cfset oneLine = "#CONTAINER_TYPE##chr(9)##label##chr(9)##DESCRIPTION##chr(9)##barcode##chr(9)##thisDate##chr(9)#">
			<!----
			<tr>
				<td>#CONTAINER_TYPE#</td>
				<td>#label#</td>
				<td>#DESCRIPTION#</td>
				<td>#barcode#</td>
				<td>#PARENT_INSTALL_DATE#</td>
				<td>
				---->
					<!--- get the parent for the container in thisRecord --->
					<cfquery name="p1" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select 
						CONTAINER_ID,
						PARENT_CONTAINER_ID,
						CONTAINER_TYPE,
						DESCRIPTION,
						PARENT_INSTALL_DATE,
						CONTAINER_REMARKS,
						label,
						barcode
						 from container
						where
						container_id = #parent_container_id#
					</cfquery>
					<cfif #p1.PARENT_CONTAINER_ID# gt 0>
						<cfset p1id = #p1.PARENT_CONTAINER_ID#>
					</cfif>
				<cfif #p1.label# gt 0>
					<cfset oneLine = "#oneLine##p1.label##chr(9)#">
				</cfif>
					<cfif len(#p1id#) gt 0>
						<cfquery name="p2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								select 
								CONTAINER_ID,
								PARENT_CONTAINER_ID,
								CONTAINER_TYPE,
								DESCRIPTION,
								PARENT_INSTALL_DATE,
								CONTAINER_REMARKS,
								label,
								barcode
								 from container
								where
								container_id = #p1id#
							</cfquery>
							<cfset oneLine = "#oneLine##p2.label##chr(9)#">
							<cfset p2id = #p2.PARENT_CONTAINER_ID#>
						
						</cfif>
					</td>
				<td><cfif len(#p2id#) gt 0>
					<cfquery name="p3" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								select 
								CONTAINER_ID,
								PARENT_CONTAINER_ID,
								CONTAINER_TYPE,
								DESCRIPTION,
								PARENT_INSTALL_DATE,
								CONTAINER_REMARKS,
								label,
								barcode
								 from container
								where
								container_id = #p2id#
							</cfquery>
							<cfset oneLine = "#oneLine##p3.label##chr(9)#">
							<cfset p3id = #p3.PARENT_CONTAINER_ID#>
						
						</cfif>
					</td>
					<td>
					
					<cfif len(#p3id#) gt 0>
						<cfquery name="p4" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								select 
								CONTAINER_ID,
								PARENT_CONTAINER_ID,
								CONTAINER_TYPE,
								DESCRIPTION,
								PARENT_INSTALL_DATE,
								CONTAINER_REMARKS,
								label,
								barcode
								 from container
								where
								container_id = #p3id#
							</cfquery>
							<cfset oneLine = "#oneLine##p4.label##chr(9)#">
							 <cfset p4id = #p4.PARENT_CONTAINER_ID#>
						</cfif>
						<cfif len(#p4id#) gt 0>
						<cfquery name="p5" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								select 
								CONTAINER_ID,
								PARENT_CONTAINER_ID,
								CONTAINER_TYPE,
								DESCRIPTION,
								PARENT_INSTALL_DATE,
								CONTAINER_REMARKS,
								label,
								barcode
								 from container
								where
								container_id = #p4id#
							</cfquery>
							<cfset oneLine = "#oneLine##p5.label##chr(9)#">
							 <cfset p5id = #p5.PARENT_CONTAINER_ID#>
						</cfif>
						<cfif len(#p5id#) gt 0>
						<cfquery name="p6" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
								select 
								CONTAINER_ID,
								PARENT_CONTAINER_ID,
								CONTAINER_TYPE,
								DESCRIPTION,
								PARENT_INSTALL_DATE,
								CONTAINER_REMARKS,
								label,
								barcode
								 from container
								where
								container_id = #p5id#
							</cfquery>
							<cfset oneLine = "#oneLine##p6.label#">
							 <cfset p6id = #p6.PARENT_CONTAINER_ID#>
						</cfif>
					
		</cfloop>
 <cfset oneLine = trim(#oneLine#)>
	<cffile action="append" file="#dlPath##dlFile#" addnewline="yes" output="#oneLine#">
 </cfloop>
 <a href="/temp/containerDownload.txt">Download</a>

 
	



</cfoutput>
