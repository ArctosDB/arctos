<cfquery name="s" datasource="#Application.uam_dbo#">
	 select * from specimen_part where
	  collection_object_id not in 
	  (select collection_object_id from coll_obj_cont_hist)
</cfquery>
<cfoutput>

	<cfloop query="s">
		<cfquery name="con" datasource="#Application.uam_dbo#">
			select max(container_id) + 1 con from container
		</cfquery>
		<cfquery name="lbl" datasource="#Application.uam_dbo#">
			select collection,institution_acronym from collection,cataloged_item
			where collection.collection_id = cataloged_item.collection_id and
			cataloged_item.collection_object_id=#derived_from_cat_item#
		</cfquery>
		
		<cfquery name="nc" datasource="#Application.uam_dbo#">
			insert into container (
				CONTAINER_ID,
				PARENT_CONTAINER_ID,
				CONTAINER_TYPE,
				LABEL,
				LOCKED_POSITION,
				INSTITUTION_ACRONYM
			) values (
				#con.con#,
				0,
				'collection object',
				'#lbl.collection# #part_name#',
				0,
				'#lbl.institution_acronym#'
			)
		</cfquery>
		<cfquery name="link" datasource="#Application.uam_dbo#">
			insert into  coll_obj_cont_hist (
				COLLECTION_OBJECT_ID,
				CONTAINER_ID,
				INSTALLED_DATE,
				CURRENT_CONTAINER_FG
			) values (
				#collection_object_id#,
				#con.con#,
				sysdate,
				1
			)
		</cfquery>
	</cfloop>

</cfoutput>