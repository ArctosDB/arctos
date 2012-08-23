

<cfif isdefined("cgi.query_string") and len(cgi.query_string) gt 0>
	<cfset rdurl=replacenocase(cgi.query_string,"path=","","all")>
	<cfif rdurl contains chr(195) & chr(151)>
		<cfset rdurl=replace(rdurl,chr(195) & chr(151),chr(215))>
	</cfif>
	<cfoutput>
	rdurl==#rdurl#
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
	<cfelseif listfindnocase(rdurl,'document',"/")>
		<cfoutput>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"document","/")>
			<cftry>
				<cfset ttl = listgetat(rdurl,gPos+1,"/")>
				<cfcatch></cfcatch>
			</cftry>
			<cftry>
				<cfset p=listgetat(rdurl,gPos+2,"/")>
				<cfcatch></cfcatch>
			</cftry>
			
			<cfinclude template="/document.cfm">
			<cfcatch>
				<cfdump var=#cfcatch#>
				<!---
				
				
			<cfif listgetat(rdurl,gPos+2,"/")>
				<cfset p=listgetat(rdurl,gPos+2,"/")>
			<cfelse>
				<cfset p=1>
			</cfif>
				<cfinclude template="/errors/404.cfm">
				--->
			</cfcatch>
		</cftry>
		</cfoutput>	
	<cfelseif listfindnocase(rdurl,'guid',"/")>
		<cftry>
			<cftry>
				<cfset contentType="text/html">
				<cfif isdefined("cgi.HTTP_ACCEPT") and cgi.HTTP_ACCEPT contains "application/rdf+xml">
					<!--- 
					We can serve only html and rdf - if they won't take rdf, just give them html.
					If the will accept rdf, pick the prioity based on q and then on order.
				---->
				<cfset q=queryNew("o,mt,q")>
				<cfset r=1>
				<cfloop list="#cgi.HTTP_ACCEPT#" index="i">
					<cfset temp=queryaddrow(q,1)>
					<cfif listlen(i,";") is 2>
						<cfset qVal=listgetat(i,2,";")>
					<cfelse>
						<cfset qVal=1>
					</cfif>
					<cfset ft=listgetat(i,1,";")>
					<cfset temp = QuerySetCell(q, "o", r, r)>
					<cfset temp = QuerySetCell(q, "mt", ft, r)>
					<cfset temp = QuerySetCell(q, "q", qVal, r)>
					<cfset r=r+1>
				</cfloop>
				<cfquery name="ctype" dbtype="query">
					select * from q order by q desc, o desc
				</cfquery>
				<cfloop query="ctype">
					<cfif mt is "application/rdf+xml" or mt is "text/html">
						<cfset contentType=mt>
					</cfif>
				</cfloop>
				</cfif>
			<cfcatch>
				<cfset contentType="text/html">
			</cfcatch>
			</cftry>
			<cfset gPos=listfindnocase(rdurl,"guid","/")>
			<cfset guid = listgetat(rdurl,gPos+1,"/")>
			<cfif contentType is "application/rdf+xml">
				<cfinclude template="/SpecimenDetailRDF.cfm">
			<cfelse>
				<cfinclude template="/SpecimenDetail.cfm">
			</cfif>
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
			
			<cfcatch><!---
				<cfinclude template="/errors/404.cfm">
			---->
			<cfdump var=#cfcatch#>
			</cfcatch>
			
			
		</cftry>
	<cfelseif listfindnocase(rdurl,'media',"/")>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"media","/")>
			<cfif listlen(rdurl,"/") gt 1>
				<cfset media_id = listgetat(rdurl,gPos+1,"/")>
			</cfif>
			<cfinclude template="/MediaDetail.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(rdurl,'publication',"/")>
		<cftry>
			<cfset gPos=listfindnocase(rdurl,"publication","/")>
			<cfif listlen(rdurl,"/") gt 1>
				<cfset publication_id = listgetat(rdurl,gPos+1,"/")>
				<cfset action="search">
			</cfif>
			<cfinclude template="/SpecimenUsage.cfm">
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
				<cfif d.recordcount is 0>
					<cfquery name="d" datasource="cf_dbuser">
						select url from cf_canned_search where upper(search_name)='#ucase(urldecode(sName))#'
					</cfquery>
				</cfif>
				<cfif d.recordcount is 0>
					<cfinclude template="/errors/404.cfm">
					<cfabort>
				</cfif>
				<cfif d.url contains "#application.serverRootUrl#/SpecimenResults.cfm?">
					<cfset mapurl=replace(d.url,"#application.serverRootUrl#/SpecimenResults.cfm?","","all")>
					<cfloop list="#mapURL#" delimiters="&" index="i">
						<cfset t=listgetat(i,1,"=")>
						<cfset v=listgetat(i,2,"=")>
						<cfset "#T#" = "#urldecode(v)#">
					</cfloop>
					<cfinclude template="/SpecimenResults.cfm">
				<cfelseif left(d.url,7) is "http://">
					Click to continue: <a href="#d.url#">#d.url#</a>
				<cfelse>
					If you are not redirected, please click this link: <a href="/#d.url#">#d.url#</a>
					<script>
						document.location='/#d.url#';
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
	<cfelseif cgi.SCRIPT_NAME contains "/DiGIR.php">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="http://129.237.201.204/arctosdigir/DiGIR.php">
	<cfelseif FileExists("#Application.webDirectory##rdurl#.cfm")>
		<cfscript>
			getPageContext().forward(cgi.REDIRECT_URL & ".cfm?" & cgi.redirect_query_string);
		</cfscript>
		<cfabort>
	<cfelse>
		<cfinclude template="/errors/404.cfm">
	</cfif>
<cfelse>
	<cfinclude template="/errors/404.cfm">
</cfif>