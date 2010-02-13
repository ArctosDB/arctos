<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfif action is "c">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select 
				guid,
				scientific_name
			from
				flat,
				loan_item
			where
				flat.collection_object_id=loan_item.collection_object_id and
				transaction_id=#transaction_id#
			order by guid		
		</cfquery>
		<cfloop query="d">
			<br><a href="/guid/#guid#">#guid#</a> #scientific_name#
		</cfloop>
	</cfif>
	<cfif action is "nothing">
		<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			select
				loan.transaction_id,
				collection || ' ' || loan_number l
			from
				loan,
				loan_item,
				cataloged_item,
				collection
			where
				cataloged_item.collection_id=collection.collection_id and
				loan.transaction_id=loan_item.transaction_id and
				loan_item.collection_object_id=cataloged_item.collection_object_id
			group by collection || ' ' || loan_number,loan.transaction_id
			order by collection || ' ' || loan_number
		</cfquery>
		<hr>
		<p>Loans with cataloged items:</p>
		<cfloop query="d">
			<br><a href="uam_catitem_loan.cfm?action=c&transaction_id=#transaction_id#">#l#</a> - 
			<a href="/Loan.cfm?action=editLoan&transaction_id=#transaction_id#">edit loan</a>
		</cfloop>
	</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">