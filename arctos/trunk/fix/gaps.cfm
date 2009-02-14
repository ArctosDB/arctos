<cfparam name="collection_cde" default="Mamm">
<cfparam name="institution_acronym" default="UAM">

<cfquery name="collection_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select collection_id from collection where
	collection_cde='#collection_cde#' and
	institution_acronym = '#institution_acronym#'
</cfquery>
<cfif #collection_id.recordcount# neq 1>
	bad collection<cfabort>
</cfif>

<cfquery name="thisColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select cat_num from cataloged_item where collection_id=#collection_id.collection_id#
</cfquery>
<cfoutput>
<cfset i=1>
<table border>
<cfloop query="thisColl">
	<cfif #cat_num# is #i#>
		<!--- nothing ---->
	<cfelse>
		<tr>
			<td>#cat_num#</td>
		</tr>
	</cfif>
	<cfset i=#i#+1>
</cfloop>
</table>
</cfoutput>