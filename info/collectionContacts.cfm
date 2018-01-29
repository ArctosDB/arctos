<cfinclude template="/includes/_header.cfm">
	<cfquery name="c" datasource="uam_god">
		select guid_prefix, collection_id from collection order by guid_prefix
	</cfquery>
	<cfoutput>
	<table border>
		<tr>
			<th>Collection</th>
		</tr>
		<cfloop query="c">
			<tr>
				<td>
					#c.guid_prefix#
				</td>
			</tr>
		</cfloop>
	</table>
	</cfoutput>
<cfinclude template="/includes/_footer.cfm">
