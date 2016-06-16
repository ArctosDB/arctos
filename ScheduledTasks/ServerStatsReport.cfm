<cfoutput>
	<cfexecute  name = "ls" timeout="10" variable = "x">
	</cfexecute>

	<cfdump var=#x#>

<!----
 arguments = "-h #application.webDirectory#"
---->

</cfoutput>