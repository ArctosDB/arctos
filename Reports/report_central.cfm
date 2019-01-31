<!----
report_central.cfm
for https://github.com/ArctosDB/arctos/issues/1419


-- Overdue loans


select
	guid_prefix,
	count(*) c
from
	loan,
	trans,
	collection
where
	loan.transaction_id=trans.transaction_id and
	trans.collection_id=collection.collection_id and
	loan.loan_status != 'closed' and
	(loan.RETURN_DUE_DATE is null or loan.RETURN_DUE_DATE > sysdate)
group by
	guid_prefix
order by
	guid_prefix;


-- list of names

			select
			    taxon_name.scientific_name
			  from
			    identification_taxonomy,
			    identification,
			    cataloged_item,
			    collection,
			    taxon_name
			  where
			    identification_taxonomy.identification_id=identification.identification_id and
			    identification.collection_object_id=cataloged_item.collection_object_id and
			    cataloged_item.collection_id=collection.collection_id and
			    identification_taxonomy.taxon_name_id=taxon_name.taxon_name_id and
			    collection.guid_prefix='APSU:Herp' and
			    taxon_name.taxon_name_id not in
			    (select taxon_name_id from taxon_term where
			      taxon_term.taxon_name_id = taxon_name.taxon_name_id and
			      taxon_term.source=collection.PREFERRED_TAXONOMY_SOURCE
			      )
			;


select
   collection.guid_prefix || ':' || cataloged_item.cat_num guid,
	part_name,
	COLL_OBJECT_ENTERED_DATE
from
   coll_object,
   specimen_part,
   cataloged_item,
   collection
 where
   coll_object.collection_object_id=specimen_part.collection_object_id and
   specimen_part.derived_from_cat_item=cataloged_item.collection_object_id and
   cataloged_item.collection_id=collection.collection_id and
   coll_object.COLL_OBJ_DISPOSITION='being processed' and
   sysdate-coll_object.COLL_OBJECT_ENTERED_DATE>365 and
	guid_prefix='UAM:Mamm'
order by
	collection.guid_prefix || ':' || cataloged_item.cat_num,
	part_name
;




---->

<!--- get data for collections in which this user is a contact ---->
<cfquery name="cnc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#" >
	select
		cf_report_cache.GUID_PREFIX,
		REPORT_NAME,
		REPORT_URL,
		REPORT_DESCR,
		REPORT_DATE,
		SUMMARY_DATA
	from
		cf_report_cache,
		collection,
		collection_contacts
	where
		cf_report_cache.guid_prefix=collection.guid_prefix and
		collection.collection_id=collection_contacts.collection_id and
		collection_contacts.CONTACT_AGENT_ID=#session.myAgentID#
	order by
		cf_report_cache.GUID_PREFIX,
		REPORT_NAME
</cfquery>
<cfif cnc.recordcount gt 0>
	<script src="/includes/sorttable.js"></script>
	<cfoutput>
	<table border id="t" class="sortable">
		<tr>
			<th>Collection</th>
			<th>Report</th>
			<th>Link</th>
			<th>Detail</th>
			<th>CacheDate</th>
		</tr>
		<cfloop query="cnc">
			<tr>
				<td>#GUID_PREFIX#</td>
				<td>#REPORT_NAME#</td>
				<td>#REPORT_URL#</td>
				<td>#SUMMARY_DATA#</td>
				<td>#REPORT_DATE#</td>
			</tr>
		</cfloop>
	</table>
	</cfoutput>

</cfif>


<cfdump var=#cnc#>