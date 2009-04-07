<!--- requires httpd.conf to contain ErrorDocument 404 /errors/missing.cfm --->
<cfoutput>
	<cfif isdefined("cgi.REDIRECT_URL") and len(cgi.REDIRECT_URL) gt 0>
		<cfif listfindnocase(cgi.REDIRECT_URL,'guid',"/")>
			guid is in the string
		<cfelse>
			we tried - bye....
		</cfif>
		
	<cfelse>
		<!--- standard go away page 
		
		<cflocation url="/errors/404.cfm" addtoken="false">
		
		--->
		bye.....
	</cfif>
</cfoutput>