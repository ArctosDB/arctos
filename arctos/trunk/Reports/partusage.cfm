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
<cfquery name="dp" dbtype="query">
	select part_name from p group by part_name
</cfquery>
<table border id="t" class="sortable">
	<tr>
		<th>Part</th>
		<th>isTissue</th>
		<th>sum</th>
		<th>UsedByCollections</th>
	</tr>
	<cfloop query="dp">
		<cfquery name="cp" dbtype="query">
			select collection,collection_id,cnt from p where part_name='#dp.part_name#' group by collection,collection_id,cnt
		</cfquery>
		<cfquery name="it" dbtype="query">
			select is_tissue from p where part_name='#dp.part_name#' group by is_tissue
		</cfquery>
		<cfif it.recordcount gt 1>
			<cfset tiss='sometimes'>
		<cfelseif it.is_tissue is 1>
			<cfset tiss='yes'>
		<cfelseif it.is_tissue is 0>
			<cfset tiss='no'>
		<cfelse>
			<cfset tiss='FAIL'>
		</cfif>
		<cfquery name="tc" dbtype="query">
			select sum(cnt) sc from cp
		</cfquery>
		<tr>
			<td>#part_name#</td>
			<td>#tiss#</td>
			<td>#tc.sc#</td>
			<td>
				<cfloop query="cp">
					<a href="/SpecimenResults.cfm?collection_id=#collection_id#&part_name==#dp.part_name#">#collection#: #cnt#</a><br>
				</cfloop>
			</td>
		</tr>
	</cfloop>
</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
