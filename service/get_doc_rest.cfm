<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select * from short_doc where  lower(colname) = ( '#lcase(fld)#' )
</cfquery>
-----#d.display_name##chr(10)##d.definition#<cfif len(d.more_info) gt 0>#chr(10)##d.more_info#</cfif>
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