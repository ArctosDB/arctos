<cfinclude template="/includes/_header.cfm">
<!--- first, see if we can find what they're looking for --->
<cfdump var="#cgi#">
<hr>
<cfdump var="#url#">


<cfdump var="#server#">
<cfdump var="#request#">
<!-------------
<cfheader statuscode="404" statustext="Page Missing">
<cfoutput>
<table cellpadding="10">
	<tr><td valign="top"><img src="/images/oops.gif"></td>
	<td>
<font color="##FF0000" size="+1">The page you tried to access does not exist.</font>

<p>&nbsp;</p>
<cfif len(#cgi.HTTP_REFERER#) gt 0>
	<br>The last page you visited was #cgi.HTTP_REFERER#.
	<cfif #cgi.HTTP_REFERER# contains "#Application.ServerRootUrl#">
		<br>The link seems to be internal. Please submit a 
		<a href="/info/bugs.cfm">bug report</a> containing any information 
		that might help us resolve this issue.
	<cfelse>
		<br>The referral seems to be external. Click <a href="#cgi.HTTP_REFERER#" target="_blank">here</a>
		to return to #cgi.HTTP_REFERER#, and please ask them to fix this problem! 
		<font size="-1">Link opens in a new window.</font>	
	</cfif>
<cfelse>
	<br>You probably typed the address incorrectly. If you came from another page, please ask
	them to fix the problem. If you came from somewhere on Arctos, please submit a
	<a href="/info/bugs.cfm">bug report</a>.
</cfif>
		<cfmail subject="Dead Link" to="#Application.PageProblemEmail#" from="dead.link@#application.fromEmail#" type="html">
			A user found a dead link! The referring site was #cgi.HTTP_REFERER#.
			<cfif isdefined("CGI.script_name")>
				<br>The missing page is #Replace(CGI.script_name, "/", "")#
			</cfif>
			<cfif isdefined("session.username")>
				<br>The username is #session.username#
			</cfif>
			<br>The IP requesting the dead link was #cgi.REMOTE_ADDR#
			<br>This message was generated by #cgi.CF_TEMPLATE_PATH#.
			<hr><cfdump var="#cgi#">
		</cfmail>
		 <p>A message has been sent to the site administrator.</p>
		 <p>
		 	Use the tabs in the header or see the <a href="siteMap.cfm">Site Map</a>
			to navigate Arctos
				
			
		 </p>
		 </td></tr>
</table>
</cfoutput>
<hr>
-------------->
<cfinclude template="/includes/_footer.cfm">