<cfif not isdefined("id") or len(#id#) is 0><cfabort></cfif>
<cfquery name="d" datasource="#Application.web_user#">
	select url from cf_canned_search where canned_id=#id#
</cfquery>
<cfif len(#d.url#) gt 0>
	<cflocation addtoken="no" url="#d.url#">
</cfif>