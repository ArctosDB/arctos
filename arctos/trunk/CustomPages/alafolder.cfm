<cfinclude template="/includes/_header.cfm">
	<script src="/includes/sorttable.js"></script>

<cfif action is "nothing">
	<form action="alafolder.cfm" method="post">
		<input type="hidden" name="action" value="find">
		<label for="barcode">Barcode</label>
		<input type="text" size="80" name="barcode" id="barcode">
		<br>
		<input type="submit" class="lnkClr" value="search">
	</form>
</cfif>
<cfif #action# is "find">
	<cfoutput>
		<cfset bclist="">
		<cfset b=replace(barcode," ","","all")>
		<cfloop list="#b#" index="i">
			<cfif len(#bclist#) is 0>
				<cfset bclist = "'#i#'">
			<cfelse>
				<cfset bclist = "#bclist#,'#i#'">
			</cfif>
		</cfloop>
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select
				collection,
				guid_prefix,
				cat_num,
				ConcatOtherId(cataloged_item.collection_object_id) ids,
				scientific_name,
				c.barcode child,
				p.barcode parent
			from
				cataloged_item,
				collection,
				identification,
				coll_obj_cont_hist,
				container c,
				container p,
				container part,
				specimen_part
			where
				cataloged_item.collection_id=collection.collection_id and
				cataloged_item.collection_object_id=identification.collection_object_id and
				accepted_id_fg=1 and
				cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
				specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
				coll_obj_cont_hist.container_id=part.container_id and
				part.parent_container_id=c.container_id and
				c.parent_container_id=p.container_id (+) and
				c.barcode in (#preservesinglequotes(bclist)#)
		</cfquery>
		<table border="1" id="tbl" class="sortable">
			<tr>
				<th>Item</th>
				<th>ID</th>
				<th>identifiers</th>
				<th>barcode</th>
				<th>parent_barcode</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td nowrap="nowrap">
						<a href="/guid/#guid_prefix#:#cat_num#">#collection# #cat_num#</a>
					</td>
					<td>#scientific_name#</td>
					<td>#replace(ids,";","<br>","all")#</td>
					<td>#child#</td>
					<td>#parent#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">
