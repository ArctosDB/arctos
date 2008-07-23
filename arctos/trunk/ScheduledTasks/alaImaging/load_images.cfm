<cfoutput>
<cfinclude template="/Application.cfm">
<cfdirectory 
   action = "list"
	filter ="*.dng"
   directory = "/var/www/html/image_dump"
   name = "images">
<cftry>
<cftransaction>
<cfloop query="images">
	name:#name#--<br>
	<cfset theBarcode = replace(name,".dng","","all")>
	theBarcode:#theBarcode#--<br>

	<cfquery name="getID" datasource="#uam_dbo#">
		select derived_from_cat_item FROM 
		  container, 
		  container pc, 
		  coll_obj_cont_hist, 
		  specimen_part
		   WHERE 
		   container.parent_container_id = pc.container_id AND
		   container.container_id = coll_obj_cont_hist.container_id AND 
		   coll_obj_cont_hist.collection_object_id = specimen_part.collection_object_id AND 
		   pc.barcode='#theBarcode#'
	</cfquery>
	
	
		   
		   
	<cfquery name="catitem" datasource="#uam_dbo#">
		select cat_num, collection,collection.collection_cde,collection.institution_acronym from cataloged_item,collection
		where cataloged_item.collection_id = collection.collection_id and
		cataloged_item.collection_object_id=#getID.derived_from_cat_item#
	</cfquery>
	
	
	<cfquery name="img" datasource="#uam_dbo#">
		select * from ala_plant_imaging where barcode='#theBarcode#'
	</cfquery>
	<cfquery name="w" datasource="#uam_dbo#">
		select agent_id from agent_name where agent_name_type='login' and agent_name='#img.whodunit#'
	</cfquery>
	<cfquery name="ncid" datasource="#uam_dbo#">
		select max(collection_object_id) + 1 collection_object_id from coll_object	
	</cfquery>
	
	<cfset loadPath = "#webDirectory#/SpecimenImages/#catitem.institution_acronym#/#catitem.collection_cde#/#catitem.cat_num#/">
	<cftry>
		<cfdirectory action="create" directory="#loadPath#">
	<cfcatch><!--- already exists, probably ----></cfcatch>
	</cftry>
	<cffile 
	   action = "move"
	   source = "/var/www/html/image_dump/#theBarcode#.dng"
	   destination = "#loadPath#/#theBarcode#.dng">
	  <cfquery name="mkC" datasource="#uam_dbo#">
	   INSERT INTO coll_object (
			collection_object_id,
			coll_object_type,
			ENTERED_PERSON_ID,
			COLL_OBJECT_ENTERED_DATE,
			LAST_EDITED_PERSON_ID,
			COLL_OBJ_DISPOSITION,
			LOT_COUNT,
			CONDITION,
			FLAGS )
		VALUES (
			#ncid.collection_object_id#,
			'IO',
			#w.agent_id#,
			to_date('#dateformat(img.whendunit,"dd-mmm-yyyy")#'),
			NULL,
			'not applicable',
			1,
			'not applicable',
			NULL )
	</cfquery>
	<cfquery name="ins" datasource="#uam_dbo#">
	INSERT INTO binary_object (
		COLLECTION_OBJECT_ID,
		VIEWER_ID,
		DERIVED_FROM_CAT_ITEM,
		MADE_DATE,
		SUBJECT,
		FULL_URL,
		MADE_AGENT_ID)
	values (
		#ncid.collection_object_id#,
		3,
		#getID.derived_from_cat_item#,
		to_date('#dateformat(img.whendunit,"dd-mmm-yyyy")#'),
		'#catitem.collection# #catitem.cat_num#',
		'http://arctos.database.museum/SpecimenImages/#catitem.institution_acronym#/#catitem.collection_cde#/#catitem.cat_num#/#theBarcode#.dng',
		#w.agent_id#
		)
		</cfquery>
</cfloop>
</cftransaction>
<cfcatch >
		<cfmail to="dustymc@gmail.com" from="image_loader@#Application.fromEmail#" subject="ALA ImagLoader Croaked" type="html">
			well it did.
		</cfmail>
</cfcatch>
</cftry>
</cfoutput>
