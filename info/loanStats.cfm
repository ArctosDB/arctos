<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>
<cfset title="Loan and Citation statistics">
<form name="f" method="get" action="loanStats.cfm">
	<label for="loanto">Loaned To Person</label>
	<input type="text" name="loanto" id="loanto">
	<br><input type="submit" value="filter">
</form>
<cfquery name="loanData" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
	select 
	collection,
	collection_id,
	TRANSACTION_ID,
	loan_number,
	loaned_to,
	LOAN_STATUS,
	RETURN_DUE_DATE,
	TRANS_DATE,
	count(distinct(derived_from_cat_item)) CntCatNum,
	count(distinct(citationID)) cntCited
	from (
		select 
			collection,
			collection.collection_id,
			loan.TRANSACTION_ID,
			loan.loan_number,
			concattransagent(loan.TRANSACTION_ID,'received by') loaned_to,
			LOAN_STATUS,
			RETURN_DUE_DATE,
			TRANS_DATE,
			specimen_part.derived_from_cat_item,
			citation.collection_object_id citationID
		from
			loan,
			trans,
			loan_item,
			specimen_part,
			citation,
			collection
		where
			loan.transaction_id = trans.transaction_id and
			trans.collection_id=collection.collection_id and
			loan.transaction_id=loan_item.transaction_id (+) and
			loan_item.collection_object_id=specimen_part.collection_object_id (+) and
			specimen_part.derived_from_cat_item=citation.collection_object_id (+)	union
		select 
			collection,
			collection.collection_id,
			loan.TRANSACTION_ID,
			loan.loan_number,
			concattransagent(loan.TRANSACTION_ID,'received by') loaned_to,
			LOAN_STATUS,
			RETURN_DUE_DATE,
			TRANS_DATE,
			specimen_part.derived_from_cat_item,
			citation.collection_object_id citationID
		from
			loan,
			trans,
			loan_item,
			specimen_part,
			citation,
			collection
		where
			loan.transaction_id = trans.transaction_id and
			trans.collection_id=collection.collection_id and
			loan.transaction_id=loan_item.transaction_id (+) and
			loan_item.collection_object_id=specimen_part.derived_from_cat_item (+) and
			loan_item.collection_object_id=citation.collection_object_id (+)
	) 
	where 1=1
	<cfif len(loanto) gt 0>
		and upper(loaned_to) like '%#ucase(loanto)#%'
	</cfif>
	group by
		collection,
		collection_id,
		TRANSACTION_ID,
		loan_number,
		loaned_to,
		LOAN_STATUS,
		RETURN_DUE_DATE,
		TRANS_DATE
</cfquery>
<cfoutput>
	<h2>Loan Statistics</h2>
<div style="background-color:lightgray;font-size:small;padding:1em; width:50%; align:center;margin-left:3em;margin:1em;">
	Citations apply to cataloged items and do not reflect activity resulting from any particular loan.
	<p>
		Each line is one loan/collection/citation combination; information may be repeated. Showing #loanData.recordcount# rows.
	</p>
	<p>
		Click headers to sort.
	</p>
</div>
<table border id="t" class="sortable">
	<tr>
		<th>Collection</th>
		<th>Loan</th>
		<th>Loaned To</th>
		<th>Status</th>
		<th>Trans Date</th>
		<th>Due Date</th>
		<th>Items Loaned</th>
		<th>Citations</th>
	</tr>
	<cfloop query="loanData">
		<tr>
			<td nowrap="nowrap">#collection#</td>
			<td nowrap="nowrap"><a href="/Loan.cfm?action=editLoan&TRANSACTION_ID=#TRANSACTION_ID#">#loan_number#</a></td>
			<td nowrap="nowrap">#loaned_to#</td>
			<td>#LOAN_STATUS#</td>
			<td nowrap="nowrap">#dateformat(TRANS_DATE,"dd mmm yyyy")#&nbsp;</td>
			<td nowrap="nowrap">#dateformat(RETURN_DUE_DATE,"dd mmm yyyy")#&nbsp;</td>
			<td>
				<a href="/SpecimenResults.cfm?loan_trans_id=#loanData.TRANSACTION_ID#&collection_id=#loanData.collection_id#">#CntCatNum#</a>
			</td>
			<td><a href="/SpecimenResults.cfm?loan_trans_id=#loanData.TRANSACTION_ID#&collection_id=#loanData.collection_id#&type_status=any">
					#cntCited#</a>&nbsp;
			</td>
		</tr>
	</cfloop>
</table>


</cfoutput>
<cfinclude template="/includes/_footer.cfm">