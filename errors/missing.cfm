
				<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
					you are coldfusion_user
				</cfif>



<!---- make sure this stays at the top ---->
<cfif listfindnocase(request.rdurl,'m',"/")>
	<!--- mobile handling ---->
	<cfif listfindnocase(request.rdurl,'guid',"/")>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"guid","/")>
			<cfset temp = listgetat(request.rdurl,gPos+1,"/")>
			<cfif listlen(temp,'?&') gt 1>
				<cfset guid=listgetat(temp,1,"?&")>
				<cfset t2=listdeleteat(temp,1,"?&")>
				<cfloop list="#t2#" delimiters="?&" index="x">
					<cfif listlen(x,"=") is 2>
						<cfset vn=listgetat(x,1,"=")>
						<cfset vv=listgetat(x,2,"=")>
						<cfset "#vn#"=vv>
					</cfif>
				</cfloop>
			<cfelse>
				<cfset guid=temp>
			</cfif>
			<cfinclude template="/m/SpecimenDetail.cfm">
			<cfcatch>
				<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
					<cfdump var=#cfcatch#>
				</cfif>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	<cfelseif listfindnocase(request.rdurl,'name',"/")>
	    <cfif replace(replace(request.rdurl,"/","","last"),"/","","all") is "name">
	        <cfinclude template="/m/taxonomy.cfm">
	    <cfelse>
	        <cftry>
	            <cfset gPos=listfindnocase(request.rdurl,"name","/")>
	            <cfset name = listgetat(request.rdurl,gPos+1,"/")>
	            <cfinclude template="/m/taxonomy.cfm">
	            <cfcatch>
					<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
						<cfdump var=#cfcatch#>
					</cfif>
	                <cfinclude template="/errors/404.cfm">
	            </cfcatch>
	        </cftry>
	    </cfif>
	</cfif>
<cfelseif listfindnocase(request.rdurl,'doi',"/")>
	<cftry>
		<cfset gPos=listfindnocase(request.rdurl,"doi","/")>
		<cfset doi = listgetat(request.rdurl,gPos+1,"/")>
		<cfset doi=replacenocase(doi,'doi:','')>
		<!--- dois have slashies in them.... --->
		<cfif listlen(request.rdurl,"/") is gPos+2>
			<cfset doi=doi & "/" & 	listgetat(request.rdurl,gPos+2,"/")>
		</cfif>

		<cfquery name="d" datasource="cf_dbuser">
			select * from doi where upper(doi)='#ucase(doi)#'
		</cfquery>
		<cfif d.recordcount is 0>
			<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
				<cfdump var=#cfcatch#>
			</cfif>
			<cfinclude template="/errors/404.cfm">
		</cfif>
		<cfif d.media_id gt 0>
			<cfset media_id=d.media_id>
			<cfinclude template="/MediaDetail.cfm">
		<cfelseif d.collection_object_id gt 0>
			<cfset collection_object_id=d.collection_object_id>
			<cfinclude template="/SpecimenDetail.cfm">
		<cfelse>
			<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
				<cfdump var=#cfcatch#>
			</cfif>
			<cfinclude template="/errors/404.cfm">
		</cfif>
	<cfcatch>

		<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
			<cfdump var=#cfcatch#>
		</cfif>
		<cfinclude template="/errors/404.cfm">
	</cfcatch>
	</cftry>
<cfelseif listfindnocase(request.rdurl,'specimen',"/")>
	<cftry>
		<cfset gPos=listfindnocase(request.rdurl,"specimen","/")>
		<cfset	i = listgetat(request.rdurl,gPos+1,"/")>
		<cfset	c = listgetat(request.rdurl,gPos+2,"/")>
		<cfset	n = listgetat(request.rdurl,gPos+3,"/")>
		<cfset guid=i & ":" & c & ":" & n>
		<cfinclude template="/SpecimenDetail.cfm">
		<cfcatch>
			<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
				<cfdump var=#cfcatch#>
			</cfif>
			<cfinclude template="/errors/404.cfm">
		</cfcatch>
	</cftry>
<cfelseif listfindnocase(request.rdurl,'document',"/")>
	<cfif replace(request.rdurl,"/","","last") is "document">
		<cfinclude template="/document.cfm">
	<cfelse>
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
				<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
					<cfdump var=#cfcatch#>
				</cfif>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	</cfif>
<cfelseif listfindnocase(request.rdurl,'guid',"/")>

<p>guid</p>



	<cfif replace(request.rdurl,"/","","last") is "guid">
		<cfinclude template="/SpecimenSearch.cfm">
	<cfelse>
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


				probably not here





				<cfset contentType="text/html">
			</cfcatch>
			</cftry>



			<cfset gPos=listfindnocase(request.rdurl,"guid","/")>
			<cfset temp = listgetat(request.rdurl,gPos+1,"/")>


			<cfdump var=gPos>
			<cfdump var=#gPos#>




			<cfif listlen(temp,'?&') gt 1>
				<cfset guid=listgetat(temp,1,"?&")>
				<cfset t2=listdeleteat(temp,1,"?&")>
				<cfloop list="#t2#" delimiters="?&" index="x">
					<cfif listlen(x,"=") is 2>
						<cfset vn=listgetat(x,1,"=")>
						<cfset vv=listgetat(x,2,"=")>
						<cfset "#vn#"=vv>
					</cfif>
				</cfloop>
			<cfelse>
				<cfset guid=temp>
			</cfif>
			<cfif contentType is "application/rdf+xml">
				<cfinclude template="/SpecimenDetailRDF.cfm">
			<cfelse>
				<cfinclude template="/SpecimenDetail.cfm">
			</cfif>
			<cfcatch>
				<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
					<cfdump var=#cfcatch#>
				</cfif>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	</cfif>
<cfelseif listfindnocase(request.rdurl,'name',"/")>
	<cfif replace(replace(request.rdurl,"/","","last"),"/","","all") is "name">
		<cfinclude template="/taxonomy.cfm">
	<cfelse>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"name","/")>
			<cfset name = listgetat(request.rdurl,gPos+1,"/")>
			<cfinclude template="/taxonomy.cfm">
			<cfcatch>
				<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
					<cfdump var=#cfcatch#>
				</cfif>
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
			<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
				<cfdump var=#cfcatch#>
			</cfif>
			<cfinclude template="/errors/404.cfm">
		</cfcatch>
	</cftry>
<cfelseif listfindnocase(request.rdurl,'project',"/") or replace(request.rdurl,"/","","last") is "project">
	<cfif replace(request.rdurl,"/","","last") is "project">
		<cfinclude template="/SpecimenUsage.cfm">
	<cfelse>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"project","/")>
			<cfif listlen(request.rdurl,"/") gt 1>
				<cfset niceProjName = listgetat(request.rdurl,gPos+1,"/")>
			</cfif>
			<cfinclude template="/ProjectDetail.cfm">
			<cfcatch>
				<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
					<cfdump var=#cfcatch#>
				</cfif>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	</cfif>
<cfelseif listfindnocase(request.rdurl,'media',"/")>
	<cfif replace(request.rdurl,"/","","last") is  "media">
		<cfinclude template="/MediaSearch.cfm">
	<cfelse>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"media","/")>
			<cfset temp = listgetat(request.rdurl,gPos+1,"/")>
			<cfif listlen(temp,'?&') gt 1>
				<cfset media_id=listgetat(temp,1,"?&")>
				<cfset t2=listdeleteat(temp,1,"?&")>
				<cfloop list="#t2#" delimiters="?&" index="x">
					<cfif listlen(x,"=") is 2>
						<cfset vn=listgetat(x,1,"=")>
						<cfset vv=listgetat(x,2,"=")>
						<cfset "#vn#"=vv>
					</cfif>
				</cfloop>
			<cfelse>
				<cfset media_id=temp>
			</cfif>
			<cfinclude template="/MediaDetail.cfm">
			<cfcatch>

				<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
					<cfdump var=#cfcatch#>
				</cfif>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	</cfif>
<cfelseif listfindnocase(request.rdurl,'publication',"/")>
	<cfif replace(request.rdurl,"/","","last") is "project">
		<cfinclude template="/SpecimenUsage.cfm">
	<cfelse>
		<cftry>
			<cfset gPos=listfindnocase(request.rdurl,"publication","/")>
			<cfif listlen(request.rdurl,"/") gt 1>
				<cfset publication_id = listgetat(request.rdurl,gPos+1,"/")>
				<cfset action="search">
			</cfif>
			<cfinclude template="/SpecimenUsage.cfm">
			<cfcatch>

				<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
					<cfdump var=#cfcatch#>
				</cfif>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	</cfif>
<cfelseif listfindnocase(request.rdurl,'saved',"/")>
    <cfoutput>
		<cftry>
		   <cfset gPos=listfindnocase(request.rdurl,"saved","/")>
		   <cfset temp = listgetat(request.rdurl,gPos+1,"/")>
	       <cfif listlen(request.rdurl,"/") gt 1>
				<cfset sName = listgetat(request.rdurl,gPos+1,"/")>
	            <cfset sName = listgetat(sName,1,"?&")>
				<cfquery name="d" datasource="cf_dbuser">
					select url from cf_canned_search where upper(search_name)='#ucase(sName)#'
				</cfquery>
               	<cfif d.recordcount is 0>
					<cfquery name="d" datasource="cf_dbuser">
						select url from cf_canned_search where upper(search_name)='#ucase(urldecode(sName))#'
					</cfquery>
				</cfif>
				<cfif d.recordcount is 0>

					<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
						<cfdump var=#cfcatch#>
					</cfif>
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
				<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
					<cfdump var=#cfcatch#>
				</cfif>
				<cfinclude template="/errors/404.cfm">
			</cfif>
			<cfcatch>
				<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
					<cfdump var=#cfcatch#>
				</cfif>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	</cfoutput>
<cfelseif listfindnocase(request.rdurl,'archive',"/")>
    <cfoutput>
		<cftry>
		   <cfset gPos=listfindnocase(request.rdurl,"archive","/")>
		   <cfset archive_name = listgetat(request.rdurl,gPos+1,"/")>
			<cfinclude template="/SpecimenResults.cfm">
		   <!----
	       <cfif listlen(request.rdurl,"/") gt 1>
				<cfset sName = listgetat(request.rdurl,gPos+1,"/")>
	            <cfset sName = listgetat(sName,1,"?&")>
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
			---->
			<cfcatch>
				<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
					<cfdump var=#cfcatch#>
				</cfif>
				<cfinclude template="/errors/404.cfm">
			</cfcatch>
		</cftry>
	</cfoutput>
<cfelseif FileExists("#Application.webDirectory#/#request.rdurl#.cfm")>
	<cfscript>
		getPageContext().forward("/" & request.rdurl & ".cfm?" & cgi.redirect_query_string);
	</cfscript>
	<cfabort>
<cfelse>
	<cfif isdefined("session.roles") and session.roles contains "coldfusion_user">
		-final cfelse-
		<cfdump var=#cfcatch#>
	</cfif>
	<cfinclude template="/errors/404.cfm">
</cfif>