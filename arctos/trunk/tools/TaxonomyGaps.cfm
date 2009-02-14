<cfinclude template="/includes/_header.cfm">
 <cfoutput>
Note: This form will return a maximum of 10,000 records.
<cfquery name="md" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 select taxon_name_id, scientific_name, phylclass, phylorder, family from taxonomy where
 phylclass is null or phylorder is null or family is null 
and rownum < 10000
order by scientific_name
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
			<a href="#Application.ServerRootUrl#/Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#">#scientific_name#</a>
			</td>
			<td>#phylclass#</td>
			<td>#phylorder#</td>
			<td>#family#</td>
		</tr>
	</cfloop>
</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">