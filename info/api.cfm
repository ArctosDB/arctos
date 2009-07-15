<cfinclude template="/includes/_header.cfm">
<cfoutput>
<cfif action is "nothing">
	<h2>
		Partial list of ways to talk to Arctos & Arctos-related products:
	</h2>
<p>
	You may link to specimen results using the <a href="/info/searchAPI.cfm">SpecimenResults.cfm API</a>. 
</p>
<p>
	You may open KML files of Arctos data using the <a href="/bnhmMaps/kml.cfm?action=api">KML API</a>. 
</p>
You may link to specimens with any of the following:
	<ul>
		<li>
			#Application.serverRootUrl#/guid/{institution}:{collection}:{catnum}
			<br>Example: #Application.serverRootUrl#/guid/UAM:Mamm:1
			<br>&nbsp;
		</li>
		<li>
			#Application.serverRootUrl#/specimen/{institution}/{collection}/{catnum}
			<br>Example: #Application.serverRootUrl#/specimen/UAM/Mamm/1
			<br>
		</li>
		<li>
			#Application.serverRootUrl#/SpecimenDetail.cfm?guid={institution}:{collection}:{catnum}
			<br>Example: #Application.serverRootUrl#/SpecimenDetail.cfm?guid=UAM:Mamm:1
			<br>&nbsp;
		</li>
	</ul>
</li>
<p>
	You may 
</p>
You may link to taxon detail pages with URLs of the format:

<p>
	#Application.serverRootUrl#/name/{taxon name}
	<br>Example: #Application.serverRootUrl#/name/Alces alces
</p>
</cfif>
<cfif action is "specimen">
	<cfquery name="st" datasource="cf_dbuser">
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
			<cfif left(code_table,2) is "CT">
				<cftry>
				<cfquery name="docs" datasource="cf_dbuser">
					select * from #code_table#
				</cfquery>
				<cfloop list="#docs.columnlist#" index="colName">
					<cfif #colName# is not "COLLECTION_CDE" and #colName# is not "DESCRIPTION">
						<cfset theColumnName = #colName#>
					</cfif>
				</cfloop>
				<cfquery name="theRest" dbtype="query">
					select #theColumnName# from docs
						group by #theColumnName#
						order by #theColumnName#
				</cfquery>
				<cfset ct="">
				<cfloop query="theRest">
					<cfset ct=ct & evaluate(theColumnName) & "<br>">
				</cfloop>
				<cfcatch>
					<cfset ct="fail: #code_table#: #cfcatch.message# #cfcatch.detail# #cfcatch.sql#">
				</cfcatch>
				</cftry>
			<cfelse>
				<cfset ct=code_table>
			</cfif>
			<tr>				
				<td valign="top">#term#</td>
				<td valign="top">#display#</td>
				<td valign="top">#ct#</td>
				<td valign="top">#definition#</td>
			</tr>
		</cfloop>
	</table>
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
