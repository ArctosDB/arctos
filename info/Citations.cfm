<cfinclude template="/includes/_header.cfm">
<cfoutput>
<cfset title="Citation Statistics">
<cfif action is "nothing">
	<h2>Citation Summary</h2>
	<cfquery name="citColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			count(citation.collection_object_id) as cnt,
			collection.collection
		FROM
			citation,
			cataloged_item,
			collection
		WHERE
			citation.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = collection.collection_id
		GROUP BY
			collection.collection
		ORDER BY 
			collection.collection
	</cfquery>
	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collection,collection_id from collection group by collection,collection_id order by collection
	</cfquery>
	<table border>
		<tr>
			<td>Collection</td>
			<td>Citations</td>
		</tr>
		<cfloop query="citColl">
			<tr>
				<td>#collection#</td>
				<td>#cnt#</td>
			</tr>
		</cfloop>
	</table>
	<h2>More Information</h2>
	<form name="a" method="post" action="Citations.cfm">
		<input type="hidden" name="action" value="CitTax">
		<label for="collection_id">Collection</label>
		<select name="collection_id" id="collection_id">
			<option value="">Any</option>
			<cfloop query="ctcollection">
				<option value="#collection_id#">#collection#</option>
			</cfloop>
		</select>
		<label for="ismatch">ID & Citation match?</label>
		<select name="ismatch" id="ismatch">
			<option value="">whatever</option>
			<option value="1">yes</option>
			<option value="0">no</option>
		</select>
		<br><input type="submit" class="lnkBtn" value="go">
	</form>
</cfif>


<cfif action is "CitTax">
	<cfquery name="cit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		SELECT 
			count(citation.collection_object_id) as cnt,
			identification.scientific_name scientific_name,
			taxonomy.scientific_name citName
		FROM
			citation,
			identification,
			taxonomy,
			cataloged_item
		WHERE
			citation.collection_object_id = cataloged_item.collection_object_id and
			cataloged_item.collection_object_id=identification.collection_object_id AND
			identification.accepted_id_fg = 1 AND
			citation.cited_taxon_name_id = citName.taxon_name_id
			<cfif isdefined("collection_id") and len(collection_id) gt 0>
				and cataloged_item.collection_id=#collection_id#
			</cfif>
			<cfif isdefined("ismatch") and ismatch is 0>
				and identification.scientific_name != taxonomy.scientific_name
			<cfelseif isdefined("ismatch") and ismatch is 1>
				and identification.scientific_name = taxonomy.scientific_name
			</cfif>
		GROUP BY
			identification.scientific_name,taxonomy.scientific_name
		ORDER BY 
			scientific_name
	</cfquery>
	Citations by Taxonomy:<a name="CitTax"></a> <a href="##top"><i><font size="-1">Top</font></i></a>
	<table border>
		<tr>
			<td>Accepted Name</td>
			<td>Cited As</td>
			<td>Citations</td>
		</tr>
	<cfloop query="cit">
		<tr>
			<td><a href="/SpecimenUsage.cfm?action=search&current_Sci_Name=#scientific_name#">#scientific_name#</a></td>
			<td>
				<cfif #CitName# is #scientific_name#>
					<a href="/SpecimenUsage.cfm?action=search&cited_Sci_Name=#CitName#"><font color="##00FF00">#CitName#</font></a>
				<cfelse>
					<a href="/SpecimenUsage.cfm?action=search&cited_Sci_Name=#CitName#"><font color="##FF0000">#CitName#</font></a>
				</cfif>
				
			</td>
			<td>
				<cfquery name="wtf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					SELECT 
						citation.collection_object_id
					FROM
						citation,
						identification,
						taxonomy
					WHERE
						citation.collection_object_id = identification.collection_object_id AND
						identification.accepted_id_fg = 1 AND
						citation.cited_taxon_name_id = taxonomy.taxon_name_id and
						identification.scientific_name='#scientific_name#' and 
						taxonomy.scientific_name='#CitName#'
				</cfquery>
				<a href="/SpecimenResults.cfm?collection_object_id=#valuelist(wtf.collection_object_id)#">#cnt#</a>
			</td>
		</tr>
	</cfloop>
	</table>
	
	</cfif>


</cfoutput>

<cfinclude template="/includes/_footer.cfm">
