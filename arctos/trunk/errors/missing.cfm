<cfif listlen(request.rdurl,"/") gt 1>
	<cfset rdurl=replacenocase(cgi.query_string,"path=","","all")>

		---<cfdump var=#request.rdurl#>
	<cfif listfindnocase(request.rdurl,'specimen',"/")>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"specimen","/")>
			<cfset	i = listgetat(request.rdurl,gPos+1,"/")>
			<cfset	c = listgetat(request.rdurl,gPos+2,"/")>
			<cfset	n = listgetat(request.rdurl,gPos+3,"/")>
			<cfset guid=i & ":" & c & ":" & n>
			<cfinclude template="/SpecimenDetail.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(request.rdurl,'document',"/")>
		<cfoutput>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"document","/")>
			<cftry>
				<cfset ttl = listgetat(request.rdurl,gPos+1,"/")>
				<cfcatch></cfcatch>
			</cftry>
			<cftry>
				<cfset p=listgetat(request.rdurl,gPos+2,"/")>
				<cfcatch></cfcatch>
			</cftry>

			<cfinclude template="/document.cfm">
			<cfcatch>
				<cfif listlen(request.rdurl,"/") gt 2 and listgetat(request.rdurl,gPos+2,"/")>
					<cfset p=listgetat(request.rdurl,gPos+2,"/")>
				<cfelse>
					<cfset p=1>
				</cfif>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
		</cfoutput>
	<cfelseif listfindnocase(request.rdurl,'guid',"/")>
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
			<cfset gPos=listfindnocase(request.rdurl,"guid","/")>
			<cfset guid = listgetat(request.rdurl,gPos+1,"/")>
			<cfif contentType is "application/rdf+xml">
				<cfinclude template="/SpecimenDetailRDF.cfm">
			<cfelse>
				<cfinclude template="/SpecimenDetail.cfm">
			</cfif>
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(request.rdurl,'name',"/")>
		<cfif listlast(request.rdurl,"/") is "name">
			<!--- redirect /name to taxonomysearch --->
			<cflocation url="/TaxonomySearch.cfm" addtoken="false">
		<cfelse>
			<cftry>
				<cfset gPos=listfindnocase(request.rdurl,"name","/")>
				<cfset scientific_name = listgetat(request.rdurl,gPos+1,"/")>
				<cfinclude template="/TaxonomyDetails.cfm">
				<cfcatch>
					<cfinclude template="/errors/404.cfm">
				</cfcatch>
			</cftry>
		</cfif>
	<cfelseif listfindnocase(request.rdurl,'api',"/")>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"api","/")>
			<cfif listlen(request.rdurl,"/") gt 1>
				<cfset action = listgetat(request.rdurl,gPos+1,"/")>
			</cfif>
			<cfinclude template="/info/api.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(request.rdurl,'project',"/")>
		<cfdump var=#request.rdurl#>
		<cfabort>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"project","/")>
			<cfif listlen(request.rdurl,"/") gt 1>
				<cfset niceProjName = listgetat(request.rdurl,gPos+1,"/")>
			</cfif>
			<cfinclude template="/ProjectDetail.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(request.rdurl,'media',"/")>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"media","/")>
			<cfif listlen(request.rdurl,"/") gt 1>
				<cfset media_id = listgetat(request.rdurl,gPos+1,"/")>
			</cfif>
			<cfinclude template="/MediaDetail.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(request.rdurl,'publication',"/")>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"publication","/")>
			<cfif listlen(request.rdurl,"/") gt 1>
				<cfset publication_id = listgetat(request.rdurl,gPos+1,"/")>
				<cfset action="search">
			</cfif>
			<cfinclude template="/SpecimenUsage.cfm">
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(request.rdurl,'saved',"/")>
		<Cfoutput>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"saved","/")>
			<cfif listlen(request.rdurl,"/") gt 1>
				<cfset sName = listgetat(request.rdurl,gPos+1,"/")>
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
	<cfelseif cgi.SCRIPT_NAME contains "/DiGIR.php" or request.rdurl contains "/DiGIR.php" or request.rdurl contains "/digir">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="http://129.237.201.204/arctosdigir/DiGIR.php">
	<cfelseif FileExists("#Application.webDirectory#/#request.rdurl#.cfm")>
		<cfscript>
			getPageContext().forward("/" & request.rdurl & ".cfm?" & cgi.redirect_query_string);
		</cfscript>
		<cfabort>
	<cfelse>
		<cfinclude template="/errors/404.cfm">
	</cfif>
<cfelse>
	<cfinclude template="/errors/404.cfm">
</cfif>