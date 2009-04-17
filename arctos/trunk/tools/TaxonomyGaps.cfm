<cfinclude template="/includes/_header.cfm">
<cfif action is "nothing">
	<cfoutput>
		Note: This form will return a maximum of 5,000 records.
		<br><a href="TaxonomyGaps.cfm?action=gap">NULL class, order, or family</a>
		<br><a href="TaxonomyGaps.cfm?action=funkyChar">scientific name contains funky characters</a>
	</cfoutput>
</cfif>
<cfif action is "funkyChar">
	<cfoutput>
		<cfquery name="md" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
				taxonomy.taxon_name_id,
				scientific_name, 
				regexp_replace(scientific_name, '[^a-zA-Z ]','X') craps,
				count(identification_taxonomy.identification_id) used
			from 
				taxonomy,
				identification_taxonomy
			where 
				taxonomy.taxon_name_id=identification_taxonomy.taxon_name_id (+) and
				regexp_like(regexp_replace(regexp_replace(scientific_name, ' var. ', ''),'[a-z]-[a-z]',''), '[^A-Za-z ]') and 
				regexp_like(regexp_replace(regexp_replace(scientific_name, ' subsp. ', ''),'[a-z]-[a-z]',''), '[^A-Za-z ]') and 
				regexp_like(regexp_replace(regexp_replace(scientific_name, ' subvar. ', ''),'[a-z]-[a-z]',''), '[^A-Za-z ]') and 
				regexp_like(regexp_replace(regexp_replace(scientific_name, ' &##215; ', ''),'[a-z]-[a-z]',''), '[^A-Za-z ]') and 
				rownum < 5000
			group by
				taxonomy.taxon_name_id,
				scientific_name
			order by scientific_name
		</cfquery>
		<table border>
			<tr>
				<td>Scientific Name</td>
				<td>X for bad char</td>
				<td>NumIds</td>
			</tr>
			<cfloop query="md">
				<tr>
					<td>
					<a href="#Application.ServerRootUrl#/Taxonomy.cfm?Action=edit&taxon_name_id=#taxon_name_id#">#scientific_name#</a>
					</td>
					<td>#craps#</td>
					<td>#used#</td>
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