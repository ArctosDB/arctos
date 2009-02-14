<cfinclude template="/includes/_header.cfm">
Use this form to retrieve all unloaded records from the Bulkloader. Records with a loaded flag of "Success!"
will NOT appear in this file.
<p>
General Access import guidelines:
<ul>
	<li>Tables --> New --> Import</li>
	<li>type=.txt</li>
	<li>Delimited</li>
	<li>Tab Delimited, First Row Contains Field Names, no text qualifier</li>
	<li>Verbatim_Date should be imported as TEXT.</li>
	<li>Part_Conditions sometimes try to import as numbers; they should be text</li>
	<li>Collection_object_id is Primary Key</li>
</ul>
<a href="bulkloader.txt">Get Data</a>
<cfquery name="getCols" datasource="uam_god">
	select column_name from sys.user_tab_cols
	where table_name='BULKLOADER'
	order by internal_column_id
</cfquery>
<cfquery name="data" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from bulkloader where 
	 (
		loaded <> 'Success!' OR loaded is null)
		
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
	<hr>
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
<cfinclude template="/includes/_footer.cfm">