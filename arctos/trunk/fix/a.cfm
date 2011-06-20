<cfoutput>
	
	<cfquery name="d" datasource="uam_god">
		select name from ttccommonname where name like '%,%'
	</cfquery>
	<cfloop query="d">
		#name#<br>
	</cfloop>
</cfoutput>