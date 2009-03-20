<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfloop from="1" to="1" index="i">
		<cftransaction>
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
				<cfif len(parent.container_id) gt 0>
					--- our container has a parent, so....
					<br>
					update container set parent_container_id=#parent.container_id#
					where container_id=#container_id#
					<cfquery name="kill" datasource="uam_god">
						update container set parent_container_id=#parent.container_id#
						where container_id=#container_id#
					</cfquery>
				<cfelse>
					--- our container has no parent, so update the children to null
					update container set parent_container_id=null
					where container_id=#container_id#
					<cfquery name="kill" datasource="uam_god">
						update container set parent_container_id=null
						where container_id=#container_id#
					</cfquery>
				</Cfif>
			</cfloop>
			<hr>
		</cftransaction>
	</cfloop>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
