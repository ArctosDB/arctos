<cfset title="Publications By Collection">
<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select collection,collection_id from collection order by collection
</cfquery>
<cfif not isdefined("collection_id")>
	<cfset collection_id="">
</cfif>
<cfoutput>
<form name="f" method="get" action="publicationbycollection.cfm">
	<label for="collection_id">Collection</label>
	<select name="collection_id" id="collection_id" size="1">
		<cfset thiscollectionid=collection_id>
		<cfloop query="ctcollection">
			<option <cfif thiscollectionid is ctcollection.collection_id> selected="selected" </cfif>
				value="#ctcollection.collection_id#">#ctcollection.collection#</option>
		</cfloop>
	</select>
	<p />
	<input type="submit"
		class="lnkBtn"
		value="Submit">
</form>

<cfif len(collection_id) gt 0>
	<cfquery name="citations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			FULL_CITATION,
			publication_id,
			linkage,
			DOI,
			PMID,
			transaction_id,
			c
			from (
			select
				FULL_CITATION,
				publication.publication_id,
				'citation' linkage,
				DOI,
				PMID,
				0 transaction_id,
				count(*) c
			from
				publication,
				citation,
				cataloged_item
			where
				publication.publication_id=citation.publication_id and
				citation.collection_object_id=cataloged_item.collection_object_id and
				cataloged_item.collection_id=#collection_id#
			group by
				FULL_CITATION,
				publication.publication_id,
				'citation',
				DOI,
				PMID,
				0
			union
			select
				FULL_CITATION,
				publication.publication_id,
				'accession project' linkage,
				DOI,
				PMID,
				cataloged_item.ACCN_ID transaction_id,
				count(*) c
			from
				publication,
				project_publication,
				project_trans,
				cataloged_item
			where
				publication.publication_id=project_publication.publication_id and
				project_publication.PROJECT_ID=project_trans.PROJECT_ID and
				project_trans.TRANSACTION_ID=cataloged_item.ACCN_ID and
				cataloged_item.collection_id=#collection_id#
			group by
				FULL_CITATION,
				publication.publication_id,
				'accession project',
				DOI,
				PMID,
				cataloged_item.ACCN_ID
			union
			select
				FULL_CITATION,
				publication.publication_id,
				'specimen loan' linkage,
				DOI,
				PMID,
				loan_item.transaction_id,
				count(*) c
			from
				publication,
				project_publication,
				project_trans,
				loan_item,
				specimen_part,
				cataloged_item
			where
				publication.publication_id=project_publication.publication_id and
				project_publication.PROJECT_ID=project_trans.PROJECT_ID and
				project_trans.TRANSACTION_ID=loan_item.TRANSACTION_ID and
				loan_item.COLLECTION_OBJECT_ID=specimen_part.COLLECTION_OBJECT_ID and
				specimen_part.derived_from_cat_item=cataloged_item.COLLECTION_OBJECT_ID and
				cataloged_item.collection_id=#collection_id#
			group by
				FULL_CITATION,
				publication.publication_id,
				'specimen loan',
				DOI,
				PMID,
				loan_item.transaction_id
			union
			select
				FULL_CITATION,
				publication.publication_id,
				'data loan' linkage,
				DOI,
				PMID,
				loan_item.transaction_id,
				count(*) c
			from
				publication,
				project_publication,
				project_trans,
				loan_item,
				cataloged_item
			where
				publication.publication_id=project_publication.publication_id and
				project_publication.PROJECT_ID=project_trans.PROJECT_ID and
				project_trans.TRANSACTION_ID=loan_item.TRANSACTION_ID and
				loan_item.COLLECTION_OBJECT_ID=cataloged_item.COLLECTION_OBJECT_ID and
				cataloged_item.collection_id=#collection_id#
			group by
				FULL_CITATION,
				publication.publication_id,
				'data loan',
				DOI,
				PMID,
				loan_item.transaction_id
		) group by
			FULL_CITATION,
			publication_id,
			linkage,
			DOI,
			PMID,
			transaction_id,
			c
	</cfquery>
	<cfif citations.recordcount lt 1>
		nothing found<cfabort>
	</cfif>
	<cfquery name="pubs" dbtype="query">
		select
			FULL_CITATION,
			publication_id,
			DOI,
			PMID
		from
			citations
		group by
			FULL_CITATION,
			publication_id,
			DOI,
			PMID
		order by
			full_citation
	</cfquery>
	<table border id="t" class="sortable">
		<tr>
			<th>Publication</th>
			<th>Details</th>
			<th>DOI</th>
			<th>PMID</th>
			<th>Google&nbsp;Scholar</th>
			<th>Citations</th>
			<th>Other&nbsp;Specimens</th>
		</tr>
		<cfloop query="pubs">
			<tr>
				<td>#full_citation#</td>
				<td><a href="/publication/#publication_id#">detail</a></td>
				<td><a href="http://dx.doi.org/#doi#">#doi#</a></td>
				<td><a href="http://www.ncbi.nlm.nih.gov/pubmed/?term=#pmid#">#pmid#</a></td>
				<td><a href="http://scholar.google.com/scholar?hl=en&q=#FULL_CITATION#">[ search ]</a></td>
				<cfquery name="citation" dbtype="query">
					select
						c
					from
						citations
					where
						publication_id=#publication_id# and
						linkage='citation'
				</cfquery>

				<td>
					<cfif citation.recordcount gt 0>
						<a href="/SpecimenResults.cfm?publication_id=#publication_id#">#citation.c# specimens</a>
					</cfif>
				</td>
				<td>
					<cfquery name="acnproj" dbtype="query">
						select
							transaction_id
						from
							citations
						where
							publication_id=#publication_id# and
							linkage='accession project'
						group by
							transaction_id
					</cfquery>
					<cfif acnproj.recordcount gt 0>
						<a href="/SpecimenResults.cfm?accn_trans_id=#valuelist(acnproj.transaction_id)#&collection_id=#collection_id#">Specimens accessioned by projects which use this publication</a>
					</cfif>
					<cfquery name="loanproj" dbtype="query">
						select
							transaction_id
						from
							citations
						where
							publication_id=#publication_id# and
							linkage in ('specimen loan','data loan')
						group by
							transaction_id
					</cfquery>
					<cfif loanproj.recordcount gt 0>
						<br><a href="/SpecimenResults.cfm?accn_trans_id=#valuelist(acnproj.transaction_id)#&collection_id=#collection_id#">Specimens used by projects which use this publication</a>
					</cfif>
				</td>

					<!----
					<cfif linkage is "citation">

					<cfelseif linkage is "accession project">
						<a href="/SpecimenResults.cfm?accn_trans_id=#transaction_id#">#c# specimens</a>
					<cfelseif linkage is "specimen loan">
						<a href="/SpecimenResults.cfm?loan_trans_id=#transaction_id#">#c# specimens</a>
					<cfelseif linkage is "data loan">
						<a href="/SpecimenResults.cfm?loan_trans_id=#transaction_id#">#c# specimens</a>
					</cfif>
					---->
				</td>
			</tr>
		</cfloop>
	</table>
</cfif>
	</cfoutput>
	<cfinclude template="/includes/_footer.cfm">
