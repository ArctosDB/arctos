<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="part/loan summary">
<cfoutput>
	<cfquery name="raw" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select
		flat.guid,
		concatSingleOtherId(cataloged_item.collection_object_id,'#session.CustomOtherIdentifier#') AS CustomID,
		specimen_part.part_name,
		specimen_part.collection_object_id partID,
		p.barcode,
		flat.began_date,
		flat.ended_date,
		flat.verbatim_date,
		flat.scientific_name,
		accn.received_date,
		loan.loan_number,
		trans.TRANS_DATE,
		specimen_part.SAMPLED_FROM_OBJ_ID
	from
		#session.SpecSrchTab#,
		flat,
		cataloged_item,
		accn,
		specimen_part,
		coll_obj_cont_hist,
		container c,
		container p,
		loan_item,
		loan,
		trans
	where
		#session.SpecSrchTab#.collection_object_id=cataloged_item.collection_object_id and
		cataloged_item.collection_object_id=flat.collection_object_id and
		cataloged_item.accn_id=accn.transaction_id and
		cataloged_item.collection_object_id=specimen_part.derived_from_cat_item and
		specimen_part.collection_object_id=coll_obj_cont_hist.collection_object_id and
		coll_obj_cont_hist.container_id=c.container_id and
		c.parent_container_id = p.container_id (+) and
		specimen_part.collection_object_id=loan_item.collection_object_id (+) and
		loan_item.transaction_id=loan.transaction_id (+) and
		loan.transaction_id=trans.transaction_id (+)
	order by
		flat.guid,
		specimen_part.part_name,
		loan_number
</cfquery>
<cfquery name="d" dbtype="query">
	select
		guid,
		partID,
		CustomID,
		part_name,
		barcode,
		began_date,
		ended_date,
		verbatim_date,
		scientific_name,
		received_date,
		SAMPLED_FROM_OBJ_ID
	from raw group by
		guid,
		partID,
		CustomID,
		part_name,
		barcode,
		began_date,
		ended_date,
		verbatim_date,
		scientific_name,
		received_date,
		SAMPLED_FROM_OBJ_ID
</cfquery>

<cfif action is "nothing">
	<a href="part_data_download.cfm?action=download">Download</a>
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
			<th>InBarcode</th>
			<th>Loan</th>
		</tr>
		<cfloop query="d">
			<tr>
				<td><a href="/guid/#guid#">#guid#</a></td>
				<td>#CustomID#</td>
				<td nowrap="nowrap">#scientific_name#</td>
				<td>#began_date#</td>
				<td>#ended_date#</td>
				<td>#verbatim_date#</td>
				<td>#dateformat(received_date,"yyyy-mm-dd")#</td>
				<td>
					#part_name#
					<cfif SAMPLED_FROM_OBJ_ID gt 0>
						(subsample)
					</cfif>
				</td>
				<td>#barcode#</td>
				<cfquery name="l" dbtype="query">
					select
						loan_number,
						TRANS_DATE
					from
						raw
					where
						partID=#partID# and
						loan_number is not null
					group by
						loan_number,
						TRANS_DATE
					order by
						loan_number,
						TRANS_DATE
				</cfquery>
				<td>
					<cfset ll=''>
					<cfloop query="l">
						<cfset ll=listappend(ll,"#loan_number# (#dateformat(TRANS_DATE,'yyyy-mm-dd')#)",";")>
					</cfloop>
					#ll#
				</td>
			</tr>
		</cfloop>
	</table>
</cfif>
<cfif action is "download">
	<cfset ac="GUID,#session.CustomOtherIdentifier#,ScientificName,BeganDate,EndedDate,VerbatimDate,AccesionedDate,Part,Modifier,Pres,InBarcode,Loan">
	<cfset variables.encoding="UTF-8">
	<cfset fname = "ArctosData_#left(session.sessionKey,10)#.csv">
	<cfset variables.fileName="#Application.webDirectory#/download/#fname#">
	<cfset header=#trim(ac)#>
	<cfscript>
		variables.joFileWriter = createObject('Component', '/component.FileWriter').init(variables.fileName, variables.encoding, 32768);
		variables.joFileWriter.writeLine(header); 
	</cfscript>
	<cfloop query="d">
		<cfset oneLine = '"#guid#","#CustomID#","#scientific_name#","#began_date#","#ended_date#","#verbatim_date#","#dateformat(received_date,"yyyy-mm-dd")#",'>
		<cfif SAMPLED_FROM_OBJ_ID gt 0>
			<cfset p=part_name & ' (subsample)'>
		<cfelse>
			<cfset p=part_name>
		</cfif>
		<cfset oneLine=oneLine & '"#p#","#barcode#"'>
		<cfquery name="l" dbtype="query">
			select
				loan_number,
				TRANS_DATE
			from
				raw
			where
				partID=#partID# and
				loan_number is not null
			group by
				loan_number,
				TRANS_DATE
			order by
				loan_number,
				TRANS_DATE
		</cfquery>
		<cfset ll=''>
		<cfloop query="l">
			<cfset ll=listappend(ll,"#loan_number# (#dateformat(TRANS_DATE,'yyyy-mm-dd')#)",";")>
		</cfloop>
		<cfset oneLine=oneLine & ',"#ll#"'>
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
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">