<cfoutput>
	<cfexecute name = "df" arguments = "-h #application.webDirectory#" timeout="10" variable = "x">
	</cfexecute>
	<cfquery name="jobs" datasource="uam_god">
		select
			OWNER,
			JOB_NAME,
			REPEAT_INTERVAL,
			ENABLED,
			STATE,
			RUN_COUNT,
			FAILURE_COUNT,
			LAST_RUN_DURATION
		from
			all_scheduler_jobs
		order by
			owner,
			job_name,
			failure_count
	</cfquery>
	<cfsavecontent variable="guts">
		<p>
			df -h #application.webDirectory#
			<br><cfdump var=#x#>
		</p>
		<p>Jobs</p>
		<table border>
			<tr>
				<th>OWNER</th>
				<th>JOB_NAME</th>
				<th>REPEAT_INTERVAL</th>
				<th>ENABLED</th>
				<th>STATE</th>
				<th>RUN_COUNT</th>
				<th>FAILURE_COUNT</th>
				<th>LAST_RUN_DURATION</th>
			</tr>
			<cfloop query="jobs">
				<tr>
					<td>#OWNER#</td>
					<td>#JOB_NAME#</td>
					<td>#REPEAT_INTERVAL#</td>
					<td>#ENABLED#</td>
					<td>#STATE#</td>
					<td>#RUN_COUNT#</td>
					<td>#FAILURE_COUNT#</td>
					<td>#LAST_RUN_DURATION#</td>
				</tr>
			</cfloop>
		</table>
	</cfsavecontent>
	#guts#



	<!----
	<cfmail to="#Application.bugReportEmail#" subject="Arctos Server Stats Report" from="serverstats@#Application.fromEmail#" type="html">
		<p>
			df -h #application.webDirectory#
			<br><cfdump var=#x#>
		</p>
	</cfmail>
	--------->
</cfoutput>