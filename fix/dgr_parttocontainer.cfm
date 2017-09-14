
<cfoutput>

	<!-----

			connect to prod from test

			spooky!!

			change plz

		----->


	<cfquery name="d" datasource="prod">
		select * from temp_dgrloc where freezer='#f#' and rack='#r#' and box='#b#'
	</cfquery>
	<cfloop query="d">
		<cfquery name="fTube" datasource="uam_god">
			select
				tube.container_id
			 from
			 	container box,
			 	container position,
			 	container tube
			 where
				box.container_id=position.parent_container_id and
				position.container_id=tube.parent_container_id and
				box.label='DGR-#d.freezer#-#d.rack#-#d.box#' and
				tube.label='NK #d.nk# #d.tissue_type#' and
				position.label='#d.place#'
		</cfquery>
		<cfdump var=#fTube#>


		<cfquery name="part" datasource="uam_god">
			select
				specimen_part.collection_object_id,
				specimen_part.part_name,
				guid,
				pc.parent_container_id
			from
				flat,
				coll_obj_other_id_num,
				specimen_part,
				coll_obj_cont_hist,
				container pc
			where
				flat.collection_object_id=coll_obj_other_id_num.collection_object_id and
				flat.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=pc.container_id and
				coll_obj_other_id_num.other_id_type='NK' and
				coll_obj_other_id_num.display_value='#d.nk#' and
				trim(replace(specimen_part.part_name,'(frozen)'))=lower(trim('#d.cpart#'))


		</cfquery>
		<cfdump var=#part#>
	</cfloop>

</cfoutput>

