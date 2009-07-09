<cfinclude template="/includes/_header.cfm">
	<cfquery name="st" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select * from cf_search_terms order by term
	</cfquery>
	<table border>
		<tr>
			<th>term</th>
			<th>display</th>
			<th>values</th>
			<th>comment</th>
		</tr>
		<cfloop query="st">
			<tr>
				<cfif left(code_table,2) is "CT">
					<cfquery name="docs" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						select * from #code_table#
					</cfquery>
					<cfloop list="#docs.columnlist#" index="colName">
						<cfif #colName# is not "COLLECTION_CDE" and #colName# is not "DESCRIPTION">
							<cfset theColumnName = #colName#>
						</cfif>
					</cfloop>
					<cfquery name="theRest" dbtype="query">
						select * from docs 
							order by #theColumnName#
					</cfquery>
					<cfset ct="">
					<cfloop query="theRest">
						<cfset ct=ct & evaluate(theColumnName) & "<br>">
					</cfloop>
				<cfelse>
					<cfset ct=code_table>
				</cfif>
				<td>#term#</td>
				<td>#display#</td>
				<td#ct#</td>
				<td>#definition#</td>
			</tr>
		</cfloop>
	</table>

<cfinclude template="/includes/_header.cfm">