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
			publication.publication_id,
			'citation' linkage,
			DOI,
			PMID,
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
			PMID
	</cfquery>
	<cfif citations.recordcount lt 1>
		nothing found<cfabort>
	</cfif>
	<table border id="t" class="sortable">
		<tr>
			<th>Publication</th>
			<th>Linkage</th>
			<th>DOI</th>
			<th>PMID</th>
			<th>Specimens</th>
		</tr>
		<cfloop query="citations">
			<tr>
				<td>#full_citation#</td>
				<td>#linkage#</td>
				<td>#doi#</td>
				<td>#pmid#</td>
				<td><a href="/SpecimenResults.cfm?publication_id=#publication_id#">#c# specimens</a></td>
			</tr>
		</cfloop>
	</table>
</cfif>
	</cfoutput>
	<cfinclude template="/includes/_footer.cfm">
