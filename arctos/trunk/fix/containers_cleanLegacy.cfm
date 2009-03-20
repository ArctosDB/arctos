<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfloop from="1" to="1" index="i">
		<cfquery name="data" datasource="uam_god">
			select * from container where container_id in (
				select min(container_id) container_id from container where
				container_type='legacy container' and barcode is null
			)
		</cfquery>
		Our container
		<cfdump var=#data#>
		<cfquery name="children" datasource="uam_god">
			select * from container where parent_container_id=#data.container_id#
		</cfquery>
		it's children
		<cfdump var=#children#>
		<cfquery name="parent" datasource="uam_god">
			select * from container where container_id=#data.parent_container_id#
		</cfquery>
		it's parent
		<cfdump var=#parent#>
		now we're going to update the children to have a parent of our container's parent and delete our container
		<cfloop query="children">
			<br>---------------<br>
			update container set parent_container_id=#parent.parent_container_id#
			where container_id=#container_id#
		</cfloop>
		<hr>
</cfloop>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
