<cfquery name="b" datasource="#Application.uam_dbo#">
	select collection_object_id from bulkloader where loaded is null
</cfquery>
<cfoutput query="b">
	<cfquery name="oneRecord" datasource="#Application.uam_dbo#">
		select * from bulkloader where collection_object_id = #collection_object_id#
	</cfquery>
	<cfinclude template="BulkloaderCheck.cfm">
	#collection_object_id#: #loadedMsg#
	<hr>
	<cfquery name="up" datasource="#Application.uam_dbo#">
		update bulkloader set loaded = '#loadedMsg#' where collection_object_id = #collection_object_id#
	</cfquery>
</cfoutput>