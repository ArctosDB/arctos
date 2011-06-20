<cfoutput>
	
	<cfquery name="d" datasource="uam_god">
		select name from ttccommonname where name like '%,%'
	</cfquery>
	<cfloop query="d">
		<hr>#name#
		<br>
		<cfloop list="#name#" index="I">
			<br>#i#<br>
		</cfloop>
	</cfloop>
</cfoutput>