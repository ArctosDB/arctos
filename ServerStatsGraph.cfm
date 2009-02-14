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


	<cfloop query="uniquePage">
		<cfquery name="bob"	dbtype="query">
			select count(*) as cnt from getStats where form = '#uniquePage.form#'
		</cfquery>
		#uniquePage.form#
			#bob.cnt#
			
				
					<cfquery name="uniqueVisits" dbtype="query">
						select count(distinct(ip)) as cnt from getStats where form = '#uniquePage.form#'
					</cfquery>
			
		
		
	</cfloop>

			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
<cfquery name="uniqueUser" dbtype="query">
	select ip, host from getStats group by ip, host
</cfquery>
<p><b>Unique Users:</b>
	<cfloop query="uniqueUser">
		&nbsp;&nbsp;&nbsp;<br>#uniqueUser.ip# #uniqueUser.host#
	</cfloop>
</cfif>
<p><b>Raw Statistics:</b>

<table border>
	<tr>
		<td><b>IP/host</b></td>
		<td><b>Username</b></td>
		<td><b>Form</b></td>
		<td><b>Date</b></td>
		<td><b>Collections</b></td>
		<td><b>Record Count</b></td>
	</tr>
	<cfloop query="getStats">
		<tr>
			<td>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
					#ip# - #host#
				<cfelse>
					masked
				</cfif>
				</td>
			<td>
			<cfif isdefined("session.roles") and listfindnocase(session.roles,"coldfusion_user")>					
					#Username#&nbsp;
				<cfelse>
					masked
				</cfif>
			</td>
			<td>#Form#</td>
			<td>#dateformat(Datestamp,"dd mmm yyyy")#</td>
			<td>#Collections#</td>
			<td>#numRecords#&nbsp;</td>
		</tr>
	</cfloop>
</table>
</cfoutput>
<cfinclude template="includes/_footer.cfm">