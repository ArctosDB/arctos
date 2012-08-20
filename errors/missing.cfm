<cfoutput>
	
	
	
	
	
	<br>
	cgi.path_translated: #cgi.path_translated#
	<br>GetPageContext().GetServletContext().getRealPath("/"): #GetPageContext().GetServletContext().getRealPath("/")#
	
	

<br>
request dump
<cfdump var=#request#>



	<cfset objRequest = GetPageContext().getRequest()>
	
	<cfset x=GetPageContext().getRequest().getAttributeNames()>
	x:#x#
	
	objRequest
<cfdump var="#objRequest#">
<hr>
<cfset REDIRECT_URL = objRequest.getAttribute("REDIRECT_URL")>

REDIRECT_URL
<cftry>
<cfdump var="#REDIRECT_URL#">
<cfcatch>crashy....</cfcatch>
</cftry>
<hr>



<cfset REDIRECT_QUERY_STRING = objRequest.getAttribute("REDIRECT_QUERY_STRING")>

REDIRECT_QUERY_STRING
<cftry>
<cfdump var="#REDIRECT_QUERY_STRING#">
<cfcatch>crashy....</cfcatch>
</cftry>
	
	
	getPageContext().getRequest()
	
	<cfdump var="#getPageContext().getRequest()#" />
	
	
	<hr>
	
	getPageContext().
	
	<cfdump var="#getPageContext()#" />
	
	
	<hr>
	getPageContext().getRequest().getAttribute('REDIRECT_URL')
	<cftry>
	<cfdump var="#getPageContext().getRequest().getAttribute('REDIRECT_URL')#" />
<cfcatch>crashy....</cfcatch>
</cftry>
	
	
	<hr>
	
	dump of getPageContext().getRequest().getOriginalRequest().getAttribute('REDIRECT_URL')
	<cftry>
	<cfdump var="#getPageContext().getRequest().getOriginalRequest().getAttribute('REDIRECT_URL')#" />
<cfcatch>crashy....</cfcatch>
</cftry>
	<hr>
	
	
<br>cgi.request_uri: #cgi.request_uri#
<br>cgi.redirect_url: #cgi.redirect_url#
<cfset x=GetPageContext().getRequest().getRequestURI() >
<br>x: #x#

<br>CGI.HTTP_X_REWRITE_URL: #CGI.HTTP_X_REWRITE_URL#

<br>CGI.X_FORWARDED_FOR: #CGI.X_FORWARDED_FOR#

<br>CGI.HTTP_X_ORIGINAL_URL: #CGI.HTTP_X_ORIGINAL_URL#

 <cfset request.urlStrings= listToArray(spanExcluding(CGI.REDIRECT_URL ,"?"), "/")>
  
  <cfdump var=#request.urlStrings#>


cgi.path_info: #cgi.path_info#
CGI dump
<cfdump var=#cgi#>
url:
<cfdump var=#url#>
<cfscript>
if (structKeyExists(cgi,"http_x_rewrite_url") && len(cgi.http_x_rewrite_url))   // iis6 1/ IIRF (Ionics Isapi Rewrite Filter)
 request.path_info = listFirst(cgi.http_x_rewrite_url,'?');
else if (structKeyExists(cgi,"http_x_original_url") && len(cgi.http_x_original_url)) // iis7 rewrite default
 request.path_info = listFirst(cgi.http_x_original_url,"?");
else if (structKeyExists(cgi,"request_uri") && len(cgi.request_uri))      // apache default
 request.path_info = listFirst(cgi.request_uri,'?');
else if (structKeyExists(cgi,"redirect_url") && len(cgi.redirect_url))      // apache fallback
 request.path_info = listFirst(cgi.redirect_url,'?');
else                     // fallback to cgi.path_info
 request.path_info = cgi.path_info;
 </cfscript>
 
 <cfdump var=#request#>

	<cfset currentPath=GetDirectoryFromPath(GetTemplatePath())> 

<br>currentpath:#currentpath#


<cffunction name="pathHandler" access="remote" returntype="string" httpmethod="GET" produces="text/plain" 
	restpath="{productName}/{productCodeName}"> 
		<cfargument name="productName" required="true" type="string" restargsource="path"/> 
		<cfargument name="productCodeName" required="true" type="string" restargsource="path"/> 
		<cfreturn productName & " " & productCodeName> </cffunction>


<cfset x=pathHandler()>

<cfdump var=#x#>





</cfoutput>






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
			<cfcatch>
				<cfinclude template="/errors/404.cfm">
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