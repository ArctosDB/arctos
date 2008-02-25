<cfinclude template="/includes/_header.cfm">
<cfquery name="colls" datasource="#Application.web_user#">
	select 
		collection.collection_cde,
		collection.collection_id,
		institution_acronym,
		descr,
		web_link,
		web_link_text,
		count(cat_num) as cnt
	from 
		collection,
		cataloged_item
	where
		collection.collection_id = cataloged_item.collection_id
	group by
		collection.collection_cde,
		collection.collection_id,		
		institution_acronym,
		descr,
		web_link,
		web_link_text
	order by collection_id
</cfquery>
<cfif #cgi.HTTP_HOST# contains "harvard.edu">
	<span style="font-size:24px; font-weight:bold;">MCZ Holdings</span>
<cfelse>
	<span style="font-size:24px; font-weight:bold;">Arctos Holdings</span>
</cfif>
<br />You may choose to set your default collection in <a href="/login.cfm">Advanced Features</a>. 
<br />Doing so will affect the appearance of
SpecimenSearch and results of specimen queries. 
<br />You may return to "generic view" at any time, also by changing your <a href="/login.cfm">Advanced Features</a>. 
<table border>
<tr>
	<td>
		<strong>Collection Code</strong>
	</td>
	<td>
		<strong>Institution Acronym</strong>
	</td>
	<td>
		<strong>Description</strong>
	</td>
	<td>
		<strong>Website</strong>
	</td>
	<td>
		<strong>Specimens</strong>
	</td>
</tr>
<cfoutput query="colls">
	<tr <cfif #client.exclusive_collection_id# is #collection_id#>style="background-color:##CCFF33" </cfif>>
		<td>
			#COLLECTION_CDE#
		</td>
		<td>
			#INSTITUTION_ACRONYM#
		</td>
		<td>
			#DESCR#
		</td>
		<td>
			<cfif len(#WEB_LINK#) gt 0 and len(#WEB_LINK_TEXT#) gt 0>
				<a href="#WEB_LINK#" target="_blank">#WEB_LINK_TEXT#</a>
			<cfelse>
				None
			</cfif>
		</td>
		<td><a href="/SpecimenSearch.cfm?collection_id=#collection_id#">#cnt#</a></td>
	</tr>
</cfoutput>
</table>
<cfinclude template="/includes/_footer.cfm">