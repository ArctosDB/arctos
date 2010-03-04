<cfinclude template="/includes/_header.cfm">
	<cfoutput>
		<cfquery name="activity" datasource="uam_god">
			select 
				to_char(TIMESTAMP,'dd-Mon-yyyy HH24:MI:SS') date_stamp, 
				SQL_TEXT sql_statement, 
				DB_USER username,
				OBJECT_NAME object,
				SQL_BIND
			from 
				uam.arctos_audit
			where
				TO_char(TIMESTAMP) > SYSDATE - 1 and
				upper(object_name) like 'CT%'
			ORDER BY 
				username,
				date_stamp,
				sql_statement
		</cfquery>
		<cfif activity.recordcount gt 0>
			<cfmail to="#Application.DataProblemReportEmail#" subject="Code Table Activity Report" from="ctreport@#Application.fromEmail#" type="html">
				Last 24 hours of code table activity:
				<table border>
					<tr>
						<th>When</th>
						<th>Who</th>
						<th>What</th>
						<th>SQL</th>
					</tr>
					<cfloop query="activity">
						<tr>
							<td>#date_stamp#</td>
							<td>#username#</td>
							<td>#object#</td>
							<td>#sql_statement#</td>
						</tr>
					</cfloop>
				</table>
			</cfmail>
		</cfif>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">