<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	<cfoutput>
		Note: This form will return a maximum of 5,000 records.
		<br><a href="TaxonomyGaps.cfm?action=gap">NULL class, order, or family</a>
	</cfoutput>
</cfif>
<cfif action is "funkyChar">
	<cfoutput>
		<cfquery name="md" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			 select taxon_name_id, scientific_name from taxonomy where
			 	regexp_like(regexp_replace(scientific_name, ' var. ', ''), '[^A-Za-z ]')
				and regexp_like(regexp_replace(scientific_name, ' subsp. ', ''), '[^A-Za-z ]')
				and regexp_like(regexp_replace(scientific_name, ' subvar. ', ''), '[^A-Za-z ]')
				and rownum < 5000
				order by scientific_name
		</cfquery>
		<table border>
			<tr>
				<td>Scientific Name</td>
			</tr>
			<cfloop query="md">
				<tr>
					<td>
					<a href="#Application.ServerRootUrl#/Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#">#scientific_name#</a>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfif action is "gap">
	<cfoutput>
		<cfquery name="md" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			 select taxon_name_id, scientific_name, phylclass, phylorder, family from taxonomy where
			 (phylclass is null or phylorder is null or family is null)
			and rownum < 5000
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
</cfif>
<cfinclude template="/includes/_footer.cfm">