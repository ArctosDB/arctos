<cfinclude template="../includes/_pickHeader.cfm">
<cfset title = "Delete encumbrance">
<cfif len(#encumbrance_id#) is 0>
		Didn't get an encumbrance_id!!<cfabort>
	</cfif>
	<cfif len(#collection_object_id#) is 0>
		Didn't get a collection_object_id!!<cfabort>
	</cfif>

<cfoutput>
	<cfquery name="deleItems" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	DELETE FROM coll_object_encumbrance WHERE encumbrance_id=#encumbrance_id# and collection_object_id = #collection_object_id#
	</cfquery>
	<p>Click <a href="" onClick="parent.opener.location.reload();self.close();">here</a> to reload the encumbrance list and close this form.
	<p>Depending on your browser, you may get a pop-up alert. Choose YES or OK to correctly reload the page.</p>
</cfoutput>
<cfinclude template="../includes/_pickFooter.cfm">