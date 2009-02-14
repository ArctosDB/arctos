<cfif not isdefined("collection_object_id") or len(#collection_object_id#) is 0>
	Didn't get a record to update!
	<cfabort>
</cfif>
<cfset uam_dbo = "MCAT_UD">
<cfset collection_object_id = #attributes.collection_object_id#>
<cfset thisDate = #dateformat(now(),"dd-mmm-yyyy")#>
<cfquery name="makeEdit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	UPDATE coll_object SET
		last_edited_person_id = #session.myAgentId#,
		last_edit_date = '#thisDate#'
	WHERE
		collection_object_id = #collection_object_id#
</cfquery>