<cfinclude template="/includes/_header.cfm">
<cfset title="part usage">
	<script src="/includes/sorttable.js"></script>
<cfoutput>

<cfquery name="p" datasource="uam_god">
	select
		collection.collection, 
		collection.collection_id, 
		specimen_part.part_name,
		count(distinct(cataloged_item.collection_object_id)) cnt,
		ctspecimen_part_name.is_tissue
	from
		specimen_part,
		ctspecimen_part_name,
		cataloged_item,
		collection
	where
		specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
		specimen_part.part_name=ctspecimen_part_name.part_name and
		cataloged_item.collection_id=collection.collection_id 
	group by
		collection.collection, 
		collection.collection_id, 
		specimen_part.part_name,
		ctspecimen_part_name.is_tissue
	order by specimen_part.part_name
</cfquery>
<cfdump var=#p#>
<cfquery name="dp" dbtype="query">
	select part_name from p group by part_name
</cfquery>
<table border id="t" class="sortable">
	<tr>
		<th>Part</th>
		<th>isTissue</th>
		<th>##</th>
		<th>UsedByCollections</th>
	</tr>
	<cfloop query="dp">
		<cfquery name="cp" dbtype="query">
			select * from p where part_name='#part_name#'
		</cfquery>
		<cfquery name="it" dbtype="query">
			select is_tissue from cp group by is_tissue
		</cfquery>
		<cfif it.recordcount gt 0>
			<cfset tiss='y/n'>
		<cfelseif it.is_tissue is 1>
			<cfset tiss='y'>
		<cfelseif it.is_tissue is 0>
			<cfset tiss='n'>
		<cfelse>
			<cfset tiss='?'>
		</cfif>
		<cfquery name="tc" dbtype="query">
			select sum(cnt) sc from p where part_name='#part_name#'
		</cfquery>
		<tr>
			<td>#part_name#</td>
			<td>#tiss#</td>
			<td>#tc.sc#</td>
			<td>
				<cfloop query="cp">
					<br><a href="/SpecimenResults.cfm?collection_id=#collection_id#&part_name==#part_name#">#collection#: #cnt#</a>
				</cfloop>
			</td>
		</tr>
	</cfloop>
</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
