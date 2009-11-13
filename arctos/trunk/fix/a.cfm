<cfoutput>
	<cfquery name="pt" datasource="uam_god">
		select 
			publication_type,
			count(*) c,
			IS_PEER_REVIEWED_FG
		from 
			publication 
		group by publication_type,IS_PEER_REVIEWED_FG 
		order by publication_type,IS_PEER_REVIEWED_FG
	</cfquery>
	<table border id="pubTotals">
		<tr>
			<th>Publication Type</th>
			<th>Count</th>
			<th>Percent Peer Reviewed</th>
		</tr>
		<cfloop query="pt">
			<cfquery name="t" dbtype="query">
				select count(*) cnt from pt where IS_PEER_REVIEWED_FG=1 and publication_type='#publication_type#'
			</cfquery>
			<cfset ppr=pt.c/t.cnt>
			<tr>
				<td>#publication_type#</td>
				<td>#pubs_of_type#</td>
				<td>#ppr#</td>
			</tr>
		</cfloop>
	</table>


<cfquery name="total_projects" datasource="uam_god">
	select count(*) total_projects from project
</cfquery>

<cfquery name="total_items_loaned" datasource="uam_god">
	select count(*) total_items_loaned from loan_item
</cfquery>
<cfquery name="ppr" datasource="uam_god">
	select decode(IS_PEER_REVIEWED_FG,0,'no','yes') IS_PEER_REVIEWED_FG, count(*) pubs_of_type from publication group by IS_PEER_REVIEWED_FG order by IS_PEER_REVIEWED_FG
</cfquery>
<table border id="pubTotals">
	<tr>
		<th>Peer Reviewed?</th>
		<th>Count</th>
	</tr>
	<cfloop query="ppr">
		<tr>
			<td>#IS_PEER_REVIEWED_FG#</td>
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
		<cfset numLoaned=0>
		<cfif loaned.tot gt 0>
			<cfset numLoaned=loaned.tot>
		</cfif>
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
			
			<td>#numLoaned#</td>
			<td>#cited.tot#</td>
			<cfset cr="">
			<cfif numLoaned is 0 and cited.tot is 0>
				<cfset cr=0>
			<cfelseif numLoaned gte cited.tot and numLoaned gt 0>
				<cfset cr=cited.tot/numLoaned>
			</cfif>
			<td>#cr#</td>
		</tr>
	</cfloop>
	</table>
</cfoutput>