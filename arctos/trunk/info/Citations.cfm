<cfinclude template="/includes/_pickHeader.cfm">
<cfoutput>

	<cfset title="Citation Statistics">
<table>
	<tr>
	  <td valign="top" align="left" nowrap>
	  <a name="top">
	    <br>
			<a href="##CitTax">Citations by Taxonomy</a>		  <br>
	    <a href="##CitColl">Citations by Collection</a>		</td>
	
		<td>
		
	<cfquery name="cit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			count(citation.collection_object_id) as cnt,
			identification.scientific_name scientific_name,
			citName.scientific_name citName
		FROM
			citation,
			identification,
			taxonomy citName
		WHERE
			citation.collection_object_id = identification.collection_object_id AND
			identification.accepted_id_fg = 1 AND
			citation.cited_taxon_name_id = citName.taxon_name_id
		GROUP BY
			identification.scientific_name,citName.scientific_name
		ORDER BY 
			scientific_name
	</cfquery>
	Citations by Taxonomy:<a name="CitTax"></a> <a href="##top"><i><font size="-1">Top</font></i></a><table border>
		<tr>
			<td>Accepted Name</td>
			<td>Cited As</td>
			<td>Citations</td>
		</tr>
	
	
	<cfloop query="cit">
		<tr>
			<td><a href="/PublicationResults.cfm?current_Sci_Name=#scientific_name#">#scientific_name#</a></td>
			<td>
				<cfif #CitName# is #scientific_name#>
					<a href="/PublicationResults.cfm?cited_Sci_Name=#CitName#"><font color="##00FF00">#CitName#</font></a>
				<cfelse>
					<a href="/PublicationResults.cfm?cited_Sci_Name=#CitName#"><font color="##FF0000">#CitName#</font></a>
				</cfif>
				
			</td>
			<td>#cnt#</td>
		</tr>
	</cfloop>
	</table>
	
	<cfquery name="citColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			count(citation.collection_object_id) as cnt,
			collection.collection_cde,
			collection.institution_acronym
		FROM
			citation,
			cataloged_item,
			collection
		WHERE
			citation.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = collection.collection_id
		GROUP BY
			collection.collection_cde,
			collection.institution_acronym
		ORDER BY 
			collection.collection_cde,
			collection.institution_acronym
	</cfquery>
	<a name="CitColl">
	<br>Citations by Collection:<a href="##top"><i><font size="-1">Top</font></i></a>
	<table border>
		<tr>
			
			<td>Collection</td>
			<td>Citations</td>
		</tr>
	<cfloop query="citColl">
		<tr>
			<td>#institution_acronym# #collection_cde#</td>
			<td>#cnt#</td>
		</tr>
	</cfloop>
	</table>
</td>
	</tr>
</table>

<br><a href="javascript: void(0);" onClick="javascript: self.close()">Close this window</a>

</cfoutput>

<cfinclude template="/includes/_pickFooter.cfm">
