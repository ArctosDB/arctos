
<cfquery name="h" datasource="#Application.uam_dbo#">
	select * from container_history where parent_container_id=41301
</cfquery>
<cfoutput>
<table border>
	<tr>
		<td>Container Label</td>
		<td>Previous Parent Label</td>
	</tr>
	<cfloop query="h">
		<cfquery name="oh" datasource="#Application.uam_dbo#">
			select * from container_history where container_id= #container_id#
			order by container_id
		</cfquery>
		<cfloop query="oh">
			<cfif #parent_container_id# is not "41301">
				<cfquery name="c" datasource="#Application.uam_dbo#">
					select * from container where container_id=#container_id#
				</cfquery>
				<cfquery name="p" datasource="#Application.uam_dbo#">
					select * from container where container_id=#parent_container_id#
				</cfquery>
				<tr>
					<td>#c.label#</td>
					<td>#p.label#</td>
				</tr>
			</cfif>
		</cfloop>
	</cfloop>
	</table>
</cfoutput>