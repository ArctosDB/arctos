<!--- requires httpd.conf to contain ErrorDocument 404 /errors/missing.cfm --->
<cfoutput>
<cfif isdefined("cgi.REDIRECT_URL") and len(cgi.REDIRECT_URL) gt 0>
	<cfif listfindnocase(cgi.REDIRECT_URL,'specimen',"/")>
		<cftry>
			<cfset gPos=listfindnocase(cgi.REDIRECT_URL,"specimen","/")>
			<cfset	i = listgetat(cgi.REDIRECT_URL,gPos+1,"/")>
			<cfset	c = listgetat(cgi.REDIRECT_URL,gPos+2,"/")>
			<cfset	n = listgetat(cgi.REDIRECT_URL,gPos+3,"/")>
			<cfset guid="#i#:#c#:#n#">

			i: #i#
							c: #c#
											n: #n#
		<!--- we'll accept URLs like .../bla/whatever/specimen/{institution}/{collection}/{catnum} --->
			<cfcatch>
				fail...@ 
				<cfdump var=#cfcatch#>
			</cfcatch>
		</cftry>
		<hr>
		<cfinclude template="/SpecimenDetail.cfm">
		"/SpecimenDetail.cfm?guid=#i#:#c#:#n#"
		<hr>
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