<cfdirectory action="LIST"
    	directory="#Application.webDirectory#/SpecimenImages"
        name="root"
		recurse="no">
<cfoutput>
<cfloop query="root">
	<br>#name#
</cfloop>


</cfoutput>