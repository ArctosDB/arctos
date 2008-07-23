<cfabort>

<cfquery name="wtf" datasource="#Application.uam_dbo#">
	select other_id_num, coll_obj_other_id_num.collection_object_id
	from coll_obj_other_id_num,
	cataloged_item
	where 
	coll_obj_other_id_num.collection_object_id = cataloged_item.collection_object_id and
	accn_id = 2422 and
	other_id_type='NPS-C'
</cfquery>
<cfoutput query="wtf">
	<cfquery name="fixIt" datasource="#Application.uam_dbo#">
		update coll_obj_other_id_num set other_id_num=
		'KATM #other_id_num#'
		where other_id_type='NPS-C' and
		other_id_num='#other_id_num#' and
		collection_object_id=#collection_object_id#
	</cfquery>
</cfoutput>
spiffy