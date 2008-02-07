</center></tr></td></table>
<p></p>

<center>
<table WIDTH="600" ALIGN="center">

<tr>
	<td align="right">
		<a href="/home.cfm"><img SRC="/images/arctos.gif" BORDER=0 ALT="[ Link to home page. ]" ></a>
	</td>
	<td align="center">
		National Biomonitoring Specimen Bank
		
	</td>
  	<td align="left">
		<a href="http://www.absc.usgs.gov/research/ammtap/nbsb.htm" target="_blank">
		<img SRC="/images/usgs.gif" BORDER=0 ALT="[ Link to USGS NBSB page. ]" ></a>
	</td>
</tr>
<tr>
	<td colspan="3" align="center">
		<font SIZE=-2>System Administrator is
        <a HREF="mailto:fndlm@uaf.edu"><i>Dusty McDonald</a>.</font>
	</td>
</tr>
</table>
<cfif not isdefined("title")>
	<cfset title = "UAM Database Access">
</cfif>
<cfhtmlhead text="<title>#variables.title#</title>">
<!--- switch to NBSB stylesheet onload --->
<script type="text/javascript" language="javascript">
	changeStyle('NBSB');
</script>

</center>

</body>
</html>

