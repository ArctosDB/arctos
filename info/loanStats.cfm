<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfquery name="loanData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select 
	 collection,
	 loan.TRANSACTION_ID,
	 loan.loan_number,
	 concattransagent(loan.TRANSACTION_ID,'received by') loaned_to,
	 LOAN_STATUS,
	 RETURN_DUE_DATE,
	 TRANS_DATE
	from
	 loan,
	 trans,
	 collection
	where
	 loan.transaction_id = trans.transaction_id and
	 trans.collection_id=collection.collection_id
</cfquery>
<cfoutput>
<div style="background-color:lightgray;font-size:small;padding:1em;">
	* Citations apply to cataloged items and do not reflect activity resulting from any particular loan.
</div>
<table border id="t" class="sortable">
	<tr>
		<th>Loan</th>
		<th>Loaned To</th>
		<th>Status</th>
		<th>Trans Date</th>
		<th>Due Date</th>
		<th>Items Loaned</th>
		<th>Citations*</th>
	</tr>
	<cfloop query="loanData">
		<tr>
			<td nowrap="nowrap">#collection# <a href="/Loan.cfm?action=editLoan&TRANSACTION_ID=#TRANSACTION_ID#">#loan_number#</a></td>
			<td nowrap="nowrap">#loaned_to#</td>
			<td>#LOAN_STATUS#</td>
			<td nowrap="nowrap">#dateformat(TRANS_DATE,"dd mmm yyyy")#&nbsp;</td>
			<td nowrap="nowrap">#dateformat(RETURN_DUE_DATE,"dd mmm yyyy")#&nbsp;</td>
			<cfquery name="wtf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select 
					collection,
					count(distinct(cataloged_item.collection_object_id)) CntCatNum,
					count(distinct(citation.collection_object_id)) cntCited,
					'part' ltype
				from
					loan_item,
					specimen_part,
					cataloged_item,
					collection,
					citation
				WHERE
					loan_item.collection_object_id = specimen_part.collection_object_id and
					specimen_part.derived_from_cat_item = cataloged_item.collection_object_id and
					cataloged_item.collection_id=collection.collection_id and
					cataloged_item.collection_object_id=citation.collection_object_id (+) and
					transaction_id=#transaction_id#
				group by
					collection
			</cfquery>
			<cfif wtf.recordcount is 0>
				<cfquery name="wtf" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select 
						collection,
						count(distinct(cataloged_item.collection_object_id)) CntCatNum,
						count(distinct(citation.collection_object_id)) cntCited,
						'catitem' ltype
					from
						loan_item,
						cataloged_item,
						collection,
						citation
					WHERE
						loan_item.collection_object_id = cataloged_item.collection_object_id and
						cataloged_item.collection_id=collection.collection_id and
						cataloged_item.collection_object_id=citation.collection_object_id (+) and
						transaction_id=#transaction_id#
					group by
						collection
					</cfquery>
				</cfif>
			<td>
				<cfloop query="wtf">
					#CntCatNum# (#collection#: #ltype#)<br>
				</cfloop>&nbsp;
			</td>
			<td>#wtf.cntCited#&nbsp;</td>
		</tr>
	</cfloop>
</table>

#loanData.recordcount#
</cfoutput>
<cfinclude template="/includes/_footer.cfm">