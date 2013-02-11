<cfset title="Publications By Collection">
<cfinclude template="includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select collection,collection_id from collection order by collection
</cfquery>
<cfif not isdefined("collection_id")>
	<cfset collection_id="">
</cfif>
<form name="f" method="post" action="publicationbycollection.cfm">
	<input type="hidden" name="action"  value="fetch">
	<label for="collection_id">Collection</label>
	<select name="collection_id" id="collection_id" size="1">
		<cfloop query="ctcollection">
			<option <cfif variables.collection_id is ctcollection.collection_id> selected="selected" </cfif>
				value="#ctcollection.collection_id#">#ctcollection.collection_id#</option>
		</cfloop>
	</select>
	<p />
	<input type="button"
		class="lnkBtn"
		value="Submit">
</form>

<cfif len(collection_id) gt 0>
	<cfquery name="citations" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select
			FULL_CITATION
		from
			publication,
			citation,
			cataloged_item
		where
			publication.publication_id=citation.publication_id and
			citation.collection_object_id=cataloged_item.collection_object_id and
			cataloged_item.collection_id=#collection_id#
	</cfquery>
	<cfif citations.recordcount lt 1>
		nothing found<cfabort>
	</cfif>
	<table border class="sortable">
		<tr>
			<th>Publication</th>
		</tr>
		<cfloop query="citations">
			<tr>
				<td>#full_citation#</td>
			</tr>
		</cfloop>
	</table>
</cfif>