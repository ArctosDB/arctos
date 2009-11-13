<cfoutput>
	<cfquery name="pt" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			publication_type,
			count(*) c
		from 
			publication 
		group by publication_type 
		order by publication_type
	</cfquery>
	<table border id="pubTotals">
		<tr>
			<th>Publication Type</th>
			<th>Count</th>
			<th>Percent Peer Reviewed</th>
			<th>Citations</th>
		</tr>
		<cfloop query="pt">
			<cfquery name="t" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
				select count(*) cnt from publication where IS_PEER_REVIEWED_FG=1 and publication_type='#publication_type#'
			</cfquery>
			<cfquery name="ctn" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
				select count(*) cnt from publication,citation where 
				publication.publication_id=citation.publication_id and
				publication_type='#publication_type#'
			</cfquery>
			<cfset ppr=t.cnt/pt.c * 100>
			<tr>
				<td>#publication_type#</td>
				<td>#c#</td>
				<td>#ppr#</td>
				<td>#ctn.cnt#</td>
			</tr>
		</cfloop>
	</table>
	<cfquery name="total_projects" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select count(*) c from project
	</cfquery>
	<cfquery name="accn_projects" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			count(distinct(project.project_id)) c
		from 
			project,
			project_trans,
			accn
		where 
			project.project_id=project_trans.project_id and
			project_trans.transaction_id=accn.transaction_id and
			project_trans.transaction_id not in (select transaction_id from loan)
	</cfquery>
	<cfquery name="loan_projects" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			count(distinct(project.project_id)) c
		from 
			project,
			project_trans,
			loan
		where 
			project.project_id=project_trans.project_id and
			project_trans.transaction_id=loan.transaction_id and
			project_trans.transaction_id not in (select transaction_id from accn)
	</cfquery>
	<cfquery name="both_projects" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			count(distinct(project.project_id)) c
		from 
			project,
			project_trans tl,
			project_trans ta,
			loan,
			accn
		where 
			project.project_id=tl.project_id and
			tl.transaction_id=loan.transaction_id and
			project.project_id=ta.project_id and
			ta.transaction_id=accn.transaction_id
	</cfquery>
	<cfquery name="neither_projects" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			count(distinct(project.project_id)) c
		from 
			project
		where 
			project_id not in (select project_id from project_trans)
	</cfquery>
	<table border>
		<tr>
			<th>Total</th>
			<th>Using</th>
			<th>Contributing </th>
			<th>Both</th>
			<th>Neither</th>
		</tr>
		<tr>
			<td>#total_projects.c#</td>
			<td>#accn_projects.c#</td>
			<td>#loan_projects.c#</td>
			<td>#both_projects.c#</td>
			<td>#neither_projects.c#</td>
		</tr>
	</table>
<cfset x=accn_projects.c + loan_projects.c + both_projects.c +neither_projects.c>
x: #x# 



<cfabort>
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