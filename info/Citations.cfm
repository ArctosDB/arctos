<cfinclude template="/includes/_header.cfm">
<cfoutput>
<cfset title="Citation Statistics">
<cfif action is "nothing">
	<h2>Citation Summary</h2>
	<cfquery name="citColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT 
			count(citation.collection_object_id) as cnt,
			collection.guid_prefix,
			collection.collection_id
		FROM
			citation,
			cataloged_item,
			collection
		WHERE
			citation.collection_object_id = cataloged_item.collection_object_id AND
			cataloged_item.collection_id = collection.collection_id
		GROUP BY
			collection.guid_prefix,collection.collection_id
		ORDER BY 
			collection.guid_prefix
	</cfquery>
	<cfquery name="ctcollection" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select guid_prefix,collection_id from collection group by guid_prefix,collection_id order by guid_prefix
	</cfquery>
	<br>NOTE: Number of Citations is not necessarily number of Specimens; if XYZ:Mamm:1 has been cited twice and XYZ:Mamm:2 has been cited once, 
	the number below will be "3" and the link will find two specimens.
	<table border>
		<tr>
			<td>Collection</td>
			<td>Citations</td>
		</tr>
		<cfloop query="citColl">
			<tr>
				<td>#guid_prefix#</td>
				<td>
					<a href="/SpecimenResults.cfm?collection_id=#collection_id#&type_status=any">#cnt#</a>
				</td>
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
				<option value="#collection_id#">#guid_prefix#</option>
			</cfloop>
		</select>
		<br><input type="submit" class="lnkBtn" value="go">
	</form>
</cfif>
<cfif action is "CitTax">
	<cfquery name="cit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		SELECT 
			count(citation.collection_object_id) as cnt,
			accidentification.scientific_name scientific_name,
			citidentification.scientific_name citName
		FROM
			citation,
			identification accidentification,
			identification citidentification,
			cataloged_item
		WHERE
			citation.collection_object_id = cataloged_item.collection_object_id and
			cataloged_item.collection_object_id=accidentification.collection_object_id AND
			accidentification.accepted_id_fg = 1 AND
			citation.identification_id = citidentification.identification_id
			<cfif isdefined("collection_id") and len(collection_id) gt 0>
				and cataloged_item.collection_id=#collection_id#
			</cfif>
		GROUP BY
			accidentification.scientific_name,citidentification.scientific_name
		ORDER BY 
			accidentification.scientific_name
	</cfquery>
	Citations by Collection:
	<table border>
		<tr>
			<td>Accepted Name</td>
			<td>Cited As</td>
			<td>Citations</td>
			<td>Specimens</td>
		</tr>
	<cfloop query="cit">
		<tr>
			<td><a href="/SpecimenUsage.cfm?action=search&current_Sci_Name=#scientific_name#">#scientific_name#</a></td>
			<td>
				<cfif CitName is scientific_name>
					<a href="/SpecimenUsage.cfm?action=search&cited_Sci_Name=#CitName#"><font color="##00FF00">#CitName#</font></a>
				<cfelse>
					<a href="/SpecimenUsage.cfm?action=search&cited_Sci_Name=#CitName#"><font color="##FF0000">#CitName#</font></a>
				</cfif>
			</td>
			<td>
				<a href="/SpecimenResults.cfm?cited_scientific_name=#CitName#&scientific_name=#scientific_name#">[ id+citationID ]</a>
			</td>
		</tr>
	</cfloop>
	</table>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">