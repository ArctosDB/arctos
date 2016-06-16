<cfoutput>
	<cfexecute name = "df" arguments = "-h #application.webDirectory#" timeout="10" variable = "x">
	</cfexecute>

	<cfdump var=#x#>

<!----

---->

</cfoutput>