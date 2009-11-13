
<cfquery name="total_projects" datasource="uam_god">
	select count(*) total_projects from project
</cfquery>
<cfquery name="total_pubs" datasource="uam_god">
	select count(*) total_pubs from publication
</cfquery>
<cfquery name="publication_type" datasource="uam_god">
	select publication_type,count(*) pubs_of_type from publication group by publication_type order by publication_type
</cfquery>
<cfquery name="total_items_loaned" datasource="uam_god">
	select count(*) total_items_loaned from loan_item
</cfquery>
<cfoutput>
<label for="pubTotals">Total Publications in Arctos</label>
<table border id="pubTotals">
	<tr>
		<th>Publication Type</th>
		<th>Count</th>
	</tr>
	<cfloop query="publication_type">
		<tr>
			<td>#publication_type#</td>
			<td>#pubs_of_type#</td>
		</tr>
	</cfloop>
</table>

<cfquery name="c" datasource="uam_god">
	select collection,collection_id from collection order by collection
</cfquery>
	<table border>
		<tr>
			<th>Collection</th>
			<th>Items Loaned</th>
			<th>Items Cited</th>
			<th>Citations/Loaned Item</th>
		</tr>
	<cfloop query="c">
		<cfquery name="loaned" datasource="uam_god">
			select 
				decode(sum(items_loaned_by_collection),
					null,0,
					sum(items_loaned_by_collection)	tot
			from (
				select 
					collection,
					count(*) items_loaned_by_collection
				from
					collection,
					cataloged_item,
					specimen_part,
					loan_item
				where
					collection.collection_id=cataloged_item.collection_id and
					cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
					specimen_part.collection_object_id=loan_item.collection_object_id and
					collection.collection_id=#collection_id#
				group by collection
				union
				select 
					collection,
					count(*) items_loaned_by_collection
				from
					collection,
					cataloged_item,
					loan_item
				where
					collection.collection_id=cataloged_item.collection_id and
					cataloged_item.collection_object_id=loan_item.collection_object_id and
					collection.collection_id=#collection_id#
				group by collection
				)
			 group by collection
		</cfquery>
		<cfquery name="cited" datasource="uam_god">
			select 
				count(*) tot
			from 
				citation,
				cataloged_item
			where
				citation.collection_object_id=cataloged_item.collection_object_id and
				cataloged_item.collection_id=#collection_id#
		</cfquery>
		<tr>
			<td>#collection#</td>
			<td>#loaned.tot#</td>
			<td>#cited.tot#</td>
			<cfset cr=cited.tot/loaned.tot>
			<td>#cr#</td>
		</tr>
	</cfloop>
	</table>
</cfoutput>