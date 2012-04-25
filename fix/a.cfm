<cfoutput>
			
		<cfdirectory action="LIST" directory="#application.webDirectory#/temp/" name="dir" recurse="yes">


<cfdump var=#dir#>

</cfoutput>