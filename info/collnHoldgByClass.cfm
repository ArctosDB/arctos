<cfinclude template = "/includes/_header.cfm">
<cfset title = "Collections Holdings By Class">
<cfoutput>
<script src="/includes/sorttable.js"></script>
<cfquery name="d" datasource="uam_god">
	select 
		nvl(phylclass,'NULL') phylclass,
		collection.collection_id,
		collection,
		count(*) c
	from
		collection,
		cataloged_item,
		identification,
		identification_taxonomy,
		taxonomy
	where
		collection.collection_id=cataloged_item.collection_id and
		cataloged_item.collection_object_id=identification.collection_object_id and
		identification.identification_id=identification_taxonomy.identification_id and
		identification_taxonomy.taxon_name_id=taxonomy.taxon_name_id
	group by
		collection,
		phylclass,
		collection.collection_id
	order by
		collection,
		phylclass
</cfquery>
<table border id="t" class="sortable">
	<tr>
		<th>Collection</th>
		<th>Class</th>
		<th>##</th>
	</tr>
	<cfloop query="d">
		<tr>
			<td>#collection#</td>
			<td>#phylclass#</td>
			<td><a href="/SpecimenResults.cfm?collection_id=#collection_id#&phylclass=#phylclass#">#c#</a></td>
		</tr>
	</cfloop>
</cfoutput>
<cfinclude template = "/includes/_footer.cfm">