<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select * from taxon_name where scientific_name like '%(%'
	</cfquery>
	<cfloop query="d">
		<br>#scientific_name#
		<cfset startpos=find('(',scientific_name)>
		<cfset stoppos=find(')',scientific_name)>
		<cfset theSG=mid(scientific_name,startpos+1,stoppos-startpos-1)>
		<br>theSG: #theSG#
	</cfloop>

</cfoutput>