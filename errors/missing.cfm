<!--- 
	requires httpd.conf to contain ErrorDocument 404 /errors/missing.cfm 
	Allows accepting URLs of the formats:
	 .../bla/whatever/specimen/{institution}/{collection}/{catnum}
	 .../bla/whatever/guid/{institution}:{collection}:{catnum}
--->
<cfif isdefined("cgi.REDIRECT_URL") and len(cgi.REDIRECT_URL) gt 0>
	<cfif urlencodedformat(url)>
		the URL is encoded
	<cfelse>
		the URL is not encoded
	</cfif>
<cfabort>
	<cfif listfindnocase(cgi.REDIRECT_URL,'specimen',"/")>
		<cftry>
			<cfset gPos=listfindnocase(cgi.REDIRECT_URL,"specimen","/")>
			<cfset	i = listgetat(cgi.REDIRECT_URL,gPos+1,"/")>
			<cfset	c = listgetat(cgi.REDIRECT_URL,gPos+2,"/")>
			<cfset	n = listgetat(cgi.REDIRECT_URL,gPos+3,"/")>
			<cfset guid=i & ":" & c & ":" & n>
			<cfinclude template="/SpecimenDetail.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(cgi.REDIRECT_URL,'guid',"/")>
		<cftry>
			<cfset gPos=listfindnocase(cgi.REDIRECT_URL,"guid","/")>
			<cfset guid = listgetat(cgi.REDIRECT_URL,gPos+1,"/")>
			<cfinclude template="/SpecimenDetail.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>				
	<cfelseif listfindnocase(cgi.REDIRECT_URL,'name',"/")>
		<cftry>
			<cfset gPos=listfindnocase(cgi.REDIRECT_URL,"name","/")>
			<cfset scientific_name = listgetat(cgi.REDIRECT_URL,gPos+1,"/")>
			<cfinclude template="/TaxonomyDetails.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>		
	<cfelse>
		<!--- see if we can handle the peristent 404s elegantly --->
		<cfif cgi.SCRIPT_NAME contains "/DiGIRprov/www/DiGIR.php">
			<cfheader statuscode="301" statustext="Moved permanently">
			<cfheader name="Location" value="http://arctos.database.museum/digir/DiGIR.php"> 
		</cfif>
		<cfinclude template="/errors/404.cfm">
	</cfif>
<cfelse>
	<cfinclude template="/errors/404.cfm">
</cfif>