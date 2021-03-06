<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
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
	<table border="1" id="a" class="sortable">
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
	<p>&nbsp;</p>
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
				select project_id from project_trans,cataloged_item
				where project_trans.transaction_id=cataloged_item.accn_id)
			and project_id not in (
				select project_id from project_trans,loan_item
				where project_trans.transaction_id=loan_item.transaction_id)
	</cfquery>
	<cfquery name="loan_projects" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			count(distinct(project.project_id)) c
		from
			project
		where
			project_id in (
				select project_id from project_trans,loan_item
				where project_trans.transaction_id=loan_item.transaction_id)
			and project_id not in (
				select project_id from project_trans,cataloged_item
				where project_trans.transaction_id=cataloged_item.accn_id)
	</cfquery>
	<cfquery name="both_projects" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			count(distinct(project.project_id)) c
		from
			project
		where
			project_id in (
				select project_id from project_trans,loan_item
				where project_trans.transaction_id=loan_item.transaction_id)
			and project_id in (
				select project_id from project_trans,cataloged_item
				where project_trans.transaction_id=cataloged_item.accn_id)
	</cfquery>
	<cfquery name="neither_projects" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			count(distinct(project.project_id)) c
		from
			project
		where
			project_id not in (
				select project_id from project_trans,loan_item
				where project_trans.transaction_id=loan_item.transaction_id)
			and project_id not in (
				select project_id from project_trans,cataloged_item
				where project_trans.transaction_id=cataloged_item.accn_id)
	</cfquery>
	<strong>Projects by activity:</strong>
	<table border="1" id="b" class="sortable">
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
	<p>&nbsp;</p>
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
				select project_id from project_trans,loan_item
				where project_trans.transaction_id=loan_item.transaction_id)
			and project.project_id not in (
				select project_id from project_trans,cataloged_item
				where project_trans.transaction_id=cataloged_item.accn_id)
			and project.project_id = project_publication.project_id (+)
			and project_publication.publication_id = citation.publication_id (+)
	</cfquery>
	<strong>Results of projects which borrow specimens:</strong>
	<table border="1" id="c" class="sortable">
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
	<p>&nbsp;</p>
	<cfquery name="c" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
		select
			guid_prefix,
			collection.collection_id,
			count(*) totSpec
		from
			collection,
			cataloged_item
		where
			collection.collection_id=cataloged_item.collection_id
		group by
			guid_prefix,
			collection.collection_id
		order by
			guid_prefix
	</cfquery>
	<strong>Usage and results by collection:</strong>
	<table border="1" id="d" class="sortable">
		<tr>
			<th>Collection</th>
			<th>Holdings</th>
			<th>%Loaned</th>
			<th>Specimens Loaned</th>
			<th>Items Loaned</th>
			<th>Specimens Cited</th>
			<th>Citations/Loaned Specimen</th>
		</tr>
		<cfquery name="loaned" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				count(collection_object_id) tot
			from
				loan_item
		</cfquery>
		<cfquery name="loanedSpec" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(distinct(collection_object_id)) tot from (
				select
					specimen_part.derived_from_cat_item collection_object_id
				from
					loan_item,
					specimen_part
				where
					loan_item.collection_object_id=specimen_part.collection_object_id
				UNION
				select
					cataloged_item.collection_object_id
				from
					loan_item,
					cataloged_item
				where
					loan_item.collection_object_id=cataloged_item.collection_object_id
				)
		</cfquery>
		<cfset numLoaned=0>
		<cfif loaned.tot gt 0>
			<cfset numLoaned=loaned.tot>
		</cfif>
		<cfquery name="cited" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				count(*) tot
			from
				citation
		</cfquery>
		<cfquery name="totHldf" dbtype="query">
			select sum(c.totSpec) grandtotal from c
		</cfquery>


		<cfset percentLoaned=decimalFormat((loanedSpec.tot/totHldf.grandtotal) * 100)>


		<tr>
			<td><strong>All Collections</strong></td>
			<td>#totHldf.grandtotal#</td>
			<td>#percentLoaned#</td>
			<td><strong>#loanedSpec.tot#</strong></td>
			<td><strong>#numLoaned#</strong></td>
			<td><strong>#cited.tot#</strong></td>
			<cfset cr="">
			<cfif numLoaned is 0 and cited.tot is 0>
				<cfset cr=0>
				<!----
			<cfelseif numLoaned gte cited.tot and numLoaned gt 0>
			---->
			<cfelse>
				<cfset cr=cited.tot/numLoaned>
			</cfif>
			<td><strong>#decimalFormat(cr)#</strong></td>
		</tr>
	<cfloop query="c">
		<cfquery name="loaned" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select
				sum(items_loaned_by_collection)	tot
			from (
				select
					guid_prefix,
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
				group by guid_prefix
				union
				select
					guid_prefix,
					count(*) items_loaned_by_collection
				from
					collection,
					cataloged_item,
					loan_item
				where
					collection.collection_id=cataloged_item.collection_id and
					cataloged_item.collection_object_id=loan_item.collection_object_id and
					collection.collection_id=#collection_id#
				group by guid_prefix
				)
			 group by guid_prefix
		</cfquery>
		<cfquery name="loanedSpec" datasource="uam_god" cachedwithin="#createtimespan(0,0,60,0)#">
			select count(distinct(collection_object_id)) tot from (
				select
					specimen_part.derived_from_cat_item collection_object_id
				from
					loan_item,
					specimen_part,
					cataloged_item
				where
					loan_item.collection_object_id=specimen_part.collection_object_id and
					specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
					cataloged_item.collection_id=#collection_id#
				UNION
				select
					cataloged_item.collection_object_id
				from
					loan_item,
					cataloged_item
				where
					loan_item.collection_object_id=cataloged_item.collection_object_id and
					cataloged_item.collection_id=#collection_id#
				)
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
			<td>#guid_prefix#</td>
			<td>#c.totSpec#</td>
			<cfif c.totSpec gt 0>
				<cfset percentLoaned=decimalFormat((loanedSpec.tot/c.totSpec) * 100)>
			<cfelse>
				<cfset percentLoaned='NULL'>
			</cfif>
			<td>#percentLoaned#</td>
			<td>#loanedSpec.tot#</td>
			<td>#numLoaned#</td>
			<td>#cited.tot#</td>
			<cfset cr="">
			<cfif numLoaned is 0 and cited.tot is 0>
				<cfset cr=0>
			<cfelseif numLoaned gte cited.tot and numLoaned gt 0>
				<cfset cr=cited.tot/numLoaned>
			</cfif>
			<td>#decimalFormat(cr)#</td>
		</tr>
	</cfloop>
	</table>
	<p>&nbsp;</p>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">