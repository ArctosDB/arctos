<!--- requires httpd.conf to contain ErrorDocument 404 /errors/missing.cfm --->
<cfoutput>
	<cfif isdefined("cgi.REDIRECT_URL") and len(cgi.REDIRECT_URL) gt 0>
		cgi.REDIRECT_URL: #cgi.REDIRECT_URL#
		<cfif listfindnocase(cgi.REDIRECT_URL,'guid',"/")>
			guid is in the string....
			<cftry>
				<cfset gPos=listfindnocase(cgi.REDIRECT_URL,"guid","/")>
				<cfset	i = listgetat(cgi.REDIRECT_URL,gPos+1)>
				<cfset	c = listgetat(cgi.REDIRECT_URL,gPos+2)>
				<cfset	n = listgetat(cgi.REDIRECT_URL,gPos+3)>
				i: #i#
								c: #c#
												n: #n#
			<!--- we'll accept URLs like .../bla/whatever/guid/{institution}/{collection}/{catnum} --->
				<cfcatch>
					fail...
				</cfcatch>
			</cftry>
			
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