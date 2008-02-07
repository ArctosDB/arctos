<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html>
	<head>
		
	</head>			
	<body>
	
	<cfoutput>
	<cfif #cgi.HTTP_USER_AGENT# contains "4.7">
		<font color="##FF0000">
			<i>
				This page does not function properly with Netscape 4.7.
				<br>Please see our <a href="http://arctos.database.museum/About.cfm?Action=sys">System Requirements</a>.
			</i>
		</font>
	</cfif>
	<cfif #cgi.HTTP_USER_AGENT# contains "MSIE">
		<div align="center">
			<font color="##FF0000"  size="-1">
				<i>
					Some features of this site may not work in your browser. We recommend 
					<a href="http://www.mozilla.org/products/firefox/">FireFox</a>.
				</i>
			</font>
		</div>
	</cfif>
	<cfinclude template="/includes/navBox.cfm">
	<cfinclude template="/includes/UAMHerpHeaderContent.cfm">
	<!---
	
	--->
</cfoutput>
<div class="content">
