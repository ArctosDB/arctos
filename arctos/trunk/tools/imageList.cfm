<cfdirectory sort="name"
  directory = "#Application.webDirectory#/images"
  name = "img">
  <cfoutput>
  <table border>
  <cfloop query="img">
  	<tr>
		<td>/images/#name#</td>
		<td><img src="/images/#name#"></td>
	</tr>	
  </cfloop>
  </table>
  </cfoutput>