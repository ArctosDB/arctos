<cfif isdefined("cgi.REDIRECT_URL") and len(cgi.REDIRECT_URL) gt 0>
	<cfset rdurl=cgi.REDIRECT_URL>
	<cfif rdurl contains chr(195) & chr(151)>
		<cfset rdurl=replace(rdurl,chr(195) & chr(151),chr(215))>
	</cfif>
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
	<cfelseif listfindnocase(rdurl,'document',"/")>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"document","/")>
			gPos---#gPos#
			<cfif listgetat(rdurl,gPos+1,"/")>
				<cfset ttl = listgetat(rdurl,gPos+1,"/")>
			</cfif>
			<cfif listgetat(rdurl,gPos+2,"/")>
				<cfset p=listgetat(rdurl,gPos+2,"/")>
			<cfelse>
				<cfset p=1>
			</cfif>
			<cfinclude template="/document.cfm">
			<cfcatch>
				<cfdump var=#cfcatch#>
				<!---
				<cfinclude template="/errors/404.cfm">
				--->
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
	<cfelseif listfindnocase(rdurl,'project',"/")>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"project","/")>
			<cfif listlen(rdurl,"/") gt 1>
				<cfset niceProjName = listgetat(rdurl,gPos+1,"/")>
			</cfif>
			<cfinclude template="/ProjectDetail.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(rdurl,'media',"/")>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"media","/")>
			<cfif listlen(rdurl,"/") gt 1>
				<cfset media_id = listgetat(rdurl,gPos+1,"/")>
				<cfset action="search">
			</cfif>
			<cfinclude template="/MediaSearch.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(rdurl,'saved',"/")>
		<Cfoutput>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"saved","/")>
			<cfif listlen(rdurl,"/") gt 1>
				<cfset sName = listgetat(rdurl,gPos+1,"/")>
				<cfquery name="d" datasource="cf_dbuser">
					select url from cf_canned_search where upper(search_name)='#ucase(sName)#'
				</cfquery>
				<cfif d.url contains "#application.serverRootUrl#/SpecimenResults.cfm?">
					<cfset mapurl=replace(d.url,"#application.serverRootUrl#/SpecimenResults.cfm?","","all")>
					<cfloop list="#mapURL#" delimiters="&" index="i">
						<cfset t=listgetat(i,1,"=")>
						<cfset v=listgetat(i,2,"=")>
						<cfset "#T#" = "#v#">
					</cfloop>
					<cfinclude template="/SpecimenResults.cfm">
				<cfelse>
					<script>
						document.location='#d.url#';
					</script>
				</cfif>
			<cfelse>
				<cfinclude template="/errors/404.cfm">
			</cfif>
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
		</Cfoutput>		
	<cfelse><!--- all the rest --->
		<!--- see if we can handle the peristent 404s elegantly --->
		<cfif cgi.SCRIPT_NAME contains "/DiGIRprov/www/DiGIR.php">
			<cfheader statuscode="301" statustext="Moved permanently">
			<cfheader name="Location" value="http://arctos.database.museum/digir/DiGIR.php">
		<cfelse>
			<cftry>
				<cfscript>
					getPageContext().forward(cgi.REDIRECT_URL & ".cfm?" & cgi.redirect_query_string);
				</cfscript>
				<cfabort>
			<cfcatch>
				<cfscript>
					getPageContext().forward("/errors/404.cfm");
				</cfscript>
				<cfabort>
			</cfcatch>
			</cftry>
		</cfif>
	</cfif>
<cfelse>
	<cfinclude template="/errors/404.cfm">
</cfif>