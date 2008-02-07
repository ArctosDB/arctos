<cfinclude template="/includes/_header.cfm">
 <cfoutput>
<cfquery name="md" datasource="#Application.web_user#">
 select taxon_name_id, scientific_name, phylclass, phylorder, family from taxonomy where
 phylclass is null or phylorder is null or family is null order by scientific_name
</cfquery>
<table border>
	<tr>
		<td>Scientific Name</td>
		<td>Class</td>
		<td>Order</td>
		<td>Family</td>
	</tr>
	<cfloop query="md">
		<tr>
			
			<td>
			<a href="#Application.ServerRootUrl#/Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#" target="#client.target#">#scientific_name#</a>
			</td>
			<td>#phylclass#</td>
			<td>#phylorder#</td>
			<td>#family#</td>
		</tr>
	</cfloop>
</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">