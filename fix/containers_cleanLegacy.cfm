<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfloop from="1" to="10" index="i">
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
		<hr>
</cfloop>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
