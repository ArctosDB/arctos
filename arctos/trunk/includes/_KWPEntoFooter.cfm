

<!---
<hr>
<center>
<a href="home.cfm">Home</a>&nbsp;|&nbsp;<a href="Specimensearch.cfm">Specimen&nbsp;Search</a>&nbsp|&nbsp<a href="PublicationSearch.cfm">Publication&nbsp;Search</a>&nbsp|&nbsp <a href="ProjectSearch.cfm">Project&nbsp;Search</a>&nbsp|&nbsp <a href="TaxonomySearch.cfm">Taxonomy Search</a>
--->
</center></tr></td></table>
<p></p>

<center>
<table WIDTH="600" ALIGN="center">
	<tr>
		<td align="right">
			<a href="/home.cfm">
			<img SRC="/images/arctos.gif" BORDER=0 ALT="[ Link to home page. ]" ></a>
		</td>
		<td align="center">
			
		</td>
		<td align="left" valign="top">
			
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
<cftry>
	<cfhtmlhead text="<title>#variables.title#</title>
	">
	<cfcatch type="template">
		<!--- 
			do nothing, couldn't process the header
			This is almost certainly because a CFFLUSH was called - we 
			just don't get a title on the pages
		 --->
	</cfcatch>
</cftry>
<script type="text/javascript" language="javascript">
	changeStyle('MSB');
</script>
</center>

</body>
</html>

