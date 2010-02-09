<cfoutput>
<cfquery name="p" datasource="uam_god">
		select status,count(*) cnt from ala_plant_imaging 
		group by status
	UNION
		select 'stuck_in_bulk' status, count(*) cnt from bulkloader where loaded is not null and collection_cde='Herb' and 
			collection_object_id > 50
			group by 'stuck_in_bulk'
</cfquery>
<!---

--->
<cfmail to="ALA_Imaging@googlegroups.com" from="ala_data_checker@#Application.fromEmail#" subject="ALA Imaging Data Problems" type="html">
	Problems with HTML email? Read this at the ALA Imaging Group web site:
	<br>
	http://groups.google.com/group/ALA_Imaging
	<br>
	ALA Plant Data Status:
	<table border>
		<tr>
			<td>Status</td>
			<td>Count</td>
		</tr>
	<cfloop query="p">
		<cfif #status# is "stuck_in_bulk">
			<tr>
				<td><a href="#Application.ServerRootUrl#/Bulkloader/bulkloader_status.cfm">#status#</a></td>
				<td>#cnt#</td>
			</tr>
		<cfelse>
			<cfif #cnt# lte 999>
				<cfquery name="link" datasource="uam_god">
					select image_id from ala_plant_imaging where status='#status#'
				</cfquery>
				<tr>
					<td><a href="#Application.ServerRootUrl#/ALA_Imaging/ala_edit.cfm?action=findem&image_id_list=#valuelist(link.image_id)#">#status#</a></td>
					<td>#cnt#</td>
				</tr>
			<cfelse>
				<tr>
					<td>#status#</td>
					<td>#cnt#</td>
				</tr>
			</cfif>
		</cfif>
	</cfloop>
	</table>
	</cfmail>
	<!---

--->
</cfoutput>
