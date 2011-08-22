<cfif not isdefined("fld")>bad call<cfabort></cfif>
<cfset fld=trim(fld)>
<cfif left(fld,1) is "_">
	<cfset fld=right(fld,len(fld)-1)>
</cfif>
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from short_doc where  lower(colname) = '#lcase(fld)#'
</cfquery>
<cfoutput>
<cfif d.recordcount is 1>
<strong>#d.display_name#</strong>
<br>#d.definition#
<cfif len(d.more_info) gt 0>
	<cfhttp url="#d.more_info#" method="head" timeout="2"></cfhttp>
	<cfif cfhttp.Statuscode is '200 OK'>
		<br><a href="#d.more_info#" target="_blank">[ More Information ]</a>
	<cfelse>
		<cfmail subject="docs: bad moreinfo" to="#Application.PageProblemEmail#" from="badlink@#Application.fromEmail#" type="html">
			#fld#: #d.more_info# not found
		</cfmail>
	</cfif>
<cfelse>
	no data found for #fld#
	<cfmail subject="doc not found" to="#Application.PageProblemEmail#" from="docMIA@#Application.fromEmail#" type="html">
		short doc not found for #fld#
	</cfmail>	
	</cfif>	
	</cfif>
</cfoutput>
<!----
<cfparam name="action" default="nothing">
<cfparam name="addCtl" default="0">
<cfif #action# is "nothing">
<!--- include search hint --->
<!---
<cfhttp url="http://arctos.database.museum/service/doc_rest.cfm" charset="utf-8" method="get">
	<cfhttpparam type="url" name="action" value="getDefinition">
	<cfhttpparam type="url" name="fld" value="#fld#">
	<cfhttpparam type="url" name="addCtl" value="#addCtl#">
</cfhttp>
<cfoutput>
		#cfhttp.fileContent#</cfoutput>
--->
</cfif>

<cfhttp url="http://g-arctos.appspot.com/ws" charset="utf-8" method="get">
	<!--- some fields are prefixed with _ (underscore) to create unique IDs - strip that crap off... --->
	<cfif left(fld,1) is "_">
		<cfset fld=right(fld,len(fld)-1)>
	</cfif>
	<cfhttpparam type="url" name="q" value="#fld#">
	<cfhttpparam type="url" name="c" value="#addCtl#">
</cfhttp>
<cfoutput>
		#cfhttp.fileContent#</cfoutput>
        
<cfif #action# is "noHint">
<!--- include search hint --->
<cfhttp url="http://arctos.database.museum/service/doc_rest.cfm" charset="utf-8" method="get">
	<cfhttpparam type="url" name="action" value="getDefinition_noHint">
	<cfhttpparam type="url" name="fld" value="#fld#">
	<cfhttpparam type="url" name="addCtl" value="#addCtl#">
</cfhttp>
<cfoutput>
		#cfhttp.fileContent#</cfoutput>
</cfif>
---->