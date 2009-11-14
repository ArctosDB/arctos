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
			specimen_part.preserve_method,
			accn.received_date
		from
			#session.SpecSrchTab#,
			flat,
			cataloged_item,
			accn,
			specimen_part,
			coll_obj_cont_hist,
			container c,
			container p
		where
			#session.SpecSrchTab#.collection_object_id=cataloged_item.collection_object_id and
			cataloged_item.collection_object_id=flat.collection_object_id and
			cataloged_item.accn_id=accn.transaction_id and
			cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
			specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
			coll_obj_cont_hist.container_id=c.container_id and
			c.parent_container_id = p.container_id (+)
		order by
			flat.collection,
			flat.cat_num,
			specimen_part.part_name,
			specimen_part.part_modifier,
			specimen_part.preserve_method
	</cfquery>
	<form method="post" action="part_data_download.cfm">
		<input type="hidden" name="action" value="download">
		<label for="fileFormat">Format</label>
		<select name="fileFormat" size="1">
			<option value="csv">CSV</option>
		</select>
		<input type="submit" value="Download">
	</form>
	<cfif action is "nothing">
		<table border="1" id="d" class="sortable">
			<tr>
				<th>CatNum</th>
				<th>#session.CustomOtherIdentifier#</th>
				<th>ScientificName</th>
				<th>BeganDate</th>
				<th>EndedDate</th>
				<th>VerbatimDate</th>
				<th>AccesionedDate</th>
				<th>Part</th>
				<th>Modifier</th>
				<th>Pres</th>
				<th>InBarcode</th>
			</tr>
			<cfloop query="d">
				<tr>
					<td><a href="/guid/#guid#">#collection# #cat_num#</a></td>
					<td>#CustomID#</td>
					<td nowrap="nowrap">#scientific_name#</td>
					<td>#dateformat(began_date,"dd mmm yyyy")#</td>
					<td>#dateformat(ended_date,"dd mmm yyyy")#</td>
					<td>#verbatim_date#</td>
					<td>#dateformat(received_date,"dd mmm yyyy")#</td>
					<td>#part_name#</td>
					<td>#part_modifier#</td>
					<td>#preserve_method#</td>
					<td>#barcode#</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
	<cfif action is "download">
		<cfset ac="CatNum,#session.CustomOtherIdentifier#,ScientificName,BeganDate,EndedDate,VerbatimDate,AccesionedDate,Part,Modifier,Pres,InBarcode">
		<cfset variables.encoding="UTF-8">
		<cfif fileFormat is "csv">
			<cfset fname = "ArctosData_#cfid#_#cftoken#.csv">
			<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
			<cfset header=#trim(ac)#>
			<cfscript>
				variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
				variables.joFileWriter.writeLine(header); 
			</cfscript>
			<cfloop query="d">
				<cfset oneLine = '"#collection# #cat_num#","#CustomID#","#scientific_name#","#dateformat(began_date,"dd mmm yyyy")#","#dateformat(ended_date,"dd mmm yyyy")#","#verbatim_date#","#dateformat(received_date,"dd mmm yyyy")#","#part_name#","#part_modifier#","#preserve_method#","#barcode#"'>
				<cfset oneLine = trim(oneLine)>
				<cfscript>
					variables.joFileWriter.writeLine(oneLine);
				</cfscript>
			</cfloop>
			<cfscript>	
				variables.joFileWriter.close();
			</cfscript>
			<cflocation url="/download.cfm?file=#fname#" addtoken="false">
			<a href="/download/#fname#">Click here if your file does not automatically download.</a>
		<cfelse>
			That file format doesn't seem to be supported yet!
		</cfif>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
