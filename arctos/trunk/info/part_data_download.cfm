<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfoutput>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select
			flat.guid,
			flat.collection,
			flat.cat_num,
			concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
			specimen_part.part_name,
			p.barcode,
			flat.began_date,
			flat.ended_date,
			flat.verbatim_date,
			flat.scientific_name,
			specimen_part.part_modifier,
			specimen_part.preserve_method
		from
			#session.SpecSrchTab#,
			flat,
			cataloged_item,
			specimen_part,
			coll_obj_cont_hist,
			container c,
			container p
		where
			#session.SpecSrchTab#.collection_object_id=cataloged_item.collection_object_id and
			cataloged_item.collection_object_id=flat.collection_object_id and
			cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=c.container_id and
			c.parent_container_id = p.container_id (+)			
	</cfquery>
	<table border="1" id="d" class="sortable">
		<tr>
			<th>Cat Num</th>
			<th>#session.CustomOtherIdentifier#</th>
			<th>Scientific Name</th>
			<th>Began Date</th>
			<th>Ended Date</th>
			<th>Verbatim Date</th>
			<th>Part</th>
			<th>Modifier</th>
			<th>Pres</th>
			<th>InBarcode</th>
		</tr>
		<cfloop query="d">
			<tr>
				<td><a href="/guid/#guid#">#collection# #cat_num#</a></td>
				<td>#CustomID#</td>
				<td>#scientific_name#</td>
				<td>#dateformat(began_date,"dd mon yyyy")#</td>
				<td>#dateformat(ended_date,"dd mon yyyy")#</td>
				<td>#verbatim_date#</td>
				<td>#part_name#</td>
				<td>#part_modifier#</td>
				<td>#preserve_method#</td>
				<td>#barcode#</td>
			</tr>
		</cfloop>
	</table>	
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
