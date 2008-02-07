<!--- no security --->
<cfdirectory action="list" directory="#webDirectory#/ALA_Imaging/data/" name="d" sort="name ASC">
<cfoutput>
	<cfloop query="d">
		<a href="#name#">#name#</a><br>
	</cfloop>
</cfoutput>