
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
					<!---- always offer desktop from mobile ---->
					<cfif request.rdurl contains "SpecimenResults.cfm" and (isdefined("mapurl") and len(mapurl) gt 0)>
						<cfset durl="/SpecimenResults.cfm?" & mapurl>
					<cfelse>
						<cfset durl=replace(replace(request.rdurl,'m/','/'),'//','/','all')>
					</cfif>
					<li>
						<link rel="canonical" href="<cfoutput>#durl#</cfoutput>"/>
						<a HREF="<cfoutput>/dm.cfm?r=#urlencodedformat(durl)#</cfoutput>">
							<font size="-1">
								Desktop Site
							</font>
						</a>
					</li>
				</ul>
			</td>
		</tr>
	</table>


<script>
window.ga=window.ga||function(){(ga.q=ga.q||[]).push(arguments)};ga.l=+new Date;
ga('create', '<cfoutput>#Application.Google_uacct#</cfoutput>', 'auto');
ga('send', 'pageview');
</script>
<script async src='https://www.google-analytics.com/analytics.js'></script>
<script>
try {
	$("#desktoplink").attr("href", $("#desktoplink").attr('href') + '?r=' + encodeURIComponent($('link[rel=canonical]').attr('href')) );
} catch(err) {}
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