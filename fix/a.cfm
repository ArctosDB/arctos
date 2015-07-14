<cfoutput>

<cfinclude template="/includes/_header.cfm">


<cfdump var=#url#>


<!------
<cfabort>




<cfsetting requesttimeout="600">

<cfset str="abc def ghi jkl">

<cfif len(str) gt 10>#left(str,3)#</cfif>

<cffunction name="truncate" access="remote">
   <cfargument name="str" required="true" type="string">
   <cfargument name="len" required="true" type="numeric">

	<cfif len(str) gt len>
		<cfreturn str>
	<cfelse>
		<cfreturn left(str,
	</cfif>
	<cfif not isdefined("page")>
		<cfset page=1>
	</cfif>

	<cftry>
	<cfquery name="flatdocs"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select get_document_media_pageinfo('#urltitle#',#page#) result from dual
	</cfquery>
	<cfreturn flatdocs.result>
	<cfcatch><cfreturn cfcatch.message></cfcatch>
	</cftry>
</cffunction>



 <cfquery name="c" datasource="uam_god" >
	select * from publication where doi is null and rownum<10
 </cfquery>
<cfdump var=#c#>

<cfhttp url="http://www.crossref.org/openurl/?pid=dlmcdonald@alaska.edu&format=unixref"></cfhttp>

<cfdump var=#cfhttp#>

----->
<cfinclude template="/includes/_footer.cfm">
</cfoutput>

