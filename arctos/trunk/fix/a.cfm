<cfdirectory action="LIST"
    	directory="#Application.webDirectory#/SpecimenImages"
        name="root"
		recurse="yes"
		type="dir">
<cfoutput>
<cfloop query="root">
	<br>#name#
</cfloop>


</cfoutput>