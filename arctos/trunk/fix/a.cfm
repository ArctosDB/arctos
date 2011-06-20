<cfinclude template="/includes/functionLib.cfm">
<cfoutput>
	
	<cfquery name="d" datasource="uam_god">
		select * from ttccommonname where name like '%,%'
	</cfquery>
	<cfloop query="d">
		<hr>#name#
		<br>
		<cfloop list="#name#" index="I">
			<cfquery name="u" datasource="uam_god">
				insert into ttccommonname (name,TAXON_NAME_ID) values ('#escapequotes(i)#',#TAXON_NAME_ID#)
			</cfquery>
			<br>#i#<br>
		</cfloop>
	</cfloop>
</cfoutput>