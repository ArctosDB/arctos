
<cfoutput>

	<!-----

			connect to prod from test

			spooky!!

			change plz

		----->


	<cfquery name="d" datasource="prod">
		select * from temp_dgrloc where freezer='#f#' and rack='#r#' and box='#b#'
	</cfquery>

	<!---
		this should match a DGR box
		we should not have yet processed that box
	--->

	<cfquery name="dgrbox" datasource="uam_god">
		select * from container where label='DGR-#d.freezer#-#d.rack#-#d.box#'
	</cfquery>

	<cfif dgrbox.recordcount is not 1>
		<cfquery name="ss" datasource="uam_god">
			update temp_dgrbox set status=status || 'box_not_found|#dgrbox.recordcount#' where box='#d.box#' and rack='#d.rack#' and freezer='#d.freezer#'
		</cfquery>
		dgrbox not found<cfabort>
	</cfif>
	<cfif dgrbox.container_remarks contains 'attempted specimen match'>
		<cfquery name="ss" datasource="uam_god">
			update temp_dgrbox set status=status || 'box_already_processed' where box='#d.box#' and rack='#d.rack#' and freezer='#d.freezer#'
		</cfquery>
		box has already been processed<cfabort>
	</cfif>
	<cftransaction>
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

		<cfquery name="part" datasource="uam_god">
			select
				specimen_part.collection_object_id,
				specimen_part.part_name,
				guid,
				pc.parent_container_id,
				pc.container_id
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

		<cfset contRemStatus=''>
		<cfif part.recordcount is 0>
			<cfset contRemStatus='#dateformat(now,"yyyy-mm-dd")#|part_not_found'>
		<cfelseif part.recordcount is 1>
			<cfif part.parent_container_id is 0 or len(part.parent_containerid) is 0>
				<cfset contRemStatus='#dateformat(now,"yyyy-mm-dd")#|part_auto_inserted'>
				<!--- and move the part-container --->
				<cfquery name="part2container" datasource="uam_god">
					update container set parent_container_id=#fTube.container_id# where container_id=#part.container_id#
				</cfquery>
			<cfelse>
				<cfset contRemStatus='#dateformat(now,"yyyy-mm-dd")#|part_found_in_container|container_id=#part.parent_container_id#'>
			</cfif>
		<cfelse>
			<!--- one specimen?? --->
			<cfquery name="dspec" dbtype='query'>
				select guid from part group by guid
			</cfquery>
			<cfif dspec.recordcount is 1>
				<cfset contRemStatus='#dateformat(now,"yyyy-mm-dd")#|multiple_part_match|guid=#dspec.guid#'>
			<cfelse>
				<cfset contRemStatus='#dateformat(now,"yyyy-mm-dd")#|multiple_specimen_match|guidlist=#valuelist(dspec.guid)#'>
			</cfif>
		</cfif>

		<cfquery name="uppartc" datasource="uam_god">
			update container set CONTAINER_REMARKS=CONTAINER_REMARKS || ';1|#contRemStatus#'
			where container_id=#fTube.container_id#
		</cfquery>
	</cfloop>


	<cfquery name="markComplete" datasource="uam_god">
			update container set CONTAINER_REMARKS=CONTAINER_REMARKS || '; #dateformat(now,"yyyy-mm-dd")# |attempted_specimen_match1' where
			container_id=#dgrbox.container_id#
	</cfquery>
	<cfquery name="ss" datasource="uam_god">
		update temp_dgrbox set status=status || 'attempted_specimen_match' where box='#d.box#' and rack='#d.rack#' and freezer='#d.freezer#'
	</cfquery>
	</cftransaction>
</cfoutput>

