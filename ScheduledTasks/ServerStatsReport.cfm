<cfoutput>
	<cfexecute  name = "ls"  variable = "x">
	</cfexecute>

	<cfdump var=#x#>

<!----
 arguments = "-h #application.webDirectory#"
---->

</cfoutput>