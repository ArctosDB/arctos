
	 <table id="_footerTable">
		<tr>
			<td align="left" valign="middle">
			 <a href="/home.cfm">
			    <img SRC="/images/Arctos-generic-footer.png" BORDER=0 ALT="[ Link to home page. ]">
				</a>
			 </td>
			<td>
				<ul>
					<li>
						<a href="/Collections/index.cfm"><font size="-1">Data Providers</font></a>
					</li>
					<li>
						<a HREF="/contact.cfm?ref=<cfoutput>#request.rdurl#</cfoutput>"><font size="-1">Report a bug or request support</font></a>
					</li>


    <cfif request.rdurl contains "SpecimenResults.cfm" and (isdefined("mapurl") and len(mapurl) gt 0)>
          <cfset durl="/SpecimenResults.cfm?" & mapurl>
    <cfelse>
                        <cfset durl=replace(replace(request.rdurl,'m/','/'),'//','/','all')>
     </cfif>
<li>
    <link rel="canonical" href="<cfoutput>#durl#</cfoutput>"/>
	                       <a HREF="<cfoutput>#durl#</cfoutput>"><font size="-1">Desktop Site</font></a>

</li>




                        <cfdump var=#durl#>
				</ul>
			</td>
		</tr>
	</table>
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));

try {
var pageTracker = _gat._getTracker("<cfoutput>#Application.Google_uacct#</cfoutput>");
pageTracker._trackPageview();
} catch(err) {}


try {


	$("#desktoplink").attr("href", $("#desktoplink").attr('href') + '?r=' + encodeURIComponent($('link[rel=canonical]').attr('href')) );





console.log($('link[rel=canonical]').attr('href'));

} catch(err) {


	console.log(err);

}


</script>
<cfif not isdefined("title")>
	<cfset title = "Database Access">
</cfif>
<cftry>
	<cfhtmlhead text='<title>#title#</title>'>
	<cfcatch type="template">
	</cfcatch>
</cftry>
</body>
</html>