<cfinclude template="includes/_header.cfm">
<cfset title = "ColdFusion Server Statistics">
<cfquery name="getStats" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from cf_user_log
	ORDER BY
		datestamp desc,
		form,
		numrecords,
		collections
</cfquery>
<cfoutput>
<cfquery name="uniqueIP" dbtype="query">
	select distinct(ip) from getStats
</cfquery>
<cfquery name="uniquePage" dbtype="query">
	select distinct(form) from getStats
</cfquery>

<br><b>Number of unique users:</b> #uniqueIP.recordcount#
<p><b>Form Usage:</b>
<table border>
	<tr>
		<td><b>Form</b></td>
		<td><b>Number Visits</b></td>
		<td><b>Unique Visitors</b></td>
	</tr>

	
	<cfloop query="uniquePage">
		<cfquery name="bob"	dbtype="query">
			select count(*) as cnt from getStats where form = '#uniquePage.form#'
			order by cnt
		</cfquery>
		<tr>
			<td>#uniquePage.form#</td>
			<td>#bob.cnt#</td>
			<td>
				
					<cfquery name="uniqueVisits" dbtype="query">
						select count(distinct(ip)) as cnt from getStats where form = '#uniquePage.form#'
					</cfquery>
			
				#uniqueVisits.cnt#
			</td>
		</tr>
		
	</cfloop>
</table>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
<cfquery name="uniqueUser" dbtype="query">
	select ip, host from getStats group by ip, host
</cfquery>
<p><b>Unique Users:</b>
	<cfloop query="uniqueUser">
		&nbsp;&nbsp;&nbsp;<br>#uniqueUser.ip# #uniqueUser.host#
	</cfloop>
</cfif>
</cfoutput>
<cfinclude template="includes/_footer.cfm">