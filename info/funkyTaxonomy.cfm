<cfinclude template = "/includes/_header.cfm">
<cfoutput>
<cfset diff_term="nomenclatural_code">
<cfset src_term="Asilini"">

results for source_term=#src_term#, differences in #diff_term#
<cfquery name="f" datasource="uam_god">
	select distinct
		scientific_name,
		term
	from
		taxon_term,
		taxon_name
	where
		taxon_term.taxon_name_id=taxon_name.taxon_name_id and
		term_type='#diff_term#' and
		source='Arctos' and
		taxon_term.taxon_name_id in (
			select taxon_name_id from taxon_term where term='#src_term#' and source='Arctos'
		)
	order by term,scientific_name;
</cfquery>
<table border>
	<tr>
		<th>ScientificName</th>
		<th>#diff_term#</th>
	</tr>

<cfloop query="f">
	<tr>
		<td>#scientific_name#</td>
		<td>#term#</td>
	</tr>
</cfloop>

</table>
</cfoutput>
<cfinclude template = "/includes/_footer.cfm">
