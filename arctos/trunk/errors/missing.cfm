<!--- 
	requires httpd.conf to contain ErrorDocument 404 /errors/missing.cfm 
	Allows accepting URLs of the formats:
	 .../bla/whatever/specimen/{institution}/{collection}/{catnum}
	 .../bla/whatever/guid/{institution}:{collection}:{catnum}
--->
<cfif isdefined("cgi.REDIRECT_URL") and len(cgi.REDIRECT_URL) gt 0>
	<cfif listfindnocase(cgi.REDIRECT_URL,'specimen',"/")>
		<cftry>
			<cfset gPos=listfindnocase(cgi.REDIRECT_URL,"specimen","/")>
			<cfset	i = listgetat(cgi.REDIRECT_URL,gPos+1,"/")>
			<cfset	c = listgetat(cgi.REDIRECT_URL,gPos+2,"/")>
			<cfset	n = listgetat(cgi.REDIRECT_URL,gPos+3,"/")>
			<cfset guid=i & ":" & c & ":" & n>
			<cfcatch>
				<cflocation url="/errors/404.cfm" addtoken="false">
			</cfcatch>
		</cftry>
		<cfinclude template="/SpecimenDetail.cfm">
	<cfelseif listfindnocase(cgi.REDIRECT_URL,'guid',"/")>
		<cftry>
			<cfset gPos=listfindnocase(cgi.REDIRECT_URL,"guid","/")>
			<cfset	guid = listgetat(cgi.REDIRECT_URL,gPos+1,"/")>
			<cfcatch>
				<cflocation url="/errors/404.cfm" addtoken="false">
			</cfcatch>
		</cftry>
				<cfinclude template="/SpecimenDetail.cfm">
	<cfelse>
		<cflocation url="/errors/404.cfm" addtoken="false">
	</cfif>
	
<cfelse>
	<cflocation url="/errors/404.cfm" addtoken="false">
	<!--- standard go away page 
	
	
	
	--->
	bye.....
</cfif>