<cfinclude template="/includes/_header.cfm">
<cfquery name="uamloan" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
		loan.transaction_id,
		loan_number,
		trans.institution_acronym
	from
		loan,trans
		where
		loan.transaction_id=trans.transaction_id and
		trans.institution_acronym='UAM' and
		loan_number not like '%Paleo%'
</cfquery>
<cfoutput>
	<table border>
	<cfloop query="uamloan">
		<tr>
			<td><a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">#loan_number#</a></td>
			<cfif len(loan_number) is 13 and loan_number contains "Mamm">
				<td>spiffy</td>
			<cfelse>
				<cfquery name="spec" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select collection from 
						loan_item,
						cataloged_item,
						collection
					where
						loan_item.collection_object_id=cataloged_item.collection_object_id and
						cataloged_item.collection_id=collection.collection_id and
						loan_item.transaction_id=#transaction_id#
					group by
						collection
					UNION
					select collection from 
						loan_item,
						specimen_part,
						cataloged_item,
						collection
					where
						loan_item.collection_object_id=specimen_part.collection_object_id and
						specimen_part.derived_from_cat_item=cataloged_item.collection_id and
						cataloged_item.collection_id=collection.collection_id and
						loan_item.transaction_id=#transaction_id#
					group by
						collection						
				</cfquery>
				<td>#valuelist(spec.collection)#</td>
			</cfif>
		</tr>
	</cfloop>
	</table>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">