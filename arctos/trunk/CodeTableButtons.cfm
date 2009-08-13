<cfinclude template="includes/_header.cfm">
<cfset title = "Edit Code Tables">
<cfquery name="getCTName" datasource="uam_god">
	select 
		distinct(table_name) table_name 
	from 
		sys.user_tables 
	where 
		table_name like 'CT%'
	UNION 
		select 'CTGEOLOGY_ATTRIBUTE' table_name from dual
	 order by table_name
</cfquery>
<cfoutput>
	<cfset i=1>
	<cfloop query="getCTName">
		<cfquery name="getCols" datasource="uam_god">
			select column_name from sys.user_tab_columns where table_name='#table_name#'
		</cfquery>
		<cfloop query="getCols">
			<cfif not #getCols.column_name# contains "DISPLAY">
				<cfset dispValFg = "no">
			<cfelse>
				<cfset dispValFg = "yes">
			</cfif>
		</cfloop>
		<cfif #dispValFg# is "no">
			<cfif #getCTName.table_name# is "ctattribute_code_tables">
				<a href="CodeTableEditor.cfm?tbl=#getCTName.table_name#&fld=special&collcde=#collcde#">#getCTName.table_name#</a>
			<cfelse>
				<cfset collcde = "">
				<cfset descn = "">
				<cfloop query="getCols">
					<cfif not column_name contains "display" AND not column_name contains "description">
						<cfif not column_name is "collection_cde">
							<cfset fld=column_name>
							<cfset collcde="#collcde#n">
						<cfelse>
							<cfset collcde="#collcde#y">
						</cfif>
					</cfif>
					<cfif column_name contains "description">
						<cfset descn="y">
					</cfif>
				</cfloop>
				<cfif #collcde# contains "y">
					<cfset collcde="y">
				<cfelse>
					<cfset collcde="n">
				</cfif>
				<cfif #descn# contains "y">
					<cfset descn="y">
				<cfelse>
					<cfset descn="n">
				</cfif>
				<cfif #getCTName.table_name# is "CTCOLLECTION_CDE">
					<cfset fld="COLLECTION_CDE">
					<CFSET collcde="n">
				</cfif>
				<a href="CodeTableEditor.cfm?tbl=#getCTName.table_name#&fld=#fld#&collcde=#collcde#&hasDescn=#descn#">#getCTName.table_name#</a>
				<cfif descn is "y">
					(includes documentation)
				<cfelse>
				<br>
			</cfif>
		</cfif>
		<cfset i=#i#+1>
	</cfloop>
</cfoutput>
<cfinclude template="includes/_footer.cfm">