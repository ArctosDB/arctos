<cfif cgi.HTTP_HOST contains "harvard.edu" >
	<br>
	<table width="95%" border="0" cellspacing="0" cellpadding="0">
	  	<tr>
	    	<td align="center" nowrap><a href="/Collections/index.cfm"><FONT size="-1">Data Providers</FONT></a></td>
	    	<td align="center" nowrap><a href="/info/bugs.cfm"><FONT size="-1">Report Errors</FONT></a></td>
	    	<td align="center" nowrap><a HREF="mailto:bhaley@oeb.harvard.edu"><FONT size="-1">System Administrator</FONT></a></td>
	  	</tr>
	</table>
    <HR>
    <table width="95%"  border="0" cellspacing="0" cellpadding="0">
		<tr>
		  <td rowspan="3" align="right" valign="bottom"><a href="/home.cfm"><img src="/images/arctos.gif" width="49" height="53" border="0" ALT="[ Link to home page. ]"></a></td>
		  <td >&nbsp;</td>
		  <td >&nbsp;</td>
		  <td >&nbsp;</td>
		  <td nowrap align="center" >&nbsp;</td>
		  <td align="center" >&nbsp;</td>
		  <td align="center" nowrap><FONT size="-1">Distributed Databases: </FONT></td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td nowrap >&nbsp;</td>
		  <td nowrap align="center" >&nbsp;</td>
		  <td align="center">&nbsp;</td>
		  <td align="center"><a href="http://www.herpnet.org/"><img src="/images/HerpNET_superbaby_logo.jpg" alt="herpnet" width="47" height="20" border="0"></a> &nbsp; <a href="http://ornisnet.org">
		<img src="/images/ornislogo_superbaby.jpg" width="47" height="20" border="0" alt="ornis"></a></td>
		</tr>
		<tr>
		  <td nowrap valign="bottom">&nbsp;</td>
		  <td nowrap valign="bottom"> <FONT size="-1"> A collaboration with multiple natural history collections</FONT></td>
		  <td nowrap>&nbsp;</td>
		  <td nowrap align="center" >&nbsp;</td>
		  <td align="center">&nbsp;</td>
		  <td align="center"><a href="http://manisnet.org">
		<img src="/images/manis_banner_superbaby.jpg" alt="manis" width="145" height="20" border="0"></a></td>
		</tr>
    </table>
    <P>&nbsp;</P>
<cfelse>

    <cfset murl="">
    <cfif request.rdurl contains "/guid/" or request.rdurl contains "/name/">
	   <cfset murl="/m" & request.rdurl>
	</cfif>
	<!----
    <cfset mobile="SpecimenSearch,SpecimenResults,name,guid,taxonomy">


    <cfdump var=#request.rdurl#>
	<cfset here=replace(replace(cgi.script_name,"/",""),".cfm","")>
	<cfdump var=#here#>

	<cfinvoke returnVariable="x" component="component.utilities" method="listcommon" list1="#mobile#" list2="#here#">

                         <cfset m=replace("/m/" & request.rdurl,'//','/','all')>
                         <cfset v="">
                         <cfif isdefined("mapurl") and len(mapurl) gt 0>
                              <cfset v=v & "&mapurl=" & mapurl>
                              <cfset v=replace(v,"&","?","first")>
                              <cfdump var=#v#>
                        </cfif>
                        <cfset m=m&v>
                              <cfdump var=#m#>
----->


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
					<cfif len(murl) gt 0>
                        <a HREF="<cfoutput>#murl#</cfoutput>"><font size="-1">View in mobile site</font></a>
                    </cfif>
				</ul>
			</td>
		</tr>
	</table>
</cfif>
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("<cfoutput>#Application.Google_uacct#</cfoutput>");
pageTracker._trackPageview();
} catch(err) {}</script>
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