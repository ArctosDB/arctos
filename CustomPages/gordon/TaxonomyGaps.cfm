<cfoutput>
<cfquery name="md" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 select taxon_name_id, scientific_name, phylclass, phylorder, family, genus from taxonomy where
 phylclass is null or phylorder is null or family is null order by scientific_name
</cfquery>
<table border>
	<tr>
		<td>Scientific Name</td>
		<td>Class</td>
		<td>Order</td>
		<td>Family</td>
		<td>Genus</td>
	</tr>
	<cfloop query="md">
		<tr>
			
			<td>
			<a href="http://arctos.database.museum/Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#">#scientific_name#</a>
			</td>
			<td>#phylclass#</td>
			<td>#phylorder#</td>
			<td>#family#</td>
			<td>#genus#</td>
		</tr>
	</cfloop>
</table>
</cfoutput>