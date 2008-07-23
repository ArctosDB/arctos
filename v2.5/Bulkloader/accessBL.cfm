<cfinclude template="/includes/_header.cfm">
<cfset collection_cde="Mamm">
<cfif #action# is "nothing">

	This form used the current structure of the Bulkloader table to build data handling tools.
	
	<p>
		As of Feb 2007, the Bulkloader in it's entirety won't fit into MS Access due to 
		Microsoft's table width constraints. You <strong>must</strong> modify the scripts 
		created by this page before you can import them into Access. For example, if your data
		include only two parts you may delete part_name_{>2}, 
		part_modifier_{>2}, preserv_method_{>2}, part_condition_{>2}, 
		part_barcode_{>2}, part_container_label_{>2}, part_lot_count_{>2},
		part_disposition_{>2}, and part_remark_{>2}.
	</p>
	
	<p>
		Text downloads do NOT provide field datatypes and constraints. 
		<ul>
			<li>
				collection_object_id must be numeric and unique
			</li>
			<li>
				all other fields may be TEXT but must conform to data rules (<em>e.g.</em>, 
				cat_num must contain integer values, began_date and ended_date must
				be full dates, etc.)
			</li>
		</ul>
	</p>
	<p>
		All columns are optional, but the bulkloader process will fail without sufficient data. See
		<a href="javascript:getDocs('Bulkloader/bulkloader_fields')">Bulkloader documentation</a>
		for more information.
	</p>
	
	<ul>
		<li>Download <a href="accessBL.cfm?action=getTextFile">text headers</a> in a comma-delimited text file and 
			import into the tool of your choice
		</li>
	</ul>
	To build a stand-alone Access bulkloader (UAM circa 2005):
	<ol>
		<li>
			Build a new Access database
		</li>
		<li>Import the Bulkloader form</li>
		<li>Click the Modules tab in the Access database window, then click "New"</li>
		<li>Copy the <a href="accessBL.cfm?action=make">make tables</a> script from this page, 
			delete any code that Access has put in the new module,
			paste the code into the new module's code window, and click the run button (or push F5)</li>
		
		<li>
			Copy the <a href="accessBL.cfm?action=populate">populate tables</a> code from this page,
			delete everything from the modules window, and paste that code in. Hit F5 or Run to 
			populate your new code tables.
		</li>
		<li>
			Copy the <a href="accessBL.cfm?action=UAMMammals">UAM Mammals Defaults</a> code from this page,
			delete everything from the modules window, and paste that code in. Hit F5 or Run to 
			make your life easier.
		</li>
		<li>
			If you want to clean up an old Bulkloader MDB file instead of creating a new one, 
			run the <a href="accessBL.cfm?action=delete">delete tables</a>
			code to remove all old code tables AND THE BULKLOADER TABLE. 
		</li>
		<li>
			If you need them, get a list of agent_names from 
			<a href="accessBL.cfm?action=agents">Agents</a>
			to rebuild table agent_name. Save as .txt and import.
		</li>
		<li>
			Update <a href="accessBL.cfm?action=geog">higher geography</a>
			to rebuild table higher_geog. Save as .txt and import.
		</li>
		<li>
			Update <a href="accessBL.cfm?action=taxonomy">mammal taxonomy</a>
			to rebuild table scientific_name. Save as .txt and import.
		</li>
		
		
	</ol>
	<cfinclude template="/includes/_footer.cfm">
</cfif>

<!------------------------------------------->
<cfif #action# is "getTextFile">
		<cfquery name="bulkloader" datasource="uam_god">
			select
				COLUMN_NAME,
				DATA_TYPE,
				DATA_LENGTH
			FROM user_tab_cols
			WHERE table_name='BULKLOADER'
				ORDER BY
			INTERNAL_COLUMN_ID
		</cfquery>
		<cfset qColList = valuelist(bulkloader.COLUMN_NAME)>
		<cfoutput>#qColList#</cfoutput>
</cfif>
<!------------------------------------------->
<cfif #action# is "">
		<li>
			Whine to Jonathan when the Bulkloader form doesn't work with the new tables
		</li>
	</ol>
	
</cfif>
<!------------------------------------------>
<cfif #action# is "make">
	<cfoutput>
		<cfquery name="bulkloader" datasource="uam_god">
			select
				COLUMN_NAME,
				DATA_TYPE,
				DATA_LENGTH
			FROM user_tab_cols
			WHERE table_name='BULKLOADER'
			and column_name <> 'COLLECTION_OBJECT_ID'
				ORDER BY
			INTERNAL_COLUMN_ID
		</cfquery>
		<cfset sql = "Private Sub makeSomeNewStuff()<br>">
		<cfset sql= "#sql# S = ""CREATE TABLE BULKLOADER (""<br>">
		<cfset sql= "#sql# S = S & ""COLLECTION_OBJECT_ID counter primary key,""<BR>">
		<CFLOOP query="BULKLOADER">
			<cfif #DATA_TYPE# is "VARCHAR2">
				<CFSET thisDataType = "VARCHAR(#data_length#)">
			<cfelseif #DATA_TYPE# is "NUMBER">
				<CFSET thisDataType = "NUMBER">
			<cfelse>
				<CFSET thisDataType = #DATA_TYPE#>
			</cfif>
			<cfset sql = "#sql#S = S & ""#column_name# #thisDataType#,""<br>">
		</CFLOOP>
		<cfset sql = "#sql#S = S & "");""">
		<cfset sql=reverse(sql)>
		<cfset sql=replace(sql,",","","first")>
		<cfset sql=reverse(sql)>
		<cfset sql = "#sql#<br>DoCmd.RunSQL (S)">
		<cfset sql = "#sql#<br>'<br>' end make bulkloader ">
<!---
	get code tables - pretend like all columns are
	varchar(60) unless we find out otherwise when an 
	application chokes....
--->	
		<cfquery name="codeTableNames" datasource="uam_god">
			select table_name from sys.user_tables where table_name like 'CT%'
		</cfquery>
		<cfloop query="codeTableNames">
			<cfset thisTableName = #table_name#>
			<cfquery name="colnames" datasource="uam_god">
				select column_name from sys.user_tab_cols where table_name='#table_name#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
			<cfset colList = "">
			<cfloop query="colnames">
				<cfif len(#colList#) is 0>
					<cfset colList=#column_name#>
				<cfelse>
					<cfset colList="#colList#,#column_name#">		
				</cfif>
			</cfloop>
			
			<cfif listlen(#colList#) is 1>
				<cfquery name="ctdata" datasource="uam_god">
					select #colList# from #thisTableName#
				</cfquery>
				<!--- normal CT, no collection cde --->
				<cfset thisCol = #colList#>
			<cfelseif LISTLEN(#colList#) is 2 and #colList# contains "COLLECTION_CDE">
				<cfloop list="#colList#" index="c">
					<cfif #c# is not "COLLECTION_CDE">
						<cfset thisCol = #c#>
					</cfif>
				</cfloop>
				<cfquery name="ctdata" datasource="uam_god">
					select #thisCol# from #thisTableName#
					where collection_cde='#collection_cde#'
				</cfquery>
				<!--- normal CT with collection_cde --->
				<cfset thisMakeCol = replace(colList,","," varchar(60),","all")>
				<cfset thisMakeCol = "#thisMakeCol# varchar(60)">
			<cfelse>
				<!--- something goofy, ignore it --->
			</cfif>
			<cfset sql = "#sql#<br>S = ""CREATE TABLE #thisTableName# (#thisCol# varchar(60));""">
			<cfset sql = "#sql#<br>doCmd.runSQL (S)">
		</cfloop>

<cfset sql = "#sql#<br>End Sub">
#sql#
	</cfoutput>
	
</cfif>
<!------------------------------------------->
<!------------------------------------------>
<cfif #action# is "populate">
	<cfoutput>
		<cfset pop= "Private Sub getSomeData()<br>
		docmd.setwarnings false<br>">
		<cfquery name="codeTableNames" datasource="uam_god">
			select table_name from sys.user_tables where table_name like 'CT%'
		</cfquery>
		<cfloop query="codeTableNames">
			<cfset thisTableName = #table_name#>
			<cfquery name="colnames" datasource="uam_god">
				select column_name from sys.user_tab_cols where table_name='#table_name#'
				and column_name <> 'DESCRIPTION'
			</cfquery>
			<cfset colList = "">
			<cfloop query="colnames">
				<cfif len(#colList#) is 0>
					<cfset colList=#column_name#>
				<cfelse>
					<cfset colList="#colList#,#column_name#">		
				</cfif>
			</cfloop>
			
			<cfif listlen(#colList#) is 1>
				<cfquery name="ctdata" datasource="uam_god">
					select #colList# from #thisTableName#
				</cfquery>
				<!--- normal CT, no collection cde --->
				<cfset thisCol = #colList#>
			<cfelseif LISTLEN(#colList#) is 2 and #colList# contains "COLLECTION_CDE">
				<cfloop list="#colList#" index="c">
					<cfif #c# is not "COLLECTION_CDE">
						<cfset thisCol = #c#>
					</cfif>
				</cfloop>
				<cfquery name="ctdata" datasource="uam_god">
					select #thisCol# from #thisTableName#
					where collection_cde='#collection_cde#'
				</cfquery>
				<!--- normal CT with collection_cde --->				
			<cfelse>
				<!--- something goofy, ignore it --->
			</cfif>
			<cfloop query="ctdata">
					<cfset thisData = replace(evaluate("ctData." & thisCol),"'","''","all")>
					<cfset pop= "#pop#<br>p = ""
					insert into #thisTableName# (#thisCol#) 
					values ('#thisData#')""">
					<cfset pop= "#pop#<br>doCmd.runSQL (p)">
			</cfloop>
		</cfloop>

<cfset pop = "#pop#<br>
docmd.setwarnings true<br>End Sub">
#pop#
	</cfoutput>
	
</cfif>
<!------------------------------------------->
<cfif #action# is "delete">
	<cfoutput>
	<cfset kill= "Private Sub killSomeOldStuff()<br>
		DoCmd.RunSQL (""drop table bulkloader;"")">
	<cfquery name="codeTableNames" datasource="uam_god">
		select table_name from sys.user_tables where table_name like 'CT%'
	</cfquery>
	<cfloop query="codeTableNames">
		<cfset kill= "#kill#<br>DoCmd.RunSQL (""drop table #table_name#;"")">
	</cfloop>
		<cfset kill = "#kill#<br>End Sub">
		#kill#
	</cfoutput>
</cfif>
<!------------------------------------------->
<cfif #action# is "UAMMammals">
Private Sub uamMammDefaults()<br>
Dim MyDB, MyTable<br>
Set MyDB = CurrentDb()<br>
Set tdf = MyDB.TableDefs("BULKLOADER")<br>
tdf.Fields("lot_count").DefaultValue = "1"<br>
tdf.Fields("condition").DefaultValue = "unchecked"<br>
tdf.Fields("COLLECTOR_ROLE_1").DefaultValue = "c"<br>
tdf.Fields("COLLECTION_CDE").DefaultValue = "Mamm"<br>
tdf.Fields("INSTITUTION_ACRONYM").DefaultValue = "UAM"<br>
tdf.Fields("VERIFICATIONSTATUS").DefaultValue = "requires verification"<br>
tdf.Fields("GEOREFMETHOD").DefaultValue = "not recorded"<br>
Set tDef = Nothing<br>
Set db = Nothing<br>
End Sub<br>
</cfif>
<!------------------------------------------->
<cfif #action# is "agents">
<cfoutput>
<cfquery name="agentName" datasource="#Application.web_user#">
	select agent_name from preferred_agent_name
</cfquery>
	agent_name<br>
<cfloop query="agentName">
	#agent_name#<br>
</cfloop>
</cfoutput>
</cfif>
<!------------------------------------------->
<cfif #action# is "geog">
<cfoutput>
<cfquery name="higher_geog" datasource="#Application.web_user#">
	select higher_geog from geog_auth_rec
	group by higher_geog
</cfquery>
	higher_geog<br>
<cfloop query="higher_geog">
	#higher_geog#<br>
</cfloop>
</cfoutput>
</cfif>
<!------------------------------------------->
<cfif #action# is "taxonomy">
<cfoutput>
<cfquery name="tax" datasource="#Application.web_user#">
	select scientific_name from taxonomy
	where phylclass='Mammalia'
	group by scientific_name
</cfquery>
	scientific_name<br>
<cfloop query="tax">
	#scientific_name#<br>
</cfloop>
</cfoutput>
</cfif>
<!------------------------------------------->
<!----
<cfif #action# is not "nothing">
<cfoutput>

<cfquery name="bulkloader" datasource="uam_god">
	select
		COLUMN_NAME,
		DATA_TYPE,
		DATA_LENGTH
	FROM user_tab_cols
	WHERE table_name='BULKLOADER'
	and column_name <> 'COLLECTION_OBJECT_ID'
		ORDER BY
	INTERNAL_COLUMN_ID
</cfquery>
<cfset sql = "Private Sub makeSomeNewStuff()<br>">
<cfset kill= "Private Sub killSomeOldStuff()<br>
	DoCmd.RunSQL (""drop table bulkloader;"")">
	<cfset sql= "#sql# S = ""CREATE TABLE BULKLOADER (""<br>">
	<cfset sql= "#sql# S = S & ""COLLECTION_OBJECT_ID counter primary key,""<BR>">

<CFLOOP query="BULKLOADER">
	<cfif #DATA_TYPE# is "VARCHAR2">
		<CFSET thisDataType = "VARCHAR(#data_length#)">
	<cfelseif #DATA_TYPE# is "NUMBER">
		<CFSET thisDataType = "NUMBER">
	<cfelse>
		<CFSET thisDataType = #DATA_TYPE#>
	</cfif>
	<cfset sql = "#sql#S = S & ""#column_name# #thisDataType#,""<br>">
</CFLOOP>
<cfset sql = "#sql#S = S & "");""">
<cfset sql=reverse(sql)>
<cfset sql=replace(sql,",","","first")>
<cfset sql=reverse(sql)>
<cfset sql = "#sql#<br>DoCmd.RunSQL (S)">
<cfset sql = "#sql#<br>'<br>' end make bulkloader ">
<!---
	get code tables - pretend like all columns are
	varchar(60) unless we find out otherwise when an 
	application chokes....
--->	
<cfquery name="codeTableNames" datasource="uam_god">
	select table_name from sys.user_tables where table_name like 'CT%'
</cfquery>

<cfset pop= "Private Sub gimmeDaData()<br>">
<cfloop query="codeTableNames">
	<cfset thisTableName = #table_name#>
	<cfquery name="colnames" datasource="uam_god">
		select column_name from sys.user_tab_cols where table_name='#table_name#'
		and column_name <> 'DESCRIPTION'
	</cfquery>
	<cfset colList = "">
	<cfloop query="colnames">
		<cfif len(#colList#) is 0>
			<cfset colList=#column_name#>
		<cfelse>
			<cfset colList="#colList#,#column_name#">		
		</cfif>
	</cfloop>
	<cfquery name="ctdata" datasource="uam_god">
		select #colList# from #thisTableName#
	</cfquery>
	<cfif listlen(#colList#) is 1>
		<!--- normal CT, no collection cde --->
		<cfset kill = "#kill#<br>DoCmd.RunSQL (""DROP TABLE #thisTableName#;"")">
		<cfset sql = "#sql#<br>S = ""CREATE TABLE #thisTableName# (#colList# varchar(60));""">
		<cfset sql = "#sql#<br>doCmd.runSQL (S)">
		<cfloop query="ctdata">
			<cfset thisData = replace(evaluate("ctData." & colList),"'","''","all")>
			<cfset pop= "#pop#<br>p = ""insert into #thisTableName# (#colList#) values ('#thisData#');""">
			<cfset pop= "#pop#<br>doCmd.runSQL (p)">
		</cfloop>
	<cfelseif LISTLEN(#colList#) is 2 and #colList# contains "COLLECTION_CDE">
		<!--- normal CT with collection_cde --->
		<cfloop list="#colList#" index="c">
			<cfif #c# is not "COLLECTION_CDE">
				<cfset thisCol = #c#>
			</cfif>
		</cfloop>
		<cfset thisMakeCol = replace(colList,","," varchar(60),","all")>
		<cfset thisMakeCol = "#thisMakeCol# varchar(60)">
		<cfset kill = "#kill#<br>DoCmd.RunSQL (""DROP TABLE #thisTableName#;"")">
		<cfset sql = "#sql#<br>S = ""CREATE TABLE #thisTableName# (#thisMakeCol#);""">
		<cfset sql = "#sql#<br>doCmd.runSQL (S)">
		<cfloop query="ctdata">
			<cfset thisData = replace(evaluate("ctData." & thisCol),"'","''","all")>
			<cfset pop= "#pop#<br>p = ""
			insert into #thisTableName# (collection_cde, #thisCol#) 
			values ('#collection_cde#','#thisData#')""">
			<cfset pop= "#pop#<br>doCmd.runSQL (p)">
		</cfloop>
	<cfelse>
		<!--- something goofy, ignore it --->
	</cfif>
	<cfset hasCollCde="no">
</cfloop>

<cfset sql = "#sql#<br>End Sub">

<cfset pop = "#pop#<br>End Sub">


<cfif #action# is "">
	#pop#
</cfif>



</cfoutput>
</cfif>

<cfquery name="agentName" datasource="#Application.web_user#">
	select agent_name from preferred_agent_name
</cfquery>
	<cfset sql="#sql#<br>
		S= ""CREATE TABLE agent_name (agent_name varchar(255));""
		<br>doCmd.runSQL (S)">
	<cfset kill = "#kill#<br>DoCmd.RunSQL (""DROP TABLE agent_name;"")">
<cfloop query="agentName">
	<cfset pop= "#pop#<br>p = ""
			insert into agent_name (agent_name) 
			values ('#agent_name#')""">
	<cfset pop= "#pop#<br>doCmd.runSQL (p)">
</cfloop>
---->