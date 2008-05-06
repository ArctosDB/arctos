<cfoutput>
	<cftransaction>
<cftry>
<cfquery name="d" datasource="#uam_dbo#">
select
	cvsdata(ala_plant_imaging.barcode || '.dng') || ',' ||
	cvsdata(collection.institution_acronym || ':' || collection.collection_cde || ':' || cat_num) || ',' ||
	cvsdata(collection.collection) || ',' ||
	cvsdata(cat_num) || ',' ||
	cvsdata(ConcatSingleOtherId(cataloged_item.collection_object_id,'ALAAC')) || ',' ||
	cvsdata(concatcoll(cataloged_item.collection_object_id)) || ',' ||
	cvsdata(identification.scientific_name) || ',' ||
	cvsdata(higher_geog) || ',' ||
	cvsdata(spec_locality) || ',' ||
	cvsdata(dec_lat) || ',' ||
	cvsdata(dec_long) || ',' ||
	cvsdata(to_meters(max_error_distance,max_error_units)) || ',' ||
	cvsdata(verbatim_date) || ',' ||
	cvsdata(coll_object_remarks) theCvsString
FROM
	ala_plant_imaging,
	container,
	container thePart,
	coll_obj_cont_hist,
	specimen_part,
	cataloged_item,
	identification,
	collecting_event,
	locality,
	geog_auth_rec,
	accepted_lat_long,
	collection,
	coll_object_remark
WHERE
	ala_plant_imaging.barcode = container.barcode AND
	container.container_id = thePart.parent_container_id AND
	thePart.container_id = coll_obj_cont_hist.container_id AND
	coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id and
	specimen_part.derived_from_cat_item = cataloged_item.collection_object_id AND
	cataloged_item.collection_object_id = identification.collection_object_id AND
	identification.accepted_id_fg = 1 AND
	cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
	collecting_event.locality_id = locality.locality_id AND
	locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
	locality.locality_id = accepted_lat_long.locality_id (+) AND
	cataloged_item.collection_id = collection.collection_id AND
	cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
	ala_plant_imaging.status IN ('loaded_containerized','pre_existing_containerized') AND
	MB_STATUS is null
</cfquery>
<cfset header = '"ImageFileName","GUID","collection","cat_num","ALA_Number","collectors","scientific_name","higher_geog","spec_locality","dec_lat","dec_long","meter_coordinate_imprecision","verbatim_date","remarks"'>
<cfset theFile = "#webDirectory#/ALA_Imaging/data/#dateformat(now(),"yyyymmdd")#_ala_data.txt">
<cffile action="write" file="#theFile#" addnewline="no" output="#header#">

<cfloop query="d">
	<cffile action="append" file="#theFile#" addnewline="yes" output="#theCvsString#">
</cfloop>

<cfquery name="sentem" datasource="#uam_dbo#">
	update ala_plant_imaging set MB_STATUS=2 where
	status IN ('loaded_containerized','pre_existing_containerized') AND
	MB_STATUS is null	
</cfquery>
<cfcatch>
	<!--- kill the file so it doesn't go anywhere--->
	<cffile action="delete" file="#theFile#" >
</cfcatch>
</cftry>
</cftransaction>
<cfftp action="open" username="morphbank1" password="halWydsik4" server="morphbank4.csit.fsu.edu" connection="mb" passive="yes">
	<cfftp connection="mb" action="changedir"  directory="alaska/data">
	<cfftp connection="mb" action="putfile" localfile="#theFile#" remotefile="#dateformat(now(),"yyyymmdd")#_ala_data.txt" name="put_data">
	<cfftp connection="mb" action="close">
</cfoutput>