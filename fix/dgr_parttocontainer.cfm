
<cfoutput>
	<cfquery name="d" datasource="uam_god">
		select * from dgr_locator where freezer='#f#' and rack='#r#' and box='#b#'
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
				tube.label='NK #d.nk# #d.tissue_type#'
		</cfquery>
		<cfdump var=#fTube#>


	</cfloop>

</cfoutput>

