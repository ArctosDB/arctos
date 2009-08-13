<cfinclude template="includes/_header.cfm">
<cfset title = "Edit Code Tables">
<cfquery name="getCTName" datasource="uam_god">
	select 
		distinct(table_name) table_name 
	from 
		uam.user_tables 
	where 
		table_name like 'CT%'
	UNION 
		select 'CTGEOLOGY_ATTRIBUTE' table_name from dual
	 order by table_name
</cfquery>
<cfoutput>
	<cfset i=1>
	<cfloop query="getCTName">
		
				<a href="CodeTableEditor.cfm?tbl=#getCTName.table_name#&fld=#fld#&collcde=#collcde#&hasDescn=#descn#">#getCTName.table_name#</a>
				<cfif descn is "y">
					(includes documentation)
				</cfif>
				<br>
			</cfif>
		</cfif>
		<cfset i=#i#+1>
	</cfloop>
</cfoutput>
<cfinclude template="includes/_footer.cfm">