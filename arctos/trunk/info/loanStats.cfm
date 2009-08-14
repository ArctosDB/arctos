<cfinclude template="/includes/_header.cfm">
<cfquery name="loanData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
 select 
	 loan.TRANSACTION_ID,
	 agent_name loaned_to,
	 LOAN_STATUS,
	 RETURN_DUE_DATE,
	 count(collection_object_id) numItems
 from
	 loan,
	 trans,
	 preferred_agent_name,
	 loan_item
 where
	 loan.transaction_id = trans.transaction_id and
	 trans.RECEIVED_AGENT_ID = preferred_agent_name.agent_id and
	 loan.transaction_id = loan_item.transaction_id (+)
GROUP BY
	loan.TRANSACTION_ID,
	 agent_name,
	 LOAN_STATUS,
	 RETURN_DUE_DATE
</cfquery>
<cfoutput>
<table border>
	<tr>
		<td>Loaned To</td>
		<td>Status</td>
		<td>Due Date</td>
		<td>Num Items Loaned</td>
		<td>Citations</td>
	</tr>
	<cfloop query="loanData">
		<tr>
			<td>#loaned_to#</td>
			<td>#LOAN_STATUS#</td>
			<td>#dateformat(RETURN_DUE_DATE,"dd mmm yyyy")#</td>
			<td>#numItems#</td>
			<cfquery name="wtf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					collection,
					count(*) CntCatNum,
					'part' ltype
				from
					loan_item,
					specimen_part,
					cataloged_item,
					collection
				WHERE
					loan_item.collection_object_id = specimen_part.collection_object_id and
					specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and
					cataloged_item.collection_id=collection.collection_id and
					transaction_id=#transaction_id#
				group by
					collection
			</cfquery>
			<cfif wtf.recordcount is 0>
				<cfquery name="wtf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						collection,
						count(*) CntCatNum,
						'catitem' ltype
					from
						loan_item,
						cataloged_item,
						collection
					WHERE
						loan_item.collection_object_id = cataloged_item.collection_object_id and
						cataloged_item.collection_id=collection.collection_id and
						transaction_id=#transaction_id#
					group by
						collection
					</cfquery>
				</cfif>
			<td>
				<cfloop query="wtf">
					#collection#: #CntCatNum# (#ltype#)<br>
				</cfloop>
			</td>
		</tr>
	</cfloop>
</table>

#loanData.recordcount#
</cfoutput>
<cfinclude template="/includes/_footer.cfm">