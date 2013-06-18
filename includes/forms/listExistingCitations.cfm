<cfoutput>
	<cfquery name="getCited" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT
			citation.citation_id,
			citation.publication_id,
			citation.collection_object_id,
			guid_prefix || ':' || cat_num guid,
			PUBLISHED_YEAR,
			identification.scientific_name, 
			citedid.scientific_name as citSciName,
			occurs_page_number,
			type_status,
			citation_remarks,
			full_citation,
			citedid.identification_id citedidid,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID
		FROM 
			citation, 
			cataloged_item,
			collection,
			identification,
			identification citedid,
			publication
		WHERE
			citation.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = collection.collection_id AND
			citation.identification_id = citedid.identification_id AND
			cataloged_item.collection_object_id = identification.collection_object_id (+) AND
			identification.accepted_id_fg = 1 AND
			citation.publication_id = publication.publication_id AND
			citation.publication_id = #publication_id#
		group by
			citation.citation_id,
			citation.publication_id,
			citation.collection_object_id,
			guid_prefix || ':' || cat_num,
			PUBLISHED_YEAR,
			identification.scientific_name, 
			citedid.scientific_name,
			occurs_page_number,
			type_status,
			citation_remarks,
			full_citation,
			citedid.identification_id,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#')
		ORDER BY
			occurs_page_number,citSciName,guid_prefix || ':' || cat_num
	</cfquery>
	<table border="1" cellpadding="0" cellspacing="0">
		<tr>
			<th>&nbsp;</th>
			<th nowrap>GUID</th>
			<th nowrap>#session.CustomOtherIdentifier#</th>
			<th nowrap>Cited As</th>
			<th>Current ID</th>
			<th nowrap>Citation Type</th>
			<th nowrap>Page ##</th>
			<th>Remarks</th>
		</tr>
		<cfset i=1>
		<cfloop query="getCited">
			<tr>
				<td nowrap>
					<table>
						<tr>
							<td>
								<a name="cid#citation_id#"></a>
								<input type="button" 
									value="Delete"
									class="delBtn"
									onClick="deleteCitation(#citation_id#,#publication_id#);">
							</td>
							<td>
								<input type="button" 
									value="Edit" 
									class="lnkBtn"
									onClick="document.location='Citation.cfm?action=editCitation&citation_id=#citation_id#';">
							</td>					
							<td>
								<input type="button" 
									value="Clone" 
									class="insBtn"
									onclick = "makeClone('#guid#');">
							</td>
						</tr>
					</table>
				</td>
				<td>
					<a href="/guid/#guid#">#guid#</a>
				</td>
				<td nowrap="nowrap">#customID#</td>
				<td nowrap><i>#getCited.citSciName#</i>&nbsp;</td>
				<td nowrap><i>#getCited.scientific_name#</i>&nbsp;</td>
				<td nowrap>#getCited.type_status#&nbsp;</td>
				<td>#getCited.occurs_page_number#&nbsp;</td>
				<td nowrap>#getCited.citation_remarks#&nbsp;</td>
			</tr>
			<cfset i=i+1>
		</cfloop>
	</table>
</cfoutput>