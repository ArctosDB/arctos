<cfquery name="getCols" datasource="uam_god">
	select column_name from sys.user_tab_cols
	where table_name='BULKLOADER_STAGE'
	order by internal_column_id
</cfquery>
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from BULKLOADER_STAGE		
</cfquery>
<cfoutput>
	<cfset colList = "">
	<cfloop query="getCols">
		<cfif len(#colList#) is 0>
			<cfset colList = #column_name#>
		<cfelse>
			<cfset colList = "#colList##chr(9)##column_name#">
		</cfif>
	</cfloop>
	<cfset colList=#trim(colList)#>
	<cfset colList = "#colList##chr(10)#"><!--- add one and only one line break back onto the end --->

	<cffile action="write" file="#Application.webDirectory#/Bulkloader/bulkloader.txt" addnewline="no" output="#colList#">
	<cfloop query="data">
		<cfquery name="thisQueryRow" dbtype="query">
			select * from data where collection_object_id = #collection_object_id#
		</cfquery>
		<cfset thisRow = "">
		<cfloop list="#colList#" index="i" delimiters="#chr(9)#">
			<cfset thisData = #evaluate("thisQueryRow." & i)#>
			<!--- replace linebreak chars in Loaded --->
			<cfif #i# is "loaded">
				<cfset thisData = #replace(thisData,chr(10),"-linebreak-","all")#>
				<cfset thisData = #replace(thisData,chr(9),"-tab-","all")#>
			</cfif>	
			<cfif len(#thisData#) is 0>
				<cfset thisData = " ">
			</cfif>
			<cfif len(#thisRow#) is 0>
				<cfset thisRow = #thisData#>
			<cfelse>
				<cfset thisRow = "#thisRow##chr(9)##thisData#">
			</cfif>
			
		</cfloop>
		<cfset thisRow=#trim(thisRow)#>
	<cfset thisRow = "#thisRow##chr(10)#">
		<cffile action="append" file="#Application.webDirectory#/Bulkloader/bulkloader.txt" addnewline="no" output="#thisRow#">
	</cfloop>
</cfoutput>
