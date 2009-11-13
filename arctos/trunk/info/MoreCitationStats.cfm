<cfinclude template="/includes/_header.cfm">
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
	
	<strong>Publications by type, reviewed status, and citations:</strong>
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
			project
		where
			project_id in (
				select project_id from project_trans,accn 
				where project_trans.transaction_id=accn.transaction_id)
			and project_id not in (
				select project_id from project_trans,loan 
				where project_trans.transaction_id=loan.transaction_id)
	</cfquery>
	<cfquery name="loan_projects" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			count(distinct(project.project_id)) c
		from 
			project
		where 
			project_id in (
				select project_id from project_trans,loan 
				where project_trans.transaction_id=loan.transaction_id)
			and project_id not in (
				select project_id from project_trans,accn 
				where project_trans.transaction_id=accn.transaction_id)
	</cfquery>
	<cfquery name="both_projects" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			count(distinct(project.project_id)) c
		from 
			project
		where
			project_id in (
				select project_id from project_trans,loan 
				where project_trans.transaction_id=loan.transaction_id)
			and project_id in (
				select project_id from project_trans,accn 
				where project_trans.transaction_id=accn.transaction_id)
	</cfquery>
	<cfquery name="neither_projects" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			count(distinct(project.project_id)) c
		from 
			project
		where 
			project_id not in (
				select project_id from project_trans,loan 
				where project_trans.transaction_id=loan.transaction_id)
			and project_id not in (
				select project_id from project_trans,accn 
				where project_trans.transaction_id=accn.transaction_id)
	</cfquery>
	<strong>Projects by activity:</strong>
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
			<td>#loan_projects.c#</td>
			<td>#accn_projects.c#</td>
			<td>#both_projects.c#</td>
			<td>#neither_projects.c#</td>
		</tr>
	</table>
	
	<cfquery name="loan_projects_res" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select 
			count(distinct(project.project_id)) c,
			count(distinct(project_publication.publication_id)) numPubs,
			count(distinct(citation.collection_object_id)) numCits,
			count(distinct(citation.publication_id)) numPubsWithCits
		from 
			project,
			project_publication,
			citation
		where 
			project.project_id in (
				select project_id from project_trans,loan 
				where project_trans.transaction_id=loan.transaction_id)
			and project.project_id not in (
				select project_id from project_trans,accn 
				where project_trans.transaction_id=accn.transaction_id)
			and project.project_id = project_publication.project_id (+)
			and project_publication.publication_id = citation.publication_id (+)
	</cfquery>
	<strong>Results of projects which borrow specimens:</strong>
	<table border>
		<tr>
			<th>Total Borrow Projects</th>
			<th>Number Pubs Produced</th>
			<th>Number Pubs that Cite</th>
			<th>Number Cites</th>
		</tr>
		<tr>
			<td>#loan_projects_res.c#</td>
			<td>#loan_projects_res.numPubs#</td>
			<td>#loan_projects_res.numPubsWithCits#</td>
			<td>#loan_projects_res.numCits#</td>
		</tr>
	</table>
	<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select collection,collection_id from collection order by collection
	</cfquery>
	<strong>Usage and results by collection:</strong>
	<table border>
		<tr>
			<th>Collection</th>
			<th>Items Loaned</th>
			<th>Items Cited</th>
			<th>Citations/Loaned Item</th>
		</tr>
	<cfloop query="c">
		<cfquery name="loaned" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
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
		<cfquery name="cited" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
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
<cfinclude template="/includes/_footer.cfm">