<!--- 
	requires httpd.conf to contain ErrorDocument 404 /errors/missing.cfm 
	Allows accepting URLs of the formats:
	 .../bla/whatever/specimen/{institution}/{collection}/{catnum}
	 .../bla/whatever/guid/{institution}:{collection}:{catnum}
--->
<cfif isdefined("cgi.REDIRECT_URL") and len(cgi.REDIRECT_URL) gt 0>
	<cfoutput>
	<cfset rdurl=cgi.REDIRECT_URL>
	<cfif rdurl contains chr(195) & chr(151)>
		<cfset rdurl=replace(rdurl,chr(195) & chr(151),chr(215))>
	</cfif>
	</cfoutput>
	<cfif listfindnocase(rdurl,'specimen',"/")>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"specimen","/")>
			<cfset	i = listgetat(rdurl,gPos+1,"/")>
			<cfset	c = listgetat(rdurl,gPos+2,"/")>
			<cfset	n = listgetat(rdurl,gPos+3,"/")>
			<cfset guid=i & ":" & c & ":" & n>
			<cfinclude template="/SpecimenDetail.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(rdurl,'guid',"/")>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"guid","/")>
			<cfset guid = listgetat(rdurl,gPos+1,"/")>
			<cfinclude template="/SpecimenDetail.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>				
	<cfelseif listfindnocase(rdurl,'name',"/")>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"name","/")>
			<cfset scientific_name = listgetat(rdurl,gPos+1,"/")>
			<cfinclude template="/TaxonomyDetails.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(rdurl,'api',"/")>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"api","/")>
			<cfif listlen(rdurl,"/") gt 1>
				<cfset action = listgetat(rdurl,gPos+1,"/")>
			</cfif>
			<cfinclude template="/info/api.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(rdurl,'saved',"/")>
		<Cfoutput>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"saved","/")>
			<cfif listlen(rdurl,"/") gt 1>
				yep
				<cfset sName = listgetat(rdurl,gPos+1,"/")>
				sName: #sName#
				<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select url from cf_canned_search where upper(search_name)='#ucase(sName)#'
				</cfquery>
				<cfdump var="#d#">
				<cfif d.url contains "#application.serverRootUrl#/SpecimenResults.cfm?">
					<cfset mapurl=replace(d.url,"#application.serverRootUrl#/SpecimenResults.cfm?","","all")>
					mapurl: #mapurl#
					<cfloop list="#mapURL#" delimiters="&" index="i">
						<cfset t=listgetat(i,1,"=")>
						<cfset v=listgetat(i,2,"=")>
												<br>i: #i# (#t# == #v#)<br>


<cfset #t#=v>
					</cfloop>
					<cfdump var=#variables#>
					<br>including: /SpecimenResults.cfm?#mapurl#
					<cfinclude template="/SpecimenResults.cfm">
				<cfelse>
					wtf...
				</cfif>
			<cfelse>
				nope
			</cfif>
			<cfcatch>
				<cfdump var=#cfcatch#>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
		</Cfoutput>
	<cfelse><!--- all the rest --->
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