<cfif #cgi.HTTP_HOST# contains "database.museum">
  <table>
	<tr>
		<td align="left" valign="middle">
		 <a href="/home.cfm">
		    <img SRC="/images/arctos.gif" BORDER=0 ALT="[ Link to home page. ]">
			</a>
		 </td>
		<td>
			<ul>
				<li>
					<a href="/Collections/index.cfm"><font size="-1">Data Providers</font></a>
				</li>
				<li>
					<a href="/info/bugs.cfm"><font size="-1">Report Errors</font></a>
				</li>
				<li>
					<a HREF="mailto:fndlm@uaf.edu"><font size="-1">System Administrator</font></a>
				</li>
			</ul>
		</td>
	</tr>
</table>
<cfelseif #cgi.HTTP_HOST# contains "harvard.edu" >
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


</div>
<cfelse>
<br>
 <table width="95%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
    	<td align="center" nowrap><a href="/Collections/index.cfm"><FONT size="-1">Data Providers</FONT></a></td>
    	<td align="center" nowrap><a href="/info/bugs.cfm"><FONT size="-1">Report Errors</FONT></a></td>
    	<td align="center" nowrap><a HREF="mailto:fndlm@uaf.edu"><FONT size="-1">System Administrator</FONT></a></td>
  	</tr>
</table>

  


 <HR>
  <table width="95%"  border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td rowspan="3" align="right" valign="bottom"><a href="/home.cfm"><img src="/images/arctos.gif" width="49" height="53" border="0" ALT="[ Link to home page. ]"></a></td>
    <td >&nbsp;</td>
    <td >&nbsp;</td>
    <td >&nbsp;</td>
    <td nowrap align="center" > <FONT size="-1"> Related Cal Sites: </FONT> </td>
    <td align="center" >&nbsp;</td>
    <td align="center" nowrap><FONT size="-1">Distributed Databases: </FONT></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td nowrap >&nbsp;</td>
    <td nowrap align="center" ><a href="http://mvz.berkeley.edu">
		<img src="/images/MVZ_Logo_super_baby.jpg" width="20" height="20" border="0" alt="MVZ"></a> </td>
    <td align="center">&nbsp;</td>
    <td align="center"><a href="http://www.herpnet.org/"><img src="/images/HerpNET_superbaby_logo.jpg" alt="herpnet" width="47" height="20" border="0"></a> &nbsp; <a href="http://ornisnet.org">
		<img src="/images/ornislogo_superbaby.jpg" width="47" height="20" border="0" alt="ornis"></a></td>
  </tr>
  <tr>
    <td nowrap valign="bottom">&nbsp;</td>
    <td nowrap valign="bottom"> <FONT size="-1"> A collaboration with multiple natural history collections</FONT></td>
    <td nowrap>&nbsp;</td>
    <td nowrap align="center" ><a href="http://bnhm.berkeley.edu">
		<img src="/images/bnhm_logo_superbaby.jpg" alt="bnhm" width="20" height="21" border="0"></a> &nbsp;<a href="http://www.berkeley.edu">
			<img src="/images/cal_logo_superbaby.jpg" width="27" height="20" border="0" alt="berkeley"></a> </td>
    <td align="center">&nbsp;</td>
    <td align="center"><a href="http://manisnet.org">
		<img src="/images/manis_banner_superbaby.jpg" alt="manis" width="145" height="20" border="0"></a></td>
  </tr>
</table>
<P>&nbsp;</P>


</div></cfif>
<cfif not isdefined("title")>
	<cfset title = "Database Access">
</cfif>
<cftry>
	<cfhtmlhead text="<title>#title#</title>
	">
	<cfcatch type="template">
		<!--- 
			do nothing, couldn't process the header
			This is almost certainly because a CFFLUSH was called - we 
			just don't get a title on the pages
		 --->
	</cfcatch>
</cftry>
</body>
</html>

