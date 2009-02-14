<cfquery name="p" datasource="#Application.uam_dbo#">
	select part_name,part_modifier,preserve_method
	from specimen_part
	group by
	part_name,part_modifier,preserve_method
</cfquery>
<cfoutput>
	<table border>
		<cfloop query="p">
			<tr>
				<td>#part_name#</td>
				<td>#part_modifier#</td>
				<td>#preserve_method#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>