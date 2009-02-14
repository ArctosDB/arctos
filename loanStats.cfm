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
				select count(distinct(cat_num)) CntCatNum from
					loan_item,
					specimen_part,
					cataloged_item
				WHERE
					loan_item.collection_object_id = specimen_part.collection_object_id and
					specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and
					transaction_id=#transaction_id#
				<!----
				UNION <!---- cataloged item loans ---->
				select count(distinct(cat_num)) CntCatNum from
					loan_item,
					cataloged_item
				WHERE
					loan_item.collection_object_id = cataloged_item.collection_object_id and
					transaction_id=#transaction_id#
					---->
			</cfquery>
			<cfquery name="wtf2" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select count(distinct(cat_num)) CntCatNum from
					loan_item,
					cataloged_item
				WHERE
					loan_item.collection_object_id = cataloged_item.collection_object_id and
					transaction_id=#transaction_id#
				</cfquery>
			<cfset totNumCit = #wtf.CntCatNum# + #wtf2.CntCatNum#>
			<td>#totNumCit#</td>
		</tr>
	</cfloop>
</table>

#loanData.recordcount#
</cfoutput>