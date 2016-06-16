<cfoutput>
	<cfexecute name = "df" arguments = "-h #application.webDirectory#" timeout="10" variable = "x">
	</cfexecute>
	<cfmail to="#Application.bugReportEmail#" subject="Arctos Server Stats Report" from="serverstats@#Application.fromEmail#" type="html">
		<p>
			df -h #application.webDirectory#
			<br><cfdump var=#x#>
		</p>
	</cfmail>
</cfoutput>